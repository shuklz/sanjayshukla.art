# Site update manual — sanjayshukla.art

This is your reference for adding paintings, sharing the URL, changing the password, and handling anything else day-to-day. Written for you, not for Claude.

---

## Quick reference

| Thing | Value |
|---|---|
| **Live URL** | `https://sanjayshukla.art/` |
| **Password** | `DigitalArtBySanjayShukla` |
| **GitHub repo** | `https://github.com/shuklz/sanjayshukla.art` |
| **Project folder on Mac** | `/Users/sanjay/Sites/sanjayshukla.art/` |
| **Pages settings** | `https://github.com/shuklz/sanjayshukla.art/settings/pages` |

---

## The single most important rule

**You only ever touch two folders: `originals/` and (rarely) the project root.**

- `originals/` — drop your iPad exports here (PNG and/or PSD). Stays on your Mac. Never goes to GitHub.
- `images/` — **never touch by hand.** This is build output. Claude/`build.sh` writes here.
- `_src/` — also never touch. Source for the gallery HTML. Stays on your Mac.

If you remember just this rule, you can't break much.

---

## Adding a new painting (the daily flow)

### What YOU do

1. **Export the painting from your iPad app** as PNG (and optionally PSD if you want an editable master).
2. **Drop both files into** `/Users/sanjay/Sites/sanjayshukla.art/originals/`. Rename them to whatever you want — CamelCase is fine. Examples:
   - `Ganesh.png` + `Ganesh.psd`
   - `Saraswati.png` + `Saraswati.psd`
   - `Hanuman2.png` (a second Hanuman piece) + `Hanuman2.psd`
3. **Open Claude Code** in the project folder and say something like:

   > *"Added 2 new paintings — Ganesh and Saraswati. Please do the rest."*

   Or even shorter:
   > *"New art in originals. Please publish."*

That's it on your end.

### What CLAUDE will do (so you can check)

1. List `originals/` to see what's new.
2. Run `./build.sh` — which:
   - Resizes each PNG to make the 3 image variants in `images/` (a 2200px JPG for the gallery, a higher-resolution JPG up to 5120px for zoom, an AVIF backup)
   - Encrypts the gallery HTML and writes the new `index.html`
3. Edit `_src/gallery.html` to add a tile (and corresponding lightbox entry) for each new painting.
4. Re-run `./build.sh` so the encrypted `index.html` includes the new tiles.
5. `git commit` with a clear message and `git push`.
6. Tell you "live in ~30 seconds at `https://sanjayshukla.art/`".

You then refresh the URL. New paintings appear in the grid. Done.

> **TODO for next session**: Claude can extend `build.sh` to auto-generate the tile markup, so step 3 becomes automatic and you don't even need to ping Claude — just `./build.sh` + commit + push. Worth doing once you've added a few paintings the manual way and the pattern is clear.

---

## Other things you might want to do

### Share the URL with someone

Send them this, exactly:

> *"Here's a little gallery of my art: https://sanjayshukla.art/  Password: `DigitalArtBySanjayShukla`"*

Tell them: **type the password, hit Enter, then click any painting to view full-screen. Use ← → arrows or the on-screen arrows to walk through; click the +/− buttons or use mouse wheel to zoom in; drag to pan when zoomed; click outside or hit Esc to close.**

### Change the password

If you ever want to rotate it (e.g. shared with too many people, want a new one):

