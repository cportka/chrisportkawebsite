# DNS configuration — chrisportka.com + deprecated domains

You own two registrars (Namecheap and EasyDNS). One domain needs to serve
the live site; the rest need to 301-redirect to it. This doc covers both.

Before starting, know which registrar holds which domain. Check at:

- **Namecheap:** https://ap.www.namecheap.com/domains/list/
- **EasyDNS:** https://cp.easydns.com/ (Domains)

---

## 1. Canonical domain: chrisportka.com

Point `chrisportka.com` and `www.chrisportka.com` at your static host
(Cloudflare Pages, Netlify, or Vercel — pick one).

### If chrisportka.com is on Cloudflare Pages

Cloudflare Pages → your project → **Custom domains** → Add `chrisportka.com`
and `www.chrisportka.com`. Cloudflare will display the exact records
to create at the registrar. Typically:

| Host | Type | Value |
|------|------|-------|
| `@` (apex) | `A` / `AAAA` or `CNAME` (flattened) | whatever Pages tells you |
| `www` | `CNAME` | `<your-project>.pages.dev` |

### Namecheap steps (if chrisportka.com lives at Namecheap)

1. Domain List → **Manage** next to `chrisportka.com`
2. **Advanced DNS** tab → remove the default "Parking Page" URL record and
   the "CNAME www → parkingpage.namecheap.com" record
3. Click **Add New Record** for each record Cloudflare/Netlify/Vercel told
   you to add. TTL = Automatic.
4. Save. DNS changes usually resolve in 5–30 min on Namecheap.

### EasyDNS steps (if chrisportka.com lives at EasyDNS)

1. Dashboard → click the domain → **DNS** tab
2. Delete any "parked" or default A records
3. Add the records your host provided (typically an `ANAME`/`ALIAS` on
   apex + a `CNAME` on `www` — EasyDNS calls apex aliasing `ANAME`)
4. **Save Changes** (the button at the bottom — it's easy to miss)
5. EasyDNS resolves changes within 5 min.

> **Why not just transfer everything to one registrar?** You can. But
> transferring costs a year of renewal fees and locks the domain for 60
> days afterward. Configuring each registrar individually is fine.

---

## 2. Email forwarding: hello@chrisportka.com → Gmail

Both registrars offer free forwarding.

### Namecheap

1. Manage the domain → **Redirect Email** (in the left sidebar)
2. If it's not enabled, enable it (free for all Namecheap domains)
3. Add alias: `hello` → `your.gmail@gmail.com`
4. Propagation ~15 min. Test by emailing `hello@chrisportka.com` from
   another account.

> Gmail has to verify the "Send mail as" feature separately if you want
> to **reply** from `hello@chrisportka.com`. Settings → Accounts →
> "Send mail as" → Add. Namecheap doesn't provide SMTP — use Gmail's
> (smtp.gmail.com, port 587, your Gmail password or an App Password).

### EasyDNS

1. Domain dashboard → **Mail** tab
2. Enable **EasyMail** forwarding (included free on most plans)
3. Alias: `hello` → your Gmail
4. Save.

---

## 3. 301 redirects for deprecated domains

For each of these, the goal is: someone hits `<old>.xyz` → lands on
`chrisportka.com` (or the deep-linked release page).

| Deprecated domain | Redirect target |
|-------------------|-----------------|
| `cportka.com` | `https://chrisportka.com` |
| `cportka.io` | `https://chrisportka.com` |
| `cportka.xyz` | `https://chrisportka.com` |
| `portka.io` | `https://chrisportka.com` |
| `djpants.xyz` | `https://chrisportka.com` |
| `trashmusic.xyz` | `https://chrisportka.com/releases/trash-music` |
| `lofibluesky.io` | `https://chrisportka.com` *(if folding in)* |

Status code should be **301 permanent**. A 302 (temporary) signals to
Google not to update its index — not what we want.

### Namecheap — URL Redirect Record

Namecheap has a built-in redirect feature; no external host needed.

1. Domain List → **Manage** (the deprecated domain)
2. **Advanced DNS** tab
3. Under **Host Records**, click **Add New Record**:
   - Type: **URL Redirect Record**
   - Host: `@` (apex)
   - Value: `https://chrisportka.com` (the target)
   - Options: **Permanent (301)** — not "Unmasked" / "Masked"
     - "Unmasked" = 301 redirect (what we want)
     - "Masked" = iframe-based cloaking (bad for SEO, don't use)
4. Add a second **URL Redirect Record**:
   - Host: `www`
   - Value: same target
   - 301 Permanent / Unmasked
5. Save. Test after ~15 min with:
   `curl -I https://cportka.com` — expect `HTTP/1.1 301 Moved Permanently`
   and `Location: https://chrisportka.com`.

For `trashmusic.xyz` only, set Value to
`https://chrisportka.com/releases/trash-music` to preserve press-link
equity.

### EasyDNS — WebForward

EasyDNS calls their redirect feature **WebForward** (or "URL Forward"
on newer UI).

1. Domain dashboard → **DNS** tab
2. Delete any existing A records pointing at old IPs
3. Click **Add Record** → choose type **WebForward**
   - Host: `@`
   - Target: `https://chrisportka.com`
   - Type: **301 Permanent** (not 302, not Stealth — Stealth frames the
     target inside an iframe, bad for SEO)
4. Add a second WebForward for `www`:
   - Host: `www`
   - Target: `https://chrisportka.com`
   - Type: 301 Permanent
5. Save.

For `trashmusic.xyz`, the target is
`https://chrisportka.com/releases/trash-music`.

> EasyDNS sometimes calls WebForward "HTTP Redirect" in the dropdown.
> Both refer to the same feature. If you can't find it, search EasyDNS
> support for "URL Forward".

### Verifying redirects

From your terminal:

```sh
for host in cportka.com cportka.io cportka.xyz djpants.xyz trashmusic.xyz portka.io; do
  printf '%-20s ' "$host"
  curl -sI "https://$host" | head -n 2 | tr -d '\r' | tr '\n' '  '
  echo
done
```

Each line should show `HTTP/2 301` (or 301/302 from the registrar's
redirect edge) with a `location:` header pointing at chrisportka.com.

If you see the registrar's parking page instead, the redirect isn't
saved — re-check the record type (must be URL Redirect / WebForward,
not A or CNAME).

---

## 4. The one thing that breaks things

**Don't also set an A record on the same host as a URL Redirect.**
If both exist, browsers pick one at random depending on DNS resolver
caching, and the behavior looks flaky. When enabling a redirect,
delete the old A/AAAA/CNAME first.

On Namecheap: remove the "Parking Page" CNAME that auto-appears.
On EasyDNS: remove the default A records the registrar adds on a fresh
domain.

---

## 5. Social handle pointers (out of scope of DNS but related)

Deprecating Linktree? Swap the links on Bandcamp/Instagram/YouTube/etc.
from `linktr.ee/cportka` to `https://chrisportka.com` directly. That's
a platform-level edit, not DNS.

If you ever want `links.chrisportka.com` as a lightweight link-page,
add a `links` CNAME at the chrisportka.com registrar pointing at a
Bio.fm / Beacons / Linktree custom domain. Not needed today.
