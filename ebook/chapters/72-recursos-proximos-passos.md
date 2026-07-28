# Recursos, comunidades e um plano de 90 dias

Chegamos ao fim do livro, mas o começo do seu caminho. Você tem o mapa, o
vocabulário e o método. O que falta é o que nenhum livro faz por você:
**consistência ao longo de meses.** Este capítulo entrega as duas coisas que
sustentam essa consistência — os **recursos e comunidades reais** onde a área
vive, e um **plano de 90 dias** concreto para você sair da teoria e entrar no
mercado. Marque esta página. É para onde você volta quando bater a dúvida do
"e agora, por onde?".

## Comunidades e conferências

A pesquisa clínica quantitativa tem uma comunidade ativa, acolhedora e — algo
raro — bastante aberta a quem está chegando. Participar não é opcional: é onde
você aprende o que os livros não contam, faz networking e descobre vagas antes de
elas virarem anúncio.

- **PHUSE** — *Pharmaceutical Users Software Exchange*. Comunidade global de
  programação e ciência de dados clínicos. Publica muito material gratuito, tem
  working groups e conferências. Um dos melhores lugares para absorver a prática
  da área. Boa parte do conteúdo é acessível sem custo.
- **PharmaSUG** — a conferência de usuários de SAS em pharma. Papers técnicos
  (muitos gratuitos no site) que são ouro para aprender padrões reais de código e
  CDISC. Existe também o **SAS Global Forum**, o evento maior da comunidade SAS.
- **CDISC** — a organização que mantém os padrões SDTM, ADaM e outros. O site tem
  documentação, treinamentos e os *implementation guides* que definem o que você
  programa.
- **R/Pharma** — conferência anual dedicada ao uso de R na indústria
  farmacêutica. Gravações e materiais costumam ficar públicos. É a referência
  para a onda de R na área.
- **pharmaverse (Slack)** — a comunidade dos pacotes R clínicos (admiral, tern,
  rtables e cia.) tem um **Slack aberto** onde mantenedores da indústria
  respondem dúvidas. Entrar ali e acompanhar as conversas é uma aula contínua e
  gratuita.
- **ASA** — *American Statistical Association*. A sociedade dos estatísticos nos
  EUA, com seções de biopharma e conferências (como a Regulatory-Industry
  Statistics Workshop). Boa para a parte mais metodológica e para networking com
  biostatisticians.
- **Grupos de LinkedIn** e as próprias páginas de PHUSE/CDISC no LinkedIn — siga,
  comente, e conecte-se com pessoas da área. Muita vaga circula ali primeiro.

> **Na prática:** você não precisa viajar para uma conferência para colher o
> valor dela. Papers do PharmaSUG, gravações do R/Pharma e o Slack do pharmaverse
> estão a um clique, de graça. Comece consumindo esse material — e, quando puder,
> participe ao vivo (mesmo online) para o networking.

## Certificações e cursos

Lembre-se do que já dissemos: **um portfólio vale mais que um certificado.** Mas
certificações e cursos ajudam a estruturar o estudo e a preencher lacunas
específicas. Os mais reconhecidos na área:

- **Certificações SAS** — a trilha de programação SAS (base, advanced) e,
  especialmente relevante para você, a de **Clinical Trials Programming**. É a
  credencial mais citada em vagas de programação estatística.
- **Treinamentos CDISC** — cursos oficiais de SDTM e ADaM pela própria CDISC.
  Densos e caros, mas canônicos. Alternativamente, estudar os *implementation
  guides* de graça já leva você longe.
- **Cursos de bioestatística clínica** — plataformas universitárias e MOOCs têm
  cursos de desenho e análise de ensaios clínicos que consolidam a parte
  metodológica (endpoints, poder, análise de sobrevivência, MMRM).

> **Glossário PT/EN:** *implementation guide* (IG) = documento da CDISC que
> especifica, variável por variável, como montar um domínio SDTM ou um dataset
> ADaM. É a fonte da verdade — e é pública.

## Livros e diretrizes (guidelines) para estudar

Para aprofundar com fontes primárias e corretas:

- **ICH E9** — *Statistical Principles for Clinical Trials.* A guideline
  fundamental sobre princípios estatísticos em ensaios. Leitura obrigatória.
- **ICH E9(R1)** — o adendo que introduziu o framework de **estimands** e análise
  de sensibilidade. Domine este: estimands são tema quente em entrevistas e
  submissões.
- **Documentos CDISC** — os implementation guides de SDTM e ADaM, além do modelo
  de *define.xml*. São a referência que você vai consultar no trabalho real.
- **Um bom livro-texto de análise de ensaios clínicos** — há clássicos sobre
  *statistical analysis of clinical trials* que cobrem desenho, endpoints,
  análise de sobrevivência e dados longitudinais. Use um deles como referência de
  cabeceira para a parte metodológica.

## Onde praticar

Teoria sem prática não te contrata. Pratique sobre os **dados sintéticos
públicos** que já usamos no projeto de portfólio:

- os datasets do **CDISC Pilot** (o estudo fictício de Alzheimer, com SDTM, ADaM
  e documentação);
- os pacotes de dados do **pharmaverse** (`{pharmaversesdtm}`,
  `{pharmaverseadam}`), ideais para treinar derivação de ADaM com `{admiral}` e
  geração de TLFs com `{tern}`/`{rtables}`/`{gtsummary}`.

Reproduzir uma tabela de um paper do PharmaSUG usando esses dados é um dos
exercícios mais produtivos que existem: você aprende o padrão real e ainda ganha
material para o portfólio.

