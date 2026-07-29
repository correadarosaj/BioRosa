# Estado do projeto — "Do Brasil ao FDA"

> Documento de **handoff / continuidade**. Serve para qualquer pessoa (ou uma
> nova sessão de IA) retomar o projeto com todo o contexto, sem depender de
> conversas anteriores. Mantenha-o atualizado conforme o livro evolui.

## O que é

Ebook em **português do Brasil**: guia de **bioestatística clínica para
profissionais brasileiros que querem trabalhar nos Estados Unidos** (pharma/CRO).
Cobre regulatório (FDA/ICH/GCP/21 CFR Part 11), protocolos, SAP, CDISC
(SDTM/ADaM/Define-XML), TLFs e carreira (vistos, currículo, entrevista, plano de
90 dias). Venda planejada em **Amazon KDP + Hotmart**.

- **Autor:** Joel Corrêa da Rosa, PhD (bioestatístico, 15 anos nos EUA, Mount Sinai).
- **Título:** "Do Brasil ao FDA".

## Estrutura do repositório

```
chapters/        # 32 capítulos .md (NN-slug.md; a ordem segue o prefixo numérico)
templates/       # SAP, shells de TLF, sinopse de protocolo (entregáveis)
assets/          # cover.html + cover.png (1600x2560, KDP), print.css, epub.css
build/           # build.sh (PDF via Chromium + EPUB via Pandoc), make-manuscript.*
manuscrito/      # do-brasil-ao-fda.qmd (livro em arquivo único, para revisão)
metadata.yaml    # metadados de publicação
OUTLINE.md       # índice mestre / plano de capítulos
STYLE.md         # guia de voz, tom e convenções (LER antes de editar)
REVISAO.md       # pontos verificados em fonte oficial + pendências
PUBLICACAO-E-VENDAS.md   # estratégia KDP + Hotmart, texto de vendas, bio curta
FEEDBACK-COLABORADORES.md # template de feedback + mapa de capítulos
```

## Como gerar os artefatos

```bash
cd <raiz-do-repo>
./build/build.sh          # gera PDF (6x9, ~295 págs) e EPUB em build/output/
./build/make-manuscript.sh # regenera o manuscrito único manuscrito/*.qmd
```
Requer `pandoc`; o PDF usa Chromium (via `playwright-core`) — ver `build/html2pdf.js`.

## Convenções (do STYLE.md — respeitar em qualquer edição)

- **Termos técnicos em inglês são mantidos de propósito** (SAP, CDISC, endpoint,
  shell, estimand…); tradução na 1ª ocorrência e no Glossário PT/EN (Apêndice A).
- Caixas de destaque em blockquote: `> **Na prática:**`, `> **Atenção:**`,
  `> **Dica de carreira:**`, `> **Glossário PT/EN:**`, `> **Verificar (fonte):**`.
- Títulos de seção em **português** (com o termo em inglês entre parênteses
  quando for jargão de mercado).
- **Numeração automática só até o 2º nível** (capítulo.seção). O 3º nível não
  recebe número automático (CSS esconde; ver print.css/epub.css). Não reintroduzir
  numeração manual em `##`/`###`.
- Cada capítulo termina com `## Resumo do capítulo`.

## O que já foi feito

- 32 capítulos escritos (~52 mil palavras) + apêndices (glossário ~119 verbetes,
  templates, checklists) + guia de publicação/vendas.
- Fatos regulatórios/imigratórios conferidos em fontes oficiais (jul/2026);
  pontos voláteis marcados com `> **Verificar (fonte):**`.
- **5 iterações** de revisão gramatical de português + padronização de termos
  (não-inferioridade, os TLFs, guideline, p-valor, adendo, e-mail).
- Numeração corrigida para 2 níveis; consolidação de subseções nos caps. **30 e 62**
  (3º nível virou lead-in em negrito).
- Capa gerada; bio do autor inserida; página de rosto e sumário no padrão de livro.
- Migrado do repositório do pacote R (BioRosa) para repositório próprio.

## Pendências

- [ ] **Incorporar o feedback dos colaboradores** (edição em andamento direto no
      GitHub, nos arquivos de `chapters/`).
- [ ] **Consolidar subseções** nos demais capítulos "leves" (candidatos: 10, 13,
      71; avaliar 12, 70, 72 — estes têm subseções que funcionam como âncoras).
      Padrão: transformar `###` curtos em parágrafos com abertura em **negrito**.
- [ ] **ISBN** (gerado no KDP) em `metadata.yaml` e `chapters/00-frontmatter.md`.
- [ ] **Contato/comunidade** em `chapters/93-encerramento.md`.
- [ ] **Revisão de leitura humana final** (idealmente alguém da área).
- [ ] Após edições: **regenerar PDF/EPUB** e rodar **QC de numeração/consistência**.
- [ ] Setup do repo: **GitHub Pages** (workflow `.github/workflows/pages.yml`) e
      **colaboradores** (Settings → Collaborators, Write).

## Como continuar numa sessão de IA nova (apontada para este repo)

Peça algo como: *"Leia STYLE.md, REVISAO.md e OUTLINE.md; incorpore as edições
dos colaboradores; regenere PDF/EPUB; rode uma passada de revisão gramatical e a
checagem de numeração nos capítulos alterados; commit e push."*
