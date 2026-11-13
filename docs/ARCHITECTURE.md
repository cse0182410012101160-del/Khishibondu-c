# Agro-Bridge Architecture

## Current target

Agro-Bridge is a Flutter client and a Node.js/Express modular monolith for a Bangladesh farmer-to-buyer marketplace with escrow and microfinance workflows.

The current backend is JavaScript and uses an in-memory singleton. PostgreSQL is the planned system of record for users, crop lots, bids, orders, escrow ledger entries, credit events, loans, chat, disputes, trace events, and audit logs. Redis, queues, and external payment or AI providers are not assumed to be available until verified.

## Boundaries

- Flutter feature modules own presentation and repository adapters. Screens do not call HTTP directly.
- Express modules expose routes, controllers, services, validation, and tests.
- Money movement belongs in the escrow service and must use a provider interface.
- AI calls go through server endpoints so provider keys never reach Flutter.
- PostgreSQL is authoritative for money, orders, loans, and audit history.
- Redis may hold cache or sessions only; cached data must be rebuildable.

## Core flow

`CREATED -> FUNDED -> IN_TRANSIT -> DELIVERED -> RELEASED`

A dispute branches from `IN_TRANSIT` or `DELIVERED` and resolves to `RELEASED` or `REFUNDED`. Every transition must validate the current state, write an append-only ledger entry, and be idempotent.

## API conventions

- Base path: `/api/v1`.
- Validate request bodies and return `{ code, message, details }` for errors.
- Authenticate with short-lived access tokens and refresh tokens when production OTP is added.
- Enforce role checks at the route boundary and audit administrative actions.
- Verify webhook signatures before processing payment events.

## Delivery order

1. Audit and document the current state.
2. Provide reproducible PostgreSQL and Redis development services and CI checks.
3. Migrate crop listing and bidding repositories from the in-memory store to PostgreSQL.
4. Migrate the remaining money and loan workflows.
5. Add payments, AI assistant, photo verification, buyer procurement, and NGO analytics as vertical slices.

## Free deployment plan

Provider choices, free-tier limitations, and the four-week delivery sequence are documented in [FREE_STACK_PLAN.md](FREE_STACK_PLAN.md). The short version is: local Docker foundation first, hosted environment switches second, free data and AI third, and sandbox payments last.
