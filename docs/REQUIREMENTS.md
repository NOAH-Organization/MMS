# NOAH Manga Management System (NOAH MMS) — System Requirements

**Last revised:** 12/05/2026 09:36 AM

> **Revision note:** This document is the authoritative requirements specification for NOAH MMS. Items marked **[ADDED]** are enhancements proposed during review. Items marked **[REVISED]** replace or clarify the original wording — see the inline note for the rationale. Items marked **[DECISION REQUIRED]** indicate open questions that must be resolved before implementation of the relevant subsystem begins.

---

## 1. Functional Requirements

> **Use case traceability:** Each requirement line below is annotated with the use case ID(s) from `USECASES.md` that satisfy it. **[GAP]** marks requirements with no covering use case. **[SYSTEM BEHAVIOR]** marks automated actions that are not user-triggered and do not map to a use case. Coverage issues are summarised in §1.3.

### 1.1 End-User Features

Personnel shall have access to the following features across four subsystems.

---

#### 1.1.1 Manga Content Storage and Delivery

- Read manga chapter by chapter within an in-browser reading view. → `UC-01-01`
- View manga metadata, including: title, author(s), illustrator(s), genres, synopsis, content rating, publication status, translation group(s), and aggregated user rating. → `UC-01-03`
- Browse a manga's chapter list organized by volume, chapter number, and available language(s). → `UC-01-02`
- View character profiles, including name, aliases, role in the story, and associated titles. → `UC-01-04`
- View all volumes belonging to the same series, if applicable. → `UC-01-05`
- Automatically record reading progress per personnel: last read chapter, last read page, and overall completion percentage. → `UC-01-06`
- **[ADDED]** Support configurable reading direction: right-to-left (RTL) for Japanese manga, left-to-right (LTR) for manhwa and manhua. → `UC-01-07`
- **[ADDED]** Support at least three page display modes: single page, double-page spread, and vertical long-strip scroll. → `UC-01-08`
- **[ADDED]** Provide page fit options: fit to width, fit to height, and original size. → `UC-01-09`
- **[ADDED]** Allow personnel to manually place or clear bookmarks on individual pages. → `UC-01-10`
- **[ADDED]** Allow personnel to submit a star-scale rating for a manga title. Ratings are aggregated into the title's overall score displayed in manga metadata. → `UC-01-12`

---

#### 1.1.2 Account Management and Social Connectivity

**Authentication & Account:**

- Log in using email or username with password. → `UC-02-02`
- **[ADDED]** Recover account access via a password reset link sent to the registered email address. → `UC-02-03`
- Enable or disable two-factor authentication (2FA) via an authenticator app or SMS. → `UC-02-04`
- Edit personal profile: display name, username, password, avatar image, and biography. → `UC-02-05`
- Delete own account. **[ADDED]** Account deletion must permanently remove or anonymize all personal data in accordance with the organization's data retention policy. → `UC-02-07`

**Social Features:**

- Create posts to share reading experiences, opinions, or recommendations. → `UC-03-01`
- Embed a manga title, chapter, or specific page reference within a post. → `UC-03-02`
- Share (repost) posts created by other personnel. → `UC-03-03`
- Comment on posts. → `UC-03-04`
- Rate posts. **[DECISION REQUIRED]** The rating model (binary upvote/downvote vs. numeric star scale) must be decided before implementation. → `UC-03-05`
- Send and accept friend requests. → `UC-03-06`, `UC-03-07`
- Remove existing friends. → `UC-03-08`
- Send and receive direct messages with other personnel (text only in the initial release). → `UC-03-09`, `UC-03-10`
- **[ADDED]** Receive in-app notifications for: friend requests, post replies, direct messages, and new chapter releases for followed titles. → `UC-03-11`
- View another personnel's public profile — display name, avatar, biography, public posts, and reading statistics. Passwords and private contact details are never exposed. → `UC-03-12`
- **[ADDED]** Configure profile privacy: choose whether reading history and statistics are publicly visible or visible only to friends. → `UC-02-06`

**Feed & Discovery:**

- View a personalized activity feed displaying posts from friends and algorithmically surfaced featured content. → `UC-03-14`

**Statistics:**

- View a personal reading dashboard displaying: total titles read, total chapters read, genre breakdown, and recently active titles. → `UC-03-13`

---

#### 1.1.3 Advanced Search and Recommendation

