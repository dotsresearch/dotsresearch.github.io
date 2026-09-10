#!/usr/bin/env bash
# Build the full bilingual site into _site/
#
# ORDER IS MANDATORY. Rendering the root project cleans _site/, which
# deletes _site/en. The English project must therefore be rendered SECOND.
set -euo pipefail

echo "==> Rendering Chinese site (root) -> _site/"
quarto render

echo "==> Rendering English site (_en) -> _site/en/"
quarto render _en

echo "==> Done. Both languages are in _site/"
echo "    Publish with: quarto publish gh-pages --no-render"
