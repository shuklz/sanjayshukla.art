# sanjayshukla.art — Personal Art Portfolio

Password-gated, display-only personal portfolio of ~50 digital paintings made on iPad. First series is **FAITH** (Mythological Hindu Gods and Goddesses); additional series may follow over time. Site title (locked in 2026-05-24) is **Digital Art by Sanjay Shukla**. Audience is family and friends; the password gate exists so the site stays off Google and out of casual hands, not as a real security boundary.

> **Handoff context**: This file was drafted in a session at `/Users/sanjay/Sites/3sstudio.net/` (the sister project, see "Carryover patterns" below) on 2026-05-24, then moved into this fresh project folder and renamed to `CLAUDE.md`. If the user references "the previous conversation" or "what we already decided", everything decided is captured in the "Decisions locked in" and "Decisions pending" sections below — there is no other context to chase.

---

## ⚡ STATE AS OF END OF 2026-05-24 (afternoon session) — READ THIS FIRST

The site is **built, encrypted, and pushed**. Four FAITH paintings are on display. Password gate is wired.

### What works (verified end of session)
- GitHub Pages is serving the Staticrypt-encrypted gallery — verified via DNS-bypass curl. View-source on `index.html` reveals only encrypted blob.
- Password gate works in **both Safari and Chrome**.
- Lightbox: click any tile, prev/next/Esc/arrow keys/backdrop-click-to-close. Sticky header that stays anchored on scroll.
- **Gold-framed mat** around every tile and the lightbox image: soft gold hairline on a `#1a1a1d` mat, brightens to full accent gold on hover.
- **Zoom + pan in the lightbox**: `+`/`−`/reset toolbar at bottom-center, mouse-wheel zoom on the image, click-and-drag to pan when zoomed in, double-click to reset, keyboard `+`/`−`/`0` shortcuts. Zoom range 1×–3×. Standard JPG (2200px) loads instantly; hi-res JPG (up to 5120px) is preloaded in the background and swapped in on first zoom. Arrow-key prev/next is suppressed when zoom > 1 so inspection isn't interrupted.
- Anti-copy: no right-click menu, no image drag, no text/image selection.
- Pipeline: `./publish.sh` is the one-button publish — auto-appends tiles for new originals to `_src/gallery.html`, runs `./build.sh` (image conversion: PNG → JPG + AVIF at 2200px + hi-res JPG capped at min(source, 5120px); plus Staticrypt encryption), then commits and pushes. `./build.sh` is still callable standalone for local-only rebuilds. Password is read from `./.password` (gitignored).

### Password (for future sessions)
- `DigitalArtBySanjayShukla` — chosen by user 2026-05-24
- Stored locally in `./.password` (gitignored, never committed)
- If `.password` file is missing on a new Mac/clone, just recreate it: `echo 'DigitalArtBySanjayShukla' > .password` then `./publish.sh`

### What's pending — pick up here when user returns
1. ✅ **Let's Encrypt cert issued (2026-05-25).** Subject is `/CN=sanjayshukla.art`, valid through Aug 22, 2026. Was blocked for ~24 hours by an orphaned DS record at the `.art` registry left over from when Google Domains was authoritative — see "DNSSEC trap" section below for the full story and the fix. Verify the cert anytime with:
   ```bash
   echo | openssl s_client -servername sanjayshukla.art -connect 185.199.108.153:443 2>/dev/null | openssl x509 -noout -subject -dates
   ```
2. ✅ **"Enforce HTTPS" toggled (2026-05-25).** Done at https://github.com/shuklz/sanjayshukla.art/settings/pages once the cert went active.
3. **Share URL + password with family/friends** — now safe to do (HTTPS enforced, cert globally propagating; allow ~30–60 min from issuance for all edge POPs to pick it up).

### The DNSSEC trap (2026-05-25 incident, recorded for future-you)

On 2026-05-24 the cert wouldn't issue. After 24 hours of "DNS check successful" but no cert, the diagnosis was that Google Domains (the previous DNS host before switching to name.com on 2026-05-24) had DNSSEC enabled by default and had pushed a DS record up to the `.art` registry. Switching nameservers to name.com — whose default DNS does NOT support DNSSEC self-signing — left the DS record orphaned at the registry. Validating resolvers (including Let's Encrypt's) returned SERVFAIL for `sanjayshukla.art`, so ACME validation never reached the HTTP-01 challenge step. The Pages settings page showed no error; the queue just silently kept retrying.

