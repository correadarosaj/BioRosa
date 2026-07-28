# Um projeto end-to-end para o seu portfólio

Você já entendeu o ecossistema, os papéis, o FDA, o protocolo, o SAP, o CDISC e
os TLFs. Agora vem a pergunta que todo recrutador faz — em voz alta ou na
cabeça: **"tudo bem, mas você já fez isso?"** Para quem vem de fora do mercado
regulado, a resposta honesta costuma ser "ainda não, mas eu entendo como
funciona". O problema é que "eu entendo" não abre portas. **Prova, sim.**

Este capítulo te guia a construir um projeto de portfólio que percorre o fluxo
inteiro — de uma sinopse de protocolo até um pacote de TLFs versionado no
GitHub — usando **dados clínicos públicos e sintéticos**. É a peça que
transforma a frase "estou estudando pharma" em "olha aqui o que eu já sei
fazer".

## Por que um projeto de ponta a ponta (end-to-end) é a sua melhor arma

Um recrutador de CRO ou pharma vê dezenas de currículos que dizem "conheço
CDISC" e "familiaridade com SAS/R". Palavras são baratas. Um **repositório
público** onde ele consegue abrir o seu `adsl.R`, ver o seu mini-SAP em PDF e
rodar o seu código que gera a Table 14.1 (demografia) é outra conversa. Você
deixa de ser uma promessa e vira uma amostra de trabalho.

O termo *end-to-end* (de ponta a ponta) é literal: o objetivo não é fazer uma
análise estatística bonita e isolada, e sim **demonstrar que você entende a
cadeia** que já vimos no livro — protocolo → SAP → SDTM → ADaM → TLF →
entrega. Recrutadores da área não querem só um cientista de dados; querem
alguém que fale o idioma da submissão regulatória.

> **Na prática:** ninguém espera que o seu projeto de portfólio seja uma
> submissão real ao FDA. Ele é uma **maquete** — pequena, mas completa e
> correta em cada elo. Um ADSL bem feito com dez variáveis vale mais que um
> modelo estatístico sofisticado que não fala CDISC.

## Os dados: use o CDISC Pilot e o pharmaverse

A boa notícia é que você **não precisa** de dados de pacientes reais (e nem
deve usá-los — seriam dados protegidos). O ecossistema já oferece dados
clínicos sintéticos, públicos e reconhecidos:

- **CDISC Pilot Project** — um estudo fictício de Alzheimer que a própria CDISC
  publicou como exemplo de referência. Ele tem datasets SDTM e ADaM completos,
  um protocolo e define/documentação. É o material de estudo mais citado da
  área.
- **pharmaverse** — uma coleção de pacotes R open source mantida por gente da
  indústria (Roche, GSK, Novartis e outras) para o fluxo clínico em R. Dentro
  dela, os pacotes de dados **`{pharmaverseadam}`** (datasets ADaM de exemplo) e
  **`{pharmaversesdtm}`** (datasets SDTM de exemplo) entregam dados sintéticos
  prontos para você programar em cima, muitos derivados do próprio CDISC Pilot.

> **Glossário PT/EN:** *pharmaverse* = ecossistema de pacotes R open source para
> pesquisa clínica regulada, mantido colaborativamente pela indústria. Não é uma
> empresa; é uma comunidade de pacotes que conversam entre si.

Usar esses dados sinaliza duas coisas ao recrutador: você conhece as fontes
canônicas da área e sabe trabalhar com o padrão real, não com um `iris` ou um
`mtcars` genérico.

## O projeto, passo a passo

### 1. Comece por uma sinopse de protocolo fictícia

Não pule esta etapa achando que "o que importa é o código". O que separa o seu
portfólio de um exercício de programação qualquer é ele **nascer de uma pergunta
clínica**. Escreva uma **sinopse** curta (uma a duas páginas) de um estudo
fictício — ou reaproveite a do CDISC Pilot. Defina:

- a doença e a população (ex.: pacientes com Alzheimer leve a moderado);
- o desenho (ex.: randomizado, duplo-cego, três braços: placebo, dose baixa,
  dose alta);
- o **endpoint primário** (ex.: mudança no escore ADAS-Cog da baseline à
  semana 24);
