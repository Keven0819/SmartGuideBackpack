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
    @Published var sosAddress: String?

    private var timer: Timer?
    private var sosTimer: Timer?
    private var latestSOSTime: TimeInterval?
    private let sosTimestampKey = "LatestSOSTime"

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

    func startSOSPolling() {
        latestSOSTime = UserDefaults.standard.double(forKey: sosTimestampKey)
        sosTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            Task {
                do {
                    let url = URL(string: "https://4d3de023f1b3.ngrok-free.app/sos/latest")!
                    let (data, response) = try await URLSession.shared.data(from: url)
                    if let httpRes = response as? HTTPURLResponse {
                        if httpRes.statusCode == 200,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let lat = json["latitude"] as? Double,
                           let lon = json["longitude"] as? Double,
                           let timestamp = json["timestamp"] as? TimeInterval {
                            
                            DispatchQueue.main.async {
                                if self.latestSOSTime != timestamp {
                                    self.latestSOSTime = timestamp
                                    UserDefaults.standard.set(timestamp, forKey: self.sosTimestampKey)

                                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    self.targetCoordinate = coordinate

                                    LocationService.shared.getAddressFromCoordinate(coordinate) { address in
                                        DispatchQueue.main.async {
                                            let resolvedAddress = address ?? "未知位置"
                                            self.sosAddress = resolvedAddress

                                            let notificationBody = "有人在 \(resolvedAddress) 發出 SOS！"
                                            NotificationService.shared.scheduleLocalNotification(title: "SOS 警報", body: notificationBody)
                                        }
                                    }
                                }
                            }
                        }
                        else if httpRes.statusCode == 404 {
                            // 無最新 SOS，清除本地警報
                            DispatchQueue.main.async {
                                self.sosAddress = nil
                                self.latestSOSTime = nil
                                UserDefaults.standard.removeObject(forKey: self.sosTimestampKey)
                            }
                        }
                    }
                } catch {
                    print("輪詢 SOS 發生錯誤:", error)
                }
            }
        }
    }

    func clearSOSAlert() {
        sosAddress = nil
        latestSOSTime = 0
        UserDefaults.standard.removeObject(forKey: sosTimestampKey)

        Task {
            do {
                let url = URL(string: "https://4d3de023f1b3.ngrok-free.app/sos/clear")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = Data()

                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 {
                    print("後端 SOS 警報清除成功")
                } else {
                    print("後端清除失敗")
                }
            } catch {
                print("清除 SOS 發生錯誤:", error)
            }
        }
    }

    deinit {
        timer?.invalidate()
        sosTimer?.invalidate()
    }
}
