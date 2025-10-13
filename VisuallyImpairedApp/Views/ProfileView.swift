//
//  ProfileView.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import SmartGuideServices

struct ProfileView: View {
    @State private var profile = UserProfile(
        name: "", phone: "", hospital: "",
        emergencyContact: EmergencyContact(name: "", phone: "", relation: "")
    )
    
    var body: some View {
        Form {
            Section(header: Text("使用者資訊")) {
                TextField("姓名", text: $profile.name)
                    .textContentType(.name)
                    .autocapitalization(.words)
                TextField("電話", text: $profile.phone)
                    .keyboardType(.phonePad)
                TextField("常駐醫院", text: $profile.hospital)
            }
            Section(header: Text("緊急聯絡人")) {
                TextField("姓名", text: $profile.emergencyContact.name)
                    .autocapitalization(.words)
                TextField("電話", text: $profile.emergencyContact.phone)
                    .keyboardType(.phonePad)
                TextField("關係", text: $profile.emergencyContact.relation)
                    .autocapitalization(.words)
            }
            
            Button {
                if let data = try? JSONEncoder().encode(profile) {
                    UserDefaults.standard.set(data, forKey: "UserProfile")
                }
            } label: {
                Text("儲存")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.vertical)
        }
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "UserProfile"),
               let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
                profile = saved
            }
        }
        .navigationTitle("設定")
    }
}
