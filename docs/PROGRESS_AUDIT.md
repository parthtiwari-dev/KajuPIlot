# KAJUPILOT Progress Audit

Date: 2026-06-07
Branch: `main`
Status: Phase 2 Today, Tasks, Call Logs, Insights, and local notifications implemented and verified; ready for IQOO smoke

## Branch And Repo

| Item | State |
|---|---|
| Current branch | `main` |
| Remote | `origin` -> `https://github.com/parthtiwari-dev/KajuPIlot.git` |
| Published? | Remote is configured; current publish/commit state should be checked before pushing |
| Roadmap preserved | Yes, `docs/kajupilot_roadmap.md` remains the source of truth |
| Progress audit | Added as `docs/PROGRESS_AUDIT.md` by user request |

## Phase -1 Checklist

| Task | Result |
|---|---|
| Read roadmap context | Done, `docs/kajupilot_roadmap.md` was absorbed before implementation |
| Preserve roadmap doc | Done, no roadmap edits made |
| Create production `.gitignore` | Done, includes Flutter, Android, Node, Docker/env, generated build outputs, and keeps Gradle wrapper files trackable |
| Add root README | Done, production-grade README added for setup, stack, verification, and rules |
| Add environment template | Done, `.env.example` created |
| Add Docker/Caddy baseline | Done, `docker-compose.yml` and `Caddyfile` created |
| Add dev Docker override | Done, `docker-compose.dev.yml` exposes API/admin/Postgres/Redis for local work |
| Add command menu | Done, `Makefile` and `scripts/dev.ps1` added |
| Scaffold Flutter app | Done in `kajupilot/` |
| Scaffold NestJS API | Done in `kajupilot-api/` |
| Scaffold Next admin shell | Done in `kajupilot-admin/` |
| Install Flutter dependencies | Done |
| Install API dependencies | Done |
| Install admin dependencies | Done |
| Add Prisma initial migration | Done |
| Verify baseline builds | Done |

## Phase 0 Checklist

| Task | Result |
|---|---|
| Replace default Flutter counter app | Done |
| Add `ProviderScope` | Done |
| Add `AdaptiveTheme` | Done |
| Add `GoRouter` routing | Done |
| Add Calm Commerce theme tokens | Done |
| Add `/setup` route | Done |
| Add shell routes `/today`, `/money`, `/deals`, `/people`, `/more` | Done |
| Add polished empty tab placeholders | Done |
| Add bottom navigation shell | Done |
| Add universal input bar | Done, UI-only Phase 0 component |
| Add placeholder input bottom sheet | Done, no parsing logic yet |
| Add API client | Done, supports `API_BASE_URL` Dart define |
| Add setup-code screen | Done |
| Store device token securely | Done with `flutter_secure_storage` |
| Route based on stored token | Done |
| Add lightweight auth provider/state | Done |
| Add Drift local database foundation | Done |
| Run Drift code generation | Done |
| Add backend health endpoint | Done |
| Add backend setup endpoint | Done |
| Add JWT-shaped device token | Done |
| Add `/auth/me` endpoint | Done |
| Add JWT strategy skeleton | Done |
| Add roles decorator/guard skeleton | Done |
| Add AI provider switch foundation | Done, `AI_PROVIDER=openai` or `AI_PROVIDER=groq` |
| Keep Phase 1 CRUD out | Done |
| Keep AI parsing out | Done |

## Phase 1A Checklist

| Task | Result |
|---|---|
| Add `KajuCard` | Done |
| Add `AmountDisplay` | Done, uses integer paise and Indian rupee formatting |
| Add `StatusBadge` | Done |
| Add `PersonAvatar` | Done |
| Add `KajuActionButton` | Done, supports phone launch path for later task cards |
| Add lightweight empty-state helper | Done |
| Add lightweight shimmer helper | Done |
| Add rupee/paise utility helpers | Done |
| Add date utility helpers | Done |
| Attach stored token to API requests | Done, setup endpoint remains token-free |
| Add typed API method foundation | Done |
| Add Drift database provider | Done |
| Add pending sync service | Done, create/update/delete queue actions only |
| Add backend current-user decorator | Done |
| Add backend JWT auth guard helper | Done |
| Route `/auth/me` through guard/decorator pattern | Done |
| Keep full CRUD out | Done |
| Keep AI parsing out | Done |

## Phase 1B Checklist

