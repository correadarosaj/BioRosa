# O stack de competências: o que aprender e em que ordem

Você já conhece o ecossistema, os papéis e as rotas de imigração. Falta a
pergunta mais prática de todas: **o que exatamente eu preciso saber fazer?** Este
capítulo é o inventário de competências — as linguagens, as ferramentas, a
estatística e as *soft skills* que o mercado espera — e, no fim, um **roteiro de
aprendizado** para quem está começando do zero. A ideia não é você dominar tudo
antes de se candidatar; é você entender o mapa e atacar na ordem certa.

## As linguagens: SAS, R e Python

### SAS — ainda o rei das submissões

O **SAS** é uma linguagem e um ambiente de análise estatística que domina a
indústria farmacêutica há décadas. Se você só puder aprender uma linguagem para
entrar nesse mercado, comece por ela. Por quê?

- **Herança regulatória:** o fluxo de submissão ao FDA foi construído em torno do
  SAS. Os padrões CDISC, os formatos de dataset (o histórico **XPT** para
  transporte), e décadas de programas validados vivem em SAS.
- **Ambiente validado:** empresas reguladas investem pesado em *validar* suas
  ferramentas (provar que produzem resultados corretos e reproduzíveis). O SAS
  chega com essa validação e o suporte comercial que a indústria exige.
- **Massa crítica:** a maior parte do código legado, das macros internas e das
  vagas ainda pede SAS. Saber SAS é o que mais rápido te torna **empregável**
  hoje.

> **Glossário PT/EN:** *Validated environment* (EN) = ambiente validado; sistema
> cujo funcionamento correto foi formalmente comprovado e documentado, exigência
> de qualquer ferramenta usada em trabalho que vai para o FDA.

### R — crescendo rápido e aceito pelo FDA

O **R** é a linguagem open-source de estatística que ganhou o mundo acadêmico e
agora avança forte na pharma. Dois pontos importantes:

- O **FDA aceita submissões que usam R**. A agência não exige SAS; exige
  **evidência de que os resultados são corretos e reproduzíveis** — e isso pode
  ser feito em R.
- Existe um movimento organizado de **pharma open-source**: consórcios da
  indústria (como o trabalho em torno da R Consortium e de iniciativas
  colaborativas entre empresas) desenvolvendo pacotes de R prontos para uso
  regulado. O guarda-chuva mais conhecido é o **pharmaverse** — uma coleção
  curada de pacotes de R para o fluxo clínico (construção de SDTM/ADaM, TLFs,
  etc.), como `admiral`, `pharmaverseadam`, entre outros.

> **Na prática:** aprender R **e** contribuir ou brincar com pacotes do
> pharmaverse é uma jogada dupla: você aprende a ferramenta em ascensão e
> constrói **portfólio público** — commits, exemplos, discussões. Isso é
> evidência visível de competência, útil tanto para o currículo quanto para
> vistos como O-1 e EB-2 NIW (Capítulo 12).

### Python — o papel emergente

O **Python** ainda não é central no fluxo de submissão regulatória clássico, mas
cresce nas bordas: automação, engenharia de dados, machine learning, *real-world
data* e ferramentas internas. Para os papéis de **Clinical Data Scientist**, é
frequentemente esperado. Para programação estatística e bioestatística de
submissão, é um bônus, não um pré-requisito — por enquanto.

> **Dica de carreira:** para **empregabilidade imediata**, SAS ainda abre mais
> portas na programação de submissão. Para **onde o mercado está indo**, R é a
> aposta de crescimento e o FDA já o aceita. A recomendação prática para a
> maioria dos iniciantes: **aprenda SAS primeiro para entrar, e R em paralelo
> para durar.** Se você mira especificamente Data Science clínico, inverta o
> peso para R/Python. Não trate como "um ou outro" — o profissional completo
> transita entre eles.

## As ferramentas de apoio: SQL e Git

**SQL** é a linguagem de consulta a bancos de dados. Dados clínicos vivem em
bancos, e saber extrair, juntar e filtrar dados com SQL é uma competência
básica e transferível — vale para programadores, data managers e data
scientists.

**Git** (e controle de versão em geral) virou padrão à medida que a pharma
moderniza suas práticas, especialmente com a adoção de R. Controle de versão é o
que permite rastrear quem mudou o quê e quando — algo que combina perfeitamente
com a mentalidade de **rastreabilidade e validação** do ambiente regulado.
Aprender o básico de Git (commit, branch, merge, pull request) te coloca à frente
de muitos candidatos que só conhecem SAS clássico.

## A estatística que o trabalho realmente exige

Você não precisa ser um pesquisador de métodos, mas precisa ter fluência
prática nos modelos que aparecem em ensaios clínicos de verdade:

- **Modelos lineares e mistos** (*linear and mixed models*): a base de boa parte
  das análises de eficácia; modelos mistos aparecem sempre que há medidas
  repetidas ou estrutura hierárquica.
- **Análise de sobrevivência** (*survival analysis*): tempo até um evento
  (Kaplan-Meier, modelo de Cox) — fundamental em oncologia e em muitos endpoints.
- **Dados categóricos** (*categorical data*): tabelas de contingência, regressão
  logística, odds ratios e risk ratios — onipresentes em segurança e em desfechos
  binários.
- **Dados longitudinais** (*longitudinal data*): pacientes medidos ao longo do
  tempo; modelos para medidas repetidas.