**Symptom (use this to recognize it in the future or on any other domain):**
```bash
dig @8.8.8.8 sanjayshukla.art A 2>&1 | grep status:
```
- `SERVFAIL` → DNSSEC chain is broken. Cert will never issue.
- `NOERROR` → DNS is healthy; cert issues normally.

The casual `dig sanjayshukla.art A` from a laptop will still return correct A records even when validation is broken, because most consumer resolvers don't enforce DNSSEC. So the site appears to work in browsers, but is invisible to Let's Encrypt. This is *the* misleading thing.

**Fix:** name.com → Manage Nameservers → bottom of page, "DNSSEC Management page" link → Remove all DS records at the registry. Propagation through the `.art` TLD takes ~30–60 min; after `dig @8.8.8.8` returns NOERROR, re-toggling the custom domain in Pages settings forces an immediate Let's Encrypt retry and the cert issues within 5–15 min.

Same lesson is also saved as a cross-project memory in 3sstudio.net's `.claude` memory dir under `dnssec-orphan-after-ns-switch.md`, in case it ever bites the sister site or a future domain.

### Browser quirk discovered — DO NOT ACCIDENTALLY RE-ENABLE
Chrome on this Mac **fails to render `sips`-generated AVIF files in `<img>` tags**: it loads them with HTTP 200 OK but renders 0×0 in the page (collapsing the tile buttons). Bizarrely, the lightbox can still show them via JS direct `src` setting on a single `<img>`. The `<picture>` element AVIF→JPG fallback did **not** save us — Chrome picked AVIF, AVIF failed at *render time* (not load time), and the browser did not fall back.

**Resolution**: `_src/gallery.html` uses plain `<img src=".../*.jpg">` with no `<picture>` wrapper. AVIFs are still generated by `build.sh` (in case Chrome AVIF rendering gets fixed or a future revival is worth it) but the gallery HTML doesn't reference them. If you re-introduce AVIF in HTML, **test in Chrome before pushing.**

