//
//  NotificationService.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import UserNotifications

public class NotificationService: NSObject {
    
    // MARK: -- 單例
    
    public static let shared = NotificationService()
    
    // MARK: -- 請求通知權限
    
    public func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission granted: \(granted)")
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    // MARK: -- 本地通知方法
    
    public func scheduleLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString,
                                        content: content,
                                        trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}

// MARK: -- UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped: \(response.notification.request.content.title)")
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
