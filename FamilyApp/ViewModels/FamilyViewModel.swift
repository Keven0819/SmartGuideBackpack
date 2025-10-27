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
    
    // MARK: -- Published 屬性
    
    @Published var targetCoordinate: CLLocationCoordinate2D?
    @Published var sosAddress: String?

    // MARK: -- 私有屬性
    
    private var timer: Timer?
    private var sosTimer: Timer?
    private var latestSOSTime: TimeInterval?
    private let sosTimestampKey = "LatestSOSTime"
    
    // MARK: -- HTTP 客戶端
    
    // 自己測試寫的更新位置和 SOS 收發的 API
    let Location_SOS_Client = HTTPClient(baseURL: URL(string: "https://smart-guide-backend-beta.vercel.app")!)
    
    // 茗萱寫的 GPS SOS 和 STT 系統 API
    let GPS_SOS_Client = HTTPClient(baseURL: URL(string: "gps_sos")!)
    
    // 郁秀寫的導航系統 API
    let GPS_Guide_Client = HTTPClient(baseURL: URL(string: "gps_guide")!)
    
    // MARK: -- 定位
    
    // 定位輪詢
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task {
                if let data = try? await self.Location_SOS_Client.get(path: "/location/latest"),
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

    // MARK: -- SOS 警報
    
    // SOS 輪詢
    func startSOSPolling() {
        latestSOSTime = UserDefaults.standard.double(forKey: sosTimestampKey)
        sosTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            Task {
                do {
                    let data = try await self.Location_SOS_Client.get(path: "/sos/latest")
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let lat = json["latitude"] as? Double,
                       let lon = json["longitude"] as? Double,
                       let timestamp = json["timestamp"] as? TimeInterval {
                        
                        DispatchQueue.main.async {
                            if self.latestSOSTime != timestamp {
                                self.latestSOSTime = timestamp
                                UserDefaults.standard.set(timestamp, forKey: self.sosTimestampKey)
                                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                self.targetCoordinate = coordinate
                                
                                LocationService.shared.reverseGeocodeIfNeeded(coordinate) { address in
                                    DispatchQueue.main.async {
                                        let resolvedAddress = address ?? "未知位置"
                                        self.sosAddress = resolvedAddress
                                        let notificationBody = "有人在 \(resolvedAddress) 發出 SOS !"
                                        NotificationService.shared.scheduleLocalNotification(title: "SOS 警報", body: notificationBody)
                                    }
                                }
                            }
                        }
                    } else {
                        // 如果解析失敗，當作沒有資料處理
                        DispatchQueue.main.async {
                            self.sosAddress = nil
                            self.latestSOSTime = nil
                            UserDefaults.standard.removeObject(forKey: self.sosTimestampKey)
                        }
                    }
                } catch let error as URLError {
                    // 如果是 404 異常，可以根據 error.code 處理，否則列印錯誤
                    if error.code == .badServerResponse {
                        DispatchQueue.main.async {
                            self.sosAddress = nil
                            self.latestSOSTime = nil
                            UserDefaults.standard.removeObject(forKey: self.sosTimestampKey)
                        }
                    } else {
                        print("輪詢 SOS 發生錯誤：", error)
                    }
                } catch {
                    print("輪詢 SOS 發生錯誤：", error)
                }
            }
        }
    }

    // 清除 SOS 警報
    func clearSOSAlert() {
        sosAddress = nil
        latestSOSTime = 0
        UserDefaults.standard.removeObject(forKey: sosTimestampKey)

        Task {
            do {
                // 只需要傳路徑和 body (這裡 body 可以是空的)
                let _ = try await Location_SOS_Client.post(path: "/sos/clear", body: Data())
                print("後端 SOS 警報清除成功")
            } catch {
                print("清除 SOS 發生錯誤:", error)
            }
        }
    }

    // MARK: -- 清理
    
    deinit {
        timer?.invalidate()
        sosTimer?.invalidate()
    }
}
