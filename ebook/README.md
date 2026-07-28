# Do Brasil ao FDA — Projeto do Ebook

Guia completo, em português, de **bioestatística clínica para profissionais
brasileiros que querem trabalhar nos Estados Unidos**. Cobre regulamentações
(FDA/ICH/GCP), protocolos de pesquisa clínica, redação de SAP, padrões CDISC
(SDTM/ADaM/Define-XML), produção de TLFs e a estratégia de transição de
carreira.

## Estrutura do projeto

```
ebook/
├── metadata.yaml         # Metadados de publicação (título, autor, ISBN, etc.)
├── README.md             # Este arquivo
├── OUTLINE.md            # Índice mestre / plano de capítulos
├── chapters/             # Um arquivo Markdown por capítulo (ordenados por prefixo NN-)
├── assets/               # CSS do EPUB, capa, imagens
├── templates/            # Templates entregáveis (SAP, shells de TLF, etc.)
└── build/
    ├── build.sh          # Script que gera PDF e EPUB via Pandoc
    └── output/           # Artefatos gerados (PDF/EPUB)
```

## Como gerar o ebook (PDF + EPUB)

Pré-requisitos:

- [Pandoc](https://pandoc.org/) ≥ 3.0
- Para o PDF: [Tectonic](https://tectonic-typesetting.github.io/) **ou** uma
  distribuição LaTeX com `xelatex` (TeX Live / MiKTeX)

```bash
cd ebook
./build/build.sh          # gera PDF + EPUB em build/output/
./build/build.sh epub     # só EPUB
./build/build.sh pdf      # só PDF
```

Instalação rápida do Pandoc + Tectonic (Debian/Ubuntu):

```bash
sudo apt-get install -y pandoc
# Tectonic (engine LaTeX autocontido, sem instalar TeX Live inteiro):
curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
```

## Convenções de escrita

- Um capítulo por arquivo em `chapters/`, nomeado `NN-slug.md` (a ordem de
  compilação segue o prefixo numérico).
- Cada arquivo começa com um cabeçalho de nível 1 (`# Título do capítulo`).
- Termos técnicos em inglês são mantidos no original (ex.: *Statistical
  Analysis Plan*), com tradução/explicação na primeira ocorrência.
- Código em blocos com a linguagem indicada (```r, ```sas).
- Caixas de destaque usam blockquote iniciado por um marcador em negrito:
  `> **Na prática:** ...`, `> **Atenção:** ...`, `> **Glossário PT/EN:** ...`.

## Status de produção

Veja `OUTLINE.md` para o plano completo e o status de cada capítulo.
