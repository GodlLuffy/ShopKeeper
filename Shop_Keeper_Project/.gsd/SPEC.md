# SPEC.md — Project Specification

> **Status**: `FINALIZED`
>
> ⚠️ **Planning Lock**: No code may be written until this spec is marked `FINALIZED`.

## Vision
ShopKeeper PRO is a **Premium Smart Retail OS** for Indian SMBs (kirana stores, retailers) built with Flutter. It competes with PhonePe Business, Vyapar, and Shopify POS. The app runs on low-to-mid end Android devices but delivers a premium FinTech-grade experience with glassmorphism, micro-animations, offline-first architecture, and AI-driven business insights.

## Goals
1. **Complete Retail Operations** — Full POS billing, inventory, sales tracking, expense logging, and customer credit (Udhar) management in one app
2. **Premium Dark UI** — "Royal Obsidian" glassmorphic dark theme with micro-animations that feels like CRED/PhonePe Business
3. **Offline-First + Cloud Sync** — Hive for local persistence, Firebase Firestore for cloud backup, seamless sync
4. **AI Business Intelligence** — Smart insights on stock depletion, sales trends, and profit optimization
5. **Indian Market Features** — GST calculation, WhatsApp integration, Udhar/credit system, Hindi-ready

## Non-Goals (Out of Scope)
- Multi-store chain management
- Employee/staff management system
- E-commerce / online storefront
- Payment gateway integration (UPI/Razorpay)
- Accounting/GST filing compliance
- iOS App Store launch (Android-first)

## Constraints
- **Platform**: Flutter (Dart), Android-first, min SDK 21
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Offline**: Hive for all local data
- **State Management**: BLoC/Cubit pattern exclusively
- **Architecture**: Clean Architecture (data/domain/presentation layers)
- **Target Devices**: Low-to-mid end Android (optimize for 2GB RAM)
- **Theme**: Dark mode only ("Royal Obsidian" design system)

## Success Criteria
- [ ] All 10 feature modules fully functional (Auth, Dashboard, Billing, Inventory, Sales, Expenses, Customers, Analytics, AI, Settings)
- [ ] Customer Udhar module complete with WhatsApp integration
- [ ] Bluetooth thermal printer support for invoices
- [ ] Zero crashes on low-end devices (2GB RAM)
- [ ] Offline mode works for all CRUD operations
- [ ] APK size under 30MB
- [ ] All screens match Royal Obsidian design system
- [ ] Barcode scanner works for both billing and inventory
- [ ] PDF/Excel export for reports
- [ ] Unit test coverage > 60%

## User Stories

### As a Kirana Store Owner
- I want to scan barcodes and create bills instantly
- So that checkout is fast during rush hours

### As a Small Retailer
- I want to track which customers owe me money (Udhar)
- So that I can send WhatsApp reminders and recover payments

### As a Shop Manager
- I want to see AI-powered insights on my dashboard
- So that I know which products to restock before they run out

### As a Business Owner
- I want to view profit reports with charts
- So that I can make informed decisions about pricing and inventory

## Technical Requirements

| Requirement | Priority | Notes |
|-------------|----------|-------|
| Customer Udhar CRUD + Ledger | Must-have | Full clean architecture implementation |
| Bluetooth invoice printing | Must-have | ESC/POS thermal printer support |
| WhatsApp credit reminders | Must-have | Deep link to WhatsApp with pre-filled message |
| Dashboard state management | Must-have | Dedicated DashboardCubit with real-time refresh |
| GST/Tax calculation in billing | Must-have | Configurable tax rates per product |
| PDF invoice generation | Should-have | Share via WhatsApp/email |
| Analytics Bloc + date filters | Should-have | Proper state management for reports |
| Barcode-to-product lookup | Should-have | Scan barcode → auto-fill product in billing |
| Export to Excel/PDF | Should-have | Sales, expenses, inventory reports |
| Multi-language (Hindi) | Nice-to-have | Flutter localization framework |
| Real ML insights | Nice-to-have | Replace rule-based AI with on-device ML |

---

*Last updated: 2026-03-29*
