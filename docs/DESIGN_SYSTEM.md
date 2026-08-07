# Design system

**`app/lib/core/theme/app_theme.dart` is the source of truth.** Every token
below is a `static const` in that file, so if the code and this document
disagree, the code wins and this document is out of date.

`design-system/healthpath/MASTER.md` is a generated artefact from an earlier
exploration and still carries the original **cyan** palette
(`#0891B2` / `#ECFEFF` / `#164E63`). That palette was replaced by the
mysihat green during the Epic 1.0 rebrand. Keep the file for its UX
guidelines and spacing scale; ignore its colours.

## Palette — "green/white wellness"

| Token | Hex | Used for |
|---|---|---|
| `primary` | `#1B7A4E` | Buttons, links, selected navigation, brand mark |
| `accent` | `#059669` | Secondary emphasis, selection indicators |
| `background` | `#F7FBF8` | Scaffold background |
| `surface` | `#FFFFFF` | Cards, sidebar, input fills |
| `foreground` | `#14532D` | Body and heading text |
| `textSecondary` | `#4B6357` | Supporting copy, hints, labels |
| `border` | `#D8EFE1` | Card and input outlines, dividers |

### Semantic colours

| Token | Hex | Meaning |
|---|---|---|
| `riskHigh` | `#DC2626` | High risk, validation errors |
| `riskModerate` | `#D97706` | Moderate risk |
| `riskLow` | `#059669` | Low risk |
| `secondaryCompare` | `#7C7C86` | "National average" in comparison bars — deliberately neutral grey so the user's own result is the only green bar |
| `chartFollowPlan` | `#059669` | Projection line: following the plan |
| `chartNoChange` | `#7C3AED` | Projection line: no change |

`AppTheme.riskColor(level)` maps `'high' | 'moderate' | 'medium' | anything
else` onto the risk colours, so risk styling is never hand-rolled at a call
site.

## Typography

Headings use **Lora** (serif, warm), body copy uses **Raleway** (clean
sans-serif), both via `google_fonts`.

| Role | Font | Size | Weight |
|---|---|---|---|
| `headlineMedium` | Lora | 32 | 700 |
| `headlineSmall` | Lora | 26 | 700 |
| `titleLarge` | Raleway | 24 | 700 |
| `titleMedium` | Raleway | 20 | 600 |
| `titleSmall` | Raleway | 18 | 600 |
| `bodyLarge` | Raleway | 17 | 400 |
| `bodyMedium` | Raleway | 16 | 400 |
| `bodySmall` | Raleway | 16 | 400 |
| `labelLarge` | Raleway | 16 | 600 |

The desktop landing hero overrides `headlineMedium` to **56px** — the only
place a size is set outside the theme, because a display size that large
would be wrong everywhere else.

## The accessibility bar

The audience is Malaysians aged 40–60 and older, which sets two hard
minimums enforced through the theme rather than left to each screen:

- **`minTextSize = 16`** — no body text smaller than 16px. Note that
  `bodySmall` is also 16, not the Material default of 12.
- **`minTapSize = 48`** — every button theme sets
  `minimumSize: Size(_, 48)`.

Other deliberate choices:

- Focused inputs get a 2px `primary` border, not just a colour shift, so
  keyboard focus is visible.
- Validation errors are text plus colour, never colour alone.
- Comparison charts pair colour with an explicit label ("You" vs "National
  average") so they survive colour-blindness and greyscale printing.
- The web splash respects `prefers-reduced-motion` by slowing the spinner
  and dropping the fade transition.

## Shape and elevation

| Element | Radius | Elevation |
|---|---|---|
| Buttons | 16 | 0 |
| Inputs | 16 | 0 |
| Cards | 20 | 0, with a 1px `border` outline |

The whole UI is flat and outlined rather than shadowed — shadows read as
noise at this card density, and outlines hold up better on the near-white
`#F7FBF8` background.

## Using the theme

Read from `Theme.of(context).textTheme` and the `AppTheme` constants. Do not
introduce a new hex literal in a screen: add a token to `AppTheme` so it can
be reused and audited. The only hex literals outside `app_theme.dart` are
the three gradient stops on the landing page.
