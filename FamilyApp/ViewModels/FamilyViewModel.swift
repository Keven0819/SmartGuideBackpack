//
// FamilyViewModel.swift
// SmartGuideBackpack
//
// Created by imac-3570 on 2025/10/9.
//

import Foundation
import CoreLocation
import SmartGuideServices

class FamilyViewModel: ObservableObject {
    // MARK: -- Singleton
    static let shared = FamilyViewModel()
    
    // MARK: -- Published 屬性
    @Published var targetCoordinate: CLLocationCoordinate2D?
    @Published var sosAddress: String?
    @Published var connectionStatus: String = "未連線"
    @Published var fallAnalysisList: [FallAnalysis] = []
    
    // MARK: -- 私有屬性
    private var webSocketTask: URLSessionWebSocketTask?
    private var latestSOSTime: TimeInterval?
    private let sosTimestampKey = "LatestSOSTime"
    private var reconnectTimer: Timer?
    
    // MARK: -- WebSocket URL
    private let wsURL = URL(string: "ws://172.20.10.11:3001/ws/family")!
    
    // MARK: -- HTTP 客戶端（保留作為備用）
    let Location_SOS_Client = HTTPClient(baseURL: URL(string: "https://smart-guide-backend-beta.vercel.app")!)
    let GPS_SOS_Client = HTTPClient(baseURL: URL(string: "gps_sos")!)
    let GPS_Guide_Client = HTTPClient(baseURL: URL(string: "gps_guide")!)
    
    init() {
        latestSOSTime = UserDefaults.standard.double(forKey: sosTimestampKey)
        connectWebSocket()
    }
    
    // MARK: -- WebSocket 連線
    func connectWebSocket() {
        webSocketTask = URLSession.shared.webSocketTask(with: wsURL)
        webSocketTask?.resume()
        
        DispatchQueue.main.async {
            self.connectionStatus = "已連線"
        }
        
        print("🔌 家人端 WebSocket 已連線")
        receiveMessage()
    }
    
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        reconnectTimer?.invalidate()
        
        DispatchQueue.main.async {
            self.connectionStatus = "已斷線"
        }
        
        print("🔌 家人端 WebSocket 已斷線")
    }
    
    // MARK: -- 接收 WebSocket 訊息
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleWebSocketMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // 繼續接收下一條訊息
                self?.receiveMessage()
                
            case .failure(let error):
                print("❌ 家人端 WebSocket 接收錯誤: \(error)")
                
                DispatchQueue.main.async {
                    self?.connectionStatus = "連線中斷"
                }
                
                // 嘗試重新連線
                self?.scheduleReconnect()
            }
        }
    }
    
    // MARK: -- 處理接收到的訊息
    private func handleWebSocketMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            print("⚠️ 無法解析訊息: \(text)")
            return
        }
        
        DispatchQueue.main.async {
            switch type {
            // ========== 位置更新 ==========
            case "location_update":
                if let lat = json["lat"] as? Double,
                   let lng = json["lng"] as? Double {
                    self.targetCoordinate = CLLocationCoordinate2D(
                        latitude: lat,
                        longitude: lng
                    )
                    print("📍 收到位置更新: \(lat), \(lng)")
                }
                
            // ========== SOS 警報 ==========
            case "sos_alert":
                if let lat = json["lat"] as? Double,
                   let lng = json["lng"] as? Double,
                   let timestamp = json["timestamp"] as? TimeInterval,
                   let address = json["address"] as? String {
                    
                    // 檢查是否為新的 SOS（避免重複通知）
                    if self.latestSOSTime != timestamp {
                        self.latestSOSTime = timestamp
                        UserDefaults.standard.set(timestamp, forKey: self.sosTimestampKey)
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        self.targetCoordinate = coordinate
                        self.sosAddress = address
                        
                        // 發送本地通知
                        let notificationBody = "有人在 \(address) 發出 SOS !"
                        NotificationService.shared.scheduleLocalNotification(
                            title: "🚨 SOS 警報",
                            body: notificationBody
                        )
                        
                        print("🚨 收到 SOS 警報: \(address)")
                    }
                }
                
            // ========== SOS 清除 ==========
            case "sos_cleared":
                self.sosAddress = nil
                self.latestSOSTime = nil
                UserDefaults.standard.removeObject(forKey: self.sosTimestampKey)
                print("✅ SOS 警報已清除")
                
            // ========== 跌倒分析 ==========
            case "fall_gsensor_analysis":
                self.handleFallAnalysis(json: json)
                
            default:
                print("⚠️ 未知訊息類型: \(type)")
            }
        }
    }
    
    // MARK: -- 清除 SOS 警報
    func clearSOSAlert() {
        sosAddress = nil
        latestSOSTime = 0
        UserDefaults.standard.removeObject(forKey: sosTimestampKey)
        
        // 透過 WebSocket 通知後端
        let message: [String: Any] = [
            "type": "clear_sos"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("❌ 清除 SOS 失敗: \(error)")
            } else {
                print("✅ 已通知後端清除 SOS")
            }
        }
    }
    
    // MARK: -- 自動重新連線
    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            print("🔄 嘗試重新連線...")
            self?.connectWebSocket()
        }
    }
    
    // MARK: -- 處理跌倒分析
    private func handleFallAnalysis(json: [String: Any]) {
        guard let timestamp = json["timestamp"] as? Int,
              let sceneDescription = json["scene_description"] as? String,
              let situationAnalysis = json["situation_analysis"] as? String,
              let messageToUser = json["message_to_user"] as? String else {
            print("⚠️ 跌倒分析資料解析失敗")
            return
        }
        
        let imageBase64 = json["image_base64"] as? String ?? ""
        
        let fallAnalysis = FallAnalysis(
            type: "fall_gsensor_analysis",
            timestamp: timestamp,
            imageBase64: imageBase64,
            sceneDescription: sceneDescription,
            situationAnalysis: situationAnalysis,
            messageToUser: messageToUser
        )
        
        self.fallAnalysisList.insert(fallAnalysis, at: 0)
        
        // 發送本地通知
        NotificationService.shared.scheduleLocalNotification(
            title: "⚠️ 跌倒偵測警報",
            body: messageToUser
        )
        
        print("🚨 收到跌倒分析: \(sceneDescription)")
    }
    
    // MARK: -- 清除跌倒分析記錄
    func clearFallAnalysisList() {
        fallAnalysisList.removeAll()
    }
    
    // MARK: -- 清理
    deinit {
        disconnectWebSocket()
    }
}
