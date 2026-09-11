# CLAUDE.md — PAUSE Lab website

Quarto website for **PAUSE Lab** (Processes At the UTLS and Satellite
Exploration / 對流層頂過程與衛星探測實驗室), an atmospheric science group at
Chinese Culture University (PCCU), Taipei, led by Kai-Wei Chang (張凱威).

Published at <https://pauselab.github.io> from the `gh-pages` branch.

---

## 1. Layout: two Quarto projects, one output tree

```
.                     Chinese project  (_quarto.yml,     lang: zh-Hant) -> _site/
├── _en/              English project  (_en/_quarto.yml, lang: en)      -> _site/en/
├── images/           shared images    (root only — never duplicated into _en/)
│   ├── gallery/      gallery figures
│   ├── tools/        screenshots of live tools
│   └── people/       member photos
├── styles.scss       shared SCSS theme (root only)
├── publications.bib  shared bibliography (root only)
├── pause-lab.csl     shared citation style (root only)
├── build.ps1 / build.sh
└── _site/            build output (gitignored)
```

**Why two projects and not one?** A Quarto navbar is a *website-level*
setting — it cannot vary per subdirectory. One project therefore cannot give
the English pages an English navbar. Two sibling projects writing into one
output tree is what makes the bilingual navbar possible.

`_en/` starts with an underscore **on purpose**: Quarto unconditionally
ignores `_`-prefixed directories, so the root render can never pick up the
English sources. Do not rename it to `en/`.

## 2. Bilingual rule (the one that matters)

**Every content change must be made twice** — once in the root `.qmd` and
once in the matching `_en/*.qmd`. The two trees are mirrors:

| Chinese (default)  | English                |
| ------------------ | ---------------------- |
| `index.qmd`        | `_en/index.qmd`        |
| `research.qmd`     | `_en/research.qmd`     |
| `people.qmd`       | `_en/people.qmd`       |
| `publications.qmd` | `_en/publications.qmd` |
| `gallery.qmd`      | `_en/gallery.qmd`      |

Keep the same headings, same section order, and the same `[TODO: ...]`
markers in both. If you add a page, add it to **both** trees *and* to both
navbars in `_quarto.yml` and `_en/_quarto.yml`.

Chinese is Traditional (zh-Hant), not Simplified.

**Do not remove the `language:` block in `_quarto.yml`.** Quarto keeps its
Traditional Chinese interface strings under the `zh-TW` locale, but pandoc
only recognises `zh-Hant` — setting `lang: zh-TW` makes pandoc warn on every
render, while `lang: zh-Hant` alone silently falls back to Quarto's
*Simplified* `zh` strings ("搜索", "已复制", "匹配的文档"). The block keeps
`lang: zh-Hant` and overrides the visible interface strings with the values
from Quarto's own `_language-zh-TW.yml`.

## 3. Shared assets — root only

`styles.scss`, `publications.bib`, `pause-lab.csl`, and `images/` exist
**once**, at the repo root. Never copy them into `_en/`. The English project
reaches them like this:

- theme → `theme: [cosmo, ../styles.scss]` (relative, in `_en/_quarto.yml`)
- bibliography → `bibliography: ../publications.bib` (relative)
- citation style → `csl: ../pause-lab.csl` (relative)
- images → `/images/...` (**site-absolute**, works from both trees)

Only the root `_quarto.yml` has `resources: [images/]`, which is what copies
`images/` into `_site/`.

## 4. Two footguns

**(a) Render order is mandatory.** Rendering the root project *cleans*
`_site/`, which deletes `_site/en`. So the root must be rendered **first**
and `_en` **second**. Always build with `./build.sh` (or `.\build.ps1`), never
with a bare `quarto render` followed by a publish — that ships a site with no
`/en/`.

**(b) The English → Chinese toggle must be `../`, not `/`.** Quarto resolves
a leading `/` against *the current project's* root, which for `_en/` is
`/en/` — so `href: /` would link the English site back to itself. The root →
English toggle is `href: /en/`, which is correct because the root project's
root is the site root.

The toggles are hardcoded navbar links; there is no Quarto i18n feature doing
this. They are styled in `styles.scss` by an attribute selector on `href`,
because Quarto navbar items accept no custom CSS class.

## 5. Build, preview, publish

```bash
./build.sh                 # or .\build.ps1 — renders BOTH languages into _site/
quarto preview             # Chinese only, live reload
quarto preview _en         # English only, live reload
```

`quarto preview` runs one project at a time, so the language toggle and the
absolute `/images/...` paths only resolve correctly against a full build.
To exercise the whole site, build and serve `_site/`:

```bash
./build.sh
npx --yes serve _site -l 8080        # -> http://localhost:8080
# or, with a real Python on PATH:  python -m http.server -d _site 8080
```

Publish (from a clean full build):

```bash
./build.sh
quarto publish gh-pages --no-render
```

`--no-render` is **required**. Without it Quarto renders only the root
project and publishes a site missing `/en/`.

