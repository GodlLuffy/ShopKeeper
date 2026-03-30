# 🎨 UI/UX Designer Master Prompt: Smart Retail OS (Project ShopKeeper PRO)

**Dear Product Designer / UI/UX Expert,**

We are transforming an existing basic stock management app into a **Premium Smart Retail OS** designed for Indian SMBs (small and medium businesses, kirana stores, retailers). It will compete directly with apps like **PhonePe Business**, **Vyapar**, and **Shopify POS**.

Your goal is to design a state-of-the-art Flutter mobile application. The target audience uses low-to-mid end Android devices, but the app must feel like a premium, "God Level" FinTech product.

---

## 💎 1. Visual Language & Aesthetics (The "God Level" Look)

This cannot look like a generic Material application. It must feel rich and expensive.

- **Theme Style**: Glassmorphism, subtle gradient glows, and card-based isolating layouts.
- **Color Palette**:
  - **Backgrounds**: Flat light grey `Color(0xFFF3F4F6)` to make white cards pop.
  - **Primary/Accent**: Deep Indigo/Purple `Color(0xFF5F259F)` or a vibrant FinTech blue.
  - **Success/Profit**: Bright Emerald Green `Color(0xFF10B981)`.
  - **Danger/Loss**: Bold Red `Color(0xFFEF4444)`.
- **Typography**: Modern Sans Serif (Inter, Outfit, or Poppins). Heavy font weights for profit numbers and headers; clean readable weights for data.
- **Micro-Interactions**: We will use `flutter_animate`. Design elements to drop in, fade, and shake on error.

---

## 📱 2. Screen-by-Screen Flow & Requirements

Here is the exact structure of what you need to design, page by page:

### 1. Splash & Auth (The First Impression)
- **Splash Screen**: Animated logo, glowing effects, entering the "Smart OS".
- **Login Screen**: 
  - Toggle between "Phone OTP" and "Email Login".
  - Sleek text fields with shadowless borders.
  - Large premium action button ("GET OTP").
- **PIN Lock Screen**:
  - Secure entry pad (4 dots).
  - Custom flat circular numpad (0-9).
  - Support for biometric/fingerprint unlock button.

### 2. The Dashboard (The "Cinematic" Hub)
This is the heart of the app. It must look like a high-end banking dashboard.
- **Top Bar**: Welcome text + Shop Name + Quick Add Button (+).
- **Financial Summary Cards**:
  - Large toggle for "Today / Week / Month".
  - Huge bold numbers for **Total Revenue** and **Total Profit**.
  - Background of these cards should have a mesh-gradient or subtle pattern.
- **AI Brain / Insights Component**:
  - A card that looks like the app "talking" to the user.
  - Examples: *"⚠️ Sugar stock finishes in 2 days"*, *"📈 Maggi sales are up 30%"*.
- **Quick Actions Row**: 4 circular glass buttons (Add Bill, Add Product, Customers, Reports).

### 3. POS Billing System (Lightning Fast Checkout)
This screen is built for speed (one-handed operation without lag).
- **Scanner Area**: Huge prominent barcode scanner button in the upper half or bottom-floating.
- **Current Cart / Item List**:
  - Clean rows. Name, Qty (+/- buttons), Price.
- **The "Total" Summary Box (Fixed to Bottom)**:
  - Subtotal.
  - Discount slider/input.
  - GST / Tax auto-calculation row.
  - **Final Grand Total** (Massive text).
  - Huge "PAY & PRINT" button. 
- **Invoice Success Popup**: Resembles a physical receipt slipping out of a printer. Options to Print (Bluetooth) or Share (WhatsApp).

### 4. Inventory Management (Product List)
- **List View**: Flat white cards mapping the product.
- **Status Tags**: Beautiful red/tinted chips saying `⚠️ Low Stock`.
- **Swipe-to-Delete**: Rounded red background reveals a bin icon when dragged.
- **Add Product Form**:
  - Golden layout rule. Input fields inside one large white box.
  - Floating image picker container on top.
  - Long floating submit button.

### 5. Customer Udhar (Credit) System [NEW MODULE - HIGH PRIORITY]
This is for Indian store owners to track who owes them money ("Udhar").
- **Customer List**:
  - Name, Phone, and the big red/green number of how much they owe (`- ₹500`).
- **Customer Profile**:
  - Ledger view (Date, Bought items, Paid amounts, Remaining Balance).
  - Two massive action buttons: **"Gave Credit"** & **"Got Payment"**.
- **WhatsApp Integration**:
  - A prominent green WhatsApp button next to unpaid balances that instantly generates a reminder: *"Bhai, aapka ₹500 baki hai."*

---

## 🎨 3. Designer Deliverables Expected
Please provide Figma files containing:
1. **Design System**: Colors, typography, input field states (active/error), and card shadow specifications.
2. **Component Library**: Reusable Buttons, Tags, Bottom Sheets, and App Bars.
3. **High-Fidelity Screens**: For all 5 sections listed above.
4. **Prototyping**: Show the flow from scanning an item to printing the bill, and sending an Udhar reminder on WhatsApp.

*Remember: Emulate PhonePe Business, CRED, and modern SaaS. No cheap Material shadows. Use rich blur effects, flat lines, and stark contrast.*
