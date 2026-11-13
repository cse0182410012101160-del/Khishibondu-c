# Agro-Bridge (কৃষিবন্ধু)
### *A Farmer-to-Buyer Marketplace with Embedded Microfinance for Bangladesh*
*(University Final Year Project)*

---

## 🌾 Project Overview

**Agro-Bridge** is an enterprise-grade, cross-platform mobile marketplace and financial rails application specifically engineered for Bangladesh's agricultural ecosystem. It directly connects rural farmers with institutional and retail buyers, introduces escrow-protected transactions over Bangladeshi MFS rails (bKash, Nagad, Rocket), dynamically scores farmer creditworthiness from transparent marketplace transactions instead of physical collateral, and enables NGOs/MFIs (such as BRAC and Grameen Bank) to disburse pre-approved harvest microloans.

---

## 🏛️ Architecture & System Design

### 1. Flutter Frontend: Strict Feature-First Clean Architecture

```
frontend/lib/
├── main.dart                          # Application entry point & multi-bloc provider
├── core/                              # Shared cross-cutting concerns
│   ├── constants/                     # API endpoints & Bangladesh agricultural constants
│   ├── di/injection.dart              # Dependency Injection via GetIt (`sl`)
│   ├── geo/location_service.dart      # GPS discovery & division bounding-box geofencing
│   ├── localization/                  # Full Bangla-first UI toggle support (AppLocalizations)
│   ├── network/api_client.dart        # Dio networking with token interceptors
│   ├── plugins/plugin_registry.dart   # Extensible Plugin & Feature-Flag Registry
│   ├── storage/cache_service.dart     # Offline-first caching for rural connectivity
│   └── theme/app_theme.dart           # Agriculture green & golden harvest palette
├── features/                          # Isolated feature modules
│   ├── auth/                          # Phone OTP verification & 4-role switcher
│   ├── marketplace/                   # Crop listings, harvest lots & bulk-lot bidding
│   ├── orders/                        # 5-stage order state machine
│   ├── escrow/                        # MFS payment rails, escrow lock/release & disputes
│   ├── microfinance/                  # Automated credit scoring & EMI simulator
│   ├── traceability/                  # Farm-to-fork batch QR code provenance
│   ├── weather/                       # GPS weather, cyclone alerts & irrigation advice
│   ├── analytics/                     # Farmer revenue & Admin moderation dashboards
│   ├── chat/                          # Buyer-Farmer direct negotiation chat
│   └── plugins/                       # Dynamic drop-in plugins (AI Disease, Yield Predictor)
└── navigation/main_navigation_shell.dart # Role-based bottom navigation bar
```

Each feature follows a strict 3-tier Clean Architecture separation:
- **`domain/`**: Pure business logic (Entities, abstract Repository interfaces, value objects).
- **`data/`**: Data sources (Dio remote API client, local cache), DTO models (`fromJson`/`toJson`).
- **`presentation/`**: `flutter_bloc` (Events, States, BLoC) and UI screens/widgets.

### 2. Backend: Node.js & Express Modular REST API

- **Base Route**: `/api/v1/...`
- **Data Store**: Zero-external-dependency in-memory persistent singleton pre-seeded with realistic Bangladeshi agricultural datasets.
- **Security**: JWT authentication + Role-Based Access Control (RBAC) middleware (`farmer`, `buyer`, `ngo`, `admin`).
- **Integration Tests**: 12/12 automated integration tests verifying the complete end-to-end user journeys.

---

## 🚀 Quick Start Guide

The free hosting choices and four-week delivery order are documented in [docs/FREE_STACK_PLAN.md](docs/FREE_STACK_PLAN.md).

### Prerequisites
- Flutter SDK (v3.13+ / Dart 3+)
- Node.js (v18+ or v20+)

### 1. Run the Backend API
```bash
cd backend
npm install
npm start
# Server starts at http://localhost:5000
```

To run the automated backend test suite:
```bash
npm test
```

