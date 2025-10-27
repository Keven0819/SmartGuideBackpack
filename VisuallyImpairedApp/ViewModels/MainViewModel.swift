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
    
    // MARK: -- Published 屬性
    
    @Published var currentAddress: String? = "讀取中…"
    @Published var uploadStatus: String? = nil
    
    // 用於接收 map/nomap/sos 等訊號
    @Published var navigationSignal: String? = nil
    
    // 導航指示文字
    @Published var navigationInstruction: String? = nil
    
    // MARK: -- 私有屬性
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    // WebSocket
    private var webSocketTask: URLSessionWebSocketTask?
    
    // 控制持續發送座標的狀態和任務
    private var isSendingLocation = false
    private var sendLocationTask: Task<Void, Never>? = nil
    
    // MARK: -- HTTP 客戶端
    
    let Location_SOS_Client = HTTPClient(baseURL: URL(string: "https://smart-guide-backend-beta.vercel.app")!)
    let GPS_SOS_Client = HTTPClient(baseURL: URL(string: "https://gps-sos-backend.onrender.com")!)
    let GPS_Guide_Client = HTTPClient(baseURL: URL(string: "https://7a2e5e9700e4.ngrok-free.app")!)
    
    // MARK: -- 初始化與訂閱
    
    init() {
        // 訂閱 LocationService 的 address 改變
        LocationService.shared.$address
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAddress in
                self?.currentAddress = newAddress ?? "無法取得地址"
            }
            .store(in: &cancellables)
        
        connectWebSocket()
    }
    
    // MARK: -- 定位更新
    
    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            Task {
                await self.sendLocation()
            }
        }
    }
    
    func sendLocation() async {
        guard let coord = LocationService.shared.coordinate,
              let heading = LocationService.shared.heading?.trueHeading else {
            DispatchQueue.main.async {
                self.uploadStatus = "定位或方位資料缺失，無法上傳"
            }
            return
        }
        
        let payload: [String: Any] = [
            "latitude": coord.latitude,
            "longitude": coord.longitude,
            "heading": heading
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            _ = try await Location_SOS_Client.post(path: "/location/update", body: data)
            DispatchQueue.main.async {
                self.uploadStatus = "位置上傳成功"
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "上傳失敗: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: -- SOS 功能
    
    func sendSOS() async {
        guard let coord = LocationService.shared.coordinate else {
            DispatchQueue.main.async {
                self.uploadStatus = "定位資料缺失，無法發送 SOS"
            }
            return
        }
        let payload: [String: Any] = [
            "latitude": coord.latitude,
            "longitude": coord.longitude
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            _ = try await Location_SOS_Client.post(path: "/sos", body: data)
            _ = try await GPS_SOS_Client.post(path: "/sos/button", body: data)
            DispatchQueue.main.async {
                self.uploadStatus = "SOS 已發送"
                NotificationService.shared.scheduleLocalNotification(
                    title: "SOS 已發送",
                    body: "緊急求救訊息已傳送"
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "發送 SOS 失敗: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: -- WebSocket 連線與接收導航指示
    
    func connectWebSocket() {
        let url = URL(string: "wss://7a2e5e9700e4.ngrok-free.app/ws/ios")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveWebSocketMessage()
    }
    
    func receiveWebSocketMessage() {
        webSocketTask?.receive() { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketText(text)
                default:
                    break
                }
                // 持續接收下一則訊息
                self?.receiveWebSocketMessage()
            case .failure(let error):
                print("WebSocket 接收錯誤: \(error)")
                // 如需要，可增加重連機制
            }
        }
    }
    
    private func handleWebSocketText(_ text: String) {
        DispatchQueue.main.async {
            if text == "map" {
                self.navigationSignal = text
                self.startSendingLocationLoop()
            } else if text == "nomap" {
                self.navigationSignal = text
                self.stopSendingLocationLoop()
            } else if text == "sos" {
                self.navigationSignal = text
            } else {
                if let data = text.data(using: .utf8),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let instruction = dict["text"] as? String {
                    self.navigationSignal = instruction
                } else {
                    self.navigationInstruction = text
                }
            }
        }
    }
    
    private func startSendingLocationLoop() {
        guard !isSendingLocation else { return }
        isSendingLocation = true
        sendLocationTask = Task {
            while isSendingLocation && !Task.isCancelled {
                await self.sendCurrentLocationViaWebSocket()
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 每5秒發送一次
            }
        }
    }
    
    private func stopSendingLocationLoop() {
        isSendingLocation = false
        sendLocationTask?.cancel()
        sendLocationTask = nil
    }
    
    // 透過 WebSocket 傳送經緯度、朝向、時間戳
    func sendCurrentLocationViaWebSocket() async {
        guard let coord = LocationService.shared.coordinate,
              let heading = LocationService.shared.heading?.trueHeading else {
            DispatchQueue.main.async {
                self.uploadStatus = "定位或方位資料缺失，無法上傳"
            }
            return
        }
        
        let data: [String: Any] = [
            "lat": coord.latitude,
            "lng": coord.longitude,
            "heading": heading,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.uploadStatus = "WebSocket 發送錯誤: \(error.localizedDescription)"
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.uploadStatus = "經緯度已透過 WebSocket 傳送"
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "JSON 序列化失敗: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: -- 語音導航功能
    
    func startVoiceCommand(text: String) async {
        let payload = ["text": text]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            let responseData = try await GPS_Guide_Client.post(path: "/voice-command", body: data)
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                DispatchQueue.main.async {
                    self.uploadStatus = json["message"] as? String
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "語音導航啟動失敗: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchNavigationStatus() async {
        do {
            let data = try await GPS_Guide_Client.get(path: "/status")
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    self.navigationInstruction = json["instruction"] as? String
                    self.uploadStatus = json["status"] as? String
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "獲取導航狀態失敗: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: -- 清理
    
    deinit {
        timer?.invalidate()
        cancellables.forEach { $0.cancel() }
        stopSendingLocationLoop()
    }
    
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}
