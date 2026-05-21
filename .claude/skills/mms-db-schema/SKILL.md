---
name: mms-db-schema
description: Reference for the NOAH MMS database schema, entity fields, and relationships. Use when writing queries, designing ORM models, building migrations, implementing service logic that touches the database, or reasoning about entity relationships and business constraints.
metadata:
  version: 1.0.0
---

# NOAH MMS — Database Schema Reference

Full source: [docs/DATABASE_DESIGN.md](../../../docs/DATABASE_DESIGN.md). This skill distills the schema into a backend-developer reference — authoritative field lists, FK wiring, and constraints. All code that touches the database must conform to the rules below.

---

## Universal Field Rules

Every entity (except OTEL-only ones) must carry:

| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID (latest native) | ro — primary key |
| `created_at` | datetime | managed by the system |
| `updated_at` | datetime | managed by the system |
| `deleted_at` | datetime | `null` if not deleted |
| `is_deleted` | boolean | default `false` |

**Soft-delete only.** Hard `DELETE` statements must not be issued through the web interface. Set `is_deleted = true` and `deleted_at` to delete a record.

**Datetime format:** `DD-MM-YYYY hh:mm:ss` or `DD-MM-YYYY`. Exception: `Series.start_year` and `Series.end_year` are stored as plain integers.

**Required fields** are marked `*`. **Read-only fields** are marked `ro` — they must not be updated after the record is created.

**Auto-computed fields** (aggregate counts, averages, caches) are maintained by the system — never manually write to them.

**Image fields** store URLs, never binary data.

**Decimal precision:** `float` rounded to 2 decimal places — no high-precision arithmetic needed.

---

## Entities Overview

| Type | Entity | Description |
| --- | --- | --- |
| Strong | `Series` | A manga/manhwa/manhua series |
| Strong | `Personnel` | User or administrator account |
| Strong | `Creator` | Author or artist |
| Strong | `Tags` | Series tag or genre |
| Strong | `Translation Group` | Translator team or official publisher |
| Strong | `Post` | User-generated activity feed entry |
| Strong | `Scrape Job` | Admin-triggered content ingestion job |
| Strong | `Audit Log` | **OTEL-only** — admin write actions (no ORM, no migration) |
| Strong | `User Log` | **OTEL-only** — user activity events (no ORM, no migration) |
| Weak | `Volume` | Volume of a series — depends on `Series` |
| Weak | `Chapter` | Chapter — tri-parent weak entity: depends on `Series`, `Volume`, and `Translation Group` |
| Weak | `Character` | Named character scoped to one series |
| Weak | `Comment` | Polymorphic comment targeting `Series`, `Chapter`, or `Post` |
| Weak | `User Preference` | Per-user reading settings (1:1 with `Personnel`) |
| Weak | `Token` | Auth token (refresh or password_reset) |
| Weak | `Notification` | In-app notification delivered to a user |
| Weak | `Message` | Single DM within a `Conversation` |
| Associated | `Series Creator Credit` | `Series` ↔ `Creator` with `role` |
| Associated | `Series User Record` | `Personnel` ↔ `Series` with bookmark, notification, rating |
| Associated | `Chapter Rating` | `Personnel` ↔ `Chapter` star rating |
| Associated | `Post Vote` | `Personnel` ↔ `Post` binary vote |
| Associated | `Creator Follow` | `Personnel` ↔ `Creator` follow |
| Associated | `Tag Proposal` | `Series` ↔ `Tags` with lifecycle status |
| Associated | `Reading Progress` | `Personnel` ↔ `Chapter` reading state |
| Associated | `Page Bookmark` | `Personnel` ↔ `Chapter` ↔ page number |
| Associated | `Friend Request` | `Personnel` ↔ `Personnel` self-referential friendship |
| Associated | `Conversation` | `Personnel` ↔ `Personnel` DM channel |
| Associated | `Character Appearance` | `Chapter` ↔ `Character` pure junction |

---

## Schema Definitions