- Perform exact-match keyword searches across manga titles, authors, and characters. → `UC-04-01`
- Perform semantic (natural language intent) searches across manga titles, authors, and characters. → `UC-04-02`
- Filter and narrow search results using multi-level tag criteria (e.g., genre, publication status, content rating, language). → `UC-04-03`
- **[ADDED]** Sort search results by: relevance, rating, popularity, recency, and alphabetical order. → `UC-04-04`
- Receive personalized recommendations on the home page for manga titles, authors, and tag-based collections, derived from reading history and preferences. → `UC-04-05`
- Receive friend suggestions based on overlapping reading preferences and genre interests. → `UC-04-06`
- View a "Similar Titles" section on each manga's detail page. → `UC-04-07`

---

#### 1.1.4 AI Assistant

- Query the AI assistant in natural language to search for manga titles, authors, and characters. → `UC-05-01`
- Ask the AI assistant questions about a manga's plot, characters, themes, or author background. → `UC-05-02`
- **[ADDED]** The AI assistant must operate within a defined scope: it shall only respond to queries relevant to manga, authors, characters, and platform features. Out-of-scope requests must be declined gracefully. → `UC-05-04`
- **[ADDED]** Conversation context must persist within a session, enabling follow-up questions without repeating prior context. → `UC-05-03`
- **[ADDED]** The AI assistant must acknowledge when it lacks sufficient information to answer a query, rather than generating speculative or fabricated responses. → `UC-05-05`

---

### 1.2 Administrator Features

Administrators shall have access to all personnel features described in Section 1.1, plus the following capabilities across three subsystems.

---

#### 1.2.1 Manga Content Management

- Scrape manga content from external web sources via a provided URL. → `UC-06-01`
- Automatically identify and select the appropriate scraping parser based on the source domain. → **[SYSTEM BEHAVIOR — no dedicated use case; covered implicitly within `UC-06-01`]**
- Upload manga content from the local file system (supported formats: ZIP/CBZ archives of image files or structured folder uploads). → `UC-06-02`
- **[ADDED]** Detect and flag potential duplicate titles during scraping or upload, prompting administrator confirmation before proceeding. → `UC-06-03`
- Delete stored manga titles. **[ADDED]** Deletion must require a two-step confirmation to prevent accidental data loss. → `UC-06-04`
- **[ADDED]** Suspend (temporarily hide) a manga title from personnel view without permanently deleting it. → `UC-06-05`
- Initiate and monitor large-scale automated batch scraping operations. → `UC-06-06`
- **[ADDED]** Schedule recurring automated scrape jobs for specific sources to fetch new chapters. → `UC-06-07`
- View a system-wide content dashboard displaying: total titles, total chapters, total pages, storage usage, and scraping job history. → `UC-06-08`
- Monitor per-title personnel engagement metrics: view counts, read-through rates, bookmarks, and ratings. → `UC-06-09`

> **[CONSIDERATION — Legal]** Web scraping may conflict with the terms of service of certain external sources. It is recommended that scraping be limited to pre-approved sources, and that a legal review step be incorporated into the workflow before any new source is added.

---

#### 1.2.2 Personnel Account Management

- Search for personnel by username, email address, or account ID. → `UC-07-01`
- View a personnel's account metadata: username, email, registration date, last active date, account status, and activity summary. → `UC-07-02`
- **[REVISED — SECURITY]** The original requirement stated that administrators may view plaintext passwords. **This must not be implemented.** Passwords are stored as irreversible cryptographic hashes and cannot be read by any party, including administrators. The administrator action in this domain is limited to **forcing a password reset**, which sends a reset link to the personnel's registered email address. See Section 2.1, item 2 for the password storage requirement. → `UC-07-03`
- Create new personnel accounts. → `UC-07-04`
- **[ADDED]** Assign and modify account roles. Supported roles in the initial release: **Personnel** and **Administrator**. → `UC-07-05`
- **[ADDED]** Suspend a personnel account (temporarily disable access) without permanently deleting it, with the ability to reinstate it. → `UC-07-06`
- Delete personnel accounts permanently. → `UC-07-07`
- View system-wide personnel activity statistics: new registrations over time, daily/monthly active counts, and top contributors. → `UC-07-08`
- View per-personnel activity summaries: reading history, post history, login history, and social connections. → `UC-07-09`

---

#### 1.2.3 AI Assistant (Administrative)

- **[REVISED]** An AI Agent shall assist administrators with manga management tasks, including generating content summaries, suggesting missing metadata, and answering queries about system content. Detailed agent capabilities must be defined in a separate AI feature specification prior to implementation. → `UC-08-01`
- Automatically generate and apply genre, theme, and content-warning tags to newly uploaded or scraped manga titles, subject to administrator review and approval before the title is published. → `UC-08-02` *(tag generation — AI action)*, `UC-06-10` *(review and approval — admin action)*
- **[REVISED]** An AI Agent shall assist administrators with personnel management tasks, including summarizing activity patterns and flagging accounts exhibiting anomalous behavior. Detailed agent capabilities must be defined in a separate AI feature specification prior to implementation. → `UC-08-03`, `UC-08-04`

