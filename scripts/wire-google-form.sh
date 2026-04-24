#!/usr/bin/env bash
#
# Wire the subscribe form to a Google Form.
#
# Usage:
#   ./scripts/wire-google-form.sh https://forms.gle/SHORTCODE
#   ./scripts/wire-google-form.sh https://docs.google.com/forms/d/e/.../viewform
#   ./scripts/wire-google-form.sh entry.1234567890   # just the email field ID
#
# What it does:
#   1. Resolves the forms.gle short URL if needed
#   2. Extracts the form ID (the /d/e/XXXX portion)
#   3. Fetches the viewform HTML and extracts the email field's entry ID,
#      trying several patterns — modern Google Forms build the form from
#      a JS blob and don't include `entry.NNNN` literally in the HTML.
#   4. Substitutes __GOOGLE_FORM_ID__ and entry.__EMAIL_FIELD__ in index.html.
#
# If automatic extraction fails, call the script with a raw `entry.NNN`
# and it'll patch just that field. Or see the MANUAL section in the
# printout for the one-click way to find it from the Google Forms UI.

set -uo pipefail

URL="${1:-}"
if [ -z "$URL" ]; then
  cat >&2 <<EOF
Usage: $0 <URL or entry.NNNN>

Examples:
  $0 https://forms.gle/TQm3Y9fkJDHZfVJN8
  $0 https://docs.google.com/forms/d/e/1FAI.../viewform
  $0 entry.1234567890

EOF
  exit 1
fi

cd "$(dirname "$0")/.."
TARGET="index.html"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET not found — run from repo root or via scripts/." >&2
  exit 1
fi

# Short-circuit: if the argument is already an entry.N string, just patch.
if [[ "$URL" =~ ^entry\.[0-9]+$ ]]; then
  EMAIL_ENTRY="$URL"
  echo "Using provided entry ID: $EMAIL_ENTRY"
  TMP="$(mktemp)"
  sed -e "s|entry\\.__EMAIL_FIELD__|$EMAIL_ENTRY|g" "$TARGET" > "$TMP"
  mv "$TMP" "$TARGET"
  echo "Patched $TARGET."
  exit 0
fi

echo "Resolving: $URL"
VIEW_URL=$(curl -sL -o /dev/null -w '%{url_effective}' "$URL")
[ -z "$VIEW_URL" ] && { echo "ERROR: couldn't resolve URL." >&2; exit 1; }
echo "  → $VIEW_URL"

FORM_ID=$(printf '%s' "$VIEW_URL" | sed -nE 's|.*/forms/d/e/([^/?#]+).*|\1|p')
[ -z "$FORM_ID" ] && {
  echo "ERROR: couldn't extract a form ID from the resolved URL." >&2
  echo "       Expected https://docs.google.com/forms/d/e/XXXX/viewform" >&2
  exit 1
}
echo "  Form ID: $FORM_ID"

echo "Fetching form HTML..."
HTML=$(curl -sL "$VIEW_URL")
if [ -z "$HTML" ]; then
  echo "ERROR: empty response fetching the form page." >&2
  exit 1
fi

# Try multiple extraction patterns. Each grep is wrapped with `|| true` so
# pipefail doesn't kill the script when a pattern finds nothing.
EMAIL_ENTRY=""

# 1. Legacy: <input name="entry.NNN">
EMAIL_ENTRY=$({ echo "$HTML" | grep -oE 'name="entry\.[0-9]+"' || true; } | head -n1 | grep -oE 'entry\.[0-9]+' || true)

# 2. Any occurrence of entry.NNN in the HTML
if [ -z "$EMAIL_ENTRY" ]; then
  EMAIL_ENTRY=$({ echo "$HTML" | grep -oE 'entry\.[0-9]+' || true; } | head -n1)
fi

# 3. data-params attribute — Google sometimes puts field ID here:
#    data-params="%.@.[1234567890,..."
if [ -z "$EMAIL_ENTRY" ]; then
  CANDIDATE=$({ echo "$HTML" | grep -oE 'data-params="[^"]*' || true; } | grep -oE '\[[0-9]{8,11},' | head -n1 | grep -oE '[0-9]+')
  [ -n "$CANDIDATE" ] && EMAIL_ENTRY="entry.$CANDIDATE"
fi

# 4. FB_PUBLIC_LOAD_DATA_ JS blob — the entry ID is an 8-11 digit integer
#    inside the field schema. Pattern [[NNN,null, is typical.
if [ -z "$EMAIL_ENTRY" ]; then
  CANDIDATE=$({ echo "$HTML" | grep -oE '\[\[[0-9]{8,11},null,' || true; } | head -n1 | grep -oE '[0-9]{8,11}')
  [ -n "$CANDIDATE" ] && EMAIL_ENTRY="entry.$CANDIDATE"
fi

if [ -z "$EMAIL_ENTRY" ]; then
  cat >&2 <<EOF

Couldn't auto-extract the email field's entry ID.

MANUAL — this always works (takes 15 seconds):

  1. Open your Google Form in the admin view (where you edit it).
  2. Click the three-dot menu (⋮) at the top right.
  3. "Get pre-filled link".
  4. Type anything into the Email field (like "x") and hit "Get link".
  5. At the bottom, click "COPY LINK".
  6. The URL you copy contains something like:
         ...?usp=pp_url&entry.1234567890=x
     Copy that "entry.1234567890" part.

Then run:

  $0 entry.1234567890

It'll patch index.html and exit.

EOF
  exit 1
fi

echo "  Email entry: $EMAIL_ENTRY"

TMP="$(mktemp)"
sed \
  -e "s|__GOOGLE_FORM_ID__|$FORM_ID|g" \
  -e "s|entry\\.__EMAIL_FIELD__|$EMAIL_ENTRY|g" \
  "$TARGET" > "$TMP"
mv "$TMP" "$TARGET"

echo
echo "Patched $TARGET. Review the diff, then:"
echo "  git add $TARGET && git commit -m 'Wire subscribe form to Google Form' && git push"
