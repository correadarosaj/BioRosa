# Define-XML, Reviewer's Guide e a submissão

Você já tem os dados: SDTM tabulado, ADaM pronto para análise. Mas dados soltos
não são uma submissão. Falta o que os torna **compreensíveis e auditáveis** para
um revisor do FDA que nunca falou com você e nunca verá o seu código: os
**metadados** e os **guias**. Este capítulo fecha a Parte V mostrando o que
realmente vai dentro do pacote de dados — e por que a rastreabilidade que
tanto martelamos se materializa aqui.

## Define-XML — o dicionário de dados legível por máquina

O **Define-XML** é a peça central da documentação de uma submissão de dados. É
um arquivo (em formato XML) que funciona como o **dicionário de dados** de todo o
pacote: ele descreve, de forma **legível por máquina**, cada dataset, cada
variável, cada vocabulário controlado e cada derivação.

Pense no Define-XML como o **mapa** que o revisor abre antes de tocar nos dados.
Para cada dataset (DM, AE, ADSL, ADAE...), ele diz:

- quais **variáveis** existem, seus rótulos, tipos e tamanhos;
- qual **Controlled Terminology** cada variável codificada usa;
- de onde cada variável **vem** (origem: coletada no CRF, derivada, atribuída) —
  é aqui que a **rastreabilidade** fica registrada formalmente;
- para variáveis derivadas, o **método de derivação** (a regra que a produz).

Existe um Define-XML para o SDTM e outro para o ADaM. Como é XML, ele é
processado por ferramentas automaticamente — mas também vem acompanhado de uma
folha de estilo que o renderiza como uma página navegável no navegador, para
leitura humana.

> **Glossário PT/EN:** *Define-XML* / "define" (EN) = o **metadado** que
> descreve os datasets, variáveis, CT e derivações de forma legível por máquina.
> É o "dicionário de dados" da submissão. *Origin* (EN) = a origem declarada de
> uma variável (coletada, derivada, atribuída) — o campo que ancora a
> rastreabilidade.

> **Atenção:** o Define-XML não é "papelada burocrática que se preenche no fim".
> Ele é o **contrato** entre os seus dados e o revisor. Um define incompleto ou
> inconsistente com os dados (variável que existe no dataset mas não no define,
> derivação declarada que não bate com o valor) é motivo de questionamento
> formal e pode atrasar a revisão. Trate-o como parte do produto, não como anexo.

## Reviewer's Guides — o texto que o define não conta

O Define-XML é preciso, mas seco. Há decisões, particularidades e convenções do
estudo que um documento estruturado de metadados não comunica bem — e é para isso
que existem os **Reviewer's Guides**, documentos em prosa (PDF) que orientam o
revisor pelo conjunto de dados.

São dois, um para cada mundo:

- **cSDRG** — *Clinical Study Data Reviewer's Guide*, o guia do **SDTM**.
  Explica o desenho do estudo em termos de dados, particularidades de cada
  domínio, decisões de mapeamento, itens de conformidade conhecidos e como
  navegar pelos datasets tabulados.
- **ADRG** — *Analysis Data Reviewer's Guide*, o guia do **ADaM**. Explica as
  populações de análise, as convenções de derivação, como os ADaM se ligam aos
  SDTM (rastreabilidade), quais datasets alimentam quais análises principais e
  qualquer particularidade que o revisor precise saber para reproduzir os
  resultados.

Enquanto o define diz **o que** cada variável é, o Reviewer's Guide diz **por
que** as coisas foram feitas daquele jeito. Os dois se complementam.

## O que compõe o pacote de submissão de dados

Juntando tudo, o "pacote de dados" que sobe para a submissão de um estudo
contém, tipicamente:

| Componente | O que é |
|---|---|
| Datasets **SDTM** | Os dados tabulados, em formato de transporte (arquivos `.xpt`) |
| Datasets **ADaM** | Os dados de análise, também em `.xpt` |
| **Define-XML** (SDTM) | Metadados dos datasets SDTM |
| **Define-XML** (ADaM) | Metadados dos datasets ADaM |
| **cSDRG** | Reviewer's Guide do SDTM (PDF) |
| **ADRG** | Reviewer's Guide do ADaM (PDF) |
| **Programas de análise** | Os programas que geram os ADaM e/ou os resultados principais |

Os datasets viajam num formato de transporte específico: o **SAS Transport
versão 5** (*SAS XPORT v5*, arquivos `.xpt`) — um formato aberto e estável,
escolhido justamente para que o FDA consiga abrir os dados independentemente do
software usado pelo sponsor. Já os **metadados** vão no **Define-XML v2.1**, que
o FDA recomenda para estudos **iniciados a partir de 15/03/2023**; as regras de
conteúdo do SDTM seguem o **SDTM Implementation Guide (SDTMIG) v6.0**, de março
de 2025. Há um formato mais novo, o **Dataset-JSON v1.1**, que está em **avaliação
e pilotos** para eventualmente substituir o `.xpt` — mas **ainda não é
obrigatório**.

