# KajuPilot — Build Roadmap
> *A private business operating system for one cashew trader. Not a SaaS. Not an AI chatbot. A companion and supervisor — built for the way he actually works.*

---

## TABLE OF CONTENTS

1. [Vision & Core Philosophy](#1-vision--core-philosophy)
2. [Design System](#2-design-system)
3. [Tech Stack](#3-tech-stack)
4. [Architecture](#4-architecture)
5. [Database Schema](#5-database-schema)
6. [API Design](#6-api-design)
7. [Screen-by-Screen UI Spec](#7-screen-by-screen-ui-spec)
8. [AI Parser Design](#8-ai-parser-design)
9. [Build Phases](#9-build-phases)
10. [Deployment](#10-deployment)

---

## 1. VISION & CORE PHILOSOPHY

### What This Is

A private, local-first Android app for a cashew commodity trader. It replaces his paper notebook, WhatsApp reminders to himself, and mental load. It remembers every deal, every promise, every pending rupee — and pushes him through the day like a smart business partner who also happens to work 24/7 for free.

### The Three Flows That Matter

Everything else is secondary to getting these three right:

```
NIGHT DUMP          MORNING CHECK         AFTER-CALL CAPTURE
──────────────      ─────────────         ──────────────────
He types in         Today screen          One tap logs what
plain language      shows everything      happened on a call.
tomorrow's plan.    sorted and ready.     App updates state.
AI extracts it.     He just executes.     No form to fill.
```

### Core Principles

| Principle | What It Means In Practice |
|-----------|---------------------------|
| **Local-first** | Works offline. Syncs when internet available. Zero loading spinners for basic CRUD. |
| **UI-first, AI-under-the-hood** | Every AI action is also doable by tapping in the UI. AI is a shortcut, never a dependency. |
| **Two paths for everything** | Type plain text → AI fills the form. OR tap the form manually. Same result. |
| **Supervisor, not tracker** | Pushes him through his day. Reminds. Escalates. Tells him who to call first. |
| **Zero clutter** | If a feature doesn't make him money faster, it doesn't exist. |
| **Your visibility** | Everything he does is logged server-side. You have full admin access. |

### What This Is NOT

- Not a chatbot. He never has a conversation with the AI.
- Not a SaaS product. One user, one APK, your VPS, done.
- Not a bank aggregation app. All money entry is manual.
- Not a generic finance tracker. It knows about cashew grades, delivery cycles, buyer behavior.

---

## 2. DESIGN SYSTEM

> Design philosophy: **Calm Commerce** — the quiet confidence of a trader who knows his numbers cold. Like a premium commodity terminal crossed with the restraint of Apple Notes. Not corporate. Not flashy. Just sharp.

### 2.1 Color Palette

The accent color is **warm amber-gold** — the color of a cashew. It ties the entire visual identity to the trade without being gimmicky.

#### Dark Mode (Primary)

| Token | Hex | Usage |
|-------|-----|-------|
| `bg-base` | `#0B0B10` | App-level background |
| `bg-surface` | `#13131C` | Screen backgrounds |
| `bg-card` | `#1A1A26` | Cards, tiles |
| `bg-elevated` | `#22223A` | Bottom sheets, modals, overlays |
| `border-subtle` | `#28283C` | Dividers, card outlines |
| `border-medium` | `#36366A` | Input focus, separators |
| `accent` | `#C8873A` | Primary CTA, highlights, active tab |
| `accent-muted` | `rgba(200,135,58,0.12)` | Tag backgrounds, glow halos |
| `accent-dim` | `#7A5020` | Pressed state on accent |
| `text-primary` | `#EEEEF4` | Headlines, primary labels |
| `text-secondary` | `#7878A0` | Subtext, captions, helper text |
| `text-muted` | `#46466A` | Placeholders, disabled |
| `success` | `#34D399` | Money received, completed, paid |
| `success-muted` | `rgba(52,211,153,0.12)` | Success chip background |
| `warning` | `#FBBF24` | Pending, due soon, upcoming |
| `warning-muted` | `rgba(251,191,36,0.12)` | Warning chip background |
| `danger` | `#F87171` | Overdue, critical, delete |
| `danger-muted` | `rgba(248,113,113,0.12)` | Danger chip background |
| `info` | `#60A5FA` | Informational, neutral tags |

#### Light Mode

| Token | Hex | Usage |
|-------|-----|-------|
| `bg-base` | `#F3F2ED` | Warm off-white — not pure white, never glaring |
| `bg-surface` | `#FAFAF7` | Screen backgrounds |
| `bg-card` | `#FFFFFF` | Cards with shadow |
| `bg-elevated` | `#F6F5F0` | Bottom sheets |
| `border-subtle` | `#E6E5DE` | Dividers |
| `border-medium` | `#D0CFC4` | Input borders |
| `accent` | `#B5692A` | Darker amber for light-bg contrast |
| `text-primary` | `#18181E` | |
| `text-secondary` | `#636380` | |
| `text-muted` | `#9898B8` | |
| `success` | `#059669` | |
| `warning` | `#D97706` | |
| `danger` | `#DC2626` | |

**Light mode cards**: `box-shadow: 0 2px 12px rgba(0,0,0,0.06)`. Dark mode: no shadow, use `border-subtle` border instead.

### 2.2 Typography

**Primary font**: `Plus Jakarta Sans` — slightly rounded, modern, confident. Not Inter (too generic). Not Roboto (too Android-y). Jakarta Sans sits at the intersection of premium and readable.

**Mono font**: `JetBrains Mono` — all currency amounts and numbers. Makes money feel precise and real.

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1  # Plus Jakarta Sans
  # JetBrains Mono via flutter_local asset or google_fonts
```

| Style Name | Font | Weight | Size | Letter Spacing | Usage |
|------------|------|--------|------|----------------|-------|
| `displayLarge` | Plus Jakarta Sans | 700 | 32sp | -0.5 | Screen titles |
| `headlineMedium` | Plus Jakarta Sans | 600 | 24sp | -0.3 | Section headers |
| `titleLarge` | Plus Jakarta Sans | 600 | 18sp | -0.2 | Card titles |
| `titleMedium` | Plus Jakarta Sans | 600 | 16sp | 0 | List titles |
| `bodyLarge` | Plus Jakarta Sans | 400 | 16sp | 0 | Primary body text |
| `bodyMedium` | Plus Jakarta Sans | 400 | 14sp | 0 | Secondary body |
| `labelSmall` | Plus Jakarta Sans | 500 | 11sp | +0.5 | Chips, badges |
| `amountXL` | JetBrains Mono | 700 | 32sp | -1 | Hero amount displays |
| `amountLarge` | JetBrains Mono | 700 | 24sp | -0.5 | Summary totals |
| `amountMedium` | JetBrains Mono | 600 | 18sp | 0 | Card amounts |
| `amountSmall` | JetBrains Mono | 500 | 14sp | 0 | Inline amounts |

### 2.3 Spacing System (4pt grid)

```dart
class KajuSpacing {
  static const double xs  = 4;   // tight spacing, icon gaps
  static const double sm  = 8;   // between related elements
  static const double md  = 16;  // standard padding inside cards
  static const double lg  = 24;  // section spacing
  static const double xl  = 32;  // major section breaks
  static const double xxl = 48;  // hero spacing
}
```

### 2.4 Border Radius

```dart
class KajuRadius {
  static const double xs       = 6;   // chips, tags
  static const double sm       = 8;   // small buttons
  static const double md       = 12;  // inputs, small cards
  static const double lg       = 16;  // main cards
  static const double xl       = 20;  // FAB, feature cards
  static const double sheet    = 24;  // top corners of bottom sheets
  static const double full     = 999; // avatars, pill badges
}
```

### 2.5 Core Widget Vocabulary

These are the reusable building blocks. Build them first. Everything else is composed from these.

---

#### `KajuCard`
Standard card container used everywhere.
```
Background: bg-card
Border: 1px solid border-subtle
Border radius: 16px
Padding: 16px
Dark: no shadow | Light: 0 2px 12px rgba(0,0,0,0.06)
```

---

#### `AmountDisplay`
Every rupee amount in the app.
```
Font: JetBrains Mono
Always prefixed with ₹
Positive/received → success color
Pending (has due date, not overdue) → warning color
Overdue → danger color
Neutral → text-primary
Indian number formatting: 1,00,000 not 100,000
```

```dart
// intl package
final formatter = NumberFormat('#,##,###', 'en_IN');
String formatINR(double amount) => '₹${formatter.format(amount)}';
```

---

#### `StatusBadge`
Small pill badge for deal/task status.

| Status | Background | Text |
|--------|------------|------|
| Quoted | info-muted | info |
| Confirmed | warning-muted | warning |
| Delivered | accent-muted | accent |
| Paid | success-muted | success |
| Overdue | danger-muted | danger |
| Pending | warning-muted | warning |
| Done | success-muted | success |

---

#### `PersonAvatar`
40px circle. Background: accent-muted. Text: accent color. First 2 characters of name, capitalized.

---

#### `KajuActionButton`
The "Call" button on task cards.
```
Background: accent
Icon: phone icon
Label: "Call"
Tap action: url_launcher → tel:+91XXXXXXXXXX
```

---

#### `OutcomeSheet`
Bottom sheet that appears after a call.
```
Title: "How did it go with [Name]?"
Buttons (2x2 grid):
  Payment promised | New order
  No answer        | Delivery update
  Not interested   | Other
Optional text field: "Add note..."
Primary button: Save
```

---

#### `UniversalInputBar`
Fixed bar above bottom nav on all screens.
```
Height: 56px
Background: bg-elevated
Border radius: 12px (inside a 12px padded container)
Left icon: spark/AI icon (accent color)
Placeholder: "Sold 50kg W320 to Amit at ₹780..."
Right icon: mic (opens Gboard voice → natively via TextInput)
Tap anywhere → expands to ParseSheet (full-height bottom sheet)
```

---

### 2.6 Motion & Interaction

```
Standard transitions:     200ms ease-out
Bottom sheet reveal:      280ms cubic-bezier(0.32, 0.72, 0, 1)
Card insertion:           AnimatedList with 300ms slide+fade
Outcome button press:     80ms scale-down (0.95) → release
Loading shimmer:          1200ms looping gradient sweep
Haptic feedback:          HapticFeedback.lightImpact() on Done/Confirm
```

No gratuitous animation. Every motion communicates state change, not decoration.

---

## 3. TECH STACK

### Flutter App (Android APK → future Windows EXE)

| Concern | Package | Why |
|---------|---------|-----|
| State management | `flutter_riverpod` | Clean, testable, no boilerplate hell |
| Navigation | `go_router` | Type-safe, deep-link ready |
| Local database | `drift` | Type-safe SQLite, reactive queries |
| HTTP client | `dio` | Interceptors for auth token injection |
| Fonts | `google_fonts` | Plus Jakarta Sans |
| Local notifications | `flutter_local_notifications` | Reminders, call nudges |
| Secure storage | `flutter_secure_storage` | Device token storage |
| Theme persistence | `adaptive_theme` | Dark/light, persisted |
| Charts | `fl_chart` | Expense donut, trends |
| Number formatting | `intl` | Indian number system (lakhs) |
| URL launcher | `url_launcher` | tel: for calls, wa.me for WhatsApp |
| Icons | `phosphor_flutter` | Consistent, clean icon set |
| Shimmer loading | `shimmer` | Skeleton loaders |

### Backend (Oracle VPS)

| Concern | Tech | Why |
|---------|------|-----|
| Runtime | Node.js 20 LTS | Stable, well-supported |
| Framework | NestJS | Modules, DI, validation built-in |
| ORM | Prisma | Type-safe, migrations from day 1 |
| Database | PostgreSQL 16 | Reliable, JSON support, full SQL |
| Cache + Jobs | Redis + BullMQ | Cron for daily insights, retry logic |
| AI | Groq SDK (`groq-sdk`) | Fast, free-tier Llama 3.1/3.3 |
| Server | Caddy v2 | Auto HTTPS, single config file |
| Containers | Docker Compose | One command deploy, zero server config |

### Admin Dashboard

| Concern | Tech |
|---------|------|
| Framework | Next.js 14 (App Router) |
| UI components | shadcn/ui |
| Styling | Tailwind CSS |
| Charts | Recharts |
| Auth | Same JWT, `role: admin` guard |

---

## 4. ARCHITECTURE

### 4.1 System Diagram

```
┌─────────────────────────────────────────┐
│              His Android Phone          │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │   Flutter App (APK)              │   │
│  │   Riverpod + GoRouter + Drift    │   │
│  │   Local SQLite (offline-first)   │   │
│  └──────────────┬───────────────────┘   │
└─────────────────┼───────────────────────┘
                  │ HTTPS REST (Dio)
                  │ (sync in background)
┌─────────────────┼───────────────────────┐
│   Oracle VPS    │                       │
│                 ▼                       │
│  ┌──────────────────────┐               │
│  │   NestJS API         │               │
│  │   Port 3000          │               │
│  └──────┬───────┬───────┘               │
│         │       │                       │
│    ┌────▼─┐  ┌──▼────┐                  │
│    │  PG  │  │ Redis │  ──→ Groq API    │
│    │  16  │  │BullMQ │                  │
│    └──────┘  └───────┘                  │
│                                         │
│  ┌──────────────────────┐               │
│  │  Next.js Admin Panel │               │
│  │  Port 3001           │               │
│  └──────────────────────┘               │
│                                         │
│  ┌──────────────────────┐               │
│  │  Caddy (reverse proxy│               │
│  │  + auto HTTPS)       │               │
│  └──────────────────────┘               │
└─────────────────────────────────────────┘
```

### 4.2 Local-First Sync Strategy

**Rule**: Every write hits local Drift SQLite first. UI updates immediately. Background sync follows.

```
User action (add deal / mark paid / log call)
  │
  ▼
Write to local Drift SQLite (instant)
  │
  ▼
UI updates reactively via Riverpod stream
  │
  ▼
Background sync queue (isolated Isolate)
  │
  ├── Has internet? → POST to API with sync_id (UUID)
  │                   Backend upserts on sync_id (idempotent)
  │
  └── No internet? → Queue in local pending_sync table
                      Retry when connectivity returns
```

**Conflict resolution**: last-write-wins. Acceptable for single user — no multi-device race conditions.

**sync_id**: client-generated UUID per record. Backend does `INSERT ... ON CONFLICT (sync_id) DO UPDATE`. This means no duplicate records even if the same payload is sent twice.

### 4.3 Flutter Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── colors.dart          # All color tokens as ThemeExtension
│   │   ├── typography.dart      # TextTheme with Jakarta Sans + JetBrains Mono
│   │   ├── spacing.dart         # KajuSpacing constants
│   │   └── app_theme.dart       # ThemeData light + dark
│   ├── router/
│   │   └── router.dart          # GoRouter config, all routes
│   ├── di/
│   │   └── providers.dart       # Riverpod global providers (repo, db, api)
│   ├── db/
│   │   ├── app_database.dart    # Drift DB definition
│   │   ├── tables/              # One file per table
│   │   └── daos/                # Data access objects per feature
│   ├── network/
│   │   ├── api_client.dart      # Dio client with auth interceptor
│   │   └── endpoints.dart       # All API path constants
│   └── utils/
│       ├── currency.dart        # ₹ formatting, Indian number system
│       ├── date.dart            # Relative dates, IST helpers
│       └── fuzzy.dart           # Simple fuzzy name matching for AI parser
│
├── features/
│   ├── today/
│   │   ├── today_screen.dart
│   │   ├── task_card.dart
│   │   ├── outcome_sheet.dart   # After-call capture
│   │   └── today_provider.dart  # Riverpod: today's tasks, stats
│   │
│   ├── money/
│   │   ├── money_screen.dart
│   │   ├── ledger_tab.dart      # Receivable / Payable list
│   │   ├── expenses_tab.dart    # Expense list + chart
│   │   ├── add_payment_sheet.dart
│   │   ├── add_expense_sheet.dart
│   │   └── money_provider.dart
│   │
│   ├── deals/
│   │   ├── deals_screen.dart
│   │   ├── deal_card.dart
│   │   ├── deal_detail_sheet.dart
│   │   ├── add_deal_sheet.dart
│   │   └── deals_provider.dart
│   │
│   ├── people/
│   │   ├── people_screen.dart
│   │   ├── person_card.dart
│   │   ├── person_profile_screen.dart
│   │   ├── add_person_sheet.dart
│   │   └── people_provider.dart
│   │
│   ├── input/
│   │   ├── universal_input_bar.dart   # The persistent bottom input
│   │   ├── parse_sheet.dart           # Full-height input + AI preview
│   │   ├── preview_item_card.dart     # One parsed item in preview
│   │   └── input_provider.dart        # Parse state, Groq integration
│   │
│   ├── insights/
│   │   ├── insights_screen.dart
│   │   ├── ai_summary_card.dart
│   │   ├── weekly_report_card.dart
│   │   ├── people_insights_card.dart
│   │   ├── expense_chart.dart
│   │   └── insights_provider.dart
│   │
│   └── settings/
│       ├── settings_screen.dart
│       └── theme_toggle.dart
│
├── shared/
│   ├── widgets/
│   │   ├── kaju_card.dart
│   │   ├── amount_display.dart
│   │   ├── status_badge.dart
│   │   ├── person_avatar.dart
│   │   ├── kaju_action_button.dart
│   │   ├── skeleton_loader.dart
│   │   └── empty_state.dart
│   └── models/                  # Pure Dart models (not Drift tables)
│       ├── party.dart
│       ├── deal.dart
│       ├── payment.dart
│       └── task.dart
│
└── main.dart
```

### 4.4 Backend Project Structure

```
src/
├── auth/
│   ├── auth.module.ts
│   ├── auth.service.ts
│   ├── device-token.strategy.ts   # Validates Bearer token
│   └── roles.guard.ts             # owner | admin
│
├── parties/
│   ├── parties.module.ts
│   ├── parties.controller.ts
│   ├── parties.service.ts
│   └── dto/
│
├── deals/
│   ├── deals.module.ts
│   ├── deals.controller.ts
│   ├── deals.service.ts           # Includes total_amount computation
│   └── dto/
│
├── payments/
│   ├── payments.module.ts
│   ├── payments.controller.ts
│   ├── payments.service.ts        # Ledger aggregation here
│   └── dto/
│
├── expenses/
│   └── ...
│
├── tasks/
│   ├── tasks.module.ts
│   ├── tasks.controller.ts
│   ├── tasks.service.ts           # Priority sorting, today filter
│   └── dto/
│
├── call-logs/
│   ├── call-logs.module.ts
│   ├── call-logs.controller.ts
│   ├── call-logs.service.ts       # After-call auto-actions (next task, deal update)
│   └── dto/
│
├── ai/
│   ├── ai.module.ts
│   ├── ai.controller.ts
│   ├── ai.service.ts              # Groq calls, parse, confirm
│   ├── parse-logs.service.ts      # Logs all AI interactions
│   └── prompts/
│       ├── parser.prompt.ts       # System prompt for 8b parsing
│       └── insights.prompt.ts     # System prompt for 70b insights
│
├── insights/
│   ├── insights.module.ts
│   ├── insights.controller.ts
│   └── insights.service.ts        # Aggregation SQL, daily summary generation
│
├── sync/
│   └── sync.service.ts            # Handles sync_id deduplication
│
├── admin/
│   ├── admin.module.ts
│   ├── admin.controller.ts        # Protected by roles.guard (admin only)
│   └── admin.service.ts
│
├── scheduler/
│   └── daily-insights.cron.ts     # BullMQ job: 7AM IST → generate AI summary
│
├── prisma/
│   ├── schema.prisma
│   └── migrations/
│
└── main.ts
```

---

## 5. DATABASE SCHEMA

**Global conventions:**
- All PKs: `UUID` (generated by client for offline-first sync)
- All tables: `created_at`, `updated_at` auto-managed by Prisma
- Soft deletes: `deleted_at` nullable timestamp — never hard delete business data
- All monetary values: `Decimal(14,2)` — avoids float precision bugs with money

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ────────────────────────────────
// USERS
// ────────────────────────────────
model User {
  id            String    @id @default(uuid())
  name          String
  businessName  String?
  deviceToken   String    @unique  // The APK auth token
  role          Role      @default(OWNER)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  parties       Party[]
  deals         Deal[]
  payments      Payment[]
  expenses      Expense[]
  tasks         Task[]
  callLogs      CallLog[]
  aiParseLogs   AiParseLog[]
}

enum Role {
  OWNER
  ADMIN
}

// ────────────────────────────────
// PARTIES (Customers / Suppliers)
// ────────────────────────────────
model Party {
  id          String      @id @default(uuid())
  userId      String
  user        User        @relation(fields: [userId], references: [id])
  name        String
  phone       String?
  type        PartyType   @default(CUSTOMER)
  trustTag    TrustTag    @default(NEW)
  notes       String?
  syncId      String      @unique  // Client-generated UUID
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  deletedAt   DateTime?

  deals       Deal[]
  payments    Payment[]
  tasks       Task[]
  callLogs    CallLog[]

  @@index([userId, deletedAt])
}

enum PartyType {
  CUSTOMER
  SUPPLIER
  BOTH
}

enum TrustTag {
  RELIABLE
  SLOW_PAYER
  RISKY
  NEW
}

// ────────────────────────────────
// DEALS (Sales + Purchases)
// ────────────────────────────────
model Deal {
  id             String      @id @default(uuid())
  userId         String
  user           User        @relation(fields: [userId], references: [id])
  partyId        String
  party          Party       @relation(fields: [partyId], references: [id])
  type           DealType    @default(SALE)
  cashewGrade    String      // W320, W240, W180, broken, split, etc.
  quantityKg     Decimal     @db.Decimal(10, 2)
  ratePerKg      Decimal     @db.Decimal(10, 2)
  totalAmount    Decimal     @db.Decimal(14, 2)  // quantityKg * ratePerKg
  paidAmount     Decimal     @db.Decimal(14, 2)  @default(0)
  status         DealStatus  @default(CONFIRMED)
  deliveryDate   DateTime?
  paymentDue     DateTime?
  notes          String?
  syncId         String      @unique
  createdAt      DateTime    @default(now())
  updatedAt      DateTime    @updatedAt
  deletedAt      DateTime?

  payments       Payment[]

  @@index([userId, status, deletedAt])
  @@index([partyId, deletedAt])
  @@index([paymentDue])
}

enum DealType {
  SALE
  PURCHASE
}

enum DealStatus {
  QUOTED
  CONFIRMED
  DELIVERED
  PAID
}

// ────────────────────────────────
// PAYMENTS (Money In / Out)
// ────────────────────────────────
model Payment {
  id           String      @id @default(uuid())
  userId       String
  user         User        @relation(fields: [userId], references: [id])
  partyId      String
  party        Party       @relation(fields: [partyId], references: [id])
  dealId       String?     // nullable: payment may not link to a specific deal
  deal         Deal?       @relation(fields: [dealId], references: [id])
  type         PaymentType
  amount       Decimal     @db.Decimal(14, 2)
  method       String?     // cash, UPI, NEFT, cheque
  notes        String?
  paymentDate  DateTime
  syncId       String      @unique
  createdAt    DateTime    @default(now())
  updatedAt    DateTime    @updatedAt
  deletedAt    DateTime?

  @@index([userId, paymentDate, deletedAt])
  @@index([partyId, deletedAt])
}

enum PaymentType {
  RECEIVED   // Money coming in from customer
  PAID       // Money going out to supplier
}

// ────────────────────────────────
// EXPENSES (Business Costs)
// ────────────────────────────────
model Expense {
  id           String          @id @default(uuid())
  userId       String
  user         User            @relation(fields: [userId], references: [id])
  category     ExpenseCategory
  amount       Decimal         @db.Decimal(14, 2)
  notes        String?
  expenseDate  DateTime
  syncId       String          @unique
  createdAt    DateTime        @default(now())
  updatedAt    DateTime        @updatedAt
  deletedAt    DateTime?

  @@index([userId, expenseDate, deletedAt])
}

enum ExpenseCategory {
  TRANSPORT
  LABOUR
  PACKAGING
  BROKER_COMMISSION
  STOCK_PURCHASE
  OTHER
}

// ────────────────────────────────
// TASKS (Calls / Deliveries / Reminders)
// ────────────────────────────────
model Task {
  id            String      @id @default(uuid())
  userId        String
  user          User        @relation(fields: [userId], references: [id])
  partyId       String?
  party         Party?      @relation(fields: [partyId], references: [id])
  type          TaskType
  title         String
  notes         String?
  scheduledAt   DateTime
  completedAt   DateTime?
  status        TaskStatus  @default(PENDING)
  priority      Int         @default(0)  // higher = show first on Today
  syncId        String      @unique
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt
  deletedAt     DateTime?

  callLogs      CallLog[]

  @@index([userId, scheduledAt, deletedAt])
  @@index([userId, status, deletedAt])
}

enum TaskType {
  CALL
  DELIVERY
  PAYMENT_COLLECTION
  REMINDER
  OTHER
}

enum TaskStatus {
  PENDING
  DONE
  POSTPONED
  CANCELLED
}

// ────────────────────────────────
// CALL LOGS (After-Call Capture)
// ────────────────────────────────
model CallLog {
  id              String        @id @default(uuid())
  userId          String
  user            User          @relation(fields: [userId], references: [id])
  taskId          String?
  task            Task?         @relation(fields: [taskId], references: [id])
  partyId         String?
  party           Party?        @relation(fields: [partyId], references: [id])
  outcome         CallOutcome
  notes           String?
  promisedDate    DateTime?     // if payment promised
  promisedAmount  Decimal?      @db.Decimal(14, 2)
  nextFollowup    DateTime?     // auto-created next task from this outcome
  syncId          String        @unique
  createdAt       DateTime      @default(now())
}

enum CallOutcome {
  PAYMENT_PROMISED
  NEW_ORDER
  NO_ANSWER
  NOT_INTERESTED
  DELIVERY_UPDATE
  OTHER
}

// ────────────────────────────────
// AI PARSE LOGS (Every AI Interaction)
// ────────────────────────────────
model AiParseLog {
  id           String    @id @default(uuid())
  userId       String
  user         User      @relation(fields: [userId], references: [id])
  rawInput     String    // exactly what he typed
  parsedJson   Json      // exactly what Groq returned
  confirmed    Boolean   @default(false)
  confirmedAt  DateTime?
  createdAt    DateTime  @default(now())

  @@index([userId, createdAt])
}
```

### Key Indexes (raw SQL for documentation)

```sql
-- Fast today screen load
CREATE INDEX idx_tasks_today ON tasks(user_id, scheduled_at, deleted_at)
  WHERE deleted_at IS NULL;

-- Ledger computation speed
CREATE INDEX idx_payments_party_user ON payments(user_id, party_id, deleted_at)
  WHERE deleted_at IS NULL;

-- Deal pending amount queries
CREATE INDEX idx_deals_party_status ON deals(user_id, party_id, status, deleted_at)
  WHERE deleted_at IS NULL;

-- Overdue detection
CREATE INDEX idx_deals_due ON deals(user_id, payment_due)
  WHERE deleted_at IS NULL AND status != 'PAID';
```

---

## 6. API DESIGN

**Base URL**: `https://your-domain-or-ip/api/v1`

**Auth**: All requests require `Authorization: Bearer <device_token>` header.

**Errors**: All errors follow `{ statusCode, message, error }` shape.

**Soft deletes**: All `DELETE` endpoints set `deleted_at`, never remove rows.

**Idempotency**: All `POST` endpoints accept `syncId` in body. Duplicate `syncId` → returns existing record, not an error.

---

### Auth

```
POST /auth/setup     # First launch: { setupCode } → { deviceToken, userId }
GET  /auth/me        # Verify token, return current user info
```

---

### Parties

```
GET    /parties                 ?search=&type=&trustTag=
POST   /parties                 { name, phone, type, trustTag, notes, syncId }
GET    /parties/:id             → party + computed stats (total deals, avg delay, total pending)
PUT    /parties/:id             { name?, phone?, type?, trustTag?, notes? }
DELETE /parties/:id             soft delete
GET    /parties/:id/history     → paginated list of all deals + payments + callLogs for this party
GET    /parties/:id/ledger      → { receivable, payable, net, overdueAmount, oldestOverdueDate }
```

---

### Deals

```
GET    /deals                   ?status=&partyId=&from=&to=&grade=
POST   /deals                   { partyId, type, cashewGrade, quantityKg, ratePerKg,
                                  paidAmount?, deliveryDate?, paymentDue?, notes?, syncId }
                                → total_amount computed server-side
GET    /deals/:id
PUT    /deals/:id               Partial update any field
PUT    /deals/:id/status        { status } → validates status transitions
DELETE /deals/:id               soft delete
```

---

### Payments

```
GET    /payments                ?partyId=&type=&from=&to=
POST   /payments                { partyId, dealId?, type, amount, method?, notes?,
                                  paymentDate, syncId }
                                → also updates deal.paid_amount if dealId provided
GET    /payments/ledger         → { totalReceivable, totalPayable, net,
                                    overdueParties: [{partyId, name, amount, daysPastDue}] }
DELETE /payments/:id            soft delete
```

---

### Expenses

```
GET    /expenses                ?category=&from=&to=
POST   /expenses                { category, amount, notes?, expenseDate, syncId }
DELETE /expenses/:id            soft delete
GET    /expenses/summary        → { byCategory: {}, total, periodComparison }
```

---

### Tasks

```
GET    /tasks                   ?status=&type=&partyId=&from=&to=
GET    /tasks/today             → sorted by priority DESC, then scheduled_at ASC
POST   /tasks                   { partyId?, type, title, notes?, scheduledAt, priority?, syncId }
PUT    /tasks/:id               Partial update
PUT    /tasks/:id/complete      { } → sets status=DONE, completedAt=now
PUT    /tasks/:id/postpone      { scheduledAt } → updates scheduledAt, status=POSTPONED
DELETE /tasks/:id               soft delete
```

---

### Call Logs

```
POST   /call-logs               { taskId?, partyId?, outcome, notes?, promisedDate?,
                                  promisedAmount?, syncId }

                                Side effects (server-side):
                                - PAYMENT_PROMISED → create Task(type=PAYMENT_COLLECTION,
                                  scheduledAt=promisedDate, partyId=partyId)
                                - NEW_ORDER → create Task(type=CALL, title="Follow up on new order")
                                - NO_ANSWER → create Task(type=CALL, scheduledAt=tomorrow)

GET    /call-logs               ?partyId=&from=&to=
```

---

### AI

```
POST   /ai/parse                { text }
                                → Groq call (llama-3.1-8b-instant)
                                → stores AiParseLog (confirmed=false)
                                → { logId, parsed: { tasks[], deals[], payments[], expenses[] } }

POST   /ai/parse/:logId/confirm { edits? }  # optional manual edits to parsed data
                                → creates all records from parsed JSON
                                → matches party names fuzzy-against DB
                                → returns { created: { taskIds[], dealIds[], paymentIds[], ... } }

GET    /ai/summary/today        → cached (Redis, 1hr TTL) AI-generated today summary text
GET    /ai/insights/weekly      → cached (Redis, 6hr TTL) weekly report text
```

---

### Insights

```
GET    /insights/today          → { pendingCollection, callsDue, deliveriesDue,
                                    overdueCount, topCallsToday: [{partyId, name, reason, amount}] }
GET    /insights/weekly         → { revenue, expenses, profit, dealsCount, newParties,
                                    topBuyers, slowestPayers }
GET    /insights/people         → { topBuyers[], slowPayers[], inactiveCustomers[] }
```

---

### Admin (role: ADMIN only)

```
GET    /admin/users                 All users summary
GET    /admin/users/:id/activity    Full activity log for a user (today / 7d / 30d)
GET    /admin/ai-logs               All AI parse logs (paginated)
GET    /admin/ai-logs/:id           Single log: rawInput + parsedJson + confirmed
GET    /admin/stats                 System-level: total deals today, AI calls today, sync errors
```

---

## 7. SCREEN-BY-SCREEN UI SPEC

### 7.1 App Shell

```
┌─────────────────────────────┐
│  [Screen content area]      │  ← Each feature screen, no shared app bar
│                             │
│                             │
│                             │
│  ┌─────────────────────┐    │
│  │ Universal Input Bar │    │  ← Fixed, always visible
│  └─────────────────────┘    │
├─────────────────────────────┤
│  Today │ Money │ Deals │ People │ More  │  ← Bottom nav
└─────────────────────────────┘
```

**Bottom nav tabs**:
- Today → `House` icon (phosphor)
- Money → `CurrencyInr` icon
- Deals → `Package` icon
- People → `Users` icon
- More → `DotsThree` icon

Active tab: accent color + accent-muted background pill. Inactive: text-secondary.

No heavy top AppBar. Each screen has its own lightweight in-scroll header.

---

### 7.2 TODAY SCREEN

The most important screen. He opens this every morning and it tells him exactly what to do.

```
┌─────────────────────────────────────┐
│  Good morning, Vikram               │  text-secondary, bodyMedium
│  Thursday, June 5                   │  text-primary, displayLarge-ish
│                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────┐ │
│  │₹2.4L    │ │ 6 calls  │ │ 2 del│ │  ← Quick stats chips
│  │to collect│ │planned   │ │today │ │
│  └──────────┘ └──────────┘ └──────┘ │
│                                     │
│  CALLS TODAY ──────────────────      │  section header: text-muted, labelSmall
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ 🔴 OVERDUE · 2 days            │ │  ← red left strip
│  │  [AV] Amit Verma               │ │
│  │       Collect ₹80,000          │ │  amountMedium, danger color
│  │       W320 deal · May 28       │ │  text-muted, bodyMedium
│  │                                │ │
│  │  [Call]  [Done]  [Postpone]    │ │
│  └─────────────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │  [RS] Ramesh Sahu               │ │
│  │       Ask for W240 order        │ │
│  │       Scheduled · 11:00 AM      │ │
│  │                                │ │
│  │  [Call]  [Done]  [Postpone]    │ │
│  └─────────────────────────────────┘ │
│                                     │
│  PAYMENTS DUE ─────────────────────  │
│  ┌─────────────────────────────────┐ │
│  │  [MK] Mahesh Kumar              │ │
│  │       ₹1,20,000 due today       │ │  warning color amount
│  │  [Call]  [View Deal]           │ │
│  └─────────────────────────────────┘ │
│                                     │
│  DELIVERIES DUE ───────────────────  │
│  ...delivery cards...               │
│                                     │
│  TOMORROW (collapsed) ▸             │  tap to expand preview
└─────────────────────────────────────┘
```

**Task card behavior**:
- `[Call]` → `url_launcher`: `tel:+91XXXXXXXXXX` → after dialer dismissed → OutcomeSheet slides up
- `[Done]` → `HapticFeedback.lightImpact()` → card fades out with checkmark
- `[Postpone]` → date/time picker bottom sheet → task updates and re-sorts

**OutcomeSheet** (after call):
```
┌────────────────────────────────────┐
│  ●  How did it go with Amit?       │
│                                    │
│  ┌─────────────┐ ┌───────────────┐ │
│  │💰 Payment   │ │📦 New order   │ │
│  │   promised  │ │               │ │
│  └─────────────┘ └───────────────┘ │
│  ┌─────────────┐ ┌───────────────┐ │
│  │📵 No answer │ │❌ Not interested│ │
│  └─────────────┘ └───────────────┘ │
│  ┌─────────────┐ ┌───────────────┐ │
│  │🚚 Delivery  │ │✏️ Other       │ │
│  │   update    │ │               │ │
│  └─────────────┘ └───────────────┘ │
│                                    │
│  [Add note...]                     │
│                                    │
│  [Save & close]                    │
└────────────────────────────────────┘
```

Server-side auto-actions on outcome:
- `PAYMENT_PROMISED` → creates new Task (PAYMENT_COLLECTION, scheduledAt = promisedDate)
- `NO_ANSWER` → creates follow-up Task (CALL, scheduledAt = tomorrow, same purpose)
- `NEW_ORDER` → creates follow-up Task (CALL, "Follow up on order enquiry")

---

### 7.3 MONEY SCREEN

```
┌─────────────────────────────────────┐
│  Money                              │  titleLarge
│                                     │
│  ┌───────────────────────────────┐  │
│  │  TO RECEIVE          TO PAY   │  │
│  │  ₹3,24,500          ₹48,000  │  │  amountLarge, success / warning
│  │  NET: ₹2,76,500              │  │  amountMedium
│  └───────────────────────────────┘  │
│                                     │
│  [Receivable] [Payable] [Expenses]  │  tab bar
│  ─────── active tab underline ────  │
│                                     │
│  (RECEIVABLE TAB)                   │
│                                     │
│  Filter: [All ▾] [Overdue] [Week]   │  chips
│                                     │
│  ┌─────────────────────────────────┐ │
│  │  [AV] Amit Verma               │ │
│  │       ₹1,40,000 pending  🔴    │ │  danger + overdue badge
│  │       2 deals · Last: May 28   │ │  text-muted
│  │                        [Call]  │ │
│  └─────────────────────────────────┘ │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │  [RS] Ramesh Sahu              │ │
│  │       ₹84,000 pending          │ │  warning
│  │       1 deal · Due: Jun 10     │ │
│  │                        [Call]  │ │
│  └─────────────────────────────────┘ │
│  ...                                │
│                                     │
│                          [+ Add]    │  FAB bottom right
└─────────────────────────────────────┘
```

Tap on a party row → **Party Ledger Detail** (pushed route, not sheet):
```
[← Back]
[AV] Amit Verma
     +91 98765 43210
[Call]  [WhatsApp]         ← wa.me/91... deep link

SUMMARY
Pending:  ₹1,40,000  (danger)
Overdue:  8 days
Avg delay: 6 days
Tag: [Slow Payer]          ← editable, tap to change

TRANSACTION HISTORY (newest first)
  ─── Jun 3 ──────────────────────
  Payment received · ₹42,000
  Method: UPI

  ─── May 28 ─────────────────────
  Deal: W320 · 100kg · ₹780/kg
  Total: ₹78,000 · Paid: ₹0 · Pending: ₹78,000
  Status: [Delivered]

  ─── May 20 ─────────────────────
  Payment received · ₹62,000
  ...
```

---

### 7.4 DEALS SCREEN

```
┌─────────────────────────────────────┐
│  Deals                              │
│                                     │
│  [All] [Quoted] [Confirmed] [Delivered] [Paid]  │  horizontal scroll tabs
│                                     │
│  [🔍 Search by name or grade...]    │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │  [AV] Amit Verma  · W320       │ │  name + grade chip
│  │       100kg · ₹780/kg          │ │  bodyMedium
│  │       Total: ₹78,000           │ │
│  │       Paid: ₹0  Pending: ₹78,000│ │  amountSmall, danger
│  │       Delivery: May 28         │ │  text-muted
│  │       Due: Jun 5  🔴           │ │  overdue badge
│  │       [Delivered]              │ │  status badge
│  └─────────────────────────────────┘ │
│  ...                                │
│                                     │
│                          [+ Deal]   │  FAB
└─────────────────────────────────────┘
```

**Add Deal Sheet** (bottom sheet, not full screen):
```
Party: [Select or type name...]    ← autocomplete against parties table
Type:  [Sale ▾]  [Purchase]
Grade: [W320 ▾]                    ← quick select: W320 W240 W180 broken split
Qty:   [____] kg
Rate:  ₹[____] per kg
Total: ₹ --- (auto-computed live)
Paid:  ₹[____] (optional advance)
Delivery: [Pick date]
Pay due:  [Pick date]
Notes: [...]
[Save Deal]
```

Tap a deal card → **Deal Detail Sheet** (bottom sheet):
Same info, all fields editable inline. Status change button prominent at bottom. Delete at top right.

---

### 7.5 PEOPLE SCREEN

```
┌─────────────────────────────────────┐
│  People                             │
│                                     │
│  [🔍 Search...]                     │
│                                     │
│  [All] [Customers] [Suppliers] [Overdue]  │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │  [AV] Amit Verma               │ │
│  │       Customer · ₹1.4L pending │ │  text-secondary · amountSmall danger
│  │       [Slow Payer]  · 3 deals  │ │  trust badge · deal count
│  └─────────────────────────────────┘ │
│  ┌─────────────────────────────────┐ │
│  │  [RS] Ramesh Sahu              │ │
│  │       Customer · ₹84K pending  │ │
│  │       [Reliable]  · 7 deals    │ │
│  └─────────────────────────────────┘ │
│  ...                                │
│                          [+ Person] │
└─────────────────────────────────────┘
```

Tap → **Person Profile** (full screen push):
```
← [Back]

[AV]  Amit Verma                 [Edit]
      Customer
      +91 98765 43210
[📞 Call]  [💬 WhatsApp]

────────────────────────────────
  3 deals     ₹3.2L total     6d avg delay
────────────────────────────────

TRUST TAG
[Reliable ▾] [Slow Payer ▾] [Risky ▾] [New ▾]   ← tap to change

[Deals] [Payments] [Calls] [Notes]     tab bar

(DEALS TAB)
  ...all deals with this person...

(CALLS TAB)
  Jun 3 · Payment promised · ₹80,000 by Jun 10
  May 29 · No answer · Follow-up set for May 30
  ...

(NOTES TAB)
  Free text, editable, saved instantly
  "Prefers W320 grade. Usually pays in 5-7 days."
```

---

### 7.6 UNIVERSAL INPUT SHEET (Parse Sheet)

Triggered by tapping the Universal Input Bar. Expands as a full-height bottom sheet.

```
┌─────────────────────────────────────┐
│    ──── [drag handle] ────          │
│                                     │
│  What's happening?                  │  titleLarge, text-secondary
│                                     │
│  ┌─────────────────────────────────┐ │
│  │                                │ │
│  │  Tomorrow call Amit for 80k    │ │  ← multiline, Gboard-compatible
│  │  payment, check on Ramesh for  │ │    fontSize 17, plus Jakarta Sans
│  │  new W240 order, delivery to   │ │
│  │  Suresh by 4pm                 │ │
│  │                                │ │
│  │                          [🎤]  │ │  ← mic = focus text field = triggers Gboard voice
│  └─────────────────────────────────┘ │
│                                     │
│  [Parse →]                          │  accent filled button
│                                     │
│  ── OR ADD MANUALLY ──              │  text-muted, labelSmall
│  [Add Sale] [Payment] [Expense] [Call]  │
│                                     │
│  ════════════════════════════════   │  (shown after parsing)
│  PREVIEW                           │
│                                     │
│  ┌────────────────────────────────┐ │
│  │ 📞 Call reminder               │ │  ← parsed item card
│  │    Amit Verma                  │ │  matches existing party
│  │    Collect ₹80,000             │ │
│  │    Tomorrow                    │ │
│  │                    [Edit] [✕]  │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌────────────────────────────────┐ │
│  │ 📞 Call reminder               │ │
│  │    Ramesh Sahu                 │ │
│  │    W240 order enquiry          │ │
│  │    Tomorrow                    │ │
│  │                    [Edit] [✕]  │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌────────────────────────────────┐ │
│  │ 🚚 Delivery                   │ │
│  │    Suresh Patel  (new contact) │ │  ← warns: "new, will be created"
│  │    Today · 4:00 PM             │ │
│  │                    [Edit] [✕]  │ │
│  └────────────────────────────────┘ │
│                                     │
│  [✓ Confirm All]                    │  accent button, full width
└─────────────────────────────────────┘
```

**States**:
- Empty → shows prompt + manual add buttons
- Typing → just the text area
- Loading (Groq call) → skeleton shimmer on 3 preview card slots
- Preview → parsed items + Confirm All
- Error → "Couldn't parse. Add manually?" + keep text in field

---

### 7.7 INSIGHTS SCREEN (in More tab)

```
┌─────────────────────────────────────┐
│  Insights                           │
│                                     │
│  TODAY                              │  section header
│  ┌─────────────────────────────────┐ │
│  │ ✦  AI Summary                  │ │  accent-muted background card
│  │    ₹2.4L is pending. Call Amit │ │
│  │    first — ₹1.4L is overdue 8  │ │
│  │    days. Ramesh hasn't ordered │ │
│  │    in 3 weeks, check in today. │ │
│  │                                │ │
│  │    Generated 7:02 AM           │ │  text-muted, labelSmall
│  └─────────────────────────────────┘ │
│                                     │
│  THIS WEEK                          │
│  ┌─────────────────────────────────┐ │
│  │  Revenue      ₹4,82,000        │ │
│  │  Expenses     ₹38,500          │ │
│  │  Est. Profit  ₹4,43,500        │ │
│  │  Deals closed  7               │ │
│  │  New parties   2               │ │
│  └─────────────────────────────────┘ │
│                                     │
│  TOP BUYERS (June)                  │
│  1. Amit Verma      ₹3,20,000      │
│  2. Ramesh Sahu     ₹2,10,000      │
│  3. Suresh Patel    ₹1,40,000      │
│                                     │
│  SLOWEST PAYERS                     │
│  Mahesh Kumar    avg 12 days delay  │  danger color on days
│  Vijay Tiwari    avg 8 days delay   │
│                                     │
│  EXPENSES THIS MONTH                │
│  ┌──────────────────────────────┐   │
│  │  [Donut chart: fl_chart]     │   │  transport/labour/packaging/etc.
│  │  Transport: 14%   ₹12,400   │   │
│  │  Labour:    8%    ₹7,000    │   │
│  └──────────────────────────────┘   │
│                                     │
│  AI TIPS                            │
│  ┌─────────────────────────────────┐ │
│  │ "Transport cost is 14% of rev  │ │
│  │  this month, up from 9% last." │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

### 7.8 EMPTY STATES

Every list screen needs a proper empty state. Not just "No data".

| Screen | Empty State |
|--------|-------------|
| Today | "Nothing on the agenda. Add tomorrow's calls above ↑" |
| Money (receivable) | "Everyone's paid up. Nice." |
| Deals | "No deals yet. Add your first one." |
| People | "No contacts yet. Add a customer or supplier." |
| Insights | "Not enough data yet. Start adding deals and payments." |

Each empty state has a simple illustration (SVG icon) in accent-muted color.

---

## 8. AI PARSER DESIGN

### 8.1 Parser Prompt (llama-3.1-8b-instant — fast, free tier)

```typescript
// src/ai/prompts/parser.prompt.ts

export const PARSER_SYSTEM_PROMPT = `
You are a data extractor for an Indian cashew commodity trader's business app.
Your job: extract structured data from his plain-language notes.
Output ONLY valid JSON. No preamble. No explanation. No markdown. No backticks.

DOMAIN KNOWLEDGE:
- Cashew grades: W180, W210, W240, W320, W450, broken, split, whole
- "k" = thousands (80k = 80000)
- Currency is always INR (Indian Rupees)
- Business parties are customers or suppliers (not family/personal)
- "tomorrow" → output "tomorrow", "today" → output "today"
- Unclear dates → null
- People mentioned without context are assumed to be customers
- "collect from X" = payment receivable from customer X
- "pay to X" = payment payable to supplier X

OUTPUT FORMAT (strict):
{
  "tasks": [
    {
      "type": "call" | "delivery" | "payment_collection" | "reminder",
      "personName": "string",
      "purpose": "string (one clear sentence)",
      "amount": number | null,
      "scheduled": "today" | "tomorrow" | "YYYY-MM-DD" | null,
      "scheduledTime": "HH:MM" | null,
      "notes": "string" | null
    }
  ],
  "deals": [
    {
      "type": "sale" | "purchase",
      "personName": "string",
      "cashewGrade": "string" | null,
      "quantityKg": number | null,
      "ratePerKg": number | null,
      "totalAmount": number | null,
      "paidAmount": number | null,
      "deliveryDate": "YYYY-MM-DD" | null,
      "paymentDue": "YYYY-MM-DD" | null,
      "notes": "string" | null
    }
  ],
  "payments": [
    {
      "type": "received" | "paid",
      "personName": "string",
      "amount": number,
      "notes": "string" | null
    }
  ],
  "expenses": [
    {
      "category": "transport" | "labour" | "packaging" | "broker_commission" | "other",
      "amount": number,
      "notes": "string" | null
    }
  ]
}

If nothing is extractable for a category, return an empty array [].
Today's date is: ${new Date().toISOString().split('T')[0]}
`;
```

### 8.2 Insights Prompt (llama-3.3-70b-versatile — used once per day max)

```typescript
// src/ai/prompts/insights.prompt.ts

export const INSIGHTS_SYSTEM_PROMPT = `
You are a sharp business advisor for an Indian cashew commodity trader.
Analyze the provided business data and return 3-5 actionable insights.

Rules:
- Be direct. No fluff.
- Focus on money and action.
- Speak like a smart business partner, not a finance app.
- Use Indian number formatting mentions (lakhs, not millions).
- Prioritize overdue money, inactive customers, rising costs.
- Suggest specific people to call, not generic advice.

Output ONLY valid JSON:
{ "insights": ["string", "string", ...] }

No preamble. No backticks. No markdown.
`;
```

### 8.3 Full Parse → Confirm Flow

```
1. User types in ParseSheet
2. Taps [Parse →]
3. Flutter: POST /ai/parse { text: "..." }

4. NestJS AiService:
   a. Call Groq (llama-3.1-8b-instant, max_tokens: 800)
   b. Parse response JSON (try-catch, return error if invalid)
   c. Store AiParseLog { rawInput, parsedJson, confirmed: false }
   d. Return { logId, parsed }

5. Flutter: Render preview cards (one per task/deal/payment/expense)

6. User can:
   a. Delete individual items (tap ✕)
   b. Edit individual items (tap Edit → inline form in card)
   c. Tap [Confirm All]

7. Flutter: POST /ai/parse/:logId/confirm { edits: [...modified items] }

8. NestJS confirm flow:
   a. Fuzzy-match personName against parties table (Levenshtein distance ≤ 2)
   b. If match → link to existing party
   c. If no match → auto-create party { name: personName, type: CUSTOMER }
   d. Create all records (tasks, deals, payments, expenses)
   e. Update AiParseLog { confirmed: true, confirmedAt: now }
   f. Return { created: { ... ids ... } }

9. Flutter: Close sheet, navigate to Today screen, show "X items added" snackbar
```

### 8.4 Fuzzy Party Matching (Server-Side)

```typescript
// Simple fuzzy match — no external lib needed
function levenshtein(a: string, b: string): number {
  // standard implementation
}

async matchParty(name: string, userId: string): Promise<Party | null> {
  const parties = await prisma.party.findMany({
    where: { userId, deletedAt: null }
  });
  
  const normalized = name.toLowerCase().trim();
  
  // Exact match first
  const exact = parties.find(p => 
    p.name.toLowerCase() === normalized
  );
  if (exact) return exact;
  
  // Fuzzy: distance ≤ 2 (handles "Amit" matching "Amit Verma")
  const fuzzy = parties.find(p => 
    levenshtein(p.name.toLowerCase(), normalized) <= 2 ||
    p.name.toLowerCase().startsWith(normalized) ||
    normalized.startsWith(p.name.toLowerCase().split(' ')[0])
  );
  
  return fuzzy || null;  // null = create new party
}
```

### 8.5 Error Handling

| Failure | Behavior |
|---------|----------|
| Groq returns invalid JSON | Return `{ error: "parse_failed" }` → Flutter shows "Couldn't parse, add manually" |
| Groq rate limit hit | Return `{ error: "rate_limited" }` → Flutter shows manual add options |
| Network timeout (>8s) | Dio timeout → show "No internet? Add manually" |
| Party not found | Auto-create with name from input, tag as `NEW` |
| Amount in wrong currency | Parser handles "lakh" → 100000, "k" → 1000 |

---

## 9. BUILD PHASES

### PHASE 0 — Foundation (Week 1)
*Goal: Everything boots. Blank app + backend running on Oracle VPS.*

#### Infrastructure
- [ ] Open ports on Oracle VPS: 80, 443 (public), 5432 and 6379 (internal only)
- [ ] Install Docker + Docker Compose on VPS
- [ ] Write `docker-compose.yml` (PostgreSQL 16, Redis 7, NestJS, Caddy, Next.js admin)
- [ ] Point domain or use raw IP with Caddy
- [ ] Create `.env` file: `DB_PASSWORD`, `GROQ_API_KEY`, `JWT_SECRET`, `ADMIN_SETUP_CODE`
- [ ] `docker compose up -d` → all services healthy
- [ ] Test: `curl https://your-domain/api/v1/health` → `{ status: "ok" }`

#### Backend
- [ ] `nest new kajupilot-api`
- [ ] Install: `prisma`, `@prisma/client`, `@groq-sdk/node`, `bullmq`, `ioredis`, `passport-jwt`
- [ ] Write `schema.prisma` (all tables from Section 5)
- [ ] Run `prisma migrate dev --name init`
- [ ] Auth module: device token strategy (JWT verify), roles guard
- [ ] `GET /api/v1/health` endpoint
- [ ] `POST /auth/setup` endpoint with `ADMIN_SETUP_CODE` env check

#### Flutter
- [ ] `flutter create kajupilot --platforms android`
- [ ] Add all packages to `pubspec.yaml`
- [ ] Set up `AdaptiveTheme` with `ThemeData` light + dark (Section 2 colors)
- [ ] `Plus Jakarta Sans` + `JetBrains Mono` fonts loading
- [ ] Riverpod `ProviderScope` in `main.dart`
- [ ] GoRouter: define all routes (shells, screens)
- [ ] Drift database: all tables mirroring Prisma schema
- [ ] Bottom nav shell (5 tabs, no content)
- [ ] Universal Input Bar widget (UI only, no logic)
- [ ] First-launch setup screen: text field for setup code → POST /auth/setup → store device token in `flutter_secure_storage`

**Deliverable**: APK installs, shows empty tabs, connects to backend, health check passes.

---

### PHASE 1 — Core CRUD (Week 2-3)
*Goal: He can manually add and view everything. No AI yet.*

#### Backend
- [ ] Parties: full CRUD + `GET /parties/:id/ledger` (receivable/payable query)
- [ ] Deals: full CRUD + status transition validation + `total_amount` computed on create
- [ ] Payments: full CRUD + `GET /payments/ledger` (aggregation query)
- [ ] Expenses: full CRUD + `GET /expenses/summary` (category breakdown)
- [ ] Auto-update `deal.paid_amount` when payment is recorded against a deal
- [ ] Soft delete on all endpoints
- [ ] Sync deduplication on all POST endpoints via `syncId`
- [ ] Validation: `class-validator` DTOs on all inputs

#### Flutter
- [ ] `AmountDisplay` widget (₹ formatting, color-coded, mono font)
- [ ] `KajuCard`, `StatusBadge`, `PersonAvatar`, `KajuActionButton` shared widgets
- [ ] Skeleton loader shimmer for all list screens
- [ ] Empty states for all screens

- [ ] **People Screen**: list with search + filter chips
- [ ] Add Person bottom sheet (name, phone, type)
- [ ] Person Profile screen (summary stats + 4 tabs)

- [ ] **Deals Screen**: list with status filter tabs
- [ ] Add Deal bottom sheet (grade selector, qty/rate → auto-compute total)
- [ ] Deal detail bottom sheet (edit inline, status change)

- [ ] **Money Screen**: Receivable / Payable / Expenses tabs
- [ ] Party ledger list (sorted by amount DESC, overdue badge)
- [ ] Add Payment bottom sheet
- [ ] Add Expense bottom sheet

- [ ] All screens: offline-first (Drift first, sync background)
- [ ] Indian number format (`intl`) on all amount displays
- [ ] Swipe to delete on list items → soft delete API call → undo snackbar
- [ ] Pull-to-refresh on all screens

**Deliverable**: He can add all his business data. Feels like a real, clean app.

---

### PHASE 2 — Today Screen + Tasks (Week 3-4)
*Goal: The supervisor. He opens this every morning and knows exactly what to do.*

#### Backend
- [ ] Tasks: full CRUD + `GET /tasks/today` (sorted: overdue first, then priority, then time)
- [ ] `PUT /tasks/:id/complete` → `completedAt = now`, `status = DONE`
- [ ] `PUT /tasks/:id/postpone` → update `scheduledAt`, `status = POSTPONED`
- [ ] Call logs: `POST /call-logs` with full side-effect logic:
  - `PAYMENT_PROMISED` → create follow-up payment collection task
  - `NO_ANSWER` → create follow-up call task (tomorrow, same purpose)
  - `NEW_ORDER` → create follow-up call task ("Follow up on order")
- [ ] `GET /insights/today` → pending totals, call count, delivery count, overdue list

#### Flutter
- [ ] **Today Screen**: full implementation (greeting, stats row, sections)
- [ ] Task card component (pending, overdue, done states)
- [ ] Stats chips (receivable, calls, deliveries)
- [ ] Overdue indicator: left red border strip on task card
- [ ] `[Call]` button → `url_launcher: tel:` → on return from dialer → show OutcomeSheet
- [ ] OutcomeSheet: 6 outcome buttons + optional note + Save
- [ ] `[Done]` → haptic + fade animation + API call
- [ ] `[Postpone]` → date/time picker bottom sheet → API call
- [ ] `flutter_local_notifications`:
  - Schedule notification per task at scheduled time
  - Morning summary notification (8AM): "X calls today, ₹Y to collect"
  - Hourly nudge during work hours if pending tasks exist
- [ ] Today screen refreshes on app foreground (Riverpod invalidate)

**Deliverable**: Today screen is the daily command center. He calls, logs, moves on.

---

### PHASE 3 — AI Parser (Week 4-5)
*Goal: Plain language → structured data. The magic shortcut.*

#### Backend
- [ ] `@groq-sdk/node` integrated as NestJS service
- [ ] `POST /ai/parse`: Groq call → parse JSON → store log → return parsed
- [ ] `POST /ai/parse/:logId/confirm`: fuzzy match parties → create all records → update log
- [ ] Fuzzy party matching logic (Section 8.4)
- [ ] Auto-create party if no fuzzy match found
- [ ] Error handling: invalid JSON from Groq → structured `parse_failed` error
- [ ] Rate limit guard: max 20 AI parse calls per hour (Redis counter, single user)

#### Flutter
- [ ] **ParseSheet**: full implementation (multiline input, mic icon)
- [ ] Mic icon behavior: `TextEditingController.selection` focus → triggers Gboard voice
- [ ] [Parse →] button → shows shimmer → renders preview cards
- [ ] Preview item card: icon per type, person name, purpose, amount, date
- [ ] "New contact" warning on unmatched person names
- [ ] Edit individual item → inline form within card
- [ ] Delete item → remove from preview list
- [ ] [Confirm All] → POST confirm → close sheet → Today screen refresh → snackbar
- [ ] Manual add shortcuts at bottom of ParseSheet (Add Sale, Payment, Expense, Call)
- [ ] Groq error states handled gracefully

**Deliverable**: He types "Call Amit tomorrow for 80k" → task created automatically.

---

### PHASE 4 — Insights + People CRM (Week 5-6)
*Goal: The brain. It knows his business better than he does.*

#### Backend
- [ ] `GET /insights/weekly` aggregation query:
  - Revenue (sum payments received)
  - Expenses (sum expenses)
  - Gross profit estimate
  - Deals closed count
  - New parties count
  - Top 3 buyers by volume
  - Top 3 slowest payers by avg delay
- [ ] `GET /insights/people` query:
  - Average payment delay per party (from call logs + payment dates)
  - Auto-update trust_tag: avg delay > 7 days → `SLOW_PAYER`
- [ ] Daily AI summary cron (BullMQ, 7AM IST):
  - Fetch today's data
  - POST to Groq (llama-3.3-70b-versatile)
  - Store result in Redis with 12hr TTL
  - `GET /ai/summary/today` → returns cached text
- [ ] `GET /expenses/summary` → category breakdown with period-over-period comparison
- [ ] `GET /parties/:id` → include computed stats (total volume, avg delay, deal count)

#### Flutter
- [ ] **Insights Screen**: AI summary card + weekly stats + people insights
- [ ] `fl_chart` donut chart for expense categories (with legend)
- [ ] Top buyers + slow payers lists with amounts
- [ ] Person profile: auto-computed stats visible in summary row
- [ ] Trust tag chip: tappable → bottom sheet to manually override
- [ ] WhatsApp deep link on person profile (`url_launcher: https://wa.me/91...`)
- [ ] Party ledger detail: transaction timeline with full history

**Deliverable**: He can see who matters most, who's risky, and where his money goes.

---

### PHASE 5 — Admin Dashboard (Week 6-7)
*Goal: You can see everything, always.*

#### Stack
Next.js 14 App Router + shadcn/ui + Tailwind + Recharts

#### Pages
- [ ] `/login` — admin credentials (separate from device token)
- [ ] `/` — overview dashboard:
  - Active users
  - Today: deals created, AI parse calls, payments logged
  - Pending collection total (system-wide)
  - AI parse success rate (confirmed / total)
- [ ] `/users/:id` — full data view for a user:
  - Parties, deals, payments, expenses, tasks, call logs
  - Timeline: everything he did today in order
  - Raw AI parse log for each session
- [ ] `/ai-logs` — table of all parse logs:
  - Raw input | Parsed JSON | Confirmed? | Created at
  - Filter: confirmed only / unconfirmed / errors
- [ ] `/exports` — download as JSON or CSV:
  - Any table, any date range, for a given user

**Deliverable**: You have full visibility into his data and usage.

---

### PHASE 6 — Polish + Release (Week 7-8)
*Goal: It feels like a ₹5000/month app he got for free.*

#### App Polish
- [ ] `AnimatedList` on Today screen: new tasks slide in, completed tasks slide out
- [ ] Bottom sheet spring animation (cubic-bezier, feels native)
- [ ] Skeleton loaders on every screen's first load
- [ ] All empty states: icon + message + CTA button
- [ ] Error states: offline banner + retry button
- [ ] Pull-to-refresh: all list screens
- [ ] Haptic feedback: Done, Confirm All, Delete
- [ ] Indian number formatting audit: every ₹ amount in the entire app
- [ ] Dark mode audit: every screen, every component, no missed `Colors.white`
- [ ] Light mode audit: warm off-white background consistent everywhere
- [ ] Theme toggle: Settings screen → `adaptive_theme.toggleTheme()`

#### App Store Assets
- [ ] App icon: cashew silhouette on `bg-base` dark, accent amber glow (design in Figma/Inkscape → export as adaptive icon for Android)
- [ ] Splash screen: app name in `titleLarge` style, accent color, dark background

#### Onboarding (3 slides, first launch only)
1. "Your calls, planned" — illustration of Today screen
2. "Your money, tracked" — illustration of Money screen
3. "Just type. We handle the rest." — illustration of ParseSheet

#### Release Build
```bash
# Increment version in pubspec.yaml
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
# Share: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# Share via WhatsApp or Google Drive link
```

He installs via: Settings → Security → Install unknown apps → (enable once) → install APK.

---

## 10. DEPLOYMENT

### Docker Compose (`docker-compose.yml`)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    restart: always
    environment:
      POSTGRES_DB: kajupilot
      POSTGRES_USER: kajuadmin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - internal

  redis:
    image: redis:7-alpine
    restart: always
    networks:
      - internal

  api:
    build:
      context: ./kajupilot-api
      dockerfile: Dockerfile
    restart: always
    environment:
      DATABASE_URL: postgresql://kajuadmin:${DB_PASSWORD}@postgres:5432/kajupilot
      REDIS_URL: redis://redis:6379
      GROQ_API_KEY: ${GROQ_API_KEY}
      JWT_SECRET: ${JWT_SECRET}
      ADMIN_SETUP_CODE: ${ADMIN_SETUP_CODE}
      NODE_ENV: production
    depends_on:
      - postgres
      - redis
    networks:
      - internal
      - external

  admin:
    build:
      context: ./kajupilot-admin
      dockerfile: Dockerfile
    restart: always
    environment:
      API_URL: http://api:3000
      ADMIN_SECRET: ${ADMIN_SECRET}
    depends_on:
      - api
    networks:
      - internal
      - external

  caddy:
    image: caddy:2-alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - api
      - admin
    networks:
      - external

volumes:
  postgres_data:
  caddy_data:
  caddy_config:

networks:
  internal:
    driver: bridge
    internal: true   # postgres + redis NOT accessible from outside
  external:
    driver: bridge
```

### Caddyfile

```
api.yourdomain.com {
  reverse_proxy api:3000
  header {
    -Server
    Strict-Transport-Security "max-age=31536000"
  }
}

admin.yourdomain.com {
  reverse_proxy admin:3000
  basicauth {
    {$ADMIN_USER} {$ADMIN_PASS_HASH}   # caddy hash-password to generate
  }
}
```

### Environment File (`.env` — never commit this)

```env
DB_PASSWORD=your_strong_password_here
GROQ_API_KEY=gsk_...
JWT_SECRET=your_64_char_random_string_here
ADMIN_SETUP_CODE=KAJU-2026      # he enters this on first launch
ADMIN_SECRET=your_admin_secret
ADMIN_USER=parth
ADMIN_PASS_HASH=$2a$14$...      # generated by: caddy hash-password
```

### Deploy Commands

```bash
# First deploy
git clone ... kajupilot
cd kajupilot
cp .env.example .env
# edit .env with real values
docker compose up -d --build

# Check status
docker compose ps
docker compose logs api --tail=50

# Update after code change
docker compose up -d --build api
# or
docker compose up -d --build api admin

# Database migrations (after schema change)
docker compose exec api npx prisma migrate deploy
```

### Backups (daily cron on VPS)

```bash
# /opt/kajupilot/backup.sh
#!/bin/bash
BACKUP_DIR="/opt/kajupilot/backups"
DATE=$(date +%Y%m%d_%H%M)
mkdir -p $BACKUP_DIR

docker compose exec -T postgres pg_dump \
  -U kajuadmin kajupilot \
  > "$BACKUP_DIR/kajupilot_$DATE.sql"

# Keep only last 30 days
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete

echo "Backup done: kajupilot_$DATE.sql"
```

```bash
# Add to crontab: crontab -e
0 2 * * * /opt/kajupilot/backup.sh >> /var/log/kajupilot-backup.log 2>&1
```

---

## FINAL CHECKLIST

### Before Sharing APK

- [ ] Test: Add 5 parties manually
- [ ] Test: Add 3 deals
- [ ] Test: Record 2 payments
- [ ] Test: Night dump with 3 tasks → AI parse → confirm
- [ ] Test: Call button opens native dialer
- [ ] Test: Outcome capture after call
- [ ] Test: Postpone a task
- [ ] Test: Today screen shows correct sorted list
- [ ] Test: Money screen ledger totals match expected
- [ ] Test: Dark mode looks correct
- [ ] Test: Light mode looks correct
- [ ] Test: Offline mode — add deal without internet → sync when reconnected
- [ ] Test: APK size is reasonable (< 50MB for release build)

### The Test That Matters

> If he opens this app on a Monday morning and closes his paper notebook forever — that is the win.

---

*Built for one. Runs on Oracle's free tier. Costs nothing. Worth everything.*
