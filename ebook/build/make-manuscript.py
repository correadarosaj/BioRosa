#!/usr/bin/env python3
"""Gera manuscrito/do-brasil-ao-fda.qmd combinando chapters/*.md em ordem.

Preserva marcadores de origem (<!-- ===== chapters/NN-slug.md ===== -->) para
permitir reintegrar edições dos colaboradores aos capítulos individuais.
"""
import glob

YAML = '''---
title: "Do Brasil ao FDA"
subtitle: "Guia Completo de Bioestatística Clínica para Profissionais Brasileiros que Querem Trabalhar nos Estados Unidos — Regulamentações, Protocolos, SAP, CDISC e TLFs"
author: "Joel Corrêa da Rosa, PhD"
date: "2026"
lang: pt-BR
toc: true
toc-depth: 2
number-sections: true
number-depth: 2
format:
  html:
    theme: cosmo
    embed-resources: true
  pdf:
    documentclass: scrreprt
    geometry: "margin=2.5cm"
  docx: default
---
'''

NOTE = '''
<!--
========================================================================
INSTRUÇÕES AOS REVISORES / COLABORADORES

• Este é o manuscrito COMPLETO em um único arquivo, em Markdown/Quarto (.qmd).
  Edite diretamente em qualquer editor de texto.

• Para comentar sem alterar o texto: <!-- REVISOR: sua observação aqui -->

• NÃO altere as linhas de marcação de capítulo, do tipo:
      <!-- ===== chapters/30-anatomia-protocolo.md ===== -->
  Elas permitem reintegrar suas edições ao projeto depois.

• Convenções do livro (mantenha): termos técnicos em inglês são mantidos de
  propósito; caixas de destaque começam com > **Na prática:** etc.; numeração
  automática só até o 2º nível.

• Renderizar (opcional; requer Quarto — quarto.org):
      quarto render do-brasil-ao-fda.qmd --to pdf     # ou html, docx
========================================================================
-->
'''


def main():
    chapters = sorted(glob.glob('chapters/[0-9]*.md'))
    parts = [YAML, NOTE]
    for f in chapters:
        parts.append(f'\n\n<!-- ===== {f} ===== -->\n')
        parts.append(open(f, encoding='utf-8').read().rstrip() + '\n')
    with open('manuscrito/do-brasil-ao-fda.qmd', 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(parts))
    print(f'capítulos incluídos: {len(chapters)}')


if __name__ == '__main__':
    main()