| Task | Result |
|---|---|
| Add protected Parties API module | Done |
| `GET /api/v1/parties` | Done, supports search/type/trustTag filters |
| `POST /api/v1/parties` | Done, supports client ID and `syncId` idempotency |
| `GET /api/v1/parties/:id` | Done |
| `PUT /api/v1/parties/:id` | Done |
| `DELETE /api/v1/parties/:id` | Done, soft delete only |
| `GET /api/v1/parties/:id/ledger` | Done |
| `GET /api/v1/parties/:id/history` | Done |
| Add duplicate `syncId` handling | Done |
| Add soft-delete restore path for undo | Done, re-sending same `syncId` restores same-user deleted party |
| Scope Parties API to current user | Done |
| Add People local-first repository | Done |
| Add People screen | Done, replaces placeholder |
| Add search field | Done |
| Add filter chips | Done: All, Customers, Suppliers, Both, Overdue |
| Add Add Person sheet | Done |
| Add edit person flow | Done |
| Add swipe delete with undo | Done |
| Add pull-to-refresh | Done, flushes pending party sync then pulls server parties |
| Add person profile route | Done, `/people/:partyId` |
| Add profile notes editing | Done, debounced local-first update |
| Keep Deals/Payments/Calls out | Done, profile tabs show empty states |
| Keep AI parsing out | Done |

## Phase 1B.1 Checklist

| Task | Result |
|---|---|
| Add phone contact import path | Done |
| Use Android native contact picker | Done, no full contact sync |
| Add `Import from phone` button to Add/Edit Person sheet | Done |
| Fill person name from selected contact | Done |
| Fill phone number from selected contact | Done |
| Keep manual entry unchanged | Done |
| Save imported contact through existing local-first flow | Done |
| Avoid roadmap edits | Done |

## Phase 1C Checklist

| Task | Result |
|---|---|
| Add protected Deals API module | Done |
| `GET /api/v1/deals` | Done, supports status/party/date/grade filters |
| `POST /api/v1/deals` | Done, supports client ID and `syncId` idempotency |
| `GET /api/v1/deals/:id` | Done |
| `PUT /api/v1/deals/:id` | Done, edits non-status fields |
| `PUT /api/v1/deals/:id/status` | Done, validates forward-only status transitions |
| `DELETE /api/v1/deals/:id` | Done, soft delete only |
| Scope Deals API to current user | Done |
| Validate deal party ownership | Done |
| Compute `totalAmount` on backend | Done |
| Return party summary with deals | Done |
| Return money/quantity as decimal strings | Done |
| Add duplicate `syncId` handling | Done |
| Reject `PAID` status until paid amount covers total | Done |
| Add Deals local-first repository | Done |
| Store quantity as grams locally | Done |
| Store money as paise locally | Done |
| Add pending sync support for deal create/update/status/delete | Done |
| Replace Deals placeholder screen | Done |
| Add status filter chips | Done: All, Quoted, Confirmed, Delivered, Paid |
| Add search by party or grade | Done |
| Add deal cards | Done |
| Add Add/Edit Deal sheet | Done |
| Add live total calculation | Done |
| Add next-status action | Done |
| Add swipe delete with undo | Done |
| Add pull-to-refresh | Done |
| Show party deals in People profile | Done |
| Keep Payments/Expenses/Tasks/AI parsing out | Done |

## Phase 1C.1 Checklist

| Task | Result |
|---|---|
| Remove cashew grade option chips | Done, grade/item is free text only |
| Remove kg-specific quantity from UI | Done, quantity is free text like `10 balti` |
| Remove rate-per-kg language | Done, rate is optional free text like `780 per balti` |
| Add manual line totals | Done |
| Compute pending from total minus paid | Done |
| Support multiple grades in one deal | Done through `DealItem` rows |
| Add backend `DealItem` model and migration | Done |
| Add local Drift `DealItems` table | Done, schema version bumped to 2 |
| Keep old deal columns compatible | Done, old kg/rate fields are zeroed for new bucket-wise deals |
| Allow new person from Add Deal | Done |
| Auto-create Sale person as Customer | Done |
| Auto-create Purchase person as Supplier | Done |
| Default new deals to Confirmed | Done, no quoted/confirmed choice shown on create |
| Preserve status workflow for later detail actions | Done |

## Phase 1D Checklist

