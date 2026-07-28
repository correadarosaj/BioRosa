# Endpoints e o framework de estimands

O **endpoint** (desfecho) é a variável que traduz o objetivo do estudo em algo
mensurável. E o **estimand** é a definição precisa da quantidade que você quer
estimar — incluindo o que fazer quando a realidade complica a medição. Este é um
dos capítulos mais importantes do livro, por dois motivos: é onde a estatística
clínica moderna mais evoluiu na última década, e é um dos temas que **mais caem
em entrevista**. Vamos com calma.

## Tipos de endpoint

Antes do estimand, o vocabulário dos tipos de desfecho. O tipo determina o
método de análise, então classifique corretamente:

- **Contínuo** (*continuous*): uma medida numérica em escala — pressão arterial,
  glicemia, mudança de peso. Analisado com médias, modelos lineares, ANCOVA,
  modelos mistos.
- **Binário** (*binary/dichotomous*): sim/não — respondeu ao tratamento ou não,
  curou ou não. Analisado com proporções, risco relativo, odds ratio, regressão
  logística.
- **Tempo-até-evento** (*time-to-event / survival*): quanto tempo até um evento
  acontecer — morte, recidiva, progressão da doença. Analisado com curvas de
  Kaplan-Meier, teste log-rank, modelo de Cox. Característica única: a
  **censura** (*censoring*), quando o evento não ocorreu até o fim do
  acompanhamento.
- **Ordinal** (*ordinal*): categorias ordenadas — escalas de gravidade (leve,
  moderado, grave), scores clínicos. Analisado com odds ratio proporcional,
  testes não-paramétricos.
- **Composto** (*composite*): combina vários eventos em um só desfecho — o
  clássico **MACE** (*Major Adverse Cardiovascular Events*: morte
  cardiovascular, infarto ou AVC). Conta-se o primeiro que ocorrer. Aumenta o
  número de eventos (mais poder), mas mistura desfechos de gravidade diferente.
- **PRO** (*Patient-Reported Outcome*, desfecho relatado pelo paciente): medido
  diretamente com o paciente, via questionários validados — dor, qualidade de
  vida, sintomas. Cada vez mais valorizado por reguladores porque captura o que
  importa para quem tem a doença.

> **Glossário PT/EN:** *Time-to-event* (EN) = tempo-até-evento / *Censoring* =
> censura (evento não observado até o fim do seguimento) / *Composite endpoint* =
> desfecho composto / *PRO, Patient-Reported Outcome* = desfecho relatado pelo
> paciente.

## O problema que o estimand resolve

Imagine um estudo simples: medir a mudança de pressão arterial da semana 0 à
semana 12, comparando o medicamento X com placebo. Parece trivial. Até você
perguntar:

- E o paciente que **parou de tomar o remédio** na semana 6 por causa de um
  efeito colateral — o que fazemos com o valor dele na semana 12?
- E o que **começou a tomar outro anti-hipertensivo de resgate** porque o do
  estudo não bastou?
- E o que **morreu** antes da semana 12?
- E o que simplesmente **sumiu** e não apareceu na visita final?

Cada uma dessas situações é um **evento intercorrente** (*intercurrent event*):
um acontecimento, após o início do tratamento, que **afeta a interpretação ou a
existência** da medida do endpoint. E aqui está o ponto crucial: **dependendo de
como você lida com cada um, o "mesmo" endpoint mede coisas diferentes**. "Mudança
de pressão até a semana 12" é ambíguo até você dizer o que fez com esses casos.

O framework de **estimands**, formalizado no **ICH E9(R1)** (uma adenda ao
guideline E9, publicada em 2019), existe para acabar com essa ambiguidade. Ele
força você a definir, **antes de coletar dados**, exatamente qual quantidade está
estimando.

## Os cinco atributos de um estimand

O ICH E9(R1) define um estimand por **cinco atributos**. Especifique os cinco e
sua pergunta fica sem ambiguidade:

1. **População** (*population*): quais pacientes? Definida pelos critérios de
   elegibilidade — ex.: adultos hipertensos com pressão sistólica acima de certo
   valor.
2. **Variável (endpoint)** (*variable/endpoint*): a medida em cada paciente —
   ex.: mudança na pressão sistólica da semana 0 à 12.
3. **Eventos intercorrentes** (*intercurrent events*) e a **estratégia** para
   lidar com cada um — o atributo novo e mais importante, detalhado abaixo.
4. **Resumo populacional** (*population-level summary*): como se resume a
   variável para comparar os grupos — ex.: a **diferença de médias** entre X e
   placebo, ou um hazard ratio, ou um odds ratio.

Isso dá cinco itens porque a população, a variável, os eventos intercorrentes
(com suas estratégias) e o resumo se combinam para descrever uma única quantidade
bem definida — o estimand. Mude qualquer atributo e você está estimando outra
coisa.

## As cinco estratégias para eventos intercorrentes

Este é o núcleo do framework. Para cada tipo de evento intercorrente, o E9(R1)
oferece cinco estratégias. Vou ilustrar todas com o mesmo caso concreto: **um
paciente que descontinua o tratamento na semana 6** por um efeito adverso.

### 1. Treatment policy

Você ignora a descontinuação e usa o valor observado na semana 12
**independentemente** de o paciente ter parado o tratamento. A pergunta é sobre
o efeito de **ter sido designado** ao tratamento, com todas as descontinuações e
mudanças que acontecem na vida real. É a estratégia mais alinhada com o espírito
da análise **ITT** (*Intention-To-Treat* — analisar todos conforme o grupo a que
foram randomizados). Precisa que você continue medindo o paciente mesmo depois
de ele parar.

*No caso*: mede-se a pressão dele na semana 12, mesmo tendo largado o remédio na
6, e esse valor entra na análise normalmente.

### 2. Hypothetical

Você estima o que teria acontecido num **cenário hipotético** em que o evento não
ocorreu — ex.: "qual seria a pressão se o paciente **tivesse continuado** o
tratamento?". Como esse valor não é observável, ele é modelado/imputado sob
suposições explícitas.

*No caso*: estima-se a pressão que o paciente teria na semana 12 **se não tivesse
descontinuado**, tipicamente por imputação sob um modelo.

### 3. Composite

O evento intercorrente vira **parte da definição do desfecho** — em geral como
fracasso. Descontinuar por efeito adverso passa a contar como "não respondeu".

*No caso*: como o paciente descontinuou por efeito adverso, ele é classificado
como **falha de tratamento**, independentemente da pressão medida.

### 4. While-on-treatment

Você considera só o valor **enquanto o paciente estava em tratamento**, até o
momento do evento.

*No caso*: usa-se a última medida **antes** da descontinuação (a da semana 6, por
exemplo); o que vem depois é ignorado, porque não reflete o tratamento.

### 5. Principal stratum

Você foca no **subgrupo (estrato) de pacientes que não teriam** o evento
intercorrente — ex.: só naqueles que tolerariam o tratamento. É conceitualmente
sofisticada e difícil de estimar, porque esse estrato não é diretamente
observável.

*No caso*: o estimand se define **apenas** sobre pacientes que não
descontinuariam por efeito adverso — pergunta-se o efeito naquele subgrupo que
tolera o tratamento.

> Repare: são **cinco descrições diferentes do mesmo estudo**, e cada uma
> responde a uma pergunta clínica genuinamente distinta. Não existe uma
> "correta" universalmente — existe a que corresponde à pergunta que interessa.
> A treatment policy responde "o que acontece na vida real com quem é posto neste
> tratamento?"; a hypothetical, "qual é o efeito farmacológico se tomado como
> prescrito?". São perguntas diferentes.

## Relação com ITT e com missing data

