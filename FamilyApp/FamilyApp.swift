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
    private let notificationService = NotificationService.shared

    init() {
        UNUserNotificationCenter.current().delegate = notificationService
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("首頁", systemImage: "house.fill")
                    }

                ChatView()
                    .tabItem {
                        Label("AI代理人", systemImage: "message.fill")
                    }
            }
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