| Task | Result |
|---|---|
| Add protected Payments API module | Done |
| `GET /api/v1/payments` | Done, supports party/deal/type/date filters |
| `POST /api/v1/payments` | Done, supports client ID and `syncId` idempotency |
| `PUT /api/v1/payments/:id` | Done |
| `DELETE /api/v1/payments/:id` | Done, soft delete only |
| `GET /api/v1/payments/ledger` | Done |
| Scope Payments API to current user | Done |
| Validate payment party ownership | Done |
| Validate linked deal ownership and party match | Done |
| Linked payment updates deal `paidAmount` | Done |
| Linked payment overpay rejection | Done |
| Soft delete reverses linked deal paid amount | Done |
| Party-level payment support | Done, reduces party-level receivable/payable without mutating deals |
| Add protected Expenses API module | Done |
| `GET /api/v1/expenses` | Done, supports category/date filters |
| `POST /api/v1/expenses` | Done, supports client ID and `syncId` idempotency |
| `PUT /api/v1/expenses/:id` | Done |
| `DELETE /api/v1/expenses/:id` | Done, soft delete only |
| `GET /api/v1/expenses/summary` | Done, returns category totals and period comparison |
| Scope Expenses API to current user | Done |
| Update party ledger/history for payments | Done, unlinked payments affect balances and payments appear in history |
| Add Payments local-first repository | Done |
| Add Expenses local-first repository | Done |
| Add Money tab | Done, replaces placeholder |
| Add Money summary card | Done: To Receive, To Pay, Net |
| Add Receivable tab | Done |
| Add Payable tab | Done |
| Add Expenses tab | Done with category filter, summary, list, delete undo |
| Add Payment sheet | Done, supports new/existing party, linked deal, or party credit |
| Add Expense sheet | Done |
| Update local linked deal paid amount on payment write | Done |
| Queue payment/expense pending sync on API failure | Done |
| Add People profile Payments tab | Done |
| Update local People stats for party-level payments | Done |
| Keep AI parsing, Tasks, Calls, Reports, Admin out | Done |

## Phase 1D.1 Checklist

| Task | Result |
|---|---|
| Add expense business/personal scope | Done |
| Default existing expenses to business | Done, backend and Drift defaults are `BUSINESS` |
| Add Prisma migration for expense scope | Done |
| Add Drift migration for expense scope | Done, schema version bumped to 3 |
| Add API expense scope filter | Done |
| Add API expense summary by scope | Done |
| Add Flutter expense scope enum/models | Done |
| Add Expense sheet scope selector | Done, Business/Personal segmented control |
| Add Money Expenses scope filter | Done: All, Business, Personal |
| Split expense summary into Business and Personal totals | Done |
| Keep budgets/accounts/advanced reports out | Done |

## Phase 1E Checklist

| Task | Result |
|---|---|
| Add silent sync coordinator | Done, retries Parties, Deals, Payments, and Expenses pending queues |
| De-dupe concurrent sync retries | Done |
| Retry pending sync after app auth/login | Done |
| Retry pending sync on app foreground resume | Done |
| Retry pending sync during pull-to-refresh | Done, then pulls the active screen data without double-counting attempts |
| Keep sync retry quiet | Done, no popup/banner/manual sync screen added |
| Polish Person Profile loading states | Done, replaced spinners/progress bars with Kaju skeleton loaders |
| Add pull-to-refresh to profile Deals tab | Done |
| Add pull-to-refresh to profile Payments tab | Done |
| Add swipe delete + undo to profile Deals tab | Done |
| Add swipe delete + undo to profile Payments tab | Done |
| Add profile empty-state CTAs | Done, Add Deal and Add Payment actions |
| Keep Money ledger rows non-deletable | Done, ledger rows remain computed balances |
| Keep Today/More placeholders unchanged | Done |

## Phase 2 Checklist

| Task | Result |
|---|---|
| Add protected Tasks API module | Done |
| `GET /api/v1/tasks` | Done, supports status/type/party/date filters |
| `GET /api/v1/tasks/today` | Done, date-aware and sorted overdue first, priority, then time |
| `POST /api/v1/tasks` | Done, supports client ID and `syncId` idempotency |
| `PUT /api/v1/tasks/:id` | Done |
| `PUT /api/v1/tasks/:id/complete` | Done |
| `PUT /api/v1/tasks/:id/postpone` | Done |
| `DELETE /api/v1/tasks/:id` | Done, soft delete only |
| Add protected Call Logs API module | Done |
| `POST /api/v1/call-logs` | Done, logs call outcomes and side effects |
| `GET /api/v1/call-logs` | Done, supports party/date filters |
| Prevent duplicate call-log side effects | Done, duplicate `syncId` returns existing call log only |
| Payment promised follow-up task | Done |
| No-answer follow-up task | Done |
| New-order follow-up task | Done |
| Complete source task after saved outcome | Done locally and on backend |
| Add Today insights API | Done, `GET /api/v1/insights/today` |
| Add Flutter Tasks API/repository | Done |
| Add Flutter Call Logs API/repository | Done |
| Add Tasks and Call Logs to silent sync retry | Done |
| Add local notification service | Done, task reminders, 8 AM summary, quiet hourly nudges |
| Add Android notification permission | Done |
| Replace Today placeholder | Done |
| Add Today stats, sections, skeletons, empty state, and pull-to-refresh | Done |
| Add manual Add/Edit Task sheet | Done |
| Add done/postpone/delete task actions | Done |
| Add call button and OutcomeSheet | Done |
| Add real People profile Calls tab | Done |
| Keep AI parsing out | Done |
| Keep Reports/Admin out | Done |

## Phase 0 App Shell Lock