Dois pontos que confundem quem está aprendendo:

**Estimand não é a mesma coisa que ITT.** ITT é um princípio sobre **quem
analisar** (todos, conforme randomizados). O estimand é mais amplo: define a
quantidade-alvo completa. A estratégia *treatment policy* é a que mais se
aproxima do espírito ITT, mas o framework de estimand **separa** duas perguntas
que antes se misturavam: "quem entra na análise?" e "como lidamos com quem
desviou?".

**Eventos intercorrentes não são a mesma coisa que missing data.** Este é um
erro conceitual comum e importante. Um paciente que descontinua o tratamento mas
**continua sendo medido** gerou um evento intercorrente, mas **não** um dado
faltante. Um paciente que **some e não é medido** gera dado faltante. A ordem
lógica correta, que o E9(R1) deixou clara, é: **primeiro** defina o estimand
(incluindo a estratégia para cada evento intercorrente); **só então** trate os
dados que ficaram genuinamente faltantes para *aquele* estimand. Antes do
E9(R1), essas duas coisas viviam embaralhadas, e métodos como o **LOCF** (*Last
Observation Carried Forward* — repetir a última medida) eram aplicados sem
clareza sobre qual pergunta respondiam.

## Análises de sensibilidade

Todo estimand baseado em suposições (especialmente as estratégias hypothetical e
qualquer tratamento de dados faltantes) precisa de **análises de sensibilidade**
(*sensitivity analyses*): você repete a análise sob **suposições alternativas
plausíveis** e verifica se a conclusão se mantém. Se o resultado só é positivo
sob a suposição mais otimista, ele é frágil. Um exemplo típico em dados faltantes
é a análise **tipping point**: quão pessimista teria de ser a suposição sobre os
dados faltantes para o resultado deixar de ser significativo?

Cuidado com a distinção: **análise de sensibilidade** testa robustez às
suposições **do mesmo estimand**; **análise suplementar** (*supplementary*)
explora estimands diferentes. Não são sinônimos.

> **Dica de carreira:** estimands caem em entrevista — quase garantido para
> vagas de Biostatistician, e cada vez mais para Statistical Programmer sênior.
> A pergunta clássica é: *"explique o framework de estimands do ICH E9(R1)"* ou
> *"quais são as estratégias para eventos intercorrentes?"*. Saber recitar os
> **cinco atributos** e as **cinco estratégias**, e ilustrar com o caso do
> paciente que descontinua, sinaliza imediatamente que você entende estatística
> clínica **moderna** — não a de vinte anos atrás. É um dos melhores
> investimentos de estudo por retorno em entrevista. Bônus: saiba dizer por que
> "evento intercorrente ≠ missing data".

## Resumo do capítulo

- Endpoints se classificam por tipo — **contínuo, binário, tempo-até-evento,
  ordinal, composto, PRO** — e o tipo determina o método de análise.
- Um **evento intercorrente** (descontinuação, medicação de resgate, morte) muda
  o significado do endpoint; sem definir como tratá-lo, "o endpoint" é ambíguo.
- O framework de **estimands** (ICH E9(R1)) define a quantidade-alvo por **cinco
  atributos**: população, variável/endpoint, eventos intercorrentes com
  estratégia, e resumo populacional.
- Há **cinco estratégias** para eventos intercorrentes: **treatment policy,
  hypothetical, composite, while-on-treatment, principal stratum** — cada uma
  responde a uma pergunta clínica diferente.
- **Estimand ≠ ITT** (ITT é sobre quem analisar) e **evento intercorrente ≠
  missing data** (defina o estimand primeiro, trate o faltante depois).
- **Análises de sensibilidade** testam se a conclusão sobrevive a suposições
  alternativas; distinga-as das análises suplementares (que exploram outros
  estimands).
- Estimands são tema quente de **entrevista**: domine os cinco atributos e as
  cinco estratégias com um exemplo concreto.
