# Tamanho amostral e poder

"Quantos pacientes precisamos?" é uma das primeiras perguntas que um sponsor faz
ao estatístico — e uma das que mais dinheiro e tempo decidem. Recrutar demais
custa milhões e expõe pacientes desnecessariamente; recrutar de menos condena o
estudo ao fracasso mesmo que o tratamento funcione. O cálculo de **tamanho
amostral** (*sample size*) é onde a estatística encontra o orçamento. Este
capítulo dá a intuição, as fórmulas certas e o código que você vai realmente
usar.

## Os cinco ingredientes

Todo cálculo de tamanho amostral equilibra cinco quantidades. Fixe quatro e a
quinta (geralmente o n) fica determinada.

- **Erro tipo I (α, alfa)**: probabilidade de concluir que há efeito quando não
  há (falso positivo). Convenção: 0,05 bilateral (*two-sided*). É o nível de
  significância.
- **Erro tipo II (β, beta)**: probabilidade de **não** detectar um efeito que
  existe (falso negativo).
- **Poder (*power*) = 1 − β**: probabilidade de detectar o efeito quando ele
  existe. Convenção: 80% ou 90%. É o oposto do erro tipo II.
- **Tamanho de efeito** (*effect size*): a magnitude da diferença que você quer
  ser capaz de detectar — o **menor efeito clinicamente relevante**. Quanto
  menor o efeito a detectar, maior o n.
- **Variabilidade** (*variability*): o desvio-padrão (σ) do desfecho, para
  endpoints contínuos. Quanto mais ruído, maior o n.

A intuição a internalizar: **n cresce quando você quer mais poder, menos α,
detectar efeitos menores, ou lidar com mais variabilidade**.

> **Glossário PT/EN:** *Type I error / α* = erro tipo I, falso positivo /
> *Type II error / β* = erro tipo II, falso negativo / *Power* = poder, 1−β /
> *Effect size* = tamanho de efeito / *Two-sided* = bilateral.

## Comparação de duas médias (t-test)

Para comparar a média de um desfecho contínuo entre dois grupos de tamanho igual,
o número de sujeitos **por grupo** é aproximadamente:

$$ n = \frac{2\,(z_{1-\alpha/2} + z_{1-\beta})^2\,\sigma^2}{\Delta^2} $$

onde Δ é a diferença de médias a detectar, σ é o desvio-padrão comum, e os *z*
são os quantis da normal padrão. Para α = 0,05 bilateral, z ≈ 1,96; para poder de
90%, z ≈ 1,282.

Repare na estrutura: o n depende de Δ e σ **apenas pela razão Δ/σ** — o *effect
size* padronizado (o d de Cohen). Dobrar o desvio-padrão quadruplica o n; reduzir
pela metade a diferença que você quer detectar quadruplica o n. É uma relação de
**quadrado**, e por isso o cálculo é tão sensível às premissas.

Exemplo em R. Queremos detectar uma diferença de 5 mmHg na pressão, assumindo
σ = 12 mmHg, poder 90%, α 0,05 bilateral:

```r
power.t.test(delta = 5, sd = 12, sig.level = 0.05,
             power = 0.90, type = "two.sample",
             alternative = "two.sided")
# n = 121.6 por grupo -> arredonde para cima: 122 por grupo, 244 no total
```

Ou com o pacote `pwr`, que trabalha com o effect size padronizado d = Δ/σ:

```r
library(pwr)
pwr.t.test(d = 5/12, sig.level = 0.05, power = 0.90,
           type = "two.sample", alternative = "two.sided")
# n = 121.5 por grupo
```

Equivalente em SAS: **PROC POWER**.

```sas
proc power;
   twosamplemeans test=diff
      meandiff = 5
      stddev   = 12
      power    = 0.90
      alpha    = 0.05
      sides    = 2
      npergroup = .;   /* deixe em branco o que quer resolver */
run;
```

## Comparação de duas proporções

Para um desfecho binário (ex.: taxa de resposta), o n **por grupo** é
aproximadamente:

$$ n = \frac{(z_{1-\alpha/2} + z_{1-\beta})^2\,[\,p_1(1-p_1) + p_2(1-p_2)\,]}{(p_1 - p_2)^2} $$

onde p1 e p2 são as proporções esperadas em cada grupo. Aqui a "variabilidade"
já está embutida nas próprias proporções (p(1−p) é a variância de uma
Bernoulli), então você não fornece σ separadamente — só as duas taxas.

Exemplo em R: taxa de resposta esperada de 40% no placebo e 55% no tratamento,
poder 90%, α 0,05 bilateral:

```r
power.prop.test(p1 = 0.40, p2 = 0.55, sig.level = 0.05,
                power = 0.90, alternative = "two.sided")
# n = 231.8 por grupo -> 232 por grupo
```

Com `pwr`, usando o effect size h (transformação arco-seno de Cohen):

```r
library(pwr)
h <- ES.h(p1 = 0.55, p2 = 0.40)          # tamanho de efeito para proporções
pwr.2p.test(h = h, sig.level = 0.05, power = 0.90,
            alternative = "two.sided")
# n por grupo (próximo do resultado acima)
```

Equivalente em SAS: `proc power; twosamplefreq test=pchi ...`.

## Visão geral: tempo-até-evento

Para desfechos de sobrevivência, a lógica muda: o que dá poder **não é o número
de pacientes, mas o número de eventos** (mortes, recidivas). Um estudo com muitos
pacientes mas poucos eventos tem pouco poder. A fórmula de **Schoenfeld** para o
número total de eventos necessário, com alocação 1:1, é:

$$ d = \frac{4\,(z_{1-\alpha/2} + z_{1-\beta})^2}{(\ln \text{HR})^2} $$

onde HR é o *hazard ratio* que se quer detectar. O número de **pacientes** vem
depois: você divide o número de eventos necessário pela probabilidade de um
paciente ter o evento durante o estudo (que depende do risco basal, da duração do
acompanhamento e do recrutamento). Por isso, estudos de sobrevivência com eventos
raros exigem amostras grandes **e** seguimento longo.

> **Verificar:** existem variações da fórmula de eventos (Schoenfeld, Freedman) e
> ajustes por alocação desigual e recrutamento escalonado. Para um cálculo de
> submissão, use um método validado (ex.: `nSurv`/`gsDesign` em R, ou
> `proc power ... twosamplesurvival` em SAS) e documente as premissas.

## Visão geral: não-inferioridade

Em um estudo de não-inferioridade, o cálculo se parece com o de superioridade,
com duas diferenças importantes:

- O teste costuma ser **unilateral** (*one-sided*), então usa-se z_{1−α} (ex.:
  1,645 para α 0,025 unilateral) no lugar de z_{1−α/2}.
- No lugar da diferença a detectar entra a **distância entre a diferença
  verdadeira assumida e a margem δ**. Se você assume que os tratamentos são
  realmente iguais (diferença verdadeira = 0), o "efeito a detectar" vira a
  própria margem δ, e o n depende de δ² no denominador.

Consequência prática: **margens pequenas exigem amostras grandes**. Provar que o
novo tratamento não é pior que o padrão por uma margem estreita pode custar mais
pacientes que provar superioridade — algo que surpreende quem está começando.

## Premissas: de onde vêm e como escolhê-las

Um cálculo de tamanho amostral é tão bom quanto suas premissas. Elas vêm de:

- **Estudos anteriores** (fase II do próprio programa, literatura publicada) para
  σ, taxas de evento e efeito plausível.
- **Relevância clínica**: o efeito a detectar deve ser o **menor efeito
  clinicamente importante** — negociado com os clínicos, não escolhido para dar
  um n bonito.
- **Registros / dados históricos** para taxas de evento no braço controle.

Como o n depende do **quadrado** do effect size padronizado, ele é extremamente
sensível. Vale sempre uma **análise de sensibilidade**: recalcule o n para uma
faixa de valores de σ e de efeito, e apresente uma tabela. Assim o sponsor
enxerga o risco.

```r
# Sensibilidade do n ao desvio-padrao assumido (mesma diferenca de 5 mmHg)
sapply(c(10, 12, 14, 16), function(s)
  ceiling(power.t.test(delta = 5, sd = s, power = 0.90)$n))
# 10 -> 85 | 12 -> 122 | 14 -> 166 | 16 -> 216 (por grupo)
```

Repare como uma premissa "razoável" de σ que erra de 12 para 16 quase **dobra**
o estudo. É por isso que a premissa de variabilidade é a que mais tira o sono.

## Ajuste para dropout

O n calculado é o número de pacientes **avaliáveis** que você precisa. Mas
pacientes abandonam o estudo (*dropout*). Se você espera perder uma fração *r*,
precisa **recrutar mais** para terminar com o n necessário:

$$ n_{\text{recrutar}} = \frac{n}{1 - r} $$

Exemplo: se precisa de 122 por grupo e espera 15% de dropout:

```r
n_avaliavel <- 122
dropout     <- 0.15
n_recrutar  <- ceiling(n_avaliavel / (1 - dropout))
n_recrutar   # 144 por grupo
```

> **Atenção:** dividir por (1 − r) é o certo; **não** basta somar 15% (que seria
> multiplicar por 1,15 e sub-recrutar). Com 15% de dropout você precisa de ~17,6%
> a mais de recrutamento, não 15%.

> **Na prática:** as premissas (σ, taxa de evento, efeito) vêm de dados
> anteriores e da opinião clínica — e frequentemente são **otimistas**. Um erro
> muito comum é o cliente "encomendar" um n pequeno assumindo um efeito grande
> demais ou uma variabilidade pequena demais; se a realidade for menos generosa,
> o estudo fica **subdimensionado** (*underpowered*) e falha em detectar um
> efeito que existe — desperdiçando anos e milhões, e expondo pacientes sem
> gerar resposta. Seu papel como estatístico é **defender premissas honestas**,
> apresentar a sensibilidade do n e resistir à pressão por números convenientes.
> Um estudo subdimensionado é um fracasso caro disfarçado de economia.

## Resumo do capítulo

- Cinco ingredientes governam o tamanho amostral: **α, β/poder, tamanho de
  efeito e variabilidade**. Fixe quatro e o n fica determinado.
- Para **duas médias**, n por grupo ≈ 2(z_{1−α/2}+z_{1−β})²σ²/Δ²; em R,
  `power.t.test` ou `pwr::pwr.t.test`; em SAS, `PROC POWER`.
- Para **duas proporções**, a variância já está em p(1−p); em R,
  `power.prop.test` ou `pwr::pwr.2p.test`.
- Em **tempo-até-evento**, o que dá poder é o **número de eventos** (fórmula de
  Schoenfeld), não o de pacientes; em **não-inferioridade**, o efeito a detectar
  vira a **margem δ**, e margens estreitas exigem amostras grandes.
- O n depende do **quadrado** do effect size padronizado — é muito sensível às
  premissas; faça sempre **análise de sensibilidade**.
- Ajuste para **dropout** dividindo por (1 − r), não somando a fração.
- Premissas costumam ser otimistas; o risco de **subdimensionar** é alto e caro.
  Defenda premissas honestas.