---

### 1.3 Coverage Notes

Cross-referencing functional requirements against `USECASES.md` produced the following findings. Gap items have been resolved; duplicate items remain as open recommendations.

#### Resolved Gaps

| Requirement | Location | Resolution |
| --- | --- | --- |
| The AI assistant must acknowledge when it lacks sufficient information to answer a query, rather than generating speculative or fabricated responses. | §1.1.4 | **Resolved.** `UC-05-05` added to SS-05 in `USECASES.md`. Distinct from `UC-05-04` (out-of-scope refusal) — this covers in-scope queries the model cannot answer. |
| Personnel account self-registration was not stated as a requirement, yet `UC-02-01` existed in `USECASES.md` as an orphan use case. | §1.1.2 | **Resolved.** All accounts are administrator-provisioned (`UC-07-04`). Self-registration is not supported. `UC-02-01` has been removed from `USECASES.md`. |

#### Open Recommendations — Duplicate Use Cases

| Use Cases | Shared Requirement | Recommendation |
| --- | --- | --- |
| `UC-06-10` and `UC-08-02` | Generate and review AI-generated tags before publication (§1.2.3) | These are complementary steps in one workflow, not true duplicates. Rename to make the boundary explicit: `UC-08-02` = *AI generates tags for a newly ingested title* (agent action); `UC-06-10` = *Administrator reviews and approves AI-generated tags before publication* (admin action). |

---

## 2. Non-Functional Requirements

### 2.1 Security Requirements

1. All personnel personal data must be protected from unauthorized external access. The system must not expose user data through any endpoint without valid authentication.
2. **[REVISED]** Passwords must be stored as irreversible cryptographic hashes using an industry-standard adaptive algorithm (bcrypt with a minimum cost factor of 12, or Argon2id). Plaintext passwords must never be stored, logged, or transmitted after the point of initial input. *(The original requirement that administrators may view passwords is incompatible with this rule and has been superseded — see §1.2.2.)*
3. **[ADDED]** All data in transit must be encrypted using TLS 1.2 or higher. The system must not be accessible over unencrypted HTTP in any deployment environment.
4. **[ADDED]** Session tokens must carry a defined expiry. Refresh token rotation must be implemented to minimize the impact of token compromise.
5. **[ADDED]** Login attempts must be rate-limited. Accounts must be temporarily locked after a configurable number of consecutive failed attempts (recommended default: 5 attempts, 15-minute lockout window).
6. **[ADDED]** The system must implement protection against the OWASP Top 10 web application vulnerabilities, including SQL injection, cross-site scripting (XSS), cross-site request forgery (CSRF), and insecure direct object references (IDOR).
7. **[ADDED]** All administrator actions that create, modify, or delete data (personnel accounts, manga titles) must be recorded in an audit log capturing: actor identity, action type, affected record, timestamp, and source IP address.

---

### 2.2 Performance Requirements

1. The system must function correctly and render content consistently across the following browsers: Google Chrome (latest), Microsoft Edge (latest), Cốc Cốc (latest), and Mozilla Firefox (latest).
2. **[REVISED]** Response time for all interactive features — including search queries, page navigation, and data retrieval — must not exceed **2 seconds** under normal load conditions. *(The original specification listed this constraint twice as separate items; they have been consolidated here.)*
3. **[ADDED]** Manga page images must begin rendering within **3 seconds** of a chapter being opened under normal network conditions. Progressive or lazy loading must be implemented for subsequent pages to avoid blocking the reading experience.
4. **[ADDED]** AI assistant responses must begin streaming within **5 seconds** of query submission. Given the inherent latency of large language model inference, the 2-second general response limit in item 2 does not apply to AI features; a streaming response pattern is required.
5. System downtime per incident must not exceed **60 minutes**, and the system must have an automated recovery mechanism in place.
6. The system must support a minimum of **100 concurrent users** in the initial release without response times exceeding the limits defined above.

---

### 2.3 Scalability Requirements

1. The system shall be deployed initially in English, but must be architected using an internationalization (i18n) framework from the outset, enabling the addition of further languages — including Vietnamese — without structural refactoring.
2. The system must be built on a modular architecture that supports future decomposition into independently scalable components as usage grows.
3. The system's frontend must be a responsive web application designed desktop-first, with layouts that degrade gracefully on tablet and mobile viewports. A dedicated native mobile application is out of scope for the initial release but must not be architecturally precluded.
4. **[ADDED]** Manga page images must be served via a CDN or equivalent edge-caching layer to ensure acceptable load times independent of user geographic location relative to the origin server.

---

### 2.4 Usability Requirements

