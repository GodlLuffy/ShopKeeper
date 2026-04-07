<p align="center">
  <img src="Shop_Keeper_Project/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="120" alt="ShopKeeper Logo"/>
</p>

<h1 align="center">🛒 ShopKeeper</h1>

<p align="center">
  <strong>A Premium, High-Performance 'Cyber Orchid' SaaS Retail OS</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/license-MIT-22c55e" alt="License"/>
  <img src="https://img.shields.io/github/stars/GodlLuffy/ShopKeeper?style=social" alt="Stars"/>
  <img src="https://img.shields.io/github/forks/GodlLuffy/ShopKeeper?style=social" alt="Forks"/>
  <img src="https://img.shields.io/github/issues/GodlLuffy/ShopKeeper" alt="Issues"/>
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Web-orange" alt="Platform"/>
</p>

<p align="center">
  ShopKeeper is a modern, high-performance 'Cyber Orchid' Flutter application designed for retail business owners. It empowers shopkeepers with real-time insights, bulletproof Cloud Sync, and a premium neon-infused user experience that rivals the world's best financial platforms.
</p>

---

## ✨ Features

### 🚀 Business Intelligence
- **🤖 AI Assistant** — Query your business data in natural language to get instant insights on stock, sales, and profits.
- **📊 Real-time Analytics** — Beautiful, interactive charts for revenue tracking and expense monitoring.
- **📈 Trend Analysis** — Visualize your growth with daily, weekly, and monthly reports.

### 🧾 Point-of-Sale Billing
- **⚡ Fast Billing** — Barcode scanner integration for rapid product entry.
- **🧾 Premium Invoices** — Generate and share professional invoices instantly.
- **🖨 Print Support** — Thermal printer compatible for receipt printing.

### 🔐 Security & Data
- **🛡️ FinTech-Grade Security** — 4-digit PIN lock with biometric authentication (Fingerprint / FaceID).
- **⚔️ Hardened Cloud Sync** — Enterprise-ready real-time synchronization with Google Firebase.
- **📈 Sync Evolution Center** — A dedicated dashboard to monitor and manage pending cloud operations in real-time.
- **💾 Offline First (Hive)** — Full offline capability ensuring zero-latency operations without internet.

### 🎨 Premium UI/UX
- **🌌 Cyber Orchid Theme** — Our signature high-contrast Neon Orchid & Electric Cyan palette on Midnight Black backgrounds.
- **💎 Glassmorphism 2.0** — Advanced 30px backdrop blurs and luminous micro-borders for a flagship experience.
- **📦 Smart Inventory** — Barcode/QR code support for fast product entry and stock management.
- **🏠 Profile Management** — Dedicated Shop Profile section to manage store identity.
- **📱 Responsive Layouts** — Perfectly optimized for mobile, tablet, and desktop.
- **🌐 Multi-language** — Localization support for global reach.

---

## 📸 Screenshots

<p align="center">
  <em>Screenshots coming soon — stay tuned!</em>
</p>

<!-- Uncomment and add your screenshots:
<p align="center">
  <img src="screenshots/dashboard.png" width="250"/>
  <img src="screenshots/billing.png" width="250"/>
  <img src="screenshots/inventory.png" width="250"/>
</p>
-->

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Platform** | Flutter SDK (Dart) |
| **Architecture** | Clean Architecture + BLoC/Cubit |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Local DB** | Hive (High-performance NoSQL) |
| **Security** | Biometric Auth & Secure Storage |
| **State Mgmt** | flutter_bloc |
| **UI** | Google Fonts, fl_chart, flutter_animate |
| **Navigation** | go_router |

---

## 📂 Project Structure

```text
lib/
├── core/             # Design system, themes, and shared utilities
├── database/         # Local persistence (Hive schemes & adapters)
├── features/         # Clean Architecture based modules
│   ├── ai_assistant/ # Intelligent business insights layer
│   ├── auth/         # Secure login & registration
│   ├── billing/      # POS billing & invoice system
│   ├── inventory/    # Stock & product management
│   ├── sales/        # Transaction recording & history
│   ├── expenses/     # Cost management
│   └── settings/     # Shop profile & app configuration
├── services/         # Core services (PIN, biometric, etc.)
└── main.dart         # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase Project (configured)
- Android Studio / VS Code

### Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/GodlLuffy/ShopKeeper.git
cd ShopKeeper/Shop_Keeper_Project

# 2. Install dependencies
flutter pub get

# 3. Setup Firebase
# Place google-services.json in android/app/
# Place GoogleService-Info.plist in ios/Runner/

# 4. Run
flutter run
```

---

## 🤝 Contributing

Contributions make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🗺️ Roadmap (Current Progress: 60%)

🚧 **Phase 9: Multi-Device Sync & Conflict Resolution (Completed)**  
📅 **Phase 10: Supplier Management & Purchase Orders (Upcoming)**

---

## 🛡️ Security

Please see our [Security Policy](SECURITY.md) for reporting vulnerabilities.

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 📄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

---

<p align="center">
  Built with ❤️ for Shopkeepers by <a href="https://github.com/GodlLuffy">Anup (GodlLuffy)</a>
</p>

<p align="center">
  <a href="https://github.com/GodlLuffy/ShopKeeper/stargazers">⭐ Star this repo if you find it useful!</a>
</p>
