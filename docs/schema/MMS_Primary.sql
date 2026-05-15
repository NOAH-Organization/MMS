CREATE TYPE "series_status" AS ENUM (
  'upcoming',
  'ongoing',
  'finished',
  'hiatus',
  'cancelled'
);

CREATE TYPE "series_type" AS ENUM (
  'manga',
  'manhua',
  'manhwa',
  'comic'
);

CREATE TYPE "chapter_type" AS ENUM (
  'oneshot',
  'series',
  'anthology'
);

CREATE TYPE "content_rating" AS ENUM (
  'everyone',
  'teen',
  'mature',
  'explicit'
);

CREATE TYPE "personnel_role" AS ENUM (
  'personnel',
  'administrator'
);

CREATE TYPE "account_status" AS ENUM (
  'active',
  'suspended',
  'deleted'
);

CREATE TYPE "reading_stats_privacy" AS ENUM (
  'public',
  'friends_only'
);

CREATE TYPE "tfa_method" AS ENUM (
  'authenticator_app',
  'sms'
);

CREATE TYPE "token_type" AS ENUM (
  'refresh',
  'password_reset'
);

CREATE TYPE "friend_request_status" AS ENUM (
  'pending',
  'accepted',
  'rejected',
  'blocked'
);

CREATE TYPE "post_vote_direction" AS ENUM (
  'upvote',
  'downvote'
);

CREATE TYPE "tag_proposal_status" AS ENUM (
  'pending',
  'approved',
  'rejected'
);

CREATE TYPE "tag_proposal_source" AS ENUM (
  'manual',
  'ai'
);

CREATE TYPE "scrape_job_status" AS ENUM (
  'pending',
  'running',
  'completed',
  'failed',
  'cancelled'
);

CREATE TYPE "reading_direction" AS ENUM (
  'rtl',
  'ltr'
);

CREATE TYPE "page_display_mode" AS ENUM (
  'single',
  'double_spread',
  'long_strip'
);

CREATE TYPE "page_fit" AS ENUM (
  'fit_width',
  'fit_height',
  'original'
);

CREATE TYPE "creator_role" AS ENUM (
  'author',
  'artist'
);

CREATE TYPE "character_role" AS ENUM (
  'protagonist',
  'antagonist',
  'supporting',
  'other'
);

CREATE TYPE "notification_type" AS ENUM (
  'friend_request',
  'post_reply',
  'direct_message',
  'new_chapter'
);

