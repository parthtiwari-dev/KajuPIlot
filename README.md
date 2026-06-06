# KajuPilot

KajuPilot is a private, local-first business operating system for one cashew commodity trader. It is not a SaaS product, not a generic finance tracker, and not a chatbot. It is designed to replace a paper notebook, WhatsApp self-reminders, and memory-heavy follow-ups with a focused Android app, a private backend, and an admin view.

The roadmap in [docs/kajupilot_roadmap.md](docs/kajupilot_roadmap.md) is the source of truth for product behavior, architecture, design language, schema, API shape, and release phases.

## Current Status

Phase 0 foundation is scaffolded:

- Flutter Android app in `kajupilot/`
- NestJS API in `kajupilot-api/`
- Next.js admin dashboard in `kajupilot-admin/`
- PostgreSQL, Redis, API, admin, and Caddy wiring in `docker-compose.yml`
- Environment template in `.env.example`
- Production ignore rules in `.gitignore`

Installed dependency locks are committed-ready:

- `kajupilot/pubspec.lock`
- `kajupilot-api/package-lock.json`
- `kajupilot-admin/package-lock.json`

## Product Goal

The app exists to help the trader answer three questions every day:

- Who should I call first?
- Which money is pending, due, or overdue?
- What changed after each call?

The core experience is built around three flows:

- Night dump: the trader enters tomorrow's plan in plain language.
- Morning check: the Today screen shows sorted calls, collections, deliveries, and reminders.
- After-call capture: one tap logs the call outcome and creates follow-up work when needed.

Every AI-assisted action must also be possible manually through the UI. AI is a shortcut, never a dependency.

## Architecture

| Layer | Stack | Purpose |
| --- | --- | --- |
| Mobile app | Flutter, Riverpod, GoRouter, Drift, Dio | Offline-first Android APK with local SQLite writes and background sync |
| Backend API | Node.js 20 LTS, NestJS, Prisma | Auth setup, validation, sync-ready schema, business logic, AI parsing, admin APIs |
| Database | PostgreSQL 16 | Durable server-side business records with decimal-safe money fields |
| Jobs/cache | Redis, BullMQ | Scheduled insights, retries, rate limits, cached summaries |
| AI | OpenAI SDK, Groq SDK | Provider-switchable model gateway for future plain-language parsing and insights |
| Admin | Next.js App Router, Tailwind, shadcn-compatible utilities, Recharts | Private visibility into activity, records, AI logs, and exports |
| Infrastructure | Docker Compose, Caddy | VPS deployment with HTTPS reverse proxy |

The roadmap calls out Next.js 14 for the admin. This scaffold uses the patched Next.js 15 line because current npm audit data flags the Next 14 line with known advisories.

## Repository Layout

```text
.
|-- kajupilot/              # Flutter Android app
|-- kajupilot-api/          # NestJS API
|-- kajupilot-admin/        # Next.js admin dashboard
|-- docs/
|   `-- kajupilot_roadmap.md
|-- .env.example
|-- .gitignore
|-- Caddyfile
|-- docker-compose.yml
|-- LICENSE
`-- README.md
```

## Prerequisites

- Git
- Flutter SDK and Dart
- Android Studio or Android SDK tooling
- Node.js 20 LTS for production parity
- Docker Desktop or Docker Engine with Compose
- OpenAI and Groq API keys for AI provider switching
- An Oracle VPS or equivalent Linux server for deployment

On Windows PowerShell, prefer `npm.cmd` if direct `npm` execution is blocked by script policy.

## Local Setup

Install all project dependencies from lockfiles:

```powershell
cd kajupilot
flutter pub get

cd ..\kajupilot-api
npm.cmd install
npx.cmd prisma generate

cd ..\kajupilot-admin
npm.cmd install
```

## Flutter App

Run the Android app:

```powershell
cd kajupilot
flutter run
```

Analyze the app:

```powershell
cd kajupilot
flutter analyze
```

Release build:

