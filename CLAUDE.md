# CLAUDE.md — NOAH MMS Project Context

This file gives Claude Code the context needed to work effectively in this repository.

---

## Project Summary

NOAH MMS is a self-hosted manga management and reading platform for an internal organization. The stack is **Next.js** (frontend, App Router) + **NestJS** (backend API) + a **relational database** (PostgreSQL) as primary store + NoSQL for AI session state. See [README.md](README.md) for the full overview and [docs/](docs/) for all specification documents.

---

## Critical Security Rules

Never violate these — they are non-negotiable requirements from [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md):

1. **Never expose `password_hash`** in any API response. It is write-only.
2. **Never store, log, or transmit plaintext passwords** after the point of initial input.
3. **Never log or return** `phone_number`, `2fa_secret`, or token plaintext values.
4. Passwords must be hashed with **bcrypt (min cost 12) or Argon2id**.
5. All endpoints require authentication unless explicitly public.
6. Protect against OWASP Top 10 — SQL injection, XSS, CSRF, IDOR.
7. Audit log every admin write action via **OpenTelemetry** (not in the main database).
8. Rate-limit login; lock accounts after 5 failed attempts (15-minute window).

---

## Architecture Decisions

| Decision | Detail |
| --- | --- |
| No self-registration | All accounts are administrator-provisioned |
| Role hierarchy | `personnel` and `administrator` only — no Moderator role |
| Deleted accounts | PII removed; content retained under `[Deleted]` placeholder |
| Post rating | Binary upvote/downvote (not star scale) |
| Manga/chapter rating | Star-scale (float) |
| DM restriction | Only between confirmed friends or with an administrator |
| Scraping | Pre-approved source list only |
| AI tagging | External VLM microservice; tags require admin approval before publication |
| AI model | Model-agnostic — no provider hardcoded |
| Adult content | Permitted; content filter governs visibility (no age-gating) |
| Deployment | Self-hosted NOAH infrastructure |
| Audit/User logs | OTEL events only — no ORM model, no DB migration |

---

## Database Design

Full schema is in [docs/DATABASE_DESIGN.md](docs/DATABASE_DESIGN.md). Key points:

- Every entity has a UUID `id`, `created_at`, `updated_at`, `deleted_at`, `is_deleted` (default `false`). The system uses **soft delete** — hard deletion through the web interface is not supported. Exceptions: `AuditLog`, `UserLog`, `Token` (invalidated via `revoked_at`), `ReadingProgress`, `PageBookmark`, `SeriesUserRecord` (never deleted).
- Datetime format: `DD-MM-YYYY hh:mm:ss` or `DD-MM-YYYY`. Exception: `Series.start_year` / `end_year` are stored as integers.
- Image fields store URLs, not binary data.
- Aggregate/computed fields (`avg_rating`, `total_reads`, etc.) are auto-computed — never manually written.
- `AuditLog` and `UserLog` are OTEL-only — they have no ORM model or migration.
- `Chapter` is a tri-parent weak entity depending on `Series`, `Volume`, and `Translation Group` simultaneously.
- `Series.available_languages` is a cached string array, auto-updated from child chapter records.

### Soft-delete behavior

`deleted_at` and `is_deleted` are managed by the system. User-facing deletions set `is_deleted = true` and `account_status = 'deleted'` on `Personnel`; titles use `is_suspended` for temporary hide. Hard DELETE statements must not be issued through the web interface.

---

## Code Conventions

Full reference: [docs/CODE_CONVENTIONS.md](docs/CODE_CONVENTIONS.md)

### General

- 4-space indentation; avoid nesting beyond 4 levels
- Opening brace at end of line; closing brace on its own line unless continued
- Functions do one thing — decompose complex functions into smaller ones
- Use framework logging; prefix log messages with an emoji matching intent
- Log format prefix: `[functionName/filename]`; surround functions with 60-dash separator lines

### TypeScript

- `const` over `let`; always end statements with `;`
- Single quotes for strings; `<>` for type assertions
- `import` only — never `require`
- Exports: `export function` / `export class` for direct exports; `const` + bottom-of-file export for constants; single export → default export
- Import order: `import type` before value → default before named → fewer before more
- Named `function` declarations for logic; arrow functions only for IIFEs, wrappers with no logic, and callbacks inside reducers/returns
- `void` + wrapper function for un-awaited async calls
- Prefer reducer functions (`.reduce()`, `.map()`) over manual iteration
- Ternary for single-line assignments; `if` for multi-line logic
- JSDoc on all exported functions — `@desc`, `@param`, `@returns`, `@throws`

### React

- Function components only (no class components)
- JSX returns one root element — use `<>` fragment
- Props are read-only; state is updated in response to user input only
- Use `children` prop for dynamic child rendering
- Always provide `key` when rendering lists
- Prefer named event handler functions over inline arrow functions
- Prefer custom components over raw HTML tags; use semantic HTML (`<section>`, `<article>`, etc.)
- Follow Rules of Hooks strictly (top-level only, in function components/custom hooks)
- Side effects outside render — use event handlers

