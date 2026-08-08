# HealthPath Changelog

## 2026-08-08 — Wired frontend to Neon backend API

- Removed `supabase_flutter`. All repositories now call the REST API via
  `ApiClient` (`package:http` + bearer token in `shared_preferences`).
- `AuthCubit` restores sessions with `GET /api/auth/me` instead of a Supabase
  auth stream.
- Default API URL is `http://localhost:3000`; override with
  `--dart-define=API_BASE_URL=...`.
- Added [HOW_TO_RUN_AND_DEPLOY.md](HOW_TO_RUN_AND_DEPLOY.md).

## 2026-08-08 — Split into frontend and backend repositories

### Two repositories
- This repository is now **frontend only**, pushed to
  [47--Frontend](https://github.com/Wahid-Islam/47--Frontend). The new API
  lives in [47--Backend](https://github.com/Wahid-Islam/47--Backend).
- **Hoisted the Flutter project from `app/` to the repository root**, which
  is the convention for a dedicated Flutter repo. `pubspec.yaml`, `lib/`,
  `web/`, `test/` and `android/` are now top-level. Git history was preserved.
- `firebase.json` now serves `build/web` and `vercel.json` builds at the root,
  both dropping the `app/` prefix.
- Every doc path updated accordingly. Earlier changelog entries below still
  say `app/` because that was accurate when they were written.

### Database moving to Neon, but not yet
- The project's database is moving to **Neon Postgres on Vercel**. The backend
  API for it is built, typechecked and unit-tested.
- **This app deliberately still runs on Supabase.** Neon exposes a
  full-privilege `DATABASE_URL`, which can never ship in a browser bundle, so
  the app cannot talk to Neon directly — the API has to be deployed and
  verified first. Keeping Supabase live means nothing breaks in the meantime,
  and rollback stays a single revert.
- Added [API_MIGRATION.md](API_MIGRATION.md): why the move needs a backend,
  what changes (only `lib/controller/repositories/`), and the two parts that
  are not a straight swap — `onAuthStateChange` has no HTTP equivalent, and
  token storage on web is a real security decision.
- The API returns the **same `snake_case` shape Supabase did**, so
  `Profile.fromJson` and the other models need no changes at cutover.

## 2026-08-07 — Web-first pivot, repo cleanup, full documentation set

### Web is now the primary target
- Renamed `mobile/` → **`app/`**, and the Dart package
  `healthpath_mobile` → **`mysihat`** (imports are now
  `package:mysihat/...`). Android `android:label` also corrected to
  `mysihat`. The Android `applicationId` was deliberately left as
  `my.healthpath.healthpath_mobile` — see `docs/ROADMAP.md`.
- Rewrote `app/web/index.html`: real title, description and Open Graph
  tags, `theme-color`, `lang="en"`, and a **CSS pre-boot splash** (mysihat
  wordmark + spinner) that removes itself on the engine's
  `flutter-first-frame` event. Deliberately does not customise
  `flutter_bootstrap.js`, which would double-initialise the engine.
- Rewrote `app/web/manifest.json` for mysihat branding, `#1B7A4E` theme
  colour, `scope`/`start_url` of `/`, `lang: en-MY`, and `orientation:
  any` (was locked to portrait).
- Added `PageTitle` (`core/widgets/page_title.dart`) and wrapped every
  route, so the browser tab and history read "Personal Insights · mysihat"
  rather than one app-wide title.

### Desktop layout fixes
- `ResponsiveShell`: wide-screen content is now **centred** in a
  `Breakpoints.contentMaxWidth` (1080px) column. It was previously pinned
  against the sidebar with a hard-coded 900px cap and dead space on the
  right.
- Added `CenteredPane` (`core/widgets/centered_pane.dart`) and applied it
  to onboarding, login, register and the questionnaire — the screens
  outside the shell, which until now stretched full-width across a desktop
  monitor.
- `OnboardingScreen` rebuilt with a real desktop treatment: a two-column
  hero (56px display type + actions in a card) at ≥1024px, collapsing to
  the stacked layout below, both sharing `_Pitch`/`_Actions`.
- Login and register now support **browser conventions**: `autofillHints`
  for password managers, and Enter-to-submit via `onFieldSubmitted`.

### Cleanup — 227 MB removed
Full record in `docs/CLEANUP.md`.
- Deleted `backend/` (97 MB Express + MongoDB API, superseded by Supabase;
  its three logic files had already been ported to Dart).
- Deleted `web/` (121 MB abandoned React scaffold with no entry point).
- Deleted `_pdf_pages/` (29 MB of regenerable PDF renders).
- Deleted `docker-compose.yml` (an empty stub since the Supabase migration),
  `app/healthpath_mobile.iml`, `app/.idea/`, and a stray `~$st.docx`.

### Hosting config corrected
- `firebase.json` and `vercel.json` repointed to `app/build/web`.
- **Fixed a real caching bug:** `firebase.json` previously served
  `**/*.@(js|css|wasm)` with `max-age=31536000,immutable`. Flutter does not
  content-hash `main.dart.js` or `flutter_bootstrap.js`, so that would have
  pinned returning visitors to a stale build indefinitely. HTML/JS/JSON/WASM
  now revalidate; only fonts and images get a long cache.
- Added `X-Content-Type-Options`, `Referrer-Policy` and `X-Frame-Options`.

### Tooling
- Pinned `formatter: page_width: 110` in `analysis_options.yaml`, so a bare
  `dart format` no longer reflows the whole codebase to the 80-column
  default.
- Formatted all 61 files and fixed the one resulting lint
  (`curly_braces_in_flow_control_structures` in `risk_engine.dart`).

### Documentation
New: `docs/README.md` (index), `docs/WEB.md`,
`docs/RESPONSIVE_DESIGN.md`, `docs/REPO_STRUCTURE.md`, `docs/TESTING.md`,
`docs/SECURITY.md`, `docs/DESIGN_SYSTEM.md`, `docs/ROADMAP.md`,
`docs/CLEANUP.md`.

Updated: root `README.md`, `docs/ARCHITECTURE.md`, `docs/RUNBOOK.md`,
`docs/HOSTING.md`, `docs/DATABASE.md`, `docs/EPIC_1.md` — all `mobile/`
paths are now `app/`.

`docs/DESIGN_SYSTEM.md` records that `design-system/healthpath/MASTER.md`
still carries the superseded cyan palette and that
`app/lib/core/theme/app_theme.dart` is the source of truth.

### Quality
- `flutter analyze` clean; `flutter test` all green (24 tests, including
  the new `centered_pane_test.dart`); `flutter build web --release`
  succeeds and boots correctly from a static server.

## 2026-08-07 — Epic 1.0: Personalised Health Risk Understanding + mysihat rebrand

See `docs/EPIC_1.md` for the full US 1.1–1.3 → screen/table/acceptance mapping.

### Database / hosting
- Confirmed **PostgreSQL** on Supabase (`loqwoiizinnshwrgaunj`).
- Added `national_mortality_baselines` (24 seeded DOSM-inspired rows) and
  `questionnaire_responses` (append-only audit trail).
- Hosting scaffolds: `firebase.json`, `vercel.json`, `docs/HOSTING.md`.

### US 1.1 Questionnaire
- `ProfileWizardScreen` rewritten to use `Form` + `GlobalKey<FormState>` with
  field-level validators: `fullName`/`age`/`gender`/`state`/`bmi` required
  (`gender`/`state` now start unselected instead of pre-checked, so "required"
  is actually enforceable), `age` 18–90, `bmi` 10–60, plus validators on
  `activityLevel`/`dietHabit`/`smoking`/`highBloodPressure`.
- Added `controller/repositories/questionnaire_repository.dart` —
  `QuestionnaireRepository.submit({userId, answers})` inserts into the
  existing `public.questionnaire_responses` table (RLS already scoped to
  the owner on the Supabase project).
- On finish: save profile → insert questionnaire snapshot → recompute
  insights → refresh habits → mark onboarding complete → navigate to
  `/home/insights` (was `/home`).
- `core/widgets/chips.dart`: `ChoiceChipRow.value` is now nullable so a
  choice field can render as "unanswered" for required-field validation.

### US 1.2 Personal Insights
- `InsightsScreen` rebuilt: "Your Health Age" card with a dual circular
  Health Age vs. Actual Age comparison (`view/widgets/health_age_dual_gauge.dart`)
  and a localized success/caution message based on `healthAgeDelta`; "3 Main
  Contributing Factors" card (Activity/Diet/Sleep-or-next-highest); primary
  CTA "Next: Action Roadmap" → `/home/plan`.

### US 1.3 National comparison
- Added to `Insights`/`RiskEngine.compute`: `peerAverageHealthAge`,
  `healthAgeDelta`, `projectedHealthAgeFollowPlan`,
  `projectedHealthAgeNoChange`, `nationalComparisonHeadline(Bm)` — all with
  backward-compatible `fromJson` defaults for previously-persisted payloads.
- `InsightsScreen` "How You Compare Nationally" card: national comparison
  headline, a Health-Age-vs-national-average bar ("You" vs "National
  average", distinct colors), the existing top-risk-vs-national bar (kept),
  and the peer comparison paragraph.
- `RiskCompareBar` (`view/widgets/risk_bars.dart`) enhanced with
  `suffix`/`decimals` so it renders both age comparisons and risk
  percentages, and uses a dedicated neutral grey for "National average"
  (`AppTheme.secondaryCompare`) vs. green for "You".

### Action Roadmap (Epic 1 handoff)
- `PlanScreen` rebuilt: title/subtitle, a 12-month Health Age projection
  `fl_chart` line chart (`view/widgets/health_age_projection_chart.dart`,
  solid green "follow the plan" vs. dashed purple "no change"), the
  existing ranked action checklist + clinic CTA, and a new daily-habit
  checklist scoped to `HabitsCubit`.

### Branding / shell — mysihat, Variation 1
- Display name changed to **mysihat** (`AppStrings.appName`); package name
  `healthpath_mobile` unchanged.
- Re-themed to green/white wellness: primary `#1B7A4E`, accent `#059669`,
  background `#F7FBF8`, foreground `#14532D` (Lora + Raleway, 16px/48px
  minimums retained).
- Home shell destination labels updated (EN+BM): Overview, Personal
  Insights, Action Roadmap, Progress, Profile.
- `ResponsiveShell` wide-screen layout replaced with a **Variation 1**
  branded sidebar (`_BrandedSidebar`): extended `NavigationRail` + a
  "mysihat" wordmark/logo header. Bottom nav unchanged on phones.
- Router `redirect` now sends users leaving `/profile-wizard` to
  `/home/insights` specifically (other entry points still land on `/home`).

### Docs
- Added `docs/EPIC_1.md`.
- Updated `docs/DATABASE.md` (`questionnaire_responses`,
  `national_mortality_baselines`, extended `insights.payload` fields) and
  `docs/ARCHITECTURE.md` (routes, repositories, theme, responsive shell).

### Quality
- `flutter analyze` clean; `flutter test` all green, including new
  `risk_engine_test.dart` coverage for the US 1.3 fields and legacy-payload
  backward compatibility.
- No MongoDB touched; Supabase only. No primary constructors used.

## 2026-08-04 — Supabase + MVC Cubit migration

### Database
- Removed MongoDB as the project database of record (`docker-compose` Mongo service cleared).
- Created Supabase schema on project `loqwoiizinnshwrgaunj`:
  - `profiles`, `insights`, `habit_logs`, `clinics`
  - RLS enabled; owner-only policies for user tables
  - Public read for clinics
  - Auth trigger creates a profile row on signup
  - Hardened SECURITY DEFINER execute grants + `search_path`
- Seeded Klinik Kesihatan clinic rows.

### Mobile architecture
- Flutter app migrated from Provider monolith to **MVC + Cubit/BLoC**.
- Added `go_router`, `supabase_flutter`, layered `model/` / `view/` / `controller/`.
- Risk engine ported to Dart (on-device); Express/Mongo no longer required for the app.
- Responsive shell (bottom nav ↔ nav rail), Soft UI wellness theme, `package:checks` tests.
- `flutter analyze` clean; `flutter test` 14/14 passing.

### Docs
- `docs/ARCHITECTURE.md`, `docs/DATABASE.md`, `docs/RUNBOOK.md`, `docs/CHANGELOG.md`
- `design-system/healthpath/MASTER.md`
- `backend/DEPRECATED.md`
- Root `README.md` updated for Supabase-first workflow.

### Security notes
- Supabase advisors clean after hardening migrations.
- Client uses anon/publishable key only; RLS enforces owner access.
- Automated `/review-security` diff review could not compute a branch/uncommitted diff in this repo state — manual RLS + client key review was used instead.

## 2026-08-04 — Mobile app rewritten to MVC + Cubit + Supabase

### Mobile
- Replaced the Provider + Express/Mongo `ApiClient` state layer with
  Supabase (`supabase_flutter`) + `flutter_bloc` Cubits, organised as
  MVC: `model/` (immutable, hand-written JSON models), `view/`
  (screens/widgets only), `controller/` (repositories + services +
  cubits). See `docs/ARCHITECTURE.md`.
- Ported `backend/src/services/riskEngine.js`, `data/dosm.js`, and
  `data/actions.js` to Dart (`controller/services/risk_engine.dart`,
  `dosm_data.dart`, `action_catalog.dart`) so Health Age/risk scoring
  runs entirely on-device.
- Added `go_router` navigation with an auth-aware `redirect` (onboarding
  → profile wizard → home shell) and `usePathUrlStrategy()` for the web
  build.
- Added a responsive `ResponsiveShell` (bottom nav on phones, nav rail on
  tablet/desktop) and `Breakpoints`/`ResponsiveBuilder` helpers.
- Re-themed the app to the "Soft UI wellness" palette (`#0891B2` /
  `#059669` / `#ECFEFF` / `#164E63`) with Lora + Raleway via
  `google_fonts`, 16px minimum text and 48px minimum tap targets.
- Kept all existing product flows: onboarding, auth (login/register/demo),
  profile wizard, summary/home, insights, plan, progress, profile,
  clinics, EN/BM strings, and the population-data disclaimer.
- Removed `lib/screens/`, `lib/state/`, `lib/services/api_client.dart`,
  `lib/theme.dart`, `lib/l10n/strings.dart`, and `lib/widgets/common.dart`.
- Added tests: `RiskEngine` unit tests, a `LocaleCubit` `bloc_test`, and a
  widget test for shared components — all using `package:checks`.
  `flutter analyze` and `flutter test` are clean.