- **Dados faltantes** (*missing data*): quase todo ensaio tem dados faltantes; é
  preciso entender os mecanismos (MCAR, MAR, MNAR) e métodos de tratamento
  (imputação múltipla, análises de sensibilidade). O FDA se importa muito com
  como você lida com o que ficou faltando.

> **Na prática:** o diferencial não é conhecer o método na teoria — é saber
> **implementá-lo no ambiente regulado**, com a documentação certa, ligado ao
> estimand definido no SAP e reproduzível na dupla programação. A ponte entre "eu
> sei estatística" e "eu produzo estatística que vai ao FDA" é justamente o que
> os capítulos técnicos deste livro constroem.

## Ler protocolo e SAP

Duas leituras são o pão de cada dia:

- O **protocolo** é o documento-mestre do estudo: objetivos, desenho, população,
  endpoints, procedimentos. Tudo o que você faz deriva dele.
- O **SAP** (*Statistical Analysis Plan*) traduz o protocolo em um plano de
  análise preciso: quais análises, em quais populações, com quais métodos.

Saber **ler** esses documentos com olhar crítico — encontrar o endpoint
primário, entender a população de análise, identificar o que o SAP especifica
para cada tabela — é uma competência que separa o júnior perdido do júnior útil.

## Competências comportamentais (soft skills): o que ninguém coloca no currículo mas todo mundo avalia

Num ambiente validado e regulado, o "como" importa tanto quanto o "o quê":

- **Documentação obsessiva:** se não está documentado, não aconteceu. Programas,
  decisões e desvios precisam ser rastreáveis.
- **Comunicação com clínicos e não estatísticos:** você vai explicar resultados
  para médicos, gerentes de projeto e reguladores. Traduzir estatística para
  quem não é estatístico é uma habilidade valiosíssima.
- **Trabalho em ambiente validado:** seguir SOPs (*Standard Operating
  Procedures*, procedimentos operacionais padrão), respeitar controle de versão,
  aceitar que rigor e rastreabilidade vêm antes de esperteza individual. Quem vem
  da academia às vezes estranha isso; abrace desde cedo.
- **Atenção a detalhe:** em pharma, um número errado numa tabela não é um bug —
  é potencialmente um problema regulatório. O cuidado é cultural.

> **Glossário PT/EN:** *SOP* (EN) = Standard Operating Procedure, procedimento
> operacional padrão; documento que define exatamente como uma tarefa deve ser
> feita para garantir consistência e conformidade.

## Roteiro sugerido: o que aprender primeiro

Se você está começando do zero, uma ordem que equilibra empregabilidade rápida e
solidez de longo prazo:

1. **SAS base** — sintaxe, DATA step, PROCs estatísticos. É o que mais rápido te
   torna candidato viável a vagas de programação. (R em paralelo se puder.)
2. **O fluxo CDISC** — entender **SDTM** e **ADaM** de verdade (tema central dos
   próximos capítulos). É isto que transforma "sei programar" em "sei programar
   *para submissão*".
3. **A estatística prática** — reforce modelos lineares/mistos, sobrevivência,
   categóricos e **missing data**, sempre pensando em como implementá-los.
4. **Ler protocolo e SAP** — pegue exemplos públicos e treine encontrar endpoint
   primário, população de análise e especificação de tabelas.
5. **R + pharmaverse** — aprenda R e explore `admiral` e amigos; construa um
   **projeto de portfólio público** de ponta a ponta (dados de exemplo → ADaM →
   um TLF).
6. **Git e SQL** — o suficiente para versionar seu trabalho e consultar bancos;
   não precisa de mais que o básico sólido no começo.
7. **Inglês técnico** — treinado dentro dos passos acima, lendo tudo no original.

> **Na prática:** não espere "terminar" o roteiro para agir. Assim que você tiver
> SAS base + noção de CDISC + um projeto de portfólio, já dá para se candidatar a
> vagas júnior e remotas. Aprendizado e busca de vaga andam **em paralelo** — o
> mercado valoriza quem mostra evidência de trabalho real mais do que quem
> coleciona certificados.

## Resumo do capítulo

- **SAS** ainda domina as submissões ao FDA (herança regulatória, ambiente
  validado, massa crítica de vagas) e é o caminho mais rápido para a
  empregabilidade; comece por ele.
- **R** cresce rápido, **é aceito pelo FDA** e tem um movimento open-source forte
  (**pharmaverse**, `admiral`) que serve de ferramenta e de portfólio público.
  **Python** é emergente, central em Data Science clínico, bônus no resto.
- Some **SQL** e **Git** ao stack — consulta a dados e controle de versão são
  básicos transferíveis e alinhados à cultura de rastreabilidade.
- A estatística exigida na prática: **modelos lineares/mistos, sobrevivência,
  categóricos, longitudinais e missing data** — com foco em *implementar* no
  ambiente regulado, não só na teoria.
- Saber **ler protocolo e SAP** e ter **soft skills** de documentação,
  comunicação e trabalho validado separam o júnior útil do júnior perdido.
- Roteiro: **SAS base → CDISC (SDTM/ADaM) → estatística prática → ler protocolo/
  SAP → R + pharmaverse (com projeto de portfólio) → Git/SQL → inglês técnico**,
  aprendendo e se candidatando em paralelo.
