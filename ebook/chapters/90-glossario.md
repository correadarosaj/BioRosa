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
| **ADaM** | Analysis Data Model | Padrão CDISC para os datasets **de análise** — os dados já derivados e prontos para gerar as TLFs. Deriva do SDTM e prioriza rastreabilidade. Ver Cap. 18. |
| **ADRG** | Analysis Data Reviewer's Guide | Documento que acompanha os datasets ADaM na submissão, explicando decisões de derivação e desvios ao revisor do FDA. Ver Cap. 19. |
| **ADSL** | Subject-Level Analysis Dataset | Dataset ADaM com **uma linha por sujeito**. É a espinha dorsal do ADaM: carrega populações de análise, braços de tratamento, datas-chave e covariáveis. Ver Cap. 18. |
| **AE** | Adverse Event | Evento adverso: qualquer ocorrência médica desfavorável em um participante, tenha ou não relação causal com o tratamento. Ver Cap. 21. |
| **ALCOA+** | Attributable, Legible, Contemporaneous, Original, Accurate (+ Complete, Consistent, Enduring, Available) | Conjunto de princípios de **integridade de dados** exigido em ambiente regulado. Todo dado deve ser atribuível, legível, contemporâneo, original e exato (mais os complementos). Ver Cap. 7. |
| **ANVISA** | Agência Nacional de Vigilância Sanitária | Agência reguladora brasileira, equivalente funcional do FDA no Brasil. |
| **AVAL** | Analysis Value | Variável numérica de análise na estrutura BDS do ADaM (o valor que entra na estatística). Sua contraparte textual é `AVALC`. |
| **Baseline** | Baseline | Valor de referência de um parâmetro **antes** do início do tratamento, usado como comparação para medir mudança. A definição de baseline é sempre especificada no SAP. |
| **BDS** | Basic Data Structure | Estrutura ADaM de **uma linha por sujeito, parâmetro e ponto no tempo** — usada para dados longitudinais (labs, sinais vitais, eficácia). Ver Cap. 18. |
| **BLA** | Biologics License Application | Pedido de licenciamento de um produto **biológico** (vacinas, anticorpos, terapias celulares) ao FDA. Análogo do NDA, mas para biológicos. Ver Cap. 5. |
| **Blinding** | Blinding (masking) | Cegamento: manter participantes e/ou equipe sem saber qual tratamento cada sujeito recebe, para reduzir viés. *Single-blind*, *double-blind*. Ver Cap. 9. |
| **CBER** | Center for Biologics Evaluation and Research | Centro do FDA responsável por **produtos biológicos** (vacinas, terapias gênicas e celulares). |
| **CDASH** | Clinical Data Acquisition Standards Harmonization | Padrão CDISC para a **coleta** de dados — como os CRFs devem ser estruturados na origem, alimentando o SDTM. Ver Cap. 16. |
| **CDER** | Center for Drug Evaluation and Research | Centro do FDA responsável por **medicamentos** (small molecules e muitos biológicos terapêuticos). |
| **CDISC** | Clinical Data Interchange Standards Consortium | Organização que define os padrões de dados clínicos (CDASH, SDTM, ADaM, Define-XML, Controlled Terminology) exigidos pelo FDA. Ver Cap. 16. |
| **CFR (21 CFR Part 11)** | Code of Federal Regulations, Title 21, Part 11 | Regulamento do FDA sobre **registros e assinaturas eletrônicas** — base para validação de sistemas e trilha de auditoria. Ver Cap. 7. |
| **CM** | Concomitant Medications | Domínio SDTM das medicações concomitantes usadas pelo participante durante o estudo. |
| **CRF** | Case Report Form | Formulário (hoje quase sempre eletrônico, *eCRF*) onde os dados de cada participante são registrados no centro de pesquisa. Ver Cap. 8. |
| **CRO** | Contract Research Organization | Empresa que executa pesquisa clínica sob contrato para os sponsors. Frequentemente a porta de entrada mais acessível para quem vem de fora. Ver Cap. 1. |
| **cSDRG** | clinical Study Data Reviewer's Guide | Documento que acompanha os datasets **SDTM** na submissão, orientando o revisor. Contraparte do ADRG (que é para ADaM). Ver Cap. 19. |
| **CSR** | Clinical Study Report | Relatório final do estudo (formato ICH E3) que integra métodos, resultados e TLFs. As tabelas de eficácia/segurança vivem tradicionalmente na Seção 14. |
| **CT** | Controlled Terminology | Vocabulário controlado do CDISC — listas de valores permitidos (ex.: `SEX`, `RACE`, unidades) que padronizam os datasets. Ver Cap. 16. |
| **CTD** | Common Technical Document | Formato ICH M4 que organiza um dossiê de submissão em cinco módulos. Sua versão eletrônica é o eCTD. Ver Cap. 5. |
| **DBL** | Database Lock | Congelamento do banco de dados: momento em que os dados são declarados finais e limpos, ninguém mais os altera, e a análise "para valer" começa. Ver Cap. 12. |
| **Define-XML** | Define-XML (Data Definition) | Arquivo XML que **descreve os metadados** dos datasets (SDTM e ADaM) submetidos — o "mapa" que diz ao revisor o que é cada variável. Ver Cap. 19. |
| **DM** | Demographics | Domínio SDTM da demografia — uma linha por sujeito com idade, sexo, raça, braço de tratamento. Domínio central do SDTM. Ver Cap. 17. |
| **Double programming** | Double (independent) programming | Técnica de QC em que **dois programadores** produzem a mesma tabela de forma independente e comparam os resultados. Ver Cap. 23. |
| **DSMB** | Data Safety Monitoring Board | Comitê independente que monitora a segurança dos participantes durante o estudo e recomenda continuar, ajustar ou parar. Sinônimo prático de IDMC. Ver Cap. 14. |
| **eCTD** | electronic Common Technical Document | Formato eletrônico do CTD, exigido pelo FDA para submissões regulatórias. Ver Cap. 16. |
| **EMA** | European Medicines Agency | Agência reguladora de medicamentos da União Europeia. Equivalente europeu do FDA. |
| **Endpoint** | Endpoint (outcome) | Desfecho: a medida usada para avaliar o efeito do tratamento (ex.: mortalidade, redução de pressão, resposta tumoral). Pode ser primário, secundário ou exploratório. Ver Cap. 10. |
| **Estimand** | Estimand | Definição precisa do "o que exatamente estamos estimando" (população, variável, manejo de eventos intercorrentes, sumário populacional). Framework do ICH E9(R1). Ver Cap. 10. |
| **EX** | Exposure | Domínio SDTM da exposição ao tratamento — quanto de droga cada sujeito recebeu, quando e por quanto tempo. Ver Cap. 17. |
| **FDA** | Food and Drug Administration | Agência federal americana que regula alimentos e medicamentos. Cliente final invisível de todo o seu trabalho. Ver Cap. 1 e 5. |
| **GCP** | Good Clinical Practice | Boas Práticas Clínicas (ICH E6): o padrão ético e de qualidade para conduzir ensaios clínicos. Ver Cap. 6 e 7. |
| **H-1B** | H-1B specialty occupation visa | Visto de trabalho americano para ocupações especializadas — a via mais comum (mas competitiva, com loteria) para profissionais estrangeiros. Ver Cap. 3. |
| **IB** | Investigator's Brochure | Documento com todas as informações pré-clínicas e clínicas conhecidas sobre o produto, entregue aos investigadores. |
| **ICF** | Informed Consent Form | Termo de consentimento livre e esclarecido assinado pelo participante antes de entrar no estudo. |
| **ICH** | International Council for Harmonisation (of Technical Requirements for Pharmaceuticals for Human Use) | Organismo internacional que harmoniza as exigências técnicas entre reguladores. Fonte das diretrizes E6, E8, E9, E9(R1), E3, M4. Ver Cap. 6. |
| **IDMC** | Independent Data Monitoring Committee | Nome ICH para o comitê independente de monitoramento de dados. Na prática, sinônimo de DSMB. Ver Cap. 14. |
| **IND** | Investigational New Drug | Pedido ao FDA para iniciar testes de um novo composto **em humanos**. Marca a transição do pré-clínico para a Fase I. Ver Cap. 5. |
| **Interim analysis** | Interim analysis | Análise interina: análise planejada dos dados **antes** do fim do estudo, geralmente para decisões de segurança ou eficácia (com ajuste de multiplicidade). Ver Cap. 14. |
| **Intercurrent event** | Intercurrent event | Evento intercorrente: algo que ocorre após o início do tratamento e afeta a interpretação do endpoint (ex.: descontinuação, uso de medicação de resgate, morte). Central no framework de estimands. Ver Cap. 10. |
| **IRB** | Institutional Review Board | Comitê de ética que aprova e supervisiona o estudo para proteger os participantes. Equivalente ao CEP/CONEP no Brasil. |
| **ISS / ISE** | Integrated Summary of Safety / Integrated Summary of Efficacy | Análises **integradas** de segurança e eficácia que combinam vários estudos de um programa, exigidas em submissões de NDA/BLA. |
| **ITT** | Intention-to-Treat | População de análise que inclui **todos os randomizados**, no grupo ao qual foram alocados, independentemente do que ocorreu depois. Princípio conservador padrão. Ver Cap. 14. |
| **Kaplan-Meier (KM)** | Kaplan-Meier estimator | Método não paramétrico para estimar curvas de sobrevida (time-to-event) na presença de censura. |
| **LB** | Laboratory | Domínio SDTM dos resultados laboratoriais (hematologia, bioquímica, urinálise). Um dos domínios mais volumosos. Ver Cap. 17. |
| **LOCF** | Last Observation Carried Forward | Método (hoje desencorajado como análise primária) de imputar dados faltantes repetindo a última observação disponível. Ver Cap. 14. |
| **MedDRA** | Medical Dictionary for Regulatory Activities | Dicionário padronizado para codificar eventos adversos e condições médicas, organizado em hierarquia (SOC → PT, entre outros níveis). Ver Cap. 21. |
| **mITT** | modified Intention-to-Treat | Variante da ITT com critérios de exclusão pré-especificados (ex.: exigir ao menos uma dose ou uma avaliação pós-baseline). Definida no SAP. Ver Cap. 14. |
| **MMRM** | Mixed Model for Repeated Measures | Modelo misto para medidas repetidas — método de referência para dados longitudinais contínuos, que usa todos os dados observados sem imputação explícita. Ver Cap. 14. |
| **NDA** | New Drug Application | Pedido de aprovação de comercialização de um **medicamento** ao FDA. Contraparte do BLA (para biológicos). Ver Cap. 5. |
| **NIH** | National Institutes of Health | Principal agência de pesquisa biomédica dos EUA; financia muitos estudos acadêmicos via *grants*. Ver Cap. 1. |
| **OCCDS** | Occurrence Data Structure | Estrutura ADaM para dados de **ocorrência** (eventos adversos, medicações concomitantes) — uma linha por evento registrado. Ver Cap. 18. |
| **OPT** | Optional Practical Training | Autorização de trabalho temporária para estudantes internacionais nos EUA após a formatura (via F-1). Uma porta de entrada comum. Ver Cap. 3. |
| **PARAM / PARAMCD** | Parameter / Parameter Code | Variáveis ADaM (BDS) que identificam o parâmetro analisado: `PARAM` é o texto descritivo, `PARAMCD` é o código curto. Ver Cap. 18. |
| **Per-protocol (PP)** | Per-Protocol population | População de análise que inclui apenas os sujeitos que **seguiram o protocolo** sem desvios majoritários. Usada como sensibilidade da ITT. Ver Cap. 14. |
| **PHUSE** | Pharmaceutical Users Software Exchange | Comunidade global de profissionais de dados clínicos; publica padrões de qualidade (ex.: whitepapers e o repositório de *TLF standards*). Ótima fonte gratuita. Ver Cap. 26. |
| **Pinnacle 21** | Pinnacle 21 (Community / Enterprise) | Ferramenta de validação de conformidade CDISC (SDTM/ADaM/Define-XML) usada de fato pela indústria e pelo FDA. A versão Community é gratuita. Ver Cap. 19. |
| **Placebo** | Placebo | Tratamento inerte usado como comparador para isolar o efeito real da intervenção. |
| **PMDA** | Pharmaceuticals and Medical Devices Agency | Agência reguladora do Japão. |
| **Power** | Statistical power | Poder estatístico: probabilidade de detectar um efeito real quando ele existe (1 − β). Guia o cálculo de tamanho amostral. Ver Cap. 11. |
| **Protocol** | Protocol | Documento mestre que define objetivos, desenho, população, tratamentos e análises de um estudo. Tudo o mais deriva dele. Ver Cap. 8. |
| **PT** | Preferred Term | Nível do MedDRA que nomeia de forma padronizada uma condição médica específica (ex.: "Nausea"). Agrupa-se em SOC. Ver Cap. 21. |
| **QC** | Quality Control | Controle de qualidade: o conjunto de verificações (incluindo double programming) que garante que TLFs e datasets estão corretos. Ver Cap. 23. |
| **Randomization** | Randomization | Randomização: alocação aleatória dos participantes aos tratamentos, base para comparações não enviesadas. Pode ser estratificada ou em blocos. Ver Cap. 9. |
| **SAE** | Serious Adverse Event | Evento adverso **grave**: resulta em morte, risco de vida, hospitalização, incapacidade ou anomalia congênita. Tem reporte acelerado. Ver Cap. 21. |
| **SAP** | Statistical Analysis Plan | Plano de análise estatística: documento que especifica **em detalhe** todas as análises, congelado antes de ver os dados. Peça central do trabalho. Ver Cap. 12–15. |
| **SDTM** | Study Data Tabulation Model | Padrão CDISC para os dados **tabulados de origem**, organizados em domínios (DM, AE, LB, VS, EX, CM…). Base a partir da qual o ADaM é derivado. Ver Cap. 17. |
| **Shell** | Table shell (mock-up) | Modelo vazio de uma tabela/listagem/figura — com título, colunas e footnotes definidos, mas sem números. Feito antes da programação. Ver Cap. 20 e o template `tlf-shells.md`. |
| **SOC** | System Organ Class | Nível mais alto do MedDRA, que agrupa PTs por sistema do corpo (ex.: "Gastrointestinal disorders"). Ver Cap. 21. |
| **Sponsor** | Sponsor | Empresa (pharma/biotech) dona do estudo e responsável legal perante o FDA. Ver Cap. 1. |
| **SUSAR** | Suspected Unexpected Serious Adverse Reaction | Reação adversa grave, inesperada e suspeita de relação com a droga — sujeita a reporte expedito ao regulador. |
| **TEAE** | Treatment-Emergent Adverse Event | Evento adverso que **surge ou piora após** o início do tratamento. É o recorte padrão para as tabelas de segurança. Ver Cap. 21. |
| **TLF** | Tables, Listings and Figures | Tabelas, listagens e figuras que resumem os resultados do estudo — o produto final visível do trabalho estatístico. Ver Cap. 20–23. |
| **Traceability** | Traceability | Rastreabilidade: a capacidade de seguir cada valor analisado de volta até o dado de origem (SDTM/CRF). Princípio central do ADaM. Ver Cap. 18. |
| **Unblinding** | Unblinding | Quebra do cegamento — planejada (no database lock) ou não planejada (emergência médica). Ver Cap. 9 e 12. |
| **USUBJID** | Unique Subject Identifier | Identificador único de cada participante ao longo de **todos** os datasets de um estudo/programa. Chave que conecta os domínios. Ver Cap. 17. |
| **Visit window** | Visit window (analysis window) | Janela de visita: regra que mapeia uma medida realizada numa data real para um ponto de tempo nominal de análise (ex.: "Semana 12 = dias 78–98"). Definida no SAP. Ver Cap. 14. |
| **VS** | Vital Signs | Domínio SDTM dos sinais vitais (pressão, frequência cardíaca, temperatura, peso). Ver Cap. 17. |
| **WHODrug** | WHO Drug Dictionary | Dicionário da OMS para codificar medicações (usado tipicamente no domínio CM). Contraparte do MedDRA, mas para drogas. Ver Cap. 21. |

> **Na prática:** você não precisa memorizar tudo de uma vez. Na primeira semana
> de qualquer projeto, os 20 termos que mais aparecem são: SAP, SDTM, ADaM,
> ADSL, TLF, shell, DBL, AE/SAE/TEAE, ITT, MedDRA, define, USUBJID, PARAMCD,
> baseline, QC, GCP, ICH E9, endpoint, estimand e sponsor. Domine esses e o resto
> vem com o contexto.
