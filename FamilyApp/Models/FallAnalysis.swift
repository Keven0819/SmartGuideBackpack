//
//  FallAnalysis.swift
//  FamilyApp
//
//  Created by imac-3570 on 2025/12/26.
//

import Foundation

struct FallAnalysis: Codable, Identifiable {
    var id: UUID = UUID()
    let type: String
    let timestamp: Int
    let imageBase64: String
    let sceneDescription: String
    let situationAnalysis: String
    let messageToUser: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case timestamp
        case imageBase64 = "image_base64"
        case sceneDescription = "scene_description"
        case situationAnalysis = "situation_analysis"
        case messageToUser = "message_to_user"
    }
    
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }
}
