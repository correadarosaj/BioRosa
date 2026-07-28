# Statistical Analysis Plan (SAP) — Template

*Esqueleto reutilizável de Statistical Analysis Plan, alinhado ao ICH E9 /
E9(R1) e à estrutura típica de SAP da indústria. Substitua todos os
`<placeholders>` e siga as instruções em itálico entre colchetes sob cada
cabeçalho. Não apague seções que não se apliquem: escreva "Not applicable" com
uma breve justificativa. Idioma do SAP real geralmente é inglês; mantido aqui em
PT-BR nas instruções para facilitar o preenchimento.*

---

## 1. Title page e aprovações

**Study title:** `<título completo do estudo>`
**Protocol number:** `<ABC-123>`   **Protocol version/date:** `<v_.__ / dd-mmm-aaaa>`
**Compound / product:** `<nome do produto>`
**Phase:** `<I / II / III / IV>`
**Sponsor:** `<nome do sponsor>`
**SAP version:** `<1.0>`   **SAP date:** `<dd-mmm-aaaa>`
**Author:** `<nome, cargo>`

*[Tabela de assinaturas: quem prepara, revisa e aprova o SAP — tipicamente o
Lead Statistician, um revisor sênior e o representante clínico. Registre nome,
cargo, assinatura e data. O SAP deve ser aprovado e congelado antes do database
lock, idealmente antes do unblinding.]*

| Função | Nome | Assinatura | Data |
|---|---|---|---|
| Prepared by (Statistician) | `< >` | | |
| Reviewed by | `< >` | | |
| Approved by (Sponsor) | `< >` | | |

## 2. Histórico de versões

*[Uma linha por versão. Descreva o que mudou e por quê. A versão 1.0 é o
congelamento inicial.]*

| Versão | Data | Autor | Descrição da mudança |
|---|---|---|---|
| 1.0 | `< >` | `< >` | Versão inicial |

## 3. Índice

*[Gerado automaticamente na formatação final. Deixe um marcador aqui.]*

## 4. Abreviações e definições

*[Liste todas as siglas usadas no SAP, em ordem alfabética, com a forma
completa. Inclua ao menos: AE, ADaM, CI, CSR, DBL, ITT, MedDRA, PP, SAE, SAP,
SD, SDTM, SE, TEAE. Veja o Apêndice A do livro como base.]*

| Sigla | Significado |
|---|---|
| `< >` | `< >` |

## 5. Introdução

### 5.1 Background e racional
*[1–2 parágrafos: doença-alvo, produto em investigação, por que o estudo é
conduzido. Resuma sem copiar o protocolo inteiro.]*

### 5.2 Propósito do SAP
*[Declare que este documento especifica em detalhe todas as análises
estatísticas planejadas para o estudo `<ABC-123>`, servindo de base para a
programação e o relatório clínico (CSR), e que foi finalizado antes do
unblinding/DBL.]*

## 6. Objetivos e endpoints do estudo

*[Copie objetivos e endpoints EXATAMENTE como no protocolo. Qualquer divergência
deve ser justificada na Seção 17.]*

| Tipo | Objetivo | Endpoint | Timepoint de análise |
|---|---|---|---|
| Primary | `< >` | `< >` | `< >` |
| Secondary | `< >` | `< >` | `< >` |
| Exploratory | `< >` | `< >` | `< >` |
| Safety | `< >` | AEs, labs, sinais vitais, ECG | `< >` |

## 7. Desenho do estudo

*[Descreva: tipo (paralelo, crossover, etc.), controle (placebo/ativo),
cegamento, randomização e fatores de estratificação, número de braços e alocação
(ex.: 1:1), fases/períodos, número planejado de centros e países, e um diagrama
esquemático do fluxo do participante (screening → randomização → tratamento →
follow-up).]*

`<descrição do desenho>`

## 8. Estimand(s) e hipóteses estatísticas

