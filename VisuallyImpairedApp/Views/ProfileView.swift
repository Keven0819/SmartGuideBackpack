//
//  ProfileView.swift
//  SmartGuideBackpack
//
//  Created by imac-3570 on 2025/10/9.
//

import SwiftUI
import SmartGuideServices

struct ProfileView: View {
    
    // MARK: - 使用者資料模型
    
    @State private var profile = UserProfile(
        name: "", phone: "", hospital: "",
        emergencyContact: EmergencyContact(name: "", phone: "", relation: "")
    )
    
    // MARK: - 狀態變數
    
    @State private var showingSaveAlert = false
    
    // MARK: - 主視圖
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.3), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .blur(radius: 8)
            
            ScrollView {
                VStack(spacing: 28) {
                    titleView
                    
                    Group {
                        Text("使用者資訊")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        GlassTextField(title: "姓名", text: $profile.name, keyboardType: .default, textContentType: .name)
                        GlassTextField(title: "電話", text: $profile.phone, keyboardType: .phonePad, textContentType: .telephoneNumber)
                        GlassTextField(title: "常駐醫院", text: $profile.hospital, keyboardType: .default, textContentType: .organizationName)
                    }
                    
                    Divider()
                        .background(Color.cyan.opacity(0.5))
                        .padding(.horizontal)
                    
                    Group {
                        Text("緊急聯絡人")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        GlassTextField(title: "姓名", text: $profile.emergencyContact.name, keyboardType: .default)
                        GlassTextField(title: "電話", text: $profile.emergencyContact.phone, keyboardType: .phonePad)
                        GlassTextField(title: "關係", text: $profile.emergencyContact.relation, keyboardType: .default)
                    }
                    
                    saveButton
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear { loadProfile() }
        .alert("資料已儲存", isPresented: $showingSaveAlert) {
            Button("確定", role: .cancel) {}
        }
        .onTapGesture { UIApplication.shared.endEditing() }
    }
    
    // MARK: - 標題
    
    private var titleView: some View {
        let gradient = LinearGradient(
            colors: [Color.cyan, Color.blue, Color.purple],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        return Text("使用者資料")
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundStyle(gradient)
            .shadow(color: Color.cyan.opacity(0.8), radius: 18, x: 0, y: 0)
            .shadow(color: Color.blue.opacity(0.6), radius: 30, x: 0, y: 0)
            .padding(.top, 40)
    }
    
    // MARK: - 儲存按鈕
    
    private var saveButton: some View {
        let buttonGradient = LinearGradient(
            gradient: Gradient(colors: [Color.cyan, Color.blue]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        return Button {
            saveProfile()
        } label: {
            Text("儲存")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isProfileValid() ? buttonGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: isProfileValid() ? Color.cyan.opacity(0.7) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!isProfileValid())
        .opacity(isProfileValid() ? 1 : 0.6)
        .accessibilityLabel("儲存使用者資料")
        .accessibilityHint(isProfileValid() ? "點擊儲存您的設定" : "請填寫必要欄位後才能儲存")
    }
    
    // MARK: - 資料處理
    
    private func isProfileValid() -> Bool {
        !profile.name.isEmpty &&
        !profile.phone.isEmpty &&
        !profile.emergencyContact.name.isEmpty &&
        !profile.emergencyContact.phone.isEmpty
    }
    
    private func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "UserProfile")
            showingSaveAlert = true
        }
    }
    
    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: "UserProfile"),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
        }
    }
}

// MARK: - GlassTextField

struct GlassTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.callout)
                .foregroundColor(Color.cyan.opacity(0.85))
                .padding(.horizontal)
            
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .padding(12)
                .background(textFieldBackground)
                .foregroundColor(.white)
                .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
    }
    
    private var textFieldBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.black.opacity(0.35))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.cyan.opacity(0.4), radius: 8, x: 0, y: 0)
    }
}

// MARK: - UserProfile Model

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
