# ADaM em profundidade

Se o SDTM é a fotografia do que aconteceu, o **ADaM** é a mesa posta para o
estatístico. É o padrão que transforma dados tabulados em **dados prontos para
análise** — com baselines calculados, populações definidas, mudanças derivadas,
flags de quais registros entram em cada teste. Quando o ADaM está bem feito,
produzir as tabelas finais é quase mecânico. Este é o capítulo que mais
importa para quem quer entender a ponte entre o dado e o resultado.

## O que é ADaM

**ADaM** é o *Analysis Data Model* — o padrão CDISC para os **datasets de
análise**. Enquanto o SDTM responde "o que aconteceu", o ADaM responde "como
analisamos". Ele deriva do SDTM (nunca o contrário) e é construído com um
objetivo explícito: **alimentar as tabelas, listagens e figuras (TLFs)** com o
mínimo de programação adicional.

### Os princípios do ADaM

Três princípios definem o padrão e valem gravar:

- **Traceability (rastreabilidade)** — cada variável derivada no ADaM deve poder
  ser rastreada de volta ao SDTM (e, por ele, ao CRF). Nada de valores que
  "aparecem do nada".
- **Analysis-ready (pronto para análise)** — o dataset deve conter tudo o que a
  análise precisa, de forma que a tabela seja produzida com o mínimo de
  manipulação. Idealmente, "um passo" separa o ADaM da tabela.
- **Metadados claros e autoexplicativos** — as variáveis, populações e
  derivações são documentadas de forma que um revisor entenda o dataset sem
  precisar ler o código de programação.

> **Glossário PT/EN:** *Analysis-ready* (EN) = "pronto para análise" — o dataset
> já contém baseline, mudança, flags e populações, de modo que a tabela sai quase
> direto. *Derivation* (EN) = "derivação" — a regra que produz uma variável
> calculada a partir de outras.

## ADSL — o dataset que sustenta tudo

O coração do ADaM é o **ADSL** (*Subject-Level Analysis Dataset*): **um registro
por sujeito**, sempre. Todo programa de submissão tem um ADSL, e ele é o dataset
de referência para as características do sujeito, os braços de tratamento e as
populações de análise. Praticamente toda tabela puxa alguma variável do ADSL.

Variáveis típicas do ADSL:

- **Tratamento planejado vs recebido:** `TRT01P` (*planned treatment* do período
  1), `TRT01A` (*actual treatment* do período 1). A distinção planejado
  vs recebido é central em análises por ITT vs por protocolo.
- **Flags de população:** valores `Y`/`N` que marcam a quais populações de
  análise o sujeito pertence. Ex.: `ITTFL` (*Intent-To-Treat Flag*), `SAFFL`
  (*Safety Population Flag*), `FASFL` (*Full Analysis Set Flag*), `PPROTFL`
  (*Per-Protocol Flag*). Essas flags são o que define quem entra em cada tabela.
- **Datas de referência:** `TRTSDT` (data de início do tratamento), `TRTEDT`
  (data de fim), `RFSTDTC`/`RFENDTC` herdadas do SDTM. Servem de âncora para
  calcular dias de estudo em outros datasets.
- **Características demográficas** trazidas para o nível do sujeito para facilitar
  subgrupos: `AGE`, `SEX`, `RACE`, e versões agrupadas como `AGEGR1`.

Um recorte de **ADSL** (um registro por sujeito):

```text
STUDYID  USUBJID           TRT01P    TRT01A    ITTFL  SAFFL  AGE  AGEGR1  SEX  TRTSDT      TRTEDT
ABC-101  ABC-101-001-0001  Drug X    Drug X    Y      Y      54   >=50    M    2025-03-10  2025-06-02
ABC-101  ABC-101-001-0002  Placebo   Placebo   Y      Y      61   >=50    F    2025-03-11  2025-06-05
ABC-101  ABC-101-002-0001  Drug X    Placebo   Y      Y      47   <50     F    2025-03-12  2025-05-20
```

Repare na terceira linha: `TRT01P` é `Drug X` mas `TRT01A` é `Placebo` — o
sujeito foi randomizado para a droga mas recebeu placebo (erro de dispensação,
por exemplo). O ADaM captura essa diferença explicitamente, e é ela que decide
se a análise ITT (usa o planejado) e a análise de segurança (usa o recebido)
tratam esse sujeito de formas diferentes.

## BDS — a estrutura para endpoints longitudinais

Para endpoints de eficácia medidos ao longo do tempo (pressão arterial ao longo
das visitas, escore de um questionário, um valor de laboratório), o ADaM usa a
**BDS** (*Basic Data Structure*). É a estrutura vertical/long do mundo da
análise — parente do formato de Findings do SDTM, mas agora com as variáveis de
análise derivadas.

Variáveis centrais da BDS:

- **PARAM / PARAMCD** — o **parâmetro** analisado, por extenso (`PARAM`) e em
  código (`PARAMCD`). Ex.: `PARAMCD = SYSBP`, `PARAM = Systolic Blood Pressure
  (mmHg)`. Cada parâmetro é uma "família" de linhas.
- **AVAL / AVALC** — o **valor de análise**, numérico (`AVAL`) ou caractere
  (`AVALC`). É o número que a tabela efetivamente usa.
- **AVISIT / AVISITN** — a **visita de análise**, por extenso e numérica. Note:
  é a visita *de análise*, que pode diferir da visita coletada (janelas de
  visita, *visit windowing*, são resolvidas aqui).
