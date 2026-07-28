# Apêndice C — Checklists

Teoria vira competência quando você consegue **executar sob pressão sem esquecer
nada**. Estes checklists condensam o que os capítulos ensinaram em listas
acionáveis. Imprima, copie para o seu gestor de tarefas, cole no topo do
documento em que estiver trabalhando. Marque `[x]` conforme avança.

Nenhuma lista substitui os SOPs internos da sua empresa nem o julgamento do seu
estatístico sênior — mas errar por esquecimento é o tipo de falha que estes
checklists evitam.

## Checklist A — Revisão de SAP antes do database lock

Use antes de declarar o SAP "final" e antes do DBL. Ver Cap. 12–15.

**Alinhamento com o protocolo**

- [ ] Objetivos e endpoints do SAP batem **exatamente** com o protocolo (mesma redação de primário/secundário/exploratório).
- [ ] Estimand(s) especificado(s): população, variável, manejo de eventos intercorrentes e sumário populacional (ICH E9(R1)).
- [ ] Toda emenda de protocolo posterior foi refletida no SAP.

**Populações e dados**

- [ ] Cada população de análise (ITT/mITT/PP/Safety) está **definida sem ambiguidade** e diz a que análises se aplica.
- [ ] Definição de baseline explícita (qual medida, qual data).
- [ ] Regras de visit windows / analysis windows especificadas.
- [ ] Derivações-chave descritas (mudança em relação ao baseline, TEAE, duração de exposição etc.).

**Métodos estatísticos**

- [ ] Método primário totalmente especificado (modelo, covariáveis, fatores, estrutura de covariância se aplicável).
- [ ] Manejo de dados faltantes definido, com análise(s) de sensibilidade coerentes com o estimand.
- [ ] Estratégia de multiplicidade descrita (ordem hierárquica, alpha, procedimento de ajuste).
- [ ] Análises interinas: número, timing, regras de parada e papel do DSMB/IDMC.
- [ ] Subgrupos pré-especificados listados (e marcados como confirmatórios ou exploratórios).

**Consistência e forma**

- [ ] Lista de TLFs no SAP corresponde aos shells e à numeração planejada.
- [ ] Abreviações usadas estão todas na lista de abreviações.
- [ ] Seção "mudanças em relação ao protocolo/SAP anterior" preenchida.
- [ ] Referências (ICH E9, guidances, métodos) corretas e citáveis.
- [ ] Versão, data e assinaturas/aprovações preenchidas; SAP congelado **antes do unblinding**.

## Checklist B — QC de um TLF

Use ao validar cada tabela, listagem ou figura antes da entrega. Ver Cap. 20 e 23.

**Contra o shell e o SAP**

- [ ] Título, numeração (`Table 14.x.x`) e footnotes idênticos ao shell.
- [ ] População correta na linha "Population" e o `N` do cabeçalho bate com o ADSL.
- [ ] Grupos de tratamento na ordem e com os rótulos definidos no SAP.

**Números**

- [ ] Denominadores corretos (a base de cada percentual é a esperada).
- [ ] Percentuais conferem com os n (`n/N`); regras de arredondamento consistentes.
- [ ] Totais e subtotais somam; nenhuma categoria some ou aparece duas vezes.
- [ ] Valores batem com o **double programming** independente (ou discrepâncias resolvidas e documentadas).
- [ ] Missing/"not reported" tratados conforme o SAP (não confundir zero com ausente).

**Forma e rastreabilidade**

- [ ] Decimais e unidades corretos e consistentes.
- [ ] Quebras de página, ordenação e alinhamento legíveis.
- [ ] Datas do run, versão do programa e fonte (dataset ADaM) registradas.
- [ ] Nenhum dado que quebre o cegamento aparece em output ainda cego.
- [ ] Log de execução limpo (sem WARNING/ERROR não explicados).

## Checklist C — Pacote de submissão de dados (SDTM / ADaM / define / guides)

Use antes de entregar o pacote de dados ao sponsor ou ao FDA. Ver Cap. 16–19.

**Datasets**

- [ ] SDTM conforme a versão do SDTMIG exigida; domínios necessários presentes (DM, AE, LB, VS, EX, CM…).
- [ ] ADaM conforme a versão do ADaMIG; ADSL e datasets BDS/OCCDS consistentes.
- [ ] Controlled Terminology na versão correta; valores dentro das listas permitidas.
- [ ] `USUBJID` único e consistente entre todos os datasets.
- [ ] Rastreabilidade ADaM → SDTM verificável (variáveis de origem e flags de análise).

**Validação e metadados**

- [ ] Pinnacle 21 rodado; findings revisados, corrigidos ou justificados (nenhum erro sem explicação).
- [ ] Define-XML gerado, válido e coerente com os datasets reais (labels, origens, comentários).
- [ ] cSDRG (para SDTM) e ADRG (para ADaM) escritos, explicando desvios e decisões.

**Empacotamento**

- [ ] Nomes de arquivos, tamanhos e formato (XPT/transport) conforme o guia de conformidade técnica do FDA.
- [ ] Estrutura de pastas do eCTD correta.
- [ ] Programas de análise entregues quando exigidos.
- [ ] Versões travadas: dado, define, guides e programas correspondem ao mesmo database lock.

## Checklist D — Preparação de carreira e candidatura

Use enquanto se prepara para o mercado americano. Ver Cap. 3, 25 e 26.

**Fundamentos técnicos**

- [ ] Domina o vocabulário deste livro (Apêndice A) e sabe explicá-lo em inglês.
- [ ] Sabe descrever o fluxo protocolo → SAP → SDTM → ADaM → TLF → submissão.
- [ ] Escolheu e pratica a stack (SAS **e/ou** R; SQL; Git) — ver Cap. 4.

**Portfólio (a prova de que você sabe fazer)**

- [ ] Projeto end-to-end público: protocolo-sintético → SAP → ADaMs → pacote de TLFs (Cap. 24).
- [ ] Repositório no GitHub organizado, com README claro e código legível.
- [ ] Ao menos uma tabela/figura reproduzida no padrão da indústria (usando os shells deste livro).

**Materiais de candidatura**

- [ ] Currículo em inglês, formato americano, com **palavras-chave reais** (SAP, CDISC, SDTM, ADaM, TLF, GCP, ICH E9).
- [ ] LinkedIn em inglês, título e "About" mirando *Biostatistician* ou *Statistical Programmer*.
- [ ] Carta/resumo curto que conecta sua formação quantitativa ao trabalho regulado.

**Inglês e entrevista**

- [ ] Consegue conduzir uma conversa técnica de 30 min em inglês sem travar.
- [ ] Preparou respostas para perguntas típicas (populações de análise, dados faltantes, QC, um caso de estudo).
- [ ] Praticou *live coding* / estudo de caso (Cap. 25).

**Estratégia**

- [ ] Definiu o alvo realista (CRO / vaga remota / Fase de entrada) — Cap. 1 e 3.
- [ ] Entende as vias de visto aplicáveis ao seu caso (H-1B, O-1, EB-2 NIW, OPT) — Cap. 3.
- [ ] Está conectado às comunidades (PHUSE, PharmaSUG, ASA) — Cap. 26.
- [ ] Começou o **plano de 90 dias** (Cap. 26). Data de início: `<preencher>`.

> **Dica de carreira:** transforme o Checklist D num documento vivo com datas.
> "Aplicar-se" a uma carreira não é um evento — é uma sequência de marcações. Um
> checklist com metade das caixas ainda em branco é, na verdade, o seu plano de
> ação para as próximas semanas.
