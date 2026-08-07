# Cleanup record

A record of what was removed from the repository, so nobody has to wonder
whether a missing folder was deleted on purpose.

## 2026-08-07 — web-first cleanup

Removed roughly **227 MB** across four items, and renamed the app folder.

### `backend/` — deleted (97 MB)

An Express + MongoDB API. It was superseded when the project moved to
Supabase: the risk-scoring logic was ported to Dart in
`app/lib/controller/services/risk_engine.dart`, and the client now talks to
Postgres directly. The folder had already been marked deprecated with a
`DEPRECATED.md` and was dead code for two changes running.

Nothing was lost — the three files that mattered were ported before
deletion:

| Was | Is now |
|---|---|
| `backend/src/services/riskEngine.js` | `app/lib/controller/services/risk_engine.dart` |
| `backend/src/data/dosm.js` | `app/lib/controller/services/dosm_data.dart` |
| `backend/src/data/actions.js` | `app/lib/controller/services/action_catalog.dart` |

### `web/` — deleted (121 MB)

A half-finished React/Tailwind scaffold. By the time it was removed it
contained a single `src/style.css` and no entry point — the vanilla
TypeScript files it started from had been deleted and never replaced. It
had 7,000 files of `node_modules` behind it and could not build.

The decision it represented — a separate JavaScript web client — was
resolved the other way: Flutter web is the primary target, so Epic 1.0
exists once instead of twice. See [WEB.md](WEB.md).

### `_pdf_pages/` — deleted (29 MB)

Fifteen PNG renders of the source PDF, produced while reading the brief.
Regenerable from `HealthPath_Bridging_the_Malaysian_Health_Data_Gap.pdf`,
which is still in the repo.

### `docker-compose.yml` — deleted

Only ever defined the MongoDB service. After the Supabase migration it had
been emptied down to `services: {}` plus a comment, so it did nothing.

### Also removed

- `app/healthpath_mobile.iml` and `app/.idea/` — IntelliJ module metadata.
- `~$st.docx` — a Word lock-file artefact.

## Renames in the same change

| Was | Is now | Why |
|---|---|---|
| `mobile/` | `app/` | Web is the primary target, so "mobile" was misleading |
| package `healthpath_mobile` | package `mysihat` | Matches the product name; imports are now `package:mysihat/...` |
| Android `android:label` | `mysihat` | Was still the generated Flutter project name |

The Android `applicationId` is still `my.healthpath.healthpath_mobile`.
Changing it means moving the Kotlin source directories and breaking any
existing installs, so it was left alone deliberately — see
[ROADMAP.md](ROADMAP.md).

## Path references updated

| File | Change |
|---|---|
| `firebase.json` | `public` → `app/build/web` |
| `vercel.json` | build command and `outputDirectory` → `app/...` |
| `docs/*.md` | every `mobile/` path → `app/` |
| `app/test/**` | every `package:healthpath_mobile/` → `package:mysihat/` |

## Verification after cleanup

`flutter pub get`, `flutter analyze` (no issues), `flutter test` (all
green), and `flutter build web --release` (succeeds) were all re-run after
the rename.
