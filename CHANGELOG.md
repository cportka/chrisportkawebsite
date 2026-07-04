# Changelog

All notable changes to this project are documented here. The format follows Keep a Changelog
(https://keepachangelog.com) and the project uses Semantic Versioning (https://semver.org).
Every change bumps the version and adds an entry below.

## [1.0.7] - 2026-07-04

### Fixed
- Vertical seam to the right of the desktop hero. The portrait faded to `--bg`, but the text column
  showed the body's lavender radial glow (slightly lighter), so the columns met on a visible line.
  Gave `.hero` a solid `var(--bg)` background so both columns match and the photo fades to black
  into the column beside it. Confirmed against a cache-free render at a tall desktop window.

## [1.0.6] - 2026-07-04

### Changed
- Strengthened the desktop hero vignette: the right edge (meeting the name column) and the bottom
  edge now pull a long fade to black inward toward the subject, instead of the subtle single-side
  fade that was hard to see. Left and top keep a gentle vignette. Verified at tall-window and
  wide-laptop desktop sizes.

## [1.0.5] - 2026-07-04

### Changed
- Vignette the hero portrait into black on all four edges instead of only one. The photo used to
  fade on a single side (bottom on mobile, right on desktop) and hard-cut on the rest — most
  visibly a hard vertical seam where the desktop photo met the name column. Rebuilt `.portrait::after`
  as a two-gradient edge fade (tuned per layout) so the photo dissolves to background on every side.

## [1.0.4] - 2026-06-28

### Fixed
- Red band at the hero image / name section seam on iOS Safari. It was the smoke layer's
  `mix-blend-mode: screen` combining with its CSS `mask` — a known iOS compositing bug that renders
  a colored band at the mask edge. Dropped the blend (the light wisps read the same over the dark
  photo with plain alpha, opacity nudged up to match) and isolated the layer, so the portrait now
  fades cleanly into the section below on both mobile and desktop.

## [1.0.3] - 2026-06-28

### Removed
- The homepage "Frequently asked" section, plus its matching `FAQPage` JSON-LD and `.faq-list`
  CSS. Removed the structured data alongside the visible section so nothing is left dangling.

## [1.0.2] - 2026-06-28

### Changed
- Reworked the hero smoke to actually look like smoke and stop overpowering the portrait. Swapped
  the lavender gradient blobs (which only ever read as a glow) for SVG `feTurbulence` fractal-noise
  wisps, stretched vertically so they read as rising plumes, drifting upward via a seamless tiled
  `background-position` loop. Dropped the intensity, and masked the layer with a radial fade so the
  smoke dissipates before any edge — fixing the hard rectangular edge at the bottom of the hero.
  Still CSS/SVG-only and `prefers-reduced-motion` safe.

## [1.0.1] - 2026-06-28

### Fixed
- Hero smoke was effectively invisible (low-alpha lavender under a `screen` blend over a dark
  photo netted almost no lightening). Rebuilt it as two brighter, larger, heavily-blurred plumes
  that rise and morph, so the wafting actually reads. Still CSS-only and `prefers-reduced-motion`
  safe.

## [1.0.0] - 2026-06-28

### Added
- SEO/AEO: `Review` structured data on both album nodes, a `FAQPage` (JSON-LD + a visible
  "Frequently asked" section), sitemap `lastmod` dates, and a reviews/live section in `llms.txt`.
- Hero motion: a soft smoke drift over the portrait and a neon flicker + glow on the California
  outline, both CSS-only and gated behind `prefers-reduced-motion`.
- Tooling: incorporated the `portka-tools` marketplace and enabled the `app-website-evaluator`
  plugin via `.claude/settings.json`.
- Process: the Portka standard via repo-bootstrap — a branch-per-change workflow `CLAUDE.md`, a
  git/`gh` permissions allowlist, an enforced SemVer version sync, a basic test suite, and CI.
