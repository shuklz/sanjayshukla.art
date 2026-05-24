# sanjayshukla.art — Personal Art Portfolio

Password-gated, display-only personal portfolio of ~50 digital paintings made on iPad. First series is **FAITH** (Mythological Hindu Gods and Goddesses); additional series may follow over time. Site title (locked in 2026-05-24) is **Digital Art by Sanjay Shukla**. Audience is family and friends; the password gate exists so the site stays off Google and out of casual hands, not as a real security boundary.

> **Handoff context**: This file was drafted in a session at `/Users/sanjay/Sites/3sstudio.net/` (the sister project, see "Carryover patterns" below) on 2026-05-24, then moved into this fresh project folder and renamed to `CLAUDE.md`. If the user references "the previous conversation" or "what we already decided", everything decided is captured in the "Decisions locked in" and "Decisions pending" sections below — there is no other context to chase.

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
- **Image policy**: display-only, served at ~2200px wide as lossy **AVIF** (quality ~65, expect ~0.3–0.7 MB each). 50 paintings ≈ 15–35 MB total — comfortable inside Pages' 1 GB soft limit and 100 GB/month bandwidth. (Originally planned as WebP; switched to AVIF on 2026-05-24 because this Mac has neither Homebrew nor `cwebp`, and macOS's built-in `sips` writes AVIF but not WebP. AVIF is also smaller at equivalent quality and well-supported in modern browsers.)
- **Originals never leave the artist's Mac.** They are not committed to git; they live in a gitignored `originals/` folder (or wherever the user puts them — see "Folder layout"). Only the optimised AVIFs go to the repo.
- **Anti-copy deterrents**: right-click context menu disabled, image dragging disabled, CSS `user-select: none`. Acknowledge to the user that none of these prevent screenshots — they're just polite gates. The display-resolution cap is what bounds losses.
- **No CDN dilemma**: the only reason to add R2 / B2 / Cloudinary would be full-resolution downloads, and there are none. GitHub Pages handles everything.
- **Vanilla HTML/CSS/JS, no framework.** Pattern matches 3sstudio.net. **One tiny exception**: Staticrypt is a Node tool that has to run locally to produce the encrypted HTML. That's a one-shell-command "build step" — see "Build pipeline" below. Don't introduce Webpack / Vite / Next / etc.

## Decisions still pending — ask the user before assuming

1. ~~Site title~~ — **RESOLVED 2026-05-24**: **Digital Art by Sanjay Shukla**.
2. **Tagline / one-line description** on the lock screen — something brief about the series? Or leave the gate visually quiet (just title + password field)?
3. **Watermark** — yes / no / what mark? Options: a small low-opacity signature in a corner of each painting (baked in during the build pipeline using ImageMagick/sips), OR a single CSS-overlay watermark on the page (visible but trivially DOM-removable), OR none. User was leaning "decide later" — confirm before shipping.
4. **Password model** — one shared password for everyone (simplest, what user is leaning toward), or several individual passwords (Staticrypt supports it; useful only if you might need to revoke one circle of viewers without disturbing others)?
5. ~~Captions / titles per painting~~ — **RESOLVED 2026-05-24**: user names source files manually (CamelCase like `RadhaKrishna.png` is fine); `build.sh` auto-converts to kebab-case slugs for committed AVIFs and URLs. Optional `<basename>.txt` next to a source image can carry a longer note. **Still open**: should captions show on hover, only in the lightbox, or not at all? (Default for first build: lightbox only.)
6. **Lock-screen wallpaper** — Staticrypt themes are minimal. Want a faded painting behind the gate, or plain background?

## Folder layout (proposed — confirm with user)

```
sanjayshukla.art/                    ← the git repo
├── originals/                       ← gitignored. The user drops iPad exports here.
│   ├── hanuman-meditation.png       ← whatever the iPad app produced (PNG/JPG/TIFF, any size)
│   ├── hanuman-meditation.txt       ← optional. Multi-line note shown under the painting.
│   └── …                            ← ~50 files
├── _src/                            ← gitignored. Unencrypted gallery source — what you edit.
│   └── gallery.html
├── images/                          ← COMMITTED. Generated AVIFs, ~2200px wide.
│   └── hanuman-meditation.avif
├── index.html                       ← COMMITTED. Staticrypt-encrypted gallery + lock screen.
├── styles.css                       ← COMMITTED.
├── CNAME                            ← COMMITTED. Contains: sanjayshukla.art
├── build.sh                         ← COMMITTED. One-command pipeline (resize + encrypt).
├── .gitignore                       ← COMMITTED. Excludes originals/, _src/, .DS_Store
└── CLAUDE.md                        ← this file
```

**Don't deviate from this layout without good reason** — the `build.sh` script and `.gitignore` are calibrated to it.

