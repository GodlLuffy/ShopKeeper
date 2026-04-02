# 🛒 ShopKeeper 

> **A Premium, High-Performance 'Cyber Orchid' SaaS Retail OS**

ShopKeeper is a modern, high-performance 'Cyber Orchid' Flutter application designed for retail business owners. It empowers shopkeepers with real-time insights, bulletproof Cloud Sync, and a premium neon-infused user experience that rivals the world's best financial platforms.

---

## ✨ Key Features

### 🚀 Business Intelligence
- **🤖 AI Assistant**: Query your business data in natural language to get instant insights on stock, sales, and profits.
- **📊 Real-time Analytics**: Beautiful, interactive charts for revenue tracking and expense monitoring.
- **📈 Trend Analysis**: Visualize your growth with daily, weekly, and monthly reports.

### 🔐 Security & Data
- **🛡️ FinTech Grade Security**: 4-digit PIN lock with biometric authentication (Fingerprint/FaceID) support.
- **⚔️ Hardened Cloud Sync**: Enterprise-ready real-time synchronization with Google Firebase.
- **📈 Sync Evolution Center**: A dedicated dashboard to monitor and manage pending cloud operations in real-time.
- **💾 Offline First (Hive)**: Full offline capability ensuring zero-latency operations without internet.

### 🎨 Premium UI/UX
- **🌌 Cyber Orchid Theme**: Our signature high-contrast Neon Orchid & Electric Cyan palette on Midnight Black backgrounds.
- **💎 Glassmorphism 2.0**: Advanced 30px backdrop blurs and luminous micro-borders for a flagship experience.
- **📦 Smart Inventory**: Barcode/QR code support for fast product entry and stock management.
- **🏠 Profile Management**: Dedicated Shop Profile section to manage store identity and owner details.
- **📱 Responsive Layouts**: Perfectly optimized for mobile, tablet, and desktop.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Platform** | Flutter SDK (Dart) |
| **State Management** | BLoC / Cubit |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Local DB** | Hive (High-performance NoSQL) |
| **Security** | Biometric Auth & Secure Storage |
| **UI Components** | Google Fonts, fl_chart, flutter_animate |

---

## 📂 Project Structure

```text
lib/
├── core/             # Design system, themes, and shared utilities
├── database/         # Local persistence (Hive schemes & adapters)
├── features/         # Clean Architecture based modules
│   ├── ai_assistant/ # Intelligent business insights layer
│   ├── auth/         # Secure login & registration
│   ├── inventory/    # Stock & product management
│   ├── sales/        # Transaction recording & history
│   ├── expenses/     # Cost management
│   └── settings/     # Shop profile & app configuration
└── main.dart         # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase Project (Configured)

### Quick Start
1. **Clone & Install**:
   ```bash
   git clone https://github.com/GodlLuffy/ShopKeeper.git
   flutter pub get
   ```
2. **Setup Firebase**:
   - Place `google-services.json` in `android/app/`.
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
3. **Run**:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing
Contributions make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for Shopkeepers by <a href="https://github.com/GodlLuffy">GodlLuffy</a>
</p>
