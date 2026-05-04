# SmartGuide Backpack - 智能導航背包系統

[English](#english) | [繁體中文](#繁體中文)

---

<a name="english"></a>
## English

**SmartGuide Backpack** is an integrated ecosystem designed to enhance the mobility and safety of visually impaired individuals. The system consists of a hardware "Guide Backpack" and two dedicated mobile applications.

### Project Structure
- **VisuallyImpairedApp/**: The client-side app for visually impaired users, providing navigation instructions and emergency triggers.
- **FamilyApp/**: The companion app for family members/caregivers to monitor location, safety status, and fall alerts.
- **SmartGuideServices/**: Shared logic, networking (HTTP/WebSocket), and core services used by both applications.

### Key Features

#### 1. Visually Impaired App
- **Voice Navigation:** Real-time audio and haptic feedback for spatial awareness.
- **Instant SOS:** One-touch emergency signaling to pre-configured contacts.
- **Location Awareness:** Continuous tracking with semantic address reporting.
- **Accessibility First:** Fully optimized for VoiceOver and high-contrast visuals.

#### 2. Family App
- **Live Map Tracking:** Monitor the user's location in real-time with hybrid map views.
- **Fall Detection Analysis:** Receive AI-processed fall alerts including scene photos and situational reports.
- **Emergency Hub:** Instant notifications for SOS triggers with one-tap navigation to the user.
- **AI Smart Assistant:** A chat interface for historical data retrieval (weather, navigation history, and emergency logs).

### Technical Stack
- **Language:** Swift 5.x
- **UI Framework:** SwiftUI
- **Maps:** MapKit
- **Real-time Sync:** WebSockets & RESTful APIs
- **Architecture:** MVVM (Model-View-ViewModel)

---

<a name="繁體中文"></a>
## 繁體中文

**SmartGuide Backpack (智能導航背包)** 是一個整合式生態系統，旨在提升視障人士的行動力與安全性。本系統由硬體「導航背包」以及兩款專屬行動應用程式組成。

### 專案結構
- **VisuallyImpairedApp/**：視障使用者端 App，提供導航指引與緊急求救功能。
- **FamilyApp/**：親友端 App，用於監控位置、安全狀態以及接收跌倒警報。
- **SmartGuideServices/**：共享邏輯、網路通訊 (HTTP/WebSocket) 及兩款 App 通用的核心服務。

### 主要功能

#### 1. 視障者端應用程式
- **語音導航：** 提供即時的音訊與觸覺回饋，增強空間感知。
- **即時 SOS：** 一鍵發送緊急訊號至預設聯絡人。
- **位置感知：** 持續追蹤並提供語義化的地址回報。
- **輔助功能優先：** 全面針對 VoiceOver 與高對比度視覺進行優化。

#### 2. 親友端應用程式
- **即時地圖追蹤：** 透過混合地圖介面即時監控使用者位置。
- **跌倒偵測分析：** 接收經 AI 處理的跌倒警報，包含現場照片與情況報告。
- **緊急中心：** SOS 觸發時立即通知，並支援一鍵導航至使用者所在地。
- **AI 智能助理：** 提供聊天介面以查詢歷史數據（天氣、導航記錄與緊急日誌）。

### 技術棧
- **開發語言：** Swift 5.x
- **UI 框架：** SwiftUI
- **地圖服務：** MapKit
- **即時同步：** WebSockets 與 RESTful APIs
- **架構設計：** MVVM (Model-View-ViewModel)
