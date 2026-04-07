# Contributing to ShopKeeper

First off, thank you for considering contributing to **ShopKeeper**! 🎉

Every contribution matters — whether it's fixing a typo, reporting a bug, or building a whole new feature.

---

## 🚀 How to Contribute

### 1. Fork & Clone

```bash
git clone https://github.com/<your-username>/ShopKeeper.git
cd ShopKeeper/Shop_Keeper_Project
flutter pub get
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes

- Write clean, readable Dart code
- Follow the existing project architecture (Clean Architecture + BLoC)
- Add comments where logic is non-obvious

### 4. Test

```bash
flutter analyze
flutter test
```

### 5. Commit & Push

```bash
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name
```

### 6. Open a Pull Request

Go to the [Pull Requests](https://github.com/GodlLuffy/ShopKeeper/pulls) tab and create a new PR.

---

## 📐 Code Guidelines

| Rule | Details |
|---|---|
| **Language** | Dart (null-safe) |
| **Architecture** | Clean Architecture (data → domain → presentation) |
| **State Management** | BLoC / Cubit only |
| **Formatting** | Run `dart format .` before committing |
| **Naming** | Use `snake_case` for files, `camelCase` for variables |
| **Commits** | Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, etc.) |

---

## 🐛 Reporting Bugs

Use the [Bug Report template](https://github.com/GodlLuffy/ShopKeeper/issues/new?template=bug_report.md) and include:
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if UI-related)
- Device / OS info

---

## 💡 Suggesting Features

Use the [Feature Request template](https://github.com/GodlLuffy/ShopKeeper/issues/new?template=feature_request.md).

---

## 🙏 Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before participating.

---

Thank you for helping make ShopKeeper better! 🛒✨
