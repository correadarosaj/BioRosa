# GCP, integridade de dados e o ambiente regulado (21 CFR Part 11)

Há um choque cultural esperando por todo profissional que vem da academia, da
ciência de dados ou do mercado financeiro e entra na pharma regulada. Lá fora,
o que importa é o resultado: se o modelo prevê bem, ninguém pergunta como você
chegou nele. Aqui, **como você chegou ao número importa tanto quanto o número**.
Um resultado correto obtido por um processo não rastreável **não vale**. Este
capítulo explica a lógica desse mundo — e por que ela existe.

## O que significa trabalhar em ambiente regulado

Trabalhar em ambiente **regulado** significa que seu trabalho pode, a qualquer
momento, ser **inspecionado** por uma autoridade (o FDA, por exemplo) que vai
querer verificar: os dados são confiáveis? o processo foi controlado? é possível
**reconstruir** exatamente o que foi feito? Se a resposta a qualquer dessas
perguntas for "não", os dados podem ser rejeitados — e anos de trabalho e
bilhões investidos vão junto.

Isso muda a natureza do trabalho. Em um ambiente **validado**, você não usa
qualquer ferramenta do jeito que quiser: você usa **sistemas validados**,
**processos documentados** e **código versionado**, porque tudo precisa ser
defensável diante de um inspetor. A frase que resume o espírito é: *"if it isn't
documented, it didn't happen"* — se não está documentado, não aconteceu.

## GCP na prática

Vimos no capítulo anterior que a **GCP** (*Good Clinical Practice*, ICH E6) é o
padrão internacional para conduzir ensaios com humanos. Para você, do lado dos
dados e da análise, GCP se traduz em algumas obrigações concretas:

- Trabalhar apenas com dados de **fontes controladas** (o banco de dados clínico
  oficial), nunca com planilhas soltas que alguém te mandou por e-mail.
- **Nunca** alterar um dado fora do processo formal. Se um valor parece errado,
  isso vira uma *query* para o *data management* resolver — você não "corrige"
  na sua análise.
- **Documentar** decisões e desvios. Toda escolha analítica relevante precisa
  estar registrada (no SAP, em memorandos, em comentários de código).
- Garantir que os resultados sejam **rastreáveis** de volta ao dado de origem.

GCP existe para proteger duas coisas: os **participantes** do estudo (o lado
ético) e a **confiabilidade dos dados** (o lado científico). Do seu assento, o
segundo é o que domina o dia a dia.

## ALCOA+ — os princípios de integridade de dados

A integridade de dados é frequentemente resumida no acrônimo **ALCOA**, expandido
para **ALCOA+**. É um checklist mental que vale internalizar, porque inspetores
pensam exatamente nesses termos:

- **A — Attributable (atribuível):** dá para saber **quem** gerou ou alterou o
  dado, e quando.
- **L — Legible (legível):** o registro é legível e permanente (não some, não é
  rasurado ao ponto de não se ler o original).
- **C — Contemporaneous (contemporâneo):** foi registrado **no momento** em que
  aconteceu, não reconstruído de memória depois.
- **O — Original:** é o registro original (ou uma cópia certificada verdadeira),
  não uma transcrição informal.
- **A — Accurate (exato):** o dado está correto e sem erros não corrigidos.

E o "**+**" acrescenta:

- **Complete (completo):** nada foi omitido, incluindo repetições e reanálises.
- **Consistent (consistente):** a sequência de eventos é coerente, com datas e
  horas em ordem.
- **Enduring (durável):** sobrevive pelo tempo de retenção exigido.
- **Available (disponível):** pode ser recuperado quando solicitado.

> **Glossário PT/EN:** *data integrity* (EN) = integridade de dados (PT) — a
> garantia de que os dados são completos, consistentes e confiáveis ao longo de
> todo o seu ciclo de vida, do registro à submissão.

ALCOA+ não é filosofia abstrata: cada letra vira uma exigência prática nos
sistemas que você usa. É por isso que existe a próxima peça — o 21 CFR Part 11.

## 21 CFR Part 11 — registros e assinaturas eletrônicas

O **21 CFR Part 11** é a parte do *Code of Federal Regulations* dos EUA (Título
21, Parte 11) que estabelece as condições sob as quais o FDA aceita **registros
eletrônicos** (*electronic records*) e **assinaturas eletrônicas** (*electronic
signatures*) como equivalentes aos de papel. Em outras palavras: é o que permite
que todo o trabalho seja digital sem perder a confiabilidade que o papel dava.

> **Glossário PT/EN:** *21 CFR Part 11* (EN) = leia "part eleven"; é a norma
> americana sobre registros e assinaturas eletrônicas em ambiente regulado pelo
> FDA. "CFR" = *Code of Federal Regulations*.

Na prática, o Part 11 exige que os sistemas computadorizados garantam, entre
outras coisas:

- **Trilha de auditoria** (*audit trail*): um registro automático, seguro e com
  data/hora de **quem fez o quê e quando** — criações, alterações e exclusões —
  sem que o usuário possa apagar ou adulterar esse histórico. É a materialização
  do "A" de *attributable* do ALCOA+.
- **Controle de acesso:** cada usuário tem credenciais próprias e permissões
  apropriadas; ninguém compartilha login, e o sistema sabe quem é quem.
