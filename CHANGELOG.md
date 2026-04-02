# Changelog

All notable changes to ShopKeeper will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.5] - 2026-04-02

### 🌌 Added (Cyber Orchid Era)
- **Cyber Orchid Design System** — Transitioned to a high-contrast Neon Orchid & Electric Cyan palette.
- **💎 Glassmorphism 2.0** — Upgraded blurs (30px) and micro-borders for flagship aesthetics.
- **📈 Sync Evolution Center** — real-time dashboard for monitoring and managing pending cloud operations.
- **⚔️ Hardened Sync Engine** — Enterprise-grade Firestore synchronization with multi-device conflict resolution.
- **🔐 PIN Lock Resiliency** — Fixed layout overflows and stabilized biometric authentication flows.

### 🛠️ Refactored
- **Sync Architecture:** Migrated logic from legacy `SyncService` to a centralized, hardened `SyncEngine`.
- **Global Themes:** Consolidated design tokens into a centralized `AppTheme` system.
- **Clean Architecture:** Removed redundant services and obsolete planning files.

---

## [1.0.0] - 2026-03-30

### 🚀 Added
- **POS Billing System** — Full point-of-sale with barcode scanner and invoice generation
- **AI Assistant** — Natural language queries for business insights
- **Inventory Management** — Add, edit, delete products with barcode/QR support
- **Sales Tracking** — Complete transaction history with daily/weekly/monthly reports
- **Expense Management** — Track and categorize business expenses
- **Cloud Sync** — Real-time Firebase Firestore synchronization
- **Offline Mode** — Full offline capability with Hive local database
- **PIN Lock** — 4-digit PIN with biometric authentication (Fingerprint / FaceID)
- **Email Verification** — Automatic verification email on registration
- **Password Reset** — "Forgot Password" flow with Firebase email templates
- **Shop Profile** — Manage shop name, owner details, and contact info
- **Premium UI** — Glassmorphism design with smooth micro-animations
- **Multi-platform** — Support for Android, iOS, Windows, and Web

### 🔐 Security
- FinTech-grade PIN + Biometric authentication
- Firebase Auth with email verification
- Encrypted local storage

### 🎨 Design
- Premium dark/light mode glassmorphism theme
- Interactive charts (fl_chart)
- Smooth animations (flutter_animate)
