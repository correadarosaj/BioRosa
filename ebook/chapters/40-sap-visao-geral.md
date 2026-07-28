# O que é um SAP e por que ele existe

Se existe um único documento que define a profissão de bioestatístico na
indústria farmacêutica, é o *Statistical Analysis Plan* — o SAP. É nele que você
vai passar boa parte da sua vida profissional: escrevendo, revisando, discutindo
vírgulas com o clínico e o programador, defendendo escolhas de método. Entender o
SAP não é "mais um tópico técnico"; é entender **como a indústria pensa**. Este
capítulo explica o que é o SAP, por que ele existe, quando é escrito e por que
uma única regra — não mudar a análise depois de ver os dados — governa tudo.

## O que é, exatamente

O **Statistical Analysis Plan** (SAP, "plano de análise estatística") é o
documento que descreve, em detalhe técnico completo, **como os dados de um ensaio
clínico serão analisados**. Ele responde, de forma precisa o bastante para ser
reproduzível, a perguntas como:

- Qual é o *endpoint* primário e como ele é derivado a partir dos dados brutos?
- Qual população de pacientes entra em cada análise?
- Qual modelo estatístico compara tratamento e controle?
- Como se lida com dados faltantes, desvios de protocolo, visitas fora de janela?
- Como se controla o erro de múltiplas comparações?
- Quais tabelas, listagens e figuras (TLFs) serão produzidas, e o que cada uma
  contém?

O SAP é escrito para ser **inequívoco**. A meta prática é: dois estatísticos
diferentes, lendo o mesmo SAP e recebendo o mesmo *dataset*, deveriam chegar
exatamente ao mesmo número. Essa reprodutibilidade é o coração do documento.

> **Glossário PT/EN:** *Statistical Analysis Plan* (SAP) = plano de análise
> estatística; documento técnico que pré-especifica toda a análise de um ensaio.
> *Endpoint* = desfecho, a medida que quantifica o efeito do tratamento.

## A relação com o protocolo

Todo ensaio clínico começa por um **protocolo** (*protocol*) — o documento
mestre que descreve o estudo por inteiro: objetivos, critérios de elegibilidade,
esquema de doses, visitas, procedimentos de segurança e uma **seção estatística**.
Essa seção estatística do protocolo é, propositalmente, relativamente enxuta:
enuncia o desenho, o *endpoint* primário, a hipótese, o cálculo de tamanho
amostral e o método principal de análise em linhas gerais.

O SAP **detalha e expande** essa seção. Onde o protocolo diz "a comparação
primária usará um modelo misto para medidas repetidas", o SAP especifica os
termos exatos do modelo, a estrutura de covariância, o método de estimação, o
tratamento de covariáveis, a definição de *baseline*, as janelas de visita e o
que fazer quando um paciente abandona o estudo. O protocolo é o *o quê*; o SAP é
o *exatamente como*.

Por isso o SAP nunca deve **contradizer** o protocolo. Se durante a escrita do
SAP você percebe que precisa mudar algo substantivo do desenho, o caminho certo é
emendar o protocolo — não "resolver" no SAP e criar uma inconsistência entre os
dois documentos. Revisores do FDA leem os dois lado a lado.

> **Na prática:** uma das primeiras tarefas de um bioestatístico júnior é
> comparar a seção estatística do protocolo com o rascunho do SAP e listar toda
> discrepância. Parece burocrático, mas é assim que se aprende a ler os dois
> documentos como um revisor os lê.

## Quando o SAP é escrito — e por que precisa ser finalizado antes

O SAP começa a ser rascunhado cedo, muitas vezes em paralelo com o protocolo, e é
refinado ao longo da condução do estudo. Mas existe um marco inegociável: o SAP
precisa estar **finalizado e assinado antes do *database lock* e do *unblinding***
— ou seja, antes de alguém ter acesso aos resultados comparativos por grupo de
tratamento.