| Task | Result |
|---|---|
| App entry | `main.dart` now boots the KajuPilot app instead of the Flutter counter |
| Theme | Light/dark Calm Commerce palette, spacing, radius, and typography tokens added |
| Navigation | Setup route and five post-setup tabs wired through GoRouter |
| Today tab | Real local-first command center added in Phase 2 |
| Money tab | Real local-first Money screen added in Phase 1D |
| Deals tab | Real local-first deals list added |
| People tab | Real local-first People screen added in Phase 1B |
| More tab | Placeholder screen added |
| Universal input | Visible above bottom navigation and opens a non-parsing bottom sheet |
| Android network access | `INTERNET` permission added |
| Android notifications | `POST_NOTIFICATIONS` permission added |

## Phase 0 Setup/Auth

| Task | Result |
|---|---|
| API base URL | Uses `--dart-define=API_BASE_URL=...`; default is Android-emulator friendly `http://10.0.2.2:3000/api/v1` |
| Physical phone URL policy | Use USB `adb reverse` and `http://127.0.0.1:3000/api/v1`, or use the laptop LAN IP |
| Setup request | `POST /api/v1/auth/setup` |
| Setup response | `{ userId, deviceToken }` |
| Token storage | Stored in secure storage |
| Startup behavior | No token opens setup; stored token opens shell |
| Future auth reuse | Token provider/state ready for later API screens |

## Phase 0 Local-First Database Foundation

| Task | Result |
|---|---|
| Drift database | Added |
| Generated database file | Added through build runner |
| Local users | Added |
| Parties | Added |
| Deals | Added |
| Deal items | Added |
| Payments | Added and now used by Phase 1D |
| Expenses | Added and now used by Phase 1D |
| Tasks | Added and now used by Phase 2 |
| Call logs | Added and now used by Phase 2 |
| AI parse logs | Added |
| Pending sync queue | Added |
| ID policy | Text IDs/UUID-style IDs |
| Sync policy | `syncId`, timestamps, and soft-delete fields included |
| Enum policy | Stored as text locally |
| Money policy | Stored locally as integer paise |

## Phase 0 Backend Tightening

| Task | Result |
|---|---|
| Global API prefix | `/api/v1` |
| Health endpoint | `GET /api/v1/health` |
| Setup endpoint | `POST /api/v1/auth/setup` |
| Current user endpoint | `GET /api/v1/auth/me` |
| JWT signing | Device token signed with `JWT_SECRET` |
| Existing owner behavior | Reuses or upgrades owner token |
| Missing bearer token | Rejected |
| Invalid bearer token | Rejected |
| Prisma schema | Matches roadmap business model for Phase 0 foundation |
| Prisma migration | Initial migration added |
| Tests | Auth service/controller specs added |
| AI model gateway | Added for future parsing/insight calls |
| AI provider config endpoint | Added `GET /api/v1/ai/providers`, returns active provider/model/cost hints without secrets |

## Phase 0 AI Provider Switch

| Task | Result |
|---|---|
| One active provider switch | Done with `AI_PROVIDER` |
| OpenAI key | `OPENAI_API_KEY` |
| OpenAI default model | `gpt-4o-mini` |
| OpenAI cost hints | `OPENAI_INPUT_COST_PER_1M`, `OPENAI_OUTPUT_COST_PER_1M` |
| Groq key | `GROQ_API_KEY` |
| Groq default model | `meta-llama/llama-4-scout-17b-16e-instruct` |
| Groq cost hints | `GROQ_INPUT_COST_PER_1M`, `GROQ_OUTPUT_COST_PER_1M` |
| Shared generation gateway | Added `AiService` |
| Provider config service | Added `AiConfigService` |
| Secret exposure | API keys are not returned by the config endpoint |
| AI parsing | Still intentionally not implemented |

## Phase 0 Admin/Docker Foundation

| Task | Result |
|---|---|
| Admin shell | Next admin placeholder shell added |
| Admin production build | Passes |
| Docker compose | PostgreSQL, Redis, API, admin, and Caddy services defined |
| Dev compose override | Exposes API on `localhost:3000`, admin on `localhost:3001`, Postgres on `5432`, Redis on `6379` |
| Makefile workflow | Added targets for env, up, migrate, health, logs, phone run, APK build, and checks |
| Production network policy | Postgres/Redis kept internal |
| Caddy routing | API and admin hostnames configured through env vars |
| Runtime Prisma CLI | `prisma` kept available so container migration deploy can run |
| Local Docker start | Done, dev stack rebuilt and restarted |
| Physical-device backend smoke | Pending Phase 2 IQOO smoke |

## Current Stack

