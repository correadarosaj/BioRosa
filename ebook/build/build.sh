#!/usr/bin/env bash
#
# build.sh — Gera o ebook em PDF e EPUB a partir dos capítulos em Markdown.
#
# Requisitos:
#   - pandoc >= 3.0            (conversão markdown -> pdf/epub)
#   - Um engine LaTeX p/ PDF:  tectonic  OU  xelatex (via TeX Live/MiKTeX)
#
# Uso:
#   ./build/build.sh          # gera PDF + EPUB
#   ./build/build.sh pdf      # só PDF
#   ./build/build.sh epub     # só EPUB
#
set -euo pipefail

# Diretório raiz do ebook (pai deste script)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="$ROOT/build/output"
mkdir -p "$OUT_DIR"

META="$ROOT/metadata.yaml"

# Ordena os capítulos pelo prefixo numérico do nome do arquivo.
mapfile -t CHAPTERS < <(find "$ROOT/chapters" -maxdepth 1 -name '*.md' | sort)

if [ ${#CHAPTERS[@]} -eq 0 ]; then
  echo "ERRO: nenhum capítulo encontrado em $ROOT/chapters" >&2
  exit 1
fi

echo "Capítulos encontrados: ${#CHAPTERS[@]}"

# Escolhe engine de PDF disponível
pdf_engine() {
  if command -v tectonic >/dev/null 2>&1; then echo "tectonic"; return; fi
  if command -v xelatex  >/dev/null 2>&1; then echo "xelatex";  return; fi
  echo ""
}

build_html() {
  echo "Gerando HTML ..."
  local css_arg=()
  [ -f "$ROOT/assets/print.css" ] && css_arg=(--css assets/print.css)
  pandoc "$META" "${CHAPTERS[@]}" \
    --from=markdown+smart \
    --standalone --embed-resources \
    --toc --toc-depth=2 \
    --number-sections \
    --top-level-division=chapter \
    --mathml \
    "${css_arg[@]}" \
    -o "$OUT_DIR/do-brasil-ao-fda.html"
  echo "  -> $OUT_DIR/do-brasil-ao-fda.html"
}

# PDF via LaTeX (tectonic/xelatex). Requer bundle LaTeX disponível.
build_pdf_latex() {
  local engine; engine="$(pdf_engine)"
  if [ -z "$engine" ]; then
    echo "AVISO: nenhum engine LaTeX encontrado — use 'pdf' (via Chromium)." >&2
    return 1
  fi
  echo "Gerando PDF com engine LaTeX=$engine ..."
  pandoc "$META" "${CHAPTERS[@]}" \
    --from=markdown+smart --pdf-engine="$engine" \
    --toc --toc-depth=2 --number-sections \
    --top-level-division=chapter \
    -o "$OUT_DIR/do-brasil-ao-fda.pdf"
  echo "  -> $OUT_DIR/do-brasil-ao-fda.pdf"
}

# PDF via Chromium (HTML -> PDF). Portátil, não exige LaTeX.
build_pdf() {
  build_html
  if command -v node >/dev/null 2>&1 && [ -f "$ROOT/build/html2pdf.js" ]; then
    echo "Gerando PDF via Chromium ..."
    node "$ROOT/build/html2pdf.js" \
      "$OUT_DIR/do-brasil-ao-fda.html" \
      "$OUT_DIR/do-brasil-ao-fda.pdf"
  else
    echo "Chromium/node indisponível; tentando LaTeX ..." >&2
    build_pdf_latex
  fi
}

build_epub() {
  echo "Gerando EPUB ..."
  local css_arg=()
  [ -f "$ROOT/assets/epub.css" ] && css_arg=(--css "$ROOT/assets/epub.css")
  local cover_arg=()
  [ -f "$ROOT/assets/cover.png" ] && cover_arg=(--epub-cover-image "$ROOT/assets/cover.png")
  pandoc "$META" "${CHAPTERS[@]}" \
    --from=markdown+smart \
    --toc --toc-depth=2 \
    --number-sections \
    --top-level-division=chapter \
    --split-level=1 \
    --mathml \
    "${css_arg[@]}" "${cover_arg[@]}" \
    -o "$OUT_DIR/do-brasil-ao-fda.epub"
  echo "  -> $OUT_DIR/do-brasil-ao-fda.epub"
}

TARGET="${1:-all}"
case "$TARGET" in
  pdf)  build_pdf ;;
  epub) build_epub ;;
  all)  build_epub; build_pdf ;;
  *) echo "Alvo desconhecido: $TARGET (use: pdf | epub | all)"; exit 1 ;;
esac

echo "Concluído."
