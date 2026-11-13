# Free Stack and Four-Week Delivery Plan

This plan keeps Agro-Bridge runnable without paid infrastructure. Provider quotas and free-tier terms change, so verify them before deployment and keep every provider behind the existing repository or service boundary.

## Free choices by stack layer

| Layer | Free choice | Catch to plan for | Project decision |
|---|---|---|---|
| Flutter web hosting | Cloudflare Pages or GitHub Pages | Static hosting only; backend calls still need HTTPS and CORS configuration. | Host the Flutter web build here; mobile builds remain local or APK artifacts. |
| Node/Express API | Render free web service | The service sleeps after inactivity, so the first request is slow. Ephemeral files must not be used for data. | Use Render only for the demo API and keep startup fast. |
| PostgreSQL | Supabase or Neon free database | Storage, connection, and compute quotas apply; free projects may pause or have retention limits. | Prefer Supabase or Neon over Render Postgres for the system of record. |
| Redis/cache | Upstash Redis free tier | Request and storage limits; never use it as the source of truth. | Use only for cache, sessions, and future queue coordination. |
| File/photo storage | Supabase Storage free tier or Cloudinary free tier | File size, bandwidth, transformations, and public URL limits. | Store only demo crop photos; keep originals small and private by default. |
| Authentication | Existing JWT demo flow for development; Supabase Auth or Firebase Auth for production OTP | SMS OTP has provider cost and rate limits; demo login must never be enabled in production. | Keep `/auth/demo-login` development-only and add real OTP after the data foundation. |
| AI assistant | Gemini or another provider's current free developer quota | Quotas, model availability, rate limits, and terms can change; never expose keys in Flutter. | Call AI only through `/api/v1/ai/*` and return a graceful advisory fallback. |
| CI | GitHub Actions free minutes for public repositories | Private repositories have account minute limits; jobs can be delayed or fail after quota. | Run backend tests, Flutter analyze, and Flutter tests on every push. |
| Containerized local services | Docker Compose with PostgreSQL and Redis | A developer machine still needs Docker resources and local backups. | Use Compose for repeatable local development and demos. |
| Monitoring/logs | Render logs, Supabase logs, and GitHub Actions artifacts | Retention and search are limited; logs may disappear. Never log secrets or personal data. | Keep structured request/error logs and export important demo evidence. |
| Payments | bKash/Nagad sandbox when access is available; local mock provider otherwise | Sandbox access, credentials, callbacks, and quotas are external dependencies. | Complete payment integration last and keep the provider interface stable. |

### Free-tier rules

- Do not depend on a sleeping service for scheduled jobs or payment webhooks.
- Do not put PostgreSQL credentials, AI keys, OTP secrets, or real personal data in source control.
- Keep PostgreSQL as the source of truth; Redis and hosted caches must be rebuildable.
- Add health checks and a visible offline/error state because free services can pause or rate-limit.
- Pin package versions and record the selected provider and quota in deployment notes.
- Treat every free plan as a prototype constraint, not a production availability promise.

## Four-week order of work

### Week 1: Free foundation first

- Run PostgreSQL and Redis locally with `docker compose up -d`.
- Install Prisma dependencies, generate the client, and apply the core schema.
- Move crop listing, bidding, and order reads/writes from the in-memory store to PostgreSQL.
- Add seed data and a one-command local setup section.
- Keep the mock payment provider and demo login available only in development.
- Require CI to pass `npm test`, `flutter analyze`, and `flutter test`.

**Exit check:** a new developer can start the local services, seed the database, run the API, and complete listing to bidding with no paid account.

### Week 2: Environment switches instead of paid services

- Add environment variables for API URL, `DATABASE_URL`, Redis URL, JWT secret, storage bucket, and AI provider.
- Deploy the API to a free sleeping host and the database to Supabase or Neon.
- Deploy Flutter web to Cloudflare Pages or GitHub Pages.
- Configure CORS, HTTPS callback URLs, health checks, and a documented cold-start warning.
- Add a provider switch for local mock storage versus hosted storage.
- Verify that cache loss and API restarts do not lose orders, escrow, loans, or audit data.

**Exit check:** the hosted demo can be restarted or cold-started without corrupting the PostgreSQL-backed core flow.

### Week 3: Free data and AI

- Replace hard-coded weather and sensor samples with a free data source or clearly labelled seeded data.
- Connect the Bangla assistant through the server using a free developer quota.
- Connect crop-photo verification through server-side storage and a free model quota, or keep the advisory sandbox fallback when quota is unavailable.
- Add request limits, response size limits, timeout handling, and offline UI states.
- Record AI confidence, model/provider, and advisory disclaimers for the thesis evaluation.

**Exit check:** AI and data features degrade gracefully when their provider is unavailable and never expose provider keys to Flutter.

### Week 4: Sandbox payments last

- Apply for and configure bKash/Nagad sandbox credentials only after the core flow is stable.
- Implement signed webhook verification, idempotency, provider references, and replay-safe state transitions.
- Test successful payment, duplicate request, duplicate webhook, timeout, invalid signature, refund, and dispute paths.
- Keep the mock provider selectable for local development and demos without sandbox access.
- Capture payment limitations clearly: sandbox only, no regulatory approval, and no real-money settlement.

**Exit check:** the demo can switch between mock and sandbox providers through environment configuration without changing escrow business logic.

## Current project gap

The repository currently has the schema and sandbox API/UI slices, but the live backend still uses the in-memory store. Week 1 database migration is therefore the next engineering task before deploying the free hosted stack.
