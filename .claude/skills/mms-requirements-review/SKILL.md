---
name: mms-requirements-review
description: Validate that an implementation conforms to the NOAH MMS functional requirements, non-functional constraints, and design decisions. Use when reviewing code, APIs, or features against REQUIREMENTS.md and USECASES.md — not for writing new code.
metadata:
  version: 1.0.0
---

# NOAH MMS — Requirements & Use Case Review Reference

Full sources: [docs/REQUIREMENTS.md](../../../docs/REQUIREMENTS.md) (67 functional + 30 non-functional requirements) and [docs/USECASES.md](../../../docs/USECASES.md) (68 use cases across 8 subsystems). This skill distills both documents into a reviewer checklist — authoritative acceptance notes, security gates, and design decision verifications. **Tier 1 and Tier 2 violations are always blocking and must never be merged.** Tiers 3 and 4 are required but may be deferred by an explicit ADR.

---

## Review Protocol

1. Identify the subsystem(s) and UC IDs the implementation claims to cover (from PR description or commit message).
2. Locate each UC ID in §Use Case Catalog and confirm that the listed actor, preconditions, and success outcomes are handled.
3. Run the full Tier 1 security checklist — every item must pass before any functional review begins.
4. Check each design decision in §Tier 2 that is relevant to the touched subsystems.
5. Verify non-functional SLAs applicable to the touched subsystem class (§Tier 3).
6. Label each failure with its tier (`BLOCKING-T1`, `BLOCKING-T2`, `REQUIRED-T3`, `REQUIRED-T4`) and cite the requirement ID or UC ID.

---

## Tier 1 — Security Non-Negotiables

Any failure here is an immediate blocker. Do not approve a PR that fails a Tier 1 check regardless of all other review outcomes.

| Check | Rule | Source |
| --- | --- | --- |
| Password storage | bcrypt cost ≥ 12 or Argon2id; plaintext never stored, logged, or transmitted after initial input | §2.1 item 2 |
| `password_hash` exposure | Never returned in any API response, log line, or error message | §1.2.2, `Personnel` schema |
| `phone_number` / `2fa_secret` | Never exposed via API; stored encrypted at rest | `Personnel` schema |
| Token plaintext | Stored as hash only (`Token.token_hash`); plaintext never persisted | `Token` schema |
| Session lifecycle | Refresh token rotation implemented; expiry enforced on every request | §2.1 item 4 |
| Account lockout | 5 consecutive failed login attempts → 15-minute lock via `locked_until`; `failed_login_attempts` reset on success | §2.1 item 5 |
| Login rate-limiting | Endpoint-level rate limiting present on the login route | §2.1 item 5 |
| Audit log | Every admin write action emits an OTEL event capturing: `actor_id`, `action_type`, `affected_entity_type`, `affected_entity_id`, `timestamp`, `source_ip` | §2.1 item 7 |
| OWASP Top 10 | SQL injection, XSS, CSRF, and IDOR mitigations present | §2.1 item 6 |
| TLS enforcement | No unencrypted HTTP path exists in any environment configuration | §2.1 item 3 |

---

## Tier 2 — Design Decisions

All eleven decisions are closed. Violations are blocking.

