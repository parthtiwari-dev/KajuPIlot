# KajuPilot

KajuPilot is a private, local-first Android business operating system for a cashew trader. It is built for daily use by one real operator, not as a SaaS product or generic finance tracker.

The app replaces scattered notebooks, WhatsApp self-reminders, memory-heavy follow-ups, and manual money tracking with one focused workflow: people, deals, money, tasks, calls, AI-assisted capture, and a private admin layer.

## Production Status

KajuPilot v1.0.0 is deployed on an Oracle VPS and packaged as a private Android APK.

Live production endpoints:

| Surface | URL | Notes |
| --- | --- | --- |
| Android API | [https://api.141.148.213.89.sslip.io/api/v1](https://api.141.148.213.89.sslip.io/api/v1) | Used by the release APK for sync |
| API health | [https://api.141.148.213.89.sslip.io/api/v1/health](https://api.141.148.213.89.sslip.io/api/v1/health) | Public health check |
| Admin dashboard | [https://admin.141.148.213.89.sslip.io](https://admin.141.148.213.89.sslip.io) | Password protected by Caddy basic auth and admin login |

Admin access has two layers:

- Caddy browser popup: `ADMIN_USER` plus the password used to generate `ADMIN_PASS_HASH`.
- Admin app login: `ADMIN_USER` plus `ADMIN_SECRET`.

Secrets are stored only in the server `.env` file and are intentionally not committed.

## What It Does

The trader can:

- Maintain people/party records for customers, suppliers, and both.
- Add bucket-wise sale and purchase deals with multiple item rows.
- Track received money, paid money, business expenses, and personal expenses.
- See receivables, payables, pending balances, expense mix, and weekly business stats.
- Create tasks and call reminders for follow-ups, collections, deliveries, and notes.
- Use native phone calls and log call outcomes.
- Use the universal input bar to turn messy trader notes into confirmed tasks, deals, payments, and expenses.
- Work locally first on the phone, then sync to the Oracle backend when online.
- Inspect activity, users, AI logs, and exports through the admin dashboard.

## Product Flow

The daily workflow is intentionally simple:

1. Night dump: type or voice tomorrow's plan into the universal input.
2. Morning check: use Today to see calls, collections, deliveries, and overdue work.
3. During the day: add deals/payments/expenses manually or through the AI preview sheet.
4. After calls: log the outcome and create follow-up tasks when needed.
5. Weekly view: use More/Insights to review revenue, expenses, buyers, slow payers, and AI notes.

Every AI-assisted path has a manual fallback. AI creates records only after preview and confirmation.

## Architecture

| Layer | Stack | Purpose |
| --- | --- | --- |
| Mobile app | Flutter, Riverpod, GoRouter, Drift, Dio | Offline-first Android APK with local SQLite writes and sync |
| Backend API | NestJS, Prisma, Node.js 20 | Auth, CRUD APIs, sync rules, business logic, AI parsing, admin APIs |
| Database | PostgreSQL 16 | Durable server records with decimal-safe money fields |
| Cache/jobs | Redis, BullMQ | AI cache, rate limits, scheduled summaries |
| AI gateway | OpenAI + Groq SDKs | Provider-switchable parsing and summaries |
| Admin | Next.js 15, Tailwind, Recharts | Private operational dashboard and exports |
| Edge | Caddy | HTTPS reverse proxy and admin basic auth |
| Deployment | Docker Compose on Oracle VPS | Private production stack |

Production network shape:

```text
Phone APK
  -> https://api.141.148.213.89.sslip.io/api/v1
  -> Caddy 443
  -> API container 3000
  -> Postgres + Redis private Docker network

Admin browser
  -> https://admin.141.148.213.89.sslip.io
  -> Caddy 443 + basic auth
  -> Admin container 3001
  -> API container through http://api:3000/api/v1
```

Only ports `80` and `443` are public for KajuPilot. API `3000`, admin `3001`, Postgres `5432`, and Redis `6379` are not exposed publicly.

## Repository Layout

```text
.
|-- kajupilot/                    # Flutter Android app
|-- kajupilot-api/                # NestJS API
|-- kajupilot-admin/              # Next.js admin dashboard
|-- docs/
|   |-- ORACLE_DEPLOYMENT.md      # Production deploy/runbook
|   |-- PROGRESS_AUDIT.md         # Phase-by-phase implementation record
|   `-- kajupilot_roadmap.md      # Locked source roadmap
|-- scripts/
|   |-- dev.ps1                   # Windows local helper
|   `-- oracle-prod-env.sh        # Oracle production env helper
|-- Caddyfile
|-- Makefile
|-- docker-compose.yml            # Production compose
|-- docker-compose.dev.yml        # Local dev port override
|-- .env.example                  # Minimal key list
|-- .env.local.example            # Local Windows template
`-- .env.production.example       # Oracle production template
```

## Private APK Release

Build the production APK against the Oracle API:

```powershell
cd "C:\great learning self paced\z Final Projects\KajuPIlot"
make release-oracle ORACLE_IP=141.148.213.89
```

Primary APK to share:

```text
kajupilot\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

Most modern Android phones should use the `arm64-v8a` APK. The release is private APK distribution, not Play Store publishing.

Before handing over a clean APK, reset local phone data:

```powershell
adb uninstall com.kajupilot.app
adb install "kajupilot\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
```

The user needs:

- The APK.
- Internet access.
- The private setup code from Oracle `.env` under `ADMIN_SETUP_CODE`.
- Android permission to install from unknown sources.

## Oracle Operations

SSH:

```powershell
ssh -i "C:\great learning self paced\z Final Projects\oracle-auto-provision\oracle_key" ubuntu@141.148.213.89
```

Sync code and restart production:

```bash
cd ~/kajupilot
git pull origin main
make prod-up
make prod-migrate
make prod-health
make prod-ps
```

Check logs:

```bash
cd ~/kajupilot
make prod-logs
```

Verify public API:

```bash
curl -fsS https://api.141.148.213.89.sslip.io/api/v1/health
curl -fsS https://api.141.148.213.89.sslip.io/api/v1/ai/providers
```

Do not use `make health` on Oracle. That target is for Windows local development and calls PowerShell. Use `make prod-health`.

Full deployment notes are in [docs/ORACLE_DEPLOYMENT.md](docs/ORACLE_DEPLOYMENT.md).

## Data Reset For Handoff

To wipe all KajuPilot server test data before a fresh handoff:

```bash
cd ~/kajupilot
docker compose --env-file .env -f docker-compose.yml down -v
make prod-up
make prod-migrate
make prod-health
```

This deletes KajuPilot's Postgres volume. Use it only when test data can be discarded.

To clear a phone:

```powershell
adb shell pm clear com.kajupilot.app
```

Or fully reinstall:

```powershell
adb uninstall com.kajupilot.app
adb install "kajupilot\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
```

## Local Development

Prerequisites:

- Flutter SDK and Android tooling
- Node.js 20
- Docker Desktop or Docker Engine with Compose
- Git
- OpenAI/Groq keys for AI features

Create local env:

```powershell
copy .env.local.example .env
```

Start the local stack:

```powershell
make env-check
make build
make up
make migrate
make health
```

Run on a physical Android phone with hot reload:

```powershell
make devices
make run
```

`make run` uses:

```text
adb reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1
```

Run checks:

```powershell
make checks
```

## Environment

Use the right template:

| Environment | Template |
| --- | --- |
| Windows local dev | `.env.local.example` |
| Oracle production | `.env.production.example` |
| Minimal key list | `.env.example` |

Important production values:

```env
DEPLOY_TARGET=production
API_HOST=api.141.148.213.89.sslip.io
ADMIN_HOST=admin.141.148.213.89.sslip.io
ADMIN_API_URL=http://api:3000/api/v1
NEXT_PUBLIC_API_URL=https://api.141.148.213.89.sslip.io/api/v1
ALLOWED_ORIGINS=https://admin.141.148.213.89.sslip.io
```

`ADMIN_API_URL` is intentionally internal Docker networking. Do not change it to the public HTTPS URL.

AI provider switch:

```env
AI_PROVIDER=openai
```

Allowed values:

- `openai`
- `groq`

Switching providers only requires changing `AI_PROVIDER`, assuming the matching API key is present.

## Verification History

The v1 implementation has passed:

- Flutter analyze and tests.
- Flutter debug APK and release APK builds.
- API build, test suite, audit, and Prisma validation.
- Admin typecheck, production build, and audit.
- Docker production compose startup on Oracle.
- Prisma migrations on Oracle.
- Public API health and AI provider checks.
- Admin login through Caddy basic auth plus app login.

See [docs/PROGRESS_AUDIT.md](docs/PROGRESS_AUDIT.md) for the full implementation record.

## Engineering Rules

- Local-first writes: phone writes to Drift SQLite first, then syncs.
- Idempotent sync: client-generated IDs and `syncId` values prevent duplicate records.
- Soft deletes: business records use `deletedAt`.
- Money safety: server values use decimal-safe storage; app stores money in paise.
- AI safety: AI creates records only after preview/confirmation.
- Manual fallback: every AI path has a manual UI path.
- Private deployment: this is built for one daily operator, not multi-tenant SaaS.

## Documentation Policy

Treat [docs/kajupilot_roadmap.md](docs/kajupilot_roadmap.md) as locked project context unless a future task explicitly asks to edit it.

## License

MIT. See [LICENSE](LICENSE).
