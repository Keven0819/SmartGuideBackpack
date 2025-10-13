//
//  HomeView.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import SmartGuideServices
import CoreLocation

struct HomeView: View {
    @StateObject private var vm = FamilyViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // 地圖顯示
                if vm.targetCoordinate != nil {
                    MapView(targetCoordinate: $vm.targetCoordinate)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("等待視障者位置…")
                        .foregroundColor(.gray)
                }

                // SOS 警示浮層
                if let sosMsg = vm.sosMessage {
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Text("⚠️ 緊急求救 ⚠️")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(sosMsg)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Button(action: {
                                vm.clearSOSAlert()
                            }) {
                                Text("確認")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.85))
                    }
                }
            }
            .onAppear {
                vm.startPolling()       // 定位輪詢
                vm.startSOSPolling()    // SOS 輪詢
            }
            .navigationTitle("視障者定位")
        }
    }
}