- alguns **endpoints secundários** e de segurança (adverse events).

Isso ancora todo o resto. Cada tabela que você programar depois vai responder a
uma pergunta que está na sinopse.

### 2. Escreva um mini-SAP

Um *Statistical Analysis Plan* completo tem dezenas de páginas; o seu **mini-SAP**
pode ter três a cinco. O objetivo é mostrar que você sabe o que um SAP contém e
como se pensa antes de tocar nos dados. Inclua:

- as **populações de análise** (ITT / *Intention-to-Treat*, per-protocol,
  safety);
- o **estimand** do endpoint primário, ainda que descrito de forma simples
  (população, variável, evento intercorrente, resumo populacional);
- o **método** para o endpoint primário (ex.: um MMRM — *Mixed Model for
  Repeated Measures*) e como você trataria dados faltantes;
- a lista dos **outputs** planejados (os TLFs que você vai gerar).

> **Na prática:** manter o mini-SAP e os TLFs coerentes é o exercício mais
> valioso do projeto inteiro. Se o SAP promete uma tabela de demografia por
> braço de tratamento e o seu código gera outra coisa, um revisor atento nota.
> Coerência entre planejamento e entrega é exatamente o que a indústria compra.

### 3. Obtenha SDTM-like e derive ADaM

Aqui está o coração técnico. Você tem duas rotas:

- **Rota rápida:** carregue datasets SDTM sintéticos do `{pharmaversesdtm}` (ex.:
  `dm`, `ae`, `vs`, `lb`) e datasets ADaM do `{pharmaverseadam}` já prontos, e
  use-os como insumo.
- **Rota que impressiona mais:** carregue os SDTM sintéticos e **derive você
  mesmo** os ADaM usando o pacote **`{admiral}`** (ADaM in R Asset Library), o
  carro-chefe do pharmaverse para construção de ADaM.

Construa, no mínimo:

- um **ADSL** (*Subject-Level Analysis Dataset*) — uma linha por sujeito, com
  variáveis de população, braço de tratamento, datas de referência, demografia
  derivada;
- um **BDS** (*Basic Data Structure*) — por exemplo um `ADAE` para adverse
  events, ou um `ADVS`/`ADLB` para sinais vitais ou laboratório, com variáveis
  como `AVAL`, `CHG`, `ABLFL`, `PARAMCD`.

O `{admiral}` foi desenhado justamente para isso: funções como as de derivação
de datas de referência e de flags de baseline mostram, em código legível, que
você entende a lógica ADaM — não só a sintaxe.

> **Glossário PT/EN:** *`{admiral}`* = ADaM in R Asset Library, pacote R open
> source para derivar datasets ADaM a partir de SDTM seguindo os padrões CDISC.
> É o modo "idiomático" de fazer ADaM em R na indústria hoje.

### 4. Programe um pacote de TLFs

Com os ADaM na mão, gere um pequeno **pacote de TLFs** — o mesmo tipo de output
que sobe numa submissão. Sugestão de um conjunto enxuto e representativo:

- uma **tabela de demografia** (Table 14.1) por braço de tratamento;
- um **AE overview** — resumo de adverse events (nº de sujeitos com pelo menos um
  AE, AEs sérios, por severidade), a partir do seu ADAE;
- um **gráfico** — por exemplo, a média do endpoint ao longo das visitas por
  braço, ou um Kaplan-Meier se você modelar tempo até evento.

Ferramentas para isso:

- **Em R:** **`{gtsummary}`** é o caminho mais amigável para tabelas resumo;
  **`{rtables}`** e **`{tern}`** (também do pharmaverse) produzem tabelas no
  layout regulatório clássico, com faixas e formatação de submissão.
- **Em SAS:** se você tiver acesso, replicar ao menos uma tabela com `PROC
  FREQ`/`PROC MEANS` e `PROC REPORT` mostra fluência na ferramenta que ainda
  domina a maioria das submissões.

Fazer **a mesma tabela em R e em SAS** é um bônus poderoso: é literalmente o
conceito de *double programming* (dupla programação, o controle de qualidade
padrão da indústria) que você viu no livro, agora demonstrado no seu portfólio.

### 5. Documente num repositório GitHub