## Como o networking realmente funciona nessa área

Muita gente qualificada trava porque trata networking como pedir emprego. Não é.
Na comunidade clínica quantitativa, networking é **contribuir e aparecer** de
forma consistente, e as oportunidades vêm como consequência. Formas concretas e
de baixo atrito:

- Responder (ou só acompanhar) dúvidas no **Slack do pharmaverse** e fóruns de
  usuários — você aprende e fica visível ao mesmo tempo.
- Comentar de forma útil em posts de pessoas da área no LinkedIn, em vez de só
  curtir. Um comentário técnico e educado é lembrado.
- Compartilhar o seu **projeto de portfólio** num post, contando o que aprendeu.
  Isso atrai recrutadores e convida conversas.
- Mandar mensagens de conexão **personalizadas** (nunca o template genérico) para
  profissionais de CRO/pharma, dizendo com sinceridade que está migrando para a
  área e admira o trabalho da pessoa.

> **Na prática:** boa parte das vagas de entrada em CRO nunca chega a virar um
> anúncio disputado — elas são preenchidas por alguém que já estava no radar de um
> gerente ou recrutador. Estar "no radar" é exatamente o que meses de presença
> consistente na comunidade constroem. Networking não é um evento; é um hábito.

## Um plano de 90 dias

A tentação, ao fechar um livro assim, é querer fazer tudo de uma vez — e parar
na segunda semana. O antídoto é um plano **progressivo**, em que cada mês tem um
foco só. Ajuste o ritmo à sua vida, mas mantenha a sequência.

### Mês 1 — Fundamentos e vocabulário

Objetivo: **falar o idioma da área com segurança.**

- Reler este livro com atenção às partes técnicas (protocolo, SAP, SDTM, ADaM,
  TLF, estimands). Fazer anotações do vocabulário em inglês.
- Ler o **ICH E9** e passar os olhos no **E9(R1)**.
- Entrar no **Slack do pharmaverse**, seguir **PHUSE**, **CDISC** e **R/Pharma**
  no LinkedIn, e começar a acompanhar as conversas.
- Escolher o seu alvo primário: **Biostatistician** ou **Statistical
  Programmer** (isso orienta a ferramenta do mês 2).
- Baixar os dados do **CDISC Pilot** e do pharmaverse e apenas explorá-los.

### Mês 2 — Uma ferramenta a fundo + começar o projeto

Objetivo: **profundidade em uma ferramenta e o portfólio no ar.**

- Escolher **uma** ferramenta principal e ir fundo: **SAS** (com olho na
  certificação de Clinical Trials Programming) **ou** **R** (com o pharmaverse:
  `{admiral}`, `{tern}`/`{rtables}`/`{gtsummary}`). Não divida a energia entre as
  duas agora.
- Iniciar o **projeto end-to-end** do capítulo 70: sinopse fictícia → mini-SAP →
  derivar ADSL e um BDS → criar o repositório no GitHub. Ainda que incompleto,
  **publique cedo** e vá evoluindo em commits.
- Estudar os **implementation guides** de SDTM e ADaM na prática, aplicando-os ao
  seu projeto.

### Mês 3 — Finalizar, empacotar e começar a aplicar

Objetivo: **transformar competência em candidaturas.**

- Concluir o **pacote de TLFs** (demografia, AE overview, um gráfico) e caprichar
  no **README** do repositório.
- Montar o **resume** de 1–2 páginas e otimizar o **LinkedIn** em inglês
  (capítulo 71), com o link do portfólio em destaque.
- **Começar a aplicar** para vagas de CRO e posições remotas, e a fazer
  **networking** ativo: comentar em posts da área, mandar mensagens de conexão
  personalizadas, participar de um evento online.
- Praticar as **perguntas técnicas de entrevista em inglês**, em voz alta.

Ao fim dos 90 dias você terá saído de "estou estudando pharma" para "tenho um
portfólio público, um resume no padrão certo, um LinkedIn que aparece nas buscas
dos recrutadores e candidaturas em andamento". Esse é o salto que este livro
inteiro foi construído para te ajudar a dar.

> **Dica de carreira: consistência vence intensidade.** Uma hora por dia, todo
> dia, durante 90 dias, produz muito mais que um fim de semana heroico seguido de
> três semanas paradas. O mercado não recompensa quem estudou mais forte numa
> semana; recompensa quem apareceu, aprendeu e entregou de forma constante. Mire
> num ritmo que você consiga sustentar — e sustente-o.

## Resumo do capítulo

- As comunidades reais da área — **PHUSE, PharmaSUG/SAS Global Forum, CDISC,
  R/Pharma, ASA** e o **Slack do pharmaverse** — oferecem aprendizado e
  networking, boa parte de graça.
- **Certificações** (SAS Clinical Trials Programming, treinamentos CDISC) e cursos
  ajudam a estruturar o estudo, mas **o portfólio vale mais** que qualquer
  credencial.
- Estude as fontes primárias: **ICH E9 e E9(R1)** (estimands), os **documentos
  CDISC** e um bom livro de análise de ensaios clínicos.
- **Pratique** sobre dados sintéticos públicos — **CDISC Pilot** e os dados do
  pharmaverse.
- Siga um **plano de 90 dias progressivo**: mês 1 fundamentos e vocabulário; mês 2
  uma ferramenta a fundo + começar o projeto; mês 3 finalizar o portfólio, montar
  o resume e começar a aplicar e a fazer networking.
- **Consistência vence intensidade:** um ritmo sustentável por 90 dias supera
  qualquer esforço heroico e intermitente.
