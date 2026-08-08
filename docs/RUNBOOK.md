# Runbook

Every command you need, in one place. All paths assume the repo root
`D:\S2-2026\W1-W3`.

## Prerequisites

- Flutter SDK (stable channel), Dart SDK `^3.12.2`
- Chrome, for `flutter run -d chrome`
- Supabase project `loqwoiizinnshwrgaunj` — already provisioned
- **No** Docker, MongoDB, or Node.js. There is no application server.

## Run the web app

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter pub get
flutter run -d chrome
```

Hot restart with `R`, quit with `q`. Use **demo login** on the landing page
to skip straight to a fully populated profile.

To check the release bundle as a real static site:

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter build web --release
cd build\web
python -m http.server 8081 --bind 127.0.0.1
```

Then open <http://127.0.0.1:8081/>.

## Run on Android (secondary)

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter devices
flutter run -d <device-id>
```

## Quality gates

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter analyze          # must print "No issues found!"
flutter test             # must be all green
dart format .            # uses page_width: 110 from analysis_options.yaml
flutter test --coverage  # writes coverage/lcov.info
```

Run `dart format` **before** `flutter analyze`, not after: reflowing a long
single-line `if` onto two lines introduces a
`curly_braces_in_flow_control_structures` finding that only the analyzer
reports.

## Deploy

See [HOSTING.md](HOSTING.md) for the full walkthrough.

```powershell
cd D:\S2-2026\W1-W3\frontend
flutter build web --release
cd ..
firebase deploy --only hosting
```

## Supabase

- Dashboard: <https://supabase.com/dashboard/project/loqwoiizinnshwrgaunj>
- Client config: `lib/core/config/supabase_config.dart`
- Schema and RLS reference: [DATABASE.md](DATABASE.md)

After any schema change, re-check the security advisors in the dashboard and
update [DATABASE.md](DATABASE.md).

## Troubleshooting

**"The process cannot access the file because it is being used by another
process"** when renaming or deleting a project directory. A Dart analysis
server, or a terminal whose working directory is inside it, holds a handle on
it. Close terminals in that folder, then:

```powershell
Get-Process dart, dartvm -ErrorAction SilentlyContinue | Stop-Process -Force
```

The IDE restarts the analysis server automatically.

**Stale build after a rename or dependency change.** Delete the generated
directories and reinstall:

```powershell
cd D:\S2-2026\W1-W3\frontend
Remove-Item -Recurse -Force .dart_tool, build -ErrorAction SilentlyContinue
flutter pub get
```

**Web changes not appearing.** `flutter build web` output filenames are not
content-hashed, so a browser can serve a cached `main.dart.js`. Hard-reload
(Ctrl+Shift+R) or check the cache headers described in [WEB.md](WEB.md).

**`flutter test` fails only on responsive assertions.** The default test
window is 800×600. Use `tester.binding.setSurfaceSize` — see
[TESTING.md](TESTING.md).

## When you change something

1. Change the code.
2. Update the affected doc in `docs/`.
3. Append a dated entry to [CHANGELOG.md](CHANGELOG.md).
4. Run `flutter analyze` and `flutter test`.
5. Commit, so that diff-based reviews can actually compute a diff.