### Series

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*original_title` | string | ro — native script (e.g. `ドラえもん`); changes cascade to `Chapter.series_original_title` and `Volume.series_original_title` |
| `*english_title` | string | |
| `vietnamese_title` | string | nullable |
| `alt_titles` | string[] | nullable |
| `description` | text | nullable — plot summary |
| `cover_image` | string (URL) | nullable |
| `background_image` | string (URL) | nullable |
| `highest_chapter` | float | auto-computed |
| `highest_volume` | int | auto-computed |
| `available_languages` | string[] | auto-computed cache of distinct languages across child chapters |
| `*status` | enum | `upcoming` \| `ongoing` \| `finished` \| `hiatus` \| `cancelled` — default `upcoming` |
| `latest_chapter` | float | nullable — officially released chapter number |
| `latest_volume` | int | nullable |
| `start_year` | int | nullable |
| `end_year` | int | nullable |
| `country` | string | nullable |
| `platforms` | string[] | nullable |
| `*series_type` | enum | `manga` \| `manhua` \| `manhwa` \| `comic` — default `manga` |
| `*chapter_type` | enum | `oneshot` \| `series` \| `anthology` — default `series` |
| `content_rating` | enum | `everyone` \| `teen` \| `mature` \| `explicit` |
| `is_suspended` | boolean | default `false` — admin visibility override; does not delete the record |
| `avg_rating` | float | auto-computed from `Series User Record` |
| `total_ratings` | int | auto-computed |
| `total_reads` | int | auto-computed — distinct user count in `Series User Record` |
| `total_comments` | int | auto-computed from `Comment.manga_id` |
| `total_bookmarks` | int | auto-computed — count where `Series User Record.is_bookmarked = true` |

---

### Personnel (User / Administrator)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*username` | string | ro — unique; login only, not display name |
| `*email` | string | ro — unique |
| `display_name` | string | defaults to `username` |
| `password_hash` | string | ro — bcrypt (min cost 12) or Argon2id; **write-only, never returned by any API** |
| `avatar_url` | string (URL) | nullable |
| `bio` | text | nullable |
| `*role` | enum | `personnel` \| `administrator` — default `personnel` |
| `*account_status` | enum | `active` \| `suspended` \| `deleted` — default `active` |
| `reading_stats_privacy` | enum | `public` \| `friends_only` — default `public` |
| `last_active_at` | datetime | updated on every successful authenticated request |
| `group_id` | UUID (FK → Translation Group) | nullable — current group membership; mutable |
| `is_2fa_enabled` | boolean | default `false` |
| `2fa_method` | enum | `authenticator_app` \| `sms` \| `null` |
| `phone_number` | string | stored encrypted; **never exposed via API**; required when `2fa_method = sms` |
| `2fa_secret` | string | stored encrypted; **never exposed via API** |
| `failed_login_attempts` | int | default `0`; reset on successful login |
| `locked_until` | datetime | nullable; auto-set after exceeding failed-attempt threshold (5 attempts / 15-min window) |
| `total_titles_read` | int | auto-computed from `Reading Progress` |
| `total_chapters_read` | int | auto-computed from `Reading Progress` |

---

### Tags

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | |
| `*name` | string | e.g. `Slice of Life`, `Shounen` |
| `description` | text | nullable |
| `group` | string | nullable — category e.g. `theme`, `genre`, `demographic` |

---

### Creator

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | |
| `*pen_name` | string | public display name |
| `native_name` | string | nullable |
| `alt_names` | string[] | nullable |
| `bio` | text | nullable |
| `birth_date` | date | nullable |
| `death_date` | date | nullable |
| `nationality` | string | nullable |
| `gender` | string | nullable |
| `social_links` | JSONB (key-value) | nullable — e.g. `{ "twitter": "...", "pixiv": "..." }` |
| `total_works_official` | int | nullable |
| `total_works_in_system` | int | auto-computed from `Series Creator Credit` |
| `*is_author` | boolean | |
| `*is_artist` | boolean | at least one of `is_author` or `is_artist` must be `true` |

---

