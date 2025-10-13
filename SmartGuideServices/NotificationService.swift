//
//  NotificationService.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import UserNotifications

public class NotificationService {
    public static let shared = NotificationService()
    
    public func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission granted: \(granted)")
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
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
