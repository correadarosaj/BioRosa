# O ecossistema CDISC

Se existe uma sigla que separa quem "sabe estatística" de quem "sabe trabalhar
em submissão ao FDA", é esta: **CDISC**. Você pode ser um mago do R, entender
modelos mistos de cor e escrever um SAP elegante — mas se não sabe entregar os
dados no formato que o FDA exige, você não consegue fechar o ciclo de uma
submissão. Esta Parte V é dedicada a fechar exatamente essa lacuna. Vamos
começar pelo mapa: o que é CDISC, por que ele existe e como as peças se
encaixam.

## O que é CDISC e por que o FDA exige

**CDISC** é o *Clinical Data Interchange Standards Consortium* — uma
organização sem fins lucrativos que mantém os **padrões de dados** usados em
pesquisa clínica. Não é uma empresa, não é uma ferramenta, não é um software: é
um conjunto de **especificações** sobre como os dados de um ensaio clínico devem
ser estruturados, nomeados e documentados.

Por que isso importa? Porque desde meados da década de 2010 o **FDA exige**, na
prática, que os dados de estudos que sustentam pedidos de aprovação sejam
submetidos em formato CDISC. Não é uma sugestão de boas práticas — é requisito
para o *dossiê* ser aceito para revisão.

A lógica é simples do ponto de vista do FDA. Imagine ser um revisor que recebe,
todo mês, dados de dezenas de estudos, de dezenas de empresas diferentes. Se
cada empresa organizasse seus dados do seu jeito — nomes de variáveis próprios,
estruturas próprias, codificações próprias — o revisor gastaria semanas só para
**entender** cada conjunto antes de conseguir **analisar** qualquer coisa. Com
um padrão comum, o revisor abre um dataset **DM** e já sabe exatamente o que vai
encontrar, em qualquer estudo, de qualquer empresa. O padrão é o que torna a
revisão viável em escala.

> **Na prática:** o FDA publica um *Data Standards Catalog* que lista quais
> versões de cada padrão CDISC são suportadas e obrigatórias em função da data
> de início do estudo. CDISC é **versionado**, e as versões mudam. Nunca decore
> "a versão certa" — confirme sempre a versão aplicável ao seu estudo em
> cdisc.org e no catálogo do FDA.

## O fluxo dos padrões: da coleta ao resultado

CDISC não é um padrão único, e sim uma **família** de padrões que cobre todo o
ciclo de vida do dado, do formulário de coleta até a tabela final. Os principais
elos:

- **CDASH** (*Clinical Data Acquisition Standards Harmonization*) — padroniza a
  **coleta**: como os campos do CRF (*Case Report Form*, o formulário onde os
  dados do paciente são registrados) devem ser desenhados. É o padrão "na
  entrada".
- **SDTM** (*Study Data Tabulation Model*) — organiza os **dados tabulados do
  estudo**: os dados como foram observados, limpos e estruturados, mas ainda
  **não** transformados para análise. É a "fotografia do que aconteceu".
- **ADaM** (*Analysis Data Model*) — os **dados prontos para análise**
  (*analysis-ready*), já com as variáveis derivadas, flags de população e
  baselines que as tabelas precisam. É a "mesa posta para o estatístico".
- **TLFs** (*Tables, Listings and Figures*) — as **tabelas, listagens e
  figuras** finais que resumem os resultados e vão para o relatório do estudo e
  para a submissão. Não são um "padrão CDISC" em si, mas são o produto final que
  os ADaM alimentam.

Dois padrões transversais amarram tudo:

- **Controlled Terminology (CT)** — os **vocabulários controlados**: listas
  oficiais de valores permitidos para variáveis codificadas (por exemplo, os
  valores válidos de sexo, de unidade de laboratório, de gravidade de evento
  adverso). Mantidos em conjunto com o NCI/EVS. É o que garante que "Male",
  "M" e "masculino" não convivam no mesmo campo.
- **Define-XML** — o **dicionário de dados legível por máquina** que descreve
  todos os datasets, todas as variáveis, a CT usada e as derivações. É o
  metadado que acompanha os dados na submissão. Veremos em detalhe no capítulo
  53.

### O pipeline, visualmente

```text
   CRF / EDC            SDTM                 ADaM                TLFs
 (coleta de dados)   (tabulação)         (análise)          (resultados)
       │                 │                   │                   │
  ┌────┴────┐       ┌────┴────┐         ┌────┴────┐         ┌────┴────┐
  │ CDASH   │──────►│ DM AE   │────────►│ ADSL    │────────►│ Tabelas │
  │ desenha │ dados │ LB VS   │ deriva  │ ADAE    │ analisa │ Listas  │
  │ o CRF   │ brutos│ EX CM…  │         │ ADLB…   │         │ Figuras │
  └─────────┘       └────┬────┘         └────┬────┘         └─────────┘
                         │                   │
                    ┌────┴───────────────────┴────┐
                    │  Controlled Terminology (CT) │  ← vocabulário comum
                    │  Define-XML (metadados)      │  ← "dicionário" de tudo
                    └──────────────────────────────┘

  ────────────────────  rastreabilidade (traceability)  ────────────────────►
        cada valor numa tabela pode ser rastreado até a linha do CRF
```

