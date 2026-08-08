# Architecture

This Flutter app uses **MVC adapted for Flutter**, with **Cubit
(flutter_bloc)** as the controller-layer state management, **Supabase** as
the backend, and **go_router** for navigation.

**Web is the primary target**; Android builds from the same codebase as a
secondary target. See [WEB.md](WEB.md) for the web-specific setup and
[RESPONSIVE_DESIGN.md](RESPONSIVE_DESIGN.md) for how layouts adapt.

There is no application server. The client talks to Supabase directly, and
the risk-scoring logic that once lived in an Express API has been ported to
on-device Dart.

## Layers

```
lib/
  main.dart              Entry point: init Supabase, path URL strategy, runApp
  app.dart                Wires all Cubits, owns the GoRouter, syncs auth -> data loads
  core/
    config/               Supabase URL/anon key + client accessor
    theme/                 Soft UI wellness ThemeData (Lora + Raleway via google_fonts)
    router/                go_router config, auth-aware redirects
    l10n/                  EN/BM string table + Malaysian states list
    responsive/            Breakpoints + ResponsiveBuilder (LayoutBuilder-based)
    widgets/               Shared "dumb" widgets: buttons, cards, chips, banners,
                           the adaptive ResponsiveShell (bottom nav <-> sidebar),
                           CenteredPane (width capping), PageTitle (browser tab)
  model/                  Immutable, JSON-serializable domain models (Model)
  controller/             Business logic (Controller)
    repositories/          One class per Supabase table; only these touch the SDK
    services/               risk_engine.dart, dosm_data.dart, action_catalog.dart
    cubits/                 One Cubit + State per feature; call repositories/services
  view/                   Screens + widgets (View) — no business logic
    screens/
    widgets/
```

### Model

Plain Dart classes (`Equatable`, hand-written `fromJson`/`toJson`, no code
generation, no primary constructors). Each model mirrors one Supabase table
or one JSON shape used by the risk engine:

| Model | Mirrors |
| --- | --- |
| `Profile` | `public.profiles` row |
| `Insights`, `RiskItem`, `RiskFactor` | `public.insights.payload` jsonb |
| `ActionItem`, `ActionCta`, `HabitCatalogItem` | Static action/habit catalog + `insights.payload.topActions/habits` |
| `Clinic` | `public.clinics` row (+ on-device `distanceKm`) |
| `HabitLogRow`, `HabitItem`, `HabitsToday` | `public.habit_logs` row + derived "today" view model |

### Controller

- **Repositories** (`controller/repositories/`) are the *only* place that
  imports `supabase_flutter`. Each wraps one table (`profiles`, `insights`,
  `habit_logs`, `clinics`, `questionnaire_responses`) or Supabase Auth
  (`AuthRepository`). They return models, never raw maps.
  `QuestionnaireRepository.submit()` (Epic 1.0 / US 1.1) inserts one
  immutable snapshot row per profile-wizard submission — it doesn't read
  or cache, since the wizard is write-only from the app's perspective.
- **Services** (`controller/services/`) hold pure business logic:
  - `dosm_data.dart` — DOSM-inspired baseline mortality curves.
  - `action_catalog.dart` — static catalog of preventive actions and daily
    habits.
  - `risk_engine.dart` — `RiskEngine.compute(Profile)` → `Insights`. Runs
    entirely on-device, so scoring needs no network round trip.

  All three were ported from the deleted Express backend; see
  [CLEANUP.md](CLEANUP.md) for the file-by-file mapping.
- **Cubits** (`controller/cubits/`) are the glue between repositories/
  services and the View. Each has its own immutable `State`:
  - `AuthCubit` / `AuthState` — Supabase auth session, login/register/demo
    login/logout, and `onboardingComplete` (read from the profile) used by
    the router.
  - `ProfileCubit` / `ProfileState` — load/save the current profile.
  - `InsightsCubit` / `InsightsState` — load persisted insights, or
    `recalculate(profile)` to run `RiskEngine` and upsert the result.
  - `HabitsCubit` / `HabitsState` — load/create today's `habit_logs` row,
    derive the "today's habits" list from the latest insights, toggle
    completion.
  - `ClinicsCubit` / `ClinicsState` — load clinics and sort by on-device
    haversine distance from a reference point.
  - `LocaleCubit` — EN/BM locale, persisted via `shared_preferences`.

  Cubits are intentionally decoupled (no cubit depends on another cubit).
  Cross-cubit orchestration — e.g. "after the wizard saves a profile,
  recompute insights and refresh today's habits" — happens in the
  **screen's submit handler**, which reads multiple cubits and calls them
  in sequence. This keeps every cubit independently unit-testable.

### View

Screens under `view/screens/` and shared presentational widgets under
`core/widgets/` (app-wide) and `view/widgets/` (screen-specific, e.g. the
Health Age gauge, risk bars, action card). Screens:

- Use `BlocBuilder`/`BlocSelector` with `buildWhen`/`selector` to scope
  rebuilds to the smallest widget subtree, instead of rebuilding whole
  screens.
- Use `const` constructors wherever a widget doesn't depend on cubit state.
- Never call Supabase directly — only through `context.read<XCubit>()`.

## Navigation (`go_router`)

`core/router/app_router.dart` builds a single `GoRouter` with:

- Top-level routes: `/splash`, `/onboarding`, `/login`, `/register`,
  `/profile-wizard`, `/clinics`.
- A `StatefulShellRoute.indexedStack` for the authenticated home shell,
  with 5 branches: `/home` (Overview), `/home/insights` (Personal
  Insights, Epic 1.0 US 1.2/1.3), `/home/plan` (Action Roadmap, Epic 1.0
  handoff), `/home/progress`, `/home/profile`. Each branch keeps its own
  navigation stack and scroll position when switching tabs.
- A `redirect` callback driven by `AuthCubit.state`, refreshed via
  `GoRouterRefreshStream` (wraps the Cubit's `Stream` as a `Listenable`):
  unauthenticated → `/onboarding`; authenticated but
  `!onboardingComplete` → `/profile-wizard`; leaving `/profile-wizard`
  once onboarded → **`/home/insights`** (Epic 1.0 US 1.1 requires landing
  on Personal Insights, not just the generic home tab); other
  authenticated entry points (splash/onboarding/login/register) →
  `/home`.
- `ProfileWizardScreen` also calls `context.go('/home/insights')`
  explicitly right after a successful "finish" submit, so navigation
  doesn't depend solely on the redirect firing on the next rebuild.
- Web builds call `usePathUrlStrategy()` (from `flutter_web_plugins`) in
  `main.dart` so URLs are path-based (`/home/plan`) instead of using `#`.
  Hosts must rewrite unknown paths to `/index.html` — see
  [HOSTING.md](HOSTING.md).
- Every route is wrapped in `PageTitle`, which sets the browser tab title
  ("Personal Insights · mysihat") so history entries and bookmarks are
  meaningful.

## Responsive layout

Summarised here, detailed in [RESPONSIVE_DESIGN.md](RESPONSIVE_DESIGN.md).

`core/responsive/breakpoints.dart` defines `mobile < 600 <= tablet < 1024
<= desktop`, plus `contentMaxWidth = 1080`.

- `ResponsiveShell` switches between a bottom `NavigationBar` (phone) and
  the mysihat **Variation 1** `BrandedSidebar` (tablet and up): an extended
  `NavigationRail` under a wordmark header. On wide windows the content
  beside the sidebar is capped at `contentMaxWidth` and **centred**.
- `CenteredPane` caps and centres screens that sit *outside* the shell —
  onboarding, login, register, the questionnaire — at 460px for forms or
  960px for two-column panes.
- `OnboardingScreen` branches at `Breakpoints.desktop` into a two-column
  desktop hero or a stacked phone layout, sharing the same `_Pitch` and
  `_Actions` subtrees.

## Theme — mysihat "Green/white wellness"

`core/theme/app_theme.dart`: primary `#1B7A4E`, accent `#059669`,
background `#F7FBF8`, foreground `#14532D`. Headings use **Lora**, body
copy uses **Raleway** (both via `google_fonts`). Minimum body text is 16px
and every interactive control has a minimum 48×48 tap target, matching the
target audience (Malaysians aged 40–60+).

## Auth & demo flow

- `AuthRepository.register()` creates the Supabase Auth user, then
  performs a **safety-net upsert** of the `profiles` row (a DB trigger
  already creates it on signup, but the app doesn't rely on trigger
  timing).
- `AuthRepository.demoSignIn()` signs in as
  `lim.weijian@healthpath.demo` / `demo1234` (signs the account up on
  first use), applies the **Lim Wei Jian** profile (age 48, low activity,
  unhealthy diet, smoker, BMI 27.4, high blood pressure) unless the demo
  account was already customised, then runs `RiskEngine.compute` and
  upserts the result into `public.insights`.
- Finishing the profile wizard follows the same pattern: save the profile
  → `QuestionnaireRepository.submit` (questionnaire snapshot, best-effort)
  → `InsightsCubit.recalculate` → `HabitsCubit.refreshToday` →
  `AuthCubit.markOnboardingComplete()` → explicit
  `context.go('/home/insights')`, landing the user on Personal Insights
  (Epic 1.0 US 1.1) rather than the generic home tab.

## Testing

`test/` mirrors `lib/`. Conventions, the full test inventory and the
`package:checks` assertion style are in [TESTING.md](TESTING.md).

Run everything with `flutter test`; static analysis with `flutter analyze`.
Both are clean as of the web-first change.
