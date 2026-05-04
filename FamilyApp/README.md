# SmartGuide - 親友端應用程式 (Family App)

[English](#english) | [繁體中文](#繁體中文)

---

<a name="english"></a>
## English

The **Family App** is a companion application for the SmartGuide system, designed for family members and caregivers to monitor, communicate with, and ensure the safety of visually impaired users.

### Key Features
- **Real-time Location Monitoring:** Track the user's current position on a high-fidelity hybrid map with status indicators.
- **Emergency Management:** Receive instant SOS alerts with precise location data and a dedicated interface to manage and clear alerts.
- **Fall Detection Analysis:** Advanced monitoring system that displays fall alerts including scene photos, situation analysis, and historical logs.
- **AI Intelligent Assistant:** Integrated chat interface for communication, featuring smart cards for weather updates, navigation records, and emergency history.
- **Safety Analytics:** Review detailed reports on potential risks and environmental hazards detected by the SmartGuide system.

### Technical Overview
- **Framework:** SwiftUI
- **Mapping:** MapKit (Hybrid View)
- **Data Sync:** Real-time WebSocket connection for instantaneous location and alert updates.
- **Shared Core:** Powered by `SmartGuideServices`.

---

<a name="繁體中文"></a>
## 繁體中文

**親友端應用程式 (Family App)** 是 SmartGuide 系統的配套應用，專為家屬與照護者設計，用於監控、溝通並確保視障使用者的安全。

### 主要功能
- **即時位置監控：** 在高畫質混合地圖上追蹤使用者的目前位置，並顯示狀態指示。
- **緊急狀況管理：** 接收包含精確位置數據的即時 SOS 警報，並設有專用介面來管理與清除警報。
- **跌倒偵測分析：** 先進的監控系統，顯示包含現場照片、情況分析與歷史記錄的跌倒警報。
- **AI 智能助理：** 整合式聊天介面，支援天氣更新、導航記錄與緊急歷史記錄的智能卡片。
- **安全分析：** 查看 SmartGuide 系統偵測到的潛在風險與環境危害的詳細報告。

### 技術概覽
- **開發框架：** SwiftUI
- **地圖服務：** MapKit (混合檢視模式)
- **數據同步：** 透過 WebSocket 建立即時連線，確保位置與警報的瞬時更新。
- **共享核心：** 由 `SmartGuideServices` 提供底層支援。
