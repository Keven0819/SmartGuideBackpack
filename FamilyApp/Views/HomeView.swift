//
//  HomeView.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import SmartGuideServices
import CoreLocation
import UIKit // 需要引入 UIKit 來設定外觀

struct HomeView: View {
    
    // MARK: - ViewModel
    
    @StateObject private var vm = FamilyViewModel()

    // MARK: - Init (新增的部分)
    // 在這裡設定底部 TabBar 的外觀，強制變為不透明
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // 設定為不透明背景
        appearance.backgroundColor = UIColor.systemBackground // 設定背景色 (隨系統深淺色變換，或是用 .white)
        
        // 套用到標準外觀與捲動邊緣外觀
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: - Main View
    
    var body: some View {
        NavigationView {
            ZStack {
                if vm.targetCoordinate != nil {
                    MapView(targetCoordinate: $vm.targetCoordinate)
                        .edgesIgnoringSafeArea(.all)
                        // 注意：因為我們要讓 TabBar 不透明，
                        // 如果 MapView 被 TabBar 擋住，可以考慮移除 .bottom 的忽略安全區域
                        // 但通常為了地圖滿版，我們還是會留著
                } else {
                    ProgressView("等待定位...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .foregroundColor(.gray)
                }

                VStack(spacing: 12) {
                    // 頂部標題毛玻璃 + 漸層光暈
                    Text("視障者定位")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                Color.clear
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .blendMode(.overlay)
                            }
                            .background(.ultraThinMaterial)
                            .cornerRadius(40)
                        )
                        .shadow(color: Color.purple.opacity(0.7), radius: 12, x: 0, y: 0)
                        .padding(.horizontal, 24)
                        .padding(.top, 40)

                    Spacer(minLength: 10)
                    
                    if let sosAddress = vm.sosAddress {
                        VStack(spacing: 16) {
                            Text("SOS 警報")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)

                            Text(sosAddress)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)

                            Button(action: vm.clearSOSAlert) {
                                Text("清除警報")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(30)
                            .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(28)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red.opacity(0.85), Color.red.opacity(0.95)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.red.opacity(0.8), radius: 16, x: 0, y: 0)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.35), value: vm.sosAddress)
                    } else {
                        Color.clear
                            .frame(height: 140)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                vm.connectWebSocket()
            }
        }
    }
}