1. Edit the file `.password` in the project folder (it's just a plain text file with one line — the password).
2. Tell Claude: *"Changed the password. Please rebuild and push."*
3. Claude runs `./build.sh` (which re-encrypts with the new password) and pushes.
4. **Share the new password with whoever you want to still have access.** Old password no longer works the moment the push lands.

### Edit a caption (the name shown under a painting in the lightbox)

Tell Claude: *"Change the caption for `<filename>` to `<new caption>`."*

Captions today are auto-derived from filenames (`RadhaKrishna.png` → "Radha Krishna"). Custom captions need a small edit to `_src/gallery.html` — Claude will do it.

### Remove a painting

Tell Claude: *"Remove `<filename>` from the gallery."*

Claude will:
- Delete the relevant tile from `_src/gallery.html`
- Delete the three files from `images/` (`.jpg`, `-hires.jpg`, `.avif`)
- Re-build and push

You can also leave the source files in `originals/` (since `originals/` is gitignored, it doesn't affect the site) or delete them yourself — your choice.

### Tweak the look (border, mat color, background, fonts, etc.)

Tell Claude what you want changed in plain words:

> *"Make the mat slightly lighter — currently it's almost black, I want it a touch more visible against the gallery background."*

> *"The gold border is too bright. Tone it down."*

> *"Can the title at the top be smaller and pushed to the left instead of center?"*

Claude edits `styles.css`, re-builds, pushes. Done in a minute or two.

### Add a whole new series (e.g., NATURE, PORTRAITS — alongside FAITH)

This is bigger. Tell Claude: *"I want to add a new series called X. Help me organize."*

Claude will probably suggest reorganizing the gallery into sections (or creating a small landing page that links to per-series gallery pages). It's a 30-min change, not a 5-min change. Worth doing thoughtfully when you actually have the second series ready, not before.

---

## What NOT to do

- **Don't manually edit anything in `images/`.** `build.sh` overwrites it. Your edits will vanish.
- **Don't push to GitHub without running `./build.sh` first.** You'd push stale `index.html` and the new images wouldn't show.
- **Don't delete `.password`** unless you have it written down somewhere. Without it, `./build.sh` fails. (It's not committed to GitHub either, so it only exists on this Mac — and your memory.)
- **Don't share the GitHub repo URL** publicly. It's a public repo so the encrypted gallery code is readable, but anyone with the URL can also see the file listing in `images/` and download paintings by guessing filenames. Share the **site URL** (`sanjayshukla.art`), not the GitHub one.
- **Don't `git push --force`** or use any "force" git commands. Pages serves whatever's on `main`. Force-push could blow away work that's only on GitHub.
- **Don't click "Unpublish site"** in GitHub Pages settings. That's destructive. The "Remove" button next to the custom domain is also disruptive — only use either if Claude has told you to.

---

## Things that might go wrong, and what to do

### "I dropped a file in `originals/` but my filename has weird characters / spaces / Hindi text."

Probably still works (`build.sh` converts to lowercase kebab-case), but to be safe, rename to plain Latin letters and (optional) numbers. Example: instead of `Lord Shiva (cosmic dance).png`, use `LordShivaCosmicDance.png` or `LordShiva3.png`. Tell Claude if you're unsure.

### "I told Claude to publish but the new painting isn't showing on the live URL."

Common causes (Claude will check these too):
1. Browser cached the old version — **hard refresh** with `Cmd+Shift+R` on Mac.
2. Pages hasn't finished rebuilding — wait 60 sec, refresh again.
3. The painting file wasn't actually moved to `originals/` — check the folder.

### "The site doesn't load at all — `sanjayshukla.art` is blank or shows an error."

1. **`Your connection is not private` / cert warning in Chrome?** — the TLS cert may still be in the slow issuance process (was happening as of 2026-05-24). Try Safari, which is more forgiving. Or wait a few hours and try Chrome again.
2. **Site is down for everyone?** — check `https://www.githubstatus.com/`. If GitHub Pages is having an outage, just wait.
3. **Site is down only for you?** — try a phone on cellular data (different network). If it works there, your wifi/router is caching DNS poorly; restart router or wait.

### "I forgot the password."

It's in this file at the top, in CLAUDE.md, in `.password` on the Mac, and (hopefully) in your password manager. If somehow it's lost from all of those, Claude can pick a new one and rebuild — but everyone you shared the old one with would need the new one.

---

## What's in this project (so you know what each file is)

```
sanjayshukla.art/
├── originals/          ← YOU. Drop iPad exports (PNG/PSD) here. Stays on Mac.
├── images/             ← BUILD OUTPUT. JPG + hi-res JPG + AVIF per painting. Don't touch.
├── _src/gallery.html   ← The gallery's HTML source. Don't touch (Claude edits it).
├── index.html          ← Encrypted gallery (password gate). Built by ./build.sh.
├── styles.css          ← Visual styling. Claude edits when you ask for visual changes.
├── build.sh            ← The build script. You don't run it; Claude does.
├── CNAME               ← Tells GitHub Pages the custom domain is sanjayshukla.art.
├── robots.txt          ← Asks search engines not to index. Don't touch.
├── favicon.svg/.ico    ← The little tab icon. The gold "S".
├── .password           ← Your gallery password, plain text. Stays on Mac, never committed.
├── .gitignore          ← Tells git which files to never commit.
├── .staticrypt.json    ← Encryption salt. Auto-generated.
├── CLAUDE.md           ← Instructions for Claude (the AI).
└── UPDATE.md           ← This file (instructions for you).
```

---

## Sanity check before you wrap each session

After Claude says "pushed", you can verify with:

1. Open `https://sanjayshukla.art/` in your browser (Safari if HTTPS still uncertain).
2. Confirm you see the password prompt.
3. Type `DigitalArtBySanjayShukla`.
4. Confirm the gallery loads, your new painting is there.
5. Click it, confirm the lightbox opens and zoom works.

If all four pass, you're good.

---

## When to actually call for help vs handle it yourself

**You can handle yourself:**
- Adding/removing paintings
- Sharing the URL
- Browser cache issues (hard refresh)

**Ask Claude:**
- Anything visual (border, colors, layout, fonts, sizing)
- Captions, titles, lock-screen copy
- Password change
- Adding a new series
- Anything you're not sure about — there's no penalty for asking

**Ask Claude with screenshot:**
- The site is broken in some weird way
- A specific painting looks wrong
- The Pages settings page shows an error

---

*This manual lives in the repo so you can read it on your phone via `https://github.com/shuklz/sanjayshukla.art/blob/main/UPDATE.md`.*