| Package | Version |
|---|---|
| Flutter app Dart SDK constraint | `^3.6.1` |
| flutter_riverpod | `^2.6.1` |
| go_router | `^16.1.0` |
| adaptive_theme | `^3.7.2` |
| drift | `2.28.0` |
| drift_flutter | `0.2.4` |
| drift_dev | `2.28.0` |
| dio | `^5.9.2` |
| flutter_local_notifications | `^19.5.0` |
| flutter_secure_storage | `^10.3.1` |
| intl | `^0.20.2` |
| url_launcher | `^6.3.2` |
| timezone | `^0.10.1` |
| sqlite3_flutter_libs | `^0.5.42` |
| NestJS | `^11.0.0` |
| Prisma | `^6.0.0` |
| PostgreSQL Docker image | `postgres:16-alpine` |
| Redis Docker image | `redis:7-alpine` |
| Next.js admin | `^15.5.18` |
| React admin | `^18.3.1` |
| Tailwind admin | `^3.4.17` |
| OpenAI SDK | `^6.42.0` |
| Groq SDK | `^0.26.0` |

## Phase -1 Files Added

| Area | Files |
|---|---|
| Root setup | `.gitignore`, `.env.example`, `README.md`, `docker-compose.yml`, `Caddyfile` |
| Dev commands | `Makefile`, `docker-compose.dev.yml`, `scripts/dev.ps1` |
| Flutter scaffold | `kajupilot/` |
| API scaffold | `kajupilot-api/` |
| Admin scaffold | `kajupilot-admin/` |
| Prisma migration | `kajupilot-api/prisma/migrations/20260604193000_init/migration.sql` |

## Phase 0 Files Added

| Area | Files |
|---|---|
| Flutter app root | `kajupilot/lib/main.dart`, `kajupilot/lib/app/kaju_app.dart` |
| Flutter routing | `kajupilot/lib/core/router/app_router.dart` |
| Flutter theme | `app_theme.dart`, `kaju_colors.dart`, `spacing.dart` |
| Flutter auth | `auth_controller.dart`, `token_storage.dart` |
| Flutter API | `api_client.dart` |
| Flutter database | `app_database.dart`, `app_database.g.dart` |
| Flutter setup UI | `setup_screen.dart` |
| Flutter shell UI | `app_shell.dart`, `empty_feature_screen.dart` |
| Flutter input UI | `universal_input_bar.dart` |
| Flutter tests | `kajupilot/test/widget_test.dart` |
| Backend health | `health.controller.ts`, `health.module.ts` |
| Backend auth | `auth.controller.ts`, `auth.service.ts`, setup DTO, JWT strategy, roles decorator, roles guard, token payload type |
| Backend AI | `ai.module.ts`, `ai.controller.ts`, `ai.service.ts`, `ai-config.service.ts` |
| Backend Prisma | `prisma.module.ts`, `prisma.service.ts`, `prisma/schema.prisma` |
| Backend tests | `auth.service.spec.ts`, `auth.controller.spec.ts`, `ai-config.service.spec.ts` |
| Admin shell | `kajupilot-admin/app/page.tsx`, `layout.tsx`, `globals.css` |

## Verification

| Check | Result |
|---|---|
| `flutter pub run build_runner build --delete-conflicting-outputs` | Pass |
| `dart.bat format lib test` | Pass |
| `flutter.bat analyze` | Pass |
| `flutter.bat test` | Pass, 45 Flutter tests |
| `flutter.bat test test/features/money` | Pass, 5 Money repository tests |
| `flutter.bat test test\features\today` | Pass, 3 Today repository tests |
| `flutter.bat build apk --debug` | Pass |
| `npm.cmd run build` in API | Pass |
| `npm.cmd run format` in API | Pass |
| `npm.cmd test` in API | Pass, 13 suites / 58 tests |
| Phase 2 targeted backend specs | Pass, 9 Tasks/Call Logs/Insights tests |
| `npm.cmd audit` in API | Pass, 0 vulnerabilities |
| Prisma validate with `DATABASE_URL` | Pass |
| `npm.cmd run build` in admin | Pass |
| `npm.cmd audit` in admin | Pass, 0 vulnerabilities |
| `docker compose --env-file .env.example config` | Pass |
| `make health` | Pass, API health and AI provider config returned successfully |
| `make migrate` | Pass, no pending migrations |
| Docker API/admin rebuild | Pass with `make build` |
| Docker dev stack restart | Pass with `make up` |
| Authenticated Parties route smoke | Pass, `GET /api/v1/parties` returned successfully |
| Authenticated Deals route smoke | Pass, `GET /api/v1/deals` returned successfully |
| Authenticated bucket-wise Deal create smoke | Pass, created deal with item `10 balti` and pending total |
| Authenticated Payments route smoke | Pass, linked payment updated deal paid amount |
| Authenticated Expenses route smoke | Pass, expense create and summary returned successfully |
| Authenticated personal expense smoke | Pass, `scope=PERSONAL` create and scoped summary returned successfully |
| Android contact picker bridge compile | Pass through debug APK build |
| Manual APK install/run | Pass, user confirmed IQOO opens app UI |
| Manual setup flow against live backend | Pending Phase 2 IQOO smoke |

