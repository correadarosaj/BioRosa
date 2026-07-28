# Currículo, LinkedIn e a entrevista técnica

Você tem o vocabulário, tem o entendimento do fluxo regulado e — se seguiu o
capítulo anterior — tem um projeto de portfólio publicado. Falta a parte que
muita gente qualificada subestima e por isso trava: **se apresentar de um jeito
que o mercado americano entenda e queira comprar.** Um currículo montado no
formato brasileiro, um LinkedIn sem as palavras certas ou uma entrevista técnica
sem preparo derrubam candidatos que teriam dado ótimos profissionais. Este
capítulo é sobre não deixar isso acontecer com você.

## O resume americano (não é o seu currículo Lattes)

O documento que você vai enviar chama-se **resume** — e ele é diferente do
currículo brasileiro em pontos que importam:

- **1 a 2 páginas.** Não mais. Um resume de quatro páginas sinaliza que você não
  sabe priorizar. Para quem está entrando na área, uma página bem-feita é o
  ideal.
- **Sem foto, sem data de nascimento, sem estado civil, sem CPF.** Nos EUA, incluir
  esses dados é no mínimo estranho e pode até criar problemas legais de
  discriminação para o empregador. Corte tudo isso.
- **Sem parágrafos longos.** O formato é de **bullets curtos**, cada um começando
  com um **verbo de ação** e, sempre que possível, **quantificando** o resultado.

### Verbos de ação e resultados quantificados

Compare:

- Fraco: "Responsável por análises estatísticas de dados clínicos."
- Forte: "Derived ADSL and ADAE datasets in R (`{admiral}`) from SDTM inputs and
  produced a demographics and AE-overview TLF package for a simulated Phase II
  study."

O segundo bullet começa com verbo (*derived*, *produced*), nomeia ferramentas e
padrões reais, e descreve um entregável concreto. Verbos úteis: *developed,
programmed, derived, validated, automated, authored, implemented, reviewed*.

### As palavras-chave (keywords) que passam pelo ATS

Grande parte das candidaturas em pharma/CRO passa primeiro por um **ATS**
(*Applicant Tracking System*, o sistema que filtra currículos por
palavras-chave) antes de um humano ler. Se o seu resume não contém os termos da
vaga, ele pode ser descartado antes de qualquer pessoa te ver. Garanta que
apareçam, de forma **verdadeira**, os termos do seu perfil:

`CDISC`, `SDTM`, `ADaM`, `SAP` (*Statistical Analysis Plan*), `TLF` (*Tables,
Listings, Figures*), `SAS`, `R`, `GCP` (*Good Clinical Practice*), `ICH E9`,
`clinical trials`, `regulatory submission`, `double programming`, e — conforme o
alvo — `MMRM`, `survival analysis`, `estimands`.

> **Atenção:** "de forma verdadeira" é literal. Nunca liste uma ferramenta ou um
> padrão que você não sabe explicar numa entrevista. Recrutadores de pharma
> testam. Colocar "SAS avançado" e travar no primeiro `PROC` derruba você na
> hora — e queima a sua credibilidade para as próximas vagas na mesma empresa.

### Estrutura sugerida do resume

```text
[Nome]  |  cidade/país  |  e-mail  |  LinkedIn  |  link do GitHub (portfólio)

SUMMARY (2-3 linhas)
  Quantitative professional transitioning into clinical biostatistics /
  statistical programming. CDISC (SDTM/ADaM), SAS & R, regulated trial workflow.

SKILLS
  Programming: SAS, R (admiral, tern, gtsummary), Git
  Standards:   CDISC SDTM & ADaM, ICH E9, GCP
  Methods:     MMRM, survival analysis, ITT/PP populations, missing data

PROJECTS
  End-to-end ADaM & TLF portfolio (link) — sinopse, mini-SAP, ADaM em admiral,
  pacote de TLFs em R/SAS. Bullets com verbo + resultado.

EXPERIENCE
  Cada cargo: verbo de ação + o que fez + resultado quantificado.
  Traduza responsabilidades antigas para a linguagem da vaga-alvo.

EDUCATION
  Grau, instituição, ano. (Sem Lattes, sem carga horária.)
```

