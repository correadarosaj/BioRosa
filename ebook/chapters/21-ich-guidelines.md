# As diretrizes ICH que todo bioestatístico precisa conhecer

Se o capítulo anterior foi o mapa do território, este é o dicionário das leis
locais. Quando você entra em uma reunião de projeto e alguém diz "isso precisa
seguir a E9" ou "qual é o estimand do estudo, segundo a E9(R1)?", espera-se que
você saiba do que se trata. Estas siglas — E6, E9, E9(R1), E3, E8, M4 — são o
vocabulário compartilhado da indústria global. Dominá-las é o que faz você soar
como alguém de dentro, e não como alguém tentando entrar.

## O que é o ICH e por que ele existe

O **ICH** é o *International Council for Harmonisation of Technical Requirements
for Pharmaceuticals for Human Use*. Antes do ICH, cada região (Estados Unidos,
Europa, Japão) tinha exigências técnicas próprias, e um mesmo medicamento
precisava de estudos e documentos diferentes para cada mercado — um desperdício
enorme de tempo, dinheiro e pacientes.

O ICH reúne autoridades regulatórias (como FDA, EMA e a japonesa PMDA) e a
indústria para **harmonizar** essas exigências. O resultado são as **guidelines
ICH**: documentos técnicos que, uma vez adotados por uma região, viram a
referência comum. Por isso o que você aprende de ICH **serve para o mundo
inteiro** — é conhecimento transferível entre sponsors, CROs e países.

As guidelines são organizadas em famílias por letra:

- **Q** — *Quality* (qualidade, fabricação);
- **S** — *Safety* (segurança não clínica);
- **E** — *Efficacy* (eficácia, ensaios clínicos) — **é aqui que mora quase todo
  o seu trabalho**;
- **M** — *Multidisciplinary* (temas que cruzam as outras, como o formato de
  submissão).

> **Atenção:** guidelines são atualizadas por meio de revisões, indicadas pelo
> sufixo `(R1)`, `(R2)`, `(R3)`. Sempre confirme qual versão está **vigente** em
> ich.org e qual foi **adotada** pela região relevante (ex.: o FDA publica sua
> própria adoção via guidance). Citar a revisão errada em um documento
> regulado é um erro de credibilidade.

## E6 — Boas Práticas Clínicas (Good Clinical Practice, GCP)

A **E6** define as **Boas Práticas Clínicas** (*Good Clinical Practice*, ou
**GCP**): o padrão ético e científico internacional para desenhar, conduzir,
registrar e reportar ensaios que envolvem seres humanos. É o alicerce de tudo.

A versão **E6(R2)** foi por muitos anos a referência em vigor; uma revisão maior,
a **E6(R3)**, foi desenvolvida para modernizar a GCP diante de ensaios
descentralizados, fontes de dados variadas e ambientes digitais. A E6(R3) foi
**finalizada pelo ICH em janeiro de 2025**: o FDA publicou sua adoção como
guidance final em **setembro de 2025** e a EMA a tornou **efetiva em 23 de julho
de 2025**. O foco da revisão está exatamente nos temas que mais crescem na
prática atual: **ensaios descentralizados**, **dados eletrônicos** e
**monitoramento baseado em risco** (*risk-based monitoring*).

> **Verificar (fonte):** cronogramas de adoção regional ainda evoluem; confirme
> a versão vigente e a data efetiva na sua região em ich.org e fda.gov antes de
> citá-la num documento regulado.

**Por que importa para o estatístico:** GCP é o que torna os dados **confiáveis
e auditáveis**. Ela sustenta princípios como integridade de dados e
rastreabilidade — que aprofundamos no próximo capítulo. Na análise, GCP se
traduz em: usar apenas dados de fontes controladas, documentar tudo, e nunca
"consertar" dados fora do processo formal.

## E9 — a "bíblia" estatística

A **E9**, *Statistical Principles for Clinical Trials*, é **o** documento
estatístico do ICH. Se você lê apenas uma guideline na íntegra, que seja esta.
Ela estabelece os princípios que sustentam praticamente toda decisão que você
vai tomar em um SAP. Vamos aos temas centrais.