### Tooling state on this Mac
- `git` ✓
- `sips` ✓ (built-in to macOS)
- `node` v24.16.0 + `npm` 11.13.0 ✓ (installed via official `.pkg` from https://nodejs.org/, **NOT** via Homebrew — Homebrew is not installed on this Mac)
- `gh` CLI ✗ — Pages settings changes go via the web UI at https://github.com/shuklz/sanjayshukla.art/settings/pages
- `brew` ✗ — don't suggest `brew install X`; user prefers `.pkg` installs or built-in tools
- Python 3 ✓ (for local preview: `python3 -m http.server 8765` from project root)

### Day-to-day "add a painting" workflow (locked in)
```bash
cp ~/iPad-export.png originals/MyNewPainting.png   # CamelCase is fine
./publish.sh                                        # one-button: tile + convert + encrypt + commit + push
```
That's it. See "Build pipeline" below for what `publish.sh` does internally.

---

## Quick facts

- **Domain**: `sanjayshukla.art` (already owned, at name.com)
- **Repo**: `https://github.com/shuklz/sanjayshukla.art` — already created (empty, public, no README/license/gitignore auto-seeded) on 2026-05-24. First push from the local clone should land cleanly.
- **Live**: `https://sanjayshukla.art/` once Pages + DNS are wired
- **Owner**: Sanjay Shukla — `shuklz@gmail.com`
- **Commit identity**: `git -c user.email=shuklz@gmail.com -c user.name=shuklz …` — this repo will NOT be tied to a global git config, same as the sister site
- **Default branch**: `main`

## What this site is — and isn't

**Is**: a quiet, password-gated gallery. Visitor lands on a Staticrypt lock screen, enters one shared password, sees a masonry grid of paintings. Click a tile → fullscreen lightbox with prev/next. That's the whole site.

**Isn't**: a shop, a print store, a downloadable archive, a blog. No commerce, no comments, no analytics, no "share" buttons, no full-resolution downloads. Originals stay on the artist's Mac forever.

## Decisions locked in (from the planning conversation, 2026-05-24)

- **Hosting**: GitHub Pages from `main`, exactly like the sister site. No separate CDN — Pages' built-in Fastly is plenty for 50 display-res images.
- **Password gate**: **Staticrypt** (encrypts the actual gallery HTML payload). Specifically chosen over a JS-only password prompt because Staticrypt makes the page un-viewable in *view-source* without the password — which also keeps it out of search engine indexes. (User explicitly asked for the stronger of the two options.)
- **Image policy**: each painting produces **three** committed outputs from one PNG source: (1) `<slug>.avif` at 2200px (AVIF quality 65, currently unreferenced in HTML due to Chrome render bug — kept for future revival), (2) `<slug>.jpg` at 2200px (JPEG quality 80, what the masonry grid and initial lightbox view actually display), and (3) `<slug>-hires.jpg` at min(source-max-dim, 5120px) (JPEG quality 82, preloaded by the lightbox and swapped in when the user zooms past 1×). JPGs are ~0.6–1.7 MB each at 2200px and ~2.5–7 MB each at hi-res. 50 paintings ≈ 200–300 MB total committed — comfortable inside Pages' 1 GB soft limit and 100 GB/month bandwidth. (History: originally planned as WebP; switched to AVIF + JPG dual-output on 2026-05-24 because this Mac has neither Homebrew nor `cwebp`, and macOS's built-in `sips` writes both AVIF and JPG but not WebP. Hi-res JPG variant added later that day to support the lightbox zoom feature.)
- **Originals never leave the artist's Mac.** They are not committed to git; they live in a gitignored `originals/` folder. AVIFs, JPGs, and hi-res JPGs all go to the repo (in `images/`).
- **Anti-copy is now weaker for the hi-res JPGs.** Since the lightbox can load `images/<slug>-hires.jpg` (up to 5120px on the long edge), anyone who guesses or sniffs the URL pattern can download that variant directly. Acceptable trade-off for the zoom feature; user explicitly approved 2026-05-24. The 2200px standard JPG is what's shown in the grid and at fit-screen, so a casual right-click-save (if right-click were allowed) would still get the smaller one.
- **Anti-copy deterrents**: right-click context menu disabled, image dragging disabled, CSS `user-select: none`. Acknowledge to the user that none of these prevent screenshots — they're just polite gates. The display-resolution cap is what bounds losses.
- **No CDN dilemma**: the only reason to add R2 / B2 / Cloudinary would be full-resolution downloads, and there are none. GitHub Pages handles everything.
- **Vanilla HTML/CSS/JS, no framework.** Pattern matches 3sstudio.net. **One tiny exception**: Staticrypt is a Node tool that has to run locally to produce the encrypted HTML. That's a one-shell-command "build step" — see "Build pipeline" below. Don't introduce Webpack / Vite / Next / etc.

## Decisions still pending — ask the user before assuming

1. ~~Site title~~ — **RESOLVED 2026-05-24**: **Digital Art by Sanjay Shukla**.
2. **Tagline / one-line description** on the lock screen — something brief about the series? Or leave the gate visually quiet (just title + password field)?
3. **Watermark** — yes / no / what mark? Options: a small low-opacity signature in a corner of each painting (baked in during the build pipeline using ImageMagick/sips), OR a single CSS-overlay watermark on the page (visible but trivially DOM-removable), OR none. User was leaning "decide later" — confirm before shipping.
4. ~~Password model~~ — **RESOLVED 2026-05-24**: single shared password `DigitalArtBySanjayShukla`. If multi-password becomes useful later, Staticrypt's `-p` flag also accepts a JSON file with per-recipient passwords.
5. ~~Captions / titles per painting~~ — **RESOLVED 2026-05-24**: source files are CamelCase (`RadhaKrishna.png`); `build.sh` kebab-cases to slugs. `publish.sh` derives the caption by splitting CamelCase + digit boundaries, OR reads the first line of `originals/<basename>.txt` if present. Caption shows in the lightbox only (not on hover). The `.txt` sidecar is consulted *once* — at tile-insertion time — not on every build, so post-insertion caption changes require hand-editing `_src/gallery.html`.
6. **Lock-screen wallpaper** — Staticrypt themes are minimal. Want a faded painting behind the gate, or plain background?