### 8.1 Estimand(s) — ICH E9(R1)
*[Para cada endpoint confirmatório, defina os cinco atributos do estimand:]*

- **Treatment condition:** `<tratamento experimental vs comparador>`
- **Population:** `<população-alvo>`
- **Variable (endpoint):** `<variável>`
- **Intercurrent events e estratégias:** `<liste cada evento intercorrente
  (descontinuação, medicação de resgate, morte…) e a estratégia adotada —
  treatment policy, hypothetical, composite, while-on-treatment, principal
  stratum>`
- **Population-level summary:** `<ex.: diferença de médias, risk ratio, hazard
  ratio>`

### 8.2 Hipóteses estatísticas
*[Enuncie H0 e H1 do endpoint primário, o tipo de teste (superioridade,
não-inferioridade, equivalência), a margem se aplicável, e o nível de
significância (two-sided alpha = `<0.05>`).]*

- **H0:** `< >`   **H1:** `< >`
- Alpha: `<0.05, two-sided>`

## 9. Determinação do tamanho amostral

*[Reproduza o cálculo do protocolo: efeito assumido, variabilidade/taxa de
evento, poder (`<80%/90%>`), alpha, taxa de dropout assumida, N por braço e N
total. Cite o método/software e as premissas. Deve bater com o protocolo.]*

`<premissas e resultado do cálculo>`

## 10. Populações de análise

*[Defina cada população SEM ambiguidade e diga a que análises se aplica.]*

| População | Definição | Uso |
|---|---|---|
| Randomized / ITT | Todos os sujeitos randomizados, analisados no braço alocado. | Eficácia primária |
| mITT (se aplicável) | `<critério, ex.: ≥1 dose e ≥1 avaliação pós-baseline>` | `< >` |
| Per-Protocol (PP) | Sujeitos sem desvios majoritários pré-especificados. | Sensibilidade da eficácia |
| Safety | Todos que receberam ≥1 dose, analisados pelo tratamento **recebido**. | Todas as análises de segurança |

*[Descreva também como serão listados e classificados os desvios de protocolo
majoritários que excluem da PP.]*

## 11. Considerações gerais de análise

### 11.1 Definição de baseline
*[Qual medida/data é o baseline para cada tipo de variável. Regra para múltiplas
medidas pré-dose.]*

### 11.2 Visit windows / analysis windows
*[Regras que mapeiam a data real de uma avaliação para o timepoint nominal de
análise. Apresente uma tabela dia-alvo / intervalo por visita. Regra de
desempate quando duas medidas caem na mesma janela.]*

| Visita nominal | Dia-alvo | Intervalo (dias) |
|---|---|---|
| `<Week 4>` | `<28>` | `<15–42>` |

### 11.3 Derivações e convenções gerais
*[Regras de: mudança em relação ao baseline (change / percent change), duração
de exposição, definição de TEAE (janela treatment-emergent), unidades, datas
parciais/imputação de datas, e convenções de arredondamento e apresentação (nº de
decimais para média, DP, percentuais, p-valores).]*

## 12. Manejo de dados faltantes

*[Descreva a abordagem primária (ex.: MMRM usa dados observados sem imputação
explícita) e como missing será tratado por tipo de variável. Ligue as escolhas
ao estimand (Seção 8). Evite LOCF como método primário; se usado em sensibilidade,
justifique. Especifique quaisquer análises de sensibilidade a dados faltantes
(ex.: tipping point, controlled imputation / multiple imputation).]*

## 13. Métodos estatísticos

### 13.1 Dados demográficos e de baseline
*[Estatística descritiva por braço e total: contínuas (n, mean, SD, median, min,
max), categóricas (n, %). Sem testes de hipótese entre braços, em geral.]*

### 13.2 Disposição dos sujeitos
*[Contagens e percentuais de randomizados, tratados, completers, descontinuados
por motivo, por braço.]*

