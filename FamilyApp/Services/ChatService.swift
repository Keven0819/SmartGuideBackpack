//
//  ChatService.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/11/3.
//

import Foundation
import SmartGuideServices

class ChatService {
    private let httpClient: HTTPClient
    
    // 定義隱藏的 System Prompt
    // 更新指令：要求兩天資料，並指定格式
    // 格式設計：|||WEATHER|地點|日期1,狀況1,最高1,最低1,降雨1,舒適1;日期2,狀況2,最高2,最低2,降雨2,舒適2|||
    private let hiddenInstruction = """
    
    (IMPORTANT SYSTEM INSTRUCTION:
    回答完使用者的問題後，若內容包含「天氣」資訊，
    請務必在回答的最後面換行，並嚴格依照以下格式附上【兩天】的預報資料以便程式解析：
    
    |||WEATHER|地點|日期1,天氣狀況1,最高溫1,最低溫1,降雨機率1,舒適度1;日期2,天氣狀況2,最高溫2,最低溫2,降雨機率2,舒適度2|||
    
    範例：
    |||WEATHER|台中市|今天,多雲午後雷陣雨,32°C,26°C,60%,悶熱;明天,晴時多雲,33°C,27°C,20%,易中暑|||
    
    如果是導航或求救紀錄，維持原格式：
    |||NAV|日期|目的地|||
    |||SOS|日期|地點|狀態|||
    
    若無相關資料則不需要附上標籤，絕對不要使用 Markdown。)
    """
    
    init() {
        // 假設你的 n8n 位置
        self.httpClient = HTTPClient(baseURL: URL(string: "http://192.168.2.7:5678")!)
    }
    
    func sendMessage(userQuery: String) async throws -> String {
        // 1. 將隱藏指令注入到使用者的查詢中
        let injectedQuery = userQuery + hiddenInstruction
        
        let body: [String: Any] = ["UserQuery": injectedQuery]
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        // 2. 發送請求 (n8n 會收到包含指令的文字)
        let data = try await httpClient.post(path: "webhook/EyeHelper", body: jsonData)
        
        // 3. n8n 此時回傳的應該是純文字 (包含 AI 的回答 + 我們要求的 ||| 標籤)
        if let responseString = String(data: data, encoding: .utf8) {
            // 處理 n8n 可能回傳的 JSON 包裝 (如果 n8n 預設回傳 { "output": "..." })
            // 這裡做一個簡單的清洗，防止 n8n 回傳的是 JSON 格式的 String
            return cleanJSONResponse(responseString)
        }
        
        throw URLError(.cannotDecodeContentData)
    }
    
    // 簡單的輔助函式，若 n8n 回傳的是 JSON 格式字串，嘗試取出內容；否則回傳原字串
    private func cleanJSONResponse(_ text: String) -> String {
        if let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // 嘗試抓取常見的 n8n 輸出欄位
            return (json["output"] as? String) ?? (json["text"] as? String) ?? text
        }
        return text
    }
}
