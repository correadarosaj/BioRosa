# A estrutura de um SAP, seção a seção

Um SAP não é um texto livre — ele segue uma estrutura reconhecível que se repete,
com pequenas variações, de estudo para estudo e de empresa para empresa. Aprender
essa estrutura é como aprender a planta de uma casa: uma vez que você sabe onde
fica cada cômodo, consegue entrar em qualquer SAP e se orientar em minutos. Este
capítulo percorre as seções típicas e diz, para cada uma, **o que você precisa
escrever**.

## Existe um template de referência

Antes de percorrer as seções: você não precisa inventar a estrutura do zero. A
**PHUSE** (*Pharmaceutical Users Software Exchange*, uma associação da indústria
voltada a padrões e boas práticas em programação e estatística clínica) publica um
**template de SAP** de referência, desenvolvido de forma colaborativa pela
comunidade e disponível gratuitamente no site da organização. Muitas empresas
baseiam seus templates internos nele, com adaptações. Vale conhecê-lo como ponto
de partida e como "gabarito" mental da estrutura.

> **Verificar:** cite a versão vigente do PHUSE SAP template ao referenciá-lo num
> documento real; o material é atualizado periodicamente pelos grupos de trabalho
> da PHUSE.

A ordem exata das seções varia, mas o conteúdo abaixo aparece em praticamente
todo SAP. Vamos por partes.

## 1. Introdução e escopo

Abre o documento situando o leitor: qual é o estudo (número do protocolo, título,
fase), o produto investigado, e **o propósito do SAP**. Aqui você declara que o
SAP detalha a análise pré-especificada no protocolo, aponta a versão do protocolo
a que se refere e lista os documentos relacionados (protocolo, CRF, especificação
de datasets). Também é onde entra o **histórico de versões** e, muitas vezes, uma
lista de abreviaturas.

**O que escrever:** identificação do estudo, propósito e escopo do documento,
referência cruzada ao protocolo (com versão e data), lista de documentos
relacionados.

## 2. Objetivos e endpoints

Reafirma os **objetivos** do estudo — primário, secundários e exploratórios — e,
para cada objetivo, o **endpoint** correspondente. É aqui que a hierarquia de
importância começa a aparecer: qual pergunta o estudo existe para responder
(objetivo primário) e quais são as perguntas de apoio.

**O que escrever:** cada objetivo com seu(s) endpoint(s), definidos de forma
precisa — não "melhora da função pulmonar", mas "variação do FEV1 do *baseline* à
semana 12". Cada endpoint aqui será, mais adiante, ligado a um método de análise.

## 3. Desenho do estudo

Descreve a arquitetura do ensaio: randomizado ou não, cego ou aberto, paralelo ou
*cross-over*, número de braços, razão de alocação, estratos de randomização,
duração do tratamento e do *follow-up*, e o esquema de visitas. Um diagrama do
desenho é comum e muito útil.

**O que escrever:** tipo de desenho, braços e alocação, fatores de estratificação,
cronograma de visitas e de tratamento. Nada de novo em relação ao protocolo — é um
resumo fiel para dar contexto à análise.

## 4. Hipóteses estatísticas

Enuncia formalmente a **hipótese nula (H0)** e a **alternativa (H1)** do teste
primário, o nível de significância (tipicamente *alfa* bilateral de 0,05) e se o
teste é de superioridade, não-inferioridade ou equivalência. Em estudos de
não-inferioridade, aqui entra a **margem** pré-especificada — um ponto delicado e
sempre escrutinado pelo FDA.

**O que escrever:** H0 e H1 do endpoint primário, tipo e direção do teste, nível
de *alfa*, e (se aplicável) a margem de não-inferioridade com sua justificativa.

## 5. Determinação do tamanho amostral

Documenta o **cálculo de tamanho amostral** (*sample size*): o efeito assumido, a
variabilidade esperada, o poder (*power*) desejado (usualmente 80% ou 90%), o
*alfa*, a taxa de abandono prevista e o software/método usado. O objetivo é que
qualquer pessoa reproduza o número de pacientes a partir dos parâmetros
declarados.

**O que escrever:** todos os *inputs* do cálculo, o *N* resultante por braço e
total, e a fonte das suposições (estudos anteriores, literatura). Se o tamanho é
guiado por precisão em vez de poder, explique.

## 6. Populações de análise

Define **quais pacientes entram em quais análises**. As populações típicas são:

- **ITT (*Intention-To-Treat*):** todos os randomizados, analisados no grupo ao
  qual foram alocados, independentemente do que receberam de fato. Preserva o
  benefício da randomização.
- **mITT (*modified ITT*):** uma versão da ITT com uma exclusão pré-definida e
  mínima (por exemplo, quem nunca recebeu nenhuma dose ou não tem nenhuma medida
  pós-*baseline*). A definição precisa ser rígida e justificada.
- **Per-protocol (PP):** apenas os pacientes que seguiram o protocolo sem desvios
  maiores. Usada em análises de sensibilidade e como primária em alguns estudos de
  não-inferioridade.
- **Safety:** todos os que receberam ao menos uma dose, analisados pelo tratamento
  **efetivamente recebido** (não pelo alocado). É a base de toda análise de
  segurança.

**O que escrever:** a definição operacional exata de cada população e **qual é a
primária para eficácia** (em geral a ITT/mITT) e qual para segurança (a Safety).

## 7. Dados: fontes e padrões

Descreve de onde vêm os dados e como estão organizados. Na indústria regulada, isso
significa **CDISC**: os dados coletados são estruturados em **SDTM** (*Study Data
Tabulation Model*) e os dados prontos para análise, em **ADaM** (*Analysis Data
Model*). O SAP aponta os datasets ADaM que serão usados — tipicamente o **ADSL**
(*subject-level analysis dataset*, uma linha por paciente) e datasets *BDS* (*Basic
Data Structure*) por domínio, como um dataset de eficácia e o **ADAE** para eventos
adversos.

**O que escrever:** as fontes de dados, a menção ao pipeline CDISC (SDTM → ADaM) e
os principais datasets de análise. O detalhe fino das derivações vive na
especificação de ADaM, mas o SAP referencia e alinha com ela.

> **Glossário PT/EN:** *SDTM* = modelo de tabulação dos dados coletados; *ADaM* =
> modelo de dados prontos para análise, derivado do SDTM. *ADSL* = dataset com uma
> linha por sujeito, base de todas as populações e covariáveis.

## 8. Convenções gerais e derivações

Uma seção frequentemente subestimada, mas decisiva para a reprodutibilidade.
Define as **regras transversais** que valem para o estudo inteiro:

- **Baseline:** qual medida conta como valor de linha de base (a última antes da
  primeira dose? a média de duas?).
- **Visit windows** (janelas de visita): como alocar uma medida coletada em dia
  não exato à visita "nominal" mais próxima. Ex.: a visita da "semana 12" aceita
  medidas entre os dias X e Y.
- **Unscheduled visits** (visitas não programadas): se e como entram nas análises
  por visita.
- **Derivações** comuns: como calcular *change from baseline*, idade, IMC, duração
  de exposição, conversão de unidades, e regras de arredondamento e formatação de
  datas.

**O que escrever:** cada convenção de forma explícita e sem ambiguidade. É aqui
que "dois estatísticos chegam ao mesmo número" se ganha ou se perde.

## 9. Manejo de dados faltantes

Declara **como o estudo trata os dados faltantes** (*missing data*) — abandono de
pacientes, visitas perdidas, medidas ausentes. É uma seção que o FDA lê com lupa,
porque o tratamento do *missing* pode mudar a conclusão. Aqui você aponta o método
principal (hoje, tipicamente um modelo que usa todos os dados observados, como o
MMRM, em vez de preencher valores) e antecipa as análises de sensibilidade que
testam a robustez dessa escolha. O próximo capítulo aprofunda os métodos.

**O que escrever:** premissa sobre o mecanismo de *missing*, método primário de
manejo e as análises de sensibilidade previstas. Ligue tudo à estrutura de
*estimands* (ICH E9(R1)).

## 10. Métodos estatísticos por endpoint

O coração do SAP. Para **cada endpoint**, descreve o método de análise em detalhe
implementável. Para o **endpoint primário**, isso significa: o modelo (por
exemplo, MMRM), seus termos exatos (efeitos fixos, covariáveis, estrutura de
covariância), a população, o tratamento do *missing*, a estatística de interesse e
como o intervalo de confiança e o *p-valor* são obtidos. Para os **secundários**,
o mesmo nível de detalhe, proporcional à sua importância.

**O que escrever:** um bloco por endpoint, do primário aos exploratórios, cada um
com modelo, população, e forma de apresentação do resultado. Este é o texto que o
programador traduz em código.

## 11. Multiplicidade