## Build pipeline (`build.sh`)

One shell script does two things:

1. **Optimise images** — for each file in `originals/`, produce `images/<kebab-case>.avif` at ~2200px wide, quality 65, using macOS's built-in `sips`. Filename is auto-converted to kebab-case (`RadhaKrishna.png` → `radha-krishna.avif`) — see `build.sh` for the exact transform. Skip files where the AVIF is newer than the original. If a watermark is ever enabled, composite during this step (sips can do basic composition; ImageMagick would need installing).
2. **Encrypt the gallery HTML** — run `npx staticrypt _src/gallery.html -p "$PASSWORD" -o index.html --short` (or whatever the current Staticrypt CLI is — verify with `npx staticrypt --help` before assuming flags). `--short` keeps the output a single file. Read the password from a local-only file like `.password` (which MUST be gitignored), or prompt for it.

The user's full workflow becomes:

```bash
# Add new painting:
cp ~/iPad-export.png originals/new-painting.png
./build.sh
git add images/new-painting.avif index.html
git -c user.email=… -c user.name=… commit -m "Add 'New Painting'"
git push
```

Pages rebuilds in ~30 seconds; live within a minute.

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

## Setup tasks (one-time)

When the user fires Claude in the new folder, expect to:

1. **Confirm decisions pending** above (title, watermark, password model, captions, lock-screen visual).
2. **Initialise the repo**: `git init -b main`, scaffold `.gitignore` and the folder structure first.
3. **Confirm the GitHub repo exists.** Run `gh repo view shuklz/sanjayshukla.art` first. If it returns metadata, the user created it in the browser (most likely path — they were given that option at handoff time) and you push to it. If it 404s, ask the user whether they'd like you to create it via `gh repo create shuklz/sanjayshukla.art --public --description "Personal art portfolio — sanjayshukla.art"` or whether they prefer to do it themselves in the browser. **Critical**: the repo must start empty (no README, no .gitignore, no license auto-added by GitHub) so the first local push isn't blocked by an unrelated initial commit. If GitHub auto-seeded anything, deal with it before pushing (`git pull --rebase` and resolve, or delete + recreate empty).
4. **Wire DNS** at name.com per the recipe above. The user does this in their name.com dashboard; Claude provides exact values and verifies with `dig` or `curl` once propagated.
5. **Build the gallery HTML** in `_src/gallery.html` (masonry grid, lightbox JS, anti-copy CSS/JS). Borrow conventions from `3sstudio.net/index.html` — the gallery + lightbox there is a working reference.
6. **Write `build.sh`**.
7. **Run the first build**, verify locally (`python3 -m http.server 8765`), then push.
8. **Document the "add a painting" workflow** at the top of this file (will become the most-read section over time).

## Conventions

- **No build step beyond `./build.sh`.** No Vite, no Webpack, no Next, no React, no Tailwind. Vanilla everything.
- **Commit specific files, not `git add .`** — risk of leaking `originals/` or `.password` if `.gitignore` has a typo.
- **Image filenames are kebab-case lowercase** in `images/` (`saraswati-veena.avif`, not `Saraswati Veena.AVIF`) — Pages URLs are case-sensitive even though macOS's filesystem isn't. Source files in `originals/` may be CamelCase; `build.sh` does the conversion.
- **`images/` only contains AVIFs** generated by `build.sh`. Never hand-place files there.
- **Never commit `originals/` or `_src/`** — verify with `git status` before each push.
- **Don't `git push --force`** — Pages serves whatever's on `main`, and the artist's only off-Mac backup of the *generated site* is what's on GitHub.

## Carryover patterns from 3sstudio.net

The sister project lives at `/Users/sanjay/Sites/3sstudio.net/`. It's the studio's marketing site, also vanilla HTML/CSS/JS on GitHub Pages. Working patterns worth borrowing:

- **Lightbox structure** — `3sstudio.net/index.html` near the bottom has a shared lightbox (`<div class="lightbox">`) with prev/next/Esc/arrow keys/backdrop-click-to-close. The JS walks `[data-gallery]` elements. Adapt this directly; it's well-tested.
- **Cache-busting** — `<link rel="stylesheet" href="styles.css?v=N">`. Bump `N` whenever CSS changes; Pages' `cache-control: max-age=600` means stale CSS for up to 10 min otherwise.
- **Folder case sensitivity gotcha** — Pages URLs are case-sensitive even on macOS. Use lowercase folder names. To rename for case, two-step it: `mv X X_tmp && mv X_tmp x`.
- **DNS at name.com** — same provider, same recipe (see above).
- **Let's Encrypt cert** — issued automatically by Pages, auto-renewed.

There is otherwise **no shared code** between the two sites and no reason to introduce any. Borrow patterns, don't import files.
