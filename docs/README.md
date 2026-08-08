# mysihat documentation

Every document in this folder is kept current with the code. If you change
behaviour, update the relevant doc **and** append an entry to
[CHANGELOG.md](CHANGELOG.md) in the same change.

## Start here

| Doc | Covers |
|---|---|
| [REPO_STRUCTURE.md](REPO_STRUCTURE.md) | What every folder and file in the repo is for |
| [HOW_TO_RUN_AND_DEPLOY.md](HOW_TO_RUN_AND_DEPLOY.md) | Run locally and deploy online |
| [RUNBOOK.md](RUNBOOK.md) | Every command: run, test, format, build, deploy |
| [API_MIGRATION.md](API_MIGRATION.md) | How the app talks to the Neon backend API |

## Product

| Doc | Covers |
|---|---|
| [EPIC_1.md](EPIC_1.md) | Epic 1.0 user stories 1.1–1.3 mapped to screens, tables and acceptance criteria |
| [ROADMAP.md](ROADMAP.md) | Known gaps and the follow-up work queue |

## Engineering

| Doc | Covers |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | MVC + Cubit/BLoC layering, routing, data flow |
| [WEB.md](WEB.md) | The web-first setup: entry point, PWA, URLs, caching, browser support |
| [RESPONSIVE_DESIGN.md](RESPONSIVE_DESIGN.md) | Breakpoints and the rules that keep phone and desktop layouts honest |
| [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) | Colour, type and spacing tokens, and the accessibility bar |
| [DATABASE.md](DATABASE.md) | Postgres schema, RLS policies, triggers, migrations |
| [TESTING.md](TESTING.md) | Test layout, conventions, coverage |
| [SECURITY.md](SECURITY.md) | Threat model for a keyless static SPA, RLS, what must never ship |
| [HOSTING.md](HOSTING.md) | Deploying to Firebase Hosting or Vercel |

## History

| Doc | Covers |
|---|---|
| [CHANGELOG.md](CHANGELOG.md) | Dated record of every significant change |
| [CLEANUP.md](CLEANUP.md) | What was deleted from the repo, and why |

## Conventions used across these docs

- Paths are relative to the repo root, where the Flutter project lives.
- Code identifiers are written as `RiskEngine.compute` or `profiles.user_id`.
- "US 1.2" style references point at [EPIC_1.md](EPIC_1.md).
