# chrisportka.com

The source of a website for a songwriter who owns too many domains.

Built from one photograph, two fonts, and a promise to stop buying
anything that ends in `.xyz`.

No framework. No CMS. No build step. If something breaks, it is
almost certainly in `index.html`.

- **[docs/assets.md](docs/assets.md)** — the photo, the covers, the
  Bandcamp embeds. One script does most of it.
- **[docs/deploy.md](docs/deploy.md)** — Cloudflare Pages, repo
  visibility, the rules the design is trying not to break.
- **[docs/dns.md](docs/dns.md)** — 301-redirect every domain that was
  once named `cportka`, `djpants`, or `trashmusic` to somewhere that
  was not.
- **`releases/`** — one HTML file per album. The template expands.

Run it locally:

```sh
python3 -m http.server 8000
```

Buy the vinyl: <https://cportka.bandcamp.com/album/the-album-everyone-wants>.

All rights reserved on the songs, the portrait, and the name.
Everything else is just HTML, and that never really belonged to anyone.