Vamos aos termos, porque eles são centrais:

- **Blinding / unblinding** (cegamento / quebra de cegamento): num ensaio cego,
  ninguém sabe quem recebeu o medicamento e quem recebeu placebo. O *unblinding*
  é o momento em que essa informação é revelada.
- **Database lock** (travamento do banco): o ponto em que os dados são declarados
  limpos, completos e congelados. Depois do *lock*, os dados não mudam mais.

A regra é simples e absoluta: **toda decisão analítica precisa ser tomada antes de
você poder ver como ela afeta o resultado**. Se o SAP está assinado antes do
*unblinding*, então nenhuma escolha de método pode ter sido influenciada pelo
desejo de fazer o resultado "dar certo".

Isso tem um nome: **pré-especificação** (*pre-specification*). É o mecanismo que
protege o ensaio contra o *cherry-picking* — escolher, depois de ver os dados, a
análise que produz o *p-valor* mais bonito. Sem pré-especificação, com dezenas de
escolhas plausíveis (qual população? qual método de imputação? ajustar por quais
covariáveis? qual janela de visita?), quase sempre existe *alguma* combinação que
transforma um resultado nulo em "significativo". A pré-especificação fecha essa
porta antes que ela possa ser aberta.

> **Atenção:** o pecado capital da bioestatística regulatória é **mudar a análise
> depois de ver os dados**. Não importa quão boa seja a justificativa técnica: se
> a mudança acontece após o *unblinding* e afeta o *endpoint* primário, o revisor
> do FDA vai — corretamente — desconfiar de que a escolha foi guiada pelo
> resultado. Um método "melhor" escolhido tarde demais vale menos que um método
> "razoável" escolhido a tempo. Data-driven **antes** do lock é ciência;
> data-driven **depois** é viés.

Uma prática que reforça isso: em muitos estudos, o estatístico escreve e roda todo
o código de análise contra dados **cegos** ou dados-teste (*dummy data*) antes do
*lock*, de modo que, no dia do *unblinding*, basta apontar o programa já validado
para os dados reais. Nada é decidido no calor do resultado.

## Quem escreve, revisa e aprova

O SAP é um documento de time, com papéis bem definidos:

- **Autor (lead biostatistician):** o bioestatístico responsável pelo estudo
  escreve o SAP. É a peça central do seu trabalho.
- **Revisores:** o estatístico sênior ou *biostatistics lead* do programa, o
  clínico (*medical/clinical lead*), o *data manager*, o programador estatístico
  que vai implementar as TLFs, e frequentemente regulatório e *medical writing*.
  Cada um lê com uma lente diferente — o clínico verifica se os *endpoints* fazem
  sentido médico; o programador, se as derivações são implementáveis.
- **Aprovadores (signatários):** o SAP é formalmente **assinado**, geralmente pelo
  bioestatístico responsável e pelo clínico responsável do sponsor, às vezes por
  um representante regulatório. A assinatura, com data, é o que dá força à
  pré-especificação: ela prova *quando* o plano foi congelado.

Em estudos conduzidos por uma CRO, o SAP costuma ser escrito pela CRO e aprovado
pelo *sponsor* — mas a responsabilidade e a assinatura final permanecem com o
sponsor, que é o dono da submissão perante o FDA.

## Versões e emendas

Um SAP raramente nasce pronto na versão 1.0 e fica intocado. Ele evolui, e essa
evolução precisa ser **rastreável**:

- Versões de rascunho (*draft*) circulam para revisão antes da assinatura.
- A **versão final assinada** é o marco que precede o *unblinding*.
- Se algo precisa mudar **depois** dessa versão final, faz-se uma **emenda**
  (*amendment*), numerada, datada e — crucialmente — **justificada**.

