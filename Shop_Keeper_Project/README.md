# 🛒 ShopKeeper PRO

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Design-Cyber_Orchid-EA4335?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Developer-Anup-4285F4?style=for-the-badge" />
</p>

---

## 🌌 The Enterprise-Grade'Cyber Orchid' Retail OS

**ShopKeeper PRO** is a premium, high-performance SaaS retail operating system. It empowers modern business owners with real-time financial intelligence, professional audit reporting, and a luxury "Cyber Orchid" aesthetic that sets a new standard for business management.

---

## ✨ Flagship Features

### 📊 Executive Financial Intelligence
- **📄 AI-Powered PDF Audits**: Generate professional PDF profit reports for "Today" or "Monthly" periods with a single tap.
- **📈 Real-time Analytics**: Interactive Fl-Charts for revenue, cost, and net profit monitoring.
- **📤 Smart Sharing**: Instantly share audit summaries via WhatsApp, Email, or Print.

### 🚛 Advanced Procurement Ledger
- **🏢 Vendor Registration**: Detailed supplier records including business addresses and contact persons.
- **📞 Direct Action**: Call or message vendors directly from the app using integrated communication shortcuts.
- **💸 Debt Tracking**: Real-time accounts payable monitoring with automated balance calculations.

### 🔐 FinTech Grade Security
- **🛡️ Shield-Check Encryption**: 4-digit PIN lock to protect sensitive financial data.
- **⚔️ Hardened Cloud Sync**: Enterprise-ready real-time synchronization with Google Firebase.
- **💾 Offline First (Hive)**: Zero-latency operations ensured by a robust local NoSQL database.

### 🎨 Signature Cyber Orchid UI
- **💎 Glassmorphism 2.0**: Advanced backdrop blurs and luminous micro-borders for a flagship experience.
- **✨ Gold-Indigo Accents**: A curated color palette designed for high-end enterprise applications.
- **🚀 Ultra-Smooth Motion**: State-of-the-art micro-animations using `flutter_animate`.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Core Framework** | Flutter SDK (Dart) |
| **State Management** | BLoC / Cubit Pattern |
| **Backend** | Firebase (Auth, Firestore, Cloud Messaging) |
| **Local Persistence** | Hive (High-performance NoSQL) |
| **Reporting Engine** | PDF & Printing Services |
| **Iconography** | Lucide Icons (Premium Vector Set) |
| **Typography** | Outfit (Google Fonts) |

---

## 🚀 Installation & Build

### Prerequisites
- Flutter SDK (latest stable)
- Firebase Project configured in the Google Cloud Console.

### Setup Steps
1. **Clone & Install**:
   ```bash
   git clone https://github.com/GodlLuffy/Shop_Keeper_Project.git
   cd Shop_Keeper_Project
   flutter pub get
   ```
2. **Setup Firebase**:
   - Place `google-services.json` in `android/app/`.
   - Ensure the SHA-1 fingerprints are registered in Firebase Console.

### Production Build (Android)
To generate the final release APKs:
```powershell
flutter clean
flutter build apk --release --split-per-abi
```

---

<p align="center">
  <b>Developed with ❤️ for the next generation of Shopkeepers by Anup</b><br/>
  <i>Empowering local businesses with global technology.</i>
</p>

---

© 2026 ShopKeeper PRO OS. All Rights Reserved.