## 6. How to add content

**A publication** — add a BibTeX entry to `publications.bib`. That is all.
Both publication pages use `nocite: '@*'`, which renders every entry in the
file, so neither `.qmd` needs editing and there is no per-language list to
keep in sync. Copy one of the existing entries as a template.

Submitted or in-review work goes in as `@unpublished` with
`note = {Manuscript submitted}`; move it to `@article` once it is accepted.
The note is printed in place of the journal name.

Two rules for entries, both explained in §9:

- **Write titles in sentence case** (AMS style), capitalising the first word
  after a colon.
- **Brace-protect proper nouns** — `{North American}`, `{Darwin}`,
  `{United States}`. Citeproc sentence-cases titles, so an unprotected proper
  noun renders lowercased ("north american monsoon"). Acronyms in caps (ERA5,
  UTLS) survive on their own.

Use AMS journal abbreviations in the `journal` field (`J. Atmos. Sci.`, not
`Journal of the Atmospheric Sciences`) — the style cannot abbreviate for you.

Give every published entry **both** `doi` and `url`, where `url` is just
`https://doi.org/` plus the DOI:

```
  doi={10.1175/JAS-D-21-0009.1},
  url={https://doi.org/10.1175/JAS-D-21-0009.1}
```

The redundancy is deliberate — see §9 for why the style prints `url` rather
than `doi`. Verify the DOI against Crossref rather than reconstructing it;
only Copernicus (`10.5194/acp-VOL-PAGE-YEAR`), MDPI
(`10.3390/<journal><vol><issue><article>`) and AGU (`10.1029/<article id>`)
are derivable, and AMS and Wiley DOIs are not. `@unpublished` entries have
neither field.

**A person** — copy a `.person-card` block in `people.qmd` *and*
`_en/people.qmd`, under the right heading. Only the two staffed headings
exist (主持人 / 研究助理 — Principal investigator / Research staff); the
empty 研究生, 大學部專題生 and 畢業與離任成員 sections were deliberately
removed rather than left standing empty, so add a heading back when there is
somebody to put under it — in **both** trees. A card holds, in order: an optional
`.person-photo` image, `.person-name`, `.person-role`, an optional
`.person-exp` (prior appointments, newest first), an optional
`.person-edu` (a plain markdown list, one degree per line, newest first), an
optional `.person-links`, and an optional `.person-bio`.

Put the photo in `images/people/` and reference it as
`/images/people/name.jpg`. Nobody has a photo yet, so both existing cards
carry their `<img>` line commented out — uncomment it once the file exists,
rather than leaving the page pointing at a missing image.

**News** — there is deliberately no news section or news page. It was removed
from the home pages on request. Do not add one back unless asked.

**A gallery figure** — drop the image in `images/gallery/`, then copy one
`<figure class="gallery-item">` block in `gallery.qmd` *and*
`_en/gallery.qmd` (the image file itself is shared, so it is added once).
The grid is plain CSS with `auto-fill` — it reflows on its own, and there is
no glob, listing, or R/Python dependency to keep working.

**A live tool** — a `.tool-card` in `research.qmd` *and* `_en/research.qmd`:
a screenshot, `.tool-name`, `.tool-desc`, and a `.tool-link` pill pointing at
the running app. Screenshots go in `images/tools/`. The card is stacked, not
two-column, so it degrades to a text-only card while the screenshot is still
missing — which is why both `<a><img>` lines currently sit commented out.

The ATMS card points at a **bare IP with a self-signed certificate**
(`https://140.137.32.73:8050/`), so visitors get a browser interstitial
before the app loads. Replacing it with a real hostname is one URL edit per
language file — four occurrences total, two of them inside the commented-out
`<img>` links.

**A research theme** — add a `##` section to `research.qmd` and
`_en/research.qmd`, and, if it should be featured, a matching
`.research-card` on both home pages. The home page shows a *subset*: 軌跡模擬
/ Trajectory modeling is a research section with no home-page card. The two
home pages must still carry the same cards as each other.

## 7. Placeholder convention

Unwritten content is marked with a literal `[TODO: ...]` in the page text.
**Do not invent research descriptions, people, publications, titles, or
news.** Leave the marker until a human supplies real content.

List everything outstanding:

```bash
grep -rn "TODO" --include="*.qmd" --include="*.bib" .
```

