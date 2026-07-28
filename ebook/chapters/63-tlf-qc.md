# QC e validação de TLFs

Um número errado numa tabela de eventos adversos pode significar um sinal de
segurança que passou despercebido — ou um falso alarme que atrasa uma
aprovação. Por isso, num ambiente regulado, **nenhum TLF vai para o CSR sem
passar por controle de qualidade (QC)**. Não é zelo opcional do programador
caprichoso; é uma etapa obrigatória do processo, documentada e auditável. Este
capítulo mostra como o QC funciona, o vocabulário que você vai ouvir no primeiro
dia e o que faz uma tabela ser **reprovada**.

## Por que QC é obrigatório (e não negociável)

A lógica é a mesma que rege todo o resto do trabalho regulado: o FDA baseia
decisões de saúde pública nesses números, e precisa **confiar** neles. Confiança,
no mundo regulado, não é fé — é **evidência documentada** de que o resultado foi
verificado de forma independente. Um TLF sem trilha de QC é, para efeitos
regulatórios, um número sem procedência. Além disso, boas práticas (GCP) e a
integridade de dados exigida por normas como a **21 CFR Part 11** pressupõem que
os resultados sejam verificáveis e rastreáveis.

Traduzindo para o dia a dia: para cada tabela existe um **production programmer**
que a produz e um **QC programmer** (também chamado de *validation programmer*)
que a verifica. São **pessoas diferentes**. O QC não pode ser feito por quem
escreveu o código original — verificar o próprio trabalho não é verificação.

## Os métodos de QC

### Double programming (programação dupla independente)

O método mais rigoroso, reservado às tabelas mais críticas. Dois programadores
produzem a **mesma** tabela **de forma independente** — idealmente sem ver o
código um do outro, trabalhando a partir do mesmo shell e da mesma especificação.
Depois, comparam-se os **resultados** (os datasets que geram a tabela), não o
código. Se batem exatamente, há forte evidência de que ambos estão certos (é
improvável que dois programadores cometam o mesmo erro de forma independente).
Se divergem, investiga-se até achar a causa.

Uma variação poderosa, ligada ao capítulo anterior: usar **linguagens
diferentes** para produção e QC — a tabela sai em SAS e é validada em R, ou
vice-versa. A independência de linguagem reduz ainda mais a chance de um erro
comum.

### Revisão visual contra o shell e o SAP

Nem tudo exige reprogramação. Muita verificação é **revisão visual estruturada**:
conferir a tabela produzida contra o **shell** (títulos, ordem de linhas,
rótulos, notas de rodapé, casas decimais) e contra o **SAP** (a população está
correta? o método bate com o pré-especificado?). Também entram checagens de
sanidade: os percentuais de uma coluna somam o que deveriam? o N do cabeçalho
bate com a tabela de disposição? há células em branco onde deveria haver zero?

### Comparação automatizada de resultados

Quando se faz double programming, a comparação em si é automatizada:

- **Em SAS**, a ferramenta é **PROC COMPARE**, que confronta dois datasets
  observação a observação, variável a variável, e reporta cada diferença:

```sas
proc compare base=prod_table compare=qc_table
             out=diffs outnoequal listall;
run;
```

O resultado desejado é a mensagem de que **não há diferenças** (`NOTE: No
unequal values were found`). Qualquer diferença listada é um item a resolver.

- **Em R**, o equivalente são funções como `diffdf::diffdf()`, `waldo::compare()`
  ou `all.equal()`, que comparam dois data frames e apontam onde divergem:

```r
library(diffdf)
diffdf(base = prod_table, compare = qc_table)
# idealmente: "No issues were found!"
```

## Níveis de QC por criticidade

Não se aplica o mesmo rigor a tudo — seria caro e desnecessário. O nível de QC
é **proporcional à criticidade** do output, algo definido no plano de validação
do estudo:

| Criticidade | Exemplo | QC típico |
|---|---|---|
| Alta | Endpoint de eficácia primário; overview de AEs; disposição | **Double programming** independente |
| Média | Tabelas de segurança secundárias; demografia | Double programming ou revisão visual rigorosa |
| Baixa | Listagens exploratórias; outputs de apoio | Revisão visual estruturada |

A regra mental: **quanto mais perto o número está de sustentar uma decisão
regulatória, mais pesado o QC.** O endpoint primário sempre recebe o tratamento
mais rigoroso.

## Log limpo, versionamento e reprodutibilidade

QC não é só "o número está certo" — é também "o processo é confiável e
repetível". Três disciplinas sustentam isso:

- **Log limpo:** o programa deve rodar **sem warnings e sem errors** no log
  (SAS) ou no console (R). Um `WARNING` de valores inesperados, um `NOTE` de
  variável não inicializada, uma coerção silenciosa de tipo — tudo isso é
  investigado e resolvido, não ignorado. Um log sujo, mesmo que a tabela
  "pareça" certa, é motivo de reprovação.