CREATE TABLE "series" (
  "id" uuid PRIMARY KEY NOT NULL,
  "original_title" varchar NOT NULL,
  "english_title" varchar NOT NULL,
  "vietnamese_title" varchar,
  "alt_titles" text[],
  "description" text,
  "cover_image" varchar,
  "background_image" varchar,
  "highest_chapter" float,
  "highest_volume" int,
  "status" series_status NOT NULL DEFAULT 'upcoming',
  "latest_chapter" float,
  "latest_volume" int,
  "start_year" int,
  "end_year" int,
  "country" varchar,
  "platforms" text[],
  "series_type" series_type NOT NULL DEFAULT 'manga',
  "chapter_type" chapter_type NOT NULL DEFAULT 'series',
  "content_rating" content_rating NOT NULL DEFAULT 'everyone',
  "is_suspended" boolean NOT NULL DEFAULT false,
  "avg_rating" float,
  "total_ratings" int NOT NULL DEFAULT 0,
  "total_reads" int NOT NULL DEFAULT 0,
  "total_comments" int NOT NULL DEFAULT 0,
  "total_bookmarks" int NOT NULL DEFAULT 0,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "tags" (
  "id" uuid PRIMARY KEY NOT NULL,
  "name" varchar NOT NULL,
  "description" text,
  "group" varchar,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "creator" (
  "id" uuid PRIMARY KEY NOT NULL,
  "pen_name" varchar NOT NULL,
  "native_name" varchar,
  "alt_names" text[],
  "bio" text,
  "birth_date" date,
  "death_date" date,
  "nationality" varchar,
  "gender" varchar,
  "social_links" jsonb,
  "total_works_official" int,
  "total_works_in_system" int NOT NULL DEFAULT 0,
  "is_author" boolean NOT NULL DEFAULT false,
  "is_artist" boolean NOT NULL DEFAULT false,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "translation_group" (
  "id" uuid PRIMARY KEY NOT NULL,
  "name" varchar NOT NULL,
  "alt_names" text[],
  "description" text,
  "website_url" varchar,
  "languages" text[],
  "is_official_publisher" boolean NOT NULL DEFAULT false,
  "total_chapters_translated" int NOT NULL DEFAULT 0,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "personnel" (
  "id" uuid PRIMARY KEY NOT NULL,
  "username" varchar UNIQUE NOT NULL,
  "email" varchar UNIQUE NOT NULL,
  "display_name" varchar,
  "password_hash" varchar NOT NULL,
  "avatar_url" varchar,
  "bio" text,
  "role" personnel_role NOT NULL DEFAULT 'personnel',
  "account_status" account_status NOT NULL DEFAULT 'active',
  "reading_stats_privacy" reading_stats_privacy NOT NULL DEFAULT 'public',
  "last_active_at" timestamp,
  "group_id" uuid,
  "is_2fa_enabled" boolean NOT NULL DEFAULT false,
  "tfa_method" tfa_method,
  "phone_number" varchar,
  "tfa_secret" varchar,
  "failed_login_attempts" int NOT NULL DEFAULT 0,
  "locked_until" timestamp,
  "total_titles_read" int NOT NULL DEFAULT 0,
  "total_chapters_read" int NOT NULL DEFAULT 0,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "post" (
  "id" uuid PRIMARY KEY NOT NULL,
  "body" text NOT NULL,
  "embedded_reference" jsonb,
  "is_repost" boolean NOT NULL DEFAULT false,
  "original_post_id" uuid,
  "upvote_count" int NOT NULL DEFAULT 0,
  "downvote_count" int NOT NULL DEFAULT 0,
  "comment_count" int NOT NULL DEFAULT 0,
  "repost_count" int NOT NULL DEFAULT 0,
  "author_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "scrape_job" (
  "id" uuid PRIMARY KEY NOT NULL,
  "source_url" varchar NOT NULL,
  "target_manga_id" uuid,
  "is_recurring" boolean NOT NULL DEFAULT false,
  "schedule" varchar,
  "started_at" timestamp,
  "completed_at" timestamp,
  "status" scrape_job_status NOT NULL DEFAULT 'pending',
  "result_summary" jsonb,
  "error_details" jsonb,
  "created_by" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "volume" (
  "id" uuid PRIMARY KEY NOT NULL,
  "volume_number" int NOT NULL,
  "title" varchar,
  "release_date" date,
  "publisher" varchar DEFAULT 'unknown',
  "isbn" varchar,
  "edition" varchar DEFAULT 'standard',
  "published_chapter_start" float,
  "published_chapter_end" float,
  "store_links" jsonb,
  "price" jsonb,
  "description" text,
  "cover_image" varchar,
  "current_chapter_start" float,
  "current_chapter_end" float,
  "total_pages" int NOT NULL DEFAULT 0,
  "avg_rating" float,
  "total_ratings" int NOT NULL DEFAULT 0,
  "total_reads" int NOT NULL DEFAULT 0,
  "total_comments" int NOT NULL DEFAULT 0,
  "total_bookmarks" int NOT NULL DEFAULT 0,
  "series_id" uuid NOT NULL,
  "series_original_title" varchar NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "chapter" (
  "id" uuid PRIMARY KEY NOT NULL,
  "chapter_number" float NOT NULL,
  "title" varchar,
  "release_date" date,
  "language" varchar NOT NULL DEFAULT 'none',
  "is_official" boolean NOT NULL DEFAULT false,
  "description" text,
  "page_count" int NOT NULL,
  "is_special" boolean NOT NULL DEFAULT false,
  "pages" jsonb NOT NULL,
  "avg_rating" float,
  "total_ratings" int NOT NULL DEFAULT 0,
  "total_reads" int NOT NULL DEFAULT 0,
  "total_comments" int NOT NULL DEFAULT 0,
  "total_bookmarks" int NOT NULL DEFAULT 0,
  "series_id" uuid NOT NULL,
  "series_original_title" varchar NOT NULL,
  "volume_id" uuid NOT NULL,
  "volume_number" int NOT NULL,
  "group_id" uuid NOT NULL,
  "uploader_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "character" (
  "id" uuid PRIMARY KEY NOT NULL,
  "name" varchar NOT NULL,
  "aliases" text[],
  "role" character_role,
  "description" text,
  "image_url" varchar,
  "series_id" uuid NOT NULL,
  "series_original_title" varchar NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "user_preference" (
  "user_id" uuid PRIMARY KEY NOT NULL,
  "reading_direction" reading_direction NOT NULL DEFAULT 'rtl',
  "page_display_mode" page_display_mode NOT NULL DEFAULT 'single',
  "page_fit" page_fit NOT NULL DEFAULT 'fit_width',
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE TABLE "token" (
  "id" uuid PRIMARY KEY NOT NULL,
  "user_id" uuid NOT NULL,
  "type" token_type NOT NULL,
  "token_hash" varchar NOT NULL,
  "issued_at" timestamp NOT NULL,
  "expires_at" timestamp NOT NULL,
  "revoked_at" timestamp
);

CREATE TABLE "friend_request" (
  "id" uuid PRIMARY KEY NOT NULL,
  "requester_id" uuid NOT NULL,
  "addressee_id" uuid NOT NULL,
  "status" friend_request_status NOT NULL DEFAULT 'pending',
  "requested_at" timestamp NOT NULL,
  "responded_at" timestamp,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "comment" (
  "id" uuid PRIMARY KEY NOT NULL,
  "body" text NOT NULL,
  "parent_comment_id" uuid,
  "manga_id" uuid,
  "chapter_id" uuid,
  "post_id" uuid,
  "author_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "conversation" (
  "id" uuid PRIMARY KEY NOT NULL,
  "last_message_at" timestamp,
  "participant_a_id" uuid NOT NULL,
  "participant_b_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "message" (
  "id" uuid PRIMARY KEY NOT NULL,
  "body" text NOT NULL,
  "is_read" boolean NOT NULL DEFAULT false,
  "sent_at" timestamp NOT NULL,
  "conversation_id" uuid NOT NULL,
  "sender_id" uuid NOT NULL
);

CREATE TABLE "notification" (
  "id" uuid PRIMARY KEY NOT NULL,
  "type" notification_type NOT NULL,
  "is_read" boolean NOT NULL DEFAULT false,
  "reference" jsonb,
  "recipient_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  "deleted_at" timestamp,
  "is_deleted" boolean NOT NULL DEFAULT false
);

CREATE TABLE "reading_progress" (
  "user_id" uuid NOT NULL,
  "chapter_id" uuid NOT NULL,
  "last_page" int NOT NULL,
  "is_completed" boolean NOT NULL DEFAULT false,
  "last_read_at" timestamp,
  PRIMARY KEY ("user_id", "chapter_id")
);

CREATE TABLE "page_bookmark" (
  "id" uuid PRIMARY KEY NOT NULL,
  "user_id" uuid NOT NULL,
  "chapter_id" uuid NOT NULL,
  "page_number" int NOT NULL,
  "note" text,
  "bookmarked_at" timestamp NOT NULL
);

CREATE TABLE "series_creator_credit" (
  "series_id" uuid NOT NULL,
  "creator_id" uuid NOT NULL,
  "role" creator_role NOT NULL,
  PRIMARY KEY ("series_id", "creator_id", "role")
);

CREATE TABLE "series_user_record" (
  "user_id" uuid NOT NULL,
  "series_id" uuid NOT NULL,
  "is_bookmarked" boolean NOT NULL DEFAULT false,
  "notify_on_new_chapter" boolean NOT NULL DEFAULT false,
  "rating" float,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  PRIMARY KEY ("user_id", "series_id")
);

CREATE TABLE "chapter_rating" (
  "user_id" uuid NOT NULL,
  "chapter_id" uuid NOT NULL,
  "rating" float NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  PRIMARY KEY ("user_id", "chapter_id")
);

CREATE TABLE "post_vote" (
  "user_id" uuid NOT NULL,
  "post_id" uuid NOT NULL,
  "direction" post_vote_direction NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  PRIMARY KEY ("user_id", "post_id")
);

CREATE TABLE "creator_follow" (
  "user_id" uuid NOT NULL,
  "creator_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  PRIMARY KEY ("user_id", "creator_id")
);

CREATE TABLE "tag_proposal" (
  "series_id" uuid NOT NULL,
  "tag_id" uuid NOT NULL,
  "status" tag_proposal_status NOT NULL DEFAULT 'pending',
  "source" tag_proposal_source NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL,
  PRIMARY KEY ("series_id", "tag_id")
);

CREATE TABLE "character_appearance" (
  "chapter_id" uuid NOT NULL,
  "character_id" uuid NOT NULL,
  PRIMARY KEY ("chapter_id", "character_id")
);

CREATE UNIQUE INDEX ON "friend_request" ("requester_id", "addressee_id");

CREATE UNIQUE INDEX ON "conversation" ("participant_a_id", "participant_b_id");

CREATE UNIQUE INDEX ON "page_bookmark" ("user_id", "chapter_id", "page_number");

COMMENT ON TABLE "series" IS 'Main archived entity. Can be suspended by an administrator without permanent deletion.';

COMMENT ON COLUMN "series"."id" IS 'ro';

COMMENT ON COLUMN "series"."original_title" IS 'ro — native-script title (e.g. ドラえもん for Japanese)';

COMMENT ON COLUMN "series"."alt_titles" IS 'aliases, abbreviations, alternate names';

COMMENT ON COLUMN "series"."cover_image" IS 'URL';

COMMENT ON COLUMN "series"."background_image" IS 'URL';

COMMENT ON COLUMN "series"."highest_chapter" IS 'auto-computed — highest chapter number currently in the system';

COMMENT ON COLUMN "series"."highest_volume" IS 'auto-computed — highest volume number currently in the system';

COMMENT ON COLUMN "series"."latest_chapter" IS 'latest officially released chapter number';

COMMENT ON COLUMN "series"."latest_volume" IS 'latest officially released volume number';

COMMENT ON COLUMN "series"."platforms" IS 'platforms the series is available on';

COMMENT ON COLUMN "series"."is_suspended" IS 'administrator-imposed visibility override; hides from all personnel without deletion';

COMMENT ON COLUMN "series"."avg_rating" IS 'auto-computed — average of series_user_record.rating where rating IS NOT NULL';

COMMENT ON COLUMN "series"."total_ratings" IS 'auto-computed — count of non-null ratings in series_user_record';

COMMENT ON COLUMN "series"."total_reads" IS 'auto-computed — distinct user count in series_user_record';

COMMENT ON COLUMN "series"."total_comments" IS 'auto-computed from comment where manga_id matches';

COMMENT ON COLUMN "series"."total_bookmarks" IS 'auto-computed — count of series_user_record rows where is_bookmarked = true';

COMMENT ON TABLE "tags" IS 'Tags for series categorization and advanced search. Tag suggestions are generated by VLM and require admin approval.';

COMMENT ON COLUMN "tags"."name" IS 'e.g. Slice of Life, Romance, Shounen';

COMMENT ON COLUMN "tags"."group" IS 'category the tag belongs to: theme, character type, narrative style, genre, demographic';

COMMENT ON TABLE "creator" IS 'Author or artist. A person may hold both roles. At least one role required.';

COMMENT ON COLUMN "creator"."pen_name" IS 'primary public display name / pseudonym';

COMMENT ON COLUMN "creator"."native_name" IS 'name in native language/script';

COMMENT ON COLUMN "creator"."alt_names" IS 'other aliases';

COMMENT ON COLUMN "creator"."social_links" IS 'key-value map: platform → URL (X/Twitter, Pixiv, Facebook, etc.)';

COMMENT ON COLUMN "creator"."total_works_official" IS 'official count — may differ from system count';

COMMENT ON COLUMN "creator"."total_works_in_system" IS 'auto-computed from series_creator_credit';

COMMENT ON TABLE "translation_group" IS 'Group of translators. Official publishers are modeled as groups with is_official_publisher = true. A personnel member belongs to at most one group at a time.';

COMMENT ON COLUMN "translation_group"."alt_names" IS 'alternate names or abbreviations';

COMMENT ON COLUMN "translation_group"."website_url" IS 'URL';

COMMENT ON COLUMN "translation_group"."languages" IS 'list of languages this group works in';

COMMENT ON COLUMN "translation_group"."is_official_publisher" IS 'marks an official publisher (e.g. Viz Media, Yen Press)';

COMMENT ON COLUMN "translation_group"."total_chapters_translated" IS 'auto-computed — count of chapters attributed to this group';

COMMENT ON TABLE "personnel" IS 'User or administrator account. All accounts are administrator-provisioned; self-registration is not supported.';

COMMENT ON COLUMN "personnel"."id" IS 'ro';

COMMENT ON COLUMN "personnel"."username" IS 'ro — used for login only, not the display name';

COMMENT ON COLUMN "personnel"."email" IS 'ro — used for login and password reset';

COMMENT ON COLUMN "personnel"."display_name" IS 'shown on profile; defaults to username';

COMMENT ON COLUMN "personnel"."password_hash" IS 'ro — bcrypt (min cost 12) or Argon2id; write-only, never exposed via API';

COMMENT ON COLUMN "personnel"."avatar_url" IS 'URL';

COMMENT ON COLUMN "personnel"."last_active_at" IS 'updated on every successful login and authenticated request';

COMMENT ON COLUMN "personnel"."group_id" IS 'nullable — current translation group; null if not a member of any group';

COMMENT ON COLUMN "personnel"."tfa_method" IS 'original field: 2fa_method — null if 2FA is disabled';

COMMENT ON COLUMN "personnel"."phone_number" IS 'stored encrypted; required when tfa_method = sms; null otherwise; never exposed via API';

COMMENT ON COLUMN "personnel"."tfa_secret" IS 'original field: 2fa_secret — stored encrypted; null if 2FA disabled; never exposed via API';

COMMENT ON COLUMN "personnel"."failed_login_attempts" IS 'reset on successful login';

COMMENT ON COLUMN "personnel"."locked_until" IS 'null if not locked; auto-set after exceeding failed-attempt threshold';

COMMENT ON COLUMN "personnel"."total_titles_read" IS 'auto-computed from reading_progress';

COMMENT ON COLUMN "personnel"."total_chapters_read" IS 'auto-computed from reading_progress';

COMMENT ON TABLE "post" IS 'User-generated post on the activity feed. A repost points to an existing post; body acts as optional commentary.';

COMMENT ON COLUMN "post"."id" IS 'ro';

COMMENT ON COLUMN "post"."embedded_reference" IS '{ type, id, page_number? } — type: manga | chapter | page';

COMMENT ON COLUMN "post"."original_post_id" IS 'ro — null if not a repost';

COMMENT ON COLUMN "post"."upvote_count" IS 'auto-computed from post_vote';

COMMENT ON COLUMN "post"."downvote_count" IS 'auto-computed from post_vote';

COMMENT ON COLUMN "post"."comment_count" IS 'auto-computed from comment';

COMMENT ON COLUMN "post"."repost_count" IS 'auto-computed — count of reposts referencing this post';

COMMENT ON TABLE "scrape_job" IS 'Content ingestion job triggered by an administrator. Can be one-off or recurring. Job history is retained.';

COMMENT ON COLUMN "scrape_job"."id" IS 'ro';

COMMENT ON COLUMN "scrape_job"."source_url" IS 'ro';

COMMENT ON COLUMN "scrape_job"."target_manga_id" IS 'ro — null for new-title ingestion; non-null when updating an existing series';

COMMENT ON COLUMN "scrape_job"."schedule" IS 'cron expression — null if is_recurring = false';

COMMENT ON COLUMN "scrape_job"."result_summary" IS '{ chapters_added, pages_added, errors }';

COMMENT ON COLUMN "scrape_job"."error_details" IS 'null if no errors';

COMMENT ON COLUMN "scrape_job"."created_by" IS 'admin-only';

COMMENT ON TABLE "volume" IS 'Volume belonging to a series. Volume 0 is the default catch-all for chapters with no assigned volume.';

COMMENT ON COLUMN "volume"."id" IS 'ro';

COMMENT ON COLUMN "volume"."volume_number" IS 'ro';

COMMENT ON COLUMN "volume"."title" IS 'optional volume title';

COMMENT ON COLUMN "volume"."isbn" IS 'International Standard Book Number';

COMMENT ON COLUMN "volume"."edition" IS 'e.g. anniversary, collab, standard';

COMMENT ON COLUMN "volume"."published_chapter_start" IS 'first chapter number in the official release';

COMMENT ON COLUMN "volume"."published_chapter_end" IS 'last chapter number in the official release';

COMMENT ON COLUMN "volume"."store_links" IS 'key-value map: store → URL';

COMMENT ON COLUMN "volume"."price" IS 'key-value map: currency → price';

COMMENT ON COLUMN "volume"."cover_image" IS 'front cover URL';

COMMENT ON COLUMN "volume"."current_chapter_start" IS 'first chapter currently in the system for this volume';

COMMENT ON COLUMN "volume"."current_chapter_end" IS 'last chapter currently in the system for this volume';

COMMENT ON COLUMN "volume"."total_pages" IS 'total page count currently in the system';

COMMENT ON COLUMN "volume"."avg_rating" IS 'auto-computed — average rating across all chapters in this volume';

COMMENT ON COLUMN "volume"."total_ratings" IS 'auto-computed — count of ratings across all chapters';

COMMENT ON COLUMN "volume"."total_reads" IS 'auto-computed — distinct user count across all chapters';

COMMENT ON COLUMN "volume"."total_comments" IS 'auto-computed from comment rows where chapter_id matches any chapter in this volume';

COMMENT ON COLUMN "volume"."total_bookmarks" IS 'auto-computed from page_bookmark records across all chapters';

COMMENT ON COLUMN "volume"."series_original_title" IS 'ro — denormalized from series.original_title to avoid joins at display time';

COMMENT ON TABLE "chapter" IS 'Chapter belonging to exactly one series and one volume. Multiple translations of the same chapter_number may coexist.';

COMMENT ON COLUMN "chapter"."id" IS 'ro';

COMMENT ON COLUMN "chapter"."chapter_number" IS 'ro';

COMMENT ON COLUMN "chapter"."title" IS 'optional chapter title';

COMMENT ON COLUMN "chapter"."language" IS 'source or translated language; default "none" for wordless chapters';

COMMENT ON COLUMN "chapter"."is_official" IS 'whether this is an official translation';

COMMENT ON COLUMN "chapter"."page_count" IS 'always a positive integer; every chapter must have at least one page';

COMMENT ON COLUMN "chapter"."is_special" IS 'marks anniversary or special end-of-volume chapters';

COMMENT ON COLUMN "chapter"."pages" IS 'array of page objects: [{ order, url, dimensions }]';

COMMENT ON COLUMN "chapter"."avg_rating" IS 'auto-computed from chapter_rating';

COMMENT ON COLUMN "chapter"."total_ratings" IS 'auto-computed from chapter_rating';

COMMENT ON COLUMN "chapter"."total_reads" IS 'auto-computed — distinct user count in reading_progress';

COMMENT ON COLUMN "chapter"."total_comments" IS 'auto-computed from comment where chapter_id matches';

COMMENT ON COLUMN "chapter"."total_bookmarks" IS 'auto-computed from page_bookmark for this chapter';

COMMENT ON COLUMN "chapter"."series_original_title" IS 'ro — denormalized from series.original_title';

COMMENT ON COLUMN "chapter"."volume_number" IS 'ro — denormalized from volume.volume_number';

COMMENT ON COLUMN "chapter"."group_id" IS 'for official releases the publisher is the group';

COMMENT ON COLUMN "chapter"."uploader_id" IS 'non-admin uploaders must have personnel.group_id = chapter.group_id';

COMMENT ON TABLE "character" IS 'Named character scoped to exactly one series. Viewable by all personnel.';

COMMENT ON COLUMN "character"."id" IS 'ro';

COMMENT ON COLUMN "character"."name" IS 'primary display name';

COMMENT ON COLUMN "character"."aliases" IS 'alternate names or nicknames';

COMMENT ON COLUMN "character"."image_url" IS 'URL';

COMMENT ON COLUMN "character"."series_original_title" IS 'ro — denormalized from series.original_title';

COMMENT ON TABLE "user_preference" IS 'Per-user reading and display settings. Exactly one record per user. Persists across sessions and devices.';

COMMENT ON COLUMN "user_preference"."user_id" IS 'ro — one-to-one with personnel; created with defaults at account provisioning';

COMMENT ON TABLE "token" IS 'Auth token for refresh and password_reset lifecycles. Stored as hash only. No soft-delete — invalidated via revoked_at.';

COMMENT ON COLUMN "token"."id" IS 'ro';

COMMENT ON COLUMN "token"."user_id" IS 'ro';

COMMENT ON COLUMN "token"."type" IS 'ro';

COMMENT ON COLUMN "token"."token_hash" IS 'ro — hash of the plaintext token; plaintext is never stored';

COMMENT ON COLUMN "token"."issued_at" IS 'ro — set by the system on insert';

COMMENT ON COLUMN "token"."revoked_at" IS 'null if still valid; set on use (password_reset), rotation (refresh), or explicit revocation';

COMMENT ON TABLE "friend_request" IS 'Directed friendship request. blocked status prevents further contact. rejected allows re-submission after a cooldown.';

COMMENT ON COLUMN "friend_request"."id" IS 'ro';

COMMENT ON COLUMN "friend_request"."requester_id" IS 'ro — the user who initiated the request';

COMMENT ON COLUMN "friend_request"."addressee_id" IS 'ro — the user who received the request';

COMMENT ON COLUMN "friend_request"."requested_at" IS 'ro';

COMMENT ON COLUMN "friend_request"."responded_at" IS 'null until the addressee acts';

COMMENT ON TABLE "comment" IS 'Polymorphic comment. Exactly one of manga_id, chapter_id, post_id is non-null per row.';

COMMENT ON COLUMN "comment"."id" IS 'ro';

COMMENT ON COLUMN "comment"."parent_comment_id" IS 'null for top-level comments; threading limited to one level; must reference a comment with the same parent entity';

COMMENT ON COLUMN "comment"."manga_id" IS 'null if not targeting a series';

COMMENT ON COLUMN "comment"."chapter_id" IS 'null if not targeting a chapter';

COMMENT ON COLUMN "comment"."post_id" IS 'null if not targeting a post';

COMMENT ON TABLE "conversation" IS 'DM channel between exactly two users. Requires confirmed friendship or one participant being an administrator.';

COMMENT ON COLUMN "conversation"."id" IS 'ro';

COMMENT ON COLUMN "conversation"."last_message_at" IS 'auto-updated atomically on each message insert';

COMMENT ON TABLE "message" IS 'Individual message within a conversation. Immutable once written.';

COMMENT ON COLUMN "message"."id" IS 'ro';

COMMENT ON COLUMN "message"."body" IS 'text-only in the initial release';

COMMENT ON COLUMN "message"."sent_at" IS 'ro — set by the system on insert; equivalent to created_at';

COMMENT ON TABLE "notification" IS 'In-app notification delivered to a user.';

COMMENT ON COLUMN "notification"."id" IS 'ro';

COMMENT ON COLUMN "notification"."reference" IS 'e.g. { type: "chapter", id: "...", series_title: "..." } — enables deep-linking without a separate query';

COMMENT ON TABLE "reading_progress" IS 'Per-user per-chapter reading state. Created on first page view; never deleted.';

COMMENT ON COLUMN "reading_progress"."user_id" IS 'ro';

COMMENT ON COLUMN "reading_progress"."chapter_id" IS 'ro';

COMMENT ON COLUMN "reading_progress"."last_page" IS 'the most recent page the user viewed';

COMMENT ON COLUMN "reading_progress"."is_completed" IS 'false → true only; never reset; set when user reaches the last page';

COMMENT ON COLUMN "reading_progress"."last_read_at" IS 'updated on every read event';

COMMENT ON TABLE "page_bookmark" IS 'User-placed bookmark on a specific page within a chapter. Distinct from the series-level is_bookmarked flag. No soft-delete.';

COMMENT ON COLUMN "page_bookmark"."id" IS 'ro';

COMMENT ON COLUMN "page_bookmark"."user_id" IS 'ro';

COMMENT ON COLUMN "page_bookmark"."chapter_id" IS 'ro';

COMMENT ON COLUMN "page_bookmark"."page_number" IS 'ro — the specific page that was bookmarked';

COMMENT ON COLUMN "page_bookmark"."bookmarked_at" IS 'ro — set by the system on insert';

COMMENT ON TABLE "series_creator_credit" IS 'Links a series to a creator with a discriminating role. A series must have at least one author credit.';

COMMENT ON COLUMN "series_creator_credit"."series_id" IS 'ro — composite PK with creator_id and role';

COMMENT ON COLUMN "series_creator_credit"."creator_id" IS 'ro';

COMMENT ON COLUMN "series_creator_credit"."role" IS 'ro — role is part of PK so one person may hold both roles on the same series';

COMMENT ON TABLE "series_user_record" IS 'Full user–series relationship. Created on first chapter read; never deleted.';

COMMENT ON COLUMN "series_user_record"."user_id" IS 'ro';

COMMENT ON COLUMN "series_user_record"."series_id" IS 'ro';

COMMENT ON COLUMN "series_user_record"."notify_on_new_chapter" IS 'may only be true while is_bookmarked = true; clearing is_bookmarked auto-clears this flag';

COMMENT ON COLUMN "series_user_record"."rating" IS 'nullable; updated in place; feeds series.avg_rating and series.total_ratings';

COMMENT ON TABLE "chapter_rating" IS 'User rating for a specific chapter. One row per (user_id, chapter_id) pair.';

COMMENT ON COLUMN "chapter_rating"."user_id" IS 'ro';

COMMENT ON COLUMN "chapter_rating"."chapter_id" IS 'ro';

COMMENT ON COLUMN "chapter_rating"."rating" IS 'typically 1.0–5.0; updates replace in place; feeds chapter.avg_rating and chapter.total_ratings';

COMMENT ON TABLE "post_vote" IS 'Binary vote on a post. At most one per user per post. Direction change updates in place.';

COMMENT ON COLUMN "post_vote"."user_id" IS 'ro';

COMMENT ON COLUMN "post_vote"."post_id" IS 'ro';

COMMENT ON COLUMN "post_vote"."direction" IS 'changing direction updates in place; feeds post.upvote_count and post.downvote_count';

COMMENT ON TABLE "creator_follow" IS 'User following a creator. Pure junction — presence of a row implies following.';

COMMENT ON COLUMN "creator_follow"."user_id" IS 'ro';

COMMENT ON COLUMN "creator_follow"."creator_id" IS 'ro';

COMMENT ON TABLE "tag_proposal" IS 'Links a series to a tag and tracks proposal lifecycle. Required for the AI-tag review gate before publication.';

COMMENT ON COLUMN "tag_proposal"."series_id" IS 'ro';

COMMENT ON COLUMN "tag_proposal"."tag_id" IS 'ro';

COMMENT ON COLUMN "tag_proposal"."status" IS 'tag is active on the series when status = approved';

COMMENT ON TABLE "character_appearance" IS 'Records that a character appears in a specific chapter. Pure junction — no additional attributes.';

COMMENT ON COLUMN "character_appearance"."chapter_id" IS 'ro';

COMMENT ON COLUMN "character_appearance"."character_id" IS 'ro';

ALTER TABLE "personnel" ADD FOREIGN KEY ("group_id") REFERENCES "translation_group" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "post" ADD FOREIGN KEY ("original_post_id") REFERENCES "post" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "post" ADD FOREIGN KEY ("author_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "scrape_job" ADD FOREIGN KEY ("target_manga_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "scrape_job" ADD FOREIGN KEY ("created_by") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "volume" ADD FOREIGN KEY ("series_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "chapter" ADD FOREIGN KEY ("series_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "chapter" ADD FOREIGN KEY ("volume_id") REFERENCES "volume" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "chapter" ADD FOREIGN KEY ("group_id") REFERENCES "translation_group" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "chapter" ADD FOREIGN KEY ("uploader_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "character" ADD FOREIGN KEY ("series_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "user_preference" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "token" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "friend_request" ADD FOREIGN KEY ("requester_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "friend_request" ADD FOREIGN KEY ("addressee_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comment" ADD FOREIGN KEY ("parent_comment_id") REFERENCES "comment" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comment" ADD FOREIGN KEY ("manga_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comment" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapter" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comment" ADD FOREIGN KEY ("post_id") REFERENCES "post" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comment" ADD FOREIGN KEY ("author_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "conversation" ADD FOREIGN KEY ("participant_a_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "conversation" ADD FOREIGN KEY ("participant_b_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "message" ADD FOREIGN KEY ("conversation_id") REFERENCES "conversation" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "message" ADD FOREIGN KEY ("sender_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "notification" ADD FOREIGN KEY ("recipient_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reading_progress" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reading_progress" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapter" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "page_bookmark" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "page_bookmark" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapter" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "series_creator_credit" ADD FOREIGN KEY ("series_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "series_creator_credit" ADD FOREIGN KEY ("creator_id") REFERENCES "creator" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "series_user_record" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "series_user_record" ADD FOREIGN KEY ("series_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "chapter_rating" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "chapter_rating" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapter" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "post_vote" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "post_vote" ADD FOREIGN KEY ("post_id") REFERENCES "post" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "creator_follow" ADD FOREIGN KEY ("user_id") REFERENCES "personnel" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "creator_follow" ADD FOREIGN KEY ("creator_id") REFERENCES "creator" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "tag_proposal" ADD FOREIGN KEY ("series_id") REFERENCES "series" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "tag_proposal" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "character_appearance" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapter" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "character_appearance" ADD FOREIGN KEY ("character_id") REFERENCES "character" ("id") DEFERRABLE INITIALLY IMMEDIATE;
