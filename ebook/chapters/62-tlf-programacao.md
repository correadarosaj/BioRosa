# Produzindo TLFs na prática: SAS e R lado a lado

Chega de esqueletos vazios — agora vamos preencher os números. Neste capítulo
você programa três tabelas concretas a partir de datasets ADaM, **cada uma em
SAS e em R**, e compara as duas filosofias. Não decore a sintaxe; entenda o
padrão. O padrão se repete em quase tudo que você vai fazer.

Vamos assumir dois datasets ADaM já prontos (a construção do ADaM é assunto de
outra Parte deste livro):

- **`ADSL`** — uma linha por paciente. Variáveis relevantes: `TRT01A` (braço de
  tratamento, versão texto), `TRT01AN` (versão numérica para ordenar), `SAFFL`
  (flag de segurança, `'Y'/'N'`), `AGE`, `SEX`, `RACE`.
- **`ADAE`** — um AE por linha. Variáveis: `USUBJID`, `TRTA`, `SAFFL`,
  `TRTEMFL` (treatment-emergent), `AESER` (sério), `AEDECOD` (Preferred Term),
  `AEBODSYS` (System Organ Class).

## Tabela 1 — Demografia e baseline (contínua + categórica)

O objetivo: idade (`Mean (SD)`, `Median`, `Min, Max`) e sexo (`n (%)`), por
braço, na Safety Population.

### Em SAS

A abordagem clássica em SAS é **calcular** as estatísticas com uma PROC
(`MEANS`/`SUMMARY` para contínuas, `FREQ` para categóricas), empilhar os
resultados num dataset e **renderizar** com **PROC REPORT**. Mostrando as peças
de cálculo, sem a montagem completa:

```sas
/* Contínua: idade */
proc means data=adsl(where=(saffl='Y')) noprint;
    class trt01an trt01a;
    var age;
    output out=age_stats
           n=n mean=mean std=sd median=median min=min max=max;
run;

/* Categórica: sexo */
proc freq data=adsl(where=(saffl='Y')) noprint;
    tables trt01an*trt01a*sex / out=sex_freq outpct;
run;

/* Renderização final (esqueleto) */
proc report data=final_stacked nowd;
    column label ('Treatment' col_placebo col_drug);
    define label / display 'Characteristic';
    /* ... colunas por braço, formatos xx.x (xx.xx), n (xx.x) ... */
run;
```

Note o padrão SAS: **cada estatística é um passo**, você monta a tabela
literalmente célula a célula e controla a formatação com `PROC REPORT`. É
verboso, mas dá controle total sobre cada caractere — motivo de o FDA ter
convivido com SAS por décadas.

### Em R

Em R, a rota mais direta para tabelas descritivas é o pacote **gtsummary**, que
com uma única chamada produz a tabela inteira já formatada:

```r
library(gtsummary)
library(dplyr)

adsl |>
  filter(SAFFL == "Y") |>
  select(TRT01A, AGE, SEX) |>
  tbl_summary(
    by = TRT01A,
    statistic = list(
      AGE ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p})"
    ),
    label = list(AGE ~ "Age (years)", SEX ~ "Sex"),
    digits = list(AGE ~ c(1, 2))
  ) |>
  add_overall() |>
  modify_header(label ~ "**Characteristic**")
```

Uma chamada, a tabela pronta. A diferença de filosofia é gritante: SAS
**constrói** a tabela; gtsummary **declara** a tabela e a biblioteca a monta.

### Output esperado (as duas produzem)

| Characteristic | Placebo (N=98) | Drug 10 mg (N=101) | Overall (N=199) |
|---|---|---|---|
| Age (years), Mean (SD) | 54.2 (12.31) | 53.8 (11.90) | 54.0 (12.10) |
| Median | 55.0 | 54.0 | 54.0 |
| Min, Max | 22, 78 | 24, 80 | 22, 80 |
| Sex, n (%) | | | |
| &nbsp;&nbsp;Male | 51 (52.0) | 55 (54.5) | 106 (53.3) |
| &nbsp;&nbsp;Female | 47 (48.0) | 46 (45.5) | 93 (46.7) |

