# Apêndice A — Glossário PT/EN

Este glossário reúne as siglas e os termos que você vai encontrar todos os dias
trabalhando em pesquisa clínica regulada. Para cada verbete você tem a **forma
em inglês** (o vocabulário real do mercado — é assim que se fala e se escreve nas
empresas), a **sigla expandida** quando houver, e uma **definição curta em
português**. Sempre que fizer sentido, indicamos o capítulo onde o assunto é
tratado em profundidade.

Use este apêndice como consulta rápida. Quando bater dúvida no meio de uma
reunião ou de uma vaga que menciona "experience with ADaM and Define-XML", volte
aqui.

> **Dica de carreira:** decore as siglas em inglês, não a tradução. Numa
> entrevista ou num currículo, escrever *Statistical Analysis Plan* e *Study Data
> Tabulation Model* nas grafias corretas sinaliza que você conhece o terreno.

## Verbetes (ordem alfabética)

| Termo / Sigla | Forma completa (EN) | Definição (PT) |
|---|---|---|
| **ADAE** | AE Analysis Dataset | Dataset ADaM de análise dos **eventos adversos**, derivado do domínio AE do SDTM, em estrutura de ocorrência (OCCDS). Alimenta as tabelas de segurança. Ver Cap. 18 e 21. |
| **ADaM** | Analysis Data Model | Padrão CDISC para os datasets **de análise** — os dados já derivados e prontos para gerar as TLFs. Deriva do SDTM e prioriza rastreabilidade. Ver Cap. 18. |
| **ADLB** | Laboratory Analysis Dataset | Dataset ADaM de análise dos **resultados laboratoriais**, derivado do domínio LB, em estrutura BDS. Ver Cap. 18. |
| **ADRG** | Analysis Data Reviewer's Guide | Documento que acompanha os datasets ADaM na submissão, explicando decisões de derivação e desvios ao revisor do FDA. Ver Cap. 19. |
| **ADSL** | Subject-Level Analysis Dataset | Dataset ADaM com **uma linha por sujeito**. É a espinha dorsal do ADaM: carrega populações de análise, braços de tratamento, datas-chave e covariáveis. Ver Cap. 18. |
| **ADVS** | Vital Signs Analysis Dataset | Dataset ADaM de análise dos **sinais vitais**, derivado do domínio VS, em estrutura BDS. Ver Cap. 18. |
| **AE** | Adverse Event | Evento adverso: qualquer ocorrência médica desfavorável em um participante, tenha ou não relação causal com o tratamento. Ver Cap. 21. |
| **ALCOA+** | Attributable, Legible, Contemporaneous, Original, Accurate (+ Complete, Consistent, Enduring, Available) | Conjunto de princípios de **integridade de dados** exigido em ambiente regulado. Todo dado deve ser atribuível, legível, contemporâneo, original e exato (mais os complementos). Ver Cap. 7. |
| **ANCOVA** | Analysis of Covariance | Análise de covariância: modelo linear que compara médias de tratamento ajustando por covariáveis (tipicamente o baseline). Comum em endpoints contínuos. Ver Cap. 14. |
| **ANVISA** | Agência Nacional de Vigilância Sanitária | Agência reguladora brasileira, equivalente funcional do FDA no Brasil. |
| **ASA** | American Statistical Association | Principal associação de estatísticos dos EUA; publica periódicos, diretrizes e mantém redes de emprego e formação na área. Ver Cap. 26. |
| **AVAL** | Analysis Value | Variável numérica de análise na estrutura BDS do ADaM (o valor que entra na estatística). Sua contraparte textual é `AVALC`. |
| **Baseline** | Baseline | Valor de referência de um parâmetro **antes** do início do tratamento, usado como comparação para medir mudança. A definição de baseline é sempre especificada no SAP. |
| **BDS** | Basic Data Structure | Estrutura ADaM de **uma linha por sujeito, parâmetro e ponto no tempo** — usada para dados longitudinais (labs, sinais vitais, eficácia). Ver Cap. 18. |
| **BLA** | Biologics License Application | Pedido de licenciamento de um produto **biológico** (vacinas, anticorpos, terapias celulares) ao FDA. Análogo do NDA, mas para biológicos. Ver Cap. 5. |
| **Blinding** | Blinding (masking) | Cegamento: manter participantes e/ou equipe sem saber qual tratamento cada sujeito recebe, para reduzir viés. *Single-blind*, *double-blind*. Ver Cap. 9. |
| **BLS** | Bureau of Labor Statistics | Órgão do governo americano que publica dados oficiais de emprego e salários — útil para pesquisar remuneração de bioestatísticos e programadores. Ver Cap. 2. |
| **CBER** | Center for Biologics Evaluation and Research | Centro do FDA responsável por **produtos biológicos** (vacinas, terapias gênicas e celulares). |
| **CDASH** | Clinical Data Acquisition Standards Harmonization | Padrão CDISC para a **coleta** de dados — como os CRFs devem ser estruturados na origem, alimentando o SDTM. Ver Cap. 16. |
| **CDER** | Center for Drug Evaluation and Research | Centro do FDA responsável por **medicamentos** (small molecules e muitos biológicos terapêuticos). |
| **CDISC** | Clinical Data Interchange Standards Consortium | Organização que define os padrões de dados clínicos (CDASH, SDTM, ADaM, Define-XML, Controlled Terminology) exigidos pelo FDA. Ver Cap. 16. |
| **CDM** | Clinical Data Management | Gestão de dados clínicos: função responsável por coletar, limpar e validar os dados do estudo até o database lock. Ver Cap. 12. |
| **CFR (21 CFR Part 11)** | Code of Federal Regulations, Title 21, Part 11 | Regulamento do FDA sobre **registros e assinaturas eletrônicas** — base para validação de sistemas e trilha de auditoria. Ver Cap. 7. |
| **CI / IC** | Confidence Interval / Intervalo de Confiança | Faixa de valores plausíveis para um parâmetro estimado (ex.: IC 95%). Acompanha quase toda estimativa nas TLFs. Ver Cap. 11. |
| **CM** | Concomitant Medications | Domínio SDTM das medicações concomitantes usadas pelo participante durante o estudo. |
| **CRF** | Case Report Form | Formulário (hoje quase sempre eletrônico, *eCRF*) onde os dados de cada participante são registrados no centro de pesquisa. Ver Cap. 8. |
| **CRO** | Contract Research Organization | Empresa que executa pesquisa clínica sob contrato para os sponsors. Frequentemente a porta de entrada mais acessível para quem vem de fora. Ver Cap. 1. |
| **cSDRG** | clinical Study Data Reviewer's Guide | Documento que acompanha os datasets **SDTM** na submissão, orientando o revisor. Contraparte do ADRG (que é para ADaM). Ver Cap. 19. |
| **CSR** | Clinical Study Report | Relatório final do estudo (formato ICH E3) que integra métodos, resultados e TLFs. As tabelas de eficácia/segurança vivem tradicionalmente na Seção 14. |
| **CSV** | Computerized System Validation | Validação de sistemas computadorizados: comprovar que um software regulado opera como esperado. **Não** confundir com o arquivo `.csv`. Ligada ao 21 CFR Part 11. Ver Cap. 7. |
| **CT** | Controlled Terminology | Vocabulário controlado do CDISC — listas de valores permitidos (ex.: `SEX`, `RACE`, unidades) que padronizam os datasets. Ver Cap. 16. |
| **CTD** | Common Technical Document | Formato ICH M4 que organiza um dossiê de submissão em cinco módulos. Sua versão eletrônica é o eCTD. Ver Cap. 5. |
| **DBL** | Database Lock | Congelamento do banco de dados: momento em que os dados são declarados finais e limpos, ninguém mais os altera, e a análise "para valer" começa. Ver Cap. 12. |
| **Define-XML** | Define-XML (Data Definition) | Arquivo XML que **descreve os metadados** dos datasets (SDTM e ADaM) submetidos — o "mapa" que diz ao revisor o que é cada variável. Ver Cap. 19. |
| **DM** | Demographics | Domínio SDTM da demografia — uma linha por sujeito com idade, sexo, raça, braço de tratamento. Domínio central do SDTM. Ver Cap. 17. |
| **DMC** | Data Monitoring Committee | Comitê de monitoramento de dados que acompanha a segurança dos participantes durante o estudo. Termo genérico próximo de DSMB/IDMC. Ver Cap. 14. |
| **Double programming** | Double (independent) programming | Técnica de QC em que **dois programadores** produzem a mesma tabela de forma independente e comparam os resultados. Ver Cap. 23. |
| **DSMB** | Data Safety Monitoring Board | Comitê independente que monitora a segurança dos participantes durante o estudo e recomenda continuar, ajustar ou parar. Sinônimo prático de IDMC. Ver Cap. 14. |
| **EB-2** | Employment-Based, Second Preference | Categoria de green card (residência permanente) dos EUA para profissionais com grau avançado ou habilidade excepcional. Base do NIW. Ver Cap. 3. |
| **ECG** | Electrocardiogram | Eletrocardiograma: registro da atividade elétrica do coração, coletado no domínio SDTM **EG** e analisado nas tabelas de segurança. Ver Cap. 17. |
| **eCTD** | electronic Common Technical Document | Formato eletrônico do CTD, exigido pelo FDA para submissões regulatórias. Ver Cap. 16. |
| **EDC** | Electronic Data Capture | Sistema eletrônico onde os dados dos participantes são inseridos no centro de pesquisa (via eCRF). Ver Cap. 8. |
| **EMA** | European Medicines Agency | Agência reguladora de medicamentos da União Europeia. Equivalente europeu do FDA. |
| **Endpoint** | Endpoint (outcome) | Desfecho: a medida usada para avaliar o efeito do tratamento (ex.: mortalidade, redução de pressão, resposta tumoral). Pode ser primário, secundário ou exploratório. Ver Cap. 10. |
| **Estimand** | Estimand | Definição precisa do "o que exatamente estamos estimando" (população, variável, manejo de eventos intercorrentes, sumário populacional). Framework do ICH E9(R1). Ver Cap. 10. |
| **EX** | Exposure | Domínio SDTM da exposição ao tratamento — quanto de droga cada sujeito recebeu, quando e por quanto tempo. Ver Cap. 17. |
| **FAS** | Full Analysis Set | Conjunto completo de análise: população derivada segundo o princípio do intention-to-treat, com exclusões mínimas e justificadas. Definida no SAP. Ver Cap. 14. |
| **FDA** | Food and Drug Administration | Agência federal americana que regula alimentos e medicamentos. Cliente final invisível de todo o seu trabalho. Ver Cap. 1 e 5. |
| **FWER** | Familywise Error Rate | Taxa de erro por família: probabilidade de cometer ao menos um erro tipo I entre múltiplos testes. Controlá-la exige ajuste de multiplicidade. Ver Cap. 14. |
| **GCP** | Good Clinical Practice | Boas Práticas Clínicas (ICH E6): o padrão ético e de qualidade para conduzir ensaios clínicos. Ver Cap. 6 e 7. |
| **H-1B** | H-1B specialty occupation visa | Visto de trabalho americano para ocupações especializadas — a via mais comum (mas competitiva, com loteria) para profissionais estrangeiros. Ver Cap. 3. |
| **HR** | Hazard Ratio | Razão de riscos (de falha) entre dois grupos em análises de sobrevida; HR < 1 favorece o tratamento. Vem tipicamente do modelo de Cox. Ver Cap. 14. |
| **IB** | Investigator's Brochure | Documento com todas as informações pré-clínicas e clínicas conhecidas sobre o produto, entregue aos investigadores. |
| **ICF** | Informed Consent Form | Termo de consentimento livre e esclarecido assinado pelo participante antes de entrar no estudo. |
| **ICH** | International Council for Harmonisation (of Technical Requirements for Pharmaceuticals for Human Use) | Organismo internacional que harmoniza as exigências técnicas entre reguladores. Fonte das diretrizes E6, E8, E9, E9(R1), E3, M4. Ver Cap. 6. |
| **IDMC** | Independent Data Monitoring Committee | Nome ICH para o comitê independente de monitoramento de dados. Na prática, sinônimo de DSMB. Ver Cap. 14. |
| **IMC** | Índice de Massa Corporal (BMI) | *Body Mass Index* — peso dividido pela altura ao quadrado (kg/m²), usado como covariável ou critério de elegibilidade. Ver Cap. 17. |
| **IND** | Investigational New Drug | Pedido ao FDA para iniciar testes de um novo composto **em humanos**. Marca a transição do pré-clínico para a Fase I. Ver Cap. 5. |
| **Interim analysis** | Interim analysis | Análise interina: análise planejada dos dados **antes** do fim do estudo, geralmente para decisões de segurança ou eficácia (com ajuste de multiplicidade). Ver Cap. 14. |
| **Intercurrent event** | Intercurrent event | Evento intercorrente: algo que ocorre após o início do tratamento e afeta a interpretação do endpoint (ex.: descontinuação, uso de medicação de resgate, morte). Central no framework de estimands. Ver Cap. 10. |
| **IRB** | Institutional Review Board | Comitê de ética que aprova e supervisiona o estudo para proteger os participantes. Equivalente ao CEP/CONEP no Brasil. |
| **ISS / ISE** | Integrated Summary of Safety / Integrated Summary of Efficacy | Análises **integradas** de segurança e eficácia que combinam vários estudos de um programa, exigidas em submissões de NDA/BLA. |
| **ITT** | Intention-to-Treat | População de análise que inclui **todos os randomizados**, no grupo ao qual foram alocados, independentemente do que ocorreu depois. Princípio conservador padrão. Ver Cap. 14. |
| **Kaplan-Meier (KM)** | Kaplan-Meier estimator | Método não paramétrico para estimar curvas de sobrevida (time-to-event) na presença de censura. |
| **LB** | Laboratory | Domínio SDTM dos resultados laboratoriais (hematologia, bioquímica, urinálise). Um dos domínios mais volumosos. Ver Cap. 17. |
| **LOCF** | Last Observation Carried Forward | Método (hoje desencorajado como análise primária) de imputar dados faltantes repetindo a última observação disponível. Ver Cap. 14. |
| **LS Means / LSMEANS** | Least Squares Means | Médias ajustadas por modelo (mínimos quadrados): as médias de tratamento estimadas por ANCOVA/MMRM depois de controlar covariáveis. Ver Cap. 14. |
| **MAR** | Missing At Random | Mecanismo de dados faltantes em que a probabilidade de faltar depende de valores **observados**, não do valor faltante em si. Ver Cap. 14. |
| **MCAR** | Missing Completely At Random | Mecanismo de dados faltantes em que a falta é **independente** de qualquer valor, observado ou não — o caso mais benigno (e raro). Ver Cap. 14. |
| **MedDRA** | Medical Dictionary for Regulatory Activities | Dicionário padronizado para codificar eventos adversos e condições médicas, organizado em hierarquia (SOC → PT, entre outros níveis). Ver Cap. 21. |
| **mITT** | modified Intention-to-Treat | Variante da ITT com critérios de exclusão pré-especificados (ex.: exigir ao menos uma dose ou uma avaliação pós-baseline). Definida no SAP. Ver Cap. 14. |
| **ML** | Maximum Likelihood | Máxima verossimilhança: método de estimação que escolhe os parâmetros que tornam os dados observados mais prováveis. Base do MMRM (aqui **não** significa *machine learning*). Ver Cap. 14. |
| **MMRM** | Mixed Model for Repeated Measures | Modelo misto para medidas repetidas — método de referência para dados longitudinais contínuos, que usa todos os dados observados sem imputação explícita. Ver Cap. 14. |
| **MNAR** | Missing Not At Random | Mecanismo de dados faltantes em que a falta depende do **próprio valor não observado** — o caso mais problemático, que exige análises de sensibilidade. Ver Cap. 14. |
| **NDA** | New Drug Application | Pedido de aprovação de comercialização de um **medicamento** ao FDA. Contraparte do BLA (para biológicos). Ver Cap. 5. |
| **NI** | Non-Inferiority | Não inferioridade: desenho/hipótese que busca demonstrar que um tratamento não é pior que o comparador por mais do que uma margem pré-especificada. Ver Cap. 9. |
| **NIH** | National Institutes of Health | Principal agência de pesquisa biomédica dos EUA; financia muitos estudos acadêmicos via *grants*. Ver Cap. 1. |
| **NIW** | National Interest Waiver | Dispensa de interesse nacional dentro da categoria EB-2: permite pedir o green card sem oferta de emprego nem certificação trabalhista. Ver Cap. 3. |
| **OCCDS** | Occurrence Data Structure | Estrutura ADaM para dados de **ocorrência** (eventos adversos, medicações concomitantes) — uma linha por evento registrado. Ver Cap. 18. |
| **OPT** | Optional Practical Training | Autorização de trabalho temporária para estudantes internacionais nos EUA após a formatura (via F-1). Uma porta de entrada comum. Ver Cap. 3. |
| **PARAM / PARAMCD** | Parameter / Parameter Code | Variáveis ADaM (BDS) que identificam o parâmetro analisado: `PARAM` é o texto descritivo, `PARAMCD` é o código curto. Ver Cap. 18. |
| **PD** | Pharmacodynamics | Farmacodinâmica: o que a droga faz ao organismo (efeitos e mecanismo de ação). Contraparte da PK. Ver Cap. 10. |
| **Per-protocol (PP)** | Per-Protocol population | População de análise que inclui apenas os sujeitos que **seguiram o protocolo** sem desvios majoritários. Usada como sensibilidade da ITT. Ver Cap. 14. |
| **PHUSE** | Pharmaceutical Users Software Exchange | Comunidade global de profissionais de dados clínicos; publica padrões de qualidade (ex.: whitepapers e o repositório de *TLF standards*). Ótima fonte gratuita. Ver Cap. 26. |
| **Pinnacle 21** | Pinnacle 21 (Community / Enterprise) | Ferramenta de validação de conformidade CDISC (SDTM/ADaM/Define-XML) usada de fato pela indústria e pelo FDA. A versão Community é gratuita. Ver Cap. 19. |
| **PK** | Pharmacokinetics | Farmacocinética: o que o organismo faz com a droga (absorção, distribuição, metabolismo e excreção). Ver Cap. 10. |
| **Placebo** | Placebo | Tratamento inerte usado como comparador para isolar o efeito real da intervenção. |
| **PMDA** | Pharmaceuticals and Medical Devices Agency | Agência reguladora do Japão. |
| **Power** | Statistical power | Poder estatístico: probabilidade de detectar um efeito real quando ele existe (1 − β). Guia o cálculo de tamanho amostral. Ver Cap. 11. |
| **PRO** | Patient-Reported Outcome | Desfecho relatado pelo paciente: dado de saúde vindo diretamente do participante (sintomas, qualidade de vida), sem interpretação de terceiros. Coletado tipicamente no domínio QS. Ver Cap. 10. |
| **Protocol** | Protocol | Documento mestre que define objetivos, desenho, população, tratamentos e análises de um estudo. Tudo o mais deriva dele. Ver Cap. 8. |
| **PT** | Preferred Term | Nível do MedDRA que nomeia de forma padronizada uma condição médica específica (ex.: "Nausea"). Agrupa-se em SOC. Ver Cap. 21. |
| **QC** | Quality Control | Controle de qualidade: o conjunto de verificações (incluindo double programming) que garante que TLFs e datasets estão corretos. Ver Cap. 23. |
| **Randomization** | Randomization | Randomização: alocação aleatória dos participantes aos tratamentos, base para comparações não enviesadas. Pode ser estratificada ou em blocos. Ver Cap. 9. |
| **SAE** | Serious Adverse Event | Evento adverso **grave**: resulta em morte, risco de vida, hospitalização, incapacidade ou anomalia congênita. Tem reporte acelerado. Ver Cap. 21. |
| **SAP** | Statistical Analysis Plan | Plano de análise estatística: documento que especifica **em detalhe** todas as análises, congelado antes de ver os dados. Peça central do trabalho. Ver Cap. 12–15. |
| **SAS** | Statistical Analysis System | Software líder de análise estatística e de programação de TLFs; **padrão histórico** nas submissões ao FDA. Ver Cap. 4. |
| **SD / DP** | Standard Deviation / Desvio-Padrão | Medida de dispersão dos dados em torno da média; reportada ao lado da média nas tabelas descritivas. Ver Cap. 11. |
| **SDTM** | Study Data Tabulation Model | Padrão CDISC para os dados **tabulados de origem**, organizados em domínios (DM, AE, LB, VS, EX, CM…). Base a partir da qual o ADaM é derivado. Ver Cap. 17. |
| **SDTMIG** | SDTM Implementation Guide | Guia de implementação do SDTM: documento CDISC que detalha como construir cada domínio e variável na prática. Ver Cap. 17. |
| **Shell** | Table shell (mock-up) | Modelo vazio de uma tabela/listagem/figura — com título, colunas e footnotes definidos, mas sem números. Feito antes da programação. Ver Cap. 20 e o template `tlf-shells.md`. |
| **SOC** | System Organ Class | Nível mais alto do MedDRA, que agrupa PTs por sistema do corpo (ex.: "Gastrointestinal disorders"). Ver Cap. 21. |
| **Sponsor** | Sponsor | Empresa (pharma/biotech) dona do estudo e responsável legal perante o FDA. Ver Cap. 1. |
| **SQL** | Structured Query Language | Linguagem padrão para consultar e manipular bancos de dados relacionais; útil para extrair e cruzar dados clínicos. Ver Cap. 4. |
| **STEM** | Science, Technology, Engineering, Mathematics | Áreas de ciências exatas cujos diplomas dão direito à **extensão do OPT** nos EUA (trabalho prolongado após a formatura). Ver Cap. 3. |
| **SUSAR** | Suspected Unexpected Serious Adverse Reaction | Reação adversa grave, inesperada e suspeita de relação com a droga — sujeita a reporte expedito ao regulador. |
| **TEAE** | Treatment-Emergent Adverse Event | Evento adverso que **surge ou piora após** o início do tratamento. É o recorte padrão para as tabelas de segurança. Ver Cap. 21. |
| **TLF** | Tables, Listings and Figures | Tabelas, listagens e figuras que resumem os resultados do estudo — o produto final visível do trabalho estatístico. Ver Cap. 20–23. |
| **TN** | TN visa (USMCA) | Visto de trabalho para profissionais do Canadá e do México sob o acordo USMCA — **não se aplica a brasileiros**. Ver Cap. 3. |
| **Traceability** | Traceability | Rastreabilidade: a capacidade de seguir cada valor analisado de volta até o dado de origem (SDTM/CRF). Princípio central do ADaM. Ver Cap. 18. |
| **Unblinding** | Unblinding | Quebra do cegamento — planejada (no database lock) ou não planejada (emergência médica). Ver Cap. 9 e 12. |
| **USUBJID** | Unique Subject Identifier | Identificador único de cada participante ao longo de **todos** os datasets de um estudo/programa. Chave que conecta os domínios. Ver Cap. 17. |
| **Visit window** | Visit window (analysis window) | Janela de visita: regra que mapeia uma medida realizada numa data real para um ponto de tempo nominal de análise (ex.: "Semana 12 = dias 78–98"). Definida no SAP. Ver Cap. 14. |
| **VS** | Vital Signs | Domínio SDTM dos sinais vitais (pressão, frequência cardíaca, temperatura, peso). Ver Cap. 17. |
| **WHODrug** | WHO Drug Dictionary | Dicionário da OMS para codificar medicações (usado tipicamente no domínio CM). Contraparte do MedDRA, mas para drogas. Ver Cap. 21. |
| **XML** | eXtensible Markup Language | Linguagem de marcação estruturada; formato de base do Define-XML e de outros metadados de submissão. Ver Cap. 19. |
| **XPT / SAS Transport** | SAS Transport File (.xpt) | Formato de arquivo de transporte (SAS v5) aceito pelo FDA para submeter os datasets SDTM e ADaM. Ver Cap. 19. |

