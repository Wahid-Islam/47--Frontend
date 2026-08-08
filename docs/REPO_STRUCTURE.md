# Repository structure

This repository is the **frontend only**. The backend API lives in a
separate repository, [47--Backend](https://github.com/Wahid-Islam/47--Backend).
See [API_MIGRATION.md](API_MIGRATION.md) for how the two relate.

The Flutter project sits at the repository root — there is no `app/`
subfolder, so `pubspec.yaml`, `lib/` and `web/` are top-level. The Dart
package is named **`mysihat`**, so internal imports read
`package:mysihat/...`.

```
47--Frontend/
├─ lib/
│  ├─ main.dart             Init Supabase, path URL strategy, runApp
│  ├─ app.dart              Provides every Cubit, owns the GoRouter
│  ├─ core/                 Cross-feature infrastructure
│  │  ├─ config/            Supabase URL + anon key, client accessor
│  │  ├─ l10n/              EN/BM string table, Malaysian states list
│  │  ├─ responsive/        Breakpoints, ResponsiveBuilder
│  │  ├─ router/            go_router config and auth-aware redirects
│  │  ├─ theme/             Design tokens and ThemeData
│  │  └─ widgets/           Shared presentational widgets
│  ├─ model/                Immutable domain models (the "M")
│  ├─ controller/           Business logic (the "C")
│  │  ├─ cubits/            One Cubit + State per feature
│  │  ├─ repositories/      One class per Supabase table
│  │  └─ services/          Pure logic: risk engine, DOSM data, action catalog
│  └─ view/                 Screens and screen-specific widgets (the "V")
│     ├─ screens/
│     └─ widgets/
├─ test/                    Mirrors lib/ one-for-one
├─ web/                     Web entry point: index.html, manifest.json, icons
├─ android/                 Secondary target
├─ docs/                    All documentation — index at docs/README.md
├─ design-system/           Generated design tokens and UX guidelines
├─ pubspec.yaml
├─ analysis_options.yaml    flutter_lints + formatter page_width: 110
├─ firebase.json            Firebase Hosting config → serves build/web
├─ vercel.json              Vercel config → builds and serves build/web
├─ README.md                Project front door
├─ .gitignore
├─ HealthPath_Bridging_the_Malaysian_Health_Data_Gap.pdf   Source brief
├─ f02d1a98-...png          Source UI design sheet (mysihat "Variation 1")
└─ st.docx                  Source requirements document
```

The three source files at the root are the original inputs the product was
built from. They are kept because the design and copy decisions trace back
to them.

### `lib/core/widgets/`

| File | Purpose |
|---|---|
| `responsive_shell.dart` | Bottom nav ↔ branded sidebar, plus `BrandedSidebar` |
| `centered_pane.dart` | Caps and centres content outside the shell |
| `page_title.dart` | Sets the browser tab title per route |
| `buttons.dart`, `cards.dart`, `chips.dart`, `banners.dart` | Shared presentational components |

### `lib/controller/services/`

| File | Purpose |
|---|---|
| `risk_engine.dart` | `RiskEngine.compute(Profile) → Insights`. All Health Age and risk maths. |
| `dosm_data.dart` | Baseline mortality curves derived from DOSM statistics |
| `action_catalog.dart` | Static catalog of preventive actions and daily habits |

The risk engine stays on-device deliberately, so scoring has exactly one
implementation. The backend persists its output but never computes it.

### `test/`

Mirrors `lib/`, so `lib/core/widgets/centered_pane.dart` is tested by
`test/core/widgets/centered_pane_test.dart`. See [TESTING.md](TESTING.md).

## What is deliberately absent

**No server code.** This repository builds to a static bundle. The API that
replaced the deleted Node/Mongo backend is a separate repository — see
[CLEANUP.md](CLEANUP.md) for what was removed and why.

**Still talking to Supabase.** The app currently reaches Supabase directly,
with Row Level Security enforcing per-user access. The move to the new API is
documented but not yet done: [API_MIGRATION.md](API_MIGRATION.md).

## Generated directories

Ignored by git and safe to delete at any time; `flutter pub get` and
`flutter build` recreate them.

| Path | Recreate with |
|---|---|
| `.dart_tool/` | `flutter pub get` |
| `build/` | `flutter build web` |
| `.flutter-plugins-dependencies` | `flutter pub get` |

If Windows refuses to rename or delete one of these, a Dart analysis server
or a terminal sitting in that directory is holding a handle on it. Close
terminals in that folder, or stop the `dart.exe` processes; the IDE restarts
them automatically.