### Populações de análise: ITT vs per-protocol

A E9 formaliza **como definir quem entra em cada análise**. As duas populações
clássicas:

- **ITT** (*Intention-to-Treat*, "intenção de tratar") — analisa os pacientes
  **conforme o grupo ao qual foram randomizados**, independentemente de terem
  aderido, trocado de tratamento ou abandonado o estudo. Preserva a randomização
  e tende a ser **conservadora** para eficácia. Na prática, usa-se muitas vezes
  a **full analysis set** (FAS), uma aplicação do princípio ITT com exclusões
  mínimas e justificadas.
- **Per-protocol** (PP, "por protocolo") — analisa apenas os pacientes que
  **seguiram o protocolo** adequadamente (aderência, elegibilidade, sem desvios
  maiores). Responde "o que acontece em quem tomou o remédio como deveria", mas
  **quebra a proteção da randomização** e pode introduzir viés.

> **Glossário PT/EN:** *Intention-to-Treat* (EN) = intenção de tratar (PT) —
> analisa cada paciente no grupo em que foi randomizado, aconteça o que
> acontecer depois. É a espinha dorsal da análise confirmatória de eficácia.

Em estudos de **superioridade**, a ITT costuma ser a análise primária. Em
estudos de **não-inferioridade**, a divergência entre ITT e per-protocol merece
atenção especial, porque a ITT pode mascarar uma diferença real.

### Multiplicidade

Toda vez que você testa **várias hipóteses** — múltiplos endpoints, múltiplas
doses, análises interinas, subgrupos — a chance de um falso positivo cresce. A
E9 exige que o estudo tenha uma **estratégia pré-especificada de controle do
erro tipo I** (a probabilidade de declarar eficácia que não existe). Métodos
como Bonferroni, procedimentos hierárquicos (*fixed-sequence*), Hochberg e
*gatekeeping* são as ferramentas; o ponto conceitual é: a estratégia é
**definida antes** de ver os dados e documentada no SAP.

### Dados faltantes (conceitual)

Pacientes abandonam estudos, faltam visitas, medidas se perdem. A E9 alerta que
**dados faltantes podem enviesar** os resultados e que o estudo deve ter um
**plano** para lidar com eles — tanto na prevenção (bom desenho e condução)
quanto na análise. O tratamento de missing data conecta-se diretamente com a
ideia de **estimand**, que a revisão E9(R1) trouxe para o centro do palco.

## E9(R1) — o adendo sobre estimands

A **E9(R1)** é um *addendum* (complemento) à E9 que introduziu um framework para
uma pergunta aparentemente simples: **o que exatamente estamos tentando
estimar?**

O conceito central é o **estimand**: uma **descrição precisa do efeito de
tratamento** que o estudo quer medir, alinhada ao objetivo clínico. Um estimand
é definido por atributos como a população, a variável (endpoint), a medida de
resumo (ex.: diferença de médias) e — o ponto novo e crucial — como tratar os
**eventos intercorrentes**.

Um **evento intercorrente** (*intercurrent event*) é algo que acontece **depois**
da randomização e que **afeta a interpretação ou a existência** da medida de
desfecho: o paciente descontinua o tratamento, usa uma medicação de resgate,
troca de terapia, ou morre por causa não relacionada. A E9(R1) obriga a **decidir
antecipadamente** como cada tipo de evento intercorrente entra na definição do
efeito — não é mais aceitável "descobrir depois".

> **Glossário PT/EN:** *estimand* (EN) = estimando (raramente traduzido; mantenha
> *estimand*) — a definição precisa e pré-especificada do efeito de tratamento
> que o estudo pretende estimar, incluindo como os eventos intercorrentes são
> tratados.

A E9(R1) também reforça o papel das **análises de sensibilidade**: análises
adicionais que testam se a conclusão principal **se mantém** sob suposições
alternativas (por exemplo, sobre os dados faltantes). Uma conclusão robusta é a
que sobrevive a esses testes.

Este é apenas o aperitivo — há um **capítulo dedicado a estimands** mais adiante,
porque o tema é hoje um dos mais valorizados e mais cobrados em entrevistas.

