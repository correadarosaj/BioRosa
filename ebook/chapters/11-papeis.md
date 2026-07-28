# Os papéis: quem faz o quê na estatística clínica

No capítulo anterior você viu o ecossistema — sponsors, CROs, o FDA. Agora
vamos entrar no organograma. "Trabalhar com estatística clínica" não é um
cargo só: é uma família de papéis que dividem o trabalho de transformar dados
de ensaios em evidência aceita pelo FDA. Entender quem faz o quê é essencial
por dois motivos práticos: primeiro, porque as vagas usam esses títulos e você
precisa saber a qual se candidatar; segundo, porque a **porta de entrada** para
quem vem de fora costuma ser um papel específico — e não necessariamente o que
você imagina.

Vamos destrinchar os quatro principais: **Biostatistician**, **Statistical
Programmer**, **Clinical Data Manager** e **Clinical Data Scientist**.

## Biostatistician

O **Biostatistician** (bioestatístico) é o dono dos **métodos**. É quem decide
*como* o estudo vai ser analisado e responde por essas escolhas perante o
sponsor e, em última instância, perante o FDA.

**No dia a dia**, um biostatistician:

- participa do desenho do estudo — cálculo de tamanho amostral (*sample size*),
  escolha do desenho, definição de *endpoints* (desfechos) e do *estimand* (a
  quantidade que o estudo quer estimar);
- escreve o **SAP** — o *Statistical Analysis Plan*, o documento que congela o
  plano de análise antes de os dados serem desbloqueados;
- especifica as **shells** de tabelas (os moldes vazios das TLFs) e revisa os
  resultados que os programadores produzem;
- interpreta os resultados e contribui para o **CSR** (*Clinical Study Report*,
  o relatório final do estudo) e para respostas a perguntas do FDA.

> **Glossário PT/EN:** *Sample size* (EN) = tamanho amostral, quantos pacientes
> o estudo precisa; *estimand* (EN) = a definição precisa do efeito que se quer
> estimar (o quê, em quem, apesar de quais eventos intercorrentes).

**Entregáveis típicos:** SAP, shells de TLF, seções estatísticas de protocolo e
de CSR, pareceres de método, memorandos de resposta a agências.

**Ferramentas típicas:** SAS e/ou R para análise; ferramentas de cálculo de
poder (como nQuery ou pacotes de R); Word e sistemas de documentação para os
planos. O biostatistician escreve e valida análises, mas em muitas empresas
delega a produção em massa de TLFs aos programadores.

**Formação usual:** mestrado ou doutorado em **Bioestatística**, Estatística,
Epidemiologia ou área afim. É o papel onde credencial acadêmica pesa mais — um
mestrado costuma ser o piso esperado, e o PhD abre as portas mais rápido para
funções de desenho de estudo.

**Senioridade:** Biostatistician I/II → Senior Biostatistician → Principal
Biostatistician → Director / VP of Biostatistics. A progressão vai de "executa
análises sob supervisão" a "define a estratégia estatística de um programa
inteiro e negocia com o FDA".

## Statistical Programmer (SAS/R programmer)

O **Statistical Programmer** (programador estatístico, também chamado de *SAS
programmer* ou *clinical programmer*) é quem **constrói os dados e os
resultados**. Se o biostatistician é o arquiteto, o programador é quem executa a
obra — com um rigor de engenharia que é o coração da profissão.

**No dia a dia**, um statistical programmer:

- transforma dados brutos coletados no estudo em **datasets padronizados
  CDISC** — primeiro **SDTM** (o padrão dos dados como coletados) e depois
  **ADaM** (os datasets de análise, prontos para gerar resultados);
- produz as **TLFs** — *Tables, Listings and Figures* (tabelas, listagens e
  figuras) — que resumem eficácia e segurança;
- faz **double programming** (dupla programação): duas pessoas programam a mesma
  tabela de forma independente e comparam os resultados até baterem — a garantia
  de qualidade que o ambiente regulado exige;
- prepara os pacotes de dados e programas que vão na submissão ao FDA.

