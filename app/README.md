# HealthPath Mobile

Personalised Health Age and preventive actions for Malaysians aged 40–60,
built with Flutter using **MVC + Cubit/BLoC + Supabase**.

See [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) for the app
structure and [`docs/DATABASE.md`](../docs/DATABASE.md) for the Supabase
schema and RLS policies.

## Requirements

- Flutter 3.x (stable channel), Dart SDK `^3.12.2`
- A configured Supabase project (URL + anon key are already set in
  `lib/core/config/supabase_config.dart`)

## Run

```bash
flutter pub get
flutter run                 # pick a connected device/emulator
flutter run -d chrome        # run on web
```

## Test & analyze

```bash
flutter analyze
flutter test
```

## Demo login

From onboarding or the login screen, tap **"Try demo (Lim Wei Jian)"** to
sign up/in as `lim.weijian@healthpath.demo`, apply a pre-filled profile
(age 48, low activity, unhealthy diet, smoker, BMI 27.4, high blood
pressure), and see computed insights immediately.
