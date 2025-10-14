//
//  UserProfile.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import Foundation

// MARK: -- 使用者資料模型

public struct UserProfile: Codable {
    public var name: String
    public var phone: String
    public var hospital: String
    public var emergencyContact: EmergencyContact
}

// MARK: -- 緊急聯絡人模型

public struct EmergencyContact: Codable {
    public var name: String
    public var phone: String
    public var relation: String
}
