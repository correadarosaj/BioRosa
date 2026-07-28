# SDTM em profundidade

Agora que você tem o mapa, vamos entrar na primeira grande peça: o **SDTM**, o
*Study Data Tabulation Model*. É aqui que os dados coletados do estudo ganham
forma padronizada. Se você vai trabalhar como *Statistical Programmer*, SDTM
será boa parte do seu pão de cada dia. Se vai ser *Biostatistician*, precisa
entender SDTM para saber de onde vêm os dados que você analisa. Este capítulo é
o tour organizado por dentro dele.

## O que é SDTM, em uma frase

SDTM é o padrão que define **como os dados observados de um ensaio clínico são
tabulados** — ou seja, organizados em tabelas (datasets) com estrutura, nomes de
variáveis e conteúdo padronizados. A palavra-chave é *tabulation*: SDTM é uma
**fotografia estruturada do que aconteceu** com cada sujeito, fiel à coleta, com
o mínimo de transformação. Derivações de análise não moram aqui — elas ficam no
ADaM (próximo capítulo).

Cada dataset SDTM é um **domínio** (*domain*), identificado por um código de
duas letras. Você já viu alguns: **DM**, **AE**, **LB**. Vamos organizá-los.

## As classes de observação

O SDTM agrupa os domínios em **classes de observação** (*observation classes*).
Entender a classe ajuda a prever a estrutura do domínio antes mesmo de abri-lo.

- **Interventions** — o que foi **dado ao ou feito com** o sujeito: tratamentos,
  exposições, medicações. Domínios: **EX** (Exposure), **CM** (Concomitant
  Medications), **EC** (Exposure as Collected), entre outros.
- **Events** — o que **aconteceu com** o sujeito: eventos e ocorrências.
  Domínios: **AE** (Adverse Events), **MH** (Medical History), **DS**
  (Disposition).
- **Findings** — o que foi **medido, testado ou avaliado**: exames, medições,
  respostas. Domínios: **LB** (Laboratory), **VS** (Vital Signs), **EG** (ECG),
  **QS** (Questionnaires), entre muitos outros. É a classe mais numerosa.
- **Special Purpose** — domínios com estrutura própria que não se encaixam nas
  três classes acima: **DM** (Demographics), **CO** (Comments), **SE**
  (Subject Elements), **SV** (Subject Visits).
- **Trial Design** — descrevem o **desenho planejado** do estudo (não os
  sujeitos): **TA** (Trial Arms), **TE** (Trial Elements), **TV** (Trial
  Visits), **TS** (Trial Summary), **TI** (Trial Inclusion/Exclusion).

> **Glossário PT/EN:** *Findings* (EN) = classe de domínios de "achados" —
> medições e testes (laboratório, sinais vitais, ECG). *Interventions* (EN) =
> "intervenções" — o que foi administrado. *Events* (EN) = "eventos" — o que
> ocorreu.

## Os domínios principais

Você não precisa decorar os mais de cem domínios existentes. Precisa conhecer
bem estes, que aparecem em praticamente todo estudo:

| Domínio | Nome | Classe | O que contém |
|---|---|---|---|
| **DM** | Demographics | Special Purpose | Um registro por sujeito: idade, sexo, raça, braço, datas de referência |
| **AE** | Adverse Events | Events | Eventos adversos: termo, gravidade, seriedade, relação com o tratamento |
| **CM** | Concomitant Medications | Interventions | Medicações concomitantes usadas pelo sujeito |
| **EX** | Exposure | Interventions | Exposição ao tratamento do estudo: dose, unidade, datas |
| **LB** | Laboratory Test Results | Findings | Resultados de exames laboratoriais |
| **VS** | Vital Signs | Findings | Sinais vitais: pressão, frequência cardíaca, temperatura, peso |
| **MH** | Medical History | Events | História médica prévia do sujeito |
| **EG** | ECG Test Results | Findings | Resultados de eletrocardiograma |
| **DS** | Disposition | Events | Situação do sujeito no estudo: conclusão, descontinuação e motivo |

## Variáveis identificadoras e a estrutura de nomes

Alguns identificadores aparecem em (quase) todos os domínios e são a espinha
dorsal do SDTM:

- **STUDYID** — identificador do estudo.
- **DOMAIN** — o código de duas letras do domínio (`DM`, `AE`, `VS`...). Toda
  linha de um domínio carrega o próprio código.
- **USUBJID** — *Unique Subject Identifier*, o **identificador único do
  sujeito** em toda a submissão. É a chave que amarra um mesmo paciente através
  de todos os domínios e estudos.
- **SUBJID** — o identificador do sujeito **dentro do estudo/site** (mais curto,
  local). Note a diferença: `SUBJID` é local; `USUBJID` é global e único.
- **--SEQ** — número de sequência que torna cada registro único dentro do
  domínio para um sujeito (ex.: `AESEQ`, `VSSEQ`, `LBSEQ`).

Repare no padrão de nomes: as variáveis de um domínio usam o **prefixo de duas
letras do domínio + um sufixo** que descreve o conteúdo. Esse prefixo é o `--`
que você verá em documentação CDISC. Por exemplo, no domínio VS:

- `VSTESTCD` — código do teste (ex.: `SYSBP`, `DIABP`, `PULSE`, `TEMP`).
- `VSTEST` — nome do teste por extenso (ex.: `Systolic Blood Pressure`).
- `VSORRES` — resultado **original** como coletado (*original result*).
- `VSORRESU` — unidade do resultado original.
- `VSSTRESN` — resultado padronizado, numérico (*standardized result, numeric*).
- `VSSTRESC` — resultado padronizado, em caractere.
- `VISITNUM` / `VISIT` — número e nome da visita.
- `VSDTC` — data/hora da coleta (formato ISO 8601).