> **Na prática:** você não precisa memorizar tudo de uma vez. Na primeira semana
> de qualquer projeto, os 20 termos que mais aparecem são: SAP, SDTM, ADaM,
> ADSL, TLF, shell, DBL, AE/SAE/TEAE, ITT, MedDRA, define, USUBJID, PARAMCD,
> baseline, QC, GCP, ICH E9, endpoint, estimand e sponsor. Domine esses e o resto
> vem com o contexto.

## Variáveis e domínios CDISC de referência rápida

Uma consulta rápida para quando bater dúvida sobre um código de domínio SDTM ou
o nome de uma variável num dataset. Não é exaustivo — é o que mais aparece no
dia a dia.

**Domínios SDTM**

| Nome | Significado |
|---|---|
| **DM** | *Demographics* — demografia; uma linha por sujeito (idade, sexo, raça, braço de tratamento). |
| **AE** | *Adverse Events* — eventos adversos registrados durante o estudo. |
| **CM** | *Concomitant Medications* — medicações concomitantes usadas pelo participante. |
| **EX** | *Exposure* — exposição ao tratamento do estudo (dose, datas de administração). |
| **LB** | *Laboratory* — resultados de exames laboratoriais (hematologia, bioquímica, urinálise). |
| **VS** | *Vital Signs* — sinais vitais (pressão, frequência cardíaca, temperatura, peso). |
| **MH** | *Medical History* — histórico médico prévio do participante. |
| **EG** | *ECG Test Results* — resultados de eletrocardiograma. |
| **DS** | *Disposition* — situação/desfecho do participante no estudo (conclusão, descontinuação e motivo). |
| **QS** | *Questionnaires* — respostas de questionários e escalas (inclui muitos PROs). |
| **TA** | *Trial Arms* — braços e sequência de tratamento planejados do estudo (trial design). |
| **TS** | *Trial Summary* — parâmetros-resumo do estudo (metadados do desenho, um registro por parâmetro). |

