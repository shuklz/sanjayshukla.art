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

You don't need Claude for this anymore. Three steps:

1. **Export from iPad** as PNG (and optionally PSD as an editable master).
2. **Drop the file(s) into** `/Users/sanjay/Sites/sanjayshukla.art/originals/`. Rename to whatever you want — CamelCase is best. Examples:
   - `Ganesh.png` + `Ganesh.psd`
   - `Saraswati.png` + `Saraswati.psd`
   - `Hanuman2.png` (a second Hanuman piece) + `Hanuman2.psd`
3. **Open Terminal in the project folder and run:**

   ```bash
   cd /Users/sanjay/Sites/sanjayshukla.art
   ./publish.sh
   ```

That's it. Wait ~30 seconds, refresh `https://sanjayshukla.art/`, and the new paintings will be in the grid.

### What `./publish.sh` actually does (so you know what to expect)

1. Scans `originals/` for any PNG whose slug isn't in the gallery yet, and **appends a tile for each new one** to the gallery source.
2. Runs the image conversion (3 image variants per painting: 2200px JPG for the grid, hi-res JPG up to 5120px for zoom, AVIF backup). Skips files that are already converted.
3. Re-encrypts `index.html`. (If nothing actually changed, it skips this step — so re-running `./publish.sh` with nothing new is a clean no-op.)
4. Commits with a message like `Add painting: Ganesh` or `Add paintings: Ganesh, Saraswati` and `git push`s to GitHub.

### Captions

The painting's caption (what shows under the image in the lightbox) is **auto-derived from the filename**:

| Filename | Auto-caption |
|---|---|
| `RadhaKrishna.png` | Radha Krishna |
| `LordShiva.png` | Lord Shiva |
| `Hanuman2.png` | Hanuman 2 |
| `Lordshiva.png` | Lordshiva *(no internal capital to split on — rename to `LordShiva.png` to fix)* |

If you want a custom caption (longer phrase, em-dash, alternate spelling, etc.), create a one-line text file next to the painting with the same base name and a `.txt` extension:

```
originals/LordShiva2.png       ← the painting
originals/LordShiva2.txt       ← contains: Lord Shiva — stained glass
```

The `.txt` file is read once when the tile is first created (on the next `./publish.sh` run). After that, the caption lives in `_src/gallery.html` and editing the `.txt` won't change it — at that point ask Claude to update the caption, or hand-edit `_src/gallery.html`.

---

## Other things you might want to do

### Share the URL with someone

Send them this, exactly:

> *"Here's a little gallery of my art: https://sanjayshukla.art/  Password: `DigitalArtBySanjayShukla`"*

Tell them: **type the password, hit Enter, then click any painting to view full-screen. Use ← → arrows or the on-screen arrows to walk through; click the +/− buttons or use mouse wheel to zoom in; drag to pan when zoomed; click outside or hit Esc to close.**

### Change the password

If you ever want to rotate it (e.g. shared with too many people, want a new one):

1. Edit the file `.password` in the project folder (it's just a plain text file with one line — the password).
2. Run `./publish.sh`. It detects the password change, re-encrypts `index.html`, commits, and pushes.
3. **Share the new password with whoever you want to still have access.** Old password no longer works the moment the push lands.

### Edit a caption (the name shown under a painting in the lightbox)

Tell Claude: *"Change the caption for `<filename>` to `<new caption>`."*

For brand-new paintings, dropping a `<basename>.txt` next to the PNG before running `./publish.sh` sets the caption (see the "Captions" section above). To change a caption *after* the tile has already been committed, Claude has to edit `_src/gallery.html` directly.

### Remove a painting

Tell Claude: *"Remove `<filename>` from the gallery."*

Claude will:
- Delete the relevant tile from `_src/gallery.html`
- Delete the three files from `images/` (`.jpg`, `-hires.jpg`, `.avif`)
- Run `./publish.sh` to push

(`./publish.sh` only handles *adding* paintings on its own; removals still need Claude.)

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
- **Don't push to GitHub by hand.** `./publish.sh` does the push for you and makes sure `index.html` and `images/` are up to date first. A manual `git push` could ship stale `index.html` (new images wouldn't show) or skip the encryption step entirely.
- **Don't delete `.password`** unless you have it written down somewhere. Without it, `./build.sh` fails. (It's not committed to GitHub either, so it only exists on this Mac — and your memory.)
- **Don't share the GitHub repo URL** publicly. It's a public repo so the encrypted gallery code is readable, but anyone with the URL can also see the file listing in `images/` and download paintings by guessing filenames. Share the **site URL** (`sanjayshukla.art`), not the GitHub one.
- **Don't `git push --force`** or use any "force" git commands. Pages serves whatever's on `main`. Force-push could blow away work that's only on GitHub.
- **Don't click "Unpublish site"** in GitHub Pages settings. That's destructive. The "Remove" button next to the custom domain is also disruptive — only use either if Claude has told you to.

---

## Things that might go wrong, and what to do

### "I dropped a file in `originals/` but my filename has weird characters / spaces / Hindi text."

Probably still works (`build.sh` converts to lowercase kebab-case), but to be safe, rename to plain Latin letters and (optional) numbers. Example: instead of `Lord Shiva (cosmic dance).png`, use `LordShivaCosmicDance.png` or `LordShiva3.png`. Tell Claude if you're unsure.

### "I ran `./publish.sh` but the new painting isn't showing on the live URL."

Common causes:
1. Browser cached the old version — **hard refresh** with `Cmd+Shift+R` on Mac.
2. Pages hasn't finished rebuilding — wait 60 sec, refresh again.
3. The painting file wasn't actually moved to `originals/` — check the folder.
4. `./publish.sh` reported `nothing to push — already up to date.` — that means it found no new PNG in `originals/`. The file might not be a `.png` (it skips `.psd`, `.heic`, `.jpg` sources), or the slug it generated already exists in the gallery.
5. `./publish.sh` errored out — read the last few lines of the output. If it mentions `.password` or `npx`, see the relevant entry below.

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
├── _src/gallery.html   ← The gallery's HTML source. publish.sh auto-appends tiles; otherwise Claude edits.
├── index.html          ← Encrypted gallery (password gate). Built by ./build.sh.
├── styles.css          ← Visual styling. Claude edits when you ask for visual changes.
├── publish.sh          ← The one-button publish. THIS is what you run after dropping new images.
├── build.sh            ← Image conversion + encryption. Called by publish.sh; you don't normally run directly.
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

After `./publish.sh` prints `✓ done. Site updates in ~30 sec...`, verify:

1. Open `https://sanjayshukla.art/` in your browser (Safari if HTTPS still uncertain).
2. Confirm you see the password prompt.
3. Type `DigitalArtBySanjayShukla`.
4. Confirm the gallery loads, your new painting is there.
5. Click it, confirm the lightbox opens and zoom works.

If all four pass, you're good.

---

## When to actually call for help vs handle it yourself

**You can handle yourself:**
- Adding paintings (`./publish.sh`)
- Changing the password (edit `.password`, then `./publish.sh`)
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
