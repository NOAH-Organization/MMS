# NOAH Manga Management System (NOAH MMS) — Database Design

**Last revised:** 12/05/2026 12:00 PM

Based on the functional requirements and the anticipated operational needs of the system, MMS uses a relational database as its primary data store.

---

## Data Requirements

### General Requirements

Fields marked with `*` are **required** — they must not be null and, where applicable, their foreign key relationships must be satisfied. Fields marked **`ro` (read-only)** may not be modified after the record is created.

For primitive data types (excluding booleans), the default value is `null` unless a specific default is stated, signifying the absence of data. Count and total fields default to `0` unless stated otherwise. The system does not need high-precision decimal arithmetic, so `float` is the appropriate type for decimal values, rounded to 2 decimal places. Fields that represent image data (cover images, page images, etc.) must store a URL pointing to where the image is hosted.

Every entity must have a tracking `id` using the database's latest native UUID implementation. Every entity must also carry management metadata: `created_at`, `updated_at`, `deleted_at`, and `is_deleted` (defaults to `false`). The system supports **soft-delete** — hard deletion through the web interface is not supported. These metadata fields are managed by the system and are not directly controlled by users. All datetime fields must follow the format `DD-MM-YYYY hh:mm:ss` or `DD-MM-YYYY`.

Entities that represent manga content (series, chapters, volumes) must contain fields covering the following aspects: **identification**, **content information**, **publication information**, and **user statistics**. Note that some publication fields may appear similar to content fields but carry different meanings — for example, "total published chapters" (official release data) vs. "highest chapter number currently in the system" (system data). The current chapter and volume counts in the system must be computed automatically. Similarly, user statistics are aggregated from user interactions (comments, ratings, reads, etc.) and are also computed automatically.

For entity relationships: **many-to-many** relationships require a separate junction table storing both foreign keys. **One-to-many** and **zero-to-many** relationships require the "many" side to store the foreign key of the other entity.

---

### Manga (Series)

A manga series must carry complete information for display, advanced search, and management purposes. A series may have multiple authors, multiple artists, and zero or more chapters and volumes. Both the **original-language title** (e.g. Japanese for manga) and an **English title** are required. The original-language title must be written in its native script — for example, `ドラえもん` rather than the romanized form `Doraemon`. A series can be read, commented on, rated, and bookmarked by multiple users.

#### Manga Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*original_title` | ro — title in the work's source language (Japanese for manga, Chinese for manhua, Korean for manhwa, etc.) |
| | `*english_title` | for search convenience |
| | `vietnamese_title` | |
| | `alt_titles` | aliases, abbreviations, alternate names |
| **Content Info** | `description` | plot summary |
| | `cover_image` | URL |
| | `background_image` | URL |
| | `highest_chapter` | highest chapter number currently in the system (auto-computed) |
| | `highest_volume` | highest volume number currently in the system (auto-computed) |
| **Publication Info** | `*status` | one of: `upcoming`, `ongoing`, `finished`, `hiatus`, `cancelled` — default `upcoming` |
| | `latest_chapter` | latest officially released chapter number |
| | `latest_volume` | latest officially released volume number |
| | `start_year` | |
| | `end_year` | |
| | `country` | |
| | `platforms` | platforms the series is available on |
| | `series_type` | one of: `manga` (Japan), `manhua` (China), `manhwa` (Korea), `comic` (other) — default `manga` |
| | `chapter_type` | one of: `oneshot`, `series`, `anthology` — default `series` |
| | `content_rating` | one of: `everyone`, `teen`, `mature`, `explicit` — governs content-filter visibility |
| **Moderation** | `is_suspended` | default `false` — administrator-imposed visibility override; hides the title from all personnel without permanent deletion |
| **User Stats** | `avg_rating` | auto-computed |
| | `total_ratings` | auto-computed |
| | `total_reads` | auto-computed |
| | `total_comments` | auto-computed |
| | `total_bookmarks` | auto-computed |

#### Manga Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Author | many-to-many | |
| Artist | many-to-many | |
| Tags | many-to-many | |
| Chapter | zero-to-many | a series can have 0–many chapters; each chapter belongs to exactly one series |
| Volume | one-to-many | a series can have 1–many volumes; each volume belongs to exactly one series |
| Character | one-to-many | a series can have 1–many characters; each character belongs to exactly one series |
| User — Read | many-to-many | junction carries `notify_on_new_chapter` flag — see Multi-Entity Relationships |
| User — Comment | — | handled by the polymorphic Comment entity via `manga_id`; no junction table |
| User — Rating | many-to-many | |
| User — Bookmark | many-to-many | |

---

### Volume

A volume must carry complete information for display, advanced search, and management. A volume may contain zero or more chapters, but belongs to exactly one series. Every series has a default **Volume 0**, which acts as a catch-all for chapters that do not belong to any known published volume ("No Volume"). Volume 0 is the default assignment for any newly added chapter.