## Folder layout (proposed — confirm with user)

```
sanjayshukla.art/                    ← the git repo
├── originals/                       ← gitignored. The user drops iPad exports here.
│   ├── RadhaKrishna.png             ← CamelCase OK; build.sh kebab-cases for URLs
│   ├── RadhaKrishna.psd             ← optional editable master (not consumed by build.sh)
│   ├── RadhaKrishna.txt             ← optional caption override. First line is used as the tile/lightbox caption.
│   └── …                            ← ~50 files
├── _src/                            ← gitignored. Unencrypted gallery source — what publish.sh appends tiles to.
│   └── gallery.html
├── images/                          ← COMMITTED. Three outputs per painting (see Image policy).
│   ├── radha-krishna.jpg            ← 2200px; gallery + initial lightbox view
│   ├── radha-krishna-hires.jpg      ← up to 5120px; preloaded for lightbox zoom
│   └── radha-krishna.avif           ← 2200px AVIF, committed but unused in HTML (Chrome quirk, see top)
├── index.html                       ← COMMITTED. Staticrypt-encrypted gallery + lock screen.
├── styles.css                       ← COMMITTED.
├── CNAME                            ← COMMITTED. Contains exactly: sanjayshukla.art
├── publish.sh                       ← COMMITTED. One-button publish: tile + build + commit + push. What the user runs.
├── build.sh                         ← COMMITTED. Image conversion + encryption. Called by publish.sh; also runnable standalone.
├── .gitignore                       ← COMMITTED.
├── .staticrypt.json                 ← COMMITTED. Just the salt (not secret). Keeps the encryption stable across rebuilds.
├── .password                        ← GITIGNORED. Plaintext gallery password, used by build.sh.
├── UPDATE.md                        ← COMMITTED. User-facing manual (written for Sanjay, not Claude).
└── CLAUDE.md                        ← this file
```

**Don't deviate from this layout without good reason** — `publish.sh`, `build.sh`, and `.gitignore` are calibrated to it.

## Build pipeline (`publish.sh` → `build.sh`)

Two shell scripts. `publish.sh` is what the user runs; it delegates the heavy lifting to `build.sh`.

### `publish.sh` — the one-button publish

1. **Detect new paintings** — for each `originals/*.png`, computes the kebab slug and greps `_src/gallery.html` for it. Any slug not present is "new".
2. **Append tiles** — for each new painting, inserts a `<button class="tile">…</button>` block just before `    </main>` in `_src/gallery.html`. Insertion uses a `head N | insert | tail N+1` split (not awk — BSD awk on macOS rejects literal newlines in `-v` values; learned the hard way 2026-05-24).
3. **Caption resolution per new painting**:
   - If `originals/<basename>.txt` exists → first line is the caption.
   - Else → `caption_from()` splits CamelCase + digit boundaries (`LordShiva.png` → "Lord Shiva", `Hanuman2.png` → "Hanuman 2"). Filenames with no internal capital (e.g. `Ganeshji.png`) yield "Ganeshji" — user must rename or use a `.txt` sidecar to fix.
   - Captions are written into the tile's `alt`, `aria-label`, and (via JS) the lightbox caption. After tile insertion, the caption lives in `_src/gallery.html`; editing the `.txt` later won't update it (the script only consults `.txt` on *first* insertion).
4. **Calls `./build.sh`** (see below).
5. **Stages, commits, pushes** — `git add images/ index.html publish.sh && git add -u` (the `-u` picks up edits to other tracked files like `styles.css` or `UPDATE.md`). Commit message is `Add painting: X` (single new) / `Add paintings: X, Y` (multiple) / `Update site` (no new paintings, just other tracked-file edits). Detects "nothing to commit" via `git diff --cached --quiet`. Always tries to push any unpushed commits at the end (covers the case where a previous run committed but failed to push).

### `build.sh` — image conversion + encryption

