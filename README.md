# mysihat (HealthPath) — Frontend

Personalised preventive health insights for Malaysians aged 40–60.
**Understand today. Act for tomorrow.**

mysihat is a **web-first** Flutter application. It takes a short health
questionnaire, compares the answers against Malaysian mortality statistics,
and returns a personalised **Health Age**, the lifestyle factors driving it,
and a preventive **Action Roadmap**.

This repository is the **frontend**. The API lives separately in
[47--Backend](https://github.com/Wahid-Islam/47--Backend).

## Stack

| Piece | Technology |
|---|---|
| Primary target | **Web** (Flutter web, deployed as a static SPA) |
| Secondary target | Android, from the same codebase |
| App | Flutter — MVC + Cubit/BLoC + `go_router` |
| Data & auth | **PostgreSQL on Supabase** (`loqwoiizinnshwrgaunj`) |
| Risk scoring | On-device Dart (`RiskEngine`), no server round trip |
| Hosting | Firebase Hosting or Vercel |

## Where the backend fits

The project is moving its database to **Neon Postgres on Vercel**, and the
[backend API](https://github.com/Wahid-Islam/47--Backend) is built and tested.

**This app still runs on Supabase**, on purpose. Neon's `DATABASE_URL` is a
full-privilege credential that can never ship in a browser bundle, so the
move depends on that API being deployed and verified first. Keeping Supabase
live until then means the app never stops working.

The cutover touches only `lib/controller/repositories/` — the API deliberately
returns the same `snake_case` shape Supabase did, so no model, cubit, screen
or route changes. Details: [docs/API_MIGRATION.md](docs/API_MIGRATION.md).

## Run it

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter pub get
flutter run -d chrome
```

Then complete the questionnaire → Personal Insights → Action Roadmap. The
landing page also has a **demo login** that seeds a fully populated profile.

## Layout

The Flutter project is at the repository root, so `lib/`, `web/` and
`pubspec.yaml` are top-level. Full tour:
[docs/REPO_STRUCTURE.md](docs/REPO_STRUCTURE.md).

## Documentation

Everything is documented under [`docs/`](docs/README.md). The most useful
entry points:

| Doc | Read it when you want to |
|---|---|
| [docs/README.md](docs/README.md) | Find the right document |
| [docs/REPO_STRUCTURE.md](docs/REPO_STRUCTURE.md) | Know what every file and folder is for |
| [docs/RUNBOOK.md](docs/RUNBOOK.md) | Run, test, build or deploy |
| [docs/API_MIGRATION.md](docs/API_MIGRATION.md) | Move this app off Supabase onto the API |
| [docs/WEB.md](docs/WEB.md) | Understand the web-first setup |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Understand MVC + Cubit layering |
| [docs/DATABASE.md](docs/DATABASE.md) | Work on the Postgres schema or RLS |
| [docs/EPIC_1.md](docs/EPIC_1.md) | Check Epic 1.0 acceptance criteria |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | See what changed and why |

## Quality gates

```powershell
flutter analyze     # must report no issues
flutter test        # must be all green
```

## Disclaimer

mysihat reports **population-level statistical insight, not a medical
diagnosis**. It does not replace consultation with a healthcare
professional.
