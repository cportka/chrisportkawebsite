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

### EasyDNS — detailed walkthrough

EasyDNS calls their forwarding feature **EasyMail Forwarding**. It's
free on every plan and doesn't need a separate mailbox — messages to
`hello@chrisportka.com` are rewritten and relayed to your personal Gmail.

1. **Control panel** → <https://cp.easydns.com/> → sign in
2. **Domains** → click `chrisportka.com`
3. Look for **Mail** in the left navigation (sometimes under *Services*
   or *Manage* depending on UI vintage). If **Mail** is missing, check
   **Services → Enable EasyMail** first.
4. Inside the Mail tab:
   - Confirm **MX records** are set to EasyDNS mail hosts. EasyMail
     usually adds these automatically when you enable it; if not,
     click the *"Add EasyMail MX records"* button (or manually add
     `MX 10 mx1.easydns.com` and `MX 20 mx2.easydns.com` on the DNS tab).
   - Under **Forwarders** / **Aliases**, click **Add forward**.
   - Source: `hello` (just the local part — EasyDNS appends the domain)
   - Destination: `your.real@gmail.com`
   - Save.
5. Allow **5–30 min** for the MX to propagate and the alias to become
   active.
6. Test: send a message to `hello@chrisportka.com` from a different
   address. It should land in your Gmail inbox, with the sender preserved
   (so you can see who really wrote).

### MX records — what they are, why EasyDNS is asking

Your domain's A records tell the internet "web traffic for
`chrisportka.com` goes to GitHub Pages". They don't say anything about
email. If someone emails `hello@chrisportka.com` with only A records set,
their mail server can't find a mail host and the message bounces.

**MX (Mail eXchange) records** fix that. They're a separate DNS record
type, one per mail server, and they tell senders: "to deliver email for
this domain, contact *this host*." Each record has a priority — lower
numbers are tried first.

For EasyMail Forwarding, EasyDNS needs two MX records pointing at their
inbound mail servers. Web and mail routing live side by side on the
same domain — the A records (web) and MX records (mail) don't conflict.

### Exactly what to add at EasyDNS

DNS tab (or **Mail → Edit MX records**) for `chrisportka.com`:

| Host | Type | Priority | Mail Server |
|------|------|----------|-------------|
| `@`  | MX   | 10       | `LOCAL`     |
| `@`  | MX   | 20       | `LOCAL`     |

**Yes, the literal word `LOCAL`** — uppercase, no quotes, no domain.
This is an EasyDNS keyword that means "use your own mail infrastructure
**and apply my mailmaps to it**." If you put `mx1.easydns.com` directly
in the Mail Server field, DNS routes the mail correctly but EasyDNS's
forwarding engine doesn't check your mailmaps, so messages bounce.
Public DNS ends up looking identical either way (both resolve to
`mx1.easydns.com` / `mx2.easydns.com` when queried externally) — the
difference is purely internal to EasyDNS's mail-routing logic.

One `LOCAL` entry at pref 10 is sufficient. A second at pref 20 just
gives redundancy inside EasyDNS's cluster.

**If EasyDNS's UI shows a "Does not appear to be a valid server"
warning when you type `LOCAL`**, ignore it and confirm anyway — that's
a false positive from their hostname validator.

**Recommended (optional) SPF record.** Prevents spammers from spoofing
your domain. Add as a TXT record:

| Host | Type | Value                              |
|------|------|------------------------------------|
| `@`  | TXT  | `v=spf1 include:easydns.com ~all`  |

### Before you save — delete any old MX records first

If the domain was ever set up with another mail provider (Google
Workspace, Zoho, etc.), there will be leftover MX records pointing
somewhere else. Mail routing gets confused if multiple MX sets exist,
so remove those first.

### Verifying after save

Propagation is usually 5-15 min at EasyDNS. From your terminal:

```sh
dig +short MX chrisportka.com
# expect (EasyDNS expands LOCAL publicly to their real hosts):
#   10 mx1.easydns.com.
#   20 mx2.easydns.com.

dig +short TXT chrisportka.com
# expect one line containing v=spf1 include:easydns.com ~all
```

Then finish the forwarding config — on EasyDNS this lives under
**Email → Mail → mailmaps** (not "Add forward"):
- Mailmap: `hello` (EasyDNS appends the domain automatically)
- Destination: your Gmail, or a plus-addressed alias like
  `yourname+hello@gmail.com` so you can filter on it later
- Click **Next** / Save

Send a test email to `hello@chrisportka.com` from a different address
and it should land in your Gmail within a minute or two.

### Why this matters for the contact link

The contact section's `mailto:hello@chrisportka.com` link silently
fails until MX + forward are in place. The Google Form subscribe flow
doesn't depend on this — subscriptions go directly to the linked
Google Sheet — but anyone using the direct email link gets a bounce
until you finish this step.

### Replying from hello@chrisportka.com in Gmail

This is optional — if you only need inbound, skip it. For reply-as:

1. Gmail → Settings (gear icon) → **See all settings**
2. **Accounts and Import** → **Send mail as** → **Add another email address**
3. Name: `Chris Portka`, Address: `hello@chrisportka.com`, uncheck *Treat
   as an alias*
4. Next screen:
   - SMTP server: `smtp.gmail.com`
   - Port: `587`
   - Username: your Gmail address
   - Password: a Gmail *App Password* (not your login password — create
     at <https://myaccount.google.com/apppasswords>; requires 2FA on
     the Google account)
   - TLS: yes
5. Gmail sends a confirmation code to `hello@chrisportka.com`. Because
   the forward is in place, the code arrives in Gmail. Enter it.
6. You can now pick `hello@chrisportka.com` from the "From" dropdown
   when composing.

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
