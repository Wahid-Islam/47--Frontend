# Hosting

mysihat deploys as a **static single-page app**. There is no server to run:
the Flutter web bundle is uploaded to a CDN and talks to Supabase directly
from the browser.

Database: **PostgreSQL on Supabase** (`loqwoiizinnshwrgaunj`), which is
already hosted — nothing to deploy there beyond migrations.

## Build

```powershell
cd D:\S2-2026\W1-W3\app
flutter build web --release
```

Output: `app/build/web`. Both host configs at the repo root point there.

## Two things every host must do

**1. SPA rewrite.** The app uses path-based URLs (`/home/insights`, not
`/#/home/insights`), so any unknown path must be rewritten to
`/index.html`. Without this, refreshing on `/home/insights` returns a 404.

**2. Correct cache headers.** Flutter's web output filenames are **not**
content-hashed — `main.dart.js`, `flutter_bootstrap.js` and
`flutter_service_worker.js` keep the same names across every build. Serving
them with a long `immutable` cache pins returning visitors to a stale
version indefinitely. HTML, JS, JSON and WASM must revalidate; only fonts
and images get a long cache.

Both configs in this repo already do both.

## Firebase Hosting (recommended)

`firebase.json` at the repo root is ready to use:

```json
{
  "hosting": {
    "public": "app/build/web",
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
```

It also sets `max-age=0,must-revalidate` on `**/*.@(html|js|json|wasm)`, a
7-day cache on fonts and images, and `X-Content-Type-Options`,
`Referrer-Policy` and `X-Frame-Options` on everything.

Deploy:

```powershell
firebase login
firebase use --add          # pick or create the Firebase project, once
cd D:\S2-2026\W1-W3\app
flutter build web --release
cd ..
firebase deploy --only hosting
```

Do **not** run `firebase init hosting` again — it will overwrite the tuned
cache headers in `firebase.json` with its defaults.

Firebase Hosting is recommended here because the Flutter build happens on
your machine or in CI, so the host never needs a Flutter toolchain.

## Vercel

`vercel.json` at the repo root:

```json
{
  "buildCommand": "cd app && flutter build web --release",
  "outputDirectory": "app/build/web",
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

The catch is that Vercel's build image has no Flutter SDK, so
`buildCommand` fails unless you install it first. Two ways around it:

- **Install Flutter in the build step** — prefix the build command with a
  script that clones the Flutter SDK and puts it on `PATH`. Slow, and it
  re-downloads on every build.
- **Build locally or in CI, deploy the output** — run
  `flutter build web --release` yourself and point Vercel at
  `app/build/web` as a pre-built static directory. Simpler and faster.

The security headers set in `firebase.json` are **not** replicated in
`vercel.json`. If you deploy to Vercel, add a `headers` block — see
[SECURITY.md](SECURITY.md) for which headers and why.

## Configuration and secrets

The Supabase URL and **anon (publishable)** key are compiled into the
bundle from `app/lib/core/config/supabase_config.dart`. That is expected and
safe: the anon key grants the `anon` Postgres role and authorises nothing on
its own, because Row Level Security is the enforcement layer.

**Never deploy the `service_role` key.** It bypasses RLS completely. There
are no other environment variables and no `.env` file to configure.

Both development and production currently point at the same Supabase
project. Splitting them needs `--dart-define`; see [ROADMAP.md](ROADMAP.md).

## After deploying

- Load the site and hard-reload once, to confirm you are not being served a
  cached bundle.
- Navigate to a deep link like `/home/insights` and refresh, to confirm the
  SPA rewrite works.
- Register a throwaway account and complete the questionnaire, to confirm
  Supabase auth and RLS work from the deployed origin.
