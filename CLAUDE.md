# Handoff notes for the next Claude

Static site for **Chris Portka** at <https://chrisportka.com>. Hosted on GitHub Pages from `main`. No build step.

## Layout

```
index.html              homepage (hero, current release, bio, press, recent releases, mailing list)
earlier-work.html       /earlier-work — pre-TAEW catalog (singles + albums)
proto-play.html         /proto-play — pre-Chris-Portka projects (Rhiao, Beardwail, YEAIR)
press.html              /press — full quote bank + reviews list
releases/the-album-everyone-wants.html   deep page with full Bandcamp tracklist embed
releases/trash-music.html                 deep page
404.html
assets/style.css        single stylesheet — read this first before adding CSS
assets/favicon.svg + favicon-48.png + icon-192.png + icon-512.png + apple-touch-icon.png
assets/portrait-hero.jpg + assets/og-image.jpg (1200×630)
assets/albums/*.jpg     album cover thumbnails
scripts/                helper bash scripts
docs/                   dns + assets notes
sitemap.xml, robots.txt, llms.txt, site.webmanifest, CNAME
```

## Design system (don't drift)

- **Palette** (CSS vars in `:root`): bg `#100c17`, ink `#ebe5ee`, accent `#b59dd1` (lavender), rule `#2c2438`. Dark, smokey, lavender. One accent.
- **Fonts**: Cormorant Garamond italic for headings/quotes, Inter for body.
- **Patterns**:
  - `.release-item` is the discography row primitive. Modifiers: `--featured` (large cover), `--video` (16:9 embed slot), `--contact` (no thumbnail, single column — only inside `.earlier-list`).
  - `.section-heading` = italic serif h2 with a 2.5rem accent rule below.
  - `.button-primary` = solid lavender CTA (Buy the vinyl, Subscribe).
- **Avoid new CSS classes when an existing one fits.** When you need one, add it scoped (e.g. `.release-item--video`) rather than a generic name.

## Two real gotchas

1. **The git push proxy at `127.0.0.1` periodically 403s** — `git push` fails but the commit itself is fine locally. Fallback: push via `mcp__github__push_files` (one commit, two files at a time is plenty), then `git fetch origin && git reset --hard origin/main` to resync local to whatever SHA the API returned.
2. **Sandbox can't reach most external hosts** — `f4.bcbits.com`, `i1.sndcdn.com`, `docs.google.com`, `soundcloud.com`, `chrisportka.com` all return `403 host_not_allowed` from `curl`/`WebFetch`. When the user references a SoundCloud/Bandcamp asset, ask them to paste the URL; don't try to fetch it.

## Helper scripts

- `scripts/wire-google-form.sh <viewform URL or entry.NNNN>` — patches the subscribe form's Form ID + email field entry. Already wired; rerun if Chris changes forms.
- `scripts/prepare-images.sh <path-to-portrait.jpg>` — regenerates `portrait-hero.{jpg,webp,avif}` and `og-image.jpg` (1200×630). Requires ImageMagick + `cwebp` + `avifenc` (`brew install imagemagick webp libavif`).

## Validation before pushing

After any HTML edit, validate tag balance and JSON-LD:

```sh
python3 -c "
import html.parser, json, re
class V(html.parser.HTMLParser):
    VOID={'img','br','hr','meta','link','input','source','area','base','col','embed','param','track','wbr'}
    def __init__(self): super().__init__(); self.errs=[]; self.stack=[]
    def handle_starttag(self,t,a):
        if t not in self.VOID: self.stack.append(t)
    def handle_endtag(self,t):
        if self.stack and self.stack[-1]==t: self.stack.pop()
        else: self.errs.append(t)
import sys
for f in sys.argv[1:]:
    p=V(); p.feed(open(f).read())
    print(('ok ' if not p.stack and not p.errs else 'FAIL ')+f)
" *.html releases/*.html
```

## Working with Chris

- Be brief. He values wit and concision; he'll often write copy himself in a quirky voice (e.g. *"Brothers (Chinese) Recording"*, *"hey, how's everybody doing tonight?"*, *"competes us instead of cooperates us"*) — preserve it verbatim.
- He provides screenshots when something looks wrong. Read carefully — the bug is usually layout-grid related (e.g. a meta div landing in the wrong grid column because a class was scoped to `.earlier-list` but used elsewhere).
- Default tone in commit messages: descriptive paragraph, no emoji, focus on the *why*. He pushes from his Mac as `Chris Portka <chrisportka@gmail.com>`; this Claude pushes as `Claude <noreply@anthropic.com>` — that's fine.
- Don't open GitHub PRs proactively. He works on `main`.

## Recent context

The site has been through a lot of iteration — the homepage hero is currently just the portrait + name + a single linked Obscure Sound quote. Recent releases section is TAEW (featured) → KXSF live video → Trash Music. Mailing list posts to a Google Form (entry ID `entry.2065888469` on form `1FAIpQLSekASuiQlaQbViFl5JQ0wZsY4YdR8EMfCF3rnSwQurMrU7T4Q`). Read the latest few commits with `git log --oneline -20` for the real story.

Good luck.