> **Glossário PT/EN:** *Double programming* (EN) = dupla programação
> independente; duas implementações da mesma saída são comparadas para provar
> que o resultado está correto.

**Entregáveis típicos:** datasets SDTM e ADaM, TLFs, *define.xml* (a
documentação que descreve os datasets), programas SAS/R validados,
*reviewer's guides*.

**Ferramentas típicas:** **SAS** é ainda a língua franca (veremos por quê no
Capítulo 13), com **R** crescendo rápido; SQL para lidar com bancos de dados;
Git para controle de versão; sistemas de submissão e de validação.

**Formação usual:** graduação em Estatística, Matemática, Ciência da Computação,
ciências da vida com viés de dados — ou qualquer área quantitativa **com
domínio de programação**. Aqui o mestrado ajuda, mas **não é obrigatório**: o
que se testa é se você programa bem e entende o fluxo CDISC.

**Senioridade:** Programmer I/II → Senior Statistical Programmer → Principal /
Lead Programmer → Programming Manager / Associate Director. O lead costuma ser
responsável técnico por um estudo ou por um programa inteiro, coordenando outros
programadores.

> **Na prática:** para quem vem de fora do mercado americano, **statistical
> programming é quase sempre a porta de entrada mais acessível**. A demanda é
> altíssima e crônica, o critério de contratação é mais objetivo (você sabe ou
> não sabe programar SDTM/ADaM e produzir TLFs), a barreira de credencial
> acadêmica é menor que na bioestatística, e muitas dessas vagas são
> **remotas** — o que reduz a barreira geográfica e de visto no começo.

## Clinical Data Manager

O **Clinical Data Manager** (gerente de dados clínicos, CDM) cuida da
**qualidade e integridade dos dados** antes de eles chegarem à análise. É um
papel "a montante" do estatístico: sem dados limpos e confiáveis, nenhuma
análise vale nada.

**No dia a dia**, um clinical data manager:

- projeta o **CRF** (*Case Report Form*, o formulário de coleta de dados) e o
  banco de dados do estudo no sistema de **EDC** (*Electronic Data Capture*);
- escreve e roda **edit checks** — regras automáticas que detectam
  inconsistências (uma data de nascimento no futuro, um valor fora de faixa);
- gerencia **queries**: perguntas enviadas aos centros clínicos para corrigir ou
  esclarecer dados suspeitos;
- conduz o **database lock** — o congelamento oficial do banco de dados, o
  marco que libera a análise final.

> **Glossário PT/EN:** *Database lock* (EN) = travamento do banco de dados; o
> momento em que os dados são declarados finais e nenhuma alteração adicional é
> permitida sem controle formal.

**Entregáveis típicos:** especificação do CRF, plano de gerenciamento de dados
(*DMP*), edit checks, relatórios de qualidade de dados, database lock.

**Ferramentas típicas:** sistemas de EDC como Medidata Rave, Oracle Clinical /
Inform, Veeva; SQL; ferramentas de reconciliação. Programação estatística
pesada não é o foco.

**Formação usual:** ciências da vida, enfermagem, farmácia, saúde pública ou
áreas afins; menos dependente de estatística avançada e mais de organização,
atenção a processo e conhecimento de GCP (*Good Clinical Practice*).

**Senioridade:** Clinical Data Coordinator → Clinical Data Manager → Senior CDM
→ Data Management Lead / Manager. É um papel de carreira sólido por si só, e
também um ponto de contato frequente com os times de programação e estatística.

## Clinical Data Scientist

O **Clinical Data Scientist** é o papel mais **novo e menos padronizado** dos
quatro — o título significa coisas diferentes em empresas diferentes. Em geral,
descreve alguém que combina competência estatística/de programação com
métodos mais modernos de ciência de dados aplicados ao contexto clínico.

**No dia a dia**, dependendo da empresa, pode:

- aplicar **machine learning** e modelagem preditiva a dados clínicos e de
  *real-world data* (dados do mundo real, fora do ensaio controlado);
- construir pipelines de dados, dashboards e ferramentas de exploração;
- apoiar decisões com análises exploratórias que não vão direto para a
  submissão regulatória, mas informam estratégia.

