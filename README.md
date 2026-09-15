# dotsresearch.github.io

Website for **DOTS Lab** — Dynamics and Observations: Tropopause and Satellites
(對流層頂與衛星探測實驗室), Chinese Culture University, Taipei.
PI: Kai-Wei Chang (張凱威).

Built with [Quarto](https://quarto.org). Bilingual: Traditional Chinese at
the root, English under `/en/`.

## Build

```bash
./build.sh        # or .\build.ps1 on Windows PowerShell
```

Renders both languages into `_site/`. **Order matters** — see `CLAUDE.md`.

## Preview

```bash
quarto preview            # Chinese
quarto preview _en        # English
```

For the full site including the language toggle:

```bash
./build.sh
npx --yes serve _site -l 8080        # -> http://localhost:8080
```

## Publish

```bash
./build.sh
quarto publish gh-pages --no-render
```

See `CLAUDE.md` for site structure, the bilingual rule, and how to add
publications, people, and research.