### Next.js

- App Router; React Strict Mode enabled
- Keep client components as deep in the import tree as possible
- Server components may be children of client components but must not be imported inside client components — pass via JSX from a parent
- Use `<form>` and server actions for client-to-server data; client components only for interactivity
- Use `<Link>` not `<a>`
- Set cookies server-side via Next.js `cookies` API
- Project files outside `app/`; `app/` contains routing files only (`page`, `layout`, `loading`, `not-found`, etc.)

### NestJS

- All logic in service files
- Module files: imports, exports, module declarations only
- Controller files: route/API definitions only

### Docker

- Always add `.git`, `node_modules`, `.venv` to `.dockerignore`
- Supply env vars via `.env` file — not hardcoded in `Dockerfile` or compose files

---

## UI/UX Design System

Full reference: [docs/DESIGN_GUIDELINE.md](docs/DESIGN_GUIDELINE.md). All UI must use the tokens below — do not deviate without explicit instruction.

### Theme

Dark-first. Primary background: `bg-surface-base` (`#0D0D0D`). Light theme is out of scope.

### Brand Colors

| Token | Hex | Use |
| --- | --- | --- |
| `brand-red` | `#D42B2B` | Primary buttons, CTAs, active nav, ratings |
| `brand-red-hover` | `#B82222` | Hover on red elements |
| `brand-red-active` | `#9C1C1C` | Pressed state |
| `brand-red-muted` | `#3D1010` | Active nav background, red-tinted surfaces |
| `surface-base` | `#0D0D0D` | Page background |
| `surface` | `#161616` | Cards, panels |
| `surface-elevated` | `#222222` | Modals, dropdowns |

### Typography

- **Display/Headings:** Barlow Condensed (`font-display`)
- **Body/UI:** Inter (`font-sans`)
- **Code/Admin data:** JetBrains Mono (`font-mono`)

### Layout

- Desktop primary target: `xl` (1280px); max content width: `max-w-content` (1440px)
- Sidebar: 280px expanded / 64px collapsed; top bar: 64px
- Mobile: 56px top bar + 60px fixed bottom nav (sidebar collapses)
- Manga cover aspect ratio: `aspect-[2/3]` — enforced always

### Component Defaults

- Primary button: `bg-brand-red text-content-inverse hover:bg-brand-red-hover`
- All buttons: `rounded-lg font-medium transition-colors duration-150 disabled:opacity-40`
- Focus ring: `focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-red`
- Inputs: `h-10 px-3 rounded-lg bg-surface-overlay border border-stroke`, focused: `focus:border-stroke-brand focus:ring-2 focus:ring-brand-red/20`
- Icons: Lucide Icons, stroke 1.5px; always pair with `aria-label` or visible text label
- Notifications auto-dismiss at 5 seconds; errors are persistent

### Accessibility

- Body text contrast: 4.5:1 minimum (WCAG AA)
- All interactive elements keyboard-navigable with visible focus ring
- All `<img>` must have `alt`; decorative: `alt=""`
- Never convey information through color alone

---

## Subsystems Reference

| SS | Subsystem | Key Use Cases |
| --- | --- | --- |
| SS-01 | Manga Reading & Delivery | UC-01-01 to UC-01-12 |
| SS-02 | Account & Authentication | UC-02-02 to UC-02-07 |
| SS-03 | Social & Community | UC-03-01 to UC-03-14 |
| SS-04 | Search & Discovery | UC-04-01 to UC-04-07 |
| SS-05 | AI Assistant (Personnel) | UC-05-01 to UC-05-05 |
| SS-06 | Admin — Content Management | UC-06-01 to UC-06-12 |
| SS-07 | Admin — Personnel Management | UC-07-01 to UC-07-09 |
| SS-08 | Admin — AI Agent | UC-08-01 to UC-08-04 |

Total: 68 use cases. Full list in [docs/USECASES.md](docs/USECASES.md).

---

## Performance Targets

| Metric | Target |
| --- | --- |
| Interactive features (search, nav, data) | ≤ 2 seconds |
| Manga page image initial render | ≤ 3 seconds |
| AI assistant first-token streaming | ≤ 5 seconds |
| Concurrent users (initial release) | ≥ 100 |
| Uptime (rolling 30-day) | ≥ 99.5% |
| Max downtime per incident | ≤ 60 minutes |
| Loading indicator threshold | > 500ms operations |
| DB backup RPO / RTO | 24 h / 4 h |

---

## Open Questions

- Post rating model is resolved: **binary upvote/downvote** (Decision #1 in REQUIREMENTS.md)
- AI tag boundary between `UC-08-02` (AI generates) and `UC-06-10` (admin approves) — ensure both sides of the workflow are implemented
- Detailed AI agent capability spec for SS-08 is pending a separate document