#### Volume Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*volume_number` | ro |
| | `title` | optional volume title |
| **Publication Info** | `release_date` | |
| | `publisher` | default `"unknown"` |
| | `isbn` | International Standard Book Number |
| | `edition` | e.g. anniversary, collab, standard — default `"standard"` |
| | `published_chapter_start` | first chapter number in the official release |
| | `published_chapter_end` | last chapter number in the official release |
| | `store_links` | online stores where this volume is available |
| | `price` | key-value map of prices in different currencies |
| **Content Info** | `description` | context and plot summary for this volume |
| | `cover_image` | front cover URL |
| | `current_chapter_start` | first chapter currently in the system for this volume |
| | `current_chapter_end` | last chapter currently in the system for this volume |
| | `total_pages` | total page count currently in the system |
| **User Stats** | `avg_rating` | auto-computed from chapters in this volume |
| | `total_ratings` | auto-computed |
| | `total_reads` | auto-computed |
| | `total_comments` | auto-computed |
| | `total_bookmarks` | auto-computed from PageBookmark records across all chapters belonging to this volume |

#### Volume Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Manga (Series) | many-to-one | `*series_id`, `*series_original_title` — title is stored here to avoid joins at display time, since a series' original title is read-only and will never change |
| Chapter | zero-to-many | a volume can have 0–many chapters; each chapter belongs to exactly one volume |

---

### Chapter

A chapter must carry complete information for display, advanced search, and management. Every chapter must belong to exactly one series and exactly one volume (Volume 0 is the default). Multiple translations of the same chapter number may exist — different languages or multiple translations in the same language. Each chapter may only be translated by one group, or it may be an official release (in which case the publisher is considered the translation group). Users can read, comment on, rate, and bookmark chapters.

#### Chapter Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*chapter_number` | ro |
| | `title` | optional chapter title |
| **Publication Info** | `release_date` | |
| | `*language` | language of this chapter version — can be the source language (Japanese, Korean, Chinese) or a translated language (English, Vietnamese); default `"none"` (for wordless chapters) |
| | `is_official` | whether this is an official translation — default `false` |
| **Content Info** | `description` | chapter summary |
| | `*page_count` | always a positive integer; every chapter must have at least one page |
| | `is_special` | marks anniversary or special end-of-volume chapters — default `false` |
| | `*pages` | JSONB array of page objects, each containing metadata such as order, URL, and dimensions |
| **User Stats** | `avg_rating` | auto-computed |
| | `total_ratings` | auto-computed |
| | `total_reads` | auto-computed |
| | `total_comments` | auto-computed |
| | `total_bookmarks` | auto-computed |

#### Chapter Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Manga (Series) | many-to-one | `*series_id`, `*series_original_title` — stored for the same reason as in Volume |
| Volume | many-to-one | `*volume_id`, `*volume_number` — note Volume 0 as the default |
| Translation Group | many-to-one | `*group_id` — the group that translated this chapter; for official releases the publisher is recorded as the group |
| Character | many-to-many | |
| User — Upload | many-to-one | `*uploader_id` — the user (typically an admin) who added this chapter to the system |
| User — Read | many-to-many | |
| User — Comment | — | handled by the polymorphic Comment entity via `chapter_id`; no junction table |
| User — Rating | many-to-many | |

---

### Tags

Tags provide metadata for categorization and advanced search. A series can have many tags; a tag can belong to many series. Tags may also belong to different groups, enabling deeper filtering.

#### Tags Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | |
| | `*name` | tag or genre name, e.g. `Slice of Life`, `Romance`, `Shounen` |
| **Content Info** | `description` | explanation of what the tag means |
| | `group` | the category this tag belongs to, e.g. theme (fantasy, sci-fi), character type (villainess), narrative style (isekai), genre (action, romance), demographic (shounen, shoujo) |

#### Tags Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Manga (Series) | many-to-many | |

---

### Author / Artist

Stores personal information and works for authors and artists. A single person can be both an author and an artist, only an author, or only an artist — at least one role is required. The pen name the person uses publicly should be used as the display name rather than their legal name.

#### Author / Artist Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | |
| | `*pen_name` | the name or pseudonym this person uses publicly |
| | `native_name` | name in their native language/script |
| | `alt_names` | list of other aliases |
| **Personal Info** | `bio` | brief biography and works overview |
| | `birth_date` | |
| | `death_date` | |
| | `nationality` | |
| | `gender` | |
| | `social_links` | key-value map of social media URLs (X/Twitter, Pixiv, Facebook, etc.) |
| **Work Info** | `total_works_official` | total number of works they have created — may not match the system count |
| | `total_works_in_system` | number of their works currently in the system (auto-computed) |
| | `is_author` | whether this person is credited as an author |
| | `is_artist` | whether this person is credited as an artist |

#### Author / Artist Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Manga — as Author | many-to-many | story/writing credit |
| Manga — as Artist | many-to-many | illustration credit |
| User — Follow | many-to-many | users can follow an author/artist |

---

### Character

A character entity stores profile information for named characters appearing in a series. Characters are scoped to a single series, though they may appear across multiple chapters within it. Character pages are viewable by all personnel.

