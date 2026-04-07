You are a **Senior Flutter + Firebase Staff Engineer** working on my production app **ShopKeeper**.

Your mission is to perform a **deep full-project audit and upgrade**.

Project Repo:
https://github.com/GodlLuffy/ShopKeeper

---

# 🎯 PRIMARY OBJECTIVE

Transform this project into a **production-ready premium inventory + billing + analytics app** with **perfect Firebase architecture, secure authentication, and flawless database sync**.

You must work like a **10+ years senior mobile architect**.

---

# 🔍 STEP 1 — FULL PROJECT INSPECTION

First deeply inspect:

* all pages
* all routes
* all widgets
* all providers / bloc / riverpod / state logic
* Firebase setup
* Firestore collections
* Hive local database
* auth flow
* login flow
* PIN security
* invoice flow
* stock update flow
* charts and analytics
* product CRUD
* sales history
* customer debt tracking
* billing print logic
* app startup flow
* splash screen
* navigation structure
* reusable components
* error handling
* API integrations
* offline sync
* cloud sync conflicts

Find:

* dead code
* broken database calls
* half-connected UI
* missing awaits
* wrong async state updates
* null safety issues
* Firestore read/write bugs
* duplicated logic
* page performance issues
* unoptimized rebuilds
* bad folder structure

---

# 🏗️ STEP 2 — REBUILD TO SENIOR ARCHITECTURE

Refactor into this structure:

lib/
core/
constants/
theme/
services/
utils/
models/
repositories/
features/
auth/
inventory/
billing/
analytics/
customers/
settings/
widgets/

Use:

* feature-first architecture
* repository pattern
* service layer
* Firebase abstraction
* clean separation of UI/business/data
* reusable widgets
* scalable routing

---

# 🔥 STEP 3 — FIREBASE AUTH SYSTEM

Implement full auth module:

## Required

* Email + Password Sign Up
* Login
* Logout
* Verify Email
* Forgot Password
* Reset Password
* Session persistence
* Auth state listener
* Secure route guard
* Auto redirect if email not verified
* Resend verification email
* nice loading + error UI

### Flow Rules

* user cannot access dashboard without verified email
* on signup send verification email automatically
* on login check FirebaseAuth.instance.currentUser.emailVerified
* if false → redirect verify email screen
* if true → dashboard

Build:

* LoginPage
* SignupPage
* VerifyEmailPage
* ForgotPasswordPage
* ResetSuccessPage

---

# ☁️ STEP 4 — FIRESTORE DATABASE PERFECT STRUCTURE

Create professional scalable Firestore schema:

users/{uid}

* name
* email
* createdAt
* shopName
* phone
* role
* subscriptionPlan

shops/{shopId}

* ownerId
* createdAt
* settings

products/{productId}

* name
* barcode
* price
* stock
* costPrice
* category
* updatedAt

sales/{saleId}

* productIds
* totalAmount
* paymentMode
* customerId
* createdAt

customers/{customerId}

* name
* phone
* debt
* updatedAt

analytics/{dayId}

* revenue
* expenses
* profit
* itemsSold

Make all collections strongly typed with Dart models.

---

# 🔄 STEP 5 — FRONTEND ↔ BACKEND VALIDATION

Check every screen and verify:

* is UI connected to correct collection?
* is product stock decrementing after billing?
* are charts reading live sales data?
* are daily reports correct?
* are debts updating customer records?
* is offline Hive syncing back to Firestore?
* are duplicate sales avoided?
* is delete safe?
* are failed writes retried?

Fix all broken connections.

---

# ⚡ STEP 6 — HIVE + FIREBASE HYBRID DATABASE

Implement offline-first sync:

## Local

Hive stores:

* products
* pending sales
* cached analytics
* customer debts

## Cloud

Firestore sync engine:

* push pending local changes
* resolve conflicts using updatedAt
* auto retry failed sync
* background sync on app resume
* sync status badge

---

# 🎨 STEP 7 — PREMIUM UX UPGRADE

Upgrade all auth + dashboard UI to premium fintech level:

Style reference:

* PhonePe
* Razorpay
* CRED
* Notion dark elegance

Requirements:

* glass cards
* smooth charts
* animated KPI counters
* premium PIN lock
* shimmer loading
* success micro animations
* zero ugly dialogs
* snackbar system
* consistent spacing
* reusable buttons
* input validation states

---

# 🧪 STEP 8 — FULL QA CHECK

Run deep code validation:

* no broken imports
* no unused code
* no duplicate widgets
* no context after await issue
* no memory leaks
* no stream leaks
* no unsafe setState
* all firebase exceptions handled
* all Firestore indexes validated
* all forms validated
* all routes protected
* all CRUD tested

---

# 🚀 FINAL OUTPUT FORMAT

Return:

1. Full audit report
2. Found issues list
3. Updated folder structure
4. Firebase auth implementation
5. Firestore schema
6. fixed pages list
7. sync engine logic
8. production-ready code patches
9. migration steps
10. launch checklist
