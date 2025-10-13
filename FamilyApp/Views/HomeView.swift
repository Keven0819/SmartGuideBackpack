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
                if vm.targetCoordinate != nil {
                    MapView(targetCoordinate: $vm.targetCoordinate)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("等待定位...")
                        .foregroundColor(.gray)
                }

                if let sosAddress = vm.sosAddress {
                    VStack {
                        Spacer()

                        VStack(spacing: 14) {
                            Text("SOS 警報")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)

                            Text(sosAddress)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Button(action: vm.clearSOSAlert) {
                                Text("清除警報")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(25)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.red.opacity(0.9))
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut, value: vm.sosAddress)
                    }
                }
            }
            .navigationTitle("視障者定位")
            .onAppear {
                vm.startPolling()
                vm.startSOSPolling()
            }
        }
    }
}
