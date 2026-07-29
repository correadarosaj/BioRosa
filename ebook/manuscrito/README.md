# Manuscrito editável — para colaboradores

Este diretório contém o livro inteiro em **um único arquivo editável**:

- **`do-brasil-ao-fda.qmd`** — o manuscrito completo (~54 mil palavras, 32
  capítulos) em **Markdown/Quarto**. É só texto: abra em qualquer editor
  (VS Code, Typora, Obsidian, RStudio, Bloco de Notas) e edite direto.

## Como os colaboradores editam

1. Abra `do-brasil-ao-fda.qmd` no editor de sua preferência.
2. Edite o texto normalmente. Para **comentar sem alterar**, use um comentário
   HTML: `<!-- REVISOR: sua observação -->`.
3. **Não apague** as linhas marcadoras de capítulo:
   `<!-- ===== chapters/30-anatomia-protocolo.md ===== -->` — elas dizem de qual
   arquivo veio cada trecho e permitem reintegrar as edições ao projeto.
4. Devolva o arquivo editado (ou o diff), que as mudanças são reincorporadas aos
   capítulos individuais em `../chapters/`.

## Renderizar (opcional)

Com [Quarto](https://quarto.org) instalado:

```bash
quarto render do-brasil-ao-fda.qmd --to pdf     # ou html, docx
```

O cabeçalho YAML do arquivo já define PDF, HTML e Word (docx), com numeração
automática até o 2º nível (`number-depth: 2`).

> Sem Quarto, também renderiza com Pandoc:
> `pandoc -f markdown do-brasil-ao-fda.qmd -o saida.docx`

## Fonte canônica

A fonte "oficial" do livro continua sendo os arquivos individuais em
`../chapters/*.md` (é de lá que saem o PDF e o EPUB de produção, via
`../build/build.sh`). Este `.qmd` é um **instantâneo combinado** gerado para a
rodada de revisão — depois de incorporar o feedback, ele pode ser regenerado.
Para evitar divergência, **edite em um lugar por vez**: durante a revisão dos
colaboradores, edite aqui; a reintegração aos `chapters/` é feita em seguida.
