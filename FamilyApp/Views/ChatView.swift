//
// ChatView.swift
// SmartGuideBackpack
//
// Created by imac-3570 on 2025/11/3.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let time: String
    let isHistoryRecord: Bool = false // 標記是否為歷史紀錄訊息
}

// 求救紀錄結構
struct EmergencyRecord: Identifiable {
    let id = UUID()
    let date: String
    let location: String
    let status: String
}

// 導航紀錄結構
struct NavigationRecord: Identifiable {
    let id = UUID()
    let date: String
    let destination: String
}

struct ChatView: View {
    @State private var messages: [Message] = [
        Message(text: "哈囉！有什麼我可以幫忙的嗎？", isUser: false, time: "10:01 AM"),
        Message(text: "你可以問我：\n• 查詢求救紀錄\n• 查詢導航紀錄\n• 最近的導航", isUser: false, time: "10:01 AM")
    ]
    
    @State private var inputText = ""
    @State private var isTyping = false
    
    // 模擬的歷史紀錄資料
    @State private var emergencyRecords: [EmergencyRecord] = [
        // 可以在這裡添加測試資料
        // EmergencyRecord(date: "2025-11-01", location: "台中市西區", status: "已處理")
    ]
    
    @State private var navigationRecords: [NavigationRecord] = [
        NavigationRecord(date: "2025-11-02", destination: "台中科技大學"),
        NavigationRecord(date: "2025-11-01", destination: "台中火車站"),
        NavigationRecord(date: "2025-10-30", destination: "逢甲夜市"),
        NavigationRecord(date: "2025-10-29", destination: "太原火車站"),
        NavigationRecord(date: "2025-10-28", destination: "台中公園")
    ]
    
    var body: some View {
        ZStack {
            // 優雅的漸層背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.88, green: 0.92, blue: 0.98),
                    Color(red: 0.82, green: 0.88, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 頂部標題區
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.6, blue: 1.0),
                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI 智能助理")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("線上服務中")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                
                // 訊息區域
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(messages) { msg in
                                MessageRow(message: msg)
                                    .id(msg.id)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: msg.isUser ? .trailing : .leading)
                                            .combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                            
                            if isTyping {
                                TypingIndicator()
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // 輸入區域
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        // 輸入框
                        HStack(spacing: 12) {
                            Image(systemName: "text.bubble")
                                .foregroundColor(.gray.opacity(0.6))
                                .font(.system(size: 18))
                            
                            TextField("輸入訊息...", text: $inputText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                            
                            if !inputText.isEmpty {
                                Button {
                                    inputText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(
                                            inputText.isEmpty ?
                                            Color.gray.opacity(0.2) :
                                            Color(red: 0.5, green: 0.5, blue: 0.95),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                        
                        // 發送按鈕
                        Button {
                            sendMessage()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: inputText.isEmpty ?
                                                [Color.gray.opacity(0.3), Color.gray.opacity(0.3)] :
                                                [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.6, green: 0.4, blue: 0.9)]
                                            ),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 52, height: 52)
                                    .shadow(
                                        color: inputText.isEmpty ? .clear : Color.blue.opacity(0.3),
                                        radius: 10,
                                        x: 0,
                                        y: 4
                                    )
                                
                                Image(systemName: "arrow.up")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .disabled(inputText.isEmpty)
                        .scaleEffect(inputText.isEmpty ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: inputText.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: Date())
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            messages.append(Message(text: trimmed, isUser: true, time: timeStr))
            inputText = ""
        }
        
        // 模擬 AI 正在輸入
        withAnimation {
            isTyping = true
        }
        
        // 檢測關鍵字並回應
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                isTyping = false
            }
            
            let responseText = detectKeywordAndRespond(userInput: trimmed)
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                messages.append(Message(
                    text: responseText,
                    isUser: false,
                    time: formatter.string(from: Date())
                ))
            }
        }
    }
    
    // 關鍵字檢測與回應
    func detectKeywordAndRespond(userInput: String) -> String {
        let input = userInput.lowercased()
        
        // 檢測求救紀錄相關關鍵字
        if input.contains("求救") || input.contains("緊急") || input.contains("emergency") {
            return generateEmergencyRecordResponse()
        }
        
        // 檢測導航紀錄相關關鍵字
        if input.contains("導航") || input.contains("路線") || input.contains("navigation") || input.contains("最近") {
            return generateNavigationRecordResponse()
        }
        
        // 預設回應
        return "我能幫您查詢：\n\n📍 導航紀錄\n🚨 求救紀錄\n\n請問需要查詢哪一項呢？"
    }
    
    // 生成求救紀錄回應
    func generateEmergencyRecordResponse() -> String {
        if emergencyRecords.isEmpty {
            return "🚨 求救紀錄\n\n無歷史求救紀錄\n\n系統目前沒有任何求救記錄，這是好消息！😊"
        } else {
            var response = "🚨 求救紀錄\n\n"
            for (index, record) in emergencyRecords.enumerated() {
                response += "\(index + 1). \(record.date)\n"
                response += "   📍 位置：\(record.location)\n"
                response += "   ✓ 狀態：\(record.status)\n\n"
            }
            return response.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    // 生成導航紀錄回應
    func generateNavigationRecordResponse() -> String {
        if navigationRecords.isEmpty {
            return "📍 導航紀錄\n\n無導航紀錄"
        } else {
            var response = "📍 導航紀錄\n\n"
            for (index, record) in navigationRecords.enumerated() {
                response += "\(index + 1). \(record.date) 目的地：\(record.destination)\n"
            }
            return response.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

// MARK: - Message Row
struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if !message.isUser {
                // AI 頭像
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                    Color(red: 0.6, green: 0.4, blue: 0.9)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            } else {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                // 訊息氣泡
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(message.isUser ? .white : Color(red: 0.2, green: 0.3, blue: 0.5))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            if message.isUser {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.6, blue: 1.0),
                                        Color(red: 0.6, green: 0.4, blue: 0.9)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                Color.white
                            }
                        }
                            .clipShape(ChatBubbleShape(isUser: message.isUser))
                            .shadow(
                                color: message.isUser ?
                                Color.blue.opacity(0.25) :
                                Color.black.opacity(0.08),
                                radius: message.isUser ? 10 : 6,
                                x: 0,
                                y: message.isUser ? 4 : 2
                            )
                    )
                
                // 時間戳記
                Text(message.time)
                    .font(.system(size: 11))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.horizontal, 6)
            }
            
            if message.isUser {
                // 用戶頭像
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.3, green: 0.8, blue: 0.7),
                                    Color(red: 0.4, green: 0.6, blue: 0.9)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            } else {
                Spacer(minLength: 50)
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.6, blue: 1.0),
                                Color(red: 0.6, green: 0.4, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                    .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                        .scaleEffect(animating ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
            
            Spacer(minLength: 50)
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Chat Bubble Shape
struct ChatBubbleShape: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isUser ?
            [.topLeft, .topRight, .bottomLeft] :
            [.topRight, .topLeft, .bottomRight],
            cornerRadii: CGSize(width: 22, height: 22)
        )
        return Path(path.cgPath)
    }
}
