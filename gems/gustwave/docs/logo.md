# Logo

The Gustwave logo is **Kites**: an equilateral triangle cut into three kite-shaped pieces that meet at its center. A library built from parts, shown as a mark built from parts. On hover, in the site header and the docs, the amber piece lifts out of its slot.

The files live in `app/assets/images/gustwave/logo/` and resolve as `gustwave/logo/<file>` in the asset pipeline.

## Files

| File | Use |
|---|---|
| `gustwave-mark.svg` | The mark in color. Works on light and dark backgrounds. |
| `gustwave-mark-ink.svg`, `gustwave-mark-white.svg` | One-color mark for single-color print, embossing or busy backgrounds. |
| `gustwave-lockup.svg` | Mark and wordmark on light backgrounds. The default logo. |
| `gustwave-lockup-on-dark.svg` | Mark and wordmark on dark backgrounds. |
| `gustwave-lockup-ink.svg`, `gustwave-lockup-white.svg` | One-color lockups. |
| `gustwave-app-icon.svg` | Rounded app tile, 1024 × 1024. |
| `favicon.svg`, `favicon.ico` | Browser tab icon. The `.ico` holds 16, 32 and 48 px. |
| `apple-touch-icon.png` | iOS home screen, 180 px. Full-bleed: iOS rounds the corners itself. |
| `icon-192.png`, `icon-512.png` | Web app manifest icons, `"purpose": "any"`. |
| `icon-maskable-512.png` | Web app manifest icon, `"purpose": "maskable"`. The mark sits inside the safe zone. |

The wordmark is set in [Bricolage Grotesque](https://github.com/ateliertriay/bricolage) Bold, licensed under the [SIL Open Font License](https://openfontlicense.org), and converted to outlines, so the lockups don't need the font installed.

## Colors

| Name | Hex | Where |
|---|---|---|
| Blue | `#2D5BFF` | Top kite |
| Teal | `#13B3A2` | Bottom-right kite |
| Amber | `#FFB020` | Bottom-left kite, the one that lifts |
| Ink | `#101936` | Wordmark on light backgrounds, one-color mark |
| Navy | `#0B1230` | App icon background |

## Construction

Start from an equilateral triangle. Draw lines from its center to the midpoint of each side, which cuts it into three kites. Inset each kite so the gaps between them are even, then round the corners. In the 120-unit grid the mockups used, the triangle's circumradius is 50, the gap is 6 and the corner radius is 4.

`favicon.svg` and `favicon.ico` use a small-size cut with a gap of 10 and a corner radius of 3.5, so the gaps stay open at 16 px. Use them only below 24 px.

## Sizing and spacing

- Keep clear space around the mark or lockup equal to half the mark's height.
- Don't use the mark smaller than 16 px. Below 24 px, use the favicon cut.
- Don't set the lockup shorter than 20 px.
- Don't recolor the kites, change their order, rotate the mark or set the wordmark in another font.

## The hover

The hover only plays where there is a pointer: the site header and the docs. The favicon, app icons, print and social images are always static.

| Moment | Behavior |
|---|---|
| Rest | The mark as drawn. |
| Hover or focus | The amber kite moves 11 × 7 units down and left in the 120-unit grid and turns −6°. A dashed outline of its slot and a soft shadow fade in. 220 ms, ease-out. |
| Release | The kite drops back in over 360 ms with a slight overshoot, `cubic-bezier(.34, 1.56, .64, 1)`. |
| Touch | There is no hover. Play it once on first load, or on tap. |
| Reduced motion | The kite jumps between states without animating. |

In the SVGs each kite is a `path` with the classes `gw-kite` and `gw-kite-blue`, `gw-kite-teal` or `gw-kite-amber`, so inline markup can target the amber piece directly.
