# Epic 1.0 — Personalised Health Risk Understanding

**App:** `app/` (Flutter, package `mysihat`, display name **mysihat**), web-first
**Design:** mysihat Personal Insights + Action Roadmap, green/white wellness palette, Variation 1 sidebar on wide screens.

This document maps each user story to the screens, data, and acceptance
criteria that satisfy it, for review/QA purposes.

---

## US 1.1 — Questionnaire

**Goal:** Collect demographics + lifestyle answers, validate them, persist
a profile + an immutable questionnaire snapshot, compute Health Age, and
land the user on Personal Insights.

| Piece | Location |
| --- | --- |
| Screen | `lib/view/screens/profile_wizard_screen.dart` |
| Validation | `Form` + `GlobalKey<FormState>`, per-field `validator`s (only the visible step's fields are mounted, so `validate()` naturally scopes to the current step) |
| Persist profile | `ProfileCubit.save()` → `ProfileRepository.upsertProfile()` → `public.profiles` |
| Persist questionnaire snapshot | `QuestionnaireRepository.submit()` → `public.questionnaire_responses` (new repo) |
| Compute Health Age | `InsightsCubit.recalculate()` → `RiskEngine.compute()` |
| Mark onboarding complete | `AuthCubit.markOnboardingComplete()` |
| Navigate on finish | `context.go('/home/insights')` (explicit, plus the router `redirect` also prefers `/home/insights` when leaving `/profile-wizard`) |

### Fields & validators

| Field | Required | Validation |
| --- | --- | --- |
| `fullName` | Yes | Non-empty after trim |
| `age` | Yes | Integer, `18 <= age <= 90` |
| `gender` | Yes | Must be selected (starts unselected — no default chip is pre-checked) |
| `state` | Yes | Must be selected (starts unselected) |
| `activityLevel` | — | Choice field, always has a valid default; still wrapped in a `FormField` for consistency |
| `dietHabit` | — | Same as above |
| `bmi` | Yes | Numeric, `10 <= bmi <= 60` |
| `smoking` | — | Boolean switch, never blank |
| `highBloodPressure` | — | Boolean switch, never blank |

Field-level errors render inline (red helper text) under each control via
`FormField.errorText` / a shared `_fieldError` helper — no generic banner
mixed with specific field errors.

### Acceptance criteria → verification

- **Mandatory fields cannot be blank.** `gender`/`state` start as `null`
  (no default selection) and fail validation until chosen; `fullName`,
  `age`, `bmi` fail on empty input. Covered by inline validators;
  exercised manually + via `flutter analyze`/`flutter test` (widget tests
  for the shared `ChoiceChipRow`/button components still pass with the
  now-nullable `value`).
- **Invalid inputs show clear field-level validation.** Age outside
  18–90 or non-integer → `validationAgeRange`; BMI outside 10–60 or
  non-numeric → `validationBmiRange`; unselected choice fields →
  `validationSelect` — all localized EN/BM.
- **Valid submit stores profile + questionnaire snapshot and computes
  Health Age.** `_submit(finish: true)` chains `ProfileCubit.save` →
  `QuestionnaireRepository.submit` → `InsightsCubit.recalculate` →
  `HabitsCubit.refreshToday` → `AuthCubit.markOnboardingComplete`.
- **After successful finish, navigate to Personal Insights.**
  `context.go('/home/insights')` runs immediately after the above chain
  completes (not just a generic `/home`).

---

## US 1.2 — Personal Insights

**Goal:** Show the user's Health Age vs. actual age with a clear
success/caution message, and the top 3 contributing lifestyle factors.

| Piece | Location |
| --- | --- |
| Screen | `lib/view/screens/insights_screen.dart` |
| Dual age comparison | `lib/view/widgets/health_age_dual_gauge.dart` (`HealthAgeDualGauge`) |
| Contributing factors | `FactorBar` (`lib/view/widgets/risk_bars.dart`) fed by `InsightsScreen._topFactors()` |
| Model | `lib/model/insights.dart` (`Insights`, `RiskFactor`) |
| Compute | `lib/controller/services/risk_engine.dart` (`RiskEngine.compute`) |

### Layout

1. **AppBar:** "Personal Insights" / "Wawasan Peribadi" (`AppStrings['insights']`).
2. **Subtitle:** `insightsSubtitle` — one line about Health Age + key factors.
3. **"Your Health Age" card:** `HealthAgeDualGauge` renders two large
   circular numbers side-by-side (Health Age, colored green if
   healthier-than-actual or amber if older-than-actual; Actual Age,
   neutral grey), both on a shared 0–100 scale so their fill lengths are
   directly comparable. Below the gauges, a localized message box:
   - `healthAgeYoungerMsg` (green) when `healthAgeDelta < 0`
   - `healthAgeOlderMsg` (amber) when `healthAgeDelta > 0`
   - `healthAgeSameMsg` (green) when `healthAgeDelta == 0`
4. **"3 Main Contributing Factors" card:** `InsightsScreen._topFactors()`
   prefers `physical_inactivity` (Activity), `diet` (Diet), and `sleep`
   (not currently modelled — no questionnaire field for it yet) from
   `insights.factors`, falling back to the next-highest-scored factors so
   exactly 3 `FactorBar` rows are always shown, each with a colored
   High/Medium/Low `RiskChip`.
5. **National comparison** — see US 1.3 below (same screen).
6. **Primary CTA:** "Next: Action Roadmap" / "Seterusnya: Pelan Tindakan"
   → `context.go('/home/plan')`.

---

## US 1.3 — National comparison

**Goal:** Visually compare the user's Health Age and top risk against
national/peer averages for their age + gender band.

| Piece | Location |
| --- | --- |
| Section | `InsightsScreen` → "How You Compare Nationally" card |
| Bars | `RiskCompareBar` (`lib/view/widgets/risk_bars.dart`), enhanced with `suffix`/`decimals` params so it renders both ages ("48") and risk percentages ("18.4%") |
| Copy | `Insights.nationalComparisonHeadline(Bm)`, `Insights.peerComparison(Bm)` |

### What's shown

1. **Headline** (`nationalComparisonHeadline`): one sentence combining the
   Health-Age-vs-national-average delta and the top-risk personal-vs-national
   percentage, e.g. *"Your Health Age (54) is 6 years higher than the
   national average (48) for men your age. Your top risk, cardiovascular
   disease, sits at 32.4% vs a national average of 22.0%."*
2. **Health Age comparison bar:** `RiskCompareBar` with `personal =
   healthAge`, `national = peerAverageHealthAge`, labeled **"You"** (green,
   `AppTheme.primary`) vs **"National average"** (neutral grey,
   `AppTheme.secondaryCompare`) — a visually distinct color pair reused
   from the risk-percentage bar below it.
3. **Top risk comparison bar:** the existing `RiskCompareBar` (kept, now
   reusable) showing `topRisk.personalRisk` vs `topRisk.nationalAverage`.
4. **Peer comparison copy:** `insights.localizedPeerComparison(locale)`.

### Model / engine additions (`lib/model/insights.dart`, `lib/controller/services/risk_engine.dart`)

| Field | Meaning | MVP formula |
| --- | --- | --- |
| `peerAverageHealthAge` | Demographic (age+gender band) average Health Age | `actualAge` (average-lifestyle peer ≈ their own chronological age) |
| `healthAgeDelta` | Signed distance from actual age | `healthAge - actualAge` |
| `projectedHealthAgeFollowPlan` | 12-month optimistic projection for the roadmap chart | `max(healthAge - 6, actualAge - 12)` |
| `projectedHealthAgeNoChange` | 12-month pessimistic projection for the roadmap chart | `min(healthAge + 8, actualAge + 15)` |
| `nationalComparisonHeadline(Bm)` | One-sentence EN/BM summary | Built from `healthAge`, `peerAverageHealthAge`, and `topRisk` |

All fields have defaults in `Insights.fromJson` (falling back to
`actualAge`/`healthAge`-derived values), so older persisted
`insights.payload` rows deserialize without error — verified by the new
`risk_engine_test.dart` case *"Insights.fromJson fills MVP defaults for
legacy payloads missing US 1.3 fields"*.

---

## Action Roadmap (Epic 1 handoff)

| Piece | Location |
| --- | --- |
| Screen | `lib/view/screens/plan_screen.dart` |
| Chart | `lib/view/widgets/health_age_projection_chart.dart` (`HealthAgeProjectionChart`, `fl_chart` `LineChart`) |
| Action checklist | `ActionCard` (existing, unchanged) fed by `insights.topActions` |
| Habit checklist | `_HabitChecklist` (new, scoped `BlocBuilder` on `HabitsCubit`) fed by `insights.habits` via `HabitsCubit` |

- **Title/subtitle:** "Action Roadmap" / "Pelan Tindakan" + `planSubtitle`.
- **Health Age projection (12 months) chart:** solid green line from
  `healthAge` → `projectedHealthAgeFollowPlan` ("Follow the plan"), dashed
  purple line from `healthAge` → `projectedHealthAgeNoChange` ("No
  change"), linearly interpolated month-by-month.
- **Action checklist:** unchanged `ActionCard`s (impact chip, CTA button),
  ranked by `RiskEngine._rankActions`.
- **Daily habit checklist:** reuses `HabitsCubit` (same source as the
  Progress tab) so ticking a habit here and on Progress stays in sync.
- **Clinic CTAs kept:** `ActionCard.onClinic` still pushes `/clinics`.

---

## Branding / shell (Variation 1)

- **Display name:** `AppStrings['appName']` → **mysihat**. The Dart package
  is also `mysihat`; Supabase project and table names are unchanged.
- **Theme** (`lib/core/theme/app_theme.dart`): green/white wellness —
  primary `#1B7A4E`, accent `#059669`, background `#F7FBF8`, foreground
  `#14532D`. Lora (headings) + Raleway (body) retained; 16px minimum text,
  48px minimum tap targets retained.
- **Home shell destinations** (`lib/view/screens/home_shell.dart`, driven
  by `AppStrings`): Overview, Personal Insights, Action Roadmap, Progress,
  Profile (EN+BM).
- **`ResponsiveShell`** (`lib/core/widgets/responsive_shell.dart`): wide
  screens (`>= Breakpoints.tablet`) now render a **Variation 1 branded
  sidebar** — an extended `NavigationRail` with a "mysihat" wordmark +
  logo mark header (`_BrandedSidebar`) — instead of a bare icon rail.
  Phones keep the bottom `NavigationBar`.
- **Auth redirect after onboarding:** `app_router.dart`'s `redirect`
  callback now sends a user leaving `/profile-wizard` to
  `/home/insights` specifically (other authenticated entry points —
  splash/onboarding/login/register — still land on `/home`).

---

## Data model

### `public.questionnaire_responses` (existing table, now used by the app)

| Column | Type | Notes |
| --- | --- | --- |
| `id` | `uuid` | PK, `gen_random_uuid()` |
| `user_id` | `uuid` | FK → `profiles.id`, RLS-scoped |
| `answers` | `jsonb` | Full questionnaire snapshot (fullName, age, gender, state, activityLevel, dietHabit, smoking, bmi, highBloodPressure) |
| `submitted_at` | `timestamptz` | `now()` |

RLS: `authenticated` role, `INSERT`/`SELECT` scoped to `auth.uid() = user_id`
(`questionnaire_insert_own`, `questionnaire_select_own` — already applied
on the `loqwoiizinnshwrgaunj` project). See `docs/DATABASE.md`.

### `public.insights.payload` (jsonb, extended)

Adds `peerAverageHealthAge`, `healthAgeDelta`,
`projectedHealthAgeFollowPlan`, `projectedHealthAgeNoChange`,
`nationalComparisonHeadline`, `nationalComparisonHeadlineBm` — see
"Model / engine additions" above. No column/table migration required
(same `jsonb` column); backward-compatible via `Insights.fromJson`
defaults.

---

## Quality

- `flutter analyze` — clean (0 issues).
- `flutter test` — all suites passing, including new/updated
  `risk_engine_test.dart` cases for the US 1.3 fields and legacy-payload
  backward compatibility.
- All new `BlocBuilder`s use scoped `buildWhen` (e.g. `_HabitChecklist`
  only rebuilds on `items` changes); widgets favor `const` constructors
  where they don't depend on cubit state.
- No MongoDB touched; all persistence is Supabase (`profiles`, `insights`,
  `questionnaire_responses`).
- No primary constructors used (project convention).
