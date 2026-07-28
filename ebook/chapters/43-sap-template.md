# Um SAP-modelo comentado

Teoria só gruda quando você vê o documento real. Este capítulo apresenta um SAP
**abreviado** para um ensaio de Fase III fictício e o percorre seção a seção: um
bloco de **texto-modelo** (do jeito que apareceria num SAP de verdade, ainda que
condensado) seguido de **comentários** que explicam *por que* cada escolha foi
feita. O objetivo não é você copiar este texto, e sim aprender a **ler as escolhas
por trás das palavras** — porque é isso que separa quem preenche um template de
quem entende o que está preenchendo.

O estudo fictício, que chamaremos de **RUBRA-301**:

- **Medicamento X** (via oral, uma vez ao dia) versus **placebo**;
- Fase III, randomizado 1:1, duplo-cego, grupos paralelos;
- **Endpoint primário contínuo**: variação do escore de sintomas (uma escala
  validada de 0 a 100, maior = pior) do *baseline* à **semana 12**;
- Análise primária por **MMRM**.

> **Atenção:** tudo abaixo é ilustrativo e propositalmente simplificado. Um SAP
> real de Fase III tem dezenas de páginas, definições operacionais muito mais
> minuciosas e uma lista de TLFs extensa. Use este capítulo como esqueleto
> comentado, não como documento pronto para submeter.

## 1. Sinopse do estudo

> **Texto-modelo.** *O estudo RUBRA-301 é um ensaio de Fase III, multicêntrico,
> randomizado, duplo-cego, controlado por placebo, de grupos paralelos, para
> avaliar a eficácia e a segurança do Medicamento X 50 mg uma vez ao dia versus
> placebo em adultos com [doença Y] de gravidade moderada a grave. Aproximadamente
> 400 pacientes serão randomizados 1:1, estratificados por região geográfica
> (América do Norte vs. resto do mundo) e gravidade basal (moderada vs. grave). O
> período de tratamento duplo-cego é de 12 semanas, com avaliações nas semanas 2,
> 4, 8 e 12. Este SAP detalha as análises pré-especificadas no protocolo versão
> 3.0 (data DD-MMM-AAAA) e deve estar finalizado e assinado antes do database lock
> e do unblinding.*

**Comentários.** A sinopse condensa desenho, população, intervenção, tamanho e
duração num parágrafo — é o "elevator pitch" do estudo. Três detalhes carregam
peso: (a) os **fatores de estratificação** (região e gravidade) reaparecerão como
**covariáveis** no modelo primário — não é coincidência, é boa prática incluir os
estratos de randomização no modelo; (b) a menção explícita à **versão do
protocolo** amarra o SAP a um protocolo específico; (c) a frase sobre **assinar
antes do unblinding** não é decorativa — é a declaração da pré-especificação que
dá valor probatório a tudo que vem depois.

## 2. Objetivos e endpoints

> **Texto-modelo.**
>
> | Tipo | Objetivo | Endpoint |
> |---|---|---|
> | Primário | Avaliar o efeito de X vs. placebo sobre os sintomas | Variação do escore de sintomas do baseline à semana 12 |
> | Secundário-chave | Avaliar o efeito sobre a resposta clínica | Proporção de respondedores (redução ≥ 30% no escore) na semana 12 |
> | Secundário-chave | Avaliar o efeito sobre a qualidade de vida | Variação do escore de QoL do baseline à semana 12 |
> | Exploratório | Explorar o curso temporal do efeito | Variação do escore de sintomas nas semanas 2, 4 e 8 |
> | Segurança | Caracterizar a segurança e a tolerabilidade | AEs, exames laboratoriais, sinais vitais |

**Comentários.** Repare na **hierarquia**: um primário, dois secundários-chave
(*key secondary*, que entrarão no controle formal de multiplicidade) e o resto
exploratório ou de segurança. Só os *key secondary* "gastam alfa"; os exploratórios
não. Cada endpoint é definido de forma **operacional** — "redução ≥ 30%" e "na
semana 12", não "melhora dos sintomas". Essa precisão é o que permite ao
programador implementar sem adivinhar.

## 3. Populações de análise

> **Texto-modelo.**
> - ***Full Analysis Set* (FAS):** todos os pacientes randomizados que receberam ao
>   menos uma dose do tratamento em estudo e têm ao menos uma avaliação de eficácia
>   pós-baseline. Os pacientes são analisados de acordo com o **tratamento
>   randomizado**. O FAS é a população primária de eficácia.
> - **Per-Protocol (PP):** subconjunto do FAS sem desvios maiores de protocolo
>   (definidos na seção X). Usada em análise de sensibilidade do endpoint primário.
> - **Safety:** todos os pacientes que receberam ao menos uma dose, analisados de
>   acordo com o **tratamento efetivamente recebido**. É a população de todas as
>   análises de segurança.

