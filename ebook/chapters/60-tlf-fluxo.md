# TLFs: o que são e o fluxo de produção

Se o SAP (*Statistical Analysis Plan*) é o plano de voo e os datasets ADaM
(*Analysis Data Model*, o padrão CDISC de dados prontos para análise) são o
combustível, os **TLFs** são o avião pousando: o produto final que o mundo
enxerga. Quase tudo o que um revisor do FDA lê sobre os resultados de um estudo
chega a ele na forma de TLFs. Nesta Parte VI, você vai aprender a fabricá-los
do começo ao fim. Este capítulo é o mapa do processo.

## O que significa "TLF"

TLF é a sigla de **Tables, Listings and Figures** — Tabelas, Listagens e
Figuras. (Você também verá "TFL" e "TLG", onde o *G* é de *Graphs*; são
sinônimos, muda só a ordem das letras e o gosto da empresa.) São três formatos
distintos de apresentar os mesmos dados analisados:

- **Tables (Tabelas):** dados **sumarizados e agregados** — contagens,
  percentuais, médias, medianas, resultados de testes estatísticos. Uma tabela
  de demografia mostra a idade média por braço de tratamento, não a idade de
  cada paciente. É o formato mais comum e o mais importante.
- **Listings (Listagens):** dados **linha a linha, no nível do paciente**, sem
  agregação. Uma listagem de eventos adversos mostra cada AE (*adverse event*)
  de cada paciente, com data de início, severidade e desfecho. Servem de
  rastreabilidade e detalhe: se um revisor quiser auditar um número de uma
  tabela, ele desce até a listagem.
- **Figures (Figuras):** as **representações gráficas** — curvas de
  Kaplan-Meier, gráficos de forest, spaghetti plots de valores ao longo do
  tempo, gráficos de barras de resposta. Uma figura bem-feita comunica em
  segundos o que uma tabela leva um parágrafo para explicar.

> **Glossário PT/EN:** *Table* = tabela (dados agregados). *Listing* = listagem
> (dados por paciente, sem sumarizar). *Figure* = figura/gráfico. Juntos: TLFs,
> o "output" que a estatística entrega.

## De onde saem os números: ADaM é a fonte

Um TLF nunca é produzido a partir de dados brutos. A cadeia CDISC é rígida:
os dados coletados viram **SDTM** (*Study Data Tabulation Model*, os dados
organizados como foram observados), o SDTM vira **ADaM** (dados derivados,
com as variáveis de análise já calculadas — flags de população, baseline,
mudança em relação ao baseline, dia de estudo), e **o ADaM é a fonte de todo
TLF**.

Isso não é preferência de estilo; é um princípio regulatório de
rastreabilidade. Cada célula de cada tabela precisa poder ser reconstruída a
partir de um dataset ADaM, que por sua vez rastreia até o SDTM, que rastreia
até o CRF. As duas classes de ADaM que você mais usará como fonte são:

- **ADSL** (*Subject-Level Analysis Dataset*): uma linha por paciente. É a
  fonte das tabelas de disposição, demografia, baseline e das flags de
  população (`SAFFL`, `ITTFL`, etc.).
- **BDS** (*Basic Data Structure*): estrutura de várias linhas por paciente,
  uma por parâmetro e ponto no tempo. É a fonte de tabelas de laboratório,
  sinais vitais, endpoints longitudinais — qualquer coisa medida repetidamente.

Guarde este reflexo: **antes de programar um TLF, você identifica qual ADaM é
a fonte e qual flag de população define o denominador.** Voltaremos a isso
sem parar.

## O ciclo de produção, do plano à submissão

Produzir TLFs é um processo industrial com etapas bem definidas e papéis
separados. Na ordem:

```text
   SAP  ──►  Shells (mock-ups)  ──►  Especificação  ──►  Programação
 (o quê,      o esqueleto da        as regras de       (production +
  o método)   tabela, sem números)  cada número         QC/validação)
                                                             │
                                                             ▼
                                        CSR (ICH E3)  ──►  Submissão ao FDA
```

### 1. SAP — o quê e como

Tudo começa no **SAP**. É lá que se define quais análises existirão, com quais
populações, quais métodos estatísticos e — num anexo que muitas vezes é o mais
volumoso do documento — **a lista de TLFs**. O SAP diz "haverá uma tabela de
overview de TEAEs na população de segurança"; ele ainda não desenha a tabela.

### 2. Shells — o esqueleto sem números

O **shell** (também chamado de *mock-up*, *mock table* ou *table shell*) é o
desenho da tabela **antes de existir qualquer dado**: o título, a estrutura de
linhas e colunas, as estatísticas em cada célula (representadas por placeholders
como `xx (xx.x)`), as notas de rodapé e a população. É literalmente o esqueleto.

Por que fazer isso antes dos dados? Porque desenhar a tabela vazia obriga a
decidir **tudo** — quais categorias, qual ordem, qual denominador, quantas
casas decimais — enquanto ainda é barato mudar de ideia e enquanto ninguém pode
ser acusado de escolher o formato depois de ver os resultados. É a mesma lógica
de pré-especificação que rege o SAP. Um shell típico é assim:

```text
Table 14.1.2
Demographic Characteristics — Safety Population

                          Placebo        Drug 10 mg      Total
                          (N=xx)         (N=xx)          (N=xx)
--------------------------------------------------------------------
Age (years)
   n                        xx             xx              xx
   Mean (SD)             xx.x (xx.xx)   xx.x (xx.xx)    xx.x (xx.xx)
   Median                  xx.x           xx.x            xx.x
   Min, Max              xx, xx         xx, xx          xx, xx

Sex, n (%)
   Male                  xx (xx.x)      xx (xx.x)       xx (xx.x)
   Female                xx (xx.x)      xx (xx.x)       xx (xx.x)
--------------------------------------------------------------------
[Rodapé: Safety Population. Percentuais baseados em N da coluna.]
```

### 3. Especificação — as regras de cada célula

Entre o shell e o código costuma existir uma **especificação de programação**
(TLF specs): um documento que diz, para cada tabela, qual ADaM é a fonte, quais
filtros aplicar, como derivar cada estatística, como ordenar, como tratar
missing. Em times enxutos, o shell bem anotado já cumpre esse papel; em big
pharma, é um documento formal separado.

### 4. Programação — production e QC

Aqui o código entra em cena, e o trabalho se divide em dois:

- **Production programming:** o programador de produção escreve o código
  (SAS ou R) que lê o ADaM e gera a tabela conforme o shell.
- **QC / validação:** um **segundo** programador, de forma **independente**,
  verifica que os números estão certos — no caso mais rigoroso, reprogramando
  a tabela do zero e comparando resultado com resultado (*double programming*).
  O Capítulo 63 é inteiro sobre isso.

## Numeração e titulação: a convenção 14.x

Os TLFs seguem uma numeração padronizada que vem do **ICH E3**, a guideline que
define a estrutura do **CSR** (*Clinical Study Report*, o relatório final do
estudo). No CSR, as tabelas de eficácia e segurança ficam na **Seção 14**, e por
convecção histórica os grupos são:

| Numeração | Conteúdo |
|---|---|
| Table 14.1.x | Disposição, demografia, características de baseline |
| Table 14.2.x | Análises de eficácia (endpoints) |
| Table 14.3.x | Análises de segurança (AEs, laboratório, sinais vitais) |

Listagens costumam ir para a **Seção 16** (apêndices). O título de cada TLF é
padronizado: número, um título descritivo e — sempre — a **população** de
análise. "Table 14.3.1.1 — Overview of Treatment-Emergent Adverse Events, Safety
Population". A população faz parte do título porque ela define o que a tabela
significa.

> **Atenção:** o esquema 14.1/14.2/14.3 é a convenção mais difundida, mas cada
> sponsor tem seu próprio *TLF numbering standard*. Não decore os números como
> se fossem lei — entenda a lógica (disposição → demografia → eficácia →
> segurança) e adapte-se ao padrão da empresa onde você estiver.

## Como os TLFs viram CSR e submissão

O destino dos TLFs é duplo:

- **CSR:** o *Clinical Study Report* é o documento narrativo de centenas de
  páginas que conta a história de um estudo. Os TLFs entram como as tabelas do
  corpo (Seção 11, resultados) e, principalmente, como o grande apêndice de
  Seção 14. O texto do CSR interpreta; os TLFs sustentam.
- **Submissão:** numa submissão ao FDA (um NDA ou BLA), os TLFs vão junto com
  os datasets SDTM e ADaM, os programas que os geraram e a documentação
  (*define.xml*, *reviewer's guide*). O revisor pode reexecutar seu código
  sobre seus dados. É por isso que reprodutibilidade não é opcional.

> **Na prática:** o TLF não começa quando os dados chegam — começa no SAP,
> meses antes de existir um único paciente com dados completos. Quando o banco
> é travado (*database lock*), os shells já estão aprovados, as especificações
> escritas e boa parte do código já rodou contra dados de teste ou dados
> parciais (*dry run*). O *lock* dispara a produção final; ele não a inicia do
> zero. Times que deixam para pensar na tabela depois do lock vivem em pânico.

## Quem faz o quê

Numa CRO ou num departamento de pharma, os papéis típicos são:

- **Bioestatístico (lead):** define os TLFs no SAP, desenha ou aprova os
  shells, decide os métodos, interpreta os resultados.
- **Programador estatístico de produção:** transforma shell + spec em código
  que gera a tabela.
- **Programador de QC / validação:** verifica de forma independente, muitas
  vezes reprogramando.
- **Data management:** garante que os dados que alimentam o ADaM estão limpos.

Como recém-chegado, a porta de entrada mais comum é a **programação** — de
produção ou de QC. Dominar o fluxo inteiro, mesmo entrando por uma peça dele,
é o que te faz subir.

## Resumo do capítulo

- **TLF = Tables, Listings, Figures:** tabelas (dados agregados), listagens
  (dados por paciente) e figuras (gráficos). É o produto final que o FDA lê.
- Todo TLF nasce de um **ADaM** — **ADSL** para dados por paciente, **BDS**
  para dados repetidos no tempo — por rastreabilidade regulatória.
- O ciclo é **SAP → shells (mock-ups) → especificação → programação
  (production + QC) → CSR → submissão**. O shell é o esqueleto da tabela,
  desenhado sem números, antes dos dados.
- A numeração segue o **ICH E3**: Seção 14 do CSR, com 14.1 (disposição/
  demografia), 14.2 (eficácia) e 14.3 (segurança); cada título carrega a
  **população** de análise.
- Papéis separados: o **bioestatístico** define, o **programador de produção**
  gera, o **programador de QC** valida de forma independente.
- O planejamento do TLF começa no **SAP**, muito antes do *database lock* —
  não depois que os dados chegam.
