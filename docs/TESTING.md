# Testing

```powershell
cd app
flutter test                # everything
flutter test test/core      # one directory
flutter test test/core/widgets/centered_pane_test.dart
```

## Layout

`test/` mirrors `lib/` one directory for one directory, so the test for a
file is always at the same relative path with a `_test` suffix.

| Test | Covers |
|---|---|
| `test/controller/services/risk_engine_test.dart` | Health Age maths, risk ordering, US 1.3 comparison fields, JSON round-trip, legacy-payload defaults |
| `test/controller/cubits/locale_cubit_test.dart` | EN/BM switching and `shared_preferences` persistence |
| `test/core/widgets/centered_pane_test.dart` | Content width capping and centring |
| `test/core/widgets/responsive_shell_test.dart` | `BrandedSidebar` labels and tap handling |
| `test/view/widgets/buttons_and_chips_test.dart` | Shared button and choice-chip components |
| `test/view/widgets/health_age_widgets_test.dart` | Health Age gauge and projection chart render without overflow |

## Assertions: `package:checks`

The project uses `package:checks`, not `package:matcher`. Write
`check(actual).equals(expected)` rather than `expect(actual, expected)`.

```dart
check(size.width).equals(CenteredPane.formWidth);
check(insights.healthAge).isGreaterThan(profile.age);
check(tester.takeException()).isNull();
```

`checks` gives better failure output and refuses silently-wrong comparisons
between unrelated types at compile time.

## Widget test conventions

**Resize the window explicitly when testing responsive behaviour.** The
default test window is 800×600, so a `SizedBox(width: 1600)` is silently
clamped to 800 and a desktop-layout assertion will fail for the wrong
reason.

```dart
await tester.binding.setSurfaceSize(const Size(1600, 700));
addTearDown(() => tester.binding.setSurfaceSize(null));
```

**Watch out for widgets that don't expand.** `ColoredBox` with no child
lays out at `constraints.smallest`, i.e. zero. Use `SizedBox.expand` when
you want to measure the space a parent handed down.

**Test presentational widgets in isolation.** `BrandedSidebar` is public
precisely so a test doesn't have to build a real `go_router`
`StatefulNavigationShell`. Prefer extracting a widget over writing a test
that needs the whole app.

**Assert no exception was swallowed.** `check(tester.takeException()).isNull()`
catches overflow and assertion errors that would otherwise only show as a
red screen.

## Cubit tests

`bloc_test` plus `package:checks`:

```dart
blocTest<LocaleCubit, String>(
  'setLocale("bm") emits "bm"',
  build: LocaleCubit.new,
  act: (cubit) => cubit.setLocale('bm'),
  expect: () => ['bm'],
);
```

Cubits are intentionally independent of each other, which is what makes
them testable without mocking a graph of dependencies. Cross-cubit
orchestration lives in screen submit handlers — see
[ARCHITECTURE.md](ARCHITECTURE.md).

## Coverage

```powershell
cd app
flutter test --coverage
```

Writes `coverage/lcov.info`. To read it as HTML you need `lcov`'s `genhtml`,
which is not available on Windows by default; the practical options are
running it under WSL or using an editor extension that renders `lcov.info`
inline.

`coverage/` is gitignored.

## Static analysis and formatting

```powershell
cd app
flutter analyze     # must report "No issues found!"
dart format .       # honours page_width: 110 from analysis_options.yaml
```

The formatter width is pinned in `analysis_options.yaml`. Without that pin a
bare `dart format` reflows the entire codebase to the 80-column default.

Note that formatting can *create* lint findings — reflowing a long
single-line `if` onto two lines triggers
`curly_braces_in_flow_control_structures`. Run `flutter analyze` after
formatting, not before.

## What is not tested yet

See [ROADMAP.md](ROADMAP.md). The main gaps are repository classes (they
need a mocked Supabase client) and full end-to-end screen flows.
