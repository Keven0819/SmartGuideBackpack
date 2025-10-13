//
//  MainViewModel.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/10.
//

import Foundation
import CoreLocation
import SmartGuideServices

class MainViewModel: ObservableObject {
    @Published var coordinateString = "讀取中…"
    @Published var uploadStatus: String? = nil
    private var timer: Timer?

    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task {
                await self.sendLocation()
            }
            if let coord = LocationService.shared.coordinate,
               let heading = LocationService.shared.heading?.trueHeading {
                DispatchQueue.main.async {
                    self.coordinateString =
                        "Lat:\(coord.latitude)\nLon:\(coord.longitude)\nHeading:\(Int(heading))°"
                }
            }
        }
    }

    func sendLocation() async {
        guard let coord = LocationService.shared.coordinate,
              let heading = LocationService.shared.heading?.trueHeading else {
            DispatchQueue.main.async {
                self.uploadStatus = "定位或方位資料缺失，無法上傳"
                print(self.uploadStatus)
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
            let responseData = try await HTTPClient.shared.post(path: "/location/update", body: data)

            if let responseString = String(data: responseData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.uploadStatus = "位置上傳成功: \(responseString)"
                    print(self.uploadStatus)
                }
            } else {
                DispatchQueue.main.async {
                    self.uploadStatus = "位置上傳成功"
                    print(self.uploadStatus)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.uploadStatus = "上傳失敗: \(error.localizedDescription)"
                print(self.uploadStatus)
            }
        }
    }

    func sendSOS() async {
        guard let coord = LocationService.shared.coordinate else {
            DispatchQueue.main.async {
                self.uploadStatus = "定位資料缺失，無法發送 SOS"
                print(self.uploadStatus)
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
                print(self.uploadStatus)
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
