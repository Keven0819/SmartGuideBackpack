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
    
    // MARK: -- 私有屬性
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    // MARK: -- HTTP 客戶端
    
    // 自己測試寫的更新位置和 SOS 收發的 API
    let Location_SOS_Client = HTTPClient(baseURL: URL(string: "https://smart-guide-backend-qg7d1ygqq-keven0819s-projects.vercel.app")!)
    
    // 茗萱寫的 GPS SOS 和 STT 系統 API
    let GPS_SOS_Client = HTTPClient(baseURL: URL(string: "gps_sos")!)
    
    // 郁秀寫的導航系統 API
    let GPS_Guide_Client = HTTPClient(baseURL: URL(string: "gps_guide")!)
    
    // MARK: -- 初始化與訂閱
    
    init() {
        // 訂閱 LocationService 的 address 改變
        LocationService.shared.$address
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAddress in
                self?.currentAddress = newAddress ?? "無法取得地址"
            }
            .store(in: &cancellables)
    }

    // MARK: -- 定位更新
    
    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
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
    
    // 我自己的 SOS 發送功能
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

    // MARK: -- 清理
    deinit {
        timer?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
}