**Comentários.** Este SAP usa **FAS** (uma forma de mITT: ITT com uma exclusão
mínima e pré-definida — sem dose ou sem nenhuma medida pós-baseline). Note os dois
princípios cruciais: eficácia analisa pelo tratamento **randomizado** (preserva a
randomização), enquanto segurança analisa pelo tratamento **recebido** (o que
importa para efeitos adversos é a exposição real). A **per-protocol** aparece só
como **sensibilidade** — coerente com um estudo de **superioridade**, onde a
FAS/ITT é a barra conservadora e crível. (Num estudo de não-inferioridade, a PP
teria papel muito mais central, como vimos no capítulo de métodos.)

## 4. Endpoint primário: o modelo MMRM

> **Texto-modelo.** *A variação do escore de sintomas em relação ao baseline será
> analisada por um modelo misto para medidas repetidas (MMRM) na população FAS. O
> modelo incluirá, como efeitos fixos, o **grupo de tratamento**, a **visita**
> (semanas 2, 4, 8, 12, como fator categórico), a **interação tratamento × visita**,
> a **região** e a **gravidade basal**; e o **escore basal** como covariável
> contínua, junto com a **interação baseline × visita**. Uma estrutura de
> covariância **não estruturada** (unstructured) modelará a correlação entre as
> visitas do mesmo paciente; se o modelo não convergir, adotar-se-á, em ordem
> pré-definida, uma estrutura mais parcimoniosa (Toeplitz heterogênea, depois
> AR(1) heterogênea). Os graus de liberdade serão calculados pelo método de
> **Kenward-Roger**. O tratamento será estimado pela **diferença de médias
> ajustadas (LS means)** entre X e placebo na **semana 12**, com intervalo de
> confiança de 95% e p-valor bilateral. Todos os dados observados serão usados; sob
> a premissa de dados faltantes **MAR**, o MMRM não requer imputação explícita.*

**Comentários.** Este é o parágrafo mais importante do SAP inteiro, e vale
dissecá-lo:

- **Por que MMRM?** Porque é longitudinal (medidas repetidas nas semanas 2–12) e
  haverá abandono. O MMRM usa **todas** as visitas observadas de cada paciente sem
  imputar, e é válido sob **MAR** — exatamente o padrão discutido no capítulo
  anterior. É por isso que a última frase pode dizer "não requer imputação
  explícita": o modelo extrai a informação parcial de quem saiu.
- **Por que tratamento × visita, e a estimativa na semana 12?** A interação
  permite que o efeito varie por visita (ele cresce ao longo do tempo); a
  **estimativa de interesse é a LS mean da diferença na semana 12**, o momento do
  endpoint primário. Ao modelar todas as visitas conjuntamente, ganha-se precisão
  na estimativa da semana 12.
- **Por que região e gravidade no modelo?** São os **estratos de randomização** —
  incluí-los como covariáveis é prática recomendada e alinha a análise ao desenho.
- **Por que baseline como covariável (e não como diferença simples)?** Ajustar
  pelo valor basal aumenta o poder e corrige desequilíbrios residuais; a interação
  baseline × visita permite que esse ajuste varie no tempo.
- **Por que declarar a estrutura de covariância E um plano de fallback?** Porque a
  *unstructured* é a mais flexível, mas pode não convergir. Pré-especificar a
  **ordem de estruturas alternativas** evita que, no dia da análise, alguém
  "escolha" a estrutura olhando o resultado — o pecado capital. A decisão já está
  tomada e datada.
- **Por que Kenward-Roger?** É o método de graus de liberdade recomendado para
  MMRM com covariância não estruturada, especialmente em amostras não enormes.

> **Na prática:** um programador estatístico consegue traduzir esse parágrafo quase
> linha a linha em código (`PROC MIXED` no SAS com `REPEATED ... / TYPE=UN` e
> `DDFM=KR`, ou o equivalente em R). É essa a prova de que o método está bem
> especificado: ele é **implementável sem adivinhação**.

## 5. Endpoints secundários-chave

> **Texto-modelo.** *A proporção de respondedores na semana 12 será comparada entre
> os grupos por um modelo de **regressão logística** ajustado por tratamento,
> região e gravidade basal, reportando-se a razão de chances (odds ratio) com IC de
> 95%. Pacientes sem avaliação na semana 12 serão considerados **não respondedores**
> (non-responder imputation). A variação do escore de QoL na semana 12 será
> analisada por um MMRM com a mesma estrutura do modelo primário. Ambos os testes
> secundários-chave só serão interpretados como confirmatórios dentro da hierarquia
> de testes da Seção 6.*

