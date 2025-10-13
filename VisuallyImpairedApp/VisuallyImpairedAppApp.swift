//
//  VisuallyImpairedAppApp.swift
//  VisuallyImpairedApp
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI

@main
struct VisuallyImpairedAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
                    .toolbar {
                        NavigationLink("設定", destination: ProfileView())
                    }
            }
        }
    }
}