### 2. Run the Flutter Frontend
```bash
cd frontend
flutter pub get
flutter analyze     # 0 errors, 0 warnings
flutter test        # All tests pass
flutter run
```

> **Android Emulator Note:** When running on Android emulator, network requests to `localhost:5000` automatically route via `http://10.0.2.2:5000`.

---

## 🔑 Demo Accounts & Pre-Seeded Profiles

Instant one-tap login buttons are provided on the login screen for testing all 4 roles:

| Role | Name | Phone / ID | Special Capabilities |
| :--- | :--- | :--- | :--- |
| **Farmer** | Md. Rafiqul Islam | `+8801712345678` | List harvest lots, review bids, track credit score, view escrow payouts |
| **Buyer** | Green Agro Wholesale Ltd. | `+8801812345678` | Place bulk-lot bids, fund escrow via bKash/Nagad, confirm delivery, raise disputes |
| **Microfinance (NGO)** | BRAC Microfinance Hub | `+8801912345678` | Review loan applications, inspect dynamic marketplace credit scores, disburse funds |
| **Admin** | Agro-Bridge Operations | `+8801512345678` | Moderate platform, manage escrow disputes, toggle feature-flags and plugins |

---

## 🔄 State Management & Order Flow

### 1. Order State Machine
```
Listed ──► Negotiating (Bulk Bidding) ──► Confirmed (Escrow Locked) ──► Delivered ──► Paid (Escrow Released)
                                                      │
                                                      └──► Disputed (Admin Arbitrated)
```

1. **Listing**: Farmer publishes harvest lot (e.g., 250 Maund Bogura Diamond Potatoes).
2. **Bidding**: Buyer offers unit price and requested quantity via `bidding_dialog.dart`.
3. **Escrow Lock**: Farmer accepts bid. Buyer's funds are locked into escrow via bKash/Nagad rail.
4. **Delivery**: Farmer ships goods. Buyer inspects batch and clicks **Confirm Delivery**.
5. **Payout**: Escrow instantly disburses funds to farmer's registered MFS wallet.

### 2. Credit Scoring Engine (`creditEngine.js`)
Calculates a credit score ($300 - 850$) from verified on-platform marketplace activity:
- **Sales Volume Weight (35%)**: Total gross sales in BDT.
- **Fulfillment Consistency (30%)**: Percentage of orders delivered without disputes.
- **Buyer Reviews & Ratings (20%)**: Star ratings from verified buyers.
- **Transaction Frequency (15%)**: Active sales months over the past year.

---

## 🧩 How to Drop in New Plugins / Feature Flags

Both frontend and backend are equipped with an extensible Plugin Registry.

### Adding a New Flutter Plugin (e.g., `GovernmentSubsidyPlugin`):

1. Create a new file in `lib/features/plugins/subsidy_plugin.dart` implementing `FeaturePlugin`:
```dart
import 'package:flutter/material.dart';
import 'package:agro_bridge/core/plugins/plugin_registry.dart';

class GovernmentSubsidyPlugin extends FeaturePlugin {
  @override
  String get id => 'govt_subsidy_directory';
  @override
  String get title => 'Government Fertilizer Subsidy';
  @override
  String get titleBn => 'সরকারি সার ও বীজ প্রণোদনা';
  @override
  String get description => 'Official DAE directory of seasonal agricultural subsidies.';
  @override
  String get version => '1.0.0';
  @override
  IconData get icon => Icons.account_balance;
  @override
  List<String> get enabledRoles => ['farmer', 'admin'];

  @override
  Widget buildScreen(BuildContext context) => const SubsidyDirectoryScreen();
}
```

2. Register it in `lib/core/di/injection.dart`:
```dart
pluginRegistry.register(GovernmentSubsidyPlugin(), defaultActive: true);
```
No core screens or navigation shells require any modifications! The plugin automatically surfaces in the dynamic plugin catalog and role dashboards.

