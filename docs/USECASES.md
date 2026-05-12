# NOAH Manga Management System (NOAH MMS) — Use Case List

**Last revised:** 08/05/2026 04:18 PM

---

## SS-01: Manga Reading & Delivery

- UC-01-01 Read a manga chapter in the in-browser reader
- UC-01-02 Navigate chapters by volume, chapter number, and language
- UC-01-03 View manga detail page (metadata, synopsis, rating, status)
- UC-01-04 View character profiles
- UC-01-05 View all volumes in a series
- UC-01-06 Track and resume reading progress
- UC-01-07 Configure reading direction (RTL / LTR)
- UC-01-08 Switch page display mode (single / double-spread / long-strip)
- UC-01-09 Change page fit option (width / height / original)
- UC-01-10 Place or clear a bookmark on a page
- UC-01-12 Rate a manga title

---

## SS-02: Account & Authentication

- UC-02-02 Log in with email or username and password
- UC-02-03 Reset password via email link
- UC-02-04 Enable or disable two-factor authentication (2FA)
- UC-02-05 Edit profile (display name, username, password, avatar, biography)
- UC-02-06 Configure profile privacy (reading history and statistics visibility)
- UC-02-07 Delete own account

---

## SS-03: Social & Community

- UC-03-01 Create a post
- UC-03-02 Embed a manga, chapter, or page reference in a post
- UC-03-03 Repost another personnel's post
- UC-03-04 Comment on a post
- UC-03-05 Upvote or downvote a post
- UC-03-06 Send a friend request
- UC-03-07 Accept or decline a friend request
- UC-03-08 Remove a friend
- UC-03-09 Send a direct message to a friend or administrator
- UC-03-10 View inbox and receive messages
- UC-03-11 Receive in-app notifications (friend requests, replies, messages, new chapters)
- UC-03-12 View another personnel's public profile
- UC-03-13 View personal reading statistics dashboard
- UC-03-14 View personalized activity feed

---

## SS-04: Search & Discovery

- UC-04-01 Search by keyword (titles, authors, characters)
- UC-04-02 Search by natural language (semantic intent)
- UC-04-03 Filter search results by tags (genre, status, content rating, language)
- UC-04-04 Sort search results (relevance, rating, popularity, recency, alphabetical)
- UC-04-05 View personalized recommendations on the home page
- UC-04-06 View friend suggestions based on reading overlap
- UC-04-07 View similar titles on a manga detail page

---

## SS-05: AI Assistant (Personnel)

- UC-05-01 Query the AI assistant to find manga, authors, or characters
- UC-05-02 Ask the AI assistant about plot, characters, themes, or author background
- UC-05-03 Ask follow-up questions within the same session (context persistence)
- UC-05-04 Receive a graceful refusal for out-of-scope queries
- UC-05-05 Receive an honest acknowledgement of limited knowledge when the AI assistant cannot answer an in-scope query

---

## SS-06: Admin — Content Management

- UC-06-01 Scrape manga from an external URL
- UC-06-02 Upload manga from the local file system (ZIP/CBZ or folder)
- UC-06-03 Review and resolve flagged duplicate titles
- UC-06-04 Delete a manga title (with two-step confirmation)
- UC-06-05 Suspend or unsuspend a manga title
- UC-06-06 Initiate a batch scraping operation
- UC-06-07 Schedule a recurring automated scrape job for a source
- UC-06-08 View the system-wide content dashboard
- UC-06-09 Monitor per-title personnel engagement metrics
- UC-06-10 Review and approve AI-generated tags before publishing a title

---

## SS-07: Admin — Personnel Management

- UC-07-01 Search for a personnel account (by username, email, or ID)
- UC-07-02 View a personnel account's details and activity summary
- UC-07-03 Force a password reset for a personnel account
- UC-07-04 Create a new personnel account
- UC-07-05 Assign or change a personnel's role
- UC-07-06 Suspend or reinstate a personnel account
- UC-07-07 Delete a personnel account permanently
- UC-07-08 View system-wide personnel statistics (registrations, active users, top contributors)
- UC-07-09 View per-personnel activity summary (reading, posts, logins, connections)

---

## SS-08: Admin — AI Agent

- UC-08-01 Request an AI-generated summary or metadata suggestions for a manga title
- UC-08-02 Review and apply AI-generated tags before publication
- UC-08-03 Request an AI-generated activity summary for a personnel account
- UC-08-04 Review AI-flagged accounts with anomalous behavior

---

**Total: 66 use cases across 8 subsystems.**
