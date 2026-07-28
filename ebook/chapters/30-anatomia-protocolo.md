# Anatomia de um protocolo clínico

Todo ensaio clínico começa por um documento: o **protocolo** (*protocol*). É a
planta baixa do estudo — descreve por que ele existe, quem entra, o que se faz
com cada paciente, o que se mede e como os dados serão analisados. É um
documento regulado: o FDA o revisa, o comitê de ética o aprova, e cada médico
que recruta pacientes é obrigado a segui-lo à risca.

Para você, que quer trabalhar com estatística clínica, o protocolo não é
"papelada dos médicos". É o documento onde as decisões estatísticas mais
importantes já foram tomadas — muitas vezes antes de o primeiro paciente ser
recrutado. Saber ler um protocolo, e principalmente saber ler e escrever sua
seção estatística, é uma competência central da profissão. Este capítulo é o
seu tour guiado.

## As seções de um protocolo

Protocolos seguem uma estrutura previsível. O ICH — *International Council for
Harmonisation*, o organismo que harmoniza normas de pesquisa entre EUA, Europa
e Japão — publicou a guideline **E6 (Good Clinical Practice, ou GCP)**, que
lista os itens que um protocolo deve conter. Na prática, quase todo protocolo
tem estas seções, nesta ordem aproximada:

### Título e sinopse

O **título** identifica o estudo e costuma codificar o desenho: fase, população,
intervenção, comparador. A **sinopse** (*synopsis*) é um resumo de 2 a 5 páginas
que condensa o estudo inteiro — objetivos, desenho, tamanho amostral, endpoints.
Muitas vezes é a única parte que executivos e revisores leem primeiro. Se você
souber escrever uma boa sinopse, você entendeu o estudo.

### Contexto e justificativa (background e rationale)

O **background** revisa o que já se sabe: a doença, os tratamentos existentes,
os dados pré-clínicos e de fases anteriores. O **rationale** (justificativa)
responde à pergunta "por que este estudo, com este desenho, agora?". É aqui que
se ancora, por exemplo, a escolha do comparador ou da dose.

### Objetivos e endpoints

Esta é a seção que mais interessa ao estatístico, e vamos voltar a ela em
detalhe. Os **objetivos** (*objectives*) dizem o que o estudo quer descobrir; os
**endpoints** (desfechos) dizem como isso será medido. Separam-se em:

- **Primário** (*primary*): o objetivo principal, aquele que dita o tamanho
  amostral e sobre o qual recai a decisão de sucesso ou fracasso do estudo.
- **Secundários** (*secondary*): objetivos adicionais importantes, geralmente
  testados de forma controlada só se o primário for positivo.
- **Exploratórios** (*exploratory*): hipóteses de geração de conhecimento, sem
  controle formal de erro — servem para orientar estudos futuros.

### Desenho do estudo

O **desenho** (*study design*) descreve a arquitetura: grupos paralelos ou
crossover, randomizado ou não, cego ou aberto, número de braços, duração,
número de visitas. Um diagrama de fluxo (*study schema*) quase sempre acompanha.
O próximo capítulo é inteiramente dedicado a desenhos.

### População e critérios de elegibilidade

Define **quem** pode entrar. Os **critérios de inclusão** (*inclusion criteria*)
dizem quem é elegível (ex.: adultos com determinado diagnóstico confirmado); os
**critérios de exclusão** (*exclusion criteria*) dizem quem fica de fora (ex.:
gestantes, comorbidade grave, uso de certo medicamento). Juntos, definem a
população-alvo — e, portanto, para quem os resultados vão valer.

### Tratamentos

Descreve as **intervenções** (*treatments/interventions*): o produto em
investigação, a dose, a via, o esquema, e o comparador (placebo ou tratamento
ativo). Inclui regras de ajuste de dose, medicação concomitante permitida e
proibida, e critérios de descontinuação.

### Cronograma de avaliações (schedule of assessments)

O **schedule of assessments** (cronograma de avaliações) é uma tabela grande que
lista, para cada visita, tudo o que será feito: exames, coletas de sangue,
questionários, medidas de eficácia e de segurança. Para o estatístico e o
programador, essa tabela é ouro: ela define **quais variáveis existem e em quais
momentos** — a base do futuro dataset.

### Considerações estatísticas

A **seção de considerações estatísticas** (*statistical considerations*) é o
coração quantitativo do protocolo. Voltamos a ela na próxima seção, porque é
onde você vai passar boa parte da sua vida profissional.

### Ética e consentimento

Descreve a proteção dos participantes: aprovação por um **IRB** (*Institutional
Review Board*) ou comitê de ética, o processo de **consentimento informado**
(*informed consent*), confidencialidade e o comitê independente de monitoramento
de segurança (**DSMB**, *Data Safety Monitoring Board*) quando existe.

> **Glossário PT/EN:** *Protocol* (EN) = protocolo, a planta baixa do estudo /
> *Synopsis* = sinopse, resumo executivo / *Eligibility criteria* = critérios de
> elegibilidade (inclusão/exclusão) / *Schedule of assessments* = cronograma de
> avaliações por visita.

## A seção estatística do protocolo (e como ela difere do SAP)

Aqui está uma distinção que confunde muita gente que chega de fora, e que você
precisa dominar: a **seção estatística do protocolo** não é o **SAP**
(*Statistical Analysis Plan*, plano de análise estatística).

A seção estatística do protocolo é um **resumo de alto nível** das decisões
analíticas. Ela tipicamente contém:

- a hipótese e o **framework de teste** (superioridade, não-inferioridade);
- o **endpoint primário** e como será analisado (ex.: modelo, teste);
- o **cálculo de tamanho amostral**, com premissas e poder;
- as **populações de análise** (ITT, per-protocol, safety);
- o tratamento geral de **dados faltantes** (*missing data*) e de análises
  interinas, se houver.

