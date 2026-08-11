# MySihat frontend

Flutter web client for MySihat. Users complete a short health questionnaire, get a Health Age estimate, and pick a few daily habits to track.

The API lives in [47--Backend](https://github.com/Wahid-Islam/47--Backend). Production frontend is on Vercel; it talks to the backend over HTTPS using `API_BASE_URL`.

## What this app does

After signup (or the shared demo login), the onboarding wizard collects age, body measures, lifestyle answers, and diagnosed high blood pressure / diabetes. Health Age is calculated on the client from those inputs against the project’s Malaysian mortality tables. Insights and habit recommendations are loaded from the backend when available; if the recommendation API is down, the app falls back to a local ranking engine.

The shell has three main areas: My Health (insights and Health Age), habits for today, and profile / language settings (English, Bahasa Melayu, Simplified Chinese).

## Run locally

```powershell
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

Point `API_BASE_URL` at a running backend. For a production-shaped build on Vercel, `scripts/vercel_install.sh` installs Flutter and `scripts/vercel_build.sh` sets `API_BASE_URL` (defaulting to the live backend if the env var is unset).

## Notes

- Web routing uses `go_router` with a catch-all rewrite in `vercel.json` so deep links hit `index.html`.
- Decorative images under `assets/images/` are used on the sidebar promo card and the My Health backdrop.
- Do not commit secrets. The frontend only needs the public API base URL.
