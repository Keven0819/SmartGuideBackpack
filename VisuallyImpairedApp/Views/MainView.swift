//
//  MainView.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import CoreLocation
import SmartGuideServices

struct MainView: View {
    @StateObject private var vm = MainViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            if let address = vm.currentAddress, !address.isEmpty {
                Text(address)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.7)
            } else {
                Text("正在取得位置...")
                    .foregroundColor(.gray)
                    .font(.title3)
                    .padding(.horizontal, 20)
            }
            
            if let status = vm.uploadStatus, status == "位置上傳成功" || status == "SOS 已發送" {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)
                    .transition(.opacity)
            } else if let status = vm.uploadStatus {
                Text(status)
                    .foregroundColor(.blue)
                    .font(.callout)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .transition(.opacity)
            }
            
            Button(action: {
                Task { await vm.sendSOS() }
            }) {
                Text("SOS 緊急求救")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.red)
                    .cornerRadius(12)
                    .shadow(color: Color.red.opacity(0.6), radius: 8, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            Task { vm.startUpdating() }
        }
        .navigationTitle("導引背包")
        .animation(.easeInOut, value: vm.uploadStatus)
    }
}