#### Character Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*name` | primary display name |
| | `aliases` | list of alternate names or nicknames |
| **Description** | `role` | one of: `protagonist`, `antagonist`, `supporting`, `other` |
| | `description` | character background and role in the story |
| | `image_url` | URL |

#### Character Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Manga (Series) | many-to-one | `*series_id`, `*series_original_title` — a character belongs to exactly one series |
| Chapter | many-to-many | chapters in which this character appears |

---

### Translation Group

A translation group is the team responsible for translating a chapter. Each chapter is attributed to exactly one group. Official publisher releases are treated as a group where `is_official_publisher` is `true`. Members of a group are optionally tracked via a junction to User.

#### Translation Group Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | |
| | `*name` | |
| | `alt_names` | list of alternate names or abbreviations |
| **Info** | `description` | |
| | `website_url` | URL |
| | `languages` | list of languages this group works in |
| | `is_official_publisher` | marks an official publisher (e.g. Viz Media, Yen Press) — default `false` |
| **Stats** | `total_chapters_translated` | auto-computed |

#### Translation Group Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Chapter | one-to-many | a group can translate many chapters; each chapter has one group |
| User — Member | many-to-many | optional tracking of which users are members of the group |

---

### User / Personnel

A user account represents one personnel member or administrator. All accounts are administrator-provisioned — self-registration is not supported. The `password_hash` field is write-only and must never be returned by any API endpoint. Reading statistics visibility is configurable per user.

#### User Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*username` | ro — unique, used for login only; not the display name |
| | `*email` | ro — unique, used for login and password reset |
| **Account Info** | `display_name` | shown on profile; defaults to username |
| | `password_hash` | ro — bcrypt (min cost 12) or Argon2id; write-only, never exposed via API |
| | `avatar_url` | URL |
| | `bio` | |
| | `*role` | one of: `personnel`, `administrator` — default `personnel` |
| | `*account_status` | one of: `active`, `suspended`, `deleted` — default `active` |
| | `reading_stats_privacy` | one of: `public`, `friends_only` — default `public` |
| | `last_active_at` | updated on every successful login and authenticated request |
| **Security** | `is_2fa_enabled` | default `false` |
| | `2fa_method` | one of: `authenticator_app`, `sms` — `null` if 2FA is disabled |
| | `phone_number` | stored encrypted — required when `2fa_method` is `sms`; `null` otherwise; never exposed via API |
| | `2fa_secret` | stored encrypted — `null` if 2FA is disabled; never exposed via API |
| | `failed_login_attempts` | default `0`; reset on successful login |
| | `locked_until` | `null` if not locked; auto-set after exceeding the failed-attempt threshold |
| **Activity Stats** | `total_titles_read` | auto-computed |
| | `total_chapters_read` | auto-computed |

