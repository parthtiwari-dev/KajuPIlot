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
|-- Makefile
|-- docker-compose.yml
|-- docker-compose.dev.yml
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

For local Windows development:

```powershell
copy .env.local.example .env
```

For Oracle production:

```bash
cp .env.production.example .env
nano .env
```

Use `.env.example` only as a minimal key list. The full copy-paste templates are `.env.local.example` and `.env.production.example`.

On Oracle, the important production URL values are:

```env
DEPLOY_TARGET=production
API_HOST=api.141.148.213.89.sslip.io
ADMIN_HOST=admin.141.148.213.89.sslip.io
ADMIN_API_URL=http://api:3000/api/v1
NEXT_PUBLIC_API_URL=https://api.141.148.213.89.sslip.io/api/v1
ALLOWED_ORIGINS=https://admin.141.148.213.89.sslip.io
```

`ADMIN_API_URL` is intentionally internal Docker networking. Do not change it to the public HTTPS URL.

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

For local development, use the Makefile command menu. It starts the API directly on `localhost:3000`, which is the cleanest path for a physical Android phone through `adb reverse`.

If `make` is installed:

```powershell
make help
```

If `make` is not installed, run the same commands through PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/dev.ps1 help
```

Recommended terminal split:

```powershell
# Terminal 1: create/check env, start Docker dev stack, migrate, verify
make env
make env-check
make build
make up
make migrate
make health
make ps
```

```powershell
# Terminal 2: keep logs open
make logs
```

```powershell
# Terminal 3: run the Flutter app on the IQOO with hot reload
make devices
make run
```

The Flutter run command uses the default IQOO device id `1592533185000B8`. Override it only if `make devices` shows a different id:

```powershell
make run DEVICE_ID=your_device_id
```

The Flutter run command runs:

- `adb reverse tcp:3000 tcp:3000`
- `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1`

Useful dev commands:

```powershell
make ps
make restart
make down
make apk
make checks
```

## Oracle Production Deployment

The Oracle production path is documented in [docs/ORACLE_DEPLOYMENT.md](docs/ORACLE_DEPLOYMENT.md).

Production uses Caddy as the only public entrypoint:

```text
Phone app -> https://api.<oracle-ip>.sslip.io/api/v1 -> Caddy -> API container
Admin web -> https://admin.<oracle-ip>.sslip.io -> Caddy -> Admin container
```

Postgres, Redis, the API container port `3000`, and the admin container port `3001` stay private inside Docker.

On the VPS, use the production targets:

```bash
bash scripts/oracle-prod-env.sh
make prod-up
make prod-migrate
make prod-health
```

On Windows, build the private release APK against the deployed API:

```powershell
make release-oracle ORACLE_IP=141.148.213.89
```

Use `make up` for local development. Use `make prod-up` or `make up DEPLOY_TARGET=prod` on Oracle so the dev port override is not used.

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