1. **Optimise images** — for each file in `originals/`, produce three outputs in `images/`: `<kebab>.avif` (sips, quality 65, capped at 2200px), `<kebab>.jpg` (sips, quality 80, capped at 2200px), and `<kebab>-hires.jpg` (sips, quality 82, capped at `min(source-max-dim, 5120px)` — never upscales). Filename is auto-converted to kebab-case (`RadhaKrishna.png` → `radha-krishna.jpg`) via three sed expressions in the `kebab()` helper. Skip files where any output is newer than the source. If a watermark is ever enabled, composite during this step (sips can do basic composition; ImageMagick would need installing).
2. **Encrypt the gallery HTML** — copies `_src/gallery.html` to `_src/index.html`, then runs Staticrypt: `STATICRYPT_PASSWORD="$(cat .password)" npx --yes staticrypt _src/index.html -d . --short --template-title "Digital Art by Sanjay Shukla" --template-color-primary "#f0c75c" --template-color-secondary "#0e0e10" --template-button "Enter" --template-placeholder "Password"`. Then removes the temp `_src/index.html`. `--short` suppresses the "short password" warning. Reads password from `.password` (gitignored). Fails fast if `.password` or `npx` is missing.
3. **Conditional re-encryption** — Staticrypt uses a fresh IV per run, so re-encrypting unchanged content still produces a different `index.html` (= noise commits). `build.sh` skips step 2 entirely when `index.html` is newer than both `_src/gallery.html` AND `.password`. Don't remove this guard — without it, every `./publish.sh` run pushes a meaningless 1-line diff. (See commits e96f856…7f78913 from 2026-05-24 evening for examples of this noise — left in history because rewriting pushed commits needs force-push, which the user has prohibited.)

### The user's full workflow

```bash
cp ~/iPad-export.png originals/NewPainting.png   # CamelCase recommended; .psd optional alongside
# (optional) echo 'Custom Caption' > originals/NewPainting.txt
./publish.sh                                      # Pages rebuilds in ~30 sec
```

Local git identity is set per-repo (`git config user.email shuklz@gmail.com`, `git config user.name "Sanjay Shukla"`) — done once at init, no need to re-add `-c` flags per commit.

### Things `publish.sh` does NOT do (still need Claude)

- **Remove a painting** — no automation. Claude must edit `_src/gallery.html` to drop the tile, `rm images/<slug>.{jpg,avif}` and `rm images/<slug>-hires.jpg`, then `./publish.sh` to push.
- **Re-order tiles** — `publish.sh` always appends new tiles at the end of `<main class="gallery">`. To reorder, hand-edit `_src/gallery.html`.
- **Change a caption after first insertion** — once a tile is in `_src/gallery.html`, the `.txt` sidecar is no longer consulted. Edit `_src/gallery.html` directly (the tile's `aria-label` and the img's `alt` must both be updated to keep them in sync).

## Staticrypt — what to know

- Staticrypt is a Node CLI: `npx staticrypt …` works without a global install.
- It takes an HTML file, wraps the body in encrypted form, and emits a self-contained HTML page whose top of `<body>` is a password prompt. When the visitor types the password, JS decrypts the payload in-browser and renders it.
- **The gotcha**: once a visitor has decrypted the page, they can save the now-decrypted HTML and the images via DevTools. Staticrypt keeps the *site* private, not individual sessions. Acceptable for the family-and-friends use case.
- The unencrypted source (`_src/gallery.html`) must NEVER be committed. The whole point is that `git log` of a public repo doesn't leak the gallery. Put it in `.gitignore` and double-check before the first push.
- The password lives only in the local `.password` file (also gitignored) and in the user's head. **If the user loses it, the gallery cannot be decrypted** — they'd just rebuild and push a new `index.html` with a new password. Make sure the user understands this before publishing.

## DNS setup (lift from 3sstudio.net)

The sister site's DNS recipe at name.com works identically here:

- **Apex** (`sanjayshukla.art`) — A records to the four GitHub Pages IPs:
  - `185.199.108.153`
  - `185.199.109.153`
  - `185.199.110.153`
  - `185.199.111.153`
- **www** (`www.sanjayshukla.art`) — CNAME → `shuklz.github.io`
- **CNAME file in repo** — contains exactly `sanjayshukla.art` (no protocol, no trailing slash). Without this file Pages won't claim the apex.
- GitHub Pages issues the Let's Encrypt cert automatically once DNS resolves. "Enforce HTTPS" checkbox in the repo's Pages settings should be on as soon as it's available.

