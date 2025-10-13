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
            Text(vm.coordinateString)
                .multilineTextAlignment(.center)
            if let status = vm.uploadStatus {
                Text(status)
                    .foregroundColor(.blue)
                    .padding()
            }
            Button("SOS 緊急求救") {
                Task { await vm.sendSOS() }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(8)
        }
        .onAppear { vm.startUpdating() }
        .navigationTitle("導引背包")
    }
}

