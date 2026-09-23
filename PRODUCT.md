# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Every role counts equally. The app is role-based: each role gets its own home and tools, and none of them dominates the design.

- **Owner:** runs a cleaning company on the platform. Full control: users, roles, client accounts, members, and their permissions.
- **Account manager:** owns client relationships: clients, contacts, locations, proposals and negotiations, schedules, jobs, complaints, tasks.
- **Supervisor:** runs the work on the ground: jobs and crew assignments, checklists, complaints, calendar, tasks.
- **Crew:** cleaners on site. They see only the jobs they're assigned to: check in, start, tick checklist items, complete, check out. Many have low tech literacy. They often work in bright or outdoor light and may be wearing gloves.
- **Client (external):** a cleaning company's own customer. Sees their account's info, contract, jobs, calendar and files, and can file and follow complaints.

## Product Purpose

Space Clean is operations software for commercial cleaning companies. It covers the full lifecycle of a client account in one place:

sale (proposal versions → approval) → contract (sign, renew, expire) → scope of work per location and area, with recurring schedules → a calendar generated from those schedules → jobs on the ground (crew, check-in/out, checklists, quality score, client sign-off) → after-service (complaints with resolution time, tasks with due dates).

Success means every role can do its daily job from a phone. Crew finish their jobs without help, managers keep accounts moving, and clients can see that the work happened.

## Positioning

A single system that connects what was sold (proposal and contract) to what gets cleaned (scope and schedule) to what was actually done (job check-ins, checklists, sign-off) to how the client felt about it (complaints). It uses two permission layers: global staff roles plus per-client-account membership with overridable permissions. So a crew member, a supervisor and the client's own contact can all work in the same account, each seeing only what they should.

## Operating Context

- **Business model:** SaaS sold to many cleaning companies. The current backend API (`docs/frontend-api.md`) has no organization/tenant layer yet. How tenancy is handled is still undecided.
- **Field use:** crew and supervisors use the app on client sites (offices, buildings with floors and access codes), on the move, often one-handed.
- **Office use:** owners and account managers run pipelines, contracts, members and schedules.
- **Schedule vocabulary:** frequencies are daily/weekly/biweekly/monthly/quarterly/annual/one-time, shifts have start and end times, and weekdays run 1 = Monday.
- **Languages:** Spanish and English. The API returns translation keys, never display text.

## Capabilities and Constraints

- Flutter app for Android and iOS only. No web or desktop.
- Backend: `https://space-clean-be-production.up.railway.app`, a REST API with JWT auth (15-minute access token, 7-day refresh token, no logout endpoint).
- The UI is driven by the effective permission set of the member (`<module>.<action>`, e.g. `jobs.assign`, `contract.download`), not by role name alone.
- Records with history are never deleted: users are deactivated, clients go inactive, complaints are resolved, and proposals get new versions.
- **Not built yet in the API:** file uploads/attachments, notifications, client timeline, global search, dashboard KPIs, audit log. Chat lives in a separate service; this API stores only `externalMessageId` references.
- **Undecided:** multi-tenant model; offline support (connectivity on site hasn't been raised as a requirement).

## Brand Commitments

- Name: **Space Clean**.
- An existing brand (logo, colors, voice) is published on the company website. **https://www.spacecleanllc.com** Future visual work must use that brand, not invent one.
- One custom design on both Android and iOS, following the reference `docs/example_app.png`: gray ground, white rounded cards, big bold titles, black round and pill actions, a custom white tab bar. Space Clean colors: logo navy #0A4781 as the strong accent, brand orange #C2410C as the highlight. Typeface: Manrope (bundled). Native behaviors stay per OS: back gestures, dialogs, date and choice pickers, haptics, and page transitions. The app is light-only.

## Evidence on Hand

- API contract: `docs/frontend-api.md`, `docs/api-message-keys.md` (git-ignored, kept locally).
- **None yet:** customers, testimonials, metrics, screenshots, or logo files in the repo. Don't fabricate them.

## Product Principles

1. **Each role opens to its own day.** Home is the work that role does next, not a generic dashboard.
2. **The field flow must work with no training.** Crew actions (check in, start, checklist, complete, check out) must be obvious, large, and hard to get wrong.
3. **Show only what the permissions allow.** Build screens from the member's effective permissions. Hide what isn't allowed rather than showing buttons that return 403.
4. **History is never lost.** Deactivate, resolve, version and reschedule instead of deleting, and make that history visible where it matters.
5. **Two languages from day one.** Every string, including server errors, is translated. No raw keys and no English-only text.

## Accessibility & Inclusion

- Crew with low tech literacy: plain words, one primary action per screen, icons paired with labels, forgiving flows with undo or confirmation on anything irreversible.
- Bright or outdoor light and gloves: high contrast, large touch targets (well above the 44–48 pt minimum for field actions), no information conveyed by color alone.
- Respect OS text scaling and screen readers on both platforms.
