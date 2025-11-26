//
//  MainViewModel.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/10.
//

import Foundation
import Combine
import CoreLocation
import SmartGuideServices

class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentAddress: String?
    @Published var uploadStatus: String?
    @Published var navigationSignal: String?
    @Published var navigationInstruction: String?
    
    // MARK: - WebSocket
    private var webSocketTask: URLSessionWebSocketTask?
    private let wsURL = URL(string: "ws://192.168.1.11:3001/ws/ios")!
    
    // MARK: - Location
    private var locationCancellable: AnyCancellable?
    private var headingCancellable: AnyCancellable?
    private var addressCancellable: AnyCancellable?
    
    init() {
        observeLocation()
    }
    
    // MARK: - 觀察位置變化
    func observeLocation() {
        locationCancellable = LocationService.shared.$coordinate
            .compactMap { $0 }
            .sink { [weak self] coord in
                self?.sendLocationUpdate(coord: coord)
            }
        
        headingCancellable = LocationService.shared.$heading
            .sink { [weak self] heading in
                // heading 會隨著位置一起發送
            }
        
        addressCancellable = LocationService.shared.$address
            .sink { [weak self] address in
                self?.currentAddress = address
            }
    }
    
    func startUpdating() {
        // LocationService 已經在背景運行
        print("✅ 開始監聽位置")
    }
    
    // MARK: - WebSocket 連線
    func connectWebSocket() {
        webSocketTask = URLSession.shared.webSocketTask(with: wsURL)
        webSocketTask?.resume()
        print("🔌 WebSocket 已連線")
        
        // 開始接收訊息
        receiveMessage()
    }
    
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("🔌 WebSocket 已斷線")
    }
    
    // MARK: - 接收 WebSocket 訊息
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
                print("❌ WebSocket 接收錯誤: \(error)")
            }
        }
    }
    
    // MARK: - 處理接收到的訊息
    private func handleWebSocketMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            // 處理舊格式（map/nomap/sos）
            DispatchQueue.main.async {
                self.navigationSignal = text
            }
            return
        }
        
        DispatchQueue.main.async {
            switch type {
            case "location_ack":
                if let status = json["status"] as? String, status == "ok" {
                    self.uploadStatus = "位置即時更新"
                }
                
            case "sos_ack":
                if let status = json["status"] as? String {
                    if status == "success" {
                        self.uploadStatus = "SOS 已發送"
                    } else {
                        self.uploadStatus = json["message"] as? String ?? "SOS 發送失敗"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.uploadStatus = nil
                    }
                }
                
            case "navigation_signal":
                self.navigationSignal = json["signal"] as? String
                
            case "navigation_instruction":
                self.navigationInstruction = json["instruction"] as? String
                
            case "clear_sos_ack":
                // 家人端已清除 SOS 警報
                print("✅ SOS 警報已被家人清除")
                // 如果需要可以顯示提示
                // self.uploadStatus = "SOS 已解除"

            case "sos_cleared":
                // 所有端都收到 SOS 已清除的通知
                print("✅ SOS 已清除")
                
            default:
                print("⚠️ 未知訊息類型: \(type)")
            }
        }
    }
    
    // MARK: - 發送位置更新（透過 WebSocket）
    private func sendLocationUpdate(coord: CLLocationCoordinate2D) {
        guard let webSocketTask = webSocketTask else { return }
        
        let heading = LocationService.shared.heading?.trueHeading ?? 0
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        let message: [String: Any] = [
            "type": "location",
            "lat": coord.latitude,
            "lng": coord.longitude,
            "heading": heading,
            "timestamp": timestamp
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        webSocketTask.send(.string(jsonString)) { error in
            if let error = error {
                print("❌ 位置發送失敗: \(error)")
            }
        }
    }
    
    // MARK: - 發送 SOS（透過 WebSocket）
    func sendSOS() async {
        guard let coord = LocationService.shared.coordinate else {
            await MainActor.run {
                uploadStatus = "無法取得位置"
            }
            return
        }
        
        await MainActor.run {
            uploadStatus = "正在發送 SOS..."
        }
        
        let message: [String: Any] = [
            "type": "sos",
            "lat": coord.latitude,
            "lng": coord.longitude
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            await MainActor.run {
                uploadStatus = "SOS 發送失敗"
            }
            return
        }
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("❌ SOS 發送失敗: \(error)")
                Task { @MainActor in
                    self.uploadStatus = "SOS 發送失敗"
                }
            }
        }
        
        // 等待後端的 sos_ack 回應（已在 handleWebSocketMessage 處理）
    }
}
