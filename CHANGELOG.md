# Changelog

All notable changes to this project are documented here. The format follows Keep a Changelog
(https://keepachangelog.com) and the project uses Semantic Versioning (https://semver.org).
Every change bumps the version and adds an entry below.

## [1.4.1] - 2026-07-16

### Changed
- Swapped the sticker tagline's font from Inter 800 to **Dancing Script 700** — a flowing cursive
  that keeps the black-core / white-band / black-rim outline treatment but reads pretty instead of
  blocky. Chosen from a seven-font rendered comparison (Pacifico, Kaushan, Yellowtail, Satisfy,
  Courgette, Great Vibes) as the heaviest of the genuinely cursive options, so the counters
  survive the stroke bands. Inter 800 dropped from the font payload.

## [1.4.0] - 2026-07-16

### Added
- "Earlier work" is now a dying neon sign — a dim, struggling-to-stay-alive flicker with brief
  catches that fail, a hard sputter, and sparks that fly off it. Legibility floor kept.
- Hovering a Recent release now sparks its bottom rule to life as a neon tube — a stuttering
  ignition, then a fast vibrating buzz for as long as the hover (or keyboard focus) lasts.

### Changed
- "Musician, Songwriter, Guy" restyled as a die-cut sticker: black core / white band / black rim
  (three stacked SVG text strokes, heavy Inter 800).
- Sparks everywhere are now thin, angular streaks — like real electrical sparks — instead of round
  drops, and there are more of them: California throws five jagged shards per flare, "out now"
  fans out seven needles across its two buzzes.

### Fixed
- (from pre-merge review) The row-hover neon respects `prefers-reduced-motion` (the guard was being
  out-cascaded), the hover trigger is gated to hover-capable devices so a tap on iOS can't leave
  the vibrate running forever, the `:focus-visible` trigger is split into its own rule (old Safari
  drops comma-joined lists containing it), and the dying sign's dim floor was raised to keep the
  link's contrast above WCAG 4.5:1 in every held state.

## [1.3.0] - 2026-07-08

### Added
- Quote roulette: each page load, one of the four quotes (the hero's Obscure Sound line + the three
  Press quotes) is drawn at random for the hero; the other three hold the Press section — always
  1 up top, 3 below. Tiny inline script, no dependencies; without JS the default arrangement stands.

### Changed
- Drastically brightened the neon words. "Chris Portka" and "out now" get a hot near-white core in
  a much bigger lavender halo, deeper multi-step buzz clusters, and an overshoot flare as the tube
  catches again ("out now" flares right as its sparks fly). The California outline's resting glow
  got a modest matching bump so it doesn't read flat next to the brighter name.

## [1.2.2] - 2026-07-06

### Changed
- Lore wisps + a homepage layout tweak:
  - The lore silhouettes now **drift in and out on the wind** continuously and are **much more
    transparent** (~10% peak) so they read as whisps. Relocated into the discography section.
  - The **chicken** stays (a favorite) but is nudged **up to overlap the final outro line** — it's
    absolutely positioned, so the text never moves.
  - On desktop, **About and Press now share a row** — About on the left, Press staggered a little
    lower on the right, a touch more compact — with Recent releases continuing below. Stacks as
    before on mobile.
  - Added `overflow-x: hidden` so the drifting wisps can't cause sideways scroll.

## [1.2.1] - 2026-07-06

### Changed
- Tuned the Lynch/lore touches:
  - **Red Room wink** recolored from crimson to purple/black (on-palette), with more of the B&W
    test pattern showing (added horizontal broadcast strips) and a broken-broadcast flicker.
  - **Roadhouse hum** made stronger and more present — a breathing edge vignette with a couple of
    electrical buzz-flickers, instead of the near-invisible flat dim.
  - **Lore silhouettes** moved out of the hero and sprinkled into the section gutters (press,
    discography, outro) as faint ~20% off-to-the-side hints; hidden on narrow screens.
  - **"out now" sparks** made bigger and more numerous (a fuller burst).
  - **Hero smoke** dialed down further (opacity 0.30/0.22 → 0.20/0.14).

## [1.2.0] - 2026-07-06

### Added
- Lynch / lore touches on the homepage, all lavender-only (save the one crimson wink) and
  reduced-motion safe:
  - **Red Room wink** — hovering/tapping California briefly reveals a B&W broadcast test pattern
    behind a wind-blown crimson curtain, clipped to the state, then it snaps back to lavender. The
    one deliberate break of the one-accent rule, only on interaction.
  - **The Roadhouse hum** — an almost-imperceptible slow dim/brighten breath over the whole page.
  - **Lore in the haze** — faint silhouettes drift up through the hero smoke and dissolve on slow,
    staggered cycles: a knotty branch + leaves, the crescent moon, an owl, a dog howling at the
    moon, a chicken, and stray leaves.
  - **Sign sparks** — the "out now" neon occasionally bursts a few sparks off its corner in time
    with its buzz.

## [1.1.0] - 2026-07-06

### Added
- Neon-noir touches across the homepage, all lavender-only and reduced-motion safe:
  - "Chris Portka" now glows as a lavender neon sign, with a slow, mostly-steady flicker.
  - "out now" beside the album title is a small lit neon sign.
  - The California outline gets a bigger, "struggling-to-ignite" flicker and throws a few sparks
    off its southeast corner on the flares.
  - A whisper of drifting film grain over the whole page (35mm noir texture, kept very faint).
  - The section-heading accent rules read as small lit neon bars with a slow, rare flicker.

### Changed
- Made the hero smoke a touch subtler (less smoke).

## [1.0.8] - 2026-07-05

### Changed
- Social sharing audit + polish (the broken X card the audit chased turned out to be X's own
  stale-cache/re-scrape lag, not our markup — it self-healed on refresh):
  - Re-encoded `assets/og-image.jpg` from progressive to **baseline** JPEG (some scrapers are flaky
    with progressive), and taught `scripts/prepare-images.sh` to keep it baseline (`-interlace none`).
  - Secondary pages (`earlier-work`, `press`, `proto-play`) now share the wide **1200×630**
    `og-image.jpg` instead of the 2000×2000 square `portrait-hero.jpg`, so their previews stop
    getting center-cropped. Added `og:image:width/height` to every page.
  - Album deep pages switched to the `summary` card so their square 800×800 covers show uncropped
    instead of being cropped by a wide card.
  - Added `og:image:alt` + `twitter:image:alt` (accessibility) and `twitter:creator` across all pages.
  - Gave `404.html` a minimal share block so a broken link still previews gracefully.

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
