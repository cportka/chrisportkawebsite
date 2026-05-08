#!/usr/bin/env bash
#
# Smoke-test the live subscribe form by POSTing a marked test email.
#
# This hits the *real* Google Form endpoint, so a successful run will create
# a row in the linked Google Sheet. The email is prefixed with a timestamp
# marker so you can spot and delete it after.
#
# Usage:
#   scripts/test-subscribe.sh                # uses default marker email
#   scripts/test-subscribe.sh you@email.com  # uses a custom email
#
# What "success" looks like:
#   - HTTP 200 from docs.google.com (Google Forms returns 200 even on the
#     confirmation page — there's no machine-readable success token).
#   - A new row in the linked Google Sheet within ~10s, containing the marker.
#
# Caveat: a 200 means "Google accepted the request." It does NOT 100% confirm
# the row landed in the Sheet (e.g. if the form was unlinked from the sheet
# in the form editor, submissions still 200 but never appear). Always
# eyeball the sheet to fully verify.

set -euo pipefail

FORM_ACTION="https://docs.google.com/forms/d/e/1FAIpQLSekASuiQlaQbViFl5JQ0wZsY4YdR8EMfCF3rnSwQurMrU7T4Q/formResponse"
EMAIL_FIELD="entry.2065888469"

stamp=$(date +%Y%m%d-%H%M%S)
default_email="subscribe-test+${stamp}@chrisportka.com"
email="${1:-$default_email}"

echo "==> POST $FORM_ACTION"
echo "    $EMAIL_FIELD = $email"
echo

http_code=$(curl -sS -o /tmp/subscribe-test-body.html -w "%{http_code}" \
  --max-time 20 \
  -X POST "$FORM_ACTION" \
  --data-urlencode "${EMAIL_FIELD}=${email}" \
  --data-urlencode "fvv=1" \
  --data-urlencode "submit=Submit" \
  || echo "000")

echo "HTTP $http_code"
echo

case "$http_code" in
  200)
    if grep -qiE "form has been submitted|response has been recorded|your response" /tmp/subscribe-test-body.html 2>/dev/null; then
      echo "PASS: Google returned the confirmation page."
    else
      echo "PASS (probable): HTTP 200 returned. Confirmation text not detected,"
      echo "                 but Google often A/B's the confirmation page wording."
    fi
    echo
    echo "Now verify in the Google Sheet:"
    echo "  - A new row should appear within ~10s"
    echo "  - Email column should contain: $email"
    echo "  - Delete the test row when done."
    ;;
  000)
    echo "FAIL: network/curl error — no response from Google."
    exit 1
    ;;
  *)
    echo "FAIL: unexpected HTTP $http_code"
    echo "Response body saved to /tmp/subscribe-test-body.html"
    exit 1
    ;;
esac
