# Métodos analíticos no SAP

O capítulo anterior mostrou *onde* cada assunto vive no SAP. Este mergulha nos
**métodos** que ocupam suas seções mais técnicas — os temas em que uma entrevista
para bioestatístico realmente aperta e em que o revisor do FDA passa mais tempo.
Não vamos derivar fórmulas; vamos construir o **modelo mental correto** de cada
método: o que ele faz, quando usá-lo e por que a indústria evoluiu na direção que
evoluiu. Toda esta discussão se ancora em duas referências: o **ICH E9**
("Statistical Principles for Clinical Trials") e seu adendo **ICH E9(R1)**, que
introduziu o *framework* de *estimands*.

## Populações de análise: qual é a primária, e quando

O capítulo anterior definiu ITT, mITT, per-protocol e Safety. A pergunta prática é
**qual delas é a primária para eficácia** — e a resposta depende do tipo de
alegação:

- Em estudos de **superioridade**, a primária é quase sempre a **ITT** (ou mITT):
  todos os randomizados, no grupo alocado. A ITT é **conservadora** para
  superioridade — incluir quem abandonou ou não aderiu tende a *diluir* o efeito,
  então "passar" na ITT é uma barra alta e crível. Ela preserva a randomização,
  que é a única garantia de que os grupos são comparáveis.
- Em estudos de **não-inferioridade**, a coisa se inverte: a ITT pode ser
  *anticonservadora*, porque diluir a diferença **favorece** a conclusão de
  "não pior". Por isso, nesses estudos, a **per-protocol** ganha peso e
  frequentemente é co-primária — analisa-se em ambas e exige-se consistência.
- A **Safety** é sempre a base da análise de segurança, analisada pelo tratamento
  **recebido**, não pelo alocado — porque, para efeitos adversos, o que importa é
  a que droga o paciente foi de fato exposto.

> **Na prática:** a definição de mITT é um campo minado. Toda exclusão precisa ser
> **pré-especificada, mínima e independente do resultado** — por exemplo, "não
> recebeu nenhuma dose". Excluir pacientes por um critério que só se conhece
> *depois* de ver os dados reabre a porta do viés que a randomização fechou.

## Dados faltantes: o problema que definiu a bioestatística moderna

Pacientes abandonam estudos. Perdem visitas. Um valor não é coletado. Esse
*missing data* é, provavelmente, o problema metodológico mais consequente de um
ensaio — porque a forma de lidar com ele pode inverter a conclusão. Comece pelo
**mecanismo** do *missing* (a taxonomia de Rubin), que é conceitual mas guia tudo:

- **MCAR (*Missing Completely At Random*):** a ausência não tem relação com nada —
  nem com valores observados, nem com os não observados. Raro na prática.
- **MAR (*Missing At Random*):** a ausência depende apenas do que **foi observado**
  (ex.: pacientes mais graves no *baseline* abandonam mais, mas condicionado a
  isso a ausência é aleatória). É a suposição de trabalho da maioria dos métodos
  modernos.
- **MNAR (*Missing Not At Random*):** a ausência depende do valor **não
  observado** (ex.: o paciente faltou justamente porque piorou). É o cenário mais
  perigoso, e o que as análises de sensibilidade existem para estressar.

Ninguém consegue *provar* qual mecanismo governa um estudo — o *missing* é, por
definição, não observado. Por isso a estratégia não é "acertar o mecanismo", e sim
**escolher um método defensável sob MAR e testar a robustez sob desvios de MAR**.

### Por que MMRM e imputação múltipla substituíram o LOCF

Por muitos anos, o método padrão foi o **LOCF** (*Last Observation Carried
Forward*, "última observação levada adiante"): quando um paciente sai, repete-se o
último valor dele até o fim. Hoje o LOCF é **desencorajado** como método primário,
e vale entender por quê:

- Ele **inventa dados** com uma premissa biologicamente implausível — a de que o
  paciente ficou congelado no tempo a partir do abandono.
- Ele trata valores imputados como se fossem observados, **subestimando a
  incerteza** e distorcendo os erros-padrão.
- Dependendo da direção da doença, ele pode ser otimista ou pessimista de formas
  imprevisíveis — não é "conservador" de maneira confiável, ao contrário do que se
  acreditava.

Duas abordagens o substituíram:

- **MMRM (*Mixed Model for Repeated Measures*):** um modelo linear misto que usa
  **todas as medidas observadas** de cada paciente ao longo das visitas, sem
  imputar nada. Ele modela a correlação entre visitas do mesmo paciente (via uma
  estrutura de covariância, tipicamente *unstructured*) e, sob MAR, produz
  estimativas válidas usando a informação parcial de quem abandonou. Virou o
  método primário padrão para *endpoints* contínuos longitudinais.