> **Verificar (fonte):** versões aceitas e datas de corte evoluem. Confirme os
> requisitos vigentes nos documentos de *Study Data Technical Conformance* do FDA
> e no *Data Standards Catalog* (fda.gov) antes de montar um pacote real.

## Conformidade: Pinnacle 21 e validação

Antes de submeter, os datasets passam por **validação de conformidade** — a
verificação automática de que seguem as regras dos padrões CDISC e as regras de
negócio do FDA. A ferramenta mais conhecida desse mundo é o **Pinnacle 21**
(também conhecido pelo nome anterior, OpenCDISC), que roda centenas de checagens
sobre os datasets e o define e produz um relatório de **findings** classificados
por severidade (erros, avisos, notas).

O ponto importante para a sua carreira: **conformidade não é opcional e quase
nunca é perfeita "de primeira"**. O fluxo real é iterativo — você roda o
validador, lê os findings, corrige o que é corrigível, e para o que permanece
(há situações legítimas em que uma regra "dispara" mas o dado está correto) você
**documenta a justificativa** no Reviewer's Guide. O FDA não espera zero
findings; espera que cada finding tenha sido **examinado e explicado**.

> **Na prática:** um dia típico de programador SDTM/ADaM inclui rodar o Pinnacle
> 21, abrir o relatório, e trabalhar a lista de findings — corrigindo uns,
> justificando outros no cSDRG/ADRG. Saber ler esse relatório e distinguir "erro
> real" de "falso positivo que se documenta" é uma habilidade prática muito
> valorizada.

## O que o revisor do FDA faz com tudo isso

Do outro lado, o revisor do FDA usa esse pacote para **verificar
independentemente** as conclusões do estudo. Com os datasets padronizados, o
define e os guias, ele pode:

- **carregar** os dados diretamente nas suas próprias ferramentas (justamente
  porque estão em padrão comum);
- **reproduzir** análises-chave a partir dos ADaM;
- **rastrear** qualquer número de uma tabela de volta ao ADaM, ao SDTM e ao CRF;
- **explorar** os dados por conta própria, além das análises que o sponsor
  escolheu apresentar.

É por isso que a **rastreabilidade** importa tanto: ela não é um capricho
acadêmico, é o que permite ao revisor **confiar** nos seus resultados sem ter de
reconstruir o estudo do zero. Um pacote rastreável acelera a revisão; um pacote
com buracos gera perguntas, atrasos e desgaste.

## Onde isso vive na submissão: eCTD Module 5

Fechando o encaixe do capítulo 50: todo esse pacote de dados vive no **Module 5**
do **eCTD** (o *electronic Common Technical Document*, a estrutura eletrônica
padronizada da submissão), a seção dos relatórios de estudos clínicos. Os
datasets, o define, os guias e os programas de cada estudo têm um lugar
específico nessa estrutura de pastas — de modo que o revisor sempre saiba onde
procurar, em qualquer submissão de qualquer empresa.

> **Dica de carreira:** familiaridade com **Pinnacle 21** e com **Define-XML**
> aparece explicitamente em descrições de vaga de *Statistical Programmer* e de
> *SDTM/ADaM Programmer*. Poder dizer "já rodei o Pinnacle 21, sei ler o
> relatório de findings e sei o que entra num pacote de submissão (define,
> cSDRG, ADRG)" te coloca à frente de candidatos que só conhecem estatística.
> Se você quer um projeto de portfólio de alto impacto, montar um pequeno
> conjunto SDTM + ADaM + Define-XML de um estudo fictício e validá-lo é uma das
> demonstrações mais convincentes que existem para esse mercado.

## Resumo do capítulo

- O **Define-XML** é o **dicionário de dados legível por máquina** da submissão:
  descreve datasets, variáveis, Controlled Terminology e derivações, e registra
  formalmente a **rastreabilidade** (origem de cada variável). Há um para SDTM e
  um para ADaM.
- Os **Reviewer's Guides** — **cSDRG** (SDTM) e **ADRG** (ADaM) — explicam em
  prosa **por que** as coisas foram feitas, complementando o define.
- O pacote de dados reúne **datasets SDTM + ADaM (`.xpt`) + Define-XML + cSDRG +
  ADRG + programas**.
- A **validação de conformidade** (via **Pinnacle 21**) é iterativa: corrige-se o
  que dá e **documenta-se** o que resta — o FDA espera findings examinados e
  explicados, não necessariamente zero.
- O revisor usa o pacote para **reproduzir e rastrear** os resultados de forma
  independente — por isso a rastreabilidade acelera a revisão.
- Tudo vive no **Module 5** do **eCTD**; familiaridade com Pinnacle 21 e
  Define-XML é um diferencial explícito em vagas.
