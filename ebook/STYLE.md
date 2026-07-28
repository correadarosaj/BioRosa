# Guia de estilo — "Do Brasil ao FDA"

Referência de voz, formato e convenções para todos os capítulos. Objetivo:
que o livro inteiro pareça escrito pela mesma pessoa.

## Leitor-alvo

Profissional brasileiro com formação quantitativa (estatística, matemática,
epidemiologia, ciências biológicas com viés de dados, TI) que **já sabe
estatística básica** mas **não conhece o mundo regulado da pharma americana**.
Pode nunca ter visto um SAP, um dataset SDTM ou uma tabela de AE. Quer uma
transição de carreira concreta.

## Voz e tom

- Português do Brasil, claro e direto, tratando o leitor por "você".
- Profissional mas caloroso — como um mentor sênior explicando ao júnior.
- Sem encher linguiça. Cada seção entrega algo prático.
- Termos técnicos em inglês são **mantidos no original** (é o vocabulário do
  mercado): *Statistical Analysis Plan*, *estimand*, *dataset*, *shell*,
  *double programming*. Explique/traduza na **primeira** ocorrência.
- Use exemplos concretos e números realistas. Evite generalidades vagas.

## Formato Markdown

- O arquivo começa com **um** título de nível 1: `# Título do capítulo`.
  Não repita "Capítulo N" no título — a numeração é automática.
- Seções internas em `##` e `###`.
- Blocos de código com linguagem: ```r , ```sas , ```text.
- Tabelas em Markdown (pipe tables).
- Caixas de destaque via blockquote com marcador em negrito:
  - `> **Na prática:** ...` — como funciona no dia a dia do trabalho.
  - `> **Atenção:** ...` — armadilha ou erro comum.
  - `> **Glossário PT/EN:** *Term* (EN) = termo/explicação (PT).`
  - `> **Dica de carreira:** ...` — ligação com empregabilidade.
- Ao fim de cada capítulo, uma seção `## Resumo do capítulo` com 4–7 bullets.

## Tamanho

Cada capítulo "grande" (os numerados) deve ter ~1.500–2.500 palavras, o
suficiente para 5–9 páginas impressas. Front matter e apêndices podem ser
menores.

## Precisão

Este é um produto pago sobre um tema regulado. **Não invente** números de
regulamento, nomes de guidelines ou variáveis de padrão. Quando não tiver
certeza de um detalhe específico (ex.: um limite numérico de uma norma),
escreva de forma que oriente sem afirmar um falso específico, ou marque
`> **Verificar:** ...` para revisão. É melhor um livro correto e um pouco
mais genérico em um ponto do que um livro com um fato regulatório errado.

## Consistência de nomes

- FDA, ICH, CDISC, SDTM, ADaM, SAP, TLF, GCP, DSMB, CRO — sempre nessas grafias.
- "ensaio clínico" (não "julgamento clínico" — falso cognato de *trial*).
- "endpoint" (mantido em inglês), "desfecho" como sinônimo em PT quando ajudar.
