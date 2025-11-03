//
// ChatView.swift
// SmartGuideBackpack
//
// Created by imac-3570 on 2025/11/3.
//

import SwiftUI

// 統一的聊天項目
enum ChatItem: Identifiable {
    case message(Message)
    case card(MessageCard)
    
    var id: UUID {
        switch self {
        case .message(let msg): return msg.id
        case .card(let card): return card.id
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let time: String
}

// 卡片類型
enum CardType {
    case navigation(NavigationRecord)
    case weather(WeatherData)
    case emergency(EmergencyRecord)
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

// 天氣資料結構
struct WeatherData: Identifiable {
    let id = UUID()
    let location: String
    let temperature: String
    let condition: String
    let emoji: String
    let humidity: String
    let windSpeed: String
    let feelsLike: String
}

// 訊息卡片結構
struct MessageCard: Identifiable {
    let id = UUID()
    let cardType: CardType
    let time: String
}

struct ChatView: View {
    @State private var chatItems: [ChatItem] = [
        .message(Message(text: "哈囉！有什麼我可以幫忙的嗎？", isUser: false, time: "10:01 AM")),
        .message(Message(text: "你可以問我：\n• 查詢求救紀錄\n• 查詢導航紀錄\n• 查詢天氣資訊", isUser: false, time: "10:01 AM"))
    ]
    
    @State private var inputText = ""
    @State private var isTyping = false
    
    // 模擬的歷史紀錄資料
    @State private var emergencyRecords: [EmergencyRecord] = []
    
    @State private var navigationRecords: [NavigationRecord] = [
        NavigationRecord(date: "2025-11-02", destination: "台中科技大學"),
        NavigationRecord(date: "2025-11-01", destination: "台中火車站"),
        NavigationRecord(date: "2025-10-30", destination: "逢甲夜市"),
        NavigationRecord(date: "2025-10-29", destination: "太原火車站"),
        NavigationRecord(date: "2025-10-28", destination: "台中公園")
    ]
    
    // 天氣假資料
    @State private var weatherData = WeatherData(
        location: "台中市西區",
        temperature: "24°C",
        condition: "多雲",
        emoji: "⛅️",
        humidity: "65%",
        windSpeed: "12 km/h",
        feelsLike: "23°C"
    )
    
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
                            ForEach(chatItems) { item in
                                switch item {
                                case .message(let msg):
                                    MessageRow(message: msg)
                                        .id(item.id)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: msg.isUser ? .trailing : .leading)
                                                .combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                case .card(let card):
                                    MessageCardRow(card: card)
                                        .id(item.id)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .leading).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }
                            }
                            
                            if isTyping {
                                TypingIndicator()
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                    }
                    .onChange(of: chatItems.count) { _ in
                        scrollToBottom(proxy: proxy)
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
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = chatItems.last {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                proxy.scrollTo(last.id, anchor: .bottom)
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
            chatItems.append(.message(Message(text: trimmed, isUser: true, time: timeStr)))
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
            
            detectKeywordAndRespond(userInput: trimmed)
        }
    }
    
    // 關鍵字檢測與回應
    func detectKeywordAndRespond(userInput: String) {
        let input = userInput.lowercased()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: Date())
        
        // 檢測求救紀錄相關關鍵字
        if input.contains("求救") || input.contains("緊急") || input.contains("emergency") {
            sendEmergencyRecords(timeStr: timeStr)
            return
        }
        
        // 檢測導航紀錄相關關鍵字
        if input.contains("導航") || input.contains("路線") || input.contains("navigation") || input.contains("最近") {
            sendNavigationRecords(timeStr: timeStr)
            return
        }
        
        // 檢測天氣相關關鍵字
        if input.contains("天氣") || input.contains("氣溫") || input.contains("weather") || input.contains("溫度") {
            sendWeatherInfo(timeStr: timeStr)
            return
        }
        
        // 預設回應
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            chatItems.append(.message(Message(
                text: "我能幫您查詢：\n\n📍 導航紀錄\n🚨 求救紀錄\n🌤️ 天氣資訊\n\n請問需要查詢哪一項呢？",
                isUser: false,
                time: timeStr
            )))
        }
    }
    
    // 發送求救紀錄卡片
    func sendEmergencyRecords(timeStr: String) {
        if emergencyRecords.isEmpty {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                chatItems.append(.message(Message(
                    text: "目前沒有任何求救記錄，這是好消息！😊",
                    isUser: false,
                    time: timeStr
                )))
            }
        } else {
            // 先發送標題訊息
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                chatItems.append(.message(Message(
                    text: "🚨 為您找到以下求救紀錄：",
                    isUser: false,
                    time: timeStr
                )))
            }
            
            // 逐個發送卡片
            for (index, record) in emergencyRecords.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        chatItems.append(.card(MessageCard(
                            cardType: .emergency(record),
                            time: timeStr
                        )))
                    }
                }
            }
        }
    }
    
    // 發送導航紀錄卡片
    func sendNavigationRecords(timeStr: String) {
        if navigationRecords.isEmpty {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                chatItems.append(.message(Message(
                    text: "無導航紀錄",
                    isUser: false,
                    time: timeStr
                )))
            }
        } else {
            // 先發送標題訊息
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                chatItems.append(.message(Message(
                    text: "📍 為您找到最近的導航紀錄：",
                    isUser: false,
                    time: timeStr
                )))
            }
            
            // 只取最新的3筆，逐個發送卡片
            let recentRecords = Array(navigationRecords.prefix(3))
            for (index, record) in recentRecords.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        chatItems.append(.card(MessageCard(
                            cardType: .navigation(record),
                            time: timeStr
                        )))
                    }
                }
            }
            
            // 如果有更多紀錄，延遲顯示提示（確保在所有卡片之後）
            if navigationRecords.count > 3 {
                let delayTime = Double(recentRecords.count + 1) * 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        chatItems.append(.message(Message(
                            text: "還有 \(navigationRecords.count - 3) 筆較早的紀錄",
                            isUser: false,
                            time: timeStr
                        )))
                    }
                }
            }
        }
    }
    
    // 發送天氣資訊卡片
    func sendWeatherInfo(timeStr: String) {
        // 先發送標題訊息
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            chatItems.append(.message(Message(
                text: "🌤️ 為您查詢當前天氣：",
                isUser: false,
                time: timeStr
            )))
        }
        
        // 延遲發送天氣卡片
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                chatItems.append(.card(MessageCard(
                    cardType: .weather(weatherData),
                    time: timeStr
                )))
            }
        }
    }
}

