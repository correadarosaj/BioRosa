# Catálogo das tabelas essenciais

Existe um conjunto de tabelas que aparece em praticamente todo CSR, com
pequenas variações de formato. Se você aprende esse repertório, chega ao
primeiro dia de trabalho reconhecendo 80% do que vai programar. Este capítulo
é um catálogo comentado: para cada tabela, o que ela mostra, um **shell** de
exemplo, o ADaM que a alimenta e a **população** correta. Antes, três
convenções que valem para todas.

## Três convenções que se repetem

- **`n (%)`** — contagem e percentual, para variáveis categóricas. O
  percentual quase sempre usa como **denominador o N da coluna** (o número de
  pacientes daquele braço na população da tabela), não o total geral. A
  convenção de casas decimais é típica: contagem inteira, percentual com uma
  casa: `42 (35.0)`.
- **Média (DP)** — *mean (SD)*, para variáveis contínuas simétricas. A SD
  costuma levar uma casa decimal a mais que a média: `54.3 (12.47)`.
- **Mediana [min, max]** — *median [min, max]*, para descrever a distribuição
  sem assumir simetria. Junto com Q1–Q3, é o resumo robusto.

Uma tabela contínua bem-feita mostra as duas famílias juntas: `n`, `Mean (SD)`,
`Median`, `Q1, Q3`, `Min, Max`. Assim o revisor escolhe qual usar.

## 1. Disposição do paciente (*patient disposition / flow*)

A primeira tabela do CSR. Responde: quantos foram randomizados, quantos
completaram, quantos descontinuaram e **por quê**. É a prestação de contas de
cada paciente que entrou no estudo.

```text
Table 14.1.1  —  Patient Disposition  —  All Randomized

                                    Placebo     Drug 10 mg    Total
                                    (N=xx)      (N=xx)        (N=xx)
------------------------------------------------------------------------
Randomized                          xx          xx            xx
Treated (Safety Population)       xx (xx.x)   xx (xx.x)     xx (xx.x)
Completed treatment               xx (xx.x)   xx (xx.x)     xx (xx.x)
Discontinued treatment            xx (xx.x)   xx (xx.x)     xx (xx.x)
   Adverse event                  xx (xx.x)   xx (xx.x)     xx (xx.x)
   Lack of efficacy               xx (xx.x)   xx (xx.x)     xx (xx.x)
   Withdrawal by subject          xx (xx.x)   xx (xx.x)     xx (xx.x)
   Lost to follow-up              xx (xx.x)   xx (xx.x)     xx (xx.x)
------------------------------------------------------------------------
```

Fonte: **ADSL**. População: em geral **All Randomized** para o topo (é a
contagem que define os denominadores dos demais).

## 2. Desvios de protocolo (*protocol deviations*)

Sumariza os desvios importantes (*important protocol deviations*) por categoria
— violações de critério de elegibilidade, desvios de medicação, de
procedimentos. Sustenta a definição da população **Per-Protocol**.

```text
Table 14.1.3  —  Important Protocol Deviations  —  All Randomized

                                    Placebo     Drug 10 mg    Total
Subjects with >=1 deviation       xx (xx.x)   xx (xx.x)     xx (xx.x)
   Inclusion/exclusion            xx (xx.x)   xx (xx.x)     xx (xx.x)
   Study drug compliance          xx (xx.x)   xx (xx.x)     xx (xx.x)
   Prohibited medication          xx (xx.x)   xx (xx.x)     xx (xx.x)
```

Fonte: ADSL mais o dataset de desvios. Um paciente com dois desvios da mesma
categoria conta **uma vez** na linha da categoria — cuidado com a contagem de
sujeitos únicos.

## 3. Demografia e características de baseline

O retrato dos participantes no início: idade, sexo, raça/etnia, peso, IMC e as
características clínicas relevantes na linha de base. Serve para mostrar que os
braços estão **balanceados** (num estudo randomizado, devem estar).

```text
Table 14.1.2  —  Demographics and Baseline Characteristics  —  Safety Population

                          Placebo        Drug 10 mg      Total
                          (N=xx)         (N=xx)          (N=xx)
--------------------------------------------------------------------
Age (years)
   Mean (SD)             xx.x (xx.xx)   xx.x (xx.xx)    xx.x (xx.xx)
   Median                  xx.x           xx.x            xx.x
   Min, Max              xx, xx         xx, xx          xx, xx
Age group, n (%)
   < 65                  xx (xx.x)      xx (xx.x)       xx (xx.x)
   >= 65                 xx (xx.x)      xx (xx.x)       xx (xx.x)
Sex, n (%)
   Male                  xx (xx.x)      xx (xx.x)       xx (xx.x)
   Female                xx (xx.x)      xx (xx.x)       xx (xx.x)
BMI (kg/m2)
   Mean (SD)             xx.x (xx.xx)   xx.x (xx.xx)    xx.x (xx.xx)
--------------------------------------------------------------------
```

