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
struct FamilyAppApp: App {
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
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

