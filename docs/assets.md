# Assets — the photo, the album art, the OG image

Everything below is a one-time setup you'll redo roughly once per album.

## Hero portrait

Save the original B&W photo somewhere (Downloads is fine), then:

```sh
brew install imagemagick webp libavif   # one-time
./scripts/prepare-images.sh ~/Downloads/chris-portrait.jpg
```

The script writes all four files into `assets/`:

| File | Dim | What it's for |
|------|-----|---------------|
| `portrait-hero.jpg` | 2000×2000 | Universal fallback |
| `portrait-hero.webp` | 2000×2000 | Modern browsers prefer it |
| `portrait-hero.avif` | 2000×2000 | Newest browsers prefer it (smallest) |
| `og-portrait.jpg` | 1200×1200 | Link previews (Twitter, iMessage, Slack, press) |

WebP and AVIF generation is optional — the script skips cleanly if
`cwebp`/`avifenc` aren't installed. Installing them is recommended: the
AVIF is usually ~40% smaller than the JPEG at identical quality.

`index.html` already references the real paths via a `<picture>`
element. No HTML edit needed after running the script.

Commit the generated files:

```sh
git add assets/portrait-hero.* assets/og-portrait.jpg
git commit -m "Add hero portrait assets"
```

## Album covers

Drop the real cover at `assets/albums/SLUG-cover.jpg` (1200×1200).

Then update the `<img src="...-cover.svg">` references from `.svg` to
`.jpg`. They appear in:

- `index.html` — twice (release section + discography list)
- `releases/the-album-everyone-wants.html` — once
- `releases/trash-music.html` — once

## New release — full flow

1. Save the cover at `assets/albums/SLUG-cover.jpg`.
2. Copy `releases/the-album-everyone-wants.html` → `releases/SLUG.html`
   and swap the title, Bandcamp album ID, copy, and JSON-LD.
3. Add a `<li class="release-item">` block to the discography list in
   `index.html` (template is commented inside `<ol class="releases">`).
4. Add a `<url>` entry to `sitemap.xml`.

## Bandcamp embed colors

Every embed should use the site palette. Get the embed code from
Bandcamp → *album admin* → **Tools → Embed this album**, then replace
these two params in the iframe URL:

```
bgcol=f5f2ec    (paper)
linkcol=6b4a2b  (sepia)
```

## Apple touch icon

Optional but nice. A 180×180 PNG derived from the portrait or the
monogram at `assets/apple-touch-icon.png`. The HTML already links to
this path.

## Mailing list (Buttondown)

Sign up at https://buttondown.email. The free tier handles up to 100
subscribers — plenty of runway.

Settings → Embeds → Form. Your endpoint will be
`https://buttondown.email/api/emails/embed-subscribe/YOURUSERNAME`.

If your Buttondown username isn't `chrisportka`, update the
subscribe form's `action` attribute in `index.html`.