Fonte: **ADSL**. População: **Safety** ou **ITT**, conforme o SAP.

## 4. Exposição ao tratamento (*treatment exposure*)

Quanto de droga cada braço recebeu: duração da exposição (dias), dose
cumulativa, categorias de duração. Contextualiza a segurança — 40 AEs em quem
tomou o remédio por 6 meses é diferente de 40 AEs em quem tomou por 2 semanas.

```text
Table 14.3.x  —  Extent of Exposure  —  Safety Population

                                    Placebo        Drug 10 mg
Duration of exposure (days)
   Mean (SD)                       xx.x (xx.xx)   xx.x (xx.xx)
   Median                           xx.x           xx.x
   Min, Max                        xx, xx         xx, xx
Duration category, n (%)
   >= 4 weeks                      xx (xx.x)      xx (xx.x)
   >= 12 weeks                     xx (xx.x)      xx (xx.x)
Total patient-years                 xx.x           xx.x
```

Fonte: **ADSL** (variáveis de exposição derivadas, tipo `TRTDURD`) ou um ADEX.
População: **Safety**.

## 5. Endpoint de eficácia primário

A tabela que o estudo inteiro existe para produzir. O formato depende do tipo
de endpoint (contínuo, binário, tempo-até-evento), mas geralmente mostra o
resultado por braço, a **estimativa do efeito do tratamento** (diferença de
médias, odds ratio, hazard ratio) com **intervalo de confiança** e o
**valor-p**, tudo conforme o modelo pré-especificado (ex.: MMRM, ANCOVA).

```text
Table 14.2.1  —  Primary Efficacy Endpoint: Change from Baseline in [Score]
                 at Week 12 (MMRM)  —  ITT Population

                                    Placebo        Drug 10 mg
n                                   xx             xx
Baseline, Mean (SD)                 xx.x (xx.xx)   xx.x (xx.xx)
Week 12, Mean (SD)                  xx.x (xx.xx)   xx.x (xx.xx)
LS Mean change (SE)                 -xx.x (xx.x)   -xx.x (xx.x)
   Difference vs placebo (95% CI)                  -xx.x (-xx.x, -xx.x)
   p-value                                          0.xxx
```

Fonte: **BDS** (ADEFF/ADQS). População: **ITT** (ou mITT), a população de
eficácia definida no SAP.

## 6. Adverse events — o coração da segurança

Os **AEs** (*adverse events*) geram várias tabelas relacionadas. Duas ideias
governam todas elas:

- **MedDRA:** os AEs são codificados no dicionário **MedDRA** (*Medical
  Dictionary for Regulatory Activities*), que organiza cada evento numa
  hierarquia. Você trabalhará sobretudo com dois níveis: **SOC** (*System Organ
  Class*, a classe ampla, ex.: "Distúrbios gastrointestinais") e **PT**
  (*Preferred Term*, o termo específico, ex.: "Náusea"). As tabelas de AE são
  quase sempre organizadas **por SOC e, dentro dela, por PT**.
- **Treatment-emergent (TEAE):** só interessam à análise os eventos que
  **começaram ou pioraram após a primeira dose** — os *treatment-emergent
  adverse events*. Um evento que já existia antes de tratar não é atribuível ao
  tratamento. A flag `TRTEMFL = 'Y'` no ADAE marca esses eventos, e quase toda
  tabela de AE filtra por ela.

### 6a. Overview de TEAEs

O resumo de alto nível: quantos pacientes tiveram qualquer TEAE, TEAEs
relacionados, TEAEs sérios, TEAEs que levaram à descontinuação, mortes.

```text
Table 14.3.1.1  —  Overview of Treatment-Emergent Adverse Events
                   Safety Population

                                         Placebo      Drug 10 mg
                                         (N=xx)       (N=xx)
------------------------------------------------------------------
Any TEAE                               xx (xx.x)    xx (xx.x)
TEAE related to study drug             xx (xx.x)    xx (xx.x)
Serious TEAE (SAE)                     xx (xx.x)    xx (xx.x)
TEAE leading to discontinuation        xx (xx.x)    xx (xx.x)
TEAE leading to death                  xx (xx.x)    xx (xx.x)
------------------------------------------------------------------
[n (%) = número de PACIENTES com >=1 evento. Safety Population.]
```

