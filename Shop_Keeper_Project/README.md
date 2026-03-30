# 🛒 ShopKeeper 

> **A Premium, FinTech-Grade Inventory & Sales Management Solution**

ShopKeeper is a modern, high-performance Flutter application designed for retail business owners. It empowers shopkeepers with real-time insights, secure data management, and a premium user experience that rivals the best financial apps in the market.

---

## ✨ Key Features

### 🚀 Business Intelligence
- **🤖 AI Assistant**: Query your business data in natural language to get instant insights on stock, sales, and profits.
- **📊 Real-time Analytics**: Beautiful, interactive charts for revenue tracking and expense monitoring.
- **📈 Trend Analysis**: Visualize your growth with daily, weekly, and monthly reports.

### 🔐 Security & Data
- **🛡️ FinTech Grade Security**: 4-digit PIN lock with biometric authentication (Fingerprint/FaceID) support.
- **☁️ Cloud Sync**: Seamless real-time synchronization with Google Firebase.
- **💾 Offline First**: Full offline capability using Hive, ensuring your business stays operational even without internet.

### 🎨 Premium UI/UX
- **✨ Glassmorphism Design**: Elegant UI components with subtle transparency and blur effects.
- **📦 Smart Inventory**: Barcode/QR code support for fast product entry and stock management.
- **🏠 Profile Management**: Dedicated Shop Profile section to manage store identity and owner details.
- **📱 Responsive Layouts**: Perfectly optimized for various screen sizes with smooth micro-animations.

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