```powershell
cd kajupilot
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

## Backend API

The API currently includes:

- `GET /api/v1/health`
- `POST /api/v1/auth/setup`
- `GET /api/v1/auth/me`
- Prisma schema for users, parties, deals, payments, expenses, tasks, call logs, and AI parse logs

Run locally:

```powershell
cd kajupilot-api
npm.cmd run start:dev
```

Build:

```powershell
cd kajupilot-api
npm.cmd run build
```

Generate Prisma client:

```powershell
cd kajupilot-api
npx.cmd prisma generate
```

Create a development migration after configuring `DATABASE_URL`:

```powershell
cd kajupilot-api
npx.cmd prisma migrate dev --name init
```

## Admin Dashboard

Run locally:

```powershell
cd kajupilot-admin
npm.cmd run dev
```

Build:

```powershell
cd kajupilot-admin
npm.cmd run build
```

The scaffolded dashboard is intentionally minimal. It gives the admin app a production-buildable shell while the real API-backed pages are built in later phases.

## Environment Variables

Copy the template and fill real values:

```powershell
copy .env.example .env
```

Template:

```env
DB_PASSWORD=replace_me_with_a_strong_password
JWT_SECRET=replace_me_with_a_64_character_random_secret
ADMIN_SETUP_CODE=KAJU-2026
ADMIN_SECRET=replace_me
ADMIN_USER=parth
ADMIN_PASS_HASH=replace_me_with_caddy_hash_password_output
API_HOST=api.localhost
ADMIN_HOST=admin.localhost
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1
AI_PROVIDER=openai
OPENAI_API_KEY=replace_me
OPENAI_MODEL=gpt-4o-mini
OPENAI_INPUT_COST_PER_1M=0.15
OPENAI_OUTPUT_COST_PER_1M=0.60
GROQ_API_KEY=replace_me
GROQ_MODEL=meta-llama/llama-4-scout-17b-16e-instruct
GROQ_INPUT_COST_PER_1M=0.11
GROQ_OUTPUT_COST_PER_1M=0.34
AI_MAX_TOKENS=700
AI_TEMPERATURE=0.2
```

## AI Provider Switch

The backend has one active AI switch:

```env
AI_PROVIDER=openai
```

Allowed values are:

- `openai`
- `groq`

Default OpenAI model:

```env
OPENAI_MODEL=gpt-4o-mini
```

Default Groq model:

```env
GROQ_MODEL=meta-llama/llama-4-scout-17b-16e-instruct
```

To switch all future AI calls to Groq, change only:

```env
AI_PROVIDER=groq
```

The cost values are editable env hints used by the backend cost estimator. Keep them updated from the provider pricing pages when pricing changes.

Check the active provider without exposing keys:

```powershell
Invoke-RestMethod http://localhost:3000/api/v1/ai/providers
```

## Docker

Start the full stack:

```powershell
docker compose up -d --build
docker compose ps
```

Run production Prisma migrations inside the API container:

```powershell
docker compose exec api npx prisma migrate deploy
```

The Compose stack keeps PostgreSQL and Redis on an internal Docker network, exposes traffic through Caddy, and builds the API/admin containers from their local Dockerfiles.

## Engineering Rules

- Local-first writes: the Flutter app writes to Drift SQLite first, updates UI immediately, then syncs in the background.
- Idempotent sync: client-created `syncId` values prevent duplicate server records.
- Soft deletes only: business records are marked deleted with `deletedAt`, not hard-deleted.
- Money safety: server money values use decimal types, never floating-point math.
- Manual fallback: every AI parse path has a matching manual UI flow.
- Single-user assumptions: conflict handling can remain last-write-wins unless multi-device behavior is introduced.
- Minimal clutter: every feature must help the trader act faster, collect faster, or remember less.

## Verification

Current setup has been verified with:

```powershell
cd kajupilot
flutter analyze

cd ..\kajupilot-api
npm.cmd run build
npm.cmd audit

cd ..\kajupilot-admin
npm.cmd run build
npm.cmd audit
```

Expected results:

- Flutter analysis: no issues
- API build: passes
- Admin production build: passes
- API npm audit: 0 vulnerabilities
- Admin npm audit: 0 vulnerabilities

## Documentation Policy

Treat `docs/kajupilot_roadmap.md` as locked project context unless a future task explicitly asks to edit it. Implementation work should conform to that roadmap instead of reshaping it casually.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
