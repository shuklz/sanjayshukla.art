#!/bin/bash
# build.sh — convert originals/*.png → images/<kebab>.avif at ~2200px wide
# Uses macOS's built-in `sips`. Run from project root: ./build.sh

set -euo pipefail

SRC_DIR="originals"
OUT_DIR="images"
MAX_DIM=2200
AVIF_QUALITY=65
JPG_QUALITY=80

mkdir -p "$OUT_DIR"

# CamelCase / PascalCase → kebab-case-lowercase
# Examples:
#   RadhaKrishna  → radha-krishna
#   LordShiva2    → lord-shiva-2
#   SiyaRam       → siya-ram
#   Lordshiva     → lordshiva   (no internal case boundary; rename source for consistency)
kebab() {
  echo "$1" \
    | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' \
    | sed -E 's/([A-Z]+)([A-Z][a-z])/\1-\2/g' \
    | sed -E 's/([a-zA-Z])([0-9])/\1-\2/g' \
    | tr '[:upper:]' '[:lower:]'
}

shopt -s nullglob
built=0
skipped=0

for src in "$SRC_DIR"/*.png "$SRC_DIR"/*.PNG; do
  base=$(basename "$src")
  base="${base%.*}"
  slug=$(kebab "$base")
  avif="$OUT_DIR/$slug.avif"
  jpg="$OUT_DIR/$slug.jpg"

  for out in "$avif" "$jpg"; do
    if [[ -f "$out" && "$out" -nt "$src" ]]; then
      printf 'skip   %s\n' "$out"
      skipped=$((skipped + 1))
      continue
    fi

    if [[ "$out" == *.avif ]]; then
      printf 'build  %s → %s\n' "$src" "$out"
      sips -Z "$MAX_DIM" -s format avif -s formatOptions "$AVIF_QUALITY" \
           "$src" --out "$out" >/dev/null
    else
      printf 'build  %s → %s\n' "$src" "$out"
      sips -Z "$MAX_DIM" -s format jpeg -s formatOptions "$JPG_QUALITY" \
           "$src" --out "$out" >/dev/null
    fi
    built=$((built + 1))
  done
done

printf '\nimages — %d built, %d skipped.\n' "$built" "$skipped"

# --- Step 2: encrypt gallery → index.html via Staticrypt ---

if [[ ! -f .password ]]; then
  echo
  echo "error: .password file not found at project root."
  echo "create it with the gallery password (gitignored, never committed):"
  echo "  echo 'your-password' > .password"
  exit 1
fi

if ! command -v npx >/dev/null; then
  echo
  echo "error: npx not found. Install Node (https://nodejs.org/) and retry."
  exit 1
fi

echo
echo "encrypting gallery..."
cp _src/gallery.html _src/index.html
STATICRYPT_PASSWORD="$(cat .password)" npx --yes staticrypt _src/index.html \
  -d . --short \
  --template-title "Digital Art by Sanjay Shukla" \
  --template-color-primary "#f0c75c" \
  --template-color-secondary "#0e0e10" \
  --template-button "Enter" \
  --template-placeholder "Password" >/dev/null
rm _src/index.html

echo "encrypted → index.html"
echo
echo "done. Commit and push:"
echo "  git add images/ index.html"
echo "  git commit -m 'Add painting: ...'"
echo "  git push"
