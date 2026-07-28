# Apêndice B — Templates e recursos para download

Uma das partes mais valiosas deste livro não são as explicações — é o que você
pode **levar para o trabalho amanhã**. A pasta `templates/` traz esqueletos
reutilizáveis que reproduzem o formato real usado na indústria. Você preenche os
`<placeholders>` e adapta ao seu estudo. Este apêndice explica o que é cada um,
como usá-lo, e onde buscar os padrões oficiais quando precisar da fonte primária.

## Os três templates entregáveis

### 1. `templates/sap-template.md` — Esqueleto de SAP

Um *Statistical Analysis Plan* completo em branco, com **todos os cabeçalhos de
seção** que um SAP de Fase II/III costuma ter — da página de aprovações à lista
de TLFs. Sob cada cabeçalho há uma instrução em itálico dizendo o que escrever e
`<placeholders>` para os valores do seu estudo.

- **Como usar:** copie o arquivo, renomeie (ex.: `SAP_ABC-123_v1.0.md`) e
  preencha de cima para baixo. Não apague seções que não se aplicam —
  escreva "Not applicable" com uma justificativa curta. Isso mostra ao revisor
  que a decisão foi consciente, não um esquecimento.
- **Quando escrever:** o SAP é redigido depois do protocolo final e **congelado
  antes do database lock** (idealmente antes do unblinding). Ver Cap. 12.
- **Combine com:** o Cap. 13 (estrutura seção a seção) e o Cap. 15 (SAP-modelo
  comentado).

### 2. `templates/tlf-shells.md` — Shells de TLF

Uma coleção de *shells* — tabelas modelo, sem números — para as saídas mais
comuns: disposição, demografia/baseline, exposição, visão geral de AEs, AEs por
SOC/PT e uma *shift table* de laboratório. Cada shell já traz título no formato
`Table 14.x.x`, linha de população, colunas por grupo de tratamento e footnotes.

- **Como usar:** os shells são a **ponte entre o SAP e a programação**. Você (ou
  o estatístico) define o layout aqui; o programador reproduz exatamente esse
  layout enchendo os `<n (%)>` e `<média (DP)>` a partir do ADaM. Ver Cap. 20.
- **Dica:** mantenha os títulos e footnotes idênticos entre o shell e a tabela
  final. Divergência entre shell e output é um dos achados mais comuns em QC.

### 3. `templates/protocolo-synopsis.md` — Sinopse de protocolo

O modelo da **tabela-resumo de 2–3 páginas** que abre todo protocolo clínico:
título, fase, objetivos, desenho, população, tratamentos, endpoints, plano
estatístico e duração. Útil tanto para ler protocolos alheios com rapidez quanto
para montar um **estudo sintético de portfólio** (Cap. 24).

- **Como usar:** preencha a sinopse primeiro, mesmo para um projeto fictício de
  portfólio. Ela força você a tomar as decisões de desenho antes de escrever o
  SAP — que é exatamente a ordem real de trabalho.

## Onde baixar os padrões oficiais (fontes reais)

Os templates deste livro são **didáticos**. Quando você precisar da fonte
autoritativa — para citar num SAP, conferir uma variável ou justificar uma
decisão ao FDA —, vá às fontes primárias:

| Fonte | O que encontrar | Onde |
|---|---|---|
| **CDISC** | Implementation Guides oficiais: SDTMIG, ADaMIG, Define-XML, CDASH, Controlled Terminology. | `cdisc.org` (parte do conteúdo exige cadastro/membro). |
| **PHUSE** | Padrões de qualidade abertos, incluindo shells e boas práticas de TLF, whitepapers de código aberto. | `phuse.global` e o GitHub da PHUSE. |
| **ICH** | Diretrizes E6 (GCP), E8, E9, E9(R1) (estimands), E3 (CSR), M4 (CTD) — PDFs gratuitos. | `ich.org` (seção *Guidelines*). |
| **FDA** | *Guidance for Industry*, requisitos de dados para estudo (Study Data Technical Conformance Guide), catálogo de padrões suportados. | `fda.gov` (busca por *guidance documents* e *study data standards*). |
| **Pinnacle 21** | Validador de conformidade CDISC (versão Community gratuita). | `pinnacle21.com`. |

> **Atenção:** os *Implementation Guides* têm **versões** (ex.: SDTMIG v3.x,
> ADaMIG v1.x). O FDA publica quais versões aceita num catálogo de padrões
> suportados. Sempre confira a versão exigida para a sua submissão antes de
> começar — misturar versões é fonte clássica de retrabalho. Ver Cap. 19.

> **Dica de carreira:** contribuir (mesmo que só lendo e reproduzindo) com os
> repositórios abertos da PHUSE e com projetos de *pharmaverse* (pacotes R para
> a indústria) é uma forma concreta de construir portfólio e vocabulário reais.
> Ver Cap. 24 e 26.

## Nota sobre publicar e distribuir o livro

Se você é coautor ou está adaptando este material para publicação (KDP da Amazon,
Hotmart ou similar), lembre-se de três coisas:

- **Os templates são o principal atrativo comercial.** Deixe claro na descrição
  do produto que o comprador leva esqueletos utilizáveis de SAP, shells de TLF e
  sinopse de protocolo — não só teoria.
- **Aponte o leitor para o Apêndice C (Checklists).** Os checklists acionáveis
  são o que transforma a leitura em prática e geram avaliações positivas.
- **O `README.md` do projeto** descreve como compilar o livro em PDF e EPUB (via
  Pandoc) e a convenção de arquivos. Mantenha os templates como arquivos
  separados na pasta `templates/` para que possam ser oferecidos como bônus
  destacável (download à parte), além de aparecerem no corpo do ebook.

Ao final, o Apêndice C fecha o ciclo: você tem o vocabulário (Apêndice A), os
modelos (Apêndice B e a pasta `templates/`) e as listas de verificação para
aplicar tudo com qualidade de submissão.