1. The system interface must conform to the design specification in `DESIGN_GUIDELINE.md` and must be navigable without training by personnel familiar with standard web applications.
2. All system errors, validation failures, and operation outcomes must surface a clear, human-readable notification to the affected user within the current view. Error messages must describe what went wrong and, where possible, the corrective action the user should take.
3. At least **90% of new personnel** must be able to complete core tasks — finding a manga, reading a chapter, and managing their profile — without consulting external documentation, as measured by usability testing prior to release.
4. **[ADDED]** All interactive elements must meet WCAG 2.1 Level AA accessibility standards, including keyboard navigability, sufficient color contrast ratios (4.5:1 for body text), and compatibility with screen readers.
5. **[ADDED]** The system must display a loading indicator for any operation that takes longer than **500ms** to complete, so that personnel always have feedback that the system is processing their request.

---

### 2.5 Availability Requirements

1. **[REVISED]** The system must target a minimum availability of **99.5% uptime** on a rolling 30-day basis, equating to a maximum of approximately 3.6 hours of unplanned downtime per month. This formalizes the original requirement of "operational at all times," which is not achievable without a defined SLA, and reconciles it with the 60-minute per-incident limit in Section 2.2.
2. **[ADDED]** Automated health checks must monitor service availability at intervals of no greater than **1 minute**. On detection of a failure or degraded state, on-call personnel must be alerted within **5 minutes**.
3. **[ADDED]** Database backups must be performed at minimum **daily**. The recovery point objective (RPO) must not exceed **24 hours**, and the recovery time objective (RTO) must not exceed **4 hours**.

---

## 3. Resolved Design Decisions

The following items were identified during the requirements review and have since been explicitly decided. They are recorded here for traceability and must be reflected in the relevant subsystem designs.

| # | Decision | Detail | Affects |
| --- | --- | --- | --- |
| 1 | **Post rating uses a binary upvote/downvote model.** | Posts and blog entries are rated with a single upvote or downvote per personnel account. No numeric star scale is used. | §1.1.2 |
| 2 | **Direct messaging is restricted to confirmed friends and administrators.** | Personnel may only initiate direct messages with accounts they are mutually connected with, or with administrators. Unsolicited messaging from arbitrary personnel is not permitted. | §1.1.2 |
| 3 | **No content moderation workflow for user-generated content at this stage.** | There is no dedicated moderation role or automated moderation pipeline. Administrators retain the authority to remove content directly. This decision is acknowledged as a deferral and should be revisited when user-generated volume warrants it. | §1.1.2, §1.2.2 |
| 4 | **Web scraping is permitted for a pre-approved list of external sources.** | The approved source list will be provided separately. Until then, newly discovered sources are scraped automatically without per-item review. The source allowlist must be maintained and versioned by administrators. | §1.2.1 |
| 5 | **Manga tagging is handled by an external VLM-based service.** | Tag classification is treated as a separate microservice performing multi-label classification via a Vision-Language Model. The main system consumes tag data from this service but does not own the classification logic. Integration contract (API schema, confidence thresholds) is to be specified separately. | §1.1.3, §1.2.3 |
| 6 | **Adult content is permitted; access is controlled by a content filter, not age-gating.** | The system will host explicit-content manga. A content filter will govern visibility of adult material. No age-verification or age-restriction mechanism will be implemented. | §1.1.1, §1.2.1 |
| 7 | **Deployment target is self-hosted infrastructure.** | The system will be hosted on NOAH-managed servers. CDN, availability, and scalability design must account for the absence of managed cloud elasticity. | §2.3, §2.5 |
| 8 | **No Moderator role will be introduced at this stage.** | The role hierarchy remains Personnel and Administrator. Moderation authority resides solely with administrators. This may be revisited in a future release. | §1.2.2 |
| 9 | **Deleted accounts use anonymized retention with `[Deleted]` markers.** | Upon account deletion, personally identifiable information is removed, but contributed content (posts, comments, ratings) is retained and attributed to a `[Deleted]` placeholder — consistent with the Reddit model. This preserves content history and thread integrity. | §1.1.2, §2.1 |
| 10 | **The AI assistant is model-agnostic; no provider is mandated.** | The system must not hardcode dependency on any specific AI model or provider. The integration layer must support model substitution without architectural changes. Provider selection is an operational decision subject to cost, latency, and data-privacy evaluation at deployment time. | §1.1.4, §1.2.3 |
| 11 | **Manga title rating uses a star-scale model.** | Personnel rate individual manga titles using a star scale. This is distinct from post rating (Decision #1), which uses binary upvote/downvote. The exact number of stars (e.g. 1–5 or 1–10) is a UI detail to be defined in the design specification. | §1.1.1 |