A pergunta que o FDA sempre faz sobre uma emenda é: *foi antes ou depois do
unblinding?* Uma emenda feita **antes** de qualquer acesso aos dados comparativos
é rotineira e não levanta suspeita — talvez o *endpoint* de um estudo similar
tenha sido refinado, ou uma nova guideline tenha saído. Uma emenda feita **depois**
do *unblinding*, especialmente se toca no *endpoint* primário ou no método
primário, exige justificativa extraordinária e pode comprometer a credibilidade
do resultado inteiro. Por isso todo SAP mantém um **histórico de versões**
(*version history*) transparente, dizendo o que mudou, quando e por quê.

## Pré-especificado, post-hoc e exploratório

Talvez a distinção mais importante deste capítulo — e uma que separa quem
"entende o jogo" de quem não entende — é a classificação das análises pela sua
**posição temporal em relação aos dados**:

- **Análise pré-especificada** (*pre-specified*): definida no SAP **antes** do
  *unblinding*. É a análise em que o FDA mais confia, porque não pôde ser
  influenciada pelo resultado. O *endpoint* primário é sempre pré-especificado, e
  o controle de erro tipo I (*alfa*) é "gasto" nessas análises.
- **Análise post-hoc** (*post-hoc*, "depois do fato"): concebida **após** ver os
  dados. Pode ser perfeitamente legítima e útil — muitas descobertas importantes
  são post-hoc —, mas ela **não pode sustentar uma alegação de eficácia** numa
  submissão. É geradora de hipóteses, não confirmatória.
- **Análise exploratória** (*exploratory*): pré-especificada, mas sem intenção
  confirmatória e sem controle formal de multiplicidade. Serve para entender o
  medicamento, explorar subgrupos, gerar hipóteses para estudos futuros. Seus
  *p-valores* são descritivos, não decisórios.

Por que essa distinção é **crítica para o FDA**? Porque o valor probatório de um
resultado depende diretamente de quando a análise foi decidida. Um *p* = 0,02 num
*endpoint* primário pré-especificado é evidência de eficácia. O mesmo *p* = 0,02
num subgrupo descoberto post-hoc, depois de vasculhar vinte subgrupos, é quase
certamente ruído — com vinte testes, esperar-se-ia um "significativo" por acaso.
O revisor não julga o número isoladamente; julga o número **à luz de quando e por
que aquela análise foi feita**.

> **Na prática:** ao ler o *Clinical Study Report* (CSR) de qualquer ensaio, um
> revisor experiente vai direto ao SAP e à sua data de assinatura para separar o
> que era plano do que foi improviso. Toda análise post-hoc precisa ser
> **rotulada como tal** no relatório. Esconder o caráter post-hoc de uma análise
> — apresentá-la como se fosse pré-especificada — é uma falha de integridade
> grave, não um mero deslize técnico.

## Resumo do capítulo

- O **SAP** é o documento que pré-especifica, em detalhe reproduzível, **toda a
  análise estatística** de um ensaio clínico. É a peça central da profissão.
- Ele **detalha e expande** a seção estatística do protocolo e nunca deve
  contradizê-la; o protocolo é o *o quê*, o SAP é o *exatamente como*.
- O SAP precisa estar **finalizado e assinado antes do *unblinding* e do *database
  lock***. Essa **pré-especificação** é o que protege o ensaio contra
  *cherry-picking*.
- O SAP é escrito pelo bioestatístico responsável, revisado por clínico,
  programador, *data management* e regulatório, e **assinado** com data —
  a assinatura dá força à pré-especificação.
- Mudanças posteriores viram **emendas** numeradas e justificadas; a pergunta-chave
  é sempre "foi antes ou depois do *unblinding*?".
- Análises **pré-especificadas** sustentam alegações de eficácia; **post-hoc** e
  **exploratórias** geram hipóteses mas não confirmam — e o FDA julga cada
  resultado à luz de *quando* a análise foi decidida.
- O pecado capital: **mudar a análise depois de ver os dados**. Data-driven antes
  do *lock* é ciência; depois, é viés.