**Comentários.** Endpoints diferentes pedem métodos diferentes: o de resposta é
**binário** (logística), o de QoL é **contínuo longitudinal** (MMRM, reaproveitando
a estrutura primária). A **imputação de não respondedor** para o binário é uma
regra conservadora e comum — quem saiu conta como fracasso. E a frase final é
decisiva: os secundários só "valem" como confirmatórios **dentro da hierarquia** —
sem ela, seus p-valores seriam meramente descritivos.

## 6. Multiplicidade: a hierarquia de testes

> **Texto-modelo.** *Para controlar o family-wise error rate a um alfa bilateral de
> 0,05, os endpoints confirmatórios serão testados em **sequência fixa
> hierárquica**, na ordem: (1) endpoint primário (sintomas, semana 12); (2)
> resposta clínica na semana 12; (3) QoL na semana 12. Cada teste na sequência será
> conduzido ao nível pleno de 0,05, e só será interpretado como estatisticamente
> significativo se **todos os testes anteriores** na hierarquia tiverem atingido
> significância (p < 0,05). Se um teste falhar, os testes subsequentes serão
> considerados **exploratórios** e não controlados para multiplicidade.*

**Comentários.** Este é o mecanismo de multiplicidade em ação. A **sequência fixa**
(*fixed-sequence testing*) é elegante e poderosa: como cada teste só ocorre se o
anterior passou, o alfa nunca é "gasto duas vezes", e **cada teste usa 0,05 cheio**
— nada de dividir por Bonferroni. O custo é a rigidez: se o primário falha, **nada
depois dele pode ser declarado significativo**, por melhor que seja o p-valor. Por
isso a ordem reflete uma **hierarquia clínica** — o mais importante e mais provável
de dar certo vem primeiro. A última frase é a honestidade que o FDA exige: depois
de uma falha, os demais viram exploratórios, e isso precisa estar dito **antes** de
qualquer um ver os dados.

## 7. Dados faltantes e análises de sensibilidade

> **Texto-modelo.** *A análise primária por MMRM é válida sob a premissa de dados
> faltantes MAR. A robustez dessa premissa será avaliada pelas seguintes análises
> de sensibilidade do endpoint primário, todas pré-especificadas:*
> - *(a) **imputação múltipla sob cenário MNAR** do tipo jump-to-reference, em que
>   os valores faltantes do braço X são imputados assumindo o perfil do placebo
>   após a descontinuação;*
> - *(b) uma **análise de tipping point**, identificando o quão desfavorável a
>   premissa sobre os dados faltantes do braço X teria de ser para anular a
>   significância do efeito;*
> - *(c) a repetição do modelo primário na população **per-protocol**.*
>
> *O estimand primário adota a estratégia de **treatment policy** para o uso de
> medicação de resgate (o dado é usado independentemente do resgate) e uma
> estratégia **hipotética** para a descontinuação do tratamento.*

**Comentários.** Aqui o SAP conecta tudo o que vimos: a análise primária assume
**MAR**, e as sensibilidades **estressam desvios rumo a MNAR**. O
*jump-to-reference* pergunta "e se quem abandonou X passou a se comportar como
placebo?" — um cenário pessimista plausível. O *tipping point* vai além: em vez de
um único cenário, mapeia **quão ruim** o missing teria de ser para apagar o efeito;
se a resposta é "absurdamente ruim", a conclusão é robusta. E a menção explícita ao
**estimand** (treatment policy para resgate, hipotética para descontinuação) mostra
o *framework* do E9(R1) organizando as escolhas: o tratamento do missing **decorre**
das estratégias para eventos intercorrentes, não o contrário.

> **Verificar:** a escolha entre estratégias de estimand (treatment policy vs.
> hipotética vs. composite) deve refletir a pergunta clínica e regulatória do
> programa específico; num SAP real, cada estratégia é justificada em prosa e
> alinhada com o feedback da agência.

## 8. Análises de segurança

> **Texto-modelo.** *Todas as análises de segurança serão descritivas, por grupo de
> tratamento, na população Safety. Os **eventos adversos** serão codificados pelo
> dicionário **MedDRA** e resumidos como **TEAEs** (treatment-emergent adverse
> events — os que começam ou pioram após a primeira dose) por sistema-órgão (SOC) e
> termo preferido (PT), com contagens e percentuais de pacientes. Resumos
> adicionais cobrirão TEAEs por gravidade, por relação com o tratamento, TEAEs
> sérios (SAEs) e TEAEs que levaram à descontinuação. Exames **laboratoriais**,
> **sinais vitais** e **ECG** serão resumidos por estatísticas descritivas e por
> **shift tables** (deslocamento da categoria de normalidade do baseline para cada
> visita). Nenhum teste de hipótese formal será conduzido para segurança.*

