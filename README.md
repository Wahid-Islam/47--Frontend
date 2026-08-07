# mysihat (HealthPath)

Personalised preventive health insights for Malaysians aged 40–60.
**Understand today. Act for tomorrow.**

mysihat is a **web-first** Flutter application. It takes a short health
questionnaire, compares the answers against Malaysian mortality statistics,
and returns a personalised **Health Age**, the lifestyle factors driving it,
and a preventive **Action Roadmap**.

## Stack

| Piece | Technology |
|---|---|
| Primary target | **Web** (Flutter web, deployed as a static SPA) |
| Secondary target | Android, from the same codebase |
| App | Flutter — MVC + Cubit/BLoC + `go_router` |
| Database & auth | **PostgreSQL on Supabase** (`loqwoiizinnshwrgaunj`) |
| Risk scoring | On-device Dart (`RiskEngine`), no server round trip |
| Hosting | Firebase Hosting or Vercel |

There is no application server. The Flutter client talks to Supabase
directly, and Row Level Security is what enforces per-user access.

## Run it

```powershell
cd D:\S2-2026\W1-W3\app
flutter pub get
flutter run -d chrome
```

Then complete the questionnaire → Personal Insights → Action Roadmap. The
landing page also has a **demo login** that seeds a fully populated profile.

## Layout

```
app/            The Flutter application (web-first)
docs/           All project documentation — start at docs/README.md
design-system/  Generated design tokens and UX guidelines
firebase.json   Firebase Hosting config (serves app/build/web)
vercel.json     Vercel config (serves app/build/web)
```

## Documentation

Everything is documented under [`docs/`](docs/README.md). The most useful
entry points:

| Doc | Read it when you want to |
|---|---|
| [docs/README.md](docs/README.md) | Find the right document |
| [docs/REPO_STRUCTURE.md](docs/REPO_STRUCTURE.md) | Know what every file and folder is for |
| [docs/RUNBOOK.md](docs/RUNBOOK.md) | Run, test, build or deploy |
| [docs/WEB.md](docs/WEB.md) | Understand the web-first setup |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Understand MVC + Cubit layering |
| [docs/DATABASE.md](docs/DATABASE.md) | Work on the Postgres schema or RLS |
| [docs/EPIC_1.md](docs/EPIC_1.md) | Check Epic 1.0 acceptance criteria |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | See what changed and why |

## Quality gates

```powershell
cd app
flutter analyze     # must report no issues
flutter test        # must be all green
```

## Disclaimer

mysihat reports **population-level statistical insight, not a medical
diagnosis**. It does not replace consultation with a healthcare
professional.
