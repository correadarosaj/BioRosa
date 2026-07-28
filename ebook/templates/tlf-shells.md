# Shells de TLF — Coleção pronta para preencher

*Coleção de shells (mock-ups) das tabelas mais comuns num pacote de TLF de Fase
II/III. Cada shell traz: título no padrão `Table 14.x.x`, linha de população,
colunas por grupo de tratamento com `(N=xx)`, células com placeholders
(`<n (%)>`, `<média (DP)>`) e footnotes. Ajuste os rótulos de braço, o `N` e a
numeração ao seu estudo. Mantenha títulos e footnotes idênticos entre o shell e
a tabela final — divergência aqui é achado clássico de QC. A numeração 14.x segue
a convenção da Seção 14 do CSR (ICH E3).*

> **Convenção de placeholders:** `<n (%)>` = contagem e percentual;
> `<média (DP)>` = mean (SD); `xx.x` = valor numérico com 1 decimal. Substitua o
> `(N=xx)` de cada coluna pelo tamanho real da população naquele braço.

---

## Table 14.1.1 — Subject Disposition

**Population: All Randomized Subjects**

| | Placebo (N=xx) | Treatment A (N=xx) | Total (N=xx) |
|---|---|---|---|
| Randomized, n | xx | xx | xx |
| Treated (received ≥1 dose), n (%) | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| Completed treatment, n (%) | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| Discontinued treatment, n (%) | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Adverse event | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Lack of efficacy | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Withdrawal by subject | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Lost to follow-up | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Other | `<n (%)>` | `<n (%)>` | `<n (%)>` |

*Percentages are based on the number of randomized subjects in each column.
Program: `<prog.sas/R>`  Source: ADSL  Run: `<dd-mmm-aaaa hh:mm>`*

---

## Table 14.1.2 — Demographics and Baseline Characteristics

**Population: Intention-to-Treat (ITT)**

| Characteristic | Placebo (N=xx) | Treatment A (N=xx) | Total (N=xx) |
|---|---|---|---|
| **Age (years)** | | | |
| &nbsp;&nbsp;n | xx | xx | xx |
| &nbsp;&nbsp;Mean (SD) | `<média (DP)>` | `<média (DP)>` | `<média (DP)>` |
| &nbsp;&nbsp;Median | xx.x | xx.x | xx.x |
| &nbsp;&nbsp;Min, Max | xx, xx | xx, xx | xx, xx |
| **Age group, n (%)** | | | |
| &nbsp;&nbsp;< 65 years | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;≥ 65 years | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| **Sex, n (%)** | | | |
| &nbsp;&nbsp;Male | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Female | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| **Race, n (%)** | | | |
| &nbsp;&nbsp;White | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Black or African American | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Asian | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Other | `<n (%)>` | `<n (%)>` | `<n (%)>` |
| **Baseline `<parâmetro>`** | | | |
| &nbsp;&nbsp;Mean (SD) | `<média (DP)>` | `<média (DP)>` | `<média (DP)>` |

*Percentages are based on the number of ITT subjects in each column. No formal
statistical comparisons are performed. Program: `< >`  Source: ADSL*

---

## Table 14.3.1 — Extent of Exposure

**Population: Safety**

| | Placebo (N=xx) | Treatment A (N=xx) |
|---|---|---|
| **Duration of exposure (days)** | | |
| &nbsp;&nbsp;Mean (SD) | `<média (DP)>` | `<média (DP)>` |
| &nbsp;&nbsp;Median | xx.x | xx.x |
| &nbsp;&nbsp;Min, Max | xx, xx | xx, xx |
| **Cumulative exposure, n (%)** | | |
| &nbsp;&nbsp;≥ 1 day | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;≥ 4 weeks | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;≥ 12 weeks | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;≥ 24 weeks | `<n (%)>` | `<n (%)>` |
| **Total subject-time (subject-years)** | xx.x | xx.x |

*Duration of exposure = (last dose date − first dose date + 1). Percentages
based on Safety population in each column. Program: `< >`  Source: ADEX / EX*

---

## Table 14.3.2 — Overview of Treatment-Emergent Adverse Events

**Population: Safety**

| Category | Placebo (N=xx) n (%) | Treatment A (N=xx) n (%) |
|---|---|---|
| Any TEAE | `<n (%)>` | `<n (%)>` |
| TEAE related to study drug | `<n (%)>` | `<n (%)>` |
| Serious TEAE (SAE) | `<n (%)>` | `<n (%)>` |
| TEAE leading to discontinuation | `<n (%)>` | `<n (%)>` |
| TEAE leading to death | `<n (%)>` | `<n (%)>` |
| TEAE by maximum severity | | |
| &nbsp;&nbsp;Mild | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Moderate | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;Severe | `<n (%)>` | `<n (%)>` |

*A TEAE is any adverse event with onset on or after the first dose of study
drug. Subjects are counted once within each category at the most severe / most
related level. Percentages based on Safety population. MedDRA version `<xx.x>`.
Program: `< >`  Source: ADAE*

---

## Table 14.3.3 — Treatment-Emergent Adverse Events by System Organ Class and Preferred Term

**Population: Safety**

*Subjects with events in each SOC/PT are counted once. Rows are ordered by
descending frequency in the total/Treatment A column. Show SOCs and PTs meeting
the reporting threshold defined in the SAP (e.g. ≥ 5% in any arm).*

| System Organ Class / Preferred Term | Placebo (N=xx) n (%) | Treatment A (N=xx) n (%) |
|---|---|---|
| **Subjects with any TEAE** | `<n (%)>` | `<n (%)>` |
| **`<System Organ Class 1>`** | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;`<Preferred Term 1a>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;`<Preferred Term 1b>` | `<n (%)>` | `<n (%)>` |
| **`<System Organ Class 2>`** | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;`<Preferred Term 2a>` | `<n (%)>` | `<n (%)>` |
| &nbsp;&nbsp;`<Preferred Term 2b>` | `<n (%)>` | `<n (%)>` |

*Coded using MedDRA version `<xx.x>`. A subject is counted once per SOC and once
per PT, regardless of the number of events. Percentages based on Safety
population. Program: `< >`  Source: ADAE*

---

## Table 14.3.x — Laboratory Shift Table (Baseline to Worst Post-Baseline)

**Population: Safety**

*Shift from baseline category to worst post-baseline category for `<parâmetro,
ex.: ALT>`. Categories relative to the normal range: Low / Normal / High.*

**Treatment A (N=xx)**

| Baseline \ Worst post-baseline | Low n (%) | Normal n (%) | High n (%) | Missing n (%) | Total |
|---|---|---|---|---|---|
| Low | `<n (%)>` | `<n (%)>` | `<n (%)>` | `<n (%)>` | xx |
| Normal | `<n (%)>` | `<n (%)>` | `<n (%)>` | `<n (%)>` | xx |
| High | `<n (%)>` | `<n (%)>` | `<n (%)>` | `<n (%)>` | xx |
| Missing | `<n (%)>` | `<n (%)>` | `<n (%)>` | `<n (%)>` | xx |
| **Total** | xx | xx | xx | xx | xx |

*Repeat an analogous block for each treatment arm and each laboratory parameter.
Categories based on the central laboratory reference ranges. Percentages based on
subjects with a non-missing baseline value. Program: `< >`  Source: ADLB*

---

> **Na prática:** os títulos, footnotes e a ordem das colunas destes shells devem
> ser aprovados **antes** da programação. O programador reproduz o layout
> exatamente e apenas preenche os números a partir do ADaM. É por isso que o
> shell existe: separar a decisão de "o que a tabela mostra" da tarefa de
> "calcular os valores".
