#!/bin/bash
# publish.sh — the one-button publish.
#
# Workflow:
#   1. drop new PNG (and optionally PSD) into originals/
#   2. ./publish.sh
#   3. refresh https://sanjayshukla.art/ in ~30 sec
#
# What it does:
#   a. scans originals/*.png; for any new painting (slug not yet in _src/gallery.html),
#      appends a tile to the gallery
#   b. runs ./build.sh (image conversion + Staticrypt encryption)
#   c. stages changes, makes a commit, pushes to GitHub
#
# Optional caption override per painting:
#   put a one-line caption in originals/<basename>.txt
#   (e.g. originals/LordShiva2.txt → "Lord Shiva — stained glass")
# Without an override, captions are derived from the filename
#   ("RadhaKrishna.png" → "Radha Krishna", "Hanuman2.png" → "Hanuman 2").

set -euo pipefail
cd "$(dirname "$0")"

# --- helpers ---

# CamelCase → kebab-case-lowercase. Mirrors build.sh.
kebab() {
  echo "$1" \
    | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' \
    | sed -E 's/([A-Z]+)([A-Z][a-z])/\1-\2/g' \
    | sed -E 's/([a-zA-Z])([0-9])/\1-\2/g' \
    | tr '[:upper:]' '[:lower:]'
}

# CamelCase → "Camel Case" with numeric splits ("Hanuman2" → "Hanuman 2").
caption_from() {
  echo "$1" \
    | sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' \
    | sed -E 's/([A-Z]+)([A-Z][a-z])/\1 \2/g' \
    | sed -E 's/([a-zA-Z])([0-9])/\1 \2/g'
}

# --- step 1: detect new originals, append tiles to _src/gallery.html ---

if [[ ! -f _src/gallery.html ]]; then
  echo "error: _src/gallery.html not found." >&2
  exit 1
fi

shopt -s nullglob
new_entries=()
for src in originals/*.png originals/*.PNG; do
  base=$(basename "$src")
  base="${base%.*}"
  slug=$(kebab "$base")
  if ! grep -q "src=\"/images/${slug}\.jpg\"" _src/gallery.html; then
    if [[ -f "originals/$base.txt" ]]; then
      caption=$(head -n 1 "originals/$base.txt" | tr -d '\r')
    else
      caption=$(caption_from "$base")
    fi
    new_entries+=("$slug|$caption|$base")
  fi
done

if [[ ${#new_entries[@]} -gt 0 ]]; then
  echo "new paintings (${#new_entries[@]}):"
  insert=""
  for entry in "${new_entries[@]}"; do
    IFS='|' read -r slug caption base <<< "$entry"
    printf '  + %s → "%s"\n' "$base" "$caption"
    insert+="        <button class=\"tile\" type=\"button\" aria-label=\"Open painting: ${caption}\">"$'\n'
    insert+="            <img src=\"/images/${slug}.jpg\" alt=\"${caption}\" draggable=\"false\" loading=\"lazy\">"$'\n'
    insert+="        </button>"$'\n'
  done
  # Splice the insert in just before `    </main>`. Using head/tail rather than
  # awk because BSD awk on macOS rejects literal newlines in -v values.
  linenum=$(grep -n '^    </main>$' _src/gallery.html | head -1 | cut -d: -f1)
  if [[ -z "$linenum" ]]; then
    echo "error: couldn't find '    </main>' marker in _src/gallery.html" >&2
    exit 1
  fi
  {
    head -n $((linenum - 1)) _src/gallery.html
    printf '%s' "$insert"
    tail -n +"$linenum" _src/gallery.html
  } > _src/gallery.html.tmp
  mv _src/gallery.html.tmp _src/gallery.html
  echo "tiles appended to _src/gallery.html."
else
  echo "no new paintings to add."
fi

# --- step 2: resize + encrypt ---
echo
./build.sh

# --- step 3: stage, commit, push ---
echo
git add images/ index.html publish.sh
git add -u  # pick up any other tracked file the user edited (styles.css, etc.)

# Use the index, not the working tree — untracked files (like a new originals/
# sidecar) shouldn't trigger a commit.
if ! git diff --cached --quiet; then
  if [[ ${#new_entries[@]} -gt 0 ]]; then
    captions=()
    for entry in "${new_entries[@]}"; do
      IFS='|' read -r _ caption _ <<< "$entry"
      captions+=("$caption")
    done
    if [[ ${#captions[@]} -eq 1 ]]; then
      msg="Add painting: ${captions[0]}"
    else
      joined=$(printf ', %s' "${captions[@]}")
      msg="Add paintings: ${joined:2}"
    fi
  else
    msg="Update site"
  fi
  echo "committing: $msg"
  git commit -m "$msg"
fi

# Push any unpushed commits (covers a previous run that committed but failed to push).
if [[ -n "$(git rev-list '@{u}..HEAD' 2>/dev/null)" ]]; then
  echo "pushing to origin/main..."
  git push
  echo
  echo "✓ done. Site updates in ~30 sec at https://sanjayshukla.art/"
else
  echo "nothing to push — already up to date."
fi
