//
//  FallAnalysisView.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/12/26.
//

import SwiftUI

struct FallAnalysisView: View {
    
    @StateObject private var vm = FallAnalysisViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if vm.fallAnalysisList.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(vm.fallAnalysisList) { analysis in
                            FallAnalysisCardView(analysis: analysis)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("跌倒分析")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !vm.fallAnalysisList.isEmpty {
                        Button(action: {
                            vm.clearAll()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.fall")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("目前沒有跌倒分析記錄")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct FallAnalysisCardView: View {
    let analysis: FallAnalysis
    @State private var showFullScreenImage = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題和時間
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("跌倒偵測警報")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(analysis.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // 圖片區域
            if !analysis.imageBase64.isEmpty,
               let imageData = Data(base64Encoded: analysis.imageBase64),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
                    .clipped()
                    .onTapGesture {
                        showFullScreenImage = true
                    }
                    .fullScreenCover(isPresented: $showFullScreenImage) {
                        FullScreenImageView(uiImage: uiImage)
                    }
            } else {
                // 無圖片時顯示佔位符
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("無影像資料")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            // 場景描述
            InfoRowView(
                icon: "location.fill",
                title: "場景描述",
                content: analysis.sceneDescription,
                iconColor: .blue
            )
            
            // 情況分析
            InfoRowView(
                icon: "doc.text.magnifyingglass",
                title: "情況分析",
                content: analysis.situationAnalysis,
                iconColor: .purple
            )
            
            // 給使用者的訊息
//            VStack(alignment: .leading, spacing: 8) {
////                HStack {
////                    Image(systemName: "bubble.left.fill")
////                        .foregroundColor(.green)
////                    Text("系統訊息")
////                        .font(.subheadline)
////                        .fontWeight(.semibold)
////                }
//                
////                Text(analysis.messageToUser)
////                    .font(.body)
////                    .foregroundColor(.primary)
////                    .padding()
////                    .background(Color.green.opacity(0.1))
////                    .cornerRadius(10)
//            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct InfoRowView: View {
    let icon: String
    let title: String
    let content: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 全螢幕圖片檢視
struct FullScreenImageView: View {
    let uiImage: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                            // 限制縮放範圍
                            if scale < 1.0 {
                                withAnimation {
                                    scale = 1.0
                                    lastScale = 1.0
                                }
                            } else if scale > 5.0 {
                                withAnimation {
                                    scale = 5.0
                                    lastScale = 5.0
                                }
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        if scale > 1.0 {
                            scale = 1.0
                            lastScale = 1.0
                        } else {
                            scale = 2.0
                            lastScale = 2.0
                        }
                    }
                }
            
            // 關閉按鈕
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    FallAnalysisView()
}