- **Validação de sistemas computadorizados** (**CSV** — *Computer System
  Validation*): antes de um sistema ser usado para dados regulados, é preciso
  **demonstrar documentadamente** que ele faz o que deveria, de forma
  consistente. Um software não validado não pode gerar dado que vá para uma
  submissão.
- **Assinaturas eletrônicas** vinculadas de forma segura ao registro e ao
  signatário, de modo que não possam ser copiadas ou transferidas.

> **Verificar:** o FDA emitiu guidances que modernizam e esclarecem a aplicação
> do Part 11 (por exemplo, abordagens baseadas em risco e o uso de sistemas em
> nuvem). Confirme a guidance vigente em fda.gov antes de afirmar requisitos
> específicos a um cliente.

## "Programa validado" e por que existe o double programming

No mundo regulado, dizer que um programa é **validado** significa que existe
**evidência documentada** de que ele produz o resultado correto. Não basta
"rodou sem erro" — é preciso comprovar que a saída está certa.

A técnica mais emblemática dessa cultura é o **double programming** (programação
dupla, ou *independent programming*): **dois programadores** produzem
independentemente a **mesma** tabela ou dataset, a partir da mesma especificação,
usando código separado. Se os dois resultados **batem**, ganha-se confiança de
que a saída está correta; se **divergem**, investiga-se até achar a causa. É
caro, mas é a forma padrão de validar TLFs e datasets críticos de uma submissão.

> **Glossário PT/EN:** *double programming* (EN) = programação dupla (PT) — dois
> programadores replicam independentemente a mesma saída para conferir se
> coincidem; a base da validação de TLFs e datasets na indústria.

## Trilha de auditoria e versionamento de código

A trilha de auditoria não vale só para os dados clínicos — vale também para o
**seu código**. Por isso o **versionamento** (com ferramentas de controle de
versão como Git, ou sistemas equivalentes internos) não é um luxo de engenharia:
é parte da rastreabilidade exigida. Você precisa poder responder: qual versão do
código gerou esta tabela? o que mudou entre a versão de janeiro e a de março?
quem alterou e por quê?

Some a isso: SAP versionado, especificações de dataset versionadas, e uma cadeia
que liga **dado de origem → dataset → programa → tabela → resultado no relatório**.
Essa cadeia é o que um inspetor pode querer percorrer inteira.

## Reprodutibilidade como obrigação legal

Na academia, reprodutibilidade é uma **boa prática** que muita gente elogia e
pouca gente pratica. No mundo regulado, ela é uma **obrigação** — porque, como
vimos no capítulo do FDA, os **revisores do próprio FDA refazem suas análises**
a partir dos datasets que você entrega. Se o número deles não bater com o seu, o
problema é seu.

Isso significa que seu processo precisa ser **determinístico e documentado**: a
mesma entrada, com o mesmo código e o mesmo ambiente, tem que produzir **exatamente
o mesmo resultado**, hoje e daqui a cinco anos. Semente aleatória fixada quando há
simulação, versões de software controladas, caminhos de arquivo estáveis — tudo
isso deixa de ser preciosismo e vira requisito.

> **Atenção:** erros clássicos de quem chega novo ao ambiente regulado —
> **evite todos**:
> - **Editar dados na mão** ("só corrigi um valorzinho no Excel"). Nunca. Dado
>   errado vira *query*, não conserto silencioso.
> - **Código não determinístico:** esquecer de fixar a *seed*, depender de
>   ordenação instável, ou de arquivos temporários que mudam.
> - **Trabalhar fora do sistema validado:** baixar dados para a máquina local e
>   analisar "por fora". Se não está no ambiente controlado, não conta.
> - **Não versionar / sobrescrever:** salvar `analise_final_v2_FINAL.R` por cima
>   do anterior, sem histórico de quem mudou o quê.
> - **Achar que "o resultado certo" basta:** sem trilha, sem validação e sem
>   documentação, um resultado correto é regulatoriamente inútil.
> - **Comentários e log ausentes:** um programa que ninguém consegue auditar
>   depois é um passivo, por mais elegante que seja.

## Resumo do capítulo

- Em ambiente **regulado/validado**, **como** você chegou ao resultado importa
  tanto quanto o resultado: tudo precisa ser rastreável e defensável diante de
  uma inspeção do FDA. *"If it isn't documented, it didn't happen."*
- **GCP** (ICH E6), do lado dos dados, significa usar fontes controladas, nunca
  alterar dados fora do processo formal, documentar decisões e garantir
  rastreabilidade até a origem.
- **ALCOA+** (Attributable, Legible, Contemporaneous, Original, Accurate +
  Complete, Consistent, Enduring, Available) é o checklist de integridade de
  dados que inspetores usam.
- O **21 CFR Part 11** rege registros e assinaturas eletrônicas e exige **trilha
  de auditoria**, **controle de acesso**, **validação de sistemas (CSV)** e
  assinaturas seguras.
- **Programa validado** = evidência documentada de que a saída está correta; o
  **double programming** (programação dupla independente) é a forma padrão de
  validar TLFs e datasets críticos.
- **Reprodutibilidade é obrigação legal**, não só boa prática — os revisores do
  FDA refazem suas análises. Versione código, SAP e specs, e mantenha a cadeia
  dado → dataset → programa → tabela → resultado. Confirme sempre a guidance
  vigente do Part 11 em fda.gov.
