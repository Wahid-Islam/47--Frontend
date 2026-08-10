# MySihat — Frontend

Flutter web app for personalised Health Age and daily habits.

API: [47--Backend](https://github.com/Wahid-Islam/47--Backend)

## Run

```powershell
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

Production build sets `API_BASE_URL` in `scripts/vercel_build.sh`.
