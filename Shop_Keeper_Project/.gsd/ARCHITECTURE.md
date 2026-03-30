# Architecture

> Auto-generated on 2026-03-29

## Overview

ShopKeeper PRO is a Flutter mobile application following **Clean Architecture** with BLoC/Cubit state management. It uses an offline-first approach with Hive for local storage and Firebase Firestore for cloud sync.

```
┌───────────────────────────────────────────────────────────────┐
│                       FLUTTER UI                              │
│  Screens (Glassmorphic Dark Theme) + Core Widgets             │
└────────────────────────┬──────────────────────────────────────┘
                         │ BLoC/Cubit Events & States
                         ▼
┌───────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                          │
│  AuthCubit │ InventoryCubit │ SalesCubit │ BillingBloc │ ...  │
└────────────────────────┬──────────────────────────────────────┘
                         │ Use Cases (Either<Failure, Success>)
                         ▼
┌───────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                             │
│  Entities │ Repositories (abstract) │ Use Cases               │
└────────────────────────┬──────────────────────────────────────┘
                         │ Repository Implementation
                         ▼
┌───────────────────────────────────────────────────────────────┐
│                       DATA LAYER                              │
│  Models │ Data Sources │ Repository Implementations           │
└────────┬──────────────────────────────────┬───────────────────┘
         │                                  │
         ▼                                  ▼
┌─────────────────────┐       ┌─────────────────────────┐
│     HIVE (Local)    │       │   FIREBASE (Cloud)      │
│  Offline-first DB   │       │  Firestore + Storage    │
└─────────────────────┘       └─────────────────────────┘
```

## Components

### Core (`lib/core/`)
- **Purpose:** Shared infrastructure — theme, widgets, routing, constants, error handling
- **Location:** `lib/core/`
- **Pattern:** Utility/shared layer

| Directory | Purpose | Priority |
|-----------|---------|----------|
| `theme/` | Royal Obsidian dark theme (`AppTheme`) | High |
| `widgets/` | 8 reusable components (GlassCard, GradientButton, etc.) | High |
| `routing/` | GoRouter declarative navigation (`AppRouter`) | High |
| `constants/` | App-wide constants | Medium |
| `error/` | Failure classes for Either pattern | Medium |
| `usecases/` | Base use case abstraction | Medium |

### Auth (`lib/features/auth/`)
- **Purpose:** Full authentication: phone OTP, email, PIN lock, biometric
- **Location:** `lib/features/auth/`
- **Pattern:** Clean Architecture (data → domain → presentation)
- **State:** `AuthCubit`
- **Screens:** 7 (splash, login, OTP, register, onboarding, PIN setup, PIN lock)

### Dashboard (`lib/features/dashboard/`)
- **Purpose:** Central hub — financial summary, quick actions, AI insights
- **Location:** `lib/features/dashboard/`
- **Pattern:** ⚠️ Presentation only (no data/domain layers)
- **State:** ❌ No dedicated Cubit (pulls from other cubits)
- **Screens:** 1 (dashboard_screen.dart — 18KB, heavy file)

### Billing/POS (`lib/features/billing/`)
- **Purpose:** Point-of-sale checkout — cart, scanning, invoicing
- **Location:** `lib/features/billing/`
- **Pattern:** BLoC + Model + Screen + Widgets
- **State:** `BillingBloc` (events/states)
- **Screens:** 1 screen + 4 widgets (cart, invoice dialog, product sheet, total box)

### Inventory (`lib/features/inventory/`)
- **Purpose:** Product CRUD, stock management, barcode scanning
- **Location:** `lib/features/inventory/`
- **Pattern:** Clean Architecture (data → domain → presentation)
- **State:** `InventoryCubit`
- **Screens:** 6 (product list, add, edit, detail, low stock, history)