**Entregáveis típicos:** modelos, pipelines de dados, dashboards, análises
exploratórias, ferramentas internas.

**Ferramentas típicas:** **R** e **Python** com força, SQL, ferramentas de
nuvem e de visualização, frameworks de ML.

**Formação usual:** bastante variada — de estatística a ciência da computação e
data science. Costuma pedir mais Python e engenharia de dados que os papéis
clássicos.

> **Atenção:** "Clinical Data Scientist" é um título **elástico**. Antes de se
> candidatar, leia a descrição da vaga com atenção: às vezes é essencialmente um
> statistical programmer com outro nome; às vezes é um cientista de dados
> genérico que por acaso trabalha com saúde; às vezes é um papel de submissão
> regulatória moderno. Não presuma pelo título.

## Como os papéis se encaixam

Pense no fluxo de um estudo:

```text
Data Manager ──► dados limpos ──► Statistical Programmer ──► SDTM/ADaM + TLFs
   (coleta,                          (constrói datasets              │
    qualidade,                        e resultados)                  ▼
    database lock)                                          Biostatistician
                                                          (desenha o SAP,
                                                           interpreta, defende)
```

O **Data Scientist** orbita esse fluxo, muitas vezes com dados exploratórios ou
de mundo real que não seguem o caminho regulado clássico.

## Faixas salariais (ordens de grandeza)

Trate tudo abaixo como **ordem de grandeza** para comparar papéis entre si — não
como números fixos, que variam por região, empresa e ano:

- **Statistical Programmer** e **Biostatistician** costumam ter faixas
  **parecidas** nos níveis iniciais e intermediários, ambos entre os cargos bem
  remunerados para perfis quantitativos.
- No longo prazo, a **bioestatística** tende a ter um teto um pouco mais alto em
  funções de liderança de método e desenho, enquanto a **programação** oferece
  trajetórias de liderança técnica e de gestão igualmente sólidas.
- **Clinical Data Manager** costuma partir de uma faixa um pouco **abaixo** dos
  dois anteriores, mas com carreira estável e progressão clara.
- **Clinical Data Scientist** varia muito — pode alcançar as faixas mais altas
  quando o papel é sênior e técnico, mas o título por si só não garante isso.

> **Verificar:** confirmar faixas salariais atuais em fontes de mercado (BLS,
> pesquisas salariais de recrutadores de pharma) antes de publicar quaisquer
> números específicos.

## Como escolher entre biostat e programming

> **Dica de carreira:** se você **gosta de programar** e quer a rota de entrada
> mais rápida e com barreira de credencial mais baixa, mire **statistical
> programming** — a demanda é maior, o critério é mais objetivo e há mais vagas
> remotas. Se você **gosta de métodos, desenho e da parte "por que"** da
> estatística, e tem (ou está disposto a buscar) um mestrado/PhD, mire
> **biostatistician**. Os dois caminhos convergem no mesmo mundo regulado, e é
> comum migrar de programação para bioestatística depois de ganhar experiência
> — o contrário é mais raro. Para muitos brasileiros, **entrar como programador
> e depois decidir** é a estratégia de menor risco.

## Resumo do capítulo

- A estatística clínica é uma **família de papéis**, não um cargo único: os
  quatro principais são Biostatistician, Statistical Programmer, Clinical Data
  Manager e Clinical Data Scientist.
- O **Biostatistician** é o dono dos métodos (SAP, desenho, estimand,
  interpretação) e é o papel onde credencial acadêmica pesa mais.
- O **Statistical Programmer** constrói datasets CDISC (SDTM/ADaM) e TLFs com
  rigor de dupla programação; é a **porta de entrada mais acessível** para quem
  vem de fora, com mais vagas e mais oportunidades remotas.
- O **Clinical Data Manager** garante a qualidade dos dados até o database lock;
  o **Clinical Data Scientist** é um papel novo e elástico, com mais Python e ML.
- Salários de biostat e programming são **parecidos** no início; trate qualquer
  número como ordem de grandeza.
- Escolha pela sua inclinação (programar vs. métodos), lembrando que **entrar por
  programação e migrar depois** costuma ser a rota de menor risco.