**Variáveis comuns (SDTM e ADaM)**

| Nome | Significado |
|---|---|
| **STUDYID** | (SDTM) Identificador do estudo. |
| **DOMAIN** | (SDTM) Código de duas letras do domínio (ex.: DM, AE, VS). |
| **USUBJID** | (SDTM) Identificador único do sujeito em todos os datasets do estudo/programa. |
| **SUBJID** | (SDTM) Identificador do sujeito dentro do centro/estudo (não único no programa). |
| **--SEQ** | (SDTM) Número sequencial que torna cada registro único dentro do domínio (ex.: `AESEQ`, `VSSEQ`). |
| **VSTESTCD** | (SDTM) Código curto do teste de sinal vital (ex.: `SYSBP`, `DIABP`). |
| **VSORRES** | (SDTM) Resultado do sinal vital no valor e unidade originais. |
| **VSSTRESN** | (SDTM) Resultado do sinal vital padronizado, em formato numérico. |
| **LBORRES** | (SDTM) Resultado laboratorial no valor e unidade originais. |
| **AEDECOD** | (SDTM) Termo preferido (PT) do MedDRA para o evento adverso. |
| **AEBODSYS** | (SDTM) System Organ Class (SOC) do MedDRA para o evento adverso. |
| **AESER** | (SDTM) Flag de evento adverso grave — SAE (Y/N). |
| **PARAM** | (ADaM) Descrição textual do parâmetro analisado. |
| **PARAMCD** | (ADaM) Código curto do parâmetro (chave de programação). |
| **AVAL** | (ADaM) Valor de análise numérico. |
| **AVALC** | (ADaM) Valor de análise em texto (contraparte de `AVAL`). |
| **AVISIT** | (ADaM) Visita de análise (ponto de tempo nominal). |
| **BASE** | (ADaM) Valor de baseline do parâmetro. |
| **CHG** | (ADaM) Mudança em relação ao baseline (`AVAL` − `BASE`). |
| **ABLFL** | (ADaM) Flag que marca o registro usado como baseline (Y). |
| **TRTP / TRTA** | (ADaM) Tratamento planejado (*planned*) / efetivamente recebido (*actual*). |
| **TRT01P** | (ADaM) Tratamento planejado no período 1. |
| **ITTFL** | (ADaM) Flag de inclusão na população ITT (Y/N). |
| **SAFFL** | (ADaM) Flag de inclusão na população de segurança (Y/N). |
| **TRTEMFL** | (ADaM) Flag de evento adverso emergente do tratamento — TEAE (Y/N). |
| **TRTSDT** | (ADaM) Data de início do tratamento. |
| **TRTEDT** | (ADaM) Data de fim do tratamento. |