## Issues Found And Resolved

| Issue | Resolution |
|---|---|
| Roadmap needed lock discipline | Kept `docs/kajupilot_roadmap.md` unchanged |
| Flutter default counter app | Replaced with real KajuPilot shell |
| Drift latest codegen needed newer Dart than local SDK | Pinned Drift packages to versions compatible with Dart `3.6.1` |
| Android plugins required newer Gradle/AGP/Kotlin setup | Updated Android Gradle plugin, Kotlin, Gradle wrapper, compile SDK, min SDK, NDK, and desugaring |
| Gradle wrapper accidentally risked being ignored | `.gitignore` adjusted to keep wrapper files trackable |
| Backend setup token needed roadmap alignment | Switched setup token to signed JWT shape |
| `/auth/me` needed bearer validation | Added token extraction and missing-token rejection |
| API tests needed auth coverage | Added setup success/failure and `/auth/me` rejection coverage |
| Java was missing for APK builds | Installed real Temurin JDK 17 on Windows |
| PyCharm JBR lacked `jlink.exe` | Switched to full JDK install |
| Next 14 line had audit advisories | Used patched Next 15 line while keeping admin scaffold minimal |
| AI provider choice could become scattered | Added one backend AI gateway and one `AI_PROVIDER` switch before parsing code exists |
| API format script targeted a missing `test/` folder | Narrowed the format script to `src/**/*.ts` so it passes cleanly |
| API Docker container restarted on boot | Fixed CommonJS `compression` import in `main.ts` |
| `make migrate` depended on a running API container | Changed migration target to a one-off API container command |
| Bottom-tab transition felt wrong on phone | Changed shell tab routes to `NoTransitionPage` |
| Future CRUD needed reusable auth access | Added `JwtAuthGuard`, `CurrentUser`, and an authenticated-user type |
| Phase 1A risked bleeding into CRUD | Kept Parties/Deals/Payments/Expenses screens and endpoints deferred to Phase 1B+ |
| Delete undo needed server-safe restore | Made duplicate same-user `syncId` restore soft-deleted parties |
| Add/Edit Person sheet overflowed on phone with keyboard/contact import | Made sheet content scrollable and added compact-height regression test |
| Deals needed explicit totals | Deal totals are now manually entered/summed from line items; pending is total minus paid |
| Deal status could corrupt ledger state | Added forward-only status transitions and full-payment requirement for `PAID` |
| Deals were too kg-specific for real cashew trading | Reworked deals to bucket-wise free-text quantities with manual totals |
| Add Deal forced existing parties only | Add Deal can now create a new person and auto-classify Customer/Supplier from Sale/Purchase |
| Money tab was still a placeholder | Replaced it with receivable, payable, and expense workflows |
| Payment records could double-count deal balances | Linked payments now mutate deal paid amount; party-level credits reduce party balances only |
| Party ledger ignored unlinked payments | Party ledger and local stats now include party-level payment credits |
| Personal expenses could pollute business expense totals | Added Business/Personal expense scope and split summaries |
| Profile tab swipe delete fought horizontal tab paging | Disabled horizontal swiping on profile `TabBarView` so row swipe-delete is reliable |
| Sync retry needed to be reliable but invisible | Added `SyncCoordinator` and lifecycle retry without popups or manual sync UI |
| Today tab was still a placeholder | Replaced it with a real local-first command center |
| Tasks and call logs existed only as schema | Added protected APIs, Flutter repositories, sync retry, and UI |
| Call outcome retries could duplicate follow-up tasks | Made call-log `syncId` idempotent and accepted client-generated follow-up task IDs |
| Notification summaries used `Rs` text | Switched user-facing notification money text to `₹` |

## Upgrade Notes

| Area | Decision |
|---|---|
| Flutter app | Kept Dart SDK compatibility at local `^3.6.1` |
| Drift | Pinned to `2.28.0` because newer generator versions require newer Dart SDK |
| Android build | Upgraded build tooling only enough to satisfy installed plugin requirements |
| Backend | NestJS 11 used for current supported package line |
| Admin | Next.js 15 used instead of roadmap Next 14 because audit health is cleaner |
| Docker | Compose file is production-oriented; a dev override may be useful later |
| AI | OpenAI and Groq SDKs installed; one provider switch added; AI parsing intentionally not implemented yet |

## Known Risks