Quando o estudo faz **mais de um teste confirmatório** (vários endpoints, várias
doses, vários momentos), o erro tipo I se acumula. Esta seção descreve a
**estratégia de controle de multiplicidade** (*multiplicity*): a hierarquia de
testes, o método de ajuste (procedimento sequencial, *gatekeeping*, Bonferroni,
Holm, Hochberg) e como o *alfa* é distribuído. O capítulo seguinte detalha esses
métodos.

**O que escrever:** a ordem e a lógica dos testes confirmatórios e o procedimento
formal que mantém o *alfa* global em 0,05.

## 12. Análises interinas

Se o estudo tem uma **análise interina** (*interim analysis*) — uma olhada
planejada nos dados antes do fim, para eficácia, futilidade ou segurança —, o SAP
descreve quando ela ocorre, qual método de *alpha spending* controla o erro
acumulado, e quem a conduz (tipicamente um comitê independente, o DSMB/IDMC, com
acesso aos dados cegos apenas para esse fim).

**O que escrever:** número e momento das interinas, função de gasto de *alfa*,
regras de parada, e a governança (papel do DSMB). Detalhes no próximo capítulo.

## 13. Análises de subgrupos

Descreve as análises por **subgrupos** pré-especificados (idade, sexo, região,
gravidade da doença etc.). Deixa claro que, salvo raras exceções, subgrupos são
**exploratórios** — não controlam multiplicidade e não sustentam alegações. O
propósito é consistência do efeito, não descoberta de "onde o remédio funciona".

**O que escrever:** a lista de subgrupos pré-especificados, o método (usualmente o
mesmo modelo com um termo de interação) e a ressalva explícita do caráter
exploratório.

## 14. Análises de segurança

Detalha como **eventos adversos** (AEs), exames laboratoriais, sinais vitais e ECG
serão resumidos — quase sempre de forma **descritiva**, por grupo de tratamento, na
população Safety. AEs são codificados por dicionário (MedDRA) e resumidos por
sistema-órgão e termo preferido; labs costumam usar tabelas de deslocamento
(*shift tables*) e critérios de anormalidade.

**O que escrever:** as convenções de resumo de AEs (TEAE, gravidade, relação,
*serious*), o plano para labs/sinais vitais/ECG, e o fato de que segurança é
descritiva, não testada formalmente.

## 15. Lista de TLFs planejados

Fecha o SAP com a **lista das saídas** — *Tables, Listings and Figures* (TLFs):
cada tabela, listagem e figura que será produzida, numerada, com título e a
população a que se refere. Muitas empresas mantêm essa lista num documento anexo
(o *TLF list* ou *mock-up shells*), mas o SAP a governa.

**O que escrever:** o inventário completo e numerado das TLFs, cada uma amarrada a
uma seção de método deste SAP.

> **Na prática:** o SAP é o **mapa dos TLFs**. Cada linha da lista de tabelas
> aponta para uma seção de método do SAP, e cada seção de método aponta para as
> tabelas que produz. O programador estatístico lê o SAP e a lista de shells lado a
> lado: o SAP diz *o que calcular e com qual regra*, o shell diz *com qual layout
> apresentar*. Quando os dois estão bem amarrados, a programação flui; quando há
> uma tabela sem método correspondente (ou um método sem tabela), é sinal de que o
> SAP ainda não está pronto.

## Resumo do capítulo

- O SAP segue uma **estrutura reconhecível**; a **PHUSE** publica um template de
  referência que muitas empresas adotam como base.
- As seções de contexto — introdução, objetivos/endpoints, desenho, hipóteses e
  tamanho amostral — reafirmam e detalham o protocolo.
- As **populações de análise** (ITT, mITT, per-protocol, Safety) definem quem entra
  em cada análise; ITT/mITT costuma ser primária para eficácia, Safety para
  segurança.
- Os dados vivem no pipeline **CDISC** (SDTM → ADaM); o SAP referencia os datasets
  ADaM (ADSL, BDS, ADAE) e alinha com a especificação de ADaM.
- As **convenções gerais** (baseline, *visit windows*, derivações) e o **manejo de
  missing** são onde a reprodutibilidade se ganha ou se perde.
- Os **métodos por endpoint**, a **multiplicidade**, as **interinas**, os
  **subgrupos** e a **segurança** formam o núcleo técnico; a **lista de TLFs**
  fecha o documento.
- O SAP é o **mapa dos TLFs**: cada tabela aponta para um método, e cada método
  aponta para suas tabelas.