Member details on both `people.qmd` pages were taken from the lab's Google
Site (<https://sites.google.com/view/dots-pccu>), a separate, older site under
the name **DOTS**. The English degree lines are translations of the Chinese
originals, so the official English department names are worth a check.
`_en/people.qmd` carries an HTML-comment TODO on 鍾佳慧's English given name:
only the initials `C.-H.` are confirmed, from the manuscript author list.

## 8. Design

`styles.scss` is a Bootstrap `cosmo` override with a `scss:defaults` block
(palette, type scale, navbar variables) and a `scss:rules` block (component
styles). Palette: dusk `#0d1b2e` (navbar, footer, top of the home hero),
slate ink `#1b2a3a`, muted `#5f7183`, tropopause teal `#2b8aa8`, spare
sunrise gold `#d4a054` (hero eyebrow, 3px horizon, language-toggle hover —
never body-link colour), cool paper `#f3f7fa` with white cards. Type:
Inter + Noto Sans TC from Google Fonts, imported at the top of
`scss:defaults` — Noto Sans TC is what makes the Chinese pages render
properly, so keep it in the stack.

Atmospheric rather than flat: the home hero is a dusk-to-teal CSS gradient
(no image), navbar and footer are dusk bookends, and cards may use a soft
hover lift. No heavy drop shadows. Gold is decoration only. Both
`_quarto.yml` files set `navbar.background: dark` so search and the
hamburger stay light on dusk. Component classes: `.hero`, `.card-grid` +
`.research-card`, `.people-grid` + `.person-card` (with `.person-photo`,
`.person-name`, `.person-role`, `.person-exp`, `.person-edu`,
`.person-links`, `.person-bio`), `.gallery-grid` + `.gallery-item`, `.tool-card` (with
`.tool-shot`, `.tool-name`, `.tool-desc`, `.tool-link`), `.cta-link`.

`.people-grid` deliberately uses `auto-fit` with a **capped** max track
(`minmax(min(260px, 100%), 330px)`), not `auto-fill` with `1fr`. `auto-fill`
keeps empty phantom tracks, which pins a lone card — the PI, alone in a
section — to one narrow column and shreds the degree lines; an uncapped `1fr`
swings the other way and stretches a single card across the page. The cards
also set `word-break: keep-all` on the name, role, and degree list, because
CSS otherwise breaks Chinese between any two characters and splits an
institution name mid-word. `.person-bio` is excluded on purpose: running
Chinese prose does need to break anywhere.

Note that a Pandoc fenced div wrapping a heading (`::: {.research-card}` with
a `###` inside) emits `<section class="level3 research-card">`, not a `<div>`.
The class still lands, so class selectors work — just avoid selectors that
assume a `div` element.

`index.qmd` and `gallery.qmd` use `page-layout: full`, capped to 1080px in
`styles.scss`, with prose held to a 44rem measure. The other pages use
Quarto's default article layout.

## 9. Citation style

`pause-lab.csl` is a hand-written CSL 1.0 style implementing **American
Meteorological Society** reference format, used by both publications pages:

> Chang, K.-W., K. P. Bowman, L. W. Siu, and A. D. Rapp, 2021: Convective
> forcing of the North American monsoon anticyclone at intraseasonal and
> interannual time scales. *J. Atmos. Sci.*, **78**, 2941–2956.

Author, year, colon, sentence-case title, abbreviated italic journal, volume,
pages. AMS omits the issue number, so the CSL ignores `number` even though the
`.bib` still carries it. Seven or more authors collapse to "and Coauthors",
per AMS.

It departs from stock AMS in three deliberate ways:

1. **Sorted newest first** (`<key variable="issued" sort="descending"/>`),
   rather than alphabetically by author — alphabetical buries recent work.
2. **Submitted work sorts above published work of the same year** (the
   `submitted-first` macro) and prints its `note` field where the journal
   would go.
3. **The DOI is printed from the `url` variable, not `doi`.** Pandoc
   hyperlinks whatever the style renders here. Rendering `doi` with a
   `https://doi.org/` prefix puts that prefix *outside* the anchor, so only
   the identifier is clickable and underlined — it looks like a bug.
   Rendering `url`, which already holds the whole URL, gives one clean link.
   If an entry has no `url`, pandoc falls back to hyperlinking the *title*
   instead, which still works but makes that entry look different from the
   rest — so keep `url` on every published entry.

If you swap in a stock AMS style from the CSL repository, all three behaviours
disappear and the page silently reorders.

### Keep the two languages rendering identically

References are English regardless of page language, but citeproc follows the
document's `lang`, so the Chinese page will quietly diverge unless two things
hold:

- The `<locale>` block in `pause-lab.csl` has **no `xml:lang` attribute**, so
  its terms apply to every locale. Without it the Chinese page renders 和 for
  "and", 等 for "and Coauthors", and `2941～2956` for page ranges.
- **Titles in `publications.bib` are stored in sentence case already**, with
  proper nouns brace-protected. Pandoc only sentence-cases titles for English
  documents, so a Title Case entry renders title-cased on the Chinese page and
  sentence-cased on the English one. AMS capitalises the first word after a
  colon — write it capitalised and brace-protected (`{A} 45-year ...`).

After changing the bibliography or the style, confirm the two agree:

```bash
diff <(awk '/id="ref-/{f=1} f' _site/publications.html    | sed 's/<[^>]*>//g' | grep -v '^\s*$') \
     <(awk '/id="ref-/{f=1} f' _site/en/publications.html | sed 's/<[^>]*>//g' | grep -v '^\s*$')
```