> **Dica de carreira:** se a sua experiência formal não é em pharma, a seção
> **PROJECTS** (com o portfólio do capítulo anterior) sobe para logo abaixo do
> summary. Para quem vem de fora, o projeto é frequentemente a coisa mais
> relevante do documento inteiro — dê a ele o espaço nobre da página.

## LinkedIn otimizado para recrutadores de CRO/pharma

Recrutadores de CRO e pharma **caçam candidatos ativamente** no LinkedIn usando
busca por palavras-chave. Um perfil otimizado faz você aparecer nessas buscas
sem nem ter se candidatado. Pontos de alavancagem:

- **Headline:** não escreva só "Estatístico". Escreva algo como *"Statistical
  Programmer | CDISC SDTM/ADaM | SAS & R | Clinical Trials"*. É isso que a busca
  do recrutador varre.
- **About:** conte a transição em inglês, mencione o portfólio e os padrões que
  domina.
- **Featured:** fixe o link do repositório GitHub. Um clique e o recrutador vê a
  prova.
- **Skills:** adicione as mesmas keywords do resume — o LinkedIn as usa no
  matching.
- **Idioma:** perfil em **inglês** se o alvo é o mercado americano. Um perfil só
  em português te torna invisível para quem recruta lá.
- **Open to work:** ative a sinalização (pode ser só para recrutadores) com os
  títulos-alvo: *Biostatistician*, *Statistical Programmer*, *Clinical SAS
  Programmer*.

## A entrevista: as fases típicas

Um processo em CRO ou pharma costuma ter quatro etapas. Saber o que cada uma
testa te deixa muito mais calmo.

1. **Triagem com recrutador (recruiter screen).** 20–30 min, geralmente não
   técnica. Confirma o básico: experiência, pretensão salarial, **situação de
   visto/autorização de trabalho** e disponibilidade. Seja claro e honesto aqui.
2. **Entrevista técnica.** Com um estatístico ou programador sênior. Perguntas
   sobre CDISC, métodos, e sobre como você resolveria problemas reais. É aqui que
   o seu vocabulário do livro brilha.
3. **Estudo de caso / live coding.** Nem sempre existe, mas é comum para
   programação estatística: pode ser um exercício de SAS/R para levar para casa
   ou um problema resolvido ao vivo com alguém observando. Menos sobre a resposta
   perfeita, mais sobre **como você pensa** e comunica.
4. **Comportamental (behavioral).** Sobre trabalho em equipe, prazos, conflito,
   erros. Responda no formato **STAR** (*Situation, Task, Action, Result*):
   situação, tarefa, ação que você tomou, resultado. Estruture, não divague.

> **Na prática:** no live coding, **pense em voz alta**. Se você chegar à
> resposta em silêncio, o entrevistador não viu o seu raciocínio — que é
> justamente o que ele quer avaliar. Errar um detalhe de sintaxe explicando bem a
> lógica pontua mais que acertar em silêncio.

## Perguntas técnicas comuns (e como encará-las)

Não decore respostas — entenda os conceitos (o livro já te deu quase todos) e
saiba explicá-los em inglês, simples e direto.

- **ITT vs. per-protocol?** ITT (*Intention-to-Treat*) analisa todos os sujeitos
  no braço para o qual foram randomizados, independentemente de aderência —
  preserva a randomização e é conservadora para eficácia. Per-protocol analisa
  só quem seguiu o protocolo. Saiba **por que** o ITT é a população primária na
  maioria dos estudos de superioridade.
- **O que é um estimand?** A definição precisa do que o tratamento efetivamente
  faz: população, variável, tratamento dos **eventos intercorrentes**
  (*intercurrent events*) e resumo populacional — o framework do **ICH E9(R1)**.
  Saber citar os componentes já te coloca acima da média.
