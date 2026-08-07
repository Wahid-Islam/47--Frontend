# Responsive design

The single most common way a phone-shaped Flutter app looks broken in a
browser is that a full-width column stretches across a 1600px monitor:
1500px-wide buttons, and body text at 200 characters per line. Everything
below exists to prevent that.

## Breakpoints

`app/lib/core/responsive/breakpoints.dart`:

| Name | Width | Meaning |
|---|---|---|
| mobile | `< 600` | Phone. Bottom navigation bar. |
| tablet | `600 – 1023` | Branded sidebar, content fills the remaining width. |
| desktop | `>= 1024` | Branded sidebar, content capped and centred. |
| `contentMaxWidth` | `1080` | Widest the main content column ever gets. |

`Breakpoints.of(width)` returns a `DeviceType`, and `ResponsiveBuilder`
picks one of three builders, falling back to the next smaller one when a
builder isn't supplied.

Always read width from a `LayoutBuilder`'s constraints rather than
`MediaQuery.sizeOf(context)`. Inside the shell, the content area is
narrower than the window because the sidebar takes 232px, and a browser
window can be resized to any width at any moment.

## The two layout primitives

### `ResponsiveShell` — authenticated screens

`app/lib/core/widgets/responsive_shell.dart` wraps the `go_router`
`StatefulShellRoute.indexedStack` so each tab keeps its own navigation
stack and scroll position.

- Below 600px: a `NavigationBar` at the bottom, 72px tall.
- At 600px and above: `BrandedSidebar` on the left — the mysihat wordmark
  and logo mark above an extended `NavigationRail` that shows icon *and*
  label for every destination at all times. This is the "Variation 1"
  design.

On wide windows the content next to the sidebar is wrapped in
`Align(alignment: topCenter)` + `ConstrainedBox(maxWidth: contentMaxWidth)`
so it is **centred**, not pinned against the sidebar with dead space on the
right.

`BrandedSidebar` is public rather than private specifically so it can be
widget-tested without constructing a real `StatefulNavigationShell`.

### `CenteredPane` — everything outside the shell

`app/lib/core/widgets/centered_pane.dart` caps and centres a single column.
Every top-level route that is *not* inside `ResponsiveShell` — onboarding,
login, register, the questionnaire — wraps its body in it.

| Constant | Width | Used for |
|---|---|---|
| `CenteredPane.formWidth` | `460` | Forms and single call-to-action columns |
| `CenteredPane.wideWidth` | `960` | Two-column panes, charts |

Place it *outside* a `SingleChildScrollView`, not inside: the scroll view
then still fills the viewport height and only its content is narrowed.

## The landing page gets a real desktop layout

`OnboardingScreen` is the first thing a visitor sees, so it branches on
`Breakpoints.desktop`:

- `>= 1024`: `_DesktopHero` — a two-column row, the pitch on the left at
  56px display type, the sign-up/login/demo actions in a `Card` on the
  right, inside a 960px pane.
- `< 1024`: `_StackedHero` — pitch above actions in a 460px pane.

Both share `_Pitch` and `_Actions`, so the copy and the button behaviour
cannot drift apart between the two layouts.

## Rules for new screens

1. Wrap the body in `CenteredPane` unless the screen lives inside
   `ResponsiveShell`.
2. Branch on `LayoutBuilder` constraints, never on a hardcoded pixel guess.
3. Anything scrollable must actually be scrollable at 320px wide and at
   400px tall — a browser window can be short as well as narrow.
4. Extract shared subtrees (like `_Pitch`) instead of duplicating a widget
   tree per breakpoint.
5. Use `BlocBuilder`/`BlocSelector` with `buildWhen`/`selector` so a state
   change repaints one card, not the whole page.

## Tests

`app/test/core/widgets/centered_pane_test.dart` resizes the test window
with `setSurfaceSize` and asserts the child is capped at 460px on a 1600px
window, horizontally centred, allowed to fill a 320px window, and able to
honour a wider explicit `maxWidth`.

`app/test/core/widgets/responsive_shell_test.dart` covers `BrandedSidebar`
rendering every destination label and reporting the tapped index.

Note for future tests: the default test window is 800×600, so a
`SizedBox(width: 1600)` is silently clamped. Use
`tester.binding.setSurfaceSize` and reset it in `addTearDown`.