**Comentários.** O contraste com a eficácia é o ponto pedagógico: segurança é
**descritiva**, não testada. Por quê? Porque um estudo é dimensionado para detectar
o efeito de eficácia, não para "provar" ausência de danos raros; aplicar testes
formais a centenas de tipos de AE criaria uma multiplicidade incontrolável e falsos
positivos aos montes. Então resume-se e **inspeciona-se** — contagens, percentuais,
*shift tables* — deixando o julgamento clínico interpretar padrões. **TEAE**,
**SOC/PT** (a hierarquia do MedDRA) e **SAE** são vocabulário que você usará todos
os dias.

## 9. Análise interina

> **Texto-modelo.** *Uma única análise interina de eficácia e futilidade será
> conduzida quando aproximadamente 50% dos pacientes tiverem completado a semana 12.
> O controle do erro tipo I usará uma abordagem de **alpha spending** grupo-
> sequencial com fronteira do tipo **O'Brien-Fleming** (implementada via Lan-DeMets)
> para o limite de eficácia, preservando a maior parte do alfa para a análise final.
> A análise interina será conduzida por um estatístico independente (unblinded) e
> revisada pelo **DSMB** independente, que recomendará continuar, modificar ou
> interromper o estudo. A equipe do sponsor permanecerá cega. Os detalhes da
> condução estão no charter do DSMB.*

**Comentários.** Cada elemento tem uma razão: **O'Brien-Fleming** porque queremos
uma parada precoce **difícil** (só com evidência esmagadora), guardando quase todo
o alfa para o fim — o padrão da indústria. **Lan-DeMets** porque o número exato de
pacientes na interina raramente cai no ponto planejado, e a função de gasto
acomoda isso. E toda a governança de **cegueira** aparece: um estatístico
*unblinded* **fora** da equipe do estudo prepara os números, o **DSMB** independente
decide, e a equipe do sponsor **nunca** vê os dados desblindados. É assim que se
olha os dados no meio do caminho sem contaminar a análise final.

## Do modelo comentado ao template para preencher

Este capítulo mostrou as **escolhas** por trás de cada seção. O passo natural é ter
um **template em branco**, com todas as seções e os *placeholders* prontos para
você preencher no seu próprio estudo. Esse template completo — estruturado e pronto
para adaptar — está em **`templates/sap-template.md`**, um documento
complementar deste livro. Use este capítulo como o "professor comentando ao lado" e
o template como a folha em branco: leia aqui *por que* cada seção existe, preencha
lá *o que* o seu estudo precisa.

> **Dica de carreira:** um exercício de portfólio poderoso é pegar um ensaio
> publicado (o protocolo e o artigo de resultados costumam estar disponíveis) e
> **escrever você mesmo o SAP** que teria gerado aquelas análises. Você aprende
> mais escrevendo um SAP do que lendo dez. E ter um SAP completo, seu, para mostrar
> numa entrevista é evidência concreta de que você entende o documento central da
> profissão — exatamente o tipo de prova que abre portas para quem vem de fora.

## Resumo do capítulo

- Um SAP-modelo mostra não só *o que* escrever, mas **por que** cada escolha é
  feita; ler as razões por trás do texto é o que distingue quem entende o
  documento.
- A **sinopse** amarra desenho, estratos e a declaração de pré-especificação;
  objetivos e endpoints já estabelecem a **hierarquia** entre primário,
  secundários-chave e exploratórios.
- As **populações** separam eficácia (tratamento randomizado, FAS/mITT) de
  segurança (tratamento recebido, Safety); a per-protocol entra como sensibilidade
  num estudo de superioridade.
- O **endpoint primário por MMRM** especifica termos, covariáveis (incluindo os
  estratos e o baseline), estrutura de covariância com plano de fallback, LS means
  na semana 12 e a validade sob MAR — tudo **implementável sem adivinhação**.
- A **multiplicidade** por sequência fixa hierárquica testa cada endpoint a 0,05
  pleno, mas para na primeira falha; o **missing** é estressado por sensibilidades
  MNAR (jump-to-reference, tipping point) ancoradas no **estimand**.
- A **segurança** é descritiva (TEAEs por MedDRA SOC/PT, SAEs, shift tables), não
  testada; a **interina** usa alpha spending O'Brien-Fleming sob governança do
  **DSMB** independente, com a equipe do sponsor cega.
- O template em branco para preencher está em **`templates/sap-template.md`**;
  escrever um SAP do zero para um estudo publicado é um exercício de portfólio de
  alto valor.
