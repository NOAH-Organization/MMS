# NOAH Manga Management System (NOAH MMS)

**NOAH** — Neutralize, Organize, Analyze, Harmonize

NOAH MMS is a self-hosted, internal manga management and reading platform built for the NOAH organization. It lets personnel browse, read, and socially engage with manga content while giving administrators full control over content ingestion, personnel accounts, and AI-assisted management tools.

---

## Features

### For Personnel

- **Reader** — in-browser reading view with configurable direction (RTL/LTR), page display modes (single / double-spread / long-strip), and fit options; bookmarks and reading progress tracked automatically
- **Library** — manga detail pages with metadata, character profiles, volume/chapter lists, and ratings (star scale per title, binary vote per post)
- **Social** — activity feed, posts with manga embeds, reposts, comments, friend system, direct messaging (friends and admins only), and in-app notifications
- **Search & Discovery** — keyword and semantic search, multi-tag filtering, sort options, personalized recommendations, similar-title suggestions, and friend suggestions
- **AI Assistant** — natural-language manga search and Q&A, session-scoped context persistence, graceful out-of-scope refusals

### For Administrators

- **Content Management** — URL scraping (pre-approved sources), local file upload (ZIP/CBZ/folder), series metadata editing, duplicate detection, suspension, deletion (two-step confirmation), batch and scheduled scrape jobs, content dashboard
- **Personnel Management** — account provisioning (no self-registration), role assignment (Personnel / Administrator), suspension, forced password reset, deletion, activity analytics
- **AI Agent** — metadata and summary generation, AI-generated tag proposals (require admin review before publication), anomalous-account flagging
- **Translation Groups** — personnel may belong to one group at a time and upload chapters attributed to that group; admins manage all other content operations

---

## Architecture Overview

| Layer | Technology |
| --- | --- |
| Frontend | Next.js (App Router), React, Tailwind CSS |
| Backend | NestJS |
| Primary Database | Relational (PostgreSQL) |
| AI Session Store | NoSQL (managed by AI memory layer) |
| Observability | OpenTelemetry — Audit Log and User Log are OTEL events, not DB rows |
| Deployment | Self-hosted NOAH infrastructure + CDN/edge cache for images |

---

## Documentation

| Document | Description |
| --- | --- |
| [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md) | Authoritative functional and non-functional requirements |
| [docs/USECASES.md](docs/USECASES.md) | Full use-case list (68 use cases across 8 subsystems) |
| [docs/DATABASE_DESIGN.md](docs/DATABASE_DESIGN.md) | Conceptual and logical database schema |
| [docs/CODE_CONVENTIONS.md](docs/CODE_CONVENTIONS.md) | Coding standards for TypeScript, React, Next.js, NestJS, and Docker |
| [docs/DESIGN_GUIDELINE.md](docs/DESIGN_GUIDELINE.md) | UI/UX design system — colors, typography, components, Tailwind config |

---

## Key Constraints

- **No self-registration** — all accounts are administrator-provisioned
- **Passwords** stored as bcrypt (min cost 12) or Argon2id hashes; never logged or exposed via API
- **TLS 1.2+** required in all environments; no plain HTTP
- **Rate limiting** on login; accounts lock after 5 consecutive failures (15-minute window)
- **Audit log** for all admin write actions (OTEL, not in main DB)
- **Deleted accounts** retain contributed content attributed to `[Deleted]` (Reddit model)
- **Web scraping** limited to administrator-maintained pre-approved source list
- **AI assistant** is model-agnostic — no provider may be hardcoded
- **Adult content** is permitted; visibility is controlled by a content filter (no age-gating)
- **Target availability** 99.5% uptime on a rolling 30-day basis
- **Performance** all interactive features ≤ 2 s; page images begin rendering within 3 s; AI responses begin streaming within 5 s

---

## Role Hierarchy

| Role | Description |
| --- | --- |
| `personnel` | Standard user — full reading, social, and search features |
| `administrator` | All personnel features plus content management, account management, and AI agent |

No Moderator role exists in the initial release.