### Translation Group

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | |
| `*name` | string | |
| `alt_names` | string[] | nullable |
| `description` | text | nullable |
| `website_url` | string (URL) | nullable |
| `languages` | string[] | nullable |
| `is_official_publisher` | boolean | default `false` — marks publishers like Viz Media, Yen Press |
| `total_chapters_translated` | int | auto-computed |

---

### Volume (weak — depends on `Series`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*series_id` | UUID (FK → Series) | |
| `series_original_title` | string | ro — denormalized from `Series.original_title` to avoid joins |
| `*volume_number` | int | ro |
| `title` | string | nullable |
| `release_date` | date | nullable |
| `publisher` | string | default `"unknown"` |
| `isbn` | string | nullable |
| `edition` | string | default `"standard"` |
| `published_chapter_start` | float | nullable |
| `published_chapter_end` | float | nullable |
| `store_links` | JSONB | nullable |
| `price` | JSONB (key-value) | nullable — e.g. `{ "USD": 12.99, "VND": 120000 }` |
| `description` | text | nullable |
| `cover_image` | string (URL) | nullable |
| `current_chapter_start` | float | nullable — first chapter in system for this volume |
| `current_chapter_end` | float | nullable |
| `total_pages` | int | nullable |
| `avg_rating` | float | auto-computed across child chapters |
| `total_ratings` | int | auto-computed |
| `total_reads` | int | auto-computed |
| `total_comments` | int | auto-computed |
| `total_bookmarks` | int | auto-computed |

**Volume 0** is the default catch-all container for chapters not assigned to any published volume. Every series must have at least one volume (including Volume 0).

---

### Chapter (tri-parent weak — depends on `Series`, `Volume`, `Translation Group`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*series_id` | UUID (FK → Series) | |
| `*volume_id` | UUID (FK → Volume) | Vol 0 is the default |
| `*group_id` | UUID (FK → Translation Group) | |
| `*uploader_id` | UUID (FK → Personnel) | non-admin uploaders must have `Personnel.group_id = Chapter.group_id` |
| `series_original_title` | string | ro — denormalized from `Series.original_title` |
| `volume_number` | int | ro — denormalized from `Volume.volume_number` |
| `*chapter_number` | float | ro |
| `title` | string | nullable |
| `release_date` | date | nullable |
| `*language` | string | default `"none"` for wordless chapters |
| `is_official` | boolean | default `false` |
| `description` | text | nullable |
| `*page_count` | int | must be ≥ 1 |
| `is_special` | boolean | default `false` |
| `*pages` | JSONB[] | array of page objects — `{ order, url, dimensions? }` |
| `avg_rating` | float | auto-computed |
| `total_ratings` | int | auto-computed |
| `total_reads` | int | auto-computed — distinct user count in `Reading Progress` |
| `total_comments` | int | auto-computed |
| `total_bookmarks` | int | auto-computed |

Multiple translations of the same `chapter_number` may exist (different languages or same language from different groups).

---

### Character (weak — depends on `Series`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*series_id` | UUID (FK → Series) | |
| `series_original_title` | string | ro — denormalized |
| `*name` | string | primary display name |
| `aliases` | string[] | nullable |
| `role` | enum | `protagonist` \| `antagonist` \| `supporting` \| `other` |
| `description` | text | nullable |
| `image_url` | string (URL) | nullable |

---

### Comment (polymorphic weak — depends on `Series`, `Chapter`, or `Post`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*author_id` | UUID (FK → Personnel) | |
| `*body` | text | |
| `parent_comment_id` | UUID (FK → Comment) | nullable — threading limited to one level; parent must target the same entity |
| `manga_id` | UUID (FK → Series) | nullable |
| `chapter_id` | UUID (FK → Chapter) | nullable |
| `post_id` | UUID (FK → Post) | nullable |

**Constraint:** Exactly one of `manga_id`, `chapter_id`, or `post_id` must be non-null per row.

---