O **SAP** é um documento separado, muito mais longo e detalhado, escrito (e
finalizado) **antes do database lock e da quebra do cego**. Ele especifica cada
tabela, cada modelo, cada regra de derivação, cada análise de sensibilidade — no
nível em que dois programadores conseguem produzir exatamente os mesmos números
de forma independente.

Por que dois documentos? Porque servem a propósitos diferentes:

| | Seção estatística do protocolo | SAP |
|---|---|---|
| **Quando** | Antes de iniciar o estudo | Antes do database lock / unblinding |
| **Nível** | Alto nível, estratégico | Detalhe operacional total |
| **Público** | Reguladores, ética, sponsor | Estatísticos e programadores |
| **Muda?** | Só por emenda (*amendment*) ao protocolo | Pode ser refinado até o lock |

A regra de ouro é a **coerência**: o SAP detalha, mas **nunca contradiz**, a
seção estatística do protocolo. Se o protocolo diz que o endpoint primário será
analisado por um modelo misto, o SAP não pode trocá-lo por outro método sem uma
emenda ao protocolo. E ambos precisam estar prontos **antes de alguém olhar os
dados desmascarados** — essa é a essência da análise pré-especificada, que é o
que dá credibilidade regulatória ao resultado.

> **Atenção:** um erro clássico de quem está começando é tratar a seção
> estatística do protocolo e o SAP como se fossem a mesma coisa, ou achar que o
> SAP "pode ser escrito depois". Análise definida após ver os dados vira
> *post-hoc* e perde valor regulatório. O que protege a validade do estudo é a
> **pré-especificação**.

## Objetivo, endpoint e estimand — três coisas diferentes

Três palavras que parecem sinônimos, mas não são. Entender a diferença é um dos
saltos conceituais mais importantes da área — e o framework de **estimand** (que
detalhamos num capítulo próprio) nasceu justamente para desfazer essa confusão.

- **Objetivo** (*objective*): a pergunta científica, em linguagem quase comum.
  Exemplo: "avaliar se o medicamento X reduz a pressão arterial em pacientes
  hipertensos".
- **Endpoint** (*endpoint/desfecho*): a variável concreta que traduz o objetivo
  em algo mensurável. Exemplo: "mudança na pressão arterial sistólica do início
  ao final da semana 12".
- **Estimand**: a definição **precisa** da quantidade que o estudo quer estimar,
  incluindo o que fazer com eventos que atrapalham a medição — como um paciente
  que abandona o tratamento ou toma um remédio de resgate. Exemplo: "a diferença
  média entre X e placebo na mudança de pressão até a semana 12, **considerando
  o valor observado independentemente de o paciente ter parado o tratamento**".

Repare que os três descrevem "a mesma coisa" com precisão crescente. O objetivo
é vago de propósito; o endpoint escolhe a régua; o estimand fecha todas as
ambiguidades sobre **qual número exatamente** estamos estimando e para **qual
população em quais condições**. O ICH E9(R1) tornou o estimand parte esperada da
seção estatística do protocolo — e por isso ele merece um capítulo só dele.

> **Na prática:** o estatístico participa do **desenho**, não só da análise. A
> imagem de que o estatístico "recebe os dados no final e roda os testes" é
> falsa e cara. As decisões que mais afetam o sucesso de um estudo — o endpoint
> primário, o comparador, o tamanho amostral, o framework de teste, o estimand —
> são tomadas na fase de protocolo, **antes de existir qualquer dado**. Um
> estatístico que entra só no fim herda escolhas ruins que não pode mais
> desfazer. É na mesa de desenho que você agrega mais valor — e é lá que estão
> os cargos mais interessantes.

## Emendas: o protocolo é vivo (mas com regras)

Durante um estudo longo, às vezes é preciso mudar o protocolo — corrigir um
critério de elegibilidade, adicionar uma visita, ajustar uma dose. Isso se faz
por uma **emenda** (*protocol amendment*), que precisa de nova aprovação do IRB
e, dependendo da mudança, de comunicação ao FDA. Mudanças em elementos
estatísticos centrais (endpoint primário, tamanho amostral, método de análise
principal) são especialmente sensíveis: idealmente ocorrem **antes** de qualquer
olhar sobre dados de eficácia desmascarados, para não levantar suspeita de que a
mudança foi motivada pelos resultados.

## Resumo do capítulo

- O **protocolo** é a planta baixa do ensaio; segue estrutura previsível
  (título/sinopse, background/rationale, objetivos e endpoints, desenho,
  população, tratamentos, schedule of assessments, considerações estatísticas,
  ética/consentimento), alinhada ao ICH E6 (GCP).
- A **seção estatística do protocolo** é um resumo de alto nível das decisões
  analíticas; o **SAP** é um documento separado, detalhado, que especifica cada
  tabela e modelo — mas **nunca contradiz** o protocolo.
- Ambos precisam ser **pré-especificados** antes de ver os dados desmascarados;
  análise definida depois vira *post-hoc* e perde valor regulatório.
- **Objetivo**, **endpoint** e **estimand** são três níveis de precisão
  crescente: a pergunta, a régua e a quantidade-alvo exata (incluindo o que
  fazer com eventos intercorrentes).
- Mudanças no protocolo se fazem por **emenda**, com reaprovação ética; mexer em
  elementos estatísticos centrais depois de ver dados de eficácia é delicado.
- A principal lição de carreira: o estatístico agrega mais valor **no desenho**,
  não só na análise — as decisões que definem o estudo são tomadas na fase de
  protocolo.
