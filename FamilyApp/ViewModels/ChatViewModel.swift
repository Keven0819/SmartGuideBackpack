//
//  ChatViewModel.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/11/3.
//

import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chatItems: [ChatItem] = []
    @Published var isTyping: Bool = false
    
    private let chatService = ChatService()
    
    init() {
        addMessage("哈囉！我是您的視障背包語音助手。", isUser: false)
        addMessage("你可以問我：\n• 查詢求救紀錄\n• 查詢導航紀錄\n• 查詢天氣資訊", isUser: false)
    }
    
    func sendUserMessage(_ text: String) {
        // 1. 先顯示使用者的訊息 (立刻執行)
        // 這會觸發第一個動畫：使用者氣泡滑入
        addMessage(text, isUser: true)
        
        Task {
            // 2. 關鍵修改：加入 "視覺延遲"
            // 讓使用者的訊息先跑完動畫定位好 (約 0.6 秒)，再顯示 "AI 正在輸入"
            // 這讓對話感覺更有節奏感，不會瞬間全部擠出來
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 秒
            
            // 3. 顯示 AI 正在輸入動畫
            // 必須回到 MainActor (主執行緒) 更新 UI
            await MainActor.run {
                withAnimation(.spring()) {
                    isTyping = true
                }
            }
            
            do {
                // 4. 發送網路請求 (這時候 AI 正在輸入的動畫已經在畫面上了)
                let rawResponse = try await chatService.sendMessage(userQuery: text)
                
                // 5. 收到回應後，先關閉 "正在輸入"
                await MainActor.run {
                    withAnimation {
                        isTyping = false
                    }
                }
                
                // 6. 解析並顯示回應 (這裡會觸發回應的文字/卡片動畫)
                parseAndDisplayResponse(rawResponse)
                
            } catch {
                // 錯誤處理
                await MainActor.run {
                    withAnimation {
                        isTyping = false
                    }
                    print("Error: \(error)")
                    addMessage("連線發生錯誤", isUser: false)
                }
            }
        }
    }
    
    // MARK: - 解析邏輯 (Client-side Parsing)
    
    private func parseAndDisplayResponse(_ rawText: String) {
        // 定義我們的分隔符號
        let pattern = "\\|\\|\\|(.*?)\\|\\|\\|"
        
        var displayText = rawText
        var cardsData: [String] = []
        
        // 使用 Regex 尋找所有隱藏標籤
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: rawText, range: NSRange(rawText.startIndex..., in: rawText))
            
            // 倒序處理，這樣刪除文字時 range 比較好算
            for match in matches.reversed() {
                if let range = Range(match.range, in: rawText) {
                    // 1. 取出標籤內容 (例如：WEATHER|台中|24...)
                    let tagContent = String(rawText[range])
                        .replacingOccurrences(of: "|||", with: "")
                    cardsData.append(tagContent)
                    
                    // 2. 從顯示文字中移除這個標籤，以免使用者看到亂碼
                    displayText.removeSubrange(range)
                }
            }
        }
        
        // 檢查是否有天氣標籤
        let isWeahterResponse = cardsData.contains { $0.hasPrefix("WEATHER") }
        
        // 1. 先顯示乾淨的文字回應
        let cleanText = displayText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanText.isEmpty {
            // 只有在不是查詢天氣的時候才顯示文字
            if !isWeahterResponse {
                addMessage(cleanText, isUser: false)
            }
        }
        
        // 2. 解析並生成卡片 (因為是倒序抓取，這裡要反轉回來)
        processExtractedTags(cardsData.reversed())
    }
    
    private func processExtractedTags(_ tags: [String]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: Date())
        
        for tag in tags {
            // 先以 "|" 分割取出類型和主要內容
            // 格式範例：WEATHER | 台中市 | 今天,多雲..,..;明天,晴,..
            let mainParts = tag.split(separator: "|").map { String($0) }
            guard let type = mainParts.first else { continue }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    switch type {
                    case "WEATHER":
                        // 檢查格式長度是否足夠 (至少要有 類型, 地點, 資料串)
                        if mainParts.count >= 3 {
                            let location = mainParts[1]
                            let dataString = mainParts[2]
                            
                            var forecasts: [DailyForecast] = []
                            
                            // 1. 先用分號 ";" 切割出天數
                            let days = dataString.split(separator: ";")
                            
                            for dayData in days {
                                // 2. 再用逗號 "," 切割出詳細欄位
                                // 順序：日期, 狀況, 最高, 最低, 降雨, 舒適
                                let fields = dayData.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                                
                                if fields.count >= 6 {
                                    let forecast = DailyForecast(
                                        date: fields[0],
                                        condition: fields[1],
                                        maxTemp: fields[2],
                                        minTemp: fields[3],
                                        rainProb: fields[4],
                                        comfort: fields[5]
                                    )
                                    forecasts.append(forecast)
                                }
                            }
                            
                            if !forecasts.isEmpty {
                                let weatherData = WeatherData(location: location, forecasts: forecasts)
                                self.chatItems.append(.card(MessageCard(cardType: .weather(weatherData), time: timeStr)))
                            }
                        }
                        
                    case "NAV":
                        // 維持原樣...
                        if mainParts.count >= 3 {
                            let nav = NavigationRecord(date: mainParts[1], destination: mainParts[2])
                            self.chatItems.append(.card(MessageCard(cardType: .navigation(nav), time: timeStr)))
                        }
                        
                    case "SOS":
                        // 維持原樣...
                        if mainParts.count >= 4 {
                            let sos = EmergencyRecord(date: mainParts[1], location: mainParts[2], status: mainParts[3])
                            self.chatItems.append(.card(MessageCard(cardType: .emergency(sos), time: timeStr)))
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // 簡單的 Emoji 對照
    private func getWeatherEmoji(condition: String) -> String {
        if condition.contains("雨") { return "🌧️" }
        if condition.contains("雲") || condition.contains("陰") { return "☁️" }
        if condition.contains("晴") { return "☀️" }
        return "🌤️"
    }
    
    private func addMessage(_ text: String, isUser: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeStr = formatter.string(from: Date())
        let msg = Message(text: text, isUser: isUser, time: timeStr)
        withAnimation {
            chatItems.append(.message(msg))
        }
    }
}