#### User Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Manga — Reading | many-to-many | series-level watchlist/read |
| Manga — Rating | many-to-many | star-scale rating (see Decision #11) |
| Chapter — Upload | one-to-many | chapters this user has added to the system |
| Reading Progress | one-to-many | per-chapter reading state (see Reading Progress entity) |
| Page Bookmark | one-to-many | page-level bookmarks within chapters (see Page Bookmark entity) |
| Comment — Authored | one-to-many | |
| Post — Authored | one-to-many | |
| Post — Vote | many-to-many | binary upvote/downvote per post (see Decision #1) |
| Friend Request | many-to-many | self-referential via Friend Request entity |
| Direct Message | many-to-many | via Conversation entity |
| Notification — Received | one-to-many | |
| Author/Artist — Follow | many-to-many | |
| Translation Group — Member | many-to-many | optional group membership |
| User Preference | one-to-one | reading and display settings |
| Token | one-to-many | refresh and password-reset tokens |

---

### User Preference

Stores per-user reading and display settings. Exactly one record exists per user; it is created with default values when the account is provisioned. Settings persist across sessions and devices.

#### User Preference Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*user_id` | ro — primary key; one-to-one with User |
| **Reading** | `reading_direction` | one of: `rtl`, `ltr` — default `rtl` |
| | `page_display_mode` | one of: `single`, `double_spread`, `long_strip` — default `single` |
| | `page_fit` | one of: `fit_width`, `fit_height`, `original` — default `fit_width` |

#### User Preference Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User | one-to-one | `*user_id` |

---

### Token

A general-purpose token record covering two lifecycles: `refresh` tokens (used to obtain new access tokens without re-authentication) and `password_reset` tokens (single-use, authorises one password change via an emailed link). Tokens are stored as hashes — the plaintext is generated once, returned to the caller, and never persisted. Records are invalidated by setting `revoked_at` rather than being deleted. The soft-delete fields and management metadata described in General Requirements do not apply to this entity.

#### Token Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*user_id` | ro |
| | `*type` | ro — one of: `refresh`, `password_reset` |
| **Content** | `*token_hash` | ro — hash of the plaintext token; plaintext is never stored |
| **Lifecycle** | `*issued_at` | ro — set by the system on insert |
| | `*expires_at` | absolute expiry timestamp |
| | `revoked_at` | `null` if still valid; set on use (for `password_reset`), rotation (for `refresh`), or explicit revocation |

#### Token Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User | many-to-one | `*user_id` — a user may hold multiple active tokens of different types |

---

### Friend Request

Represents a directed friendship request between two users. A mutual `accepted` status constitutes a friendship. The `blocked` status prevents further contact in either direction.

#### Friend Request Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*requester_id` | ro |
| | `*addressee_id` | ro |
| **State** | `*status` | one of: `pending`, `accepted`, `rejected`, `blocked` — default `pending` |
| | `requested_at` | ro |
| | `responded_at` | `null` until the addressee acts |

#### Friend Request Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Requester | many-to-one | |
| User — Addressee | many-to-one | |

---

### Post

A post is a piece of user-generated content shared on the activity feed. A post may optionally embed a reference to a manga title, chapter, or a specific page. A repost is a post that points to an existing post; its own `body` acts as optional commentary.

#### Post Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Content** | `*body` | text content of the post |
| | `embedded_reference` | JSONB — optional structured reference: `{ type, id, page_number? }` where type is one of `manga`, `chapter`, `page` |
| | `is_repost` | default `false` |
| | `original_post_id` | ro — `null` if not a repost; references the original post |
| **Stats** | `upvote_count` | auto-computed |
| | `downvote_count` | auto-computed |
| | `comment_count` | auto-computed |
| | `repost_count` | auto-computed |

#### Post Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Author | many-to-one | `*author_id` |
| User — Vote | many-to-many | each user casts at most one vote per post; vote direction is stored in the junction (`upvote` / `downvote`) |
| Post — Original | many-to-one | self-referential; `null` unless `is_repost` is `true` |
| Comment | one-to-many | comments targeting this post |

---

### Comment

A comment can target a manga series, a chapter, or a post. Exactly one of `manga_id`, `chapter_id`, or `post_id` must be non-null. Comments support one level of threading via `parent_comment_id`.

#### Comment Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Content** | `*body` | text content |
| | `parent_comment_id` | `null` for top-level comments; references parent comment for replies |
| **Target** | `manga_id` | `null` if not on a manga series |
| | `chapter_id` | `null` if not on a chapter |
| | `post_id` | `null` if not on a post |

#### Comment Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Author | many-to-one | `*author_id` |
| Manga | many-to-one | nullable |
| Chapter | many-to-one | nullable |
| Post | many-to-one | nullable |
| Comment — Parent | many-to-one | self-referential; nullable |

---

### Conversation

A direct-message thread between exactly two users. Messaging is restricted to mutually confirmed friends and administrators (see Decision #2). The initial release supports text-only messages.

#### Conversation Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **State** | `last_message_at` | auto-updated on each new message |

#### Conversation Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Participant A | many-to-one | `*participant_a_id` |
| User — Participant B | many-to-one | `*participant_b_id` |
| Message | one-to-many | |

---

### Message

An individual message within a Conversation. `sent_at` is equivalent to `created_at` and is set by the system on insert.

#### Message Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Content** | `*body` | text content — text only in the initial release |
| **State** | `*is_read` | default `false` |
| | `*sent_at` | ro — set by the system on insert |

#### Message Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| Conversation | many-to-one | `*conversation_id` |
| User — Sender | many-to-one | `*sender_id` |

---

### Notification

An in-app notification delivered to a user. The `reference` field is a JSONB payload carrying enough data to deep-link to the triggering entity without a separate query.

#### Notification Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Content** | `*type` | one of: `friend_request`, `post_reply`, `direct_message`, `new_chapter` |
| | `*is_read` | default `false` |
| | `reference` | JSONB — e.g. `{ type: "chapter", id: "...", series_title: "..." }` |

#### Notification Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Recipient | many-to-one | `*recipient_id` |

---

### Reading Progress

Tracks a user's reading state for a specific chapter. Series-level completion percentage is computed from this table (chapters completed ÷ total chapters). `last_read_at` is updated on every read event.

#### Reading Progress Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*user_id` | ro — composite primary key with `chapter_id` |
| | `*chapter_id` | ro |
| **State** | `*last_page` | the most recent page the user viewed |
| | `*is_completed` | default `false`; set to `true` when the user reaches the last page |
| | `last_read_at` | updated on every read event |

#### Reading Progress Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User | many-to-one | |
| Chapter | many-to-one | |

---

### Page Bookmark

Records a user-placed bookmark on a specific page within a chapter (UC-01-10). This is distinct from the series-level bookmark (User → Manga many-to-many). An optional `note` allows the user to annotate the bookmark.

#### Page Bookmark Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*user_id` | ro |
| | `*chapter_id` | ro |
| | `*page_number` | ro — the specific page that was bookmarked |
| **Content** | `note` | optional user annotation |
| | `bookmarked_at` | ro — set by the system on insert |

#### Page Bookmark Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User | many-to-one | |
| Chapter | many-to-one | |

---

### Scrape Job

Represents a content ingestion job triggered by an administrator — either a one-off scrape from a URL or a scheduled recurring job. Job history is retained for auditing and the content dashboard (UC-06-08).

#### Scrape Job Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Configuration** | `*source_url` | ro |
| | `target_manga_id` | ro — `null` if this job creates a new title; references an existing series if updating |
| | `is_recurring` | default `false` |
| | `schedule` | cron expression — `null` if `is_recurring` is `false` |
| **Execution** | `*status` | one of: `pending`, `running`, `completed`, `failed`, `cancelled` — default `pending` |
| | `started_at` | `null` until the job begins |
| | `completed_at` | `null` until the job ends |
| | `result_summary` | JSONB — e.g. `{ chapters_added, pages_added, errors }` |
| | `error_details` | JSONB — `null` if no errors |

#### Scrape Job Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Created By | many-to-one | `*created_by` — the administrator who initiated the job |
| Manga | zero-to-one | `target_manga_id` — `null` for new-title ingestion |

---

### Audit Log

> **Observability note:** `AuditLog` records are **not stored in the main application database**. They are emitted as structured telemetry events to the observability stack (OpenTelemetry / OTEL) and consumed by a dedicated logging backend. This entity definition describes the event schema only — it has no ORM model or migration in the main service.

An append-only record of administrator actions that create, modify, or delete data. Audit log entries are permanent and exempt from soft-delete. The `metadata` field captures a before/after snapshot of affected fields where applicable.

#### Audit Log Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Event** | `*actor_id` | ro — the administrator who performed the action |
| | `*action_type` | ro — e.g. `create_manga`, `delete_user`, `suspend_account`, `assign_role`, `force_password_reset` |
| | `*affected_entity_type` | ro — e.g. `manga`, `user`, `chapter`, `scrape_job` |
| | `*affected_entity_id` | ro |
| | `*timestamp` | ro |
| | `*source_ip` | ro |
| | `metadata` | JSONB — before/after snapshot of changed fields; `null` if not applicable |

> Note: Audit logs are append-only and permanent. The soft-delete fields and management metadata described in General Requirements do not apply to this entity.

#### Audit Log Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User — Actor | many-to-one | `*actor_id` — always an administrator |

---

### User Log

> **Observability note:** `UserLog` records are **not stored in the main application database**. They are emitted as structured telemetry events to the observability stack (OpenTelemetry / OTEL) and consumed by a dedicated logging backend. This entity definition describes the event schema only — it has no ORM model or migration in the main service.

An event record capturing user activity on the system. Covers both authentication events (login, logout, failed login) and content interactions (read, rate, comment, bookmark). The `metadata` payload carries action-specific context. Records are append-only and permanent; the soft-delete fields and management metadata described in General Requirements do not apply to this entity.

#### User Log Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| | `*user_id` | ro |
| **Event** | `*action_type` | ro — one of: `login`, `logout`, `read_chapter`, `rate_manga`, `rate_chapter`, `comment`, `bookmark_series`, `bookmark_page`, `password_reset_request` |
| | `*timestamp` | ro — set by the system on emission |
| | `*success` | ro — `true` if the action completed successfully; `false` for failed attempts (e.g. failed login) |
| **Context** | `source_ip` | ro |
| | `user_agent` | ro |
| | `metadata` | ro — JSONB; action-specific context, e.g. `{ series_id, chapter_id }` for read events |

#### User Log Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User | many-to-one | `*user_id` — logical reference only; no enforced foreign key in the observability store |

---

### AI Session

Persists the conversation context of a user's interaction with the AI assistant within a single session (§1.1.4). Session context is scoped per user and expires after inactivity. The AI integration layer is model-agnostic (see Decision #10).

#### AI Session Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **State** | `started_at` | ro |
| | `last_active_at` | updated on every message |

#### AI Session Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| User | many-to-one | `*user_id` |
| AI Message | one-to-many | |

---

### AI Message

A single turn within an AI Session. `role` distinguishes user input from assistant output. Records are immutable once written.

#### AI Message Own Fields

| Category | Field | Notes |
| --- | --- | --- |
| **Identification** | `*id` | ro |
| **Content** | `*role` | ro — one of: `user`, `assistant` |
| | `*content` | ro — text content of the message |
| | `*sent_at` | ro — set by the system on insert |

#### AI Message Foreign Relationships

| Entity | Relationship | Notes |
| --- | --- | --- |
| AI Session | many-to-one | `*session_id` |

---

### Relationships

#### Binary Relationships

Relationships between exactly two entity types. One-to-many relationships are implemented by storing the foreign key on the "many" side. Many-to-many relationships are implemented with a pure junction table (two FK columns only, no extra data).

| Entity A | Cardinality | Entity B | Notes |
| --- | --- | --- | --- |
| Manga | many-to-many | Author/Artist | writing credit — separate junction from artist credit |
| Manga | many-to-many | Author/Artist | illustration credit — separate junction from author credit |
| Manga | many-to-many | Tags | |
| Manga | one-to-many | Volume | a series must have at least one volume, including default Vol 0 |
| Manga | zero-to-many | Chapter | chapters are optional at the series level |
| Manga | one-to-many | Character | characters are scoped to one series |
| Manga | many-to-many | User | bookmark / watchlist |
| Volume | zero-to-many | Chapter | Vol 0 is the default container for unassigned chapters |
| Chapter | many-to-one | Translation Group | each chapter has exactly one translating group |
| Chapter | many-to-one | User | upload — the user (typically admin) who added the chapter |
| Chapter | many-to-many | Character | characters appearing in this chapter |
| Translation Group | many-to-many | User | group membership (optional) |
| User | many-to-many | Author/Artist | follow |
| User | one-to-many | Post | authorship |
| User | one-to-many | Comment | authorship |
| User | one-to-many | Notification | recipient |
| User | one-to-many | AI Session | |
| User | one-to-many | Scrape Job | created by (admin only) |
| User | one-to-many | Audit Log | actor (admin only) — OTEL only |
| User | one-to-one | User Preference | reading and display settings |
| User | one-to-many | Token | refresh and password-reset tokens |
| User | one-to-many | User Log | activity events — OTEL only |
| Post | many-to-one (self) | Post | repost — an `is_repost` post references its original |
| Post | one-to-many | Comment | comments on a post |
| Comment | many-to-one (self) | Comment | reply — references parent comment; nullable |
| Comment | many-to-one | Manga | nullable target — exactly one of the three target FKs is non-null per row |
| Comment | many-to-one | Chapter | nullable target |
| Comment | many-to-one | Post | nullable target |
| Conversation | many-to-one | User | participant A (`*participant_a_id`) |
| Conversation | many-to-one | User | participant B (`*participant_b_id`) |
| Conversation | one-to-many | Message | |
| Message | many-to-one | User | sender |
| Scrape Job | zero-to-one | Manga | optional target series; `null` for new-title ingestion |
| AI Session | one-to-many | AI Message | |

---

#### Multi-Entity Relationships

Relationships that cannot be expressed as a simple two-column FK or pure junction table — either because they involve three or more entity types simultaneously, or because the junction itself carries its own attributes (making it an intersection entity or a keyed association).

**User × Manga — Reading / Watchlist**
Tracks a user's series-level reading state and notification subscription. The junction stores one attribute: `notify_on_new_chapter` (boolean, default `false`). This flag may only be `true` while a corresponding User × Manga bookmark entry exists for the same series; it must be automatically cleared when the series-level bookmark is removed.

**User × Manga — Rating**
A user assigns a star-scale rating to a manga series (Decision #11). The junction stores the numeric rating value in addition to the two foreign keys. One rating per user per series.

**User × Chapter — Rating**
A user assigns a star-scale rating to a specific chapter. Same structure as Manga rating; one rating per user per chapter.

**User × Post — Vote**
A user casts a binary vote on a post (Decision #1: upvote or downvote). The junction stores the vote direction alongside the two foreign keys. At most one vote per user per post.

**Reading Progress — User × Chapter**
Tracks a user's reading state within a specific chapter. Acts as an intersection entity with its own attributes: `last_page`, `is_completed`, and `last_read_at`. The composite primary key is `(user_id, chapter_id)`. Series-level completion percentage is derived from aggregating this table.

**Page Bookmark — User × Chapter × Page**
Anchors a user-placed bookmark to a specific page within a chapter. `page_number` is part of the logical key alongside `user_id` and `chapter_id`, making this a three-dimensional association. Carries an optional `note` attribute. Distinct from the series-level watchlist (User × Manga bookmark).

**Friend Request — User × User (directed)**
A self-referential relationship between two User instances with explicitly directed roles (`requester`, `addressee`) and a status lifecycle: `pending → accepted | rejected | blocked`. An `accepted` status from both directions constitutes a confirmed friendship.

**Conversation — User × User (symmetric DM channel)**
A direct-message channel between exactly two User instances with symmetric participant roles (`participant_a`, `participant_b`). Unlike Friend Request, roles carry no hierarchy. Constrained to confirmed friends or administrator involvement (Decision #2). The channel persists independently and aggregates Messages over time.

**Comment — User × Polymorphic Target**
A comment is authored by one User and targets exactly one of three entity types: Manga, Chapter, or Post. This is enforced at the application level — exactly one of `manga_id`, `chapter_id`, `post_id` is non-null per row. Comments additionally support self-referential threading via `parent_comment_id`, making the full association: User (author) × {Manga | Chapter | Post} (target) × Comment (optional parent).

**Chapter — Tri-parent Association (Manga × Volume × Translation Group)**
Every chapter simultaneously references three parent entities: the Manga series it belongs to, the Volume within that series, and the Translation Group that produced the translation. No chapter can exist without all three. This is the only relationship in the schema where a single entity is simultaneously and unconditionally dependent on three distinct parents.

---

## Open Issues — Data Requirements Review

**Review date:** 12/05/2026  
**Source documents:** `REQUIREMENTS.md`, `USECASES.md`

The following issues were identified by cross-referencing this document against the functional requirements and use case list. Each issue carries a **Decision** field to be resolved before implementation of the affected entity begins.

---

### Critical Gaps

These represent data that must exist for a use case or requirement to be implementable.

---

#### I-01 — `username` marked `ro` conflicts with UC-02-05

**Affected entity:** User  
**References:** UC-02-05, §1.1.2

`username` is currently marked `ro` (immutable after creation), but UC-02-05 explicitly permits personnel to edit their username. These are directly contradictory. One of the two must be changed before the account-editing subsystem is designed.

**Decision:** `username` remains `ro`. `display_name` is the user-editable public-facing name and is what UC-02-05 governs. `username` is used for login only and must be unique across all users. The field note has been updated accordingly.

---

#### I-02 — `last_active_at` missing from User

**Affected entity:** User  
**References:** UC-07-02, §1.2.2

§1.2.2 requires administrators to view a personnel's "last active date" as part of the account metadata view. The general metadata fields (`created_at`, `updated_at`) do not carry this semantic — `updated_at` reflects record modification, not user activity. A dedicated `last_active_at` (or `last_login_at`) field must be added to the User entity and updated on every successful login and authenticated request.

**Decision:** Approved. `last_active_at` added to User entity under Account Info; updated on every successful login and authenticated request.

---

#### I-03 — `phone_number` missing from User

**Affected entity:** User  
**References:** §1.1.2 (2FA)

The User entity defines `2fa_method` with a valid value of `sms`, but stores no phone number. Without a phone number field, SMS-based 2FA cannot be implemented. The field should be stored encrypted given its sensitivity.

**Decision:** Approved. `phone_number` (stored encrypted, never exposed via API) added to User entity under Security. It is required only when `2fa_method` is `sms`; null otherwise.

---

#### I-04 — Password reset token not modeled

**Affected entity:** *(new entity or User fields)*  
**References:** UC-02-03

UC-02-03 requires a password reset link to be sent to the user's registered email. This requires a short-lived, single-use token stored server-side. Currently no `PasswordResetToken` entity or equivalent fields (`reset_token_hash`, `reset_token_expires_at`) exist. Options are a separate entity or additional fields on User; either must ensure the token hash (never plaintext) and an expiry timestamp are stored.

**Decision:** *(Resolved jointly with I-05.)* A single `Token` entity was introduced to cover both password-reset and refresh token lifecycles, distinguished by a `type` field. See the Token entity definition.

---

#### I-05 — Refresh token storage not modeled

**Affected entity:** *(new entity)*  
**References:** NFR §2.1 item 4

§2.1 item 4 mandates refresh token rotation. Refresh tokens must be persisted server-side to support revocation and rotation. No `RefreshToken` entity or equivalent exists in the current schema. A typical shape: `id`, `*user_id`, `token_hash` (ro), `issued_at` (ro), `expires_at`, `revoked_at`.

**Decision:** *(Resolved jointly with I-04.)* A single `Token` entity was introduced to cover both refresh and password-reset token lifecycles, distinguished by a `type` field. See the Token entity definition.

---

#### I-06 — Login history not modeled

**Affected entity:** *(new entity)*  
**References:** UC-07-09

UC-07-09 requires admins to view per-personnel activity summaries that explicitly include **login history**. The `AuditLog` only captures administrator actions — regular user logins are not recorded there. A `LoginHistory` entity is needed, capturing at minimum: `user_id`, `timestamp`, `source_ip`, `user_agent`, and a `success` flag (to cover failed attempts as well).

**Decision:** A `UserLog` entity was introduced. It captures login, logout, failed-login events alongside all content interactions (read, rate, comment, bookmark). Both `UserLog` and `AuditLog` are designated **OTEL-only** — they are emitted as telemetry events and are not stored in the main application database. OTEL notes have been added to both entity definitions.

---

#### I-07 — Manga admin-suspension state not modeled

**Affected entity:** Manga  
**References:** UC-06-05

UC-06-05 requires suspending and unsuspending a manga title — hiding it from personnel view without deleting it. The existing `status` enum (`upcoming`, `ongoing`, `finished`, `hiatus`, `cancelled`) reflects publication state and must not be conflated with moderation state; overloading it would corrupt publication data. A separate `is_suspended` boolean field on Manga is required to represent an administrator-imposed visibility override.

**Decision:** Approved. `is_suspended` (boolean, default `false`) added to Manga entity under a new Moderation category, separate from the publication `status` field.

---

#### I-08 — User reading preferences not modeled

**Affected entity:** *(new entity or User field)*  
**References:** UC-01-07, UC-01-08, UC-01-09

Three use cases require persistent reading configuration per user:

- UC-01-07 — reading direction (RTL / LTR)
- UC-01-08 — page display mode (single / double-spread / long-strip)
- UC-01-09 — page fit option (width / height / original)

None of these are stored in the current schema. If the settings are to persist across sessions and devices (as "configure" implies), a `UserPreference` entity or a JSONB `preferences` column on User is required. Deferring to browser storage only would reset the configuration on every new device or browser.

**Decision:** A `UserPreference` entity was introduced with `user_id` as its sole primary key (one-to-one with User). It stores `reading_direction`, `page_display_mode`, and `page_fit`. The record is created with default values when a user account is provisioned.

---

### Design Inconsistencies

These entries do not block implementation outright, but represent modelling decisions that are ambiguous or contradictory within the document itself.

---

#### I-09 — "User — Comment" listed as many-to-many on Manga and Chapter

**Affected entities:** Manga (Foreign Relationships), Chapter (Foreign Relationships)  
**References:** Comment entity definition

Both the Manga and Chapter foreign relationship tables list `User — Comment | many-to-many`, implying a junction table. However, comments are handled through the polymorphic `Comment` entity with nullable `manga_id` / `chapter_id` columns — no junction table exists or is needed. These rows should either be removed or replaced with a note referencing the Comment entity.

**Decision:** The `User — Comment | many-to-many` rows in both Manga and Chapter foreign relationship tables have been replaced with a note (`—`) referencing the polymorphic Comment entity and its relevant nullable FK column. No junction table is introduced.

---

#### I-10 — "User — Bookmark" listed as many-to-many on Chapter — undefined junction

**Affected entity:** Chapter (Foreign Relationships)  
**References:** Page Bookmark entity, UC-01-10

The Chapter foreign relationship table lists `User — Bookmark | many-to-many`, but there is no defined chapter-level bookmark anywhere in the schema. The two bookmark types in the design are:

- Series-level bookmark: User × Manga junction.
- Page-level bookmark: `PageBookmark` entity (UC-01-10).

No use case, junction table, or multi-entity relationship description covers a chapter-level bookmark. This row should be removed or a chapter-level bookmark must be explicitly defined with its own rationale.

**Decision:** Chapter-level bookmarks are not supported. The `User — Bookmark | many-to-many` row has been removed from the Chapter foreign relationship table. The two supported bookmark scopes remain: series-level (User × Manga junction) and page-level (PageBookmark entity).

---

#### I-11 — Volume `total_bookmarks` has no supporting relationship

**Affected entity:** Volume  
**References:** Volume User Stats

The Volume entity includes `total_bookmarks` in its user statistics block, but no User × Volume bookmark relationship exists anywhere in the schema. Series-level bookmarks are User × Manga, and no aggregation path from that to a per-volume count is defined. Either the computation source must be specified or the field must be removed.

**Decision:** `total_bookmarks` on Volume is aggregated from PageBookmark records across all chapters belonging to that volume. The field note has been updated accordingly.

---

#### I-12 — User × Manga reading junction lacks a notification subscription flag

**Affected entity:** User × Manga junction (reading / watchlist)  
**References:** UC-03-11, Notification `new_chapter` type

UC-03-11 requires in-app notifications when new chapters are released for titles a user follows. The `new_chapter` notification type exists, but there is no mechanism in the schema to determine which users should receive it. The User × Manga "Reading / Watchlist" junction is the only plausible source, but it is currently a pure two-column junction with no attributes. It needs at minimum a `notify_on_new_chapter` boolean to distinguish passive read history from an active subscription, or a separate follow/subscription relationship must be introduced.

**Decision:** Approved. `notify_on_new_chapter` (boolean, default `false`) added to the User × Manga reading junction. It may only be `true` when a corresponding series-level bookmark exists for the same user–series pair; it is automatically cleared when the bookmark is removed. The junction is now documented in Multi-Entity Relationships. The Manga Foreign Relationships table has been updated with a reference.

---

### Documentation Issues

Minor inconsistencies between documents or within this document that should be corrected before the design is finalized.

---

#### I-13 — Use case ID mismatch across documents

**References:** REQUIREMENTS.md §1.1.4, USECASES.md SS-05

`REQUIREMENTS.md §1.1.4` cites `UC-05-95` for the AI assistant's honest-acknowledgement behavior. `USECASES.md` lists the same use case as `UC-05-05`. One document must be corrected to align them.

**Decision:** Already resolved in `REQUIREMENTS.md`. No changes required in this document.

---

#### I-14 — UC-01-11 absent from USECASES.md

**References:** USECASES.md SS-01

The use case list in SS-01 jumps from UC-01-10 directly to UC-01-12. If UC-01-11 was deliberately removed, a note should be added. If it is a numbering error, the subsequent IDs must be corrected.

**Decision:** UC-01-11 was deliberately cancelled and removed from `USECASES.md`. The gap in numbering is intentional — a design choice to preserve the IDs of all remaining use cases. No correction is needed.

---

#### I-15 — Typo in Comment section

**References:** Comment — own entity description

The opening sentence of the Comment section contains a stray double period: *"A comment can target a manga series, a chapter, or a post. . Exactly one…"*

**Decision:** Typo fixed — stray period removed from the Comment section description.
