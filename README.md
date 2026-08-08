# mysihat (HealthPath) — Frontend

Personalised preventive health insights for Malaysians aged 40–60.
**Understand today. Act for tomorrow.**

mysihat is a **web-first** Flutter application. It takes a short health
questionnaire, compares the answers against Malaysian mortality statistics,
and returns a personalised **Health Age**, the lifestyle factors driving it,
and a preventive **Action Roadmap**.

This repository is the **frontend**. The API lives in
[47--Backend](https://github.com/Wahid-Islam/47--Backend).

## Stack

| Piece | Technology |
|---|---|
| Primary target | **Web** (Flutter web, static SPA) |
| Secondary target | Android, same codebase |
| App | Flutter — MVC + Cubit/BLoC + `go_router` |
| API / auth / DB | Backend on Vercel + **Neon Postgres** |
| Risk scoring | On-device Dart (`RiskEngine`) |
| Hosting | Vercel or Firebase Hosting |

## Run locally

**Terminal A — backend first** (from the backend repo / `../backend`):

```powershell
cd D:\S2-2026\W1-W3\backend
npm run dev
```

**Terminal B — frontend:**

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter pub get
flutter run -d chrome
```

Defaults to `http://localhost:3000`. Full guide (including deploy):
**[docs/HOW_TO_RUN_AND_DEPLOY.md](docs/HOW_TO_RUN_AND_DEPLOY.md)**.

## Quality gates

```powershell
flutter analyze
flutter test
```

## Documentation

| Doc | When to read it |
|---|---|
| [docs/HOW_TO_RUN_AND_DEPLOY.md](docs/HOW_TO_RUN_AND_DEPLOY.md) | Run locally or go online |
| [docs/API_MIGRATION.md](docs/API_MIGRATION.md) | How the app talks to the API |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | MVC + Cubit layering |
| [docs/EPIC_1.md](docs/EPIC_1.md) | Epic 1.0 acceptance criteria |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | What changed |

## Disclaimer

mysihat reports **population-level statistical insight, not a medical
diagnosis**. It does not replace consultation with a healthcare professional.
