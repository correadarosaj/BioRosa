#!/usr/bin/env bash
#
# make-manuscript.sh — Gera o manuscrito editável único (Quarto/Markdown)
# a partir dos capítulos em chapters/. Saída: manuscrito/do-brasil-ao-fda.qmd
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p manuscrito
python3 build/make-manuscript.py
echo "Pronto: manuscrito/do-brasil-ao-fda.qmd"
