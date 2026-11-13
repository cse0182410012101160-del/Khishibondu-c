# Agro-Bridge Coding Rules

- Backend is Node.js and Express in JavaScript; frontend is Flutter with Dart and flutter_bloc.
- Use feature-first folders and keep Flutter screens behind BLoC and repository layers.
- Backend endpoints live below `/api/v1` and every endpoint gets a success test and failure-path tests.
- Validate request bodies at the route boundary and use one consistent error shape: `code`, `message`, `details`.
- Never put secrets, API keys, real phone numbers, NID values, or customer data in source or prompts.
- Money logic lives only in the escrow service. Use a PaymentProvider interface, signed webhook verification, and idempotency keys.
- PostgreSQL is the source of truth for orders, escrow, loans, and audit data. Redis is cache/session infrastructure only.
- Keep demo login development-only when production OTP is implemented.
- Preserve Bangla and English UI states, including loading, error, and empty states.
- Prefer small vertical slices. Read and test every change touching authentication, authorization, money, or personal data.
