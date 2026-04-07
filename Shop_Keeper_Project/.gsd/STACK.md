# Technology Stack

> Auto-generated on 2026-03-29

## Runtime

| Technology | Version | Purpose |
|------------|---------|---------|
| Dart | ^3.5.4 | Primary language |
| Flutter | Latest stable | Cross-platform UI framework |
| Firebase | Various | Backend-as-a-Service |
| Hive | 2.2.3 | Local NoSQL database |

## Core Technologies

### State Management
| Feature | System | Purpose |
|---------|--------|---------|
| Auth | `AuthCubit` | Authentication flow |
| Inventory | `InventoryCubit` | Product CRUD + stock |
| Sales | `SalesCubit` | Sale recording + history |
| Expenses | `ExpensesCubit` | Expense tracking |
| AI Assistant | `AIAssistantCubit` | Insight generation |
| Billing/POS | `BillingBloc` | Cart + checkout flow |
| Dashboard | ❌ MISSING | Needs `DashboardCubit` |
| Customers | ❌ MISSING | Needs `CustomerCubit` |
| Analytics | ❌ MISSING | Needs `AnalyticsCubit` |

### Feature Modules
| Directory | Files | Purpose |
|-----------|-------|---------|
| `features/auth/` | ~15 | Authentication, PIN, biometric |
| `features/dashboard/` | ~2 | Main hub screen |
| `features/billing/` | ~8 | POS checkout system |
| `features/inventory/` | ~12 | Product management |
| `features/sales/` | ~8 | Sales recording |
| `features/expenses/` | ~8 | Expense tracking |
| `features/customers/` | ~2 | ⚠️ Entity only, no screens |
| `features/analytics/` | ~3 | Reports & charts |
| `features/ai_assistant/` | ~3 | AI business insights |
| `features/settings/` | ~5 | User preferences |

## Dependencies

### External Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.10.1 | Firebase initialization |
| `cloud_firestore` | ^5.6.2 | Cloud database |
| `firebase_auth` | ^5.4.4 | Authentication |
| `firebase_storage` | ^12.4.10 | Image storage |
| `flutter_bloc` | ^9.1.0 | State management |
| `equatable` | ^2.0.7 | Value equality |
| `get_it` | ^8.0.3 | Dependency injection |
| `dartz` | ^0.10.1 | Functional programming (Either) |
| `go_router` | ^14.7.2 | Declarative routing |
| `hive` | ^2.2.3 | Local NoSQL storage |
| `hive_flutter` | ^1.1.0 | Hive Flutter bindings |
| `fl_chart` | 0.69.2 | Charts & graphs |
| `flutter_animate` | ^4.5.2 | Micro-animations |
| `google_fonts` | ^6.2.1 | Typography (Inter, Outfit) |
| `intl` | ^0.19.0 | Date/number formatting |
| `mobile_scanner` | ^6.0.11 | Barcode/QR scanning |
| `image_picker` | ^1.1.2 | Camera/gallery access |
| `flutter_image_compress` | ^2.3.0 | Image optimization |
| `share_plus` | ^10.1.0 | Share invoices |
| `local_auth` | ^2.3.0 | Biometric auth |
| `flutter_secure_storage` | ^10.0.0 | Secure key storage |
| `connectivity_plus` | ^6.1.3 | Network status |
| `permission_handler` | ^11.0.1 | Runtime permissions |

### Missing Dependencies (Need to Add)

| Package | Purpose | Phase |
|---------|---------|-------|
| `bluetooth_print` or `esc_pos_bluetooth` | Thermal printer | Phase 2 |
| `pdf` | PDF invoice generation | Phase 3 |
| `excel` or `csv` | Report export | Phase 3 |
| `url_launcher` | WhatsApp deep links | Phase 2 |
| `flutter_localizations` | Multi-language | Phase 5 |

## Infrastructure

| Service | Provider | Purpose |
|---------|----------|---------|
| Authentication | Firebase Auth | Phone OTP + Email login |
| Database | Cloud Firestore | Cloud data sync |
| File Storage | Firebase Storage | Product images |
| Local DB | Hive | Offline-first persistence |
| Security | flutter_secure_storage | PIN/key storage |

## Configuration

| Variable | Purpose | Location |
|----------|---------|----------|
| Firebase config | Project credentials | `google-services.json` |
| Firestore rules | Security rules | `firestore.rules` |
| Firestore indexes | Query optimization | `firestore.indexes.json` |
| App theme | Royal Obsidian design | `core/theme/app_theme.dart` |
| DI container | Service registration | `injection_container.dart` |

## File Size Inventory

| Category | Count | Approx Size |
|----------|-------|-------------|
| Feature screens | ~30 | ~200KB |
| Core widgets | 8 | ~24KB |
| Services | 7 | ~13KB |
| Bloc/Cubit | ~12 | ~30KB |
| Data/Domain | ~20 | ~40KB |
| Config/Route | ~5 | ~20KB |
| **Total** | **~82** | **~327KB** |

---

*Last updated: 2026-03-29*