### 6b. TEAEs por SOC e PT

O detalhamento: para cada SOC e cada PT dentro dela, o número de pacientes com
o evento. Ordenada por frequência decrescente (no braço ativo) é o padrão.

```text
Table 14.3.1.2  —  TEAEs by System Organ Class and Preferred Term
                   Safety Population

System Organ Class                       Placebo      Drug 10 mg
   Preferred Term                        (N=xx)       (N=xx)
------------------------------------------------------------------
Gastrointestinal disorders             xx (xx.x)    xx (xx.x)
   Nausea                              xx (xx.x)    xx (xx.x)
   Diarrhoea                           xx (xx.x)    xx (xx.x)
Nervous system disorders               xx (xx.x)    xx (xx.x)
   Headache                            xx (xx.x)    xx (xx.x)
------------------------------------------------------------------
```

### 6c. TEAEs por severidade e por relação

Variações da anterior, cruzando SOC/PT com **severidade** (mild/moderate/severe)
ou com a **relação** com a droga (related/not related). A regra de ouro:
quando um paciente tem o mesmo PT mais de uma vez, ele conta **uma vez** — e,
para severidade, pela **pior** severidade registrada.

### 6d. SAEs e AEs que levam à descontinuação

Tabelas separadas, no mesmo formato SOC/PT, filtrando respectivamente por
**sério** (`AESER='Y'`) e por **descontinuação** (`AEACN='DRUG WITHDRAWN'` ou
a flag equivalente). São de leitura obrigatória para o revisor de segurança.

## 7. Laboratório — shift tables e valores fora da faixa

Dados de laboratório geram dois formatos característicos:

- **Shift tables (tabelas de mudança):** cruzam a categoria do valor **no
  baseline** contra a categoria **pós-baseline** (Low / Normal / High), numa
  matriz. Mostram quantos pacientes "mudaram" de normal para alto, por exemplo.

```text
Table 14.3.x  —  Shift from Baseline in ALT  —  Drug 10 mg, Safety Population

                          Post-baseline (worst)
Baseline          Low       Normal      High      Total
-----------------------------------------------------------
Low               xx        xx          xx        xx
Normal            xx        xx          xx        xx
High              xx        xx          xx        xx
-----------------------------------------------------------
```

- **Valores fora da faixa / marcadamente anormais:** contagem de pacientes com
  valores acima ou abaixo dos limites de referência, ou que cruzaram limiares
  clínicos (ex.: ALT > 3x ULN — *upper limit of normal*).

Fonte: **BDS** (ADLB). População: **Safety**.

## 8. Sinais vitais e ECG

Mesma lógica do laboratório, com BDS (ADVS para sinais vitais, ADEG para ECG):
sumários de valor e de mudança em relação ao baseline por visita, mais tabelas
de valores potencialmente clínicos significativos (ex.: PA sistólica abaixo de
um limiar; para ECG, prolongamento de **QTc** acima de faixas pré-definidas).

> **Atenção:** o erro mais comum e mais grave neste catálogo é usar a
> **população ou o denominador errado**. Regra prática: tabelas de **disposição**
> em geral usam **All Randomized**; tabelas de **eficácia** usam **ITT/mITT**;
> **tudo de segurança** (exposição, AEs, laboratório, sinais vitais, ECG) usa a
> **Safety Population** (quem recebeu ao menos uma dose). E o percentual de `n
> (%)` usa o **N da coluna daquela população**, não o total do estudo. Errar a
> população não é um detalhe de formatação — muda o significado da tabela e é
> exatamente o tipo de coisa que reprova no QC.

## Resumo do capítulo

- Um punhado de tabelas se repete em quase todo CSR; dominá-las é chegar
  reconhecendo a maior parte do trabalho.
- Convenções universais: **`n (%)`** (denominador = N da coluna), **Média (DP)**
  e **Mediana [min, max]** para contínuas.
- A sequência canônica: **disposição → desvios → demografia/baseline →
  exposição → eficácia primária → AEs → laboratório → sinais vitais → ECG**.
- **AEs** são codificados em **MedDRA** (organizados por **SOC** e **PT**) e
  filtrados por **treatment-emergent** (`TRTEMFL='Y'`); um paciente conta uma
  vez por PT, pela pior severidade.
- **Laboratório, sinais vitais e ECG** produzem sumários de mudança e **shift
  tables** (baseline × pós-baseline), com fonte **BDS**.
- O ponto mais crítico: **população e denominador corretos** por tabela —
  All Randomized para disposição, ITT para eficácia, Safety para segurança.
