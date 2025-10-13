//
//  FamilyViewModel.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import Foundation
import CoreLocation
import SmartGuideServices

class FamilyViewModel: ObservableObject {
    @Published var targetCoordinate: CLLocationCoordinate2D?
    @Published var sosMessage: String?
    private var timer: Timer?
    private var sosTimer: Timer?
    
    // 用來記錄最後一筆 SOS 的 timestamp
    private var latestSOSTime: TimeInterval?

    // 原本的定位輪詢
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task {
                if let data = try? await HTTPClient.shared.get(path: "/location/latest"),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let lat = json["latitude"] as? Double,
                   let lon = json["longitude"] as? Double {
                    DispatchQueue.main.async {
                        self.targetCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
            }
        }
    }

    // 新增: SOS 輪詢
    func startSOSPolling() {
        sosTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            Task {
                if let data = try? await HTTPClient.shared.get(path: "/sos/latest"),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let lat = json["latitude"] as? Double,
                   let lon = json["longitude"] as? Double,
                   let timestamp = json["timestamp"] as? TimeInterval {
                    DispatchQueue.main.async {
                        if self.latestSOSTime != timestamp {
                            self.latestSOSTime = timestamp
                            self.sosMessage = "座標：(\(lat), \(lon))"
                        }
                    }
                }
            }
        }
    }
    
    // 清除 SOS 警示
    func clearSOSAlert() {
        sosMessage = nil
    }

    deinit {
        timer?.invalidate()
        sosTimer?.invalidate()
    }
}
