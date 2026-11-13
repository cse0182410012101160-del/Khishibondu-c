# Agro-Bridge Feature Status

Last audited: 2026-11-10

Status values: Real means backed by the current API flow; Mocked means the flow exists but uses simulated or in-memory behavior; UI-only means a screen or shell exists without a complete backend workflow.

| Area | Status | Evidence / next step |
|---|---|---|
| Phone login | Mocked | `/auth/demo-login` issues demo JWTs; real SMS OTP is not wired. |
| Bangla and English UI | Real | Locale toggle and localizations are wired in Flutter. |
| Crop listing | Mocked | Marketplace API reads the in-memory store; migrate repository to PostgreSQL. |
| Crop detail and bidding | Mocked | Listing, bid, and accept-bid flows exist; persistence is in memory. |
| Harvest submission | Mocked | Farmer listing screen exists; persistence is in memory. |
| Order tracker | Mocked | Order state flow exists; persistence is in memory. |
| Escrow vault | Mocked | Escrow lock/release is simulated; provider boundary and idempotency are implemented, while real money movement remains. |
| Credit score | Mocked | Explainable calculation exists, but events are not persisted as audit records. |
| Loan application and EMI | Mocked | Demo loan and EMI flows exist; no production persistence or disbursement. |
| Weather advisory | Mocked | API and Flutter screen exist; provider integration is not confirmed. |
| QR traceability | Real | QR provenance endpoint and Flutter views are implemented. |
| Negotiation chat | Mocked | Demo chat flow exists; durable message storage and sockets are not confirmed. |
| Admin analytics | Mocked | Dashboard and analytics endpoint exist over demo data. |
| bKash/Nagad sandbox payments | Mocked | Provider boundary, sandbox references, and idempotency are available; real credentials and signed webhooks remain. |
| AI Bangla assistant | Mocked | Server-side `/ai/assist` contract is available with advisory-only sandbox output. |
| AI crop photo verification | Mocked | Server-side `/ai/crop-quality` returns grade, reasons, and confidence; vision model and upload storage remain. |
| Buyer procurement portal | Mocked | `/procurement` provides bulk lot search, suppliers, and buyer order history; saved suppliers UI remains. |
| NGO analytics suite | Mocked | `/analytics/ngo` provides score distribution, collection/default rates, and district risk over demo records. |
| BNPL input shop | Mocked | Input catalog and farmer BNPL application flow are available through `/future/input-shop`. |
| IoT soil sensors | Mocked | Sensor telemetry and field recommendation view are available through `/future/sensors`. |
| International export matchmaking | Mocked | Export demand matches and farmer inquiry flow are available through `/future/export-matches`. |
| Ten unspecified enhancements | Undefined | The source specification names these only as "10 enhancements"; requirements are needed before implementation. |

## Infrastructure audit

- Backend: Node.js and Express, JavaScript.
- Persistence today: in-memory singleton at `backend/src/database/store.js`.
- PostgreSQL: foundation schema added; API migration remains pending.
- Redis, MongoDB, Socket.io, BullMQ: not wired or verified in the current repository.
- Automated backend checks: `cd backend && npm test`.
- Flutter checks: `cd frontend && flutter analyze && flutter test`.
