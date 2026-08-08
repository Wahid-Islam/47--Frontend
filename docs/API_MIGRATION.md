# Migrating from Supabase to the backend API

**Current state: this app still runs on Supabase.** Nothing here has been
switched yet. The [backend API](https://github.com/Wahid-Islam/47--Backend)
exists and is tested, but the cutover is deliberately a separate step so the
app keeps working while the API is deployed and verified.

## Why the database move needs a backend at all

The project moved its database to **Neon Postgres on Vercel**. Unlike
Supabase, Neon cannot be called from a browser:

- Supabase's anon key authorises nothing on its own. Row Level Security
  enforced access inside Postgres, keyed to the signed-in user's JWT. That is
  why shipping the key in this bundle was safe.
- Neon gives you a `DATABASE_URL` — a full-privilege Postgres credential.
  Anything compiled into `main.dart.js` is readable in DevTools, so putting it
  here would expose the whole database to anyone who loads the page.

So there is now an API in between, and it also takes over the two jobs
Supabase was doing for us: **authentication** and **per-user data isolation**.

## What makes the cutover small

The API returns **`snake_case` keys matching the Supabase row shape**. That
was a deliberate choice on the backend side, and it means:

- `Profile.fromJson`, `Insights.fromJson`, `HabitLogRow.fromJson` and
  `Clinic.fromJson` need **no changes**
- No cubit, screen, widget, route or theme changes
- Only `lib/controller/repositories/` and the config change

The repository layer was already the only place that imported
`supabase_flutter`, which is what keeps this contained. `http` is already a
dependency.

## What changes

| Replace | With |
|---|---|
| `core/config/supabase_config.dart` | `core/config/api_config.dart` — base URL + stored token |
| `AuthRepository` | `POST /api/auth/register`, `/login`, `/demo`; `GET /api/auth/me` |
| `ProfileRepository` | `GET` / `PUT /api/profile` |
| `InsightsRepository` | `GET` / `PUT /api/insights` |
| `HabitRepository` | `GET` / `PUT /api/habits/today` |
| `QuestionnaireRepository` | `POST /api/questionnaire` |
| `ClinicRepository` | `GET /api/clinics` |

Every authenticated request sends `Authorization: Bearer <token>`.

Endpoint and payload details: the backend's `docs/API.md`.

## The two parts that are not a straight swap

**`onAuthStateChange` has no equivalent.** `AuthCubit` currently subscribes to
a Supabase stream, and `go_router` refreshes its redirects from it via
`GoRouterRefreshStream`. There is no server-pushed stream over HTTP.

Instead, `AuthCubit` should:

1. On construction, read any stored token and call `GET /api/auth/me`
2. Emit `authenticated` with the returned user and profile, or
   `unauthenticated` on a `401`
3. Emit state directly from its own `login`/`register`/`logout` methods

`GoRouterRefreshStream` keeps working unchanged, because it listens to the
cubit's own stream rather than to Supabase.

**Token storage is a real security decision.** The obvious move is
`shared_preferences`, which is already a dependency — but on web that is
`localStorage`, readable by any script on the page, so an XSS bug becomes
account takeover. The alternative is an httpOnly cookie set by the API, which
scripts cannot read but which needs CSRF protection.

For a student project with a 7-day token, `localStorage` is a defensible
starting point. It should be a conscious choice, not a default, and it should
be revisited before this holds anyone's real health data.

## Suggested order

1. **Deploy the API first** and confirm `/api/health` reports
   `"database":"ok"`.
2. **Add this app's origin** to the API's `CORS_ALLOWED_ORIGINS`. In
   development that is whatever `flutter run -d chrome` prints — the port
   changes every run, and a mismatch is the usual cause of a CORS failure.
3. **Write `ApiClient`** — a thin wrapper over `package:http` that attaches
   the bearer token, decodes JSON, and maps non-2xx responses to a typed
   exception carrying the API's `error` message. The screens already display
   `state.errorMessage`, so error text flows through unchanged.
4. **Convert one repository at a time**, starting with `ClinicRepository`: it
   is public, needs no token, and proves the transport works end to end.
5. **Convert `AuthRepository` last**, since it is the one with real behaviour
   changes.
6. **Only then** remove `supabase_flutter` from `pubspec.yaml` and delete
   `supabase_config.dart`.

Keep the Supabase project paused rather than deleted for a while, so a
rollback is reverting a commit.

## Tests to add during the cutover

The repository layer has no tests today, which is exactly what makes replacing
it risky. `mocktail` is already a dev dependency, so each new repository can
be tested against a mocked HTTP client:

- A successful response parses into the right model
- A `401` surfaces as "not authenticated" rather than a crash
- A `400` surfaces the API's validation message
- The bearer token is actually attached

That is also the natural moment to fix the gap noted in
[ROADMAP.md](ROADMAP.md), where no repository is covered at all.

## Related

- Backend repo: <https://github.com/Wahid-Islam/47--Backend>
- Its `docs/MIGRATION_FROM_SUPABASE.md` covers the same move from the server
  side, including what to do about existing user data
- [DATABASE.md](DATABASE.md) — the Supabase schema this app still uses