## Tabela 2 — Overview de TEAEs

O objetivo: número de **pacientes** (contagem única) com qualquer TEAE, TEAE
sério e assim por diante, por braço, na Safety Population. O detalhe crítico é
a **contagem de sujeitos únicos**: um paciente com cinco AEs conta uma vez.

### Em SAS

O truque é reduzir o ADAE a um paciente por linha por categoria antes de contar.
Usa-se `PROC SQL` com `COUNT(DISTINCT USUBJID)` ou uma deduplicação com
`PROC SORT NODUPKEY`, e depois `PROC FREQ`:

```sas
proc sql;
    create table teae_any as
    select trta,
           count(distinct usubjid) as n_any
    from adae
    where saffl='Y' and trtemfl='Y'
    group by trta;

    create table teae_ser as
    select trta,
           count(distinct usubjid) as n_ser
    from adae
    where saffl='Y' and trtemfl='Y' and aeser='Y'
    group by trta;
quit;

/* denominador vem do ADSL (N da Safety Population por braço) */
proc freq data=adsl(where=(saffl='Y')) noprint;
    tables trt01a / out=denom;
run;
/* junta n_any/n_ser com denom, calcula %, renderiza com PROC REPORT */
```

O ponto de atenção é o **denominador**: ele vem do `ADSL` (todos os pacientes
de segurança), **não** do `ADAE` (só os que tiveram algum evento). Confundir os
dois é um erro clássico que infla os percentuais.

### Em R

Aqui vale mostrar o ecossistema **pharmaverse**: os pacotes **rtables** e
**tern** foram desenhados especificamente para tabelas clínicas regulatórias.
Para um overview simples, gtsummary também resolve, contando pacientes únicos:

```r
library(dplyr)
library(gtsummary)

# um flag por paciente por categoria, no nível do sujeito
ae_subj <- adae |>
  filter(SAFFL == "Y", TRTEMFL == "Y") |>
  group_by(USUBJID, TRTA) |>
  summarise(
    any_teae = TRUE,
    serious  = any(AESER == "Y"),
    .groups  = "drop"
  )

# reanexa ao ADSL para preservar o denominador da Safety Population
adsl |>
  filter(SAFFL == "Y") |>
  left_join(ae_subj, by = c("USUBJID", "TRT01A" = "TRTA")) |>
  mutate(across(c(any_teae, serious), ~ coalesce(., FALSE))) |>
  select(TRT01A, any_teae, serious) |>
  tbl_summary(
    by = TRT01A,
    statistic = all_categorical() ~ "{n} ({p})",
    label = list(any_teae ~ "Any TEAE", serious ~ "Serious TEAE")
  )
```

Observe que o `left_join` a partir do ADSL é o que garante o denominador
correto: pacientes sem nenhum AE entram com `FALSE`, e continuam no
denominador. Em `rtables`/`tern`, o mesmo se faz com layouts explícitos
(`analyze`, `summarize_row_groups`) — mais verboso, porém mais próximo do
controle fino que ambientes regulados exigem em tabelas complexas de AE.

### Output esperado

| Event category | Placebo (N=98) | Drug 10 mg (N=101) |
|---|---|---|
| Any TEAE | 61 (62.2) | 74 (73.3) |
| Serious TEAE | 5 (5.1) | 8 (7.9) |
| TEAE leading to discontinuation | 3 (3.1) | 7 (6.9) |

## Tabela 3 — Resultado de eficácia (contínuo por braço)

Para o endpoint contínuo, o cerne é ajustar o **modelo** pré-especificado
(ANCOVA ou MMRM) e extrair a estimativa do efeito. Mostrando o esqueleto do
modelo, não a tabela renderizada:

```sas
/* ANCOVA: mudança no endpoint ajustada por baseline e braço */
proc mixed data=adeff(where=(ittfl='Y' and avisitn=12 and paramcd='SCORE'));
    class trtpn(ref='0');
    model chg = base trtpn / solution;
    lsmeans trtpn / diff cl;
run;
```

