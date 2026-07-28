# Estado de revisão para publicação

## ✅ Verificação factual — concluída (jul/2026)

Os 12 pontos que antes estavam marcados como incertos foram **pesquisados em
fontes oficiais e incorporados ao texto** com a informação vigente em julho de
2026. Resumo do que foi confirmado e onde:

| Tema | Fato incorporado | Capítulo |
|---|---|---|
| ICH E6(R3) | Finalizada pelo ICH em jan/2025; FDA adotou o final em set/2025; EMA efetiva em 23/jul/2025 | `21` |
| Single pivotal study | Permitido desde o FDAMA (1997); documento vigente é **draft revisado de jun/2026** (não final) | `20` |
| 21 CFR Part 11 | Guidance final do FDA de out/2024 (Electronic Systems/Records/Signatures Q&A) substitui a de 2007 | `22` |
| Não-inferioridade | Guidance final do FDA de nov/2016; métodos fixed-margin (95-95) e synthesis | `31` |
| Nº de eventos | Fórmulas de Schoenfeld e Freedman (Freedman ligeiramente mais conservadora) | `33` |
| PHUSE × SAP template | PHUSE = white papers "Analyses & Displays" + phuse-scripts; template de SAP em si é da TransCelerate | `41` |
| Formato de submissão | SAS XPORT v5 (.xpt); Define-XML v2.1; SDTMIG/sdTCG v6.0 (2025); Dataset-JSON ainda em piloto | `53` |
| Salários | Ancorados no BLS (SOC 15-2041: mediana US$ 103.300, mai/2024); faixas de mercado como ordem de grandeza | `11` |
| H-1B | Cap 65k+20k; registro beneficiary-centric (FY2025); **taxa US$ 100k de set/2025 sob litígio**; regra wage-based (FY2027) — tudo marcado como "em fluxo" | `12` |
| OPT/STEM OPT | 12 + 24 = 36 meses; Estatística/Bioestatística são STEM (CIP 27) | `12` |
| Credential evaluation | Usar avaliador membro da **NACES** (ex.: WES, ECE) | `12` |
| EB-2 NIW / O-1 | Descritos corretamente (NIW permite autopetição; O-1 exige patrocinador; caso a caso) | `12` |

> **Nota:** os poucos `> **Verificar (fonte):**` que permanecem no texto agora são
> **lembretes de manutenção** — apontam para a fonte oficial a checar em futuras
> edições (regras regulatórias e de imigração mudam). Não são lacunas factuais.
> Em especial, **imigração (cap. 12)** mantém, em todas as caixas, a orientação
> de **consultar um advogado licenciado** — 7 avisos ao todo.

## ✅ Capa — concluída

- `assets/cover.png` (1.600 × 2.560 px, padrão KDP) gerada a partir de
  `assets/cover.html`. Para editar, ajuste o HTML e rode
  `node build/render-cover.js assets/cover.html assets/cover.png`.
- **Falta:** trocar `[Seu Nome]` na capa pelo seu nome real.

## ✅ Build — PDF e EPUB funcionando

- `./build/build.sh` gera **EPUB** (com capa embutida) e **PDF** (formato de
  livro 6×9", via Chromium). Artefatos em `build/output/`.

## ⬜ Pendências que dependem de você

Estas são pessoais/administrativas — não posso preenchê-las por você:

- [ ] **Nome do autor** — substituir `[Seu Nome — preencher]` / `[Seu Nome]` em:
      `metadata.yaml`, `chapters/00-frontmatter.md`, `chapters/01-sobre.md`
      (seção "Sobre o autor") e `assets/cover.html` (depois re-renderizar a capa).
- [ ] **Bio "Sobre o autor"** — escrever 2–4 parágrafos em `chapters/01-sobre.md`.
- [ ] **ISBN** — gerado gratuitamente no KDP ao publicar; inserir em
      `metadata.yaml` e `chapters/00-frontmatter.md`.
- [ ] **Contato/comunidade** — preencher em `chapters/93-encerramento.md`.
- [ ] **Revisão de leitura humana final** — uma passada de alguém da área é o
      último selo de qualidade antes de vender.
- [ ] **Decisões de publicação** — preço, KDP Select (exclusividade) e afiliados
      na Hotmart: ver `PUBLICACAO-E-VENDAS.md`.