| # | Decision | Verify in code | Fails if |
| --- | --- | --- | --- |
| 1 | Post rating = binary upvote/downvote | `Post Vote.direction` is `upvote` or `downvote`; no star or numeric rating field on `Post` | A numeric rating field or star widget appears on posts or post votes |
| 2 | DMs restricted to mutual friends or administrators | `Conversation` creation validates `Friend Request.status = accepted` OR one participant has `role = administrator` | Any personnel can open a DM with a stranger |
| 3 | No content moderation workflow | No moderator-role gate, no moderation-queue endpoint | A moderation queue, report workflow, or moderator-role check appears |
| 4 | Scraping from pre-approved sources only | Source URL validated against an allowlist before a scrape job is accepted | Arbitrary URLs are accepted without an allowlist check |
| 5 | Tagging via external VLM microservice | Tag data consumed from a service API; no classification model embedded in the main app | In-process image classification logic exists |
| 6 | Adult content via content filter, not age-gating | No age-verification gate present; `content_rating` enum used for filtering | An age-verification UI, gate, or endpoint appears |
| 7 | Self-hosted deployment | No managed-cloud auto-scaling primitives (AWS ASG, GCP MIG, etc.) are required dependencies | Code hardcodes cloud-provider-specific elasticity APIs as required infrastructure |
| 8 | Role enum = `personnel` or `administrator` only | `Personnel.role` accepts exactly those two values | Any third role variant (e.g., `moderator`) appears in the enum or route guards |
| 9 | Deleted accounts: `[Deleted]` anonymization, content retained | On `account_status = deleted`: PII nulled/anonymized, posts and comments remain attributed to `[Deleted]` placeholder | PII retained after deletion, or content is cascade-deleted |
| 10 | AI integration layer is model-agnostic | No hardcoded provider SDK (`openai`, `@anthropic-ai/sdk`, `google-generativeai`, etc.) at the integration contract layer | A provider SDK is imported directly in the integration layer with no abstraction |
| 11 | Manga title rating = star scale | `Series User Record.rating` is a float; `Series.avg_rating` aggregated from it | A star widget renders for posts, or a binary vote is used for title rating |

---

## Tier 3 — Non-Functional SLAs

### Performance SLAs

| Metric | Threshold | Scope | Verify by |
| --- | --- | --- | --- |
| Interactive response | ≤ 2 s | All endpoints except AI streaming | Load test / profiling at P95 |
| Manga page first render | ≤ 3 s | `UC-01-01` — chapter open | Network waterfall trace |
| AI streaming first byte | ≤ 5 s | SS-05, SS-08 AI endpoints | Streaming response timing |
| Loading indicator | Shown for any operation > 500 ms | All subsystems | UI smoke test |
| Concurrent users | ≥ 100 without SLA breach | System-wide | Load test baseline |
| Downtime per incident | ≤ 60 min | Infrastructure | Incident runbook check |
| Monthly availability | ≥ 99.5% (≤ 3.6 h unplanned downtime per 30 days) | Infrastructure | Uptime monitoring |

### Qualitative Non-Functional Rules

- All interactive elements must meet **WCAG 2.1 Level AA**: keyboard navigability, 4.5:1 contrast ratio for body text, visible focus rings, screen reader compatibility.
- Error messages must be human-readable, describe what went wrong, and where possible provide a corrective action. Never surface raw stack traces.
- Manga pages beyond the initial visible set must use progressive or lazy loading.
- Manga page images must be served through a CDN or edge cache layer.
- An i18n framework must be in place from the start even if only English is shipped initially.
- Automated health checks must run at intervals ≤ 1 minute; on-call alert must fire within 5 minutes of failure.
- Daily database backups required: RPO ≤ 24 h, RTO ≤ 4 h.

---

## Use Case Catalog

### SS-01: Manga Reading & Delivery

> UC-01-11 is intentionally absent — that number was cancelled; all other IDs are preserved.

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-01-01 | Read a manga chapter in the in-browser reader | Reading view uses dark background; UI chrome auto-hides; `Reading Progress` record created or updated on each page view |
| UC-01-02 | Navigate chapters by volume, chapter number, and language | Chapter list grouped by `Volume.volume_number`; multiple translations of the same `chapter_number` are valid and must all appear |
| UC-01-03 | View manga detail page | Must display `avg_rating` (star scale), `highest_chapter`, `status`, `content_rating`; `password_hash` and PII must never be included in the response |
| UC-01-04 | View character profiles | Scoped to `Character.series_id`; aliases sourced from `Character.aliases[]` |
| UC-01-05 | View all volumes in a series | Volume 0 is the default catch-all for unassigned chapters; must appear in the list |
| UC-01-06 | Track and resume reading progress | `Reading Progress` created on first page view and never deleted; `is_completed` transitions `false → true` only — never reversed |
| UC-01-07 | Configure reading direction (RTL / LTR) | Stored in `User Preference.reading_direction`; default `rtl` |
| UC-01-08 | Switch page display mode | `User Preference.page_display_mode`: `single`, `double_spread`, `long_strip`; default `single` |
| UC-01-09 | Change page fit option | `User Preference.page_fit`: `fit_width`, `fit_height`, `original`; default `fit_width` |
| UC-01-10 | Place or clear a bookmark on a page | `Page Bookmark` logical key = `(user_id, chapter_id, page_number)`; same key replaces note in place; no soft-delete field on this entity |
| UC-01-12 | Rate a manga title | Uses `Series User Record.rating` (float, star scale); aggregated into `Series.avg_rating` — NOT binary vote |