### Post

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*author_id` | UUID (FK → Personnel) | |
| `*body` | text | |
| `embedded_reference` | JSONB | nullable — `{ type: "manga" | "chapter" | "page", id, page_number? }` |
| `is_repost` | boolean | default `false` |
| `original_post_id` | UUID (FK → Post) | ro — `null` unless `is_repost = true` |
| `upvote_count` | int | auto-computed |
| `downvote_count` | int | auto-computed |
| `comment_count` | int | auto-computed |
| `repost_count` | int | auto-computed |

---

### User Preference (weak — 1:1 with `Personnel`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*user_id` | UUID (FK → Personnel) | ro — primary key |
| `reading_direction` | enum | `rtl` \| `ltr` — default `rtl` |
| `page_display_mode` | enum | `single` \| `double_spread` \| `long_strip` — default `single` |
| `page_fit` | enum | `fit_width` \| `fit_height` \| `original` — default `fit_width` |

Created with defaults at account provisioning. Never deleted.

---

### Token (weak — depends on `Personnel`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*user_id` | UUID (FK → Personnel) | ro |
| `*type` | enum | ro — `refresh` \| `password_reset` |
| `*token_hash` | string | ro — hash only; plaintext is never stored |
| `*issued_at` | datetime | ro |
| `*expires_at` | datetime | |
| `revoked_at` | datetime | nullable — `null` if still valid; set on use, rotation, or explicit revocation |

Does **not** carry `is_deleted` / `deleted_at`. Invalidation is via `revoked_at` only.

---

### Notification (weak — depends on `Personnel`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*recipient_id` | UUID (FK → Personnel) | |
| `*type` | enum | `friend_request` \| `post_reply` \| `direct_message` \| `new_chapter` |
| `*is_read` | boolean | default `false` |
| `reference` | JSONB | nullable — deep-link payload e.g. `{ type: "chapter", id: "...", series_title: "..." }` |

---

### Scrape Job

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*created_by` | UUID (FK → Personnel) | admin-only |
| `*source_url` | string | ro |
| `target_manga_id` | UUID (FK → Series) | ro — `null` for new-title ingestion |
| `is_recurring` | boolean | default `false` |
| `schedule` | string | cron expression — `null` if not recurring |
| `*status` | enum | `pending` \| `running` \| `completed` \| `failed` \| `cancelled` — default `pending` |
| `started_at` | datetime | nullable |
| `completed_at` | datetime | nullable |
| `result_summary` | JSONB | nullable — e.g. `{ chapters_added, pages_added, errors }` |
| `error_details` | JSONB | nullable |

---

### Conversation (associated — `Personnel` ↔ `Personnel`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*participant_a_id` | UUID (FK → Personnel) | |
| `*participant_b_id` | UUID (FK → Personnel) | |
| `last_message_at` | datetime | auto-updated atomically on each `Message` insert |

At most one conversation per unordered `(participant_a_id, participant_b_id)` pair. Only between confirmed friends or when one participant is an administrator.

---

### Message (weak — depends on `Conversation`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*conversation_id` | UUID (FK → Conversation) | |
| `*sender_id` | UUID (FK → Personnel) | |
| `*body` | text | text-only in initial release |
| `*is_read` | boolean | default `false` |
| `*sent_at` | datetime | ro — set by system on insert |

Immutable once written.

---

### Friend Request (associated — self-referential on `Personnel`)

| Field | Type / Constraint | Notes |
| --- | --- | --- |
| `*id` | UUID | ro |
| `*requester_id` | UUID (FK → Personnel) | ro |
| `*addressee_id` | UUID (FK → Personnel) | ro |
| `*status` | enum | `pending` \| `accepted` \| `rejected` \| `blocked` — default `pending` |
| `requested_at` | datetime | ro |
| `responded_at` | datetime | nullable |

Directed. At most one active request per ordered pair. `blocked` prevents any further contact. `rejected` allows re-submission after a cooldown.

---

### Series User Record (associated — never deleted)