| Risk | Action |
|---|---|
| Docker stack can drift after backend edits | Re-run `make build`, `make up`, and `make health` after API changes |
| Production Compose API is not exposed directly on host port `3000` | Use the dev compose override through `make up` for phone development |
| Physical phone cannot use emulator address `10.0.2.2` | Use `adb reverse` plus `http://127.0.0.1:3000/api/v1`, or use LAN IP |
| Manual setup smoke not yet fully completed | Enter setup code on IQOO, confirm token storage, relaunch into shell |
| Flutter debug service can disconnect on phone | App still installs/runs; rerun `make run` after reconnecting if hot reload is needed |
| Admin dashboard is placeholder-only | Keep until backend/admin roadmap phases |
| Phase 2 physical phone smoke is pending | Rebuild/restart Docker, run the app, and test Today tasks, call outcomes, and notifications on IQOO |
| Android notification permission depends on user approval | Allow notifications on the first run when prompted |
| Dialer return behavior can vary by Android device | After tapping Call, return to the app and save the outcome sheet |
| AI parsing not implemented | Start only after manual CRUD flows exist |
| AI provider prices can change | Keep env cost hints updated from OpenAI/Groq pricing pages |
| Secure production secrets are placeholders | Replace `.env` values before deployment |
| Single-device assumption still active | Multi-device sync conflict handling can wait |

## Phase 0 Data Decisions

| Item | Decision |
|---|---|
| Product stance | Private single-trader operating system, not SaaS |
| First app screen | Setup screen when no token exists |
| Post-setup app shape | Five-tab shell: Today, Money, Deals, People, More |
| Universal input | Present visually in Phase 0 but does not parse or create records yet |
| Offline-first foundation | Drift database exists before CRUD screens |
| Money storage | Integer paise locally; decimal/string conversion deferred to API boundary work |
| Sync queue | `pending_sync` exists locally for future offline-first writes |
| Manual fallback | Preserved as core rule for future AI features |
| AI provider choice | Default to OpenAI GPT-4o mini; switch to Groq by changing `AI_PROVIDER=groq` |
| Backend auth | JWT-shaped device token with stored-token validation |
| Admin | Keep as buildable placeholder until later phases |

## Phase 1A Data Decisions

| Item | Decision |
|---|---|
| Shared widgets | Added as reusable app primitives without replacing current placeholder screens |
| Amount display | Always formats from integer paise, using Indian digit grouping |
| API auth | Reads `deviceToken` from secure storage per request and sends `Authorization: Bearer ...` |
| Sync queue | Stores entity type, entity ID, action, JSON payload, attempt count, and timestamps |
| Backend protected routes | Future CRUD controllers should use `JwtAuthGuard` plus `CurrentUser` |
| Phase boundary | Parties/Deals/Payments/Expenses endpoints remain Phase 1B+ work |

## Phase 1B Data Decisions

| Item | Decision |
|---|---|
| First real CRUD slice | People/Parties, because parties are required by deals, payments, tasks, and calls |
| Party IDs | Flutter sends UUID text IDs and `syncId`; backend accepts client IDs |
| Party sync | Local Drift write happens first, then pending sync enqueue and immediate best-effort API sync |
| Pull-to-refresh | Flush pending party sync first, then pull server parties into Drift |
| Delete behavior | Local soft delete, API soft delete, snackbar undo can restore locally and server-side by re-sending same `syncId` |
| Money stats | Party pending/ledger values are computed from existing deal/payment schema and return decimal strings at API boundary |
| Profile tabs | Deals, Payments, Calls remain empty states until their later CRUD slices |

## Phase 1B.1 Data Decisions

| Item | Decision |
|---|---|
| Contact import scope | User-triggered single-contact picker only |
| Contact storage | Selected contact fills the existing Add/Edit Person form; save uses current People repository |
| Contact permissions | No bulk contact sync or background read |
| Dependency policy | Used a native Android method channel instead of adding a contacts package |

## Phase 1C Data Decisions

| Item | Decision |
|---|---|
| Second real CRUD slice | Deals, because payments and ledgers depend on deal totals |
| Deal IDs | Flutter sends UUID text IDs and `syncId`; backend accepts client IDs |
| Deal sync | Local Drift write happens first, then pending sync enqueue and immediate best-effort API sync |
| Pull-to-refresh | Flush pending deal sync first, then pull server deals into Drift |
| Quantity storage | Originally integer grams locally; superseded by Phase 1C.1 free-text quantity rows |
| Money storage | Integer paise locally; decimal strings at API boundary |
| Total amount | Originally computed from quantity/rate; superseded by Phase 1C.1 manual item totals |
| Status changes | Create may use Quoted or Confirmed; later changes use the status endpoint only |
| Delete behavior | Local soft delete, API soft delete, snackbar undo can restore by re-sending same `syncId` |
| People integration | Person profile Deals tab shows local deals filtered by `partyId`; stats update from local deals |
| Phase boundary | Payment records and automatic ledger payment behavior remain Phase 1D |

## Phase 1C.1 Data Decisions

