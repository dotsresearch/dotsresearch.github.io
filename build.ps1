# Build the full bilingual site into _site/
#
# ORDER IS MANDATORY. Rendering the root project cleans _site/, which
# deletes _site/en. The English project must therefore be rendered SECOND.
# Never run a bare `quarto render` on its own and then publish — that ships
# a site with no /en/. Always use this script.

$ErrorActionPreference = "Stop"

Write-Host "==> Rendering Chinese site (root) -> _site/" -ForegroundColor Cyan
quarto render
if ($LASTEXITCODE -ne 0) { throw "Root render failed" }

Write-Host "==> Rendering English site (_en) -> _site/en/" -ForegroundColor Cyan
quarto render _en
if ($LASTEXITCODE -ne 0) { throw "English render failed" }

Write-Host "==> Done. Both languages are in _site/" -ForegroundColor Green
Write-Host "    Publish with: quarto publish gh-pages --no-render"
