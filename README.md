# chrisportka.com

Source for the canonical musician site at **https://chrisportka.com**. Single
long-scroll page, static HTML/CSS, anchored by a moody B&W portrait.

---

## Structure

```
/
├── index.html                  primary long-scroll page
├── 404.html
├── robots.txt
├── sitemap.xml
├── _redirects                  Cloudflare Pages / Netlify redirect rules
├── releases/
│   └── trash-music.html        redirect target for trashmusic.xyz equity
└── assets/
    ├── style.css               single stylesheet — Fraunces + Inter
    ├── favicon.svg
    ├── portrait-hero.svg       PLACEHOLDER — replace with real photo
    └── albums/
        ├── taew-cover.svg      PLACEHOLDER
        └── trash-music-cover.svg  PLACEHOLDER
```

No build step. Open `index.html` locally, or run any static server:

```
python3 -m http.server 8000
```

---

## Before going live — assets to swap in

All real assets belong under `assets/`. Commit them as you go.

### 1. Hero portrait (the moody B&W photo)

Export three formats from the master file and drop them at:

- `assets/portrait-hero.jpg`   (2000px wide, ~80-150KB)
- `assets/portrait-hero.webp`  (same dimensions)
- `assets/portrait-hero.avif`  (same dimensions)

Then open `index.html` and replace the single `<img>` in the `.portrait`
figure with the `<picture>` element block (the template is commented
directly above the `<img>`).

### 2. Album covers

Drop the real cover art at:

- `assets/albums/taew-cover.jpg`  (1200×1200)
- `assets/albums/trash-music-cover.jpg`

Then update the two `<img src="...-cover.svg">` references in `index.html`
and the one in `releases/trash-music.html` to `.jpg`.

For each additional release, add a cover at `assets/albums/SLUG-cover.jpg`
and a `<li class="release-item">` block in the discography list
(the template is commented inside `<ol class="releases">`).

### 3. OpenGraph / Twitter card image

Export a 1200×630 version of the portrait (crop to include head + shoulders
with some air at top) and save at `assets/og-portrait.jpg`. This is what
shows up when the site gets shared on Twitter/X, Slack, iMessage, etc.

### 4. Apple touch icon

A 180×180 PNG derived from the portrait or the monogram at
`assets/apple-touch-icon.png`.

### 5. Bandcamp embed

On Bandcamp, go to *The Album Everyone Wants* → Tools → Embed this album.
Pick the "big" format. Set the colors to match:

- Background: `f5f2ec`
- Link color: `6b4a2b`

Copy the generated `<iframe src="...">` URL and replace
`src="about:blank"` on the `.bandcamp-embed` iframe in `index.html`.

### 6. Mailing list

Sign up at https://buttondown.email (free up to 100 subscribers).
Settings → Embeds → Form. The endpoint will be
`https://buttondown.email/api/emails/embed-subscribe/YOURUSERNAME`.
Replace `chrisportka` in the subscribe form's `action` attribute if your
Buttondown username differs.

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

### Email forwarding (`hello@chrisportka.com`)

Do this at the domain registrar — not in this repo. Most registrars offer
free email forwarding. Point `hello@chrisportka.com` at your Gmail.

### 301s from deprecated domains

This is DNS + host config at the deprecated domain's registrar, not code
in this repo. For each deprecated domain (`cportka.com`, `cportka.io`,
`cportka.xyz`, `trashmusic.xyz`, `djpants.xyz`, `portka.io`):

1. At the registrar, set the domain to redirect (301) to the appropriate
   URL on `chrisportka.com` — most registrars have a "forwarding" feature.
2. For `trashmusic.xyz` specifically, redirect to
   `https://chrisportka.com/releases/trash-music` to preserve press-link
   equity from old reviews.
3. All others redirect to `https://chrisportka.com/`.

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
