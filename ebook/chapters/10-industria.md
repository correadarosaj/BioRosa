# A indústria de pesquisa clínica nos Estados Unidos

Antes de aprender a escrever um SAP ou a estruturar um dataset ADaM, você
precisa entender o território. Quem contrata bioestatísticos nos Estados
Unidos? De onde vem o dinheiro? Por que existe tanta demanda por esse perfil —
e por que ela não vai desaparecer tão cedo? Este capítulo é o mapa do
ecossistema em que você quer entrar.

## Por que existe uma indústria inteira em torno de estatística clínica

Nos Estados Unidos, **nenhum medicamento novo, vacina ou terapia biológica
chega ao mercado sem passar pelo crivo do FDA** — a *Food and Drug
Administration*, a agência federal que regula alimentos e medicamentos. E o FDA
não aprova nada com base em opinião ou em uma boa história: ele exige
**evidência estatística rigorosa** de que o produto é seguro e eficaz.

Essa exigência é a razão de existir da sua futura profissão. Cada ensaio
clínico que sustenta um pedido de aprovação precisa de um estatístico para:

- ajudar a **desenhar** o estudo (quantos pacientes? qual comparação?);
- escrever o **plano de análise** (o *Statistical Analysis Plan*, ou SAP) antes
  de os dados serem vistos;
- transformar os dados brutos em **datasets padronizados** (CDISC);
- produzir as **tabelas, listagens e figuras** (TLFs) que resumem os resultados;
- e defender esses números diante dos revisores do FDA.

> **Na prática:** um único medicamento pode custar mais de US$ 1 bilhão e mais
> de dez anos para chegar ao mercado. A maior parte desse custo está em ensaios
> clínicos — e cada ensaio emprega estatísticos e programadores. É um mercado
> grande, estável e mal atendido por talento qualificado.

## Os quatro grandes players

O ecossistema tem quatro tipos de organização. Entender quem é quem ajuda você
a mirar as vagas certas.

### 1. Pharma e biotech (os *sponsors*)

São as empresas que **desenvolvem e são donas** do medicamento — de gigantes
como Pfizer, Merck, Johnson & Johnson e Eli Lilly a milhares de pequenas
empresas de biotecnologia. No jargão regulatório, a empresa dona do estudo é o
*sponsor* (patrocinador). O sponsor é o responsável legal perante o FDA.

- **Big pharma:** grandes departamentos de bioestatística, processos maduros,
  muitos padrões internos, ótima estrutura para quem está começando.
- **Biotech:** empresas menores, às vezes com um único produto em
  desenvolvimento. Menos gente, mais responsabilidade por pessoa, ritmo
  intenso. Frequentemente **terceirizam** boa parte do trabalho estatístico.

### 2. CROs — *Contract Research Organizations*

Uma **CRO** é uma empresa que **executa pesquisa clínica sob contrato** para os
sponsors. Nomes como IQVIA, ICON, Parexel, Fortrea e Labcorp Drug Development
são CROs enormes que empregam dezenas de milhares de pessoas no mundo todo.

Para você, brasileiro entrando no mercado, **as CROs são frequentemente a porta
de entrada mais realista**: elas contratam em volume, têm programas de
treinamento, operam globalmente (inclusive com times na América Latina) e estão
sempre precisando de programadores estatísticos e bioestatísticos.

> **Dica de carreira:** muitas CROs têm operações ou parceiros na América
> Latina e contratam para trabalho remoto. Começar em uma CRO — mesmo
> remotamente, mesmo em um cargo júnior — é uma das formas mais acessíveis de
> ganhar experiência regulada "de verdade" no seu currículo.

### 3. O FDA e as agências regulatórias

O **FDA** é o cliente final invisível de todo o seu trabalho. Você
provavelmente não vai trabalhar *no* FDA no início da carreira (a maioria dos
cargos exige cidadania americana), mas **tudo o que você produz é escrito para
os olhos de um revisor do FDA**. Entender o que esse revisor espera — que é boa
parte deste livro — é o que separa um profissional júnior de um sênior.

Equivalentes existem em outros mercados (a EMA na Europa, a ANVISA no Brasil,
a PMDA no Japão), mas o mercado americano gira em torno do FDA, e é nele que
este livro foca.

### 4. Academia e centros médicos

Universidades, hospitais universitários e institutos como o NIH (*National
Institutes of Health*) também conduzem ensaios clínicos — muitas vezes
investigador-iniciados, financiados por *grants* públicos. O trabalho
estatístico é semelhante, mas o ambiente é menos padronizado e os salários
costumam ser menores que na indústria. É um caminho válido, especialmente para
quem vem de um doutorado, mas não é o foco principal deste livro.

## Como o dinheiro (e o trabalho) flui

O fluxo típico é:

```text
Investidores / receita da pharma
        │
        ▼
   SPONSOR (pharma/biotech)  ──contrata──►  CRO
        │                                     │
        │  desenha o programa clínico         │  executa os estudos:
        │  é dono dos dados e da submissão    │  data management, biostat,
        ▼                                     ▼  programação, monitoria...
      Submissão ao FDA  ◄──── TLFs, datasets CDISC, SAP, relatórios
```

O sponsor decide desenvolver um medicamento e desenha o **programa clínico**
(o conjunto de estudos). Ele pode fazer o trabalho estatístico internamente,
terceirizar tudo para uma CRO, ou (o mais comum) uma mistura dos dois. O
produto do trabalho estatístico — SAP, datasets padronizados, TLFs — sobe pela
cadeia até compor a **submissão regulatória** ao FDA.

Você pode estar empregado por qualquer elo dessa cadeia. O trabalho técnico é
essencialmente o mesmo; o que muda é o ambiente, a variedade de projetos e a
estrutura de carreira.

## Tamanho, estabilidade e demanda

Alguns fatos que valem a pena internalizar, porque eles sustentam a tese de
carreira deste livro:

- A indústria farmacêutica é **anticíclica**: pessoas adoecem e precisam de
  remédios independentemente da economia. Ensaios clínicos em andamento não
  param no meio.
- Cada estudo precisa de estatística **por lei** — não é um "extra" que se corta
  em tempos de aperto. É uma exigência regulatória.
- Há uma **escassez crônica** de programadores estatísticos e bioestatísticos
  qualificados em CDISC e no fluxo regulatório. A oferta de talento não
  acompanha a demanda.
- O trabalho é **altamente transferível**: os padrões (CDISC, ICH, o formato de
  um SAP) são globais. O que você aprende serve para qualquer sponsor ou CRO no
  mundo.

> **Atenção:** "demanda alta" não significa "fácil entrar". O mercado valoriza
> experiência regulada específica (CDISC, SAP, submissões), que é justamente o
> que um recém-chegado ainda não tem. Este livro existe para fechar exatamente
> essa lacuna — te dar o vocabulário e as competências que sinalizam
> "esta pessoa já entende como funciona".

## Faixas salariais (para calibrar expectativas)

Salários variam muito por região, empresa, senioridade e tipo de contrato, e
mudam com o tempo — trate os números abaixo como **ordens de grandeza** para
calibrar, não como promessas. No mercado americano, cargos de bioestatística e
programação estatística na indústria estão entre os melhores remunerados para
perfis quantitativos:

- **Nível de entrada (júnior):** faixa inicial confortável já acima da média de
  profissões quantitativas.
- **Pleno / sênior:** crescimento expressivo com poucos anos de experiência
  regulada comprovada.
- **Liderança (lead / principal / manager):** patamar bastante alto,
  especialmente em big pharma e em consultoria/CRO.

> **Dica de carreira:** os títulos "Statistical Programmer" e "Biostatistician"
> têm faixas parecidas nos níveis iniciais, mas trajetórias diferentes no
> longo prazo (veremos no próximo capítulo). Ambos são portas de entrada
> viáveis — a programação estatística costuma ter a barreira de entrada um
> pouco menor para quem vem de fora.

## Onde você se encaixa nisso tudo

Se você chegou até aqui, provavelmente está mirando um destes dois destinos —
que o próximo capítulo detalha:

- **Biostatistician** — mais perto do desenho do estudo, dos métodos e do SAP;
- **Statistical Programmer** — mais perto dos dados, do CDISC e dos TLFs.

Nos dois casos, o caminho de entrada mais realista para um brasileiro passa por:
(a) dominar o **vocabulário e o fluxo regulado** — o que este livro ensina;
(b) construir **evidência** de que você sabe fazer o trabalho (um portfólio, um
projeto de ponta a ponta); e (c) entrar por uma **CRO** ou por uma vaga remota,
onde o volume de contratação é maior e a barreira geográfica é menor.

Nos próximos capítulos vamos destrinchar os papéis, os vistos e as
competências. Depois, mergulhamos no trabalho técnico de verdade.

## Resumo do capítulo

- Nos EUA, nenhum medicamento é aprovado sem **evidência estatística** aceita
  pelo FDA — essa exigência é a razão de existir da sua profissão.
- Quatro players compõem o ecossistema: **sponsors** (pharma/biotech), **CROs**,
  o **FDA** e a **academia**. As CROs costumam ser a porta de entrada mais
  acessível para quem vem de fora.
- O trabalho estatístico flui do sponsor (que desenha e é dono do estudo) para a
  execução (frequentemente na CRO) e sobe até a **submissão ao FDA**.
- A demanda é **alta e estável** (anticíclica, exigida por lei, com padrões
  globais transferíveis), mas valoriza **experiência regulada específica** —
  exatamente a lacuna que este livro fecha.
- Salários são atraentes e crescem rápido com experiência regulada comprovada;
  trate qualquer número como ordem de grandeza, não como promessa.
- Seus dois destinos prováveis são **Biostatistician** e **Statistical
  Programmer** — tema do próximo capítulo.