- **BASE** — o **valor de baseline** do parâmetro para aquele sujeito (repetido
  em todas as linhas pós-baseline daquele parâmetro).
- **ABLFL** — *Analysis Baseline Flag* (`Y` na linha que **é** o baseline).
- **CHG** — a **mudança** em relação ao baseline (`AVAL − BASE`).
- **PCHG** — a mudança **percentual** em relação ao baseline.

Um recorte de **BDS** (um parâmetro, um sujeito, ao longo das visitas):

```text
USUBJID           PARAMCD  PARAM                     AVISIT     AVAL  BASE  ABLFL  CHG   TRTP
ABC-101-001-0001  SYSBP    Systolic BP (mmHg)        Baseline   128   128   Y            Drug X
ABC-101-001-0001  SYSBP    Systolic BP (mmHg)        Week 4     119   128          -9    Drug X
ABC-101-001-0001  SYSBP    Systolic BP (mmHg)        Week 8     115   128          -13   Drug X
ABC-101-001-0001  SYSBP    Systolic BP (mmHg)        Week 12    112   128          -16   Drug X
```

Veja como tudo o que a tabela de "mudança na pressão sistólica por visita"
precisa já está pronto: `AVAL`, `BASE`, `CHG`, a visita de análise e o braço de
tratamento. O estatístico só precisa agrupar por `AVISIT` e `TRTP` e resumir.

## OCCDS — a estrutura para AEs e concomitantes

Para dados de **ocorrência** — eventos adversos, medicações concomitantes — o
ADaM usa a **OCCDS** (*Occurrence Data Structure*). Aqui não faz sentido falar em
`AVAL`/`BASE`/`CHG`: o que importa é *se* e *quantas vezes* algo ocorreu, e como
esses eventos são contados nas tabelas.

O dataset de AEs de análise é o **ADAE**, tipicamente derivado do domínio SDTM
**AE**, enriquecido com variáveis de análise. Elementos típicos:

- Termos do dicionário MedDRA já mapeados: `AEDECOD` (*preferred term*),
  `AEBODSYS` (*system organ class*).
- Flags de análise específicas: por exemplo, uma flag marcando o **primeiro**
  registro de cada termo por sujeito, usada para contar sujeitos (não eventos)
  sem dupla contagem numa tabela de incidência.
- Variáveis de tratamento (`TRTA`/`TRTP`) trazidas do ADSL, para que a tabela
  possa quebrar por braço.
- Categorizações de gravidade, seriedade e relação com o tratamento, alinhadas à
  Controlled Terminology.

O princípio das **flags de análise** vale para toda a OCCDS: em vez de o programa
da tabela decidir "quais registros contam", o ADaM já marca isso com uma flag, e
a tabela apenas filtra por ela. Isso torna a contagem auditável — o revisor vê
exatamente qual regra selecionou quais registros.

## Rastreabilidade na prática

A rastreabilidade do ADaM se materializa de duas formas que você verá
documentadas no Define-XML (capítulo 53):

- **Traceability de metadados** — cada variável ADaM aponta, na documentação,
  para a origem SDTM e a regra de derivação.
- **Traceability de dados** — quando útil, o próprio dataset carrega a variável
  de origem lado a lado com a derivada, para que o revisor confira o cálculo na
  mesma linha.

Essa dupla rastreabilidade é o que permite ao revisor do FDA reproduzir e
confiar nos seus números sem ter de reprogramar o estudo.

> **Na prática:** quando o ADaM está bem construído, ir do ADaM ao **TLF** é
> quase direto. A tabela de "mudança média na pressão por visita e braço" vira
> um `PROC MEANS`/`summarize` sobre `CHG`, agrupado por `AVISIT` e `TRTP`,
> filtrado por `SAFFL = "Y"`. Toda a inteligência — baseline, janela de visita,
> população — já foi resolvida e documentada no ADaM. É por isso que se diz que
> "um bom ADaM faz metade do trabalho da tabela". O inverso também é verdade: um
> ADaM mal feito transforma cada tabela num pesadelo de lógica ad hoc e quebra a
> rastreabilidade.

> **Atenção:** não recalcule no programa da tabela algo que deveria estar no
> ADaM. Se a tabela precisa de mudança em relação ao baseline, `CHG` tem de vir
> pronto do ADaM — derivá-la no passo da tabela esconde a lógica do revisor e
> viola o princípio *analysis-ready*.

## Resumo do capítulo

- **ADaM** (*Analysis Data Model*) são os datasets **prontos para análise**,
  derivados do SDTM, guiados por três princípios: **traceability**,
  **analysis-ready** e **metadados claros**.
- O **ADSL** tem **um registro por sujeito** e concentra tratamento (`TRT01P` /
  `TRT01A`), flags de população (`ITTFL`, `SAFFL`...) e datas de referência
  (`TRTSDT`/`TRTEDT`); quase toda tabela puxa dele.
- A **BDS** (*Basic Data Structure*) é a estrutura long para endpoints
  longitudinais: `PARAM`/`PARAMCD`, `AVAL`/`AVALC`, `AVISIT`, `BASE`, `ABLFL`,
  `CHG`.
- A **OCCDS** (*Occurrence Data Structure*) serve a dados de ocorrência (AEs no
  **ADAE**, concomitantes), com **flags de análise** que tornam a contagem
  auditável.
- A rastreabilidade se dá por metadados e, quando útil, por dados na própria
  linha — é o que deixa o revisor reproduzir seus números.
- Com um ADaM bem feito, ir do dataset ao **TLF** é quase mecânico; toda
  derivação analítica deve morar no ADaM, não no programa da tabela.