## Setup tasks (one-time) — all DONE 2026-05-24

All of these were completed during the 2026-05-24 afternoon session. Left here as historical reference / disaster-recovery checklist if the repo ever needs to be re-bootstrapped.

1. ✅ Decisions confirmed: site title `Digital Art by Sanjay Shukla`; single shared password; captions auto-derived from filenames; AVIF+JPG dual output (JPG actually displayed).
2. ✅ Repo initialised: `git init -b main`, `.gitignore` written, folder structure scaffolded.
3. ✅ GitHub repo `shuklz/sanjayshukla.art` confirmed empty; first push succeeded via HTTPS (macOS keychain had cached creds).
4. ✅ DNS wired at name.com: nameservers switched from Google's (`ns-cloud-a1-4.googledomains.com`) to name.com's defaults (`ns1-4.name.com`); 4 A records to `185.199.108-111.153` + 1 CNAME `www` → `shuklz.github.io`. **Propagation in progress as of session end.**
5. ✅ `_src/gallery.html` built — masonry via CSS columns, lightbox borrowed from 3sstudio.net.
6. ✅ `build.sh` written, then extended to also run Staticrypt.
7. ✅ First build verified locally (`python3 -m http.server 8765`); pushed; Pages serves the encrypted gallery (DNS-bypass curl confirmed).
8. ✅ "Add a painting" workflow documented at the top of this file.
9. ✅ `publish.sh` written (2026-05-24 evening): wraps build.sh with auto-tile-insertion + commit + push. End-to-end tested with Ganeshji.png + Hanumanji.png. UPDATE.md rewritten to point at `./publish.sh` as the daily flow (no need to ping Claude for additions).

## Conventions

- **No build step beyond `./publish.sh`.** No Vite, no Webpack, no Next, no React, no Tailwind. Vanilla everything.
- **`publish.sh` uses `git add` on a known file list + `git add -u`** — never `git add .`. Keeps `originals/`, `_src/`, `.password` from leaking even if `.gitignore` has a typo.
- **Image filenames are kebab-case lowercase** in `images/` (`saraswati-veena.jpg`, not `Saraswati Veena.JPG`) — Pages URLs are case-sensitive even though macOS's filesystem isn't. Source files in `originals/` may be CamelCase; `build.sh` does the conversion.
- **`images/` only contains JPG + AVIF + hi-res JPG triples** generated by `build.sh`. Never hand-place files there. Hi-res variants are named `<slug>-hires.jpg`; the lightbox derives the URL by simple replace, so don't break that pattern.
- **Never commit `originals/` or `_src/`** — both are in `.gitignore`. `publish.sh` is careful but verify with `git status` if anything looks off.
- **Don't `git push --force`** — Pages serves whatever's on `main`, and the artist's only off-Mac backup of the *generated site* is what's on GitHub. (This explicitly applies to cleaning up the 3 `Update site` noise commits from 2026-05-24 evening — leave them alone.)

## Carryover patterns from 3sstudio.net

The sister project lives at `/Users/sanjay/Sites/3sstudio.net/`. It's the studio's marketing site, also vanilla HTML/CSS/JS on GitHub Pages. Working patterns worth borrowing:

- **Lightbox structure** — `3sstudio.net/index.html` near the bottom has a shared lightbox (`<div class="lightbox">`) with prev/next/Esc/arrow keys/backdrop-click-to-close. The JS walks `[data-gallery]` elements. Adapt this directly; it's well-tested.
- **Cache-busting** — `<link rel="stylesheet" href="styles.css?v=N">`. Bump `N` whenever CSS changes; Pages' `cache-control: max-age=600` means stale CSS for up to 10 min otherwise.
- **Folder case sensitivity gotcha** — Pages URLs are case-sensitive even on macOS. Use lowercase folder names. To rename for case, two-step it: `mv X X_tmp && mv X_tmp x`.
- **DNS at name.com** — same provider, same recipe (see above).
- **Let's Encrypt cert** — issued automatically by Pages, auto-renewed.

There is otherwise **no shared code** between the two sites and no reason to introduce any. Borrow patterns, don't import files.