---

### SS-02: Account & Authentication

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-02-02 | Log in with email or username and password | Rate-limited; 5 consecutive failures → 15-min lock via `locked_until`; `failed_login_attempts` reset on success |
| UC-02-03 | Reset password via email link | Issues `Token` of `type = password_reset`; stored as hash only; plaintext never persisted or logged |
| UC-02-04 | Enable or disable two-factor authentication (2FA) | `phone_number` stored encrypted when `2fa_method = sms`; `2fa_secret` stored encrypted; neither exposed via any API response |
| UC-02-05 | Edit profile | Mutable: `display_name`, `password`, `avatar_url`, `bio`; `username` and `email` are read-only after creation |
| UC-02-06 | Configure profile privacy | `Personnel.reading_stats_privacy`: `public` or `friends_only` |
| UC-02-07 | Delete own account | Sets `account_status = deleted`; PII anonymized to `[Deleted]`; posts, comments, and ratings retained; `User Preference` never deleted |

---

### SS-03: Social & Community

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-03-01 | Create a post | `Post.author_id` = authenticated user; `body` required |
| UC-03-02 | Embed a manga, chapter, or page reference in a post | `Post.embedded_reference` JSONB: `{ type: "manga" \| "chapter" \| "page", id, page_number? }` |
| UC-03-03 | Repost another personnel's post | `Post.is_repost = true`; `original_post_id` set; read-only after creation |
| UC-03-04 | Comment on a post | `Comment.post_id` non-null; exactly one of `manga_id`, `chapter_id`, `post_id` non-null per row |
| UC-03-05 | Upvote or downvote a post | `Post Vote.direction`: `upvote` or `downvote` ONLY — never star scale (see Decision #1) |
| UC-03-06 | Send a friend request | Creates directed `Friend Request` record; at most one active request per ordered pair |
| UC-03-07 | Accept or decline a friend request | Sets `Friend Request.status` to `accepted` or `rejected`; `responded_at` set |
| UC-03-08 | Remove a friend | Sets status to appropriate terminal state; `blocked` prevents further contact |
| UC-03-09 | Send a direct message to a friend or administrator | `Conversation` only between `Friend Request.status = accepted` pairs OR with one admin participant; verify this before creation |
| UC-03-10 | View inbox and receive messages | `Message` rows are immutable once written; `is_read` toggled on view |
| UC-03-11 | Receive in-app notifications | Types: `friend_request`, `post_reply`, `direct_message`, `new_chapter` |
| UC-03-12 | View another personnel's public profile | `password_hash`, `phone_number`, `2fa_secret`, `email` never exposed; `reading_stats_privacy` setting respected |
| UC-03-13 | View personal reading statistics dashboard | Sourced from `Reading Progress` and `Series User Record`; respects `reading_stats_privacy` |
| UC-03-14 | View personalized activity feed | Posts from friends + algorithmically surfaced content; suspended titles must not appear |

---

### SS-04: Search & Discovery

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-04-01 | Search by keyword | Exact-match across titles, authors, characters |
| UC-04-02 | Search by natural language (semantic intent) | AI-powered; integration must be model-agnostic (Decision #10) |
| UC-04-03 | Filter search results by tags | Multi-level: genre, status, `content_rating`, language; only `Tag.status = approved` tags appear in filters |
| UC-04-04 | Sort search results | Options: relevance, rating, popularity, recency, alphabetical |
| UC-04-05 | View personalized recommendations | Derived from reading history and preferences; suspended titles excluded |
| UC-04-06 | View friend suggestions | Based on reading overlap and genre interests |
| UC-04-07 | View similar titles | Displayed on manga detail page; suspended titles excluded |

---

### SS-05: AI Assistant (Personnel)

> UC-05-04 and UC-05-05 are distinct cases. UC-05-04 = query is outside the manga domain entirely. UC-05-05 = query is inside the domain but the model cannot answer it. Both must be implemented separately.

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-05-01 | Query the AI assistant to find manga, authors, or characters | Model-agnostic integration (Decision #10); no provider SDK hardcoded |
| UC-05-02 | Ask about plot, characters, themes, or author background | In-scope domain only; AI streaming first byte ≤ 5 s |
| UC-05-03 | Ask follow-up questions within the same session | Session context maintained server-side; user must not re-submit prior context |
| UC-05-04 | Receive a graceful refusal for out-of-scope queries | Must decline non-manga queries explicitly; must not hallucinate an answer |
| UC-05-05 | Receive an honest acknowledgement of limited knowledge | Must not fabricate when an in-scope query exceeds model knowledge; must explicitly state it does not know |

---

### SS-06: Admin — Content Management

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-06-01 | Scrape manga from an external URL | Source URL validated against pre-approved allowlist before job is created (Decision #4) |
| UC-06-02 | Upload manga from the local file system (ZIP/CBZ or folder) | Series and volume creation are admin-only at this entry point |
| UC-06-03 | Review and resolve flagged duplicate titles | System flags potential duplicates; admin must confirm resolution before proceeding |
| UC-06-04 | Delete a manga title | Two-step confirmation required; soft-delete only (`is_deleted = true`, `deleted_at` set) |
| UC-06-05 | Suspend or unsuspend a manga title | Sets `Series.is_suspended`; does not delete; suspended titles hidden from all personnel views |
| UC-06-06 | Initiate a batch scraping operation | `Scrape Job` status lifecycle: `pending → running → completed / failed / cancelled` |
| UC-06-07 | Schedule a recurring automated scrape job | `Scrape Job.is_recurring = true`; `schedule` = valid cron expression |
| UC-06-08 | View the system-wide content dashboard | Total titles, chapters, pages, storage usage, scrape history |
| UC-06-09 | Monitor per-title personnel engagement metrics | Views, read-through rates, bookmarks, ratings; sourced from auto-computed aggregate fields — never manually written |
| UC-06-10 | Review and approve AI-generated tags | `Tag Proposal.status` transitions `pending → approved / rejected`; `source = ai` proposals require admin approval before tag is active and visible to personnel |
| UC-06-11 | Upload a chapter (group member) | Uploader's `Personnel.group_id` must equal `Chapter.group_id`; series and volume creation are not permitted via this path |
| UC-06-12 | Edit series metadata | Title edits must cascade to `Chapter.series_original_title` and `Volume.series_original_title` in the same transaction; audit OTEL event emitted with before/after JSONB payload |

---

### SS-07: Admin — Personnel Management

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-07-01 | Search for a personnel account | Search by username, email, or ID |
| UC-07-02 | View a personnel account's details and activity summary | Must NOT expose `password_hash`, `phone_number`, or `2fa_secret` |
| UC-07-03 | Force a password reset | Sends reset link via email; issues `Token` of `type = password_reset`; admin never sees plaintext password |
| UC-07-04 | Create a new personnel account | All accounts are admin-provisioned; no unauthenticated creation path may exist |
| UC-07-05 | Assign or change a personnel's role | Valid roles: `personnel` and `administrator` only (Decision #8); audit OTEL event emitted |
| UC-07-06 | Suspend or reinstate a personnel account | Sets `account_status = suspended`; reversible; distinct from `deleted` |
| UC-07-07 | Delete a personnel account permanently | Sets `account_status = deleted`; PII anonymized; content retained under `[Deleted]`; audit OTEL event emitted |
| UC-07-08 | View system-wide personnel statistics | Registrations over time, DAU/MAU, top contributors |
| UC-07-09 | View per-personnel activity summary | Reading history, post history, login history, social connections; `password_hash`, `phone_number`, `2fa_secret` never exposed |

---

### SS-08: Admin — AI Agent

| UC ID | Title | Key constraints / acceptance notes |
| --- | --- | --- |
| UC-08-01 | Request an AI-generated summary or metadata suggestions | Model-agnostic (Decision #10); result presented for admin review — not auto-applied |
| UC-08-02 | Review and apply AI-generated tags before publication | Creates `Tag Proposal` rows with `source = ai`, `status = pending`; admin approval via UC-06-10 required before any tag becomes active |
| UC-08-03 | Request an AI-generated activity summary for a personnel account | Summarizes patterns; `password_hash`, `phone_number`, `2fa_secret` must not appear in any prompt or response |
| UC-08-04 | Review AI-flagged accounts with anomalous behavior | AI flags for admin review only; does not auto-suspend |

---

## Subsystem–Requirement Cross-Reference

| Subsystem | FR Sections | NFR Sections | Design Decisions |
| --- | --- | --- | --- |
| SS-01 Manga Reading & Delivery | §1.1.1 | §2.2 (3 s page render, loading indicator), §2.4 (WCAG, loading indicator) | #11 (star rating), #6 (content filter) |
| SS-02 Account & Authentication | §1.1.2 — Auth & Account block | §2.1 (password storage, lockout, rate-limit, TLS, session rotation) | #9 (`[Deleted]` anonymization) |
| SS-03 Social & Community | §1.1.2 — Social, Feed, Stats blocks | §2.2 (2 s), §2.4 (actionable errors) | #1 (binary vote), #2 (DM restriction), #3 (no moderation), #8 (no moderator role), #9 (`[Deleted]`) |
| SS-04 Search & Discovery | §1.1.3 | §2.2 (2 s), §2.4 | #5 (VLM tags must be approved before appearing in filters), #10 (model-agnostic semantic search) |
| SS-05 AI Assistant (Personnel) | §1.1.4 | §2.2 (5 s AI streaming), §2.3 (i18n) | #10 (model-agnostic) |
| SS-06 Admin Content Management | §1.2.1, §1.1.5 | §2.2 (2 s), §2.1 (audit log) | #4 (scraping allowlist), #5 (VLM tags), #6 (content filter), #11 (star rating) |
| SS-07 Admin Personnel Management | §1.2.2 | §2.1 (password storage, audit log, no plaintext) | #8 (no moderator role), #9 (`[Deleted]`) |
| SS-08 Admin AI Agent | §1.2.3 | §2.2 (5 s AI streaming) | #5 (VLM tags), #10 (model-agnostic) |

---

## Common Violation Patterns

**Rating model confusion.** Posts use binary upvote/downvote (`Post Vote.direction`). Manga titles use a float star scale (`Series User Record.rating`). These two systems are never interchangeable. A star widget on post votes, or a binary vote button on title rating, is a blocking T2 violation.

**Plaintext credential surface.** The most common Tier 1 failure is a log statement, serializer, or error response that includes `password`, `password_hash`, `token`, `phone_number`, or `2fa_secret`. Grep the diff for these strings against every logging call, DTO, and API response transformer.

**Soft-delete bypass.** The system never hard-deletes records through the web interface except where explicitly stated (`Page Bookmark` has no soft-delete fields; `Token` uses `revoked_at`; OTEL entities have no ORM model at all). An implementation issuing a SQL `DELETE` on a soft-delete entity is a data integrity violation.

**Self-registration path.** Any endpoint that creates a `Personnel` record without requiring an authenticated administrator violates `UC-07-04` and the architecture decision in §1.3. Verify no unauthenticated or personnel-authenticated creation path exists.

**AI provider hardcoding.** Any direct import of `openai`, `@anthropic-ai/sdk`, `google-generativeai`, or equivalent SDK in the AI integration layer violates Decision #10. The integration must route through an abstraction or adapter layer that supports provider substitution.

**Tag published without approval.** Any workflow that makes a `Tag Proposal` entry visible to personnel — or usable as a filter — without its `status` transitioning to `approved` violates Decision #5 and the schema constraint. This applies to both AI-generated proposals (UC-08-02) and manual ones.

**Title edit without cascade.** Editing `Series.original_title` must update `Chapter.series_original_title` and `Volume.series_original_title` in the same transaction and emit an audit OTEL event with a before/after JSONB payload. An implementation that updates only `Series` is incomplete per UC-06-12.

**DM without friendship check.** Creating a `Conversation` or sending a `Message` without verifying `Friend Request.status = accepted` for both parties (or confirming one participant has `role = administrator`) violates Decision #2.
