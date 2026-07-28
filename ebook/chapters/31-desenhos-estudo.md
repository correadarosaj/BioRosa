# Desenhos de estudo

O **desenho** (*study design*) é a arquitetura do ensaio: como os pacientes são
alocados aos tratamentos, como os grupos são comparados, quem sabe quem está
recebendo o quê. Cada escolha de desenho tem consequências estatísticas diretas
— sobre o modelo de análise, o tamanho amostral e a força da conclusão. Este
capítulo é o seu catálogo de desenhos, sempre com a pergunta "e o que isso muda
para a estatística?".

## Grupos paralelos vs. crossover

No desenho de **grupos paralelos** (*parallel groups*), cada paciente é alocado
a **um** braço e permanece nele até o fim. Compara-se o grupo A com o grupo B —
pessoas diferentes em cada grupo. É de longe o desenho mais comum, e o padrão
para estudos confirmatórios de fase III.

No desenho **crossover**, cada paciente recebe **os dois** tratamentos em
sequência, com um período de *washout* (limpeza) entre eles para o efeito do
primeiro desaparecer. Cada paciente é seu próprio controle.

Implicações estatísticas:

- **Crossover é mais eficiente**: como se compara o paciente consigo mesmo,
  elimina-se a variabilidade entre indivíduos, e precisa-se de **menos
  pacientes** para o mesmo poder.
- Mas o crossover só funciona quando a doença é **estável e crônica** (não cura
  entre períodos) e o efeito do tratamento é **reversível**. Não serve para
  doenças agudas nem para curas.
- O grande risco é o **carryover** (efeito residual): se o primeiro tratamento
  ainda age quando começa o segundo, os efeitos se confundem. O washout existe
  para evitar isso, mas nem sempre é suficiente.
- A análise precisa modelar **período** e **sequência**, além do tratamento.

> **Glossário PT/EN:** *Parallel groups* (EN) = grupos paralelos, cada paciente
> em um só braço / *Crossover* = cruzado, cada paciente recebe os dois
> tratamentos em sequência / *Washout* = período de limpeza entre tratamentos /
> *Carryover* = efeito residual de um tratamento no período seguinte.

## Superioridade, não-inferioridade e equivalência

Esta é uma distinção que cai em entrevista e confunde muita gente. A pergunta é:
**o que exatamente você quer provar?**

### Superioridade

No teste de **superioridade** (*superiority*), você quer mostrar que o novo
tratamento é **melhor** que o comparador. A hipótese nula é "não há diferença";
você a rejeita mostrando evidência de diferença a favor do novo. É o caso mais
intuitivo.

### Não-inferioridade

No teste de **não-inferioridade** (*non-inferiority*, NI), você quer mostrar que
o novo tratamento **não é pior que o comparador ativo por mais do que uma margem
aceitável**. Por que alguém iria querer provar só isso?

Porque muitas vezes o novo tratamento tem outra vantagem — é mais barato, mais
seguro, mais cômodo (uma pílula em vez de injeção), ou tem menos efeitos
colaterais. Não precisa ser *mais eficaz*; basta **não ser meaningfully menos
eficaz**, e aí as outras vantagens justificam seu uso. Além disso, quando já
existe um tratamento eficaz para a doença, dar **placebo** aos pacientes pode
ser antiético — então o comparador tem que ser o tratamento ativo, e a pergunta
natural vira "o novo é pelo menos tão bom quanto o padrão?".

A **margem de não-inferioridade** (*non-inferiority margin*, geralmente chamada
de δ, delta) é o coração do método. Ela é o **maior grau de inferioridade que se
está disposto a tolerar** e ainda declarar o novo tratamento "não-inferior".
Você declara não-inferioridade quando o intervalo de confiança da diferença
exclui a margem δ — ou seja, quando você tem confiança de que o novo tratamento
não é pior que o padrão por mais do que δ.

De onde vem δ? Não é escolhida no chute. Ela deve ser justificada de forma que
**preserve parte do efeito** que o comparador ativo tem sobre placebo. A lógica:
o comparador ativo, no passado, mostrou-se superior a placebo por certo efeito;
a margem δ é definida para garantir que, mesmo no pior caso do intervalo de
confiança, o novo tratamento ainda mantenha uma fração clinicamente relevante
desse efeito histórico — para que "não-inferior ao ativo" não acabe significando,
na prática, "não melhor que placebo". Essa é a ideia por trás dos métodos de
**preservação de efeito** discutidos nos guidelines do ICH e do FDA.

