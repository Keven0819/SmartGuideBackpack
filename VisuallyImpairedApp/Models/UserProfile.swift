//
//  UserProfile.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import Foundation

public struct UserProfile: Codable {
    public var name: String
    public var phone: String
    public var hospital: String
    public var emergencyContact: EmergencyContact
}

public struct EmergencyContact: Codable {
    public var name: String
    public var phone: String
    public var relation: String
}
