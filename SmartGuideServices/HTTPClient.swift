//
//  HTTPClient.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import Foundation

public struct HTTPClient {
    
    // MARK: -- 屬性與初始化
    
    private let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: -- HTTP 方法
    
    public func post(path: String, body: Data) async throws -> Data {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    public func get(path: String) async throws -> Data {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = "GET"
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