### 13.3 Exposição e compliance
*[Duração de exposição, dose cumulativa/intensidade de dose, compliance, por
braço.]*

### 13.4 Análise do endpoint primário
*[Método completo: modelo estatístico (ex.: MMRM, ANCOVA, modelo de Cox,
regressão logística), variável resposta, covariáveis e fatores fixos, fatores de
estratificação da randomização, estrutura de covariância se aplicável, população
de análise, e a estimativa reportada (point estimate, IC de `<95%>`, p-valor).
Descreva verificações de premissas quando pertinente.]*

### 13.5 Análises dos endpoints secundários
*[Método por endpoint. Indique se são confirmatórios (dentro da estratégia de
multiplicidade da Seção 14) ou exploratórios.]*

### 13.6 Análises de segurança
*[TEAEs: overview (qualquer AE, related, serious, leading to discontinuation,
death), por SOC e PT (MedDRA), por severidade e por relação; SAEs; deaths.
Laboratório: estatística descritiva, mudança em relação ao baseline, shift
tables e critérios de valores clinicamente notáveis. Sinais vitais e ECG:
análogos. Toda análise de segurança é tipicamente descritiva, na população
Safety.]*

## 14. Multiplicidade e controle do erro tipo I

*[Descreva a estratégia global: ordem hierárquica dos endpoints, procedimento de
ajuste (ex.: fixed-sequence, Hochberg, gatekeeping), alpha alocado a cada família
e como o alpha é "gasto" se houver análises interinas. Deixe claro quais
resultados são confirmatórios.]*

## 15. Análises interinas e monitoramento de dados

*[Número e timing das análises interinas; objetivo (futilidade e/ou eficácia);
função de gasto de alpha e fronteiras (ex.: O'Brien-Fleming); papel e composição
do DSMB/IDMC; regras de parada; como o cegamento é mantido. Se não houver
interina, escreva "No interim analyses are planned" e cite o monitoramento de
segurança em curso, se houver.]*

## 16. Análises de subgrupos e sensibilidade

*[Liste subgrupos pré-especificados (ex.: idade, sexo, região, fatores de
estratificação) e diga se são confirmatórios ou exploratórios; método
(tipicamente forest plot com estimativas por subgrupo e teste de interação).
Liste as análises de sensibilidade do endpoint primário (ex.: PP, estimand
alternativo, métodos de dados faltantes) e o que cada uma pretende avaliar.]*

## 17. Mudanças em relação ao protocolo

*[Liste e justifique qualquer diferença entre este SAP e a seção estatística do
protocolo. Se não houver, escreva "None".]*

## 18. Referências

*[Cite as diretrizes e métodos usados. Exemplos comuns: ICH E9; ICH E9(R1); ICH
E3; guidances relevantes do FDA; artigos metodológicos citados. Use um formato de
citação consistente.]*

## 19. Anexos

### 19.1 Lista de TLFs (Tables, Listings, Figures)
*[Tabela numerada de todas as saídas planejadas, com número, título, população e
o shell correspondente. A numeração e os títulos devem casar com os shells (ver
`tlf-shells.md`) e com o CSR.]*

| Nº | Título | Tipo | População |
|---|---|---|---|
| Table 14.1.1 | Subject Disposition | Table | All randomized |
| Table 14.1.2 | Demographics and Baseline Characteristics | Table | ITT |
| Table 14.3.1 | Extent of Exposure | Table | Safety |
| Table 14.3.2 | Overview of Treatment-Emergent Adverse Events | Table | Safety |
| Table 14.3.3 | TEAEs by System Organ Class and Preferred Term | Table | Safety |
| Table 14.3.x | Laboratory Shift Table | Table | Safety |
| `<…>` | `<…>` | `<…>` | `<…>` |

### 19.2 Especificações de dataset (opcional)
*[Referencie as ADaM specs / define, se anexadas.]*

### 19.3 Mock shells (opcional)
*[Anexe ou referencie os shells de TLF.]*