- **Como você faria uma tabela de AE?** Descreva: parte do ADAE, conta **sujeitos
  únicos** (não eventos) com pelo menos um AE, quebra por *system organ class* e
  *preferred term*, por braço de tratamento, e considera *treatment-emergent*.
  Mostra que você conhece o output de verdade.
- **SDTM vs. ADaM?** SDTM organiza os dados **coletados** de forma padronizada
  (um domínio por tipo de dado); ADaM é **analysis-ready**, derivado do SDTM, com
  as variáveis prontas para gerar TLFs e rastreáveis de volta ao SDTM.
- **Como lidar com missing data?** Fale de tipos (MCAR/MAR/MNAR), de por que
  simplesmente descartar é problemático, e de abordagens como MMRM ou imputação
  múltipla — e que a estratégia deve estar **pré-especificada no SAP**.
- **O que é um MMRM?** *Mixed Model for Repeated Measures* — modela medidas
  repetidas ao longo das visitas usando todos os dados disponíveis sob suposição
  MAR, sem imputar explicitamente. Muito comum como análise primária em endpoints
  contínuos longitudinais.

## O inglês na entrevista

Você não precisa de inglês perfeito — precisa de inglês **funcional e claro**
para explicar conceitos técnicos. Dicas concretas:

- **Pratique em voz alta** explicando os conceitos acima em inglês, sozinho ou
  gravando. Fluência técnica vem de repetição, não de vocabulário chique.
- **Ritmo:** fale mais devagar do que acha necessário. Clareza vale mais que
  velocidade, e desacelerar reduz travadas.
- Se não entender uma pergunta, **peça para repetir** — *"Could you rephrase
  that?"*. É normal e profissional, não um sinal de fraqueza.
- Domine o **vocabulário da área em inglês** (que é justamente o que este livro
  manteve no original): você vai falar de *estimands*, *baseline*, *treatment
  arms*, *adverse events* — não de tradução, mas dos termos reais.

> **Atenção — erros de currículo que eliminam candidatos de fora:**
> (1) resume em formato brasileiro, com foto, três páginas e parágrafos longos;
> (2) listar ferramentas que não sabe defender numa pergunta de follow-up;
> (3) descrever tarefas em vez de resultados ("responsible for...") sem verbos de
> ação nem números; (4) perfil de LinkedIn só em português, invisível para o
> recrutador americano; (5) omitir ou embaralhar a situação de autorização de
> trabalho — recrutadores precisam saber cedo, e falta de clareza aqui gera
> desconfiança. **Sobre visto e autorização de trabalho, consulte sempre um
> advogado de imigração** antes de afirmar qualquer coisa num processo; este
> livro orienta a carreira, não substitui aconselhamento jurídico.

## Resumo do capítulo

- O **resume americano** tem 1–2 páginas, sem foto nem dados pessoais, com
  **bullets curtos**, **verbos de ação** e **resultados quantificados**.
- Inclua, de forma verdadeira, as **keywords** que o ATS procura: CDISC, SDTM,
  ADaM, SAP, TLF, SAS, R, GCP — nunca liste o que não sabe defender.
- Para quem vem de fora, a seção **PROJECTS** com o portfólio do capítulo
  anterior ganha destaque logo abaixo do summary.
- Otimize o **LinkedIn** em inglês, com headline cheia de keywords, o repositório
  no Featured e "open to work" nos títulos-alvo — recrutadores caçam por lá.
- A entrevista costuma ter quatro fases: **triagem, técnica, estudo de
  caso/live coding e comportamental (STAR)**. No live coding, pense em voz alta.
- Prepare as perguntas técnicas clássicas (ITT vs PP, estimands, tabela de AE,
  SDTM vs ADaM, missing data, MMRM) e **pratique explicá-las em inglês** de forma
  clara. Em tudo que tocar em **visto, consulte um advogado de imigração**.