> **Verificar:** as abordagens específicas de justificação da margem (ex.: método
> dos "95/95", fração de preservação de efeito) e os percentuais recomendados
> constam de guidelines regulatórios (ICH E10; FDA guidance sobre
> non-inferiority trials). Consulte a versão vigente antes de citar um número
> específico.

### Equivalência

No teste de **equivalência** (*equivalence*), você quer mostrar que os dois
tratamentos são **praticamente iguais** — nem melhor, nem pior — dentro de uma
margem δ **nos dois sentidos**. É o padrão para estudos de **bioequivalência**
(comparar um genérico com o medicamento de referência): o genérico não pode ser
nem muito mais fraco nem muito mais forte. A análise usa a abordagem dos **dois
testes unilaterais** (*two one-sided tests*, TOST): o IC da diferença precisa
caber inteiro dentro de (−δ, +δ).

Implicações estatísticas gerais:

- Em superioridade, "não rejeitar H0" significa "não provamos diferença".
- Em NI e equivalência, a lógica se **inverte**: a hipótese nula é que a
  diferença é *grande demais*, e você quer rejeitá-la.
- NI e equivalência dependem **criticamente** da margem δ, definida **a priori**
  no protocolo, e do **assay sensitivity** — a garantia de que o estudo teria
  conseguido detectar uma diferença se ela existisse.

> **Atenção:** o erro de interpretação mais comum e mais grave em não-
> inferioridade: **"não encontramos diferença estatisticamente significativa"
> NÃO é o mesmo que "os tratamentos são equivalentes/não-inferiores".** Um
> resultado não significativo pode vir de um estudo pequeno demais para detectar
> uma diferença real (falta de poder). Não-inferioridade exige o oposto: um IC
> **estreito o bastante para excluir a margem δ**. Confundir "ausência de
> evidência de diferença" com "evidência de ausência de diferença" já derrubou
> submissões inteiras. Além disso, em NI a análise **per-protocol** costuma ser
> tão ou mais importante que a ITT, porque desvios e dados faltantes tendem a
> **empurrar os grupos para parecerem iguais** — mascarando uma inferioridade
> real.

## Randomização e alocação

A **randomização** (*randomization*) é a alocação dos pacientes aos tratamentos
por sorteio. É o que torna os grupos comparáveis (equilibra fatores conhecidos e
desconhecidos) e é a base lógica dos testes estatísticos. Principais esquemas:

- **Simples** (*simple*): como jogar uma moeda para cada paciente. Funciona bem
  em amostras grandes, mas em amostras pequenas pode gerar grupos desbalanceados
  por acaso (ex.: 60 vs. 40).
- **Em blocos** (*block/permuted-block*): garante balanceamento ao longo do
  recrutamento. Dentro de cada bloco (ex.: de tamanho 4), metade vai para cada
  braço, em ordem aleatória. Assim, a qualquer momento os grupos têm tamanhos
  próximos.
- **Estratificada** (*stratified*): faz a randomização **separadamente dentro de
  subgrupos** (estratos) importantes — centro, sexo, gravidade da doença — para
  garantir que esses fatores fiquem equilibrados entre os braços. Geralmente
  combina-se estratificação com blocos.

Implicação estatística chave: **fatores usados para estratificar a randomização
devem, em geral, entrar como covariáveis no modelo de análise**. Analisar
ignorando a estratificação usada no desenho é um descasamento que os revisores
notam.

## Mascaramento (blinding)

O **mascaramento** ou **cegamento** (*blinding/masking*) esconde quem recebe o
quê, para evitar viés — de quem avalia e de quem é avaliado.

- **Aberto** (*open-label*): todos sabem o tratamento. Usado quando cegar é
  inviável (ex.: cirurgia vs. remédio). Mais sujeito a viés.
- **Simples-cego** (*single-blind*): o paciente não sabe, mas a equipe sabe.
- **Duplo-cego** (*double-blind*): nem paciente nem equipe (médico, avaliador)
  sabem. É o padrão-ouro para estudos confirmatórios, porque bloqueia o viés dos
  dois lados.