| Field | Notes |
| --- | --- |
| `*user_id` (FK → Personnel) | composite PK with `series_id` |
| `*series_id` (FK → Series) | |
| `is_bookmarked` | default `false` |
| `notify_on_new_chapter` | default `false`; may only be `true` while `is_bookmarked = true`; clearing `is_bookmarked` auto-clears this flag |
| `rating` | float, nullable; feeds `Series.avg_rating` and `Series.total_ratings`; updates replace in place |

Created on first chapter read. **Never deleted.**

---

### Reading Progress (associated — never deleted)

| Field | Notes |
| --- | --- |
| `*user_id` (FK → Personnel) | composite PK with `chapter_id` |
| `*chapter_id` (FK → Chapter) | |
| `*last_page` | most recent page viewed |
| `*is_completed` | default `false`; transitions `false → true` only, never reset |
| `last_read_at` | updated on every read event |

Created on first page view. **Never deleted.** Series completion = `is_completed = true` count ÷ total chapters.

---

### Page Bookmark (associated — no soft-delete)

| Field | Notes |
| --- | --- |
| `*id` | ro |
| `*user_id` (FK → Personnel) | |
| `*chapter_id` (FK → Chapter) | |
| `*page_number` | ro — logical key component |
| `note` | optional annotation |
| `bookmarked_at` | ro |

Logical key: `(user_id, chapter_id, page_number)`. Placing on the same page replaces the note in place. **No soft-delete.**

---

### Chapter Rating (associated)

| Field | Notes |
| --- | --- |
| `*user_id` (FK → Personnel) | composite PK with `chapter_id` |
| `*chapter_id` (FK → Chapter) | |
| `*rating` | float (typically 1.0–5.0); updates replace in place |

---

### Post Vote (associated)

| Field | Notes |
| --- | --- |
| `*user_id` (FK → Personnel) | composite PK with `post_id` |
| `*post_id` (FK → Post) | |
| `*direction` | `upvote` \| `downvote`; changing direction updates in place |

---

### Series Creator Credit (associated)

| Field | Notes |
| --- | --- |
| `*series_id` (FK → Series) | composite PK with `creator_id` and `role` |
| `*creator_id` (FK → Creator) | |
| `*role` | ro — `author` \| `artist`; one person may hold both on the same series |

A series must have at least one `author` credit.

---

### Tag Proposal (associated)

| Field | Notes |
| --- | --- |
| `*series_id` (FK → Series) | composite PK with `tag_id` |
| `*tag_id` (FK → Tags) | |
| `*status` | `pending` \| `approved` \| `rejected` — default `pending` |
| `*source` | `manual` \| `ai` |

Tag is considered active on a series when `status = approved`. AI-sourced proposals require admin approval before publication.

---

### Creator Follow / Character Appearance (pure junctions)

`Creator Follow`: `*user_id` (FK → Personnel) + `*creator_id` (FK → Creator). No extra attributes.

`Character Appearance`: `*chapter_id` (FK → Chapter) + `*character_id` (FK → Character). No extra attributes.

---

## OTEL-Only Entities (no ORM model, no migration)

`Audit Log` and `User Log` are **not** stored in the main database. They are emitted as structured events to the OpenTelemetry observability stack. Do not create ORM models or migrations for them.

- **Audit Log** — every admin write action: `actor_id`, `action_type`, `affected_entity_type`, `affected_entity_id`, `timestamp`, `source_ip`, `metadata` (before/after JSONB).
- **User Log** — user activity events: `user_id`, `action_type` (login, logout, read_chapter, rate_manga, rate_chapter, comment, bookmark_series, bookmark_page, password_reset_request, upload_chapter), `timestamp`, `success`, `source_ip`, `user_agent`, `metadata` (JSONB).

Both are append-only and permanent — soft-delete fields do not apply.

---

## Relationship Map

