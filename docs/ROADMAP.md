# Roadmap and known gaps

Honest list of what is not done. Ordered roughly by value per unit of
effort.

## Web polish

**Text selection.** The app does not wrap its content in a `SelectionArea`,
so users cannot select or copy text — something every other website allows.
It was left out because `SelectionArea` can interfere with tap handling in
lists and charts, so it needs a pass with the widget tests rather than a
blind wrap.

**Content-Security-Policy.** No CSP header is set. Flutter web needs
`wasm-unsafe-eval`, and Google Fonts loads stylesheets and font files from
`fonts.googleapis.com` and `fonts.gstatic.com`, so a strict policy takes
measurement. Currently only `nosniff`, `Referrer-Policy` and
`X-Frame-Options` are set — see [SECURITY.md](SECURITY.md).

**Self-hosted fonts.** Lora and Raleway are fetched from Google Fonts at
runtime, which costs a round trip on first paint and leaks a request to a
third party. Bundling them as assets would fix both and simplify the CSP.

**WebAssembly build.** `flutter build web` reports that a `--wasm` dry run
succeeds. Compiling to WasmGC is typically faster but drops support for
browsers without WasmGC, so it needs a browser-support decision first.

**Keyboard navigation.** Tab order has not been audited across the
questionnaire, and there are no keyboard shortcuts for switching tabs.

## Testing

**Repository tests.** None of the `controller/repositories/` classes are
tested — they need a mocked `SupabaseClient`. `mocktail` is already a
dev dependency.

**Screen-level tests.** No test covers a whole screen, because
`AuthCubit`'s default constructor reaches for the real Supabase client. It
does accept injected repositories, so the path forward is mocking
`AuthRepository` and `ProfileRepository`.

**Landing page layout test.** `CenteredPane` is tested directly, but nothing
asserts that `OnboardingScreen` actually switches to the two-column desktop
hero at 1024px. Blocked on the same `AuthCubit` mocking work.

**Coverage reporting.** `flutter test --coverage` writes `lcov.info`, but
there is no `genhtml` on Windows and no CI job publishing a coverage
number.

## Data integrity

**Postgres `CHECK` constraints.** Age (18–90) and BMI (10–60) are validated
only in the Flutter form, which a determined client can bypass. Those
bounds, plus enum constraints on `gender`, `activity_level` and
`diet_habit`, belong in the schema.

**Real DOSM data.** `dosm_data.dart` holds baseline mortality curves
described as "DOSM-inspired", and `national_mortality_baselines` is seeded
with 24 rows in the same spirit. Replacing them with published DOSM figures,
with citations, is what would make the national comparison defensible.

## Mobile (secondary target)

**Android `applicationId`.** Still `my.healthpath.healthpath_mobile` even
though the Dart package is now `mysihat`. Changing it means moving the
Kotlin source directories and breaking upgrades for anyone who has the app
installed, so it was deliberately left alone.

**No iOS target.** The `ios/` platform folder has never been generated.
`flutter create --platforms=ios .` at the repo root would add it.

## Operations

**No CI.** Nothing runs `flutter analyze` and `flutter test` automatically.
A GitHub Actions workflow on push would catch regressions that currently
depend on someone remembering.

**No error reporting.** Failures surface in the UI and are otherwise lost.
Any reporting tool needs the health-data considerations in
[SECURITY.md](SECURITY.md) thought through first.

**No environment separation.** `SupabaseConfig` hardcodes one project, so
development and production share a database. `--dart-define` would let the
project ref be supplied at build time.
