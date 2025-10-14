//
//  VisuallyImpairedAppApp.swift
//  VisuallyImpairedApp
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import UIKit
import SmartGuideServices

@main
struct VisuallyImpairedAppApp: App {

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.75, green: 0.78, blue: 0.95, alpha: 1) // 淺藍紫色背景
        
        // 选中状态字体与图示颜色（较深突出）
        UITabBar.appearance().tintColor = UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1) // 深蓝色
        
        // 未选中状态字体与图示颜色（暗色但高透明度）
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.7)
        
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    MainView()
                        .task {
                            await NotificationService.shared.requestAuthorization()
                        }
                }
                .tabItem {
                    Label("首頁", systemImage: "house.fill")
                }
                
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("親友", systemImage: "figure.2.and.child.holdinghands")
                }
            }
            .tint(Color(red: 0.1, green: 0.3, blue: 0.8)) // 確保選中項目顏色一致
        }
    }
}

