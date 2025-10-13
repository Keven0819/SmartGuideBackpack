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
    
    struct Particle: Identifiable, Equatable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var speed: CGFloat
        var opacity: Double
        
        static func == (lhs: Particle, rhs: Particle) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    @State private var particles: [Particle] = (0..<80).map { _ in
        Particle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 2...6),
            speed: CGFloat.random(in: 0.001...0.006),
            opacity: Double.random(in: 0.3...0.8)
        )
    }
    
    var body: some View {
        ZStack {
            // 深藍科技感漸層背景
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.3), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .blur(radius: 10)
            
            GeometryReader { geo in
                Canvas { context, size in
                    for i in particles.indices {
                        var particle = particles[i]
                        let pt = CGPoint(x: particle.x * size.width, y: particle.y * size.height)
                        let circle = Path(ellipseIn: CGRect(x: pt.x, y: pt.y, width: particle.size, height: particle.size))
                        context.fill(circle, with: .color(.white.opacity(particle.opacity)))
                        
                        particle.y += particle.speed
                        if particle.y > 1 {
                            particle.y = 0
                            particle.x = CGFloat.random(in: 0...1)
                            particle.opacity = Double.random(in: 0.3...0.8)
                            particle.size = CGFloat.random(in: 2...6)
                            particle.speed = CGFloat.random(in: 0.001...0.006)
                        }
                        particles[i] = particle
                    }
                }
                .animation(.linear(duration: 0.016), value: particles)
            }
            .allowsHitTesting(false)
            
            VStack(spacing: 20) {
                Spacer(minLength: 30)
                
                // 科技風霓虹漸層文字 + 光暈
                Text("Guide Backpack")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.cyan.opacity(0.8), radius: 18, x: 0, y: 0)
                    .shadow(color: Color.blue.opacity(0.6), radius: 30, x: 0, y: 0)
                    .multilineTextAlignment(.center)
                
                Spacer(minLength: 10)
                
                if let address = vm.currentAddress, !address.isEmpty {
                    VStack {
                        Text("當前位置")
                            .font(.headline)
                            .foregroundColor(Color.cyan.opacity(0.8))
                        
                        Text(address)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.white)
                            .padding(.top, 6)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.4))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.cyan.opacity(0.6), radius: 25, x: 0, y: 0)
                    )
                    .padding(.horizontal, 30)
                    .transition(.opacity)
                } else {
                    ProgressView("定位中...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.cyan))
                        .foregroundColor(.gray)
                        .font(.title3)
                        .padding(.horizontal, 20)
                }
                
                if let status = vm.uploadStatus {
                    StatusView(status: status)
                        .padding(.top, 8)
                }
                
                SOSButton {
                    Task { await vm.sendSOS() }
                }
                .padding(.top, 12)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .onAppear {
            Task { vm.startUpdating() }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.uploadStatus)
    }
}

struct StatusView: View {
    let status: String
    
    var body: some View {
        HStack {
            if status == "位置上傳成功" || status == "SOS 已發送" {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.green)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .frame(width: 24, height: 24)
            }
            
            Text(status)
                .font(.body)
                .foregroundColor(status == "位置上傳成功" || status == "SOS 已發送" ? .green : .primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            Capsule()
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .transition(.move(edge: .bottom))
    }
}

struct SOSButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("SOS 緊急求救", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.red, Color(.systemPink)]), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: Color.red.opacity(0.5), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 30)
        .accessibilityLabel("SOS 緊急求救")
        .accessibilityHint("按下以發送緊急求救訊號")
        .buttonStyle(.plain)
    }
}