Para o estatístico, há um cegamento adicional: a análise principal é planejada
(o SAP é finalizado) **antes do unblinding** — a quebra do cego — e muitas vezes
o próprio time de estatística trabalha "cego" ao código de tratamento até o
database lock.

## Controle: placebo ou comparador ativo

O **grupo controle** (*control*) é o ponto de comparação. Pode ser:

- **Placebo**: substância inerte. Isola o efeito específico do tratamento do
  efeito placebo e da evolução natural. Só é ético quando **não há tratamento
  eficaz estabelecido** que estaria sendo negado ao paciente.
- **Comparador ativo** (*active comparator*): o tratamento-padrão atual. Usado
  quando negar tratamento seria antiético, ou quando a pergunta é "o novo é
  melhor/igual ao que já se usa?". Liga-se diretamente aos desenhos de
  superioridade e não-inferioridade contra ativo.

## Desenhos adaptativos e de grupo sequencial

Nos desenhos clássicos, tudo é fixo até o fim. Nos **desenhos adaptativos**
(*adaptive designs*), o protocolo pré-especifica **regras para modificar o
estudo com base em análises interinas** (*interim analyses*) — sem quebrar a
integridade estatística. Exemplos: recalcular o tamanho amostral, abandonar um
braço de dose que não funciona (*drop-the-loser*), ou reponderar a população.

Um caso particular importante é o **desenho de grupo sequencial** (*group
sequential design*): planejam-se análises interinas em que o estudo pode ser
**parado mais cedo** — por eficácia clara, por futilidade (não vai dar em nada)
ou por segurança. O ganho é ético e econômico; o preço estatístico é que cada
"espiada" nos dados gasta um pouco do erro tipo I.

Implicação estatística central: **olhar os dados várias vezes infla o erro tipo
I**. Para controlar isso, usam-se funções de gasto de alfa (*alpha-spending
functions*), como as fronteiras de O'Brien-Fleming ou de Pocock, que distribuem
o alfa total (ex.: 5%) entre as análises, de modo que o erro global permaneça
controlado. Nada disso pode ser improvisado: as regras de parada e o gasto de
alfa têm que estar **pré-especificados** no protocolo e no SAP.

## Desenhos de dose-resposta

Estudos de **dose-resposta** (*dose-response/dose-finding*), típicos da fase II,
testam **vários níveis de dose** (mais placebo) para caracterizar a relação
entre dose e efeito — e escolher a dose a levar para a fase III. Buscam o
equilíbrio entre eficácia e segurança (a "dose certa"). A análise pode usar
testes de tendência (*trend tests*) ou modelagem da curva dose-resposta (ex.:
abordagens tipo MCP-Mod, que combinam teste de sinal e modelagem). A implicação
estatística é o **problema de múltiplas comparações**: testar muitas doses infla
o erro tipo I e exige métodos que controlem isso.

## Resumo do capítulo

- **Grupos paralelos** (cada paciente em um braço) é o padrão; **crossover**
  (cada paciente recebe os dois tratamentos) é mais eficiente, mas só serve para
  doenças crônicas estáveis e exige washout para evitar carryover.
- **Superioridade** prova que o novo é melhor; **não-inferioridade** prova que
  não é pior por mais que a margem δ; **equivalência** prova "praticamente
  igual" nos dois sentidos (ex.: bioequivalência). NI e equivalência invertem a
  lógica do teste e dependem criticamente de δ, definida a priori.
- Erro clássico de NI: "não achamos diferença" **não** é "são equivalentes";
  NI exige um IC estreito que **exclua a margem** — e a análise per-protocol
  ganha peso.
- **Randomização** (simples, em blocos, estratificada) equilibra os grupos;
  fatores de estratificação devem entrar como covariáveis na análise.
- **Mascaramento** (aberto, simples-, duplo-cego) bloqueia viés; duplo-cego é o
  padrão-ouro. O controle pode ser **placebo** (quando ético) ou **comparador
  ativo**.
- **Desenhos adaptativos** e de **grupo sequencial** permitem modificar/parar o
  estudo com regras pré-especificadas, mas exigem controle do erro tipo I
  (alpha-spending). **Dose-resposta** caracteriza a curva dose-efeito e enfrenta
  o problema de múltiplas comparações.
