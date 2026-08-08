# Web-first setup

mysihat targets the **browser** first. Android still builds from the same
codebase, but every layout, navigation and performance decision is made for
a desktop browser window and then verified to degrade cleanly to a phone.

## Why one codebase instead of a separate web app

Epic 1.0 — questionnaire, Health Age, national comparison, Action Roadmap —
is implemented once in Dart and compiles to both web and Android. The risk
engine (`lib/controller/services/risk_engine.dart`) runs on-device, so
the web build needs no application server: it is a static bundle plus
Supabase.

A separate React web client was scaffolded early on and then removed; see
[CLEANUP.md](CLEANUP.md).

## Entry point: `web/index.html`

Three things in there matter:

**A pre-boot splash.** Flutter web paints nothing until the engine, the
Dart bundle and fonts have loaded, which is seconds on a cold cache. Plain
CSS inside `index.html` paints the mysihat wordmark and a spinner
immediately. The engine fires a `flutter-first-frame` event once Dart has
painted; a small listener fades the splash out and removes it. This
deliberately does **not** customise `flutter_bootstrap.js` — calling
`_flutter.loader.load()` by hand alongside the generated bootstrap script
initialises the engine twice.

**Real metadata.** Title, description, Open Graph tags, `theme-color`
(`#1B7A4E`) and `lang="en"`, instead of the "A new Flutter project"
defaults.

**Viewport.** `width=device-width, initial-scale=1, viewport-fit=cover`.

## URLs

`main.dart` calls `usePathUrlStrategy()` from `flutter_web_plugins` when
`kIsWeb`, so routes are real paths (`/home/insights`) rather than hash
fragments (`/#/home/insights`). Every host therefore needs an SPA rewrite
sending unknown paths to `/index.html` — that rewrite is already in both
`firebase.json` and `vercel.json`.

Each route also sets the document title through `PageTitle`
(`lib/core/widgets/page_title.dart`), which wraps Flutter's `Title`
widget. Without it, every browser history entry and bookmark would read
"mysihat"; with it they read "Personal Insights · mysihat".

## PWA

`web/manifest.json` declares the name, `#1B7A4E` theme colour,
`#F7FBF8` background, `start_url: /`, `scope: /`, `lang: en-MY` and
`orientation: any`. Orientation is deliberately not locked to portrait —
this is a desktop-first app.

## Caching

Flutter's web output filenames are **not** content-hashed: `main.dart.js`,
`flutter_bootstrap.js` and `flutter_service_worker.js` keep the same name
across builds. Serving those with a long `immutable` cache pins returning
visitors to a stale build forever.

`firebase.json` therefore sets:

| Pattern | `Cache-Control` |
|---|---|
| `**/*.@(html\|js\|json\|wasm)` | `public,max-age=0,must-revalidate` |
| fonts and images | `public,max-age=604800` |

Plus `X-Content-Type-Options: nosniff`, `Referrer-Policy:
strict-origin-when-cross-origin` and `X-Frame-Options: SAMEORIGIN` on
everything.

## Browser-native behaviour worth keeping in mind

Because this is a canvas-rendered app, browser conveniences have to be
opted into rather than inherited:

- **Password managers** — login and register fields declare
  `autofillHints` (`email`, `password`, `newPassword`, `name`).
- **Enter to submit** — both auth forms wire `onFieldSubmitted` to the same
  handler as the button.
- **Deep links** — every screen has its own path, so refresh and
  back/forward work.
- **Text selection** is *not* enabled app-wide yet; see [ROADMAP.md](ROADMAP.md).

## Build

```powershell
cd app
flutter build web --release
```

Output goes to `build/web`. To check it as a real static site:

```powershell
cd app\build\web
python -m http.server 8081 --bind 127.0.0.1
```

`flutter build web` also prints a "Wasm dry run succeeded" hint. Compiling
with `--wasm` is a future option, not the current default; see
[ROADMAP.md](ROADMAP.md).

## Related

- [RESPONSIVE_DESIGN.md](RESPONSIVE_DESIGN.md) — how layouts adapt
- [HOSTING.md](HOSTING.md) — deploying the bundle
