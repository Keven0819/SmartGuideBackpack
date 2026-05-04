# SmartGuide - 視障者端應用程式 (Visually Impaired App)

[English](#english) | [繁體中文](#繁體中文)

---

<a name="english"></a>
## English

This application is the client-side component of the **SmartGuide Backpack** system, specifically designed to empower visually impaired users with enhanced mobility, situational awareness, and safety.

### Key Features
- **Intelligent Navigation:** Receive real-time voice and visual guidance instructions through the "Guide Backpack" interface.
- **Location Awareness:** Automatic tracking and display of the current address using high-precision GPS services.
- **SOS Emergency System:** A prominent, easy-to-access SOS button that instantly alerts emergency contacts and family members.
- **Accessibility Optimized:** Built from the ground up with VoiceOver support, featuring semantic labels, hints, and high-contrast UI elements.
- **Personal Safety Profile:** Securely store personal information, medical preferences (e.g., preferred hospital), and emergency contact details.
- **Futuristic UI:** A high-contrast, dark-themed interface with smooth animations for maximum legibility and modern aesthetics.

### Technical Overview
- **Framework:** SwiftUI
- **Services:** CoreLocation for positioning, WebSockets for real-time status syncing.
- **Shared Core:** Powered by `SmartGuideServices`.

---

<a name="繁體中文"></a>
## 繁體中文

本應用程式是 **SmartGuide 導航背包**系統的用戶端組件，專為視障人士設計，旨在提升其行動能力、環境感知能力與安全性。

### 主要功能
- **智能導航：** 透過「導航背包」介面接收即時語音與視覺引導指令。
- **位置感知：** 使用高精度 GPS 服務自動追蹤並顯示目前所在地址。
- **SOS 緊急求救：** 顯眼且易於操作的 SOS 按鈕，可立即通知緊急聯絡人與家屬。
- **輔助功能優化：** 全面支援 VoiceOver，具備語義化標籤、提示以及高對比度 UI 元素。
- **個人安全檔案：** 安全地儲存個人資訊、醫療偏好（如常駐醫院）以及緊急聯絡人詳細資料。
- **未來感介面：** 採用高對比深色主題與平滑動畫，確保最佳的可讀性與現代感美學。

### 技術概覽
- **開發框架：** SwiftUI
- **核心服務：** 使用 CoreLocation 進行定位，透過 WebSocket 進行即時狀態同步。
- **共享核心：** 由 `SmartGuideServices` 提供底層支援。
