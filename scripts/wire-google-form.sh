#!/usr/bin/env bash
#
# Wire the subscribe form to a Google Form.
#
# Usage:
#   ./scripts/wire-google-form.sh https://forms.gle/SHORTCODE
#
# What it does:
#   1. Resolves the forms.gle short URL to its /viewform URL
#   2. Extracts the form ID (the /d/e/XXXX portion)
#   3. Fetches the viewform page HTML
#   4. Pulls the first entry.NNNN field name (works for a one-field form)
#   5. Substitutes __GOOGLE_FORM_ID__ and entry.__EMAIL_FIELD__ in index.html
#
# Safe to re-run. If you change Forms later, run again with the new URL.

set -euo pipefail

URL="${1:-}"
if [ -z "$URL" ]; then
  echo "Usage: $0 <forms.gle/SHORTCODE or full viewform URL>" >&2
  exit 1
fi

cd "$(dirname "$0")/.."
TARGET="index.html"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: $TARGET not found — run from repo root or via scripts/." >&2
  exit 1
fi

echo "Resolving: $URL"
VIEW_URL=$(curl -sL -o /dev/null -w '%{url_effective}' "$URL")
if [ -z "$VIEW_URL" ]; then
  echo "ERROR: couldn't resolve short URL." >&2
  exit 1
fi
echo "  → $VIEW_URL"

FORM_ID=$(printf '%s' "$VIEW_URL" | sed -nE 's|.*/forms/d/e/([^/?#]+).*|\1|p')
if [ -z "$FORM_ID" ]; then
  echo "ERROR: couldn't extract a form ID from the resolved URL." >&2
  echo "       Expected something like https://docs.google.com/forms/d/e/XXXX/viewform" >&2
  exit 1
fi
echo "  Form ID: $FORM_ID"

echo "Fetching form HTML to find the email field's entry ID..."
EMAIL_ENTRY=$(curl -sL "$VIEW_URL" | grep -oE 'entry\.[0-9]+' | sort -u | head -n1)
if [ -z "$EMAIL_ENTRY" ]; then
  echo "ERROR: no entry.N field found on the form page." >&2
  echo "       Is the form empty? Or has it changed since it was built?" >&2
  exit 1
fi
echo "  Email entry: $EMAIL_ENTRY"

# Patch via a temp file for cross-platform sed safety.
TMP="$(mktemp)"
sed \
  -e "s|__GOOGLE_FORM_ID__|$FORM_ID|g" \
  -e "s|entry\\.__EMAIL_FIELD__|$EMAIL_ENTRY|g" \
  "$TARGET" > "$TMP"
mv "$TMP" "$TARGET"

echo
echo "Patched $TARGET. Review the diff, then:"
echo "  git add $TARGET && git commit -m 'Wire subscribe form to Google Form' && git push"
