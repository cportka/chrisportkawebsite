# chrisportka.com

Source for the canonical musician site at **https://chrisportka.com**. Single
long-scroll page, static HTML/CSS, anchored by a moody B&W portrait.

---

## Structure

```
/
├── index.html                  long-scroll home page
├── 404.html
├── robots.txt
├── sitemap.xml
├── _redirects                  Cloudflare Pages / Netlify redirect rules
├── docs/
│   └── dns.md                  Namecheap + EasyDNS setup steps
├── scripts/
│   └── prepare-images.sh       generate hero JPG/WebP/AVIF + OG image
├── releases/
│   ├── the-album-everyone-wants.html
│   └── trash-music.html        redirect target for trashmusic.xyz equity
└── assets/
    ├── style.css               single stylesheet — Fraunces + Inter
    ├── favicon.svg
    ├── portrait-hero.svg       placeholder — real photo goes here
    └── albums/
        ├── taew-cover.svg      placeholder
        └── trash-music-cover.svg  placeholder
```

No build step. Open `index.html` locally, or run any static server:

```
python3 -m http.server 8000
```

---

## Before going live — assets to swap in

All real assets belong under `assets/`. Commit them as you go.

### 1. Hero portrait (the moody B&W photo)

Save the original photo anywhere (Downloads, Desktop — doesn't matter),
then run:

```sh
./scripts/prepare-images.sh ~/Downloads/chris-portrait.jpg
```

The script generates all five derived files:

- `assets/portrait-hero.jpg`   (2000px, ~80–150KB — the universal fallback)
- `assets/portrait-hero.webp`  (same dims — modern browsers prefer this)
- `assets/portrait-hero.avif`  (same dims — most efficient on new browsers)
- `assets/og-portrait.jpg`     (1200×1200 — link-preview image)

Requires ImageMagick (`brew install imagemagick`). WebP + AVIF generation
is optional — the script skips them cleanly if `cwebp`/`avifenc` aren't
installed, but installing them is recommended for a ~40% smaller hero
load (`brew install webp libavif`).

`index.html` already references the real JPG/WebP/AVIF paths via a
`<picture>` element — no HTML edit needed after running the script.

### 2. Album covers

Drop the real cover art at:

- `assets/albums/taew-cover.jpg`  (1200×1200)
- `assets/albums/trash-music-cover.jpg`

Then update the `<img src="...-cover.svg">` references (four total —
two in `index.html`, one in `releases/the-album-everyone-wants.html`,
one in `releases/trash-music.html`) from `.svg` to `.jpg`.

For each additional release:

1. Add the cover at `assets/albums/SLUG-cover.jpg`.
2. Copy `releases/the-album-everyone-wants.html` to
   `releases/SLUG.html` and swap the title, Bandcamp album ID, copy,
   and JSON-LD.
3. Add a `<li class="release-item">` block to the discography list in
   `index.html` (template is commented inside `<ol class="releases">`).
4. Add a `<url>` entry to `sitemap.xml`.

### 3. Apple touch icon

A 180×180 PNG derived from the portrait or the monogram at
`assets/apple-touch-icon.png`.

### 4. Bandcamp embed

The embed for *The Album Everyone Wants* is already wired
(`album=3141064362`, bgcol=`f5f2ec`, linkcol=`6b4a2b`).

For additional releases, go to the Bandcamp admin for each album →
**Tools → Embed this album**, and copy the embed code. Use the site
colors: `bgcol=f5f2ec&linkcol=6b4a2b`. Paste into the appropriate
release page.

### 5. Mailing list

Sign up at https://buttondown.email (free up to 100 subscribers).
Settings → Embeds → Form. The endpoint will be
`https://buttondown.email/api/emails/embed-subscribe/YOURUSERNAME`.
Replace `chrisportka` in the subscribe form's `action` attribute in
`index.html` if your Buttondown username differs.

---

## Discography completion

`index.html` currently lists *The Album Everyone Wants* (2025) and
*Trash Music*. The remaining seven Bandcamp releases need to be pasted in.
The template is commented inside `<ol class="releases">` — copy it for
each release in reverse chronological order.

---

## Deployment

### Cloudflare Pages (recommended)

1. Push this repo to GitHub (already set up at `cportka/chrisportkawebsite`).
2. Cloudflare dashboard → Pages → Create a project → Connect to Git.
3. Select this repo. Build command: empty. Build output directory: `/`.
4. Deploy. You get a `*.pages.dev` URL immediately.
5. Pages → Custom domains → add `chrisportka.com` and `www.chrisportka.com`.
6. Cloudflare will tell you the DNS records to create at your registrar
   (or auto-configures if the domain is already on Cloudflare).
7. The `_redirects` file works out of the box.

### Netlify / Vercel

Both work identically for this kind of site. Netlify reads `_redirects`
as-is. Vercel needs a `vercel.json` — ask and I'll add one.

### DNS, email forwarding, and 301 redirects

See **[docs/dns.md](docs/dns.md)** — it has concrete Namecheap and EasyDNS
steps for:

- Pointing `chrisportka.com` + `www` at your host
- Setting up `hello@chrisportka.com` → Gmail forwarding
- 301 redirects from each deprecated domain (`cportka.com`,
  `cportka.io`, `cportka.xyz`, `trashmusic.xyz`, `djpants.xyz`,
  `portka.io`, `lofibluesky.io`)
- A curl snippet to verify every redirect resolves correctly

---

## On this repo being public

A few things worth knowing since `cportka/chrisportkawebsite` is public:

- **Anything committed is forever.** GitHub preserves history across
  force-pushes via the reflog and cached forks. If a secret ever lands
  in a commit, treat it as compromised — rotate it, don't just delete it.
- **Never commit:** registrar logins, Cloudflare API tokens, Buttondown
  API keys, analytics private tokens, `.env` files, or anything that
  identifies your email beyond `hello@chrisportka.com` (which is public
  by design). `.gitignore` already blocks `.env*`.
- **Git commit metadata is public.** Every commit shows your Git
  `user.email`. If that's your personal Gmail, it will be scrapable from
  the API. If you'd rather keep that private, set the repo to use
  GitHub's noreply email: Settings → Emails → "Keep my email addresses
  private" → then set `git config user.email "NNNNNN+cportka@users.noreply.github.com"`.
- **Unreleased audio:** never commit masters, stems, or pre-release
  mixes here. Streaming embeds are fine — those are already public.
- **Analytics IDs are fine to commit.** Cloudflare Web Analytics tokens
  and Plausible site domains are embed-level IDs, not secrets.
- **Buttondown embed URL is fine to commit.** It's the same URL shown
  on your public subscribe page.
- **The B&W portrait being in the repo is the point** — it's the hero
  of the live site, so its public availability is expected.

Should this be public vs. private? Public is fine and has upside:

- Lets you link to the repo from your site if you ever want to ("source")
- Helps anyone who wants to deploy a clone of the design
- Makes CI / deploy integrations simpler (no auth for clone)

The only case for private is if you'd rather keep draft content (bio
edits, unreleased album titles staged in commits) out of public view. If
that matters, move drafts to a separate private repo and only push the
ready-to-ship version here. For a brochure site, public is the normal
and lower-friction choice.

