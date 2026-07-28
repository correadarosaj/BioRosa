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

build_pdf() {
  local engine; engine="$(pdf_engine)"
  if [ -z "$engine" ]; then
    echo "AVISO: nenhum engine LaTeX (tectonic/xelatex) encontrado — PDF pulado." >&2
    return 0
  fi
  echo "Gerando PDF com engine=$engine ..."
  pandoc "$META" "${CHAPTERS[@]}" \
    --from=markdown+smart \
    --pdf-engine="$engine" \
    --toc --toc-depth=2 \
    --number-sections \
    --top-level-division=chapter \
    -o "$OUT_DIR/do-brasil-ao-fda.pdf"
  echo "  -> $OUT_DIR/do-brasil-ao-fda.pdf"
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
