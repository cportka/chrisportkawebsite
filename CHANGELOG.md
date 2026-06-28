# Changelog

All notable changes to this project are documented here. The format follows Keep a Changelog
(https://keepachangelog.com) and the project uses Semantic Versioning (https://semver.org).
Every change bumps the version and adds an entry below.

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