| Entity A | Cardinality | Entity B | FK / Junction | Notes |
| --- | --- | --- | --- | --- |
| Series | 1:N | Volume | `Volume.series_id` | must have ≥ 1 volume (incl. Vol 0) |
| Series | 0:N | Chapter | `Chapter.series_id` | |
| Series | 1:N | Character | `Character.series_id` | |
| Series | M:N | Creator | `Series Creator Credit` | carries `role` |
| Series | M:N | Tags | `Tag Proposal` | active when `status = approved` |
| Series | M:N | Personnel | `Series User Record` | created on first read; never deleted |
| Series | 1:N | Comment | `Comment.manga_id` | polymorphic; nullable |
| Volume | 0:N | Chapter | `Chapter.volume_id` | Vol 0 is default |
| Chapter | N:1 | Translation Group | `Chapter.group_id` | exactly one group per chapter |
| Chapter | N:1 | Personnel (uploader) | `Chapter.uploader_id` | non-admin must match group_id |
| Chapter | M:N | Character | `Character Appearance` | pure junction |
| Chapter | M:N | Personnel | `Chapter Rating` | one per user per chapter |
| Chapter | M:N | Personnel | `Reading Progress` | carries `last_page`, `is_completed` |
| Chapter | M:N | Personnel | `Page Bookmark` | logical key incl. page_number |
| Chapter | 1:N | Comment | `Comment.chapter_id` | polymorphic; nullable |
| Translation Group | 1:N | Personnel | `Personnel.group_id` | nullable; mutable |
| Personnel | 1:1 | User Preference | `User Preference.user_id` | |
| Personnel | 1:N | Token | `Token.user_id` | |
| Personnel | 1:N | Notification | `Notification.recipient_id` | |
| Personnel | 1:N | Post | `Post.author_id` | |
| Personnel | 1:N | Comment | `Comment.author_id` | |
| Personnel | 1:N | Scrape Job | `Scrape Job.created_by` | admin-only |
| Personnel | M:N | Creator | `Creator Follow` | |
| Personnel | M:N (self) | Personnel | `Friend Request` | directed; status lifecycle |
| Personnel | M:N (self) | Personnel | `Conversation` | symmetric; ≤1 per unordered pair |
| Post | M:1 (self) | Post | `Post.original_post_id` | null unless repost |
| Post | M:N | Personnel | `Post Vote` | binary direction |
| Post | 1:N | Comment | `Comment.post_id` | polymorphic; nullable |
| Comment | M:1 (self) | Comment | `Comment.parent_comment_id` | threading ≤ 1 level |
| Conversation | 1:N | Message | `Message.conversation_id` | |
| Message | N:1 | Personnel | `Message.sender_id` | |
| Scrape Job | 0:1 | Series | `Scrape Job.target_manga_id` | null for new titles |

---

## Key Business Constraints

- **No self-registration.** All `Personnel` records are administrator-provisioned.
- **`password_hash` is write-only.** Never return it in any API response.
- **`phone_number`, `2fa_secret`** — stored encrypted, never exposed via API.
- **Account lock:** 5 failed login attempts → lock for 15 minutes (`locked_until`).
- **Comment polymorphism:** Exactly one of `manga_id`, `chapter_id`, `post_id` must be non-null per row.
- **Chapter tri-parent:** All three FKs (`series_id`, `volume_id`, `group_id`) are non-nullable. A chapter cannot exist without all three parents.
- **Denormalized fields on Chapter/Volume:** `series_original_title` (on both) and `volume_number` (on Chapter) are copied from parent read-only fields at write time — do not recompute from joins.
- **`Series User Record`** and **`Reading Progress`** and **`Page Bookmark`** are never deleted.
- **`notify_on_new_chapter`** may only be `true` while `is_bookmarked = true`; clearing the bookmark must auto-clear this flag in the same transaction.
- **`is_completed` on Reading Progress** transitions `false → true` only — never reset it.
- **Tag activation:** A `Tag Proposal` must reach `status = approved` before the tag is considered active on a series. AI-sourced proposals require admin approval.
- **Conversation access:** Only between confirmed friends (`Friend Request.status = accepted`) or when one participant is an administrator.
- **Uploader constraint:** Non-admin chapter uploaders must have `Personnel.group_id = Chapter.group_id`.
- **`Series.available_languages`** is a cached string array — auto-updated from child chapter records whenever a chapter is added or its language changes.
