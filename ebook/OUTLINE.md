# Índice Mestre — "Do Brasil ao FDA"

Plano completo de capítulos e status de produção. Meta: 100–150+ páginas.

Legenda de status: ⬜ pendente · 🟡 rascunho · ✅ pronto

## Front matter (`chapters/00-*`)

- ⬜ `00-frontmatter.md` — Página de rosto, copyright, aviso legal, dedicatória
- ⬜ `01-sobre.md` — Sobre este livro, para quem é, como usar, sobre o autor

## Parte I — O panorama: ser bioestatístico nos EUA

- ⬜ `10-industria.md` — **Cap. 1** A indústria de pesquisa clínica nos EUA:
  pharma, biotech, CROs, FDA, academia. Quem paga, quem contrata, como o
  dinheiro flui, tamanho do mercado, salários.
- ⬜ `11-papeis.md` — **Cap. 2** Os papéis: Biostatistician vs Statistical
  Programmer vs Data Manager vs Clinical Data Scientist. O que cada um faz no
  dia a dia, ferramentas, senioridade, faixas salariais.
- ⬜ `12-transicao-carreira.md` — **Cap. 3** Do Brasil aos EUA: vistos (H-1B,
  O-1, EB-2 NIW, TN não se aplica, L-1, estudante→OPT), inglês, validação de
  diploma, remoto vs. presencial, o mercado de trabalho realista.
- ⬜ `13-competencias-ferramentas.md` — **Cap. 4** O stack de competências:
  SAS vs R vs Python, SQL, Git, estatística exigida, soft skills, o que
  aprender primeiro.

## Parte II — Regulamentações e o ambiente regulado

- ⬜ `20-fda-aprovacao.md` — **Cap. 5** O FDA e o ciclo de vida de um
  medicamento: pré-clínico, IND, Fases I–III, NDA/BLA, pós-comercialização
  (Fase IV), o papel da estatística em cada etapa.
- ⬜ `21-ich-guidelines.md` — **Cap. 6** As diretrizes ICH que todo
  bioestatístico precisa conhecer: E6 (GCP), E9 (princípios estatísticos),
  E9(R1) (estimands e análises de sensibilidade), E3, E8, M4 (CTD).
- ⬜ `22-gcp-integridade.md` — **Cap. 7** GCP na prática, integridade de dados,
  ALCOA+, 21 CFR Part 11, validação de sistemas computadorizados, trilha de
  auditoria, o que "regulado" significa no dia a dia.

## Parte III — Protocolos de pesquisa clínica

- ⬜ `30-anatomia-protocolo.md` — **Cap. 8** Anatomia de um protocolo clínico:
  seções, objetivos/endpoints, critérios de elegibilidade, a seção estatística.
- ⬜ `31-desenhos-estudo.md` — **Cap. 9** Desenhos de estudo: paralelo,
  crossover, superioridade/não-inferioridade/equivalência, adaptativos,
  randomização e blinding, estratificação.
- ⬜ `32-endpoints-estimands.md` — **Cap. 10** Endpoints e o framework de
  estimands (ICH E9(R1)): eventos intercorrentes, estratégias, população-alvo.
- ⬜ `33-tamanho-amostral.md` — **Cap. 11** Tamanho amostral e poder: fórmulas,
  premissas, exemplos práticos em R e SAS para os desenhos mais comuns.

## Parte IV — Statistical Analysis Plan (SAP)

- ⬜ `40-sap-visao-geral.md` — **Cap. 12** O que é um SAP, por que existe,
  quando é escrito e congelado, quem revisa e assina.
- ⬜ `41-sap-estrutura.md` — **Cap. 13** Estrutura seção a seção de um SAP
  (baseada em ICH E9 e no template PHUSE/CDISC), com o que escrever em cada uma.
- ⬜ `42-sap-metodos.md` — **Cap. 14** Métodos analíticos: populações de
  análise, dados faltantes, análises de sensibilidade e suplementares,
  multiplicidade, análises interinas e o papel do DSMB.
- ⬜ `43-sap-template.md` — **Cap. 15** Um SAP-modelo comentado, seção a seção,
  para um ensaio de Fase III (ligado ao template em `templates/`).

## Parte V — CDISC

- ⬜ `50-cdisc-visao-geral.md` — **Cap. 16** O ecossistema CDISC: CDASH → SDTM →
  ADaM → Define-XML → Controlled Terminology, e como tudo se conecta na
  submissão ao FDA (eCTD).
- ⬜ `51-sdtm.md` — **Cap. 17** SDTM em profundidade: classes e domínios
  (DM, AE, LB, VS, EX, CM…), variáveis, estrutura, exemplos de datasets,
  erros comuns.
- ⬜ `52-adam.md` — **Cap. 18** ADaM em profundidade: ADSL, estrutura BDS e
  OCCDS, rastreabilidade (traceability), variáveis derivadas, exemplos.
- ⬜ `53-define-submissao.md` — **Cap. 19** Define-XML, Reviewer's Guide (cSDRG/
  ADRG), a estrutura de uma submissão e o que o revisor do FDA espera.

## Parte VI — TLFs (Tables, Listings, Figures)

- ⬜ `60-tlf-fluxo.md` — **Cap. 20** O que são TLFs, o fluxo de produção, mock
  shells, o ciclo SAP → shells → programação → QC → entrega.
- ⬜ `61-tlf-catalogo.md` — **Cap. 21** Catálogo das tabelas essenciais:
  disposição, demografia, exposição, eficácia, segurança (AEs, labs, sinais
  vitais, ECG), com shells de exemplo.
- ⬜ `62-tlf-programacao.md` — **Cap. 22** Produzindo TLFs na prática: exemplos
  lado a lado em SAS (PROC REPORT/`proc freq`) e R (`gtsummary`, `rtables`,
  `tern`), do ADaM à tabela final.
- ⬜ `63-tlf-qc.md` — **Cap. 23** QC e validação: double programming,
  independent programming, checagens, versionamento, entrega e define.

## Parte VII — Da teoria à prática e à carreira

- ⬜ `70-projeto-fim-a-fim.md` — **Cap. 24** Um projeto end-to-end de portfólio:
  do protocolo-sintético ao SAP, aos ADaMs e a um pacote de TLFs — com
  repositório de exemplo.
- ⬜ `71-curriculo-entrevista.md` — **Cap. 25** Currículo, LinkedIn e portfólio
  para o mercado americano; a entrevista técnica de biostat/stat programming
  (perguntas típicas, estudo de caso, live coding).
- ⬜ `72-recursos-proximos-passos.md` — **Cap. 26** Comunidades (PHUSE, PharmaSUG,
  ASA), certificações (SAS, CDISC), cursos, e um plano de 90 dias.

## Apêndices (`chapters/9*`)

- ⬜ `90-glossario.md` — **Apêndice A** Glossário PT/EN de siglas e termos
- ⬜ `91-templates.md` — **Apêndice B** Índice dos templates entregáveis
- ⬜ `92-checklists.md` — **Apêndice C** Checklists (SAP, submissão, QC de TLF)
- ⬜ `93-encerramento.md` — Palavra final, contato, próximos produtos

## Templates entregáveis (`templates/`)

- `sap-template.md` — Esqueleto completo de SAP para preencher
- `tlf-shells.md` — Shells de tabelas típicas
- `protocolo-synopsis.md` — Modelo de sinopse de protocolo