```r
library(emmeans)

fit <- lm(CHG ~ BASE + TRTPN,
          data = subset(adeff, ITTFL == "Y" & AVISITN == 12 & PARAMCD == "SCORE"))

emmeans(fit, "TRTPN") |>
  contrast("trt.vs.ctrl", ref = 1) |>
  summary(infer = TRUE)   # LS mean difference, 95% CI, p-value
```

Repare que **a estatística é a mesma**: um modelo linear com baseline como
covariável, LS means, diferença com IC e p-valor. SAS usa `PROC MIXED` +
`LSMEANS`; R usa `lm` + `emmeans`. Números idênticos, dialetos diferentes.

## Duas filosofias, um resultado

O contraste que você deve levar deste capítulo:

| | SAS | R (tidyverse/pharmaverse) |
|---|---|---|
| Estilo | Imperativo: constrói a tabela passo a passo | Declarativo: descreve a tabela, a lib monta |
| Descritivas | `PROC MEANS`/`FREQ` + `PROC REPORT` | `gtsummary::tbl_summary` |
| Tabelas clínicas complexas | `PROC REPORT` sob medida | `rtables` + `tern` |
| Modelagem | `PROC MIXED`, `PROC GLM`, `PROC FREQ` | `lm`, `nlme`/`mmrm`, `emmeans` |
| Controle de formatação | Total, caractere a caractere | Alto, via camadas da biblioteca |

## Por que o FDA aceita R — e por que você quer saber os dois

Durante décadas, "software regulatório" era sinônimo de SAS. Isso mudou. O FDA
**não exige uma linguagem específica**: a orientação da agência é que a
submissão seja **transparente e reproduzível** — que o revisor consiga
reexecutar o código sobre os dados e chegar aos mesmos números. R atende a isso.

O que destravou o R na prática foi o **pharmaverse**, um conjunto de pacotes
open-source mantidos com rigor de indústria, com validação e documentação
pensadas para o contexto regulado:

- **admiral** — construção de datasets **ADaM** de forma padronizada;
- **rtables** e **tern** — tabelas clínicas (os TLFs) com layouts controlados;
- pacotes de suporte para métodos específicos (ex.: **mmrm** para modelos
  mistos de medidas repetidas).

Houve inclusive submissões-piloto ao FDA feitas inteiramente em R
(o *R Consortium Submissions Pilot*), demonstrando que um pacote R completo
pode ser aceito. O ponto para você não é "R substituiu SAS" — os dois convivem,
e muita big pharma roda ambos.

> **Dica de carreira:** o mercado ainda tem uma base enorme de SAS legado, e ao
> mesmo tempo uma onda crescente de adoção de R via pharmaverse. Quem sabe
> **só um** disputa metade das vagas; quem transita entre **os dois** vira a
> pessoa que faz a ponte — migra código legado, valida uma linguagem contra a
> outra (o próprio SAS-vs-R já é uma forma de QC independente) e conversa com
> times mistos. Para um brasileiro entrando agora, aprender R (grátis, com o
> pharmaverse documentado) e SAS (o padrão que ainda paga a conta) ao mesmo
> tempo é uma das maneiras mais eficientes de se diferenciar.

## Resumo do capítulo

- Todo TLF sai de um **ADaM**; o primeiro passo é sempre identificar a fonte
  (`ADSL`, `ADAE`, BDS) e a **flag de população**.
- **SAS** é imperativo — `PROC MEANS`/`FREQ` calculam, `PROC REPORT` renderiza,
  célula a célula. **R** é declarativo — `gtsummary::tbl_summary` monta a tabela
  a partir de uma descrição.
- Em tabelas de **AE**, a regra de ouro é **contar pacientes únicos** e puxar o
  **denominador do ADSL** (Safety Population), não do dataset de eventos.
- Para eficácia, a **estatística é a mesma** nas duas linguagens (modelo linear
  + LS means + IC + p): `PROC MIXED`/`LSMEANS` em SAS, `lm`/`emmeans` em R.
- O **pharmaverse** (admiral, rtables, tern) tornou o R viável para submissão;
  o FDA aceita R porque exige **reprodutibilidade**, não uma linguagem.
- Saber **SAS e R** amplia muito o leque de vagas e te posiciona como a ponte
  entre o legado e o futuro.
