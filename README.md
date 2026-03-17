# 🛒 ShopKeeper Project

A modern, premium Flutter application designed for shopkeepers to manage their inventory, sales, expenses, and more with ease. Built with performance and user experience in mind, featuring real-time synchronization and offline support.

---

## ✨ Features

- **🔐 Secure Authentication**: Integrated with Firebase Auth for robust user management.
- **📦 Inventory Management**: Track products, stock levels, and historical changes seamlessly.
- **💰 Sales & Revenue Tracking**: Record sales and view detailed revenue reports with interactive charts.
- **💸 Expense Management**: Monitor operational costs and maintain a healthy balance sheet.
- **📊 Interactive Analytics**: Visualize your business health with beautiful charts powered by `fl_chart`.
- **☁️ Real-time Sync**: Synchronize your data across devices using Cloud Firestore.
- **📥 Offline Capability**: Built-in offline support using `Hive` for uninterrupted service.
- **✨ Premium UI/UX**: Smooth animations with `flutter_animate` and custom typography with `Google Fonts`.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Cubit/Bloc](https://pub.dev/packages/flutter_bloc)
- **Dependency Injection**: [Get_it](https://pub.dev/packages/get_it)
- **Database**: 
  - [Cloud Firestore](https://firebase.google.com/docs/firestore) (Cloud)
  - [Hive](https://docs.hivedb.dev/) (Local)
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth)
- **Storage**: [Firebase Storage](https://firebase.google.com/docs/storage)
- **UI & Animation**: `flutter_animate`, `google_fonts`, `fl_chart`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase Project setup

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/GodlLuffy/ShopKeeper.git
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```text
lib/
├── core/             # Core utilities, errors, and themes
├── database/         # Local database (Hive) configurations
├── features/         # Feature-based architecture (Clean Architecture)
│   ├── auth/         # Authentication logic and UI
│   ├── inventory/    # Product and stock management
│   ├── sales/        # Sales recording and history
│   ├── expenses/     # Expense tracking
│   └── settings/     # Shop profile and app settings
├── services/         # External service integrations (Firebase, Sync)
└── main.dart         # Entry point
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve the project.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ by [GodlLuffy](https://github.com/GodlLuffy)