- **Versionamento:** o código dos TLFs é controlado (Git ou o sistema da
  empresa), com histórico de mudanças. Cada versão da tabela rastreia até a
  versão do código e a versão do ADaM que a gerou.
- **Reprodutibilidade:** rodar de novo, na mesma entrada, tem de dar
  **exatamente** o mesmo resultado. É isso que permite ao revisor do FDA
  reexecutar seu código sobre seus dados e chegar ao seu número — o coração de
  por que R e SAS são aceitos.

## Como o QC se encaixa no cronograma

Um mal-entendido comum de quem chega de fora é imaginar o QC como um carimbo no
final, feito às pressas na véspera da entrega. Na prática bem organizada, é o
contrário: o QC caminha **em paralelo** com a produção. Enquanto o production
programmer escreve a tabela de demografia, o QC programmer já está montando a
sua versão independente a partir do mesmo shell. As duas se encontram, comparam
e resolvem discrepâncias antes de o output ser considerado pronto.

Isso muda o ritmo de trabalho de um jeito que vale internalizar desde o começo:
o *database lock* não é a largada da produção nem do QC — os dois já correram
contra dados de teste e dados parciais (*dry runs*) muito antes. O lock apenas
troca a entrada pelos dados reais e definitivos, e dispara a rodada final. Um
time que só começa o QC depois que tudo foi produzido está, por definição,
atrasado e sob risco de deixar erro passar por pressa.

> **Na prática:** a métrica silenciosa de um bom programador de QC não é
> "encontrar muitos erros" nem "nunca encontrar nenhum" — é a **rastreabilidade
> do que foi verificado**. Ao pegar uma discrepância entre produção e QC, o
> reflexo certo não é "conserto o meu código até bater com o dele", e sim
> **investigar qual dos dois está certo** contra o shell, o SAP e o ADaM. Às
> vezes é a produção que erra; às vezes é o QC. Descobrir e documentar qual é
> qual é o trabalho — não fazer os números baterem a qualquer custo.

## Entrega e transferência (handoff)

Quando produção e QC batem, a tabela é **assinada** como validada e liberada
para o CSR e a submissão. O *handoff* (a entrega) inclui, além do output: o
código de produção, o código de QC, os logs limpos, a documentação de QC (o
registro de que a verificação foi feita, por quem e com que resultado) e as
notas de qualquer discrepância resolvida. Esse pacote é o que torna a tabela
**auditável** — se, anos depois, alguém perguntar "como esse número foi gerado
e verificado?", a resposta está guardada.

> **Atenção — o que reprova um TLF no QC:**
> - **População ou denominador errado** — a causa nº 1. Usar ITT onde devia ser
>   Safety, ou o N do dataset de eventos como denominador.
> - **Contagem duplicada** — contar AEs em vez de pacientes únicos numa tabela
>   `n (%)`.
> - **Divergência no PROC COMPARE / diffdf** — qualquer diferença entre produção
>   e QC não explicada.
> - **Não bater com o shell/SAP** — método diferente do pré-especificado, ordem
>   de linhas errada, rótulos ou notas de rodapé fora do padrão.
> - **Log com warnings ou errors** — mesmo que o número final pareça correto.
> - **Falta de rastreabilidade** — não dá para reproduzir o número a partir do
>   ADaM, ou o código não está versionado/documentado.
> Repare que a maioria dos motivos não é "conta matemática errada" — é
> **processo**: população, rastreabilidade, log, aderência à especificação.

> **Dica de carreira:** muitos brasileiros entram na indústria americana
> justamente pela porta do **QC / validation programming**. É um cargo de alto
> valor, com barreira de entrada um pouco menor que a de produção sênior, e é a
> melhor escola possível: fazendo QC você lê o código dos outros, aprende os
> padrões da empresa por dentro e enxerga o estudo inteiro. Colocar "double
> programming", "PROC COMPARE" e "independent validation" no currículo sinaliza
> ao recrutador que você entende o processo regulado — não só a estatística.

## Resumo do capítulo

- QC é **obrigatório** em ambiente regulado: um TLF sem verificação
  independente documentada não tem procedência para o FDA. Produção e QC são
  **pessoas diferentes**.
- O método mais forte é o **double programming** — dois programadores geram a
  tabela de forma independente e comparam **resultados** (turbinado quando usam
  linguagens diferentes, SAS vs R).
- A comparação é automatizada com **PROC COMPARE** (SAS) ou `diffdf`/`waldo`
  (R); o alvo é **zero diferenças**. Complementa-se com **revisão visual**
  contra shell e SAP.
- O rigor é **proporcional à criticidade**: endpoint primário e overview de AEs
  recebem double programming; listagens exploratórias, revisão visual.
- **Log limpo** (sem warnings/errors), **versionamento** e **reprodutibilidade**
  fazem parte do QC — ligam-se à integridade de dados da **21 CFR Part 11**.
- O que mais reprova não é conta errada, e sim **processo**: população/
  denominador errado, contagem duplicada, divergência não explicada, desvio do
  shell/SAP e falta de rastreabilidade.
