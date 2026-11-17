# AYODEX Mobile 📱

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Live Demo](https://img.shields.io/badge/Live%20Preview-GitHub%20Pages-28C76F?style=flat&logo=github)](https://piyush274.github.io/ayodex-mobile/)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-orange.svg)](#)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)](#)

> Fast, secure, and intuitive cross-platform mobile application for multi-currency fiat & crypto exchange, digital wallet management, and instant bank payouts across West Africa (primary markets in **Benin 🇧🇯** and **Nigeria 🇳🇬**).

🔗 **Live Web Preview**: [https://piyush274.github.io/ayodex-mobile/](https://piyush274.github.io/ayodex-mobile/)


---

## 🌟 Key Features

- **💱 Multi-Currency Fiat & Crypto Exchange**
  - Real-time exchange rate calculations and transparent fee structures.
  - Support for multiple fiat and cryptocurrency pairs.
  - Manual and automated gateway payment confirmations with file upload proofs.

- **⚡ Instant Payouts & Bank Transfers**
  - Seamless local bank transfers and OPay wallet payouts.
  - Real-time bank account name resolution before transfer confirmation.
  - Guaranteed fee quotes with expiration timers and idempotency protections.

- **🔐 Bank-Grade Security**
  - Two-Factor Authentication (Google Authenticator 2FA).
  - Secure transaction PIN protection with brute-force lockouts.
  - Multi-tier dynamic KYC verification process.
  - Credential & token storage backed by device secure storage (`EncryptedSharedPreferences` / iOS Keychain).

- **💼 Digital Wallet & Transaction History**
  - Live balances, quick actions, and exchange tracking.
  - Paginated transaction ledger with filters for deposits, withdrawals, and transfers.
  - Downloadable receipts and tracking by exchange ID.

- **🌍 Bilingual & Localized**
  - Built-in multi-language toggle supporting **French (`fr`)** and **English (`en`)**.
  - Localized mobile number dial codes and national identity forms.

- **🎫 In-App Customer Support**
  - Integrated support ticket system with conversation history and attachment uploads.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- **State Management**: [Riverpod](https://riverpod.dev) for safe, decoupled, and testable state management.
- **Networking**: [Dio](https://pub.dev/packages/dio) with custom interceptors for Bearer auth, idempotent headers, and business error remarks.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for declarative routing and guarded redirection (auth, KYC status, profile completion).
- **Secure Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) for sensitive access tokens and credentials.
- **Precise Math**: [decimal](https://pub.dev/packages/decimal) for fixed-precision financial calculation.

---

## 📁 Project Structure

```
lib/
├── app.dart                   # Root MaterialApp configuration & theme
├── main.dart                  # Application entry point
├── core/
│   ├── constants/             # API endpoints, colors, layout dimensions
│   ├── errors/                # Failure & exception definitions
│   ├── network/               # Dio HTTP client, interceptors & API envelopes
│   ├── services/              # Secure storage, preferences & push notifications
│   ├── theme/                 # Design tokens & Material 3 theme configurations
│   ├── utils/                 # Formatters, validators & decimal math helpers
│   └── widgets/               # Reusable atomic UI components & dynamic form builder
├── features/
│   ├── app_startup/           # Splash & initialization
│   ├── auth/                  # Login, registration, 2FA & password recovery
│   ├── dashboard/             # Wallet balances, quick actions & overview
│   ├── exchange/              # Currency conversion, previews & tracking
│   ├── kyc/                   # Dynamic KYC verification forms
│   ├── pin/                   # Transaction PIN setup & verification
│   ├── profile/               # User account settings & security
│   ├── support/               # Help tickets & inquiries
│   ├── transfers/             # Local bank & OPay transfers
│   └── withdraw/              # Multi-method withdrawal requests
└── routes/
    ├── app_router.dart        # Route declarations
    └── route_guards.dart      # Authentication & verification guards
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.14.0 or newer)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode for emulators and physical device debugging.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Piyush274/ayodex-mobile.git
   cd ayodex-mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if applicable):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Run automated unit and widget tests:
```bash
flutter test
```

---

## 📄 License

Proprietary. All rights reserved by **AYODEX**.
