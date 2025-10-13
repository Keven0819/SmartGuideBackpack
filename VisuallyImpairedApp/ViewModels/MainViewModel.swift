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
    @Published var currentAddress: String? = "讀取中…"
    @Published var uploadStatus: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    init() {
        // 訂閱 LocationService 的 address 改變
        LocationService.shared.$address
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAddress in
                self?.currentAddress = newAddress ?? "無法取得地址"
            }
            .store(in: &cancellables)
    }

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
            _ = try await HTTPClient.shared.post(path: "/location/update", body: data)
            DispatchQueue.main.async {
                self.uploadStatus = "位置上傳成功"
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "上傳失敗: \(error.localizedDescription)"
            }
        }
    }

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
            _ = try await HTTPClient.shared.post(path: "/sos", body: data)
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

    deinit {
        timer?.invalidate()
        cancellables.forEach { $0.cancel() }
    }
}