Um projeto que não está publicado não existe para o recrutador. Suba tudo no
**GitHub** com um **README** que conte a história: qual é o estudo fictício, quais
dados você usou, como rodar o código, e uma imagem ou duas dos outputs. O README
é o que a pessoa lê em 30 segundos antes de decidir se vale abrir o resto.

Estrutura de pastas sugerida:

```text
adam-portfolio/
├── README.md              <- a vitrine: o que é, como rodar, prints dos outputs
├── protocol/
│   └── synopsis.md        <- a sinopse do estudo fictício
├── sap/
│   └── mini-sap.pdf       <- o mini-SAP (3-5 páginas)
├── data/
│   ├── sdtm/              <- SDTM sintéticos (pharmaversesdtm / CDISC pilot)
│   └── adam/              <- ADaM derivados por você
├── programs/
│   ├── adam/
│   │   ├── adsl.R         <- derivação do ADSL (admiral)
│   │   └── adae.R         <- derivação de um BDS
│   └── tlf/
│       ├── t_demographics.R
│       ├── t_ae_overview.R
│       └── g_endpoint_over_time.R
├── outputs/
│   ├── tables/           <- .rtf / .html / .pdf gerados
│   └── figures/
└── renv.lock             <- ambiente reprodutível (renv), se usar R
```

Detalhes que sinalizam maturidade: um ambiente reprodutível (`{renv}` em R),
commits com mensagens claras, e talvez um GitHub Actions rodando o pipeline. Não
é obrigatório — mas mostra que você pensa em **reprodutibilidade**, palavra de
ouro num ambiente regulado.

> **Atenção:** nunca use dados de pacientes reais, mesmo "anonimizados", num
> repositório público. Além de ser proibido em qualquer contexto profissional, é
> um sinal vermelho enorme para um recrutador de pharma. Fique **exclusivamente**
> com dados sintéticos públicos (CDISC Pilot, pharmaverse). Isso não é uma
> limitação do seu projeto — é a prática correta.

## Como isso vira prova de competência

Quando você manda o link para um recrutador ou coloca no LinkedIn, ele consegue
verificar, sem acreditar em nada só pela sua palavra, que você:

- entende a **cadeia regulada** (protocolo → SAP → SDTM → ADaM → TLF);
- sabe **derivar ADaM** seguindo CDISC, não improvisar;
- produz **outputs no layout da indústria**, não gráficos genéricos de data
  science;
- documenta e versiona como um profissional, pensando em reprodutibilidade;
- conhece as **ferramentas reais** (admiral, rtables/tern/gtsummary, SAS,
  GitHub).

Isso é exatamente o conjunto de sinais que um currículo sozinho não consegue
transmitir de forma crível para quem vem de fora do mercado.

> **Dica de carreira:** um repositório público bem-feito vale mais que quase
> qualquer certificado. Certificados provam que você **assistiu** a um
> treinamento; um projeto end-to-end prova que você **consegue fazer o
> trabalho**. Se tiver que escolher onde investir as próximas semanas, escolha
> construir a peça — e depois fale dela em cada entrevista, cada mensagem de
> networking, cada linha do resumo do seu currículo.

## Resumo do capítulo

- Um **projeto end-to-end** é a prova concreta que um currículo não consegue
  dar: ele mostra que você domina a cadeia regulada inteira, não só estatística.
- Use **dados sintéticos públicos** — o **CDISC Pilot** e os pacotes de dados do
  **pharmaverse** (`{pharmaversesdtm}`, `{pharmaverseadam}`). Nunca dados reais.
- O fluxo do projeto: **sinopse fictícia → mini-SAP → SDTM-like → ADaM** (derive
  com **`{admiral}`**) **→ pacote de TLFs** (rtables/tern/gtsummary em R e/ou SAS)
  **→ repositório GitHub com README**.
- Faça um conjunto enxuto mas completo de TLFs (demografia, AE overview, um
  gráfico). Coerência entre mini-SAP e outputs é o que mais impressiona.
- Publique no **GitHub** com README, ambiente reprodutível e commits limpos —
  reprodutibilidade é palavra de ouro no ambiente regulado.
- Um **repositório público vale mais que um certificado**: transforma "estou
  estudando" em "olha o que já sei fazer".
