# ShopKeeper Retail OS: Master Build Specification

This document serves as the **Master Build Prompt** for the entire "ShopKeeper Retail OS" project. Use this prompt to initialize, recreate, or expand the application while maintaining perfect architectural and visual consistency.

---

## 🚀 1. Project Identity & Vision
**Product**: ShopKeeper Retail OS
**Core Value**: A premium, "God-Level" Retail ERP for small to medium businesses that combines POS (Point of Sale), Inventory management, and Customer Credit tracking into a secure, offline-first, bilingual powerhouse.

## 🎨 2. Design System: "Royal Obsidian"
The app MUST strictly follow these visual rules:
- **Theme**: High-contrast Dark Mode only. No generic colors.
- **Palette**: 
  - `BackgroundMain`: Dark Obsidian (#0E0F14).
  - `BackgroundLayer`: Deep Charcoal (#17181F).
  - `PrimaryIndigo`: Electric Indigo (#5D5FEF).
  - `AccentTeal`: Cosmic Teal (#00E5FF).
  - `SuccessEmerald`: (#00C853).
  - `DangerRose`: (#FF1744).
- **Core Widgets**:
  - `GlassCard`: Glassmorphic effect with 0.05 opacity white background, 24px border radius, and subtle 1px border.
  - `PremiumLoader`: Geometric indigo/teal progress indicators with sweep animations.
  - `AppErrorHandler`: Standardized snackbars with glassmorphism and icons.
  - **Typography**: Inter / Outfit for high-end readability. All headers in UPPERCASE with 1.5-2px letter spacing.

## 🛠️ 3. Core Technical Architecture
- **Language**: Dart (Flutter)
- **State Management**: `flutter_bloc` (Cubit for simple state, Bloc for complex event streams).
- **Local Database**: `hive` (Box-based storage for Sales, Products, Customers, and Expenses).
- **Localization**: Centralized `AppStrings` map with English and Hindi (Mandatory bilingual support).
- **Routing**: `go_router` for deep linking and navigation.
- **Dependency Injection**: `get_it` (SL - Service Locator).

---

## 📦 4. Mandatory Module Specifications

### 🛒 A. POS Billing & QR Terminal
- **Scanner**: Integrated `mobile_scanner` for rapid Barcode/QR input.
- **Cart Logic**: Real-time quantity adjustments, live subtotal, GST calculation, and flexible discounts (Flat or %).
- **Invoicing**: PDF generation via `invoice_pdf_renderer.dart`. Share via WhatsApp/Email or direct thermal printing.
- **Udhar Mapping**: Seamless integration with Customer Ledger to record partial payments or credit sales.

### 🍱 B. Smart Inventory Hub
- **Entities**: Id, Name, Category, Buy Price, Sell Price, Stock Quantity, Alert Level, Barcode, Image.
- **Alert System**: "Stock Alerts" panel for items reaching `minStockAlert` levels.
- **Controls**: Batch stock updates, barcode generation, and image cropping service.

### 💰 C. Customer Ledger (Udhar)
- **Functions**: Track pending balances, record payments (Settlement), and log historical transactions.
- **Bilingual Status**: Labels like `UDHAR` (Credit) vs `SETTLED` (Paid).

### 📊 D. Intelligence & Analytics
- **Dashboard**: Professional "Financial Hub" showing Today's Revenue, MoM Growth, and Profit/Loss.
- **AI Assistant**: Natural language querying for "What was my total profit last week?" or "Find products with zero stock."
- **Visuals**: `fl_chart` integration with custom dark-themed gradients.

### 🔐 E. Security & Terminal Context
- **Terminal ID**: Unique identifier for the current installation.
- **Security PIN**: 4-digit PIN for session locking.
- **Visual Themes**: Dynamic Dark/Light mode toggle with persistence via `SettingsCubit`.
- **Control Center**: Settings for Language, Theme, and GST/Tax configuration.

---

## 🌍 5. Global Localization Pattern
All UI strings MUST use the `AppStrings.get('key')` pattern.
- **English**: Master key map.
- **Hindi**: High-fidelity Indian localized strings for local businesses.
- **Bilingual Invoices**: PDF invoices generated with localized headers.

## 📈 6. Module Refinements
- **Sales History**: Advanced filtering by name/date and real-time search indexing.
- **Billing Terminal**: Optimized barcode scanning with first-match auto-add and stock validation.

## 🏗️ 7. Implementation Checklist (The "God Level" Standard)
- [ ] **Aesthetics**: Every screen must have a visual "WOW" factor. No standard Material cards.
- [ ] **Animations**: Sublte `fadeIn` and `slide` animations via `flutter_animate` for all screen transitions.
- [ ] **Empty States**: Custom `EmptyStateWidget` for list views with zero results.
- [ ] **Resilience**: Global async error handling and persistent local auto-sync.

---

**Mission Directive**: Build for the shopkeeper who values security, speed, and premium aesthetics. The app should feel more like a futuristic terminal than a simple database.