Os mesmos sufixos reaparecem em outros domínios de Findings: `LBTESTCD`,
`LBORRES`, `LBSTRESN` no laboratório; `EGTESTCD`, `EGORRES` no ECG. Aprender o
padrão de uma vez economiza decorar cem variáveis.

## Estrutura vertical (long) dos domínios de Findings

Aqui está um ponto conceitual que confunde muita gente vinda da estatística
acadêmica, onde estamos acostumados a dados "largos" (uma coluna por variável).

Os domínios de **Findings** são estruturados de forma **vertical / long**: **um
registro por observação**. Não existe uma coluna "pressão sistólica" e outra
"pressão diastólica". Existe uma coluna `VSTESTCD` que diz *qual* medida é, e uma
coluna `VSSTRESN` que diz *qual o valor*. Cada medida vira uma **linha**.

Ou seja: se num paciente, numa visita, você mediu pressão sistólica, diastólica
e pulso, isso são **três linhas** no VS — não uma linha com três colunas. É o
formato "chave-valor" empilhado, e ele se repete em LB, EG, QS e todos os
Findings. Guardar isso evita muita confusão quando você abrir um dataset SDTM
pela primeira vez e estranhar "por que está tudo empilhado".

## Exemplos de linhas

Um recorte de **DM** (Special Purpose, um registro por sujeito):

```text
STUDYID   DOMAIN  USUBJID           SUBJID  AGE  AGEU   SEX  RACE   ARMCD  ARM        COUNTRY
ABC-101   DM      ABC-101-001-0001  0001    54   YEARS  M    WHITE  TRT    Drug X     BRA
ABC-101   DM      ABC-101-001-0002  0002    61   YEARS  F    BLACK  PBO    Placebo    BRA
ABC-101   DM      ABC-101-002-0001  0001    47   YEARS  F    ASIAN  TRT    Drug X     USA
```

Um recorte de **VS** (Findings, estrutura vertical — note as múltiplas linhas
por sujeito/visita, uma por medida):

```text
STUDYID  DOMAIN  USUBJID           VSSEQ  VSTESTCD  VSTEST                    VSORRES  VSORRESU  VSSTRESN  VSSTRESU  VISIT      VSDTC
ABC-101  VS      ABC-101-001-0001  1      SYSBP     Systolic Blood Pressure   128      mmHg      128       mmHg      BASELINE   2025-03-10
ABC-101  VS      ABC-101-001-0001  2      DIABP     Diastolic Blood Pressure  82       mmHg      82        mmHg      BASELINE   2025-03-10
ABC-101  VS      ABC-101-001-0001  3      PULSE     Pulse Rate                72       beats/min 72        beats/min BASELINE   2025-03-10
ABC-101  VS      ABC-101-001-0001  4      SYSBP     Systolic Blood Pressure   119      mmHg      119       mmHg      WEEK 4     2025-04-07
```

Repare em `VSSTRESN`/`VSSTRESU`: a coluna padronizada existe justamente para
reconciliar unidades quando sites diferentes coletam em unidades diferentes. O
`VSORRES` guarda o que foi coletado; o `VSSTRESN` guarda o valor comparável.

## Erros comuns

- **Embutir derivação de análise no SDTM.** Baseline, mudança em relação ao
  baseline, flags de população — nada disso é SDTM. É ADaM. SDTM tabula, não
  analisa.
- **Confundir SUBJID com USUBJID.** `SUBJID` é local ao site/estudo; pode se
  repetir entre sites. `USUBJID` tem de ser único em toda a submissão.
- **Ignorar a Controlled Terminology.** Valores de variáveis codificadas
  (`SEX`, `VSTESTCD`, unidades) precisam vir dos vocabulários controlados. "Male"
  onde a CT pede `M` é uma não conformidade.
- **Datas fora do ISO 8601.** As variáveis `--DTC` usam formato ISO 8601
  (`AAAA-MM-DD` e derivados). Datas em outro formato quebram a validação.
- **Esquecer o `--SEQ`.** Cada registro precisa de sequência única por sujeito
  dentro do domínio.

> **Atenção:** o **USUBJID** é sagrado. Ele é a chave que costura o mesmo
> paciente através de DM, AE, VS, LB, EX e todos os outros domínios — e, num
> programa clínico, através de vários estudos. Se o USUBJID não for
> verdadeiramente único e consistente, toda a rastreabilidade desmorona: você não
> consegue mais garantir que a linha de AE e a linha de VS pertencem à mesma
> pessoa. Construa e verifique o USUBJID com paranoia.

## Resumo do capítulo

- **SDTM** (*Study Data Tabulation Model*) organiza os **dados observados** do
  estudo em **domínios** de duas letras — uma fotografia fiel do que aconteceu,
  sem derivação de análise.
- Os domínios se agrupam em classes: **Interventions** (EX, CM), **Events** (AE,
  MH, DS), **Findings** (LB, VS, EG), **Special Purpose** (DM) e **Trial
  Design** (TA, TS...).
- Domínios essenciais: **DM, AE, CM, EX, LB, VS, MH, EG, DS**.
- Identificadores-chave: **STUDYID, DOMAIN, USUBJID, SUBJID** e **--SEQ**; as
  variáveis seguem o padrão **prefixo do domínio + sufixo** (`VSTESTCD`,
  `LBORRES`...).
- Domínios de **Findings** são **verticais/long**: um registro por observação
  (`VSTESTCD` diz qual medida, `VSSTRESN` diz o valor).
- Erros comuns: derivar análise no SDTM, confundir SUBJID/USUBJID, ignorar a
  Controlled Terminology e usar datas fora do ISO 8601.
- O **USUBJID** único é o que sustenta toda a rastreabilidade — trate-o com
  rigor absoluto.
