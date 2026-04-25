#!/usr/bin/env bash
#
# Generate the hero portrait assets for chrisportka.com.
#
# Usage:
#   ./scripts/prepare-images.sh path/to/original-portrait.jpg
#
# If no argument is given, expects assets/portrait-hero.jpg to already exist
# and will just regenerate the WebP/AVIF/OG derivatives from it.
#
# Produces:
#   assets/portrait-hero.jpg   2000x2000, ~80-150KB
#   assets/portrait-hero.webp  same dims
#   assets/portrait-hero.avif  same dims
#   assets/og-image.jpg        1200x630 (top-anchored) for link previews
#
# Requires: ImageMagick. Optionally: cwebp (WebP), avifenc (AVIF).
#   macOS:  brew install imagemagick webp libavif
#   Linux:  apt install imagemagick webp libavif-bin

set -euo pipefail

cd "$(dirname "$0")/.."
OUT="assets"
DEST_JPG="$OUT/portrait-hero.jpg"

# Pick ImageMagick binary. `magick` on IM7+, `convert` on older installs.
if command -v magick >/dev/null 2>&1; then MAGICK="magick"
elif command -v convert >/dev/null 2>&1; then MAGICK="convert"
else
  echo "ERROR: ImageMagick not found. Install with: brew install imagemagick" >&2
  exit 1
fi

# Resolve source — either an argument, or the existing hero JPEG.
SRC="${1:-$DEST_JPG}"
if [ ! -f "$SRC" ]; then
  echo "ERROR: source image not found: $SRC" >&2
  echo "Pass the original as the first argument, e.g." >&2
  echo "  ./scripts/prepare-images.sh ~/Downloads/chris-portrait.jpg" >&2
  exit 1
fi

echo "Source: $SRC"

# 1. Hero JPEG — 2000px longest edge, stripped metadata, quality 82.
TMP_JPG="$(mktemp -t portka).jpg"
"$MAGICK" "$SRC" -auto-orient -resize 2000x2000\> -strip -quality 82 "$TMP_JPG"
mv "$TMP_JPG" "$DEST_JPG"
echo "  wrote $DEST_JPG ($(wc -c < "$DEST_JPG" | awk '{printf "%.0fKB", $1/1024}'))"

# 2. WebP
if command -v cwebp >/dev/null 2>&1; then
  cwebp -quiet -q 80 "$DEST_JPG" -o "$OUT/portrait-hero.webp"
  echo "  wrote $OUT/portrait-hero.webp ($(wc -c < "$OUT/portrait-hero.webp" | awk '{printf "%.0fKB", $1/1024}'))"
else
  echo "  (skip) cwebp not installed — skipping portrait-hero.webp"
  echo "    install: brew install webp"
fi

# 3. AVIF
if command -v avifenc >/dev/null 2>&1; then
  avifenc --min 20 --max 30 --speed 6 "$DEST_JPG" "$OUT/portrait-hero.avif" >/dev/null
  echo "  wrote $OUT/portrait-hero.avif ($(wc -c < "$OUT/portrait-hero.avif" | awk '{printf "%.0fKB", $1/1024}'))"
else
  echo "  (skip) avifenc not installed — skipping portrait-hero.avif"
  echo "    install: brew install libavif"
fi

# 4. OG image — 1200x630 (Twitter/Slack/iMessage preferred ratio).
#    Anchored toward the upper portion so the face stays in frame.
"$MAGICK" "$SRC" -auto-orient -resize 1200x1200^ -gravity north -extent 1200x630 \
  -strip -quality 85 "$OUT/og-image.jpg"
echo "  wrote $OUT/og-image.jpg ($(wc -c < "$OUT/og-image.jpg" | awk '{printf "%.0fKB", $1/1024}'))"

echo
echo "Done. Commit the new assets:"
echo "  git add assets/portrait-hero.* assets/og-image.jpg"
echo "  git commit -m 'Add hero portrait assets'"
