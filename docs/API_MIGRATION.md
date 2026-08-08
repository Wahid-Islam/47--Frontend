# Migrated from Supabase to the Neon backend API

**Status: done.** This app no longer uses Supabase. It talks to the
[mysihat backend](https://github.com/Wahid-Islam/47--Backend) over HTTPS,
which stores data in Neon Postgres.

## What changed

| Was | Is now |
|---|---|
| `supabase_flutter` | `package:http` via `ApiClient` |
| `SupabaseConfig` | `ApiConfig` + `apiClient` |
| Supabase Auth stream | Token in `shared_preferences` + `GET /api/auth/me` on start |
| RLS | Backend filters every query by the JWT `userId` |

Models, cubits (except auth), screens, routing and widgets were unchanged —
API responses keep the same `snake_case` row shape.

## Local default

```
API_BASE_URL = http://localhost:3000
```

Override for production builds:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://YOUR-API.vercel.app
```

## Run and deploy

See [HOW_TO_RUN_AND_DEPLOY.md](HOW_TO_RUN_AND_DEPLOY.md).
