# Deploy

No build step. Any static host works. Cloudflare Pages is the path of
least resistance — free, fast, redirects via `_redirects`, automatic
HTTPS.

## Cloudflare Pages

1. Cloudflare dashboard → **Pages** → **Create a project** → Connect to
   Git.
2. Select `cportka/chrisportkawebsite`. Production branch: `main`.
   Build command: empty. Build output directory: `/`.
3. Deploy. You get a `<something>.pages.dev` URL immediately.
4. Pages → **Custom domains** → add `chrisportka.com` and
   `www.chrisportka.com`. Cloudflare tells you which DNS records to
   create at the registrar.
5. The `_redirects` file works out of the box.

## Netlify

Same story. `_redirects` is Netlify's native syntax — works as-is.
Production branch: `main`. Build command: empty. Publish directory: `.`.

## Vercel

Needs a `vercel.json` for the redirect rules. Ask and it gets added.

## DNS, email, and 301s

All the registrar-level work (Namecheap and EasyDNS specific) lives in
**[dns.md](dns.md)** — pointing the domain at your host, email
forwarding for `hello@chrisportka.com`, and 301s from every
deprecated domain.

---

## Repo visibility

The repo is public. That's fine and has upside (no auth for CI, can
be linked as "source", easy for anyone who wants to clone the design).
A few things worth knowing:

- **Anything ever committed is forever** — GitHub preserves history
  across force-pushes via the reflog and cached forks. If a secret
  lands in a commit, rotate it, don't just delete it.
- **Never commit:** registrar logins, Cloudflare API tokens, Buttondown
  API keys, `.env` files. `.gitignore` already blocks `.env*`.
- **Commit metadata is public** — every commit shows your git
  `user.email`. If that's your personal Gmail and you'd rather keep it
  private, use GitHub's noreply address:
  ```sh
  git config user.email "NNNNNN+cportka@users.noreply.github.com"
  ```
  (get the exact address from GitHub → Settings → Emails).
- **Never commit** unreleased audio (masters, stems, pre-release
  mixes). Streaming embeds are fine — those are already public.
- **Safe to commit:** analytics site IDs (Cloudflare Web Analytics,
  Plausible), the Buttondown embed URL, streaming links,
  `hello@chrisportka.com`.

The only argument for going private is if you want to stage unreleased
album titles in commits out of public view. If that matters, draft in
a gist and only push ready-to-ship here.

---

## Design ground rules

The site was built around specific constraints. Breaking them is fine —
just do it deliberately.

- **One photograph, one voice.** The B&W portrait is the only image
  above the fold. Album covers (color) are the second visual voice.
- **One accent color.** Sepia-brown `#6b4a2b`. No second accent.
- **Serif headings, sans body.** Fraunces for typography, Inter for
  functional UI (streaming links, buttons, footer).
- **No motion.** No parallax, no scroll animations, no fades. Respects
  `prefers-reduced-motion` (trivially — nothing to disable).
- **No popups.** Mailing-list form is inline and quiet.
- **No Google Analytics or Facebook Pixel.** Cloudflare Web Analytics
  is free, privacy-preserving, and needs no cookie banner — add it
  with a single `<script>` tag if you want page-view numbers.