### Sales (`lib/features/sales/`)
- **Purpose:** Sale recording, history tracking
- **Location:** `lib/features/sales/`
- **Pattern:** Clean Architecture (data → domain → presentation)
- **State:** `SalesCubit`
- **Screens:** 2 (add sale, sales history)

### Expenses (`lib/features/expenses/`)
- **Purpose:** Expense tracking and categorization
- **Location:** `lib/features/expenses/`
- **Pattern:** Clean Architecture (data → domain → presentation)
- **State:** `ExpensesCubit`
- **Screens:** 2 (add expense, expense list)

### Customers / Udhar (`lib/features/customers/`)
- **Purpose:** Customer credit tracking, ledger, WhatsApp reminders
- **Location:** `lib/features/customers/`
- **Pattern:** ⚠️ Entity model only — NO data/presentation layers
- **State:** ❌ No Cubit
- **Screens:** ❌ None
- **Critical Gap:** HIGH PRIORITY in design spec, least developed module

### Analytics (`lib/features/analytics/`)
- **Purpose:** Charts, profit reports, business intelligence
- **Location:** `lib/features/analytics/`
- **Pattern:** Presentation only (no data/domain)
- **State:** ❌ No dedicated Cubit
- **Screens:** 2 (analytics, profit report)

### AI Assistant (`lib/features/ai_assistant/`)
- **Purpose:** AI-powered business insights and recommendations
- **Location:** `lib/features/ai_assistant/`
- **Pattern:** Presentation + Cubit (service layer in `lib/services/`)
- **State:** `AIAssistantCubit`
- **Screens:** 1 (ai_assistant_screen.dart)

### Settings (`lib/features/settings/`)
- **Purpose:** User profile, preferences, backup/restore
- **Location:** `lib/features/settings/`
- **Pattern:** Presentation only
- **State:** ❌ No dedicated Cubit
- **Screens:** 5 (settings, profile, edit profile, about, backup/restore)

### Services (`lib/services/`)
- **Purpose:** Cross-cutting services not tied to specific features
- **Files:** 7 services

| Service | Purpose |
|---------|---------|
| `ai_assistant_service.dart` | Rule-based insight generation |
| `biometric_auth_service.dart` | Fingerprint/face unlock |
| `local_image_service.dart` | Image caching & compression |
| `pin_service.dart` | PIN storage & validation |
| `report_service.dart` | Report data aggregation |
| `security_service.dart` | Encryption & secure storage |
| `sync_service.dart` | Hive ↔ Firestore sync engine |

## Data Flow

1. **User initiates action** (e.g., scans barcode in billing screen)
2. **Presentation Layer** dispatches event to BLoC/Cubit
3. **Domain Layer** executes use case via repository contract
4. **Data Layer** writes to Hive (local) first, then syncs to Firestore
5. **State emitted** back to UI via BlocBuilder/BlocListener
6. **SyncService** handles background Hive → Firestore reconciliation

## Technical Debt

- [ ] Dashboard has no dedicated Cubit — pulls state from other cubits directly
- [ ] Customers module is entity-only — needs full clean architecture build
- [ ] Analytics has no data/domain layers — computes in presentation
- [ ] Settings has no Cubit — uses direct service calls
- [ ] `dashboard_screen.dart` is 18KB — needs decomposition into widgets
- [ ] No unit tests exist
- [ ] Some screens may still have legacy light theme artifacts

## Conventions

**Naming:**
- Feature directories: `snake_case` (e.g., `ai_assistant`)
- Screen files: `*_screen.dart`
- Cubit files: `*_cubit.dart`, `*_state.dart`
- BLoC files: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- Entity files: `*_entity.dart`

**Structure:**
- Each feature follows `data/` → `domain/` → `presentation/` when fully implemented
- Presentation contains `bloc/` (or `cubit/`), `screens/`, and optionally `widgets/`
- Domain contains `entities/`, `repositories/` (abstract), `usecases/`
- Data contains `models/`, `datasources/`, `repositories/` (implementation)

---

*Last updated: 2026-03-29*