## A filosofia central: rastreabilidade de ponta a ponta

Se você guardar uma única ideia deste capítulo, guarde esta: **traceability**
(rastreabilidade). O princípio que organiza todo o ecossistema CDISC é que
**qualquer número que aparece numa tabela final deve poder ser rastreado, passo
a passo, de volta até o dado original coletado no paciente**.

Um revisor do FDA, olhando uma diferença de pressão arterial média entre grupos
numa tabela de eficácia, precisa poder perguntar: de onde veio esse valor? E a
resposta tem de ser trilhável — do TLF para a variável `AVAL` no ADaM, dessa
variável para a linha correspondente no SDTM (**VS**), e dessa linha para o
registro coletado no CRF. Sem buracos, sem "confie em mim".

É por isso que a separação **SDTM vs ADaM** existe e é tão importante:

- **SDTM responde "o que aconteceu"**: os dados observados, organizados de forma
  fiel à coleta, com o mínimo de transformação. É uma tabulação, não uma
  análise. Você **não** deve embutir lógica de análise no SDTM.
- **ADaM responde "como analisamos"**: os dados derivados, com baselines
  calculados, populações definidas, mudanças em relação ao baseline, flags de
  quais registros entram em cada análise. Cada derivação é **documentada** e
  rastreável de volta ao SDTM.

Manter esses dois mundos separados é o que permite ao revisor verificar o
trabalho de forma independente: ele confere que o SDTM reflete fielmente o CRF,
e separadamente confere que o ADaM deriva corretamente do SDTM. Misturar as
duas coisas quebra a auditabilidade — e é um dos erros conceituais mais comuns
de quem chega da academia, onde normalmente se pula direto do dado bruto para o
modelo.

> **Atenção:** um erro clássico de iniciante é tratar SDTM como "só um passo
> chato antes da análise" e tentar já derivar variáveis de análise nele. Não
> faça isso. Toda derivação analítica vive no ADaM. O SDTM deve ser uma
> tabulação limpa e honesta do que foi observado — nada mais.

## Onde CDISC se encaixa na submissão (eCTD)

Uma submissão ao FDA não é um e-mail com um PDF. É um pacote eletrônico enorme e
estruturado chamado **eCTD** (*electronic Common Technical Document*),
organizado em cinco módulos padronizados. Os dados clínicos — e portanto os
datasets CDISC — vivem no **Module 5** (relatórios de estudos clínicos).

Dentro do Module 5, para cada estudo, você encontra os datasets SDTM, os
datasets ADaM, o Define-XML de cada um, os *Reviewer's Guides* e os programas de
análise. É esse conjunto que compõe o "pacote de dados" da submissão — o tema
do capítulo 53. Por ora, guarde o encaixe: **CDISC é a linguagem em que os dados
clínicos falam dentro do eCTD**.

## Por que isso é o seu maior diferencial

Vamos ser diretos sobre carreira, porque esta é a parte que muda a sua vida
profissional.

A estatística que você aprendeu na universidade — testes, regressão, modelos —
é uma **commodity**. Muita gente sabe. O que é escasso, e o que o mercado
americano de pharma paga bem para ter, é a pessoa que sabe **operar dentro do
fluxo regulado**: pegar dados de um estudo e entregá-los em SDTM e ADaM
conformes, com Define-XML, prontos para submissão. Essa competência é
específica, difícil de aprender sozinho e está em falta crônica.

> **Dica de carreira:** em descrições de vagas de *Statistical Programmer* e
> *Biostatistician* nos EUA, "CDISC", "SDTM" e "ADaM" aparecem quase sempre como
> requisito ou diferencial. É frequentemente o **primeiro filtro** de currículo.
> Dominar esse ecossistema é, isoladamente, o maior salto de empregabilidade que
> você pode dar vindo de fora — mais do que qualquer método estatístico
> avançado.

Os próximos três capítulos abrem cada peça: **SDTM** em profundidade,
**ADaM** em profundidade, e o pacote de submissão (**Define-XML**, Reviewer's
Guides e validação). Ao fim, você terá o vocabulário e o modelo mental de quem
já entende como os dados viajam do paciente até o revisor.

## Resumo do capítulo

- **CDISC** é o consórcio que mantém os **padrões de dados** de pesquisa
  clínica; o FDA **exige** dados em formato CDISC para aceitar submissões — é
  requisito, não boa prática.
- O fluxo de padrões vai da coleta ao resultado: **CDASH** (CRF) → **SDTM**
  (dados tabulados) → **ADaM** (dados de análise) → **TLFs**, com **Controlled
  Terminology** e **Define-XML** amarrando tudo transversalmente.
- A filosofia central é **traceability**: todo número numa tabela deve poder ser
  rastreado de volta até o CRF, sem buracos.
- A separação **SDTM (o que aconteceu) vs ADaM (como analisamos)** existe para
  tornar a revisão auditável — nunca embuta lógica de análise no SDTM.
- Na submissão, os datasets CDISC vivem no **Module 5** do **eCTD**.
- CDISC é **versionado** — confirme sempre a versão aplicável em cdisc.org e no
  catálogo de padrões do FDA.
- Saber CDISC é o **maior diferencial de empregabilidade** para quem entra no
  mercado americano de pharma vindo de fora.