> **Dica de carreira:** entender E9 e, principalmente, **E9(R1) e estimands** é
> um diferencial concreto em entrevista. Muitos candidatos sabem "fazer a
> análise"; poucos sabem articular **qual estimand** o estudo persegue e por quê.
> Saber explicar, com suas palavras, o que é um evento intercorrente e como ele
> muda o efeito estimado te coloca imediatamente acima da média.

## E3 — o Relatório de Estudo Clínico (Clinical Study Report, CSR)

A **E3**, *Structure and Content of Clinical Study Reports*, define o formato do
**CSR** — o relatório completo e integrado de um único estudo clínico, com
métodos, resultados, tabelas e apêndices. É o documento que "conta a história"
do estudo para o regulador.

**Por que importa para o estatístico:** as **TLFs** que você produz não vivem
soltas — elas alimentam o CSR. Entender a estrutura E3 ajuda você a saber **quais
tabelas** são esperadas, em que ordem, e como a seção de resultados estatísticos
se encaixa no todo.

## E8 — Considerações Gerais para Estudos Clínicos

A **E8(R1)**, *General Considerations for Clinical Studies*, é a guideline
"guarda-chuva" que apresenta os princípios gerais de desenho e condução de
estudos. A revisão (R1) trouxe forte ênfase em **quality by design** — a ideia
de que a qualidade deve ser **projetada** no estudo desde o início, concentrando
esforço nos fatores que realmente importam para a confiabilidade dos resultados.

**Por que importa para o estatístico:** ela dá o vocabulário e o enquadramento de
alto nível (tipos de estudo, fatores críticos de qualidade) sobre o qual as
guidelines mais específicas, como a E9, se apoiam.

## M4 — o Documento Técnico Comum (Common Technical Document, CTD/eCTD)

A **M4** define o **CTD** (*Common Technical Document*): a **estrutura
padronizada** em que toda a submissão regulatória é organizada, dividida em
cinco módulos (do administrativo/regional aos relatórios de qualidade,
não clínicos e clínicos). Sua versão eletrônica é o **eCTD** — o formato em que
as submissões chegam ao FDA hoje.

**Por que importa para o estatístico:** seus produtos — datasets CDISC, SAP,
CSR, TLFs — não são entregues avulsos; eles ocupam **lugares específicos** dentro
do Módulo 5 (relatórios clínicos) do eCTD. Saber que existe uma "estante" com
prateleiras numeradas ajuda você a entender por que os arquivos seguem convenções
rígidas de nome e organização.

> **Na prática:** você não precisa decorar cada seção do CTD, mas precisa saber
> que **existe uma estrutura** e que seus arquivos têm um endereço nela. Quando
> alguém disser "isso vai no Módulo 5", você já entende do que se trata.

## Resumo do capítulo

- O **ICH** harmoniza as exigências técnicas entre EUA, Europa e Japão; suas
  guidelines são referência **global**, o que torna esse conhecimento
  transferível entre países, sponsors e CROs.
- **E6** = **GCP** (Boas Práticas Clínicas), o alicerce ético e de qualidade;
  **E6(R2)** foi a referência por anos e a **E6(R3)** a moderniza — confirme a
  versão vigente.
- **E9** = *Statistical Principles* é a base estatística: **ITT vs
  per-protocol**, populações de análise (FAS), **multiplicidade** e o tratamento
  conceitual de **missing data**.
- **E9(R1)** introduziu **estimands** e **eventos intercorrentes**, mais o papel
  das **análises de sensibilidade** — hoje um dos temas mais valorizados (e há
  capítulo dedicado adiante).
- **E3** estrutura o **CSR**; **E8(R1)** dá os princípios gerais com ênfase em
  *quality by design*; **M4** define o **CTD/eCTD**, a estrutura da submissão
  onde seus produtos têm endereço fixo.
- Dominar **E9 e E9(R1)** é um diferencial real em entrevista — saiba explicar
  estimand e evento intercorrente com suas próprias palavras. Sempre confirme a
  revisão vigente em ich.org e a adoção em fda.gov.