| Item | Decision |
|---|---|
| Quantity model | Free text, because traders use bucket/balti/local terms |
| Deal item model | One deal can contain multiple grade rows for the same person |
| Rate model | Optional free text, because the rate phrase may be local |
| Total model | Manual amount per item; deal total is the sum of item totals |
| Pending model | `deal.totalPaise - deal.paidPaise` locally and `totalAmount - paidAmount` on API |
| Existing deal compatibility | Existing `Deal` columns remain; new item table stores real detail |
| New party from deal | Typing a new person name creates a Party before saving the Deal |
| Auto party type | Sale creates Customer; Purchase creates Supplier |
| Quoted/Confirmed UX | New deals default to Confirmed; quoted status remains backend-supported but not shown during creation |

## Phase 1D Data Decisions

| Item | Decision |
|---|---|
| Third real CRUD slice | Money, because Deals now have totals and pending balances |
| Payment IDs | Flutter sends UUID text IDs and `syncId`; backend accepts client IDs |
| Payment sync | Local Drift write happens first, then pending sync enqueue and immediate best-effort API sync |
| Expense sync | Local Drift write happens first, then pending sync enqueue and immediate best-effort API sync |
| Linked payment model | Linked payment updates the matching deal `paidAmount` locally and on the backend |
| Linked overpayment | Rejected locally and by the API |
| Party-level payment model | Allowed as unlinked payment; reduces receivable/payable ledger without changing any deal |
| Delete behavior | Soft delete only; linked payment delete reverses deal paid amount |
| Money screen shape | Summary card plus Receivable, Payable, and Expenses tabs |
| Expense summary | Lightweight category totals; advanced reports/charts remain later |
| People integration | Person profile Payments tab shows local payments filtered by `partyId` |
| Phase boundary | Tasks, Calls, AI parsing, Reports, and Admin remain out of Phase 1D |

## Phase 1D.1 Data Decisions

| Item | Decision |
|---|---|
| Expense scope | Every expense is either `BUSINESS` or `PERSONAL` |
| Default scope | Existing and new default expenses are `BUSINESS` |
| Business reporting | Business expenses stay clean for future profit/report calculations |
| Personal reporting | Personal expenses can be tracked without creating parties/deals |
| UI surface | Scope is a segmented control in Add/Edit Expense and filter chips in Money |
| Overbuild boundary | No budgets, wallets, bank accounts, recurring rules, or advanced charts yet |

## Phase 1E Data Decisions

| Item | Decision |
|---|---|
| Sync retry UX | Automatic and quiet; no popup, banner, or manual sync screen |
| Retry timing | After auth, on app foreground resume, and on pull-to-refresh |
| Retry ordering | Flush all pending queues first, then pull the active screen's remote data |
| Duplicate retry guard | Concurrent retry calls share one in-flight retry future |
| Profile delete behavior | Deals and Payments tabs match main list swipe-delete + undo behavior |
| Ledger delete boundary | Money receivable/payable rows stay non-deletable because they are computed aggregates |
| Phase boundary | No Today/tasks, AI, reports, admin, or release assets in Phase 1E |

## Phase 2 Data Decisions

| Item | Decision |
|---|---|
| Phase shape | One coordinated Phase 2 with internal 2A Tasks, 2B Today, and 2C Calls/Notifications gates |
| Task IDs | Flutter sends UUID text IDs and `syncId`; backend accepts client IDs |
| Task sync | Drift write happens first, then pending sync enqueue and immediate best-effort API sync |
| Call-log IDs | Flutter sends UUID text IDs and `syncId`; backend accepts client IDs |
| Call-log sync | Drift write happens first, then pending sync enqueue and immediate best-effort API sync |
| Today source | Today combines local tasks with deal-driven payment and delivery attention cards |
| Date policy | Flutter uses local device date and sends `date=YYYY-MM-DD` to backend |
| Call outcome policy | Saving an outcome marks the source call task done |
| Follow-up tasks | Flutter generates follow-up task ID/`syncId` so offline records and server side effects converge |
| Payment promised | Requires promised date; promised amount is optional |
| No-answer follow-up | Tomorrow at the original task time, or 10:00 AM if no original time exists |
| New-order follow-up | Tomorrow at 10:00 AM |
| Notifications | Local only; rescheduled after auth, foreground resume, refresh, and task changes |
| Notification copy | Uses `₹` for user-facing money text |
| Phase boundary | No AI parsing, reports, admin dashboard, advanced insights screen, or release assets |

## Next Step

Smoke Phase 2 on the IQOO: run `make build`, `make up`, `make migrate`, `make health`, then `make run`; create a task, postpone it, complete it, create a call task, tap Call, return to the app, save an outcome, confirm the follow-up appears, verify the People profile Calls tab, relaunch, pull refresh, and allow notifications when Android asks.
