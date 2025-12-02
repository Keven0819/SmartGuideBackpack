//
//  ChatView.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/11/3.
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

// 卡片類型 (保留結構以便未來擴充，目前 Agent 主要回傳文字)
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

// 單日預報結構
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: String        // 日期
    let condition: String   // 天氣狀況
    let maxTemp: String     // 最高溫
    let minTemp: String     // 最低溫
    let rainProb: String    // 降雨機率
    let comfort: String     // 舒適度
    
    // 根據天氣狀況自動判斷 Emoji
    var emoji: String {
        if condition.contains("雨") { return "🌧️" }
        if condition.contains("雷") { return "⛈️" }
        if condition.contains("雲") || condition.contains("陰") { return "☁️" }
        if condition.contains("晴") { return "☀️" }
        return "🌤️"
    }
}

// 天氣資料總容器
struct WeatherData: Identifiable {
    let id = UUID()
    let location: String
    let forecasts: [DailyForecast] // 這裡存放兩天的資料
}

// 訊息卡片結構
struct MessageCard: Identifiable {
    let id = UUID()
    let cardType: CardType
    let time: String
}

struct ChatView: View {
    // MARK: - ViewModel
    @StateObject private var vm = ChatViewModel()
    
    @State private var inputText = ""
    
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
            .onTapGesture { // <--- 新增 1：點擊背景隱藏鍵盤
                hideKeyboard()
            }
            
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
                            // 綁定 ViewModel 的資料
                            ForEach(vm.chatItems) { item in
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
                            
                            // 綁定 ViewModel 的打字狀態
                            if vm.isTyping {
                                TypingIndicator()
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                    }
                    // 新增 2：點擊訊息列表的空白處也能隱藏鍵盤 (選擇性，但推薦加上)
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .onChange(of: vm.chatItems.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onAppear {
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
        if let last = vm.chatItems.last {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
    
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        // 呼叫 ViewModel 發送真實請求
        vm.sendUserMessage(trimmed)
        inputText = ""
        
        // 新增 3：發送後自動收起鍵盤
        hideKeyboard()
    }
}

// MARK: - Message Card Row
struct MessageCardRow: View {
    let card: MessageCard
    
    var body: some View {
        // 修改 1：將 alignment 改為 .top (原本是 .bottom)
        HStack(alignment: .top, spacing: 12) {
            
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
            .padding(.top, 4) // 修改 2：微調頂部位置，讓頭像跟卡片標題視覺平行
            
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
            // formatter.locale = Locale(identifier: "zh_TW") // 若需要繁體中文顯示
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Updated Weather Card View (格線佈局版)

struct WeatherCardView: View {
    let data: WeatherData
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. 標題區
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                    .font(.system(size: 16))
                
                Text(data.location)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                
                Spacer() // 標題靠左，右邊留白
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(Color(red: 0.98, green: 0.99, blue: 1.0)) // 極淡的藍色背景區隔標題
            
            Divider()
            
            // 2. 列表區
            VStack(spacing: 0) {
                ForEach(Array(data.forecasts.enumerated()), id: \.element.id) { index, forecast in
                    ForecastRow(forecast: forecast)
                    
                    // 分隔線
                    if index < data.forecasts.count - 1 {
                        Divider()
                            .padding(.leading, 20) // 讓分隔線從左邊留點空隙，比較優雅
                    }
                }
            }
        }
        // 修改：使用 maxWidth 讓它在小螢幕自動縮小，大螢幕保持寬度
        .frame(maxWidth: 330) // 加寬卡片，讓資訊不擁擠
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// 單日天氣行組件 (修正長文字顯示問題)
struct ForecastRow: View {
    let forecast: DailyForecast
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // --- 左欄：日期與圖示 (固定寬度 60) ---
            VStack(spacing: 6) {
                Text(formatDate(forecast.date))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.5, green: 0.6, blue: 0.8))
                    )
                
                Text(forecast.emoji)
                    .font(.system(size: 34))
            }
            .frame(width: 60) // 固定左側寬度
            
            // --- 右欄：詳細資訊 ---
            VStack(spacing: 8) {
                // 上排：天氣狀況 (左) + 溫度範圍 (右)
                // 改用 alignment: .top 確保如果天氣狀況換行，溫度還是會對齊第一行的高度
                HStack(alignment: .firstTextBaseline) {
                    
                    Text(forecast.condition)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.35))
                        .lineLimit(2) // 關鍵修改 1：允許最多顯示兩行
                        .minimumScaleFactor(0.8) // 關鍵修改 2：字太長時允許稍微縮小
                        .fixedSize(horizontal: false, vertical: true) // 允許垂直延展
                    
                    Spacer(minLength: 8) // 保持最小間距
                    
                    // 溫度
                    HStack(spacing: 0) {
                        Text(forecast.minTemp)
                        Text("~")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 2)
                        Text(forecast.maxTemp)
                    }
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                    .layoutPriority(1) // 關鍵修改 3：給予溫度較高優先權，確保它不被壓縮
                }
                
                // 下排：降雨機率 (左) + 舒適度 (右)
                HStack {
                    // 降雨
                    HStack(spacing: 4) {
                        Image(systemName: "umbrella.fill")
                            .font(.system(size: 10))
                        Text(forecast.rainProb)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    
                    Spacer()
                    
                    // 舒適度
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 10))
                        Text(forecast.comfort)
                            .font(.system(size: 12, weight: .regular))
                    }
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.96))
                    .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    // MARK: - 日期格式化 (保持不變)
    func formatDate(_ dateString: String) -> String {
        if dateString.contains("天") { return dateString }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "M/d"
            return outputFormatter.string(from: date)
        }
        inputFormatter.dateFormat = "MM-dd"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "M/d"
            return outputFormatter.string(from: date)
        }
        return dateString
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

// 加在檔案最下方
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
