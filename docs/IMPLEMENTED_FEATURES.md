# Agro-Bridge Implemented Features

**Project:** Agro-Bridge / Krishibondhu  
**Last reviewed:** 2026-11-14  
**Purpose:** A practical record of what is currently present in the repository.

## Product Summary

Agro-Bridge is a Bangla-first farmer marketplace with crop listings, buyer bidding, order tracking, escrow workflows, traceability, weather/pricing data, AI assistance, microfinance tools, and role-based Flutter dashboards.

## Backend Features

### Authentication and roles

- OTP and demo-login flows with JWT authentication.
- Role authorization middleware for farmer, buyer, NGO, agent, and admin flows.
- Profile registration and current-user lookup.
- Development demo accounts for local testing.

### Marketplace

- Crop-lot listing and filtering.
- Crop detail lookup.
- Buyer bulk bidding.
- Farmer bid acceptance/rejection.
- Accepted bids create orders and escrow records in the sandbox store.
- Procurement view for bulk buyers.

### Orders and escrow

- Order lifecycle handling for listed, negotiating, confirmed, delivered, paid, disputed, and cancelled states.
- Payment provider boundary with MockProvider and bKash sandbox provider support.
- Payment idempotency keys.
- Escrow state machine with invalid-transition rejection.
- Append-only ledger entry creation in the transactional escrow service.
- Dispute creation and admin release/refund resolution.
- Audit-log records for dispute resolution.
- Notification hooks for accepted bids and released payments.

### Finance and credit

- Explainable farmer credit scoring from completed orders, delivery reliability, disputes, repayments, and account age.
- CreditEvent persistence through the Prisma repository path.
- Asynchronous credit-score recomputation job after order completion when PostgreSQL and pg-boss are configured.
- Flat-rate and declining-balance EMI calculation.
- APR, total cost, repayment schedule, and high-APR warning support.
- MFI portfolio endpoint with district applicants, score buckets, and repayment-rate aggregates.

### Traceability, weather, and pricing

- QR batch provenance lookup and QR generation.
- Crop origin, farmer, quality, and laboratory information.
- SprayRecord data with pre-harvest interval warnings.
- Three-day Open-Meteo forecast with district lookup and 30-minute memory cache.
- CSV-backed wholesale and retail pricing.
- Farm-gate price calculation from completed sandbox orders.

### AI and integrations

- Bangla farming assistant endpoint with Gemini support when configured.
- Sandbox fallback when Gemini credentials are absent.
- Per-user daily request limit and repeated-question cache.
- Advisory crop photo grading endpoint with strict grade/reasons/confidence output.
- Firebase device-token registration endpoint.
- Console notifier by default and optional FCM notifier.
- bKash sandbox provider with environment-based configuration and webhook signature verification.

### Agents and group lots

- Agent role and consent-gated farmer profile creation.
- Agents can create crop lots for consented farmers.
- Agent ownership is stored on created lots.
- GroupLot service with member kilogram weights.
- Pure integer-paisa payout splitting.
- Wallet records created for group members on release.

## Flutter Features

### Application foundation

- Feature-first Flutter structure.
- BLoC state management.
- Repository and remote-data-source layers.
- GetIt dependency injection.
- Dio API client with cached JWT authorization.
- Bangla-first English/Bangla localization.
- Role-based navigation shell.
- Shared theme, image, location, cache, and plugin services.

### User-facing screens and flows

- Phone authentication, demo login, and role registration.
- Marketplace crop browsing, search, crop details, listing, and bidding.
- Nearby market map using `flutter_map` and OpenStreetMap tiles with a single location marker.
- Orders list, order detail, delivery confirmation, and dispute flow.
- Escrow wallet and dispute views.
- Credit score, loan application, EMI calculator, and MFI portfolio dashboard.
- QR scanner and batch provenance screen.
- Weather advisory and location detection.
- Buyer procurement portal.
- Bangla AI assistant with `speech_to_text` using `bn_BD` and `flutter_tts` spoken replies.
- Crop quality screen.
- Chat, analytics, plugin catalog, input shop, soil sensors, and export matchmaking screens.

### Offline and push support

- SQLite-backed offline queue for failed listing and bid writes on native targets.
- In-memory queue fallback on Flutter Web, preventing startup failure where sqflite has no browser database factory.
- Connectivity-triggered retry and pending-sync badge.
- Firebase Messaging initialization and authenticated device-token registration.

## Data and Persistence Status

| Area | Current implementation | Production status |
|---|---|---|
| Most marketplace/API sandbox flows | In-memory `DatabaseStore` | Needs PostgreSQL repository migration |
| Prisma schema | PostgreSQL models for users, lots, bids, orders, escrow, credit, loans, traceability, group lots, and wallets | Requires migration and configured `DATABASE_URL` |
| Cache | Flutter local cache and in-memory backend caches | Rebuildable/cache-only behavior expected |
| Queues | pg-boss credit job path | Requires PostgreSQL and worker startup |
| Payments | Mock and bKash sandbox provider boundary | Real credentials/webhooks still required |
| Push notifications | Console default, optional FCM | Firebase service account and device setup required |
| AI | Gemini when configured, sandbox fallback otherwise | Production key/model policy required |

## Verification Commands

Backend:

```bash
cd backend
npm test
```

Frontend:

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
```

Run locally:

```bash
cd backend
npm install
npm start

cd frontend
flutter run
```

## Important Remaining Work

- Complete and approve the Prisma role/catalog migration before changing existing user data.
- Move production-critical marketplace, order, escrow, loan, and audit writes from the in-memory store to PostgreSQL.
- Configure real Firebase, Gemini, payment-provider, Redis, and queue credentials.
- Add production OTP/SMS delivery and refresh-token security.
- Add database migrations, deployment configuration, observability, and end-to-end mobile/device verification.
- Review and remove any demo-only or placeholder data before production use.
