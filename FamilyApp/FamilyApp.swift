//
//  FamilyAppApp.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import UserNotifications
import SmartGuideServices

@main
struct FamilyApp: App {
    
    // 強引用
    private let notificationService = NotificationService.shared
    
    init() {
        // 將通知中心的 delegate 指派為 notificationService，確保強引用且 delegate 實作完整
        UNUserNotificationCenter.current().delegate = notificationService as UNUserNotificationCenterDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    // 非同步請求通知權限
                    await NotificationService.shared.requestAuthorization()
                }
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 處理點擊通知事件
        completionHandler()
    }
}