// MARK: - Message Card Row
struct MessageCardRow: View {
    let card: MessageCard
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
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
            
            VStack(alignment: .leading, spacing: 6) {
                // 卡片內容
                switch card.cardType {
                case .navigation(let record):
                    NavigationCardView(record: record)
                case .weather(let data):
                    WeatherCardView(data: data)
                case .emergency(let record):
                    EmergencyCardView(record: record)
                }
                
                // 時間戳記
                Text(card.time)
                    .font(.system(size: 11))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.horizontal, 6)
            }
            
            Spacer(minLength: 50)
        }
    }
}

// MARK: - Navigation Card View
struct NavigationCardView: View {
    let record: NavigationRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                
                Text(formatDate(record.date))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.6))
            }
            
            Divider()
            
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                
                Text(record.destination)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
            }
        }
        .padding(18)
        .frame(maxWidth: 280)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM月dd日 (EEE)"
            formatter.locale = Locale(identifier: "zh_TW")
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Weather Card View
struct WeatherCardView: View {
    let data: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題
            HStack {
                Text(data.emoji)
                    .font(.system(size: 32))
                Text(data.location)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
            }
            
            // 主要溫度
            HStack(alignment: .top, spacing: 4) {
                Text(data.temperature)
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.9))
                
                Text(data.condition)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 18)
            }
            
            Divider()
            
            // 詳細資訊
            VStack(spacing: 10) {
                WeatherDetailRow(icon: "thermometer", label: "體感溫度", value: data.feelsLike)
                WeatherDetailRow(icon: "humidity.fill", label: "濕度", value: data.humidity)
                WeatherDetailRow(icon: "wind", label: "風速", value: data.windSpeed)
            }
        }
        .padding(20)
        .frame(maxWidth: 280)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(red: 0.95, green: 0.97, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.blue.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}

struct WeatherDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.9))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.6))
        }
    }
}

// MARK: - Emergency Card View
struct EmergencyCardView: View {
    let record: EmergencyRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text(record.date)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.6))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.orange)
                    Text(record.location)
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(record.status)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: 280)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .red.opacity(0.1), radius: 8, x: 0, y: 2)
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
                // 用戶頭像 - 修正這裡！
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.3, green: 0.8, blue: 0.7),  // 改成 blue: 0.7
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