- **Multiple imputation (imputação múltipla):** gera vários conjuntos de dados
  completos, cada um com valores imputados de um modelo, analisa cada um e combina
  os resultados (regras de Rubin), **propagando corretamente a incerteza** da
  imputação. É flexível e serve tanto como método principal quanto — muito comum —
  como veículo de análises de sensibilidade (ex.: imputação sob premissas MNAR).

> **Glossário PT/EN:** *MMRM* = modelo misto para medidas repetidas; usa todos os
> dados observados sob MAR sem imputar. *LOCF* = repetir a última observação;
> hoje desaconselhado como método primário. *Multiple imputation* = imputação
> múltipla, que gera e combina vários datasets completos preservando a incerteza.

## Estimands: a pergunta antes do método

O ICH E9(R1) trouxe uma mudança de perspectiva que domina os SAPs modernos: antes
de escolher *como* analisar, defina **o que exatamente você quer estimar** — o
**estimand**. Um *estimand* é a resposta precisa à pergunta "qual é o efeito do
tratamento?", especificada por cinco atributos:

1. **Tratamento** e comparador;
2. **População** de pacientes;
3. **Variável** (o *endpoint*);
4. **Eventos intercorrentes** (*intercurrent events*) — coisas que acontecem
   *depois* da randomização e complicam a interpretação: abandono, uso de
   medicação de resgate, morte, troca de tratamento. Para cada um, define-se uma
   **estratégia** (ex.: *treatment policy* — conta o dado independentemente do
   evento; *hypothetical* — estima o que teria acontecido sem o evento;
   *composite*, *while-on-treatment*, *principal stratum*);
5. **Resumo populacional** (ex.: diferença de médias na semana 12).

A grande sacada é que **o tratamento do *missing* deixa de ser uma decisão técnica
isolada** e passa a ser uma consequência do *estimand*. A pergunta "o que fazer com
quem abandonou?" vira "quando você desenha o estimand, o abandono é um evento
intercorrente com qual estratégia?". Método (MMRM, imputação) e estimativa se
alinham à pergunta, não o contrário.

## Análises de sensibilidade e suplementares

Toda análise primária repousa sobre suposições não verificáveis (tipicamente MAR).
As **análises de sensibilidade** (*sensitivity analyses*) existem para responder:
*e se essa suposição estiver errada?*. No vocabulário do E9(R1), elas testam a
robustez das conclusões a **desvios das premissas do mesmo estimand** — por
exemplo, uma imputação sob cenário MNAR (*tipping point*, *jump-to-reference*) que
pergunta o quão pessimista o *missing* teria de ser para apagar o efeito.

Distingue-se disso a **análise suplementar** (*supplementary analysis*): uma
análise adicional que ilumina o resultado, mas **não** é um teste de robustez do
mesmo estimand (por vezes responde a um estimand diferente). A regra de ouro:
**a conclusão do estudo é forte quando a análise primária e suas sensibilidades
apontam na mesma direção**. Um efeito que só aparece na análise primária e evapora
em toda sensibilidade é frágil.

## Multiplicidade: por que e como ajustar

Cada teste de hipótese ao nível 0,05 tem 5% de chance de um falso positivo. Faça
vinte testes independentes sob H0 verdadeira e a chance de **ao menos um**
"significativo" por acaso salta para ~64%. Num estudo confirmatório com múltiplos
*endpoints*, doses ou momentos, isso é inaceitável — o FDA exige que o **erro tipo
I global (*family-wise error rate*, FWER) fique em 0,05**. Os métodos, em visão
geral:

- **Bonferroni:** divide o *alfa* pelo número de testes (0,05/*k*). Simples e
  válido sempre, mas conservador.
- **Holm:** versão *step-down* de Bonferroni — ordena os *p-valores* do menor ao
  maior e aplica limiares progressivamente menos rígidos. **Uniformemente mais
  poderoso** que Bonferroni, sem premissas extras.
- **Hochberg:** versão *step-up*, mais poderosa ainda, mas requer uma suposição
  sobre a dependência entre os testes.
- **Testagem hierárquica / *fixed-sequence*:** ordena os *endpoints* por
  importância e testa em sequência; cada um só é testado se o anterior passou, e
  cada um usa o *alfa* cheio. Elegante e poderoso quando existe uma ordem clínica
  natural, mas para na primeira falha.
- ***Gatekeeping*:** generaliza a hierarquia para **famílias** de hipóteses (um
  "portão" primário que precisa passar antes de a família secundária ser testada),
  permitindo estruturas mais ricas que uma simples fila.

O ponto conceitual: a estratégia de multiplicidade deve ser **pré-especificada no
SAP** e refletir a **hierarquia clínica** das perguntas — não escolhida depois
para acomodar quais testes passaram.

## Análises interinas e o desenho grupo-sequencial

Um estudo pode planejar olhar os dados **antes do fim** — por eficácia (parar cedo
por sucesso), futilidade (parar por falta de perspectiva) ou segurança. Mas cada
"olhada" é um teste, e testes repetidos inflam o erro tipo I. A solução é o
desenho **grupo-sequencial** (*group-sequential*) com **alpha spending** (gasto de
*alfa*): o orçamento total de 0,05 é distribuído entre as análises segundo uma
**função de gasto** (Lan-DeMets), de modo que a soma nunca ultrapasse 0,05. Duas
funções clássicas:

- **O'Brien-Fleming:** gasta **pouquíssimo** *alfa* cedo — os limiares iniciais são
  muito exigentes, então parar cedo exige evidência esmagadora, e quase todo o
  *alfa* fica preservado para a análise final. É o padrão da indústria por ser
  conservador na parada precoce.
- **Pocock:** distribui o *alfa* de forma mais uniforme — mais fácil parar cedo,
  mas ao custo de um limiar final mais rígido.

### O papel do DSMB / IDMC

Quem olha os dados **desblindados** numa interina? Não a equipe do estudo — isso
comprometeria a cegueira e a integridade. Esse papel cabe a um comitê
**independente**: o **DSMB** (*Data Safety Monitoring Board*), também chamado de
**DMC** (*Data Monitoring Committee*) ou **IDMC** (*Independent* DMC). É um grupo
externo de clínicos e ao menos um bioestatístico independente que:

- Recebe os dados desblindados (via um estatístico *unblinded* independente, fora
  da equipe do sponsor);
- Avalia segurança e, quando previsto, as análises interinas de eficácia/futilidade;
- Recomenda ao sponsor **continuar, modificar ou parar** o estudo — sem revelar os
  dados à equipe que o conduz.

O **charter do DSMB** e o SAP da interina definem, *a priori*, exatamente quais
análises o comitê vê e quais regras guiam suas recomendações. Isso preserva a
cegueira da equipe do estudo enquanto garante supervisão ética independente.

> **Dica de carreira:** dominar **MMRM e o *framework* de estimands** é um dos
> maiores diferenciais que um candidato pode ter hoje. São exatamente os temas em
> que a indústria migrou nos últimos anos, em que muitos profissionais mais
> antigos ainda pensam "à moda LOCF", e que aparecem em quase toda entrevista
> técnica séria. Se você chega sabendo enunciar um estimand pelos seus cinco
> atributos e explicar por que o MMRM dispensa imputar sob MAR, você sinaliza
> maturidade metodológica muito acima do nível de entrada. Multiplicidade e alpha
> spending completam o pacote.

## Resumo do capítulo

- A **população primária** depende da alegação: **ITT** (conservadora) para
  superioridade, **per-protocol** ganhando peso na não-inferioridade; **Safety**,
  pelo tratamento recebido, sempre para segurança.
- O **missing data** é o problema central; classifique o mecanismo em
  **MCAR/MAR/MNAR** e escolha um método defensável sob MAR, testando a robustez a
  desvios.
- O **LOCF** foi substituído porque inventa dados e subestima a incerteza; o
  **MMRM** (usa todos os dados observados sob MAR) e a **imputação múltipla** são o
  padrão atual.
- **Estimands** (ICH E9(R1)) definem *o que* estimar por cinco atributos —
  incluindo a estratégia para **eventos intercorrentes** —, e o tratamento do
  missing passa a decorrer do estimand.
- **Análises de sensibilidade** testam a robustez do mesmo estimand a premissas
  quebradas; a conclusão é forte quando primária e sensibilidades concordam.
- **Multiplicidade** controla o erro global (FWER = 0,05) via Bonferroni, Holm,
  Hochberg, hierarquia ou *gatekeeping*, sempre pré-especificada.
- **Análises interinas** usam **alpha spending** (O'Brien-Fleming, Pocock) num
  desenho grupo-sequencial; o **DSMB/IDMC** independente vê os dados desblindados e
  recomenda continuar, modificar ou parar.