---

## Design decisions (for future reference)

These are the constraints the site is built around. Changing any of them
is fine but think twice first.

- **One photo, one voice.** The B&W portrait is the only image above the
  fold. The album cover (color) is the second visual voice. Anything else
  added to the hero dilutes the gravity of the photograph.
- **One accent color.** A muted sepia-brown (`#6b4a2b`). Don't add a
  second accent — the B&W portrait provides all the contrast the page
  needs.
- **Serif headings, sans body.** Fraunces for anything typographic;
  Inter for functional UI text (streaming links, buttons, footer). The
  Fraunces `opsz` axis handles display sizes automatically.
- **No motion.** No scroll animations, no parallax, no fades beyond the
  browser default. `prefers-reduced-motion` is respected but has nothing
  to disable.
- **No analytics by default.** Cloudflare Web Analytics can be added
  with a single `<script>` tag in `index.html` — free, privacy-preserving,
  no cookie banner required. Do not add Google Analytics or Facebook Pixel.
- **No popups.** The mailing-list form is inline and understated on
  purpose.

---

## Housekeeping

- Old site repo: https://github.com/cportka/website (cportka.xyz content
  — archive after this site is live).
- Deprecated domains to route: `cportka.com`, `cportka.io`, `cportka.xyz`,
  `trashmusic.xyz`, `djpants.xyz`, `portka.io`.
- Canonical email: `hello@chrisportka.com` (forwarded to Gmail).
- Canonical handle: `@chrisportka` everywhere it's available.

License: all rights reserved. The site template here is not intended for
reuse by other artists without permission — the site is the identity.
