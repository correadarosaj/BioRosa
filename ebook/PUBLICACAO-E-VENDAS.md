# Guia de publicação e vendas — KDP + Hotmart

Este guia acompanha o ebook "Do Brasil ao FDA" e cobre como transformá-lo em um
produto à venda na **Amazon KDP** (alcance internacional, USD) e na **Hotmart**
(público brasileiro, BRL). Ele é um documento de trabalho — não faz parte do
livro em si.

> **Aviso:** valores de royalty, exigências de formato e regras das plataformas
> mudam. Confirme sempre na central de ajuda oficial (kdp.amazon.com,
> hotmart.com) antes de publicar. Nada aqui é aconselhamento fiscal ou jurídico.

---

## 1. Estratégia de duas plataformas

As duas plataformas atingem públicos diferentes e não competem entre si — o
ideal é publicar nas duas.

| | **Amazon KDP** | **Hotmart** |
|---|---|---|
| Público | Global; brasileiros no exterior; busca orgânica na Amazon | Brasil; compra por infoproduto; tráfego pago/afiliados |
| Moeda | Principalmente USD (e outras lojas) | BRL |
| Formato | EPUB (Kindle) | PDF (e bundle de arquivos) |
| Preço típico infoproduto | US$ 6,99–19,99 | R$ 47–297 |
| Royalty | 70% na faixa US$ 2,99–9,99*; senão 35% | Alto (menos taxa da plataforma) |
| Força | Descoberta orgânica, credibilidade | Afiliados, upsell, comunidade, checkout BRL |
| Fraqueza | Pouca ferramenta de marketing | Sem busca orgânica (você traz o tráfego) |

\* A faixa de 70% no KDP tem condições (preço mínimo/máximo e mercados). **Verificar** na tabela vigente do KDP.

> **Recomendação de posicionamento:** na Amazon, preço mais baixo para ganhar
> volume e reviews (reviews são o motor da descoberta). Na Hotmart, um preço
> mais alto com o produto "empacotado" (ebook + templates + checklists +
> eventual bônus/comunidade), vendido como transformação de carreira.

---

## 2. Amazon KDP — passo a passo

### 2.1 Prepare os arquivos

1. Gere o EPUB: `./build/build.sh epub` (produz `build/output/do-brasil-ao-fda.epub`).
2. **Capa** (obrigatória): imagem 1.600 × 2.560 px (proporção 1:1,6), JPG/TIFF,
   texto legível em miniatura. Coloque em `assets/cover.png` para o build
   embutir no EPUB, e faça upload da versão de alta resolução no KDP.
3. Revise o EPUB no **Kindle Previewer** (app gratuito da Amazon) — ele mostra
   como fica em diferentes dispositivos e aponta erros.

### 2.2 Crie a publicação

1. Conta em [kdp.amazon.com](https://kdp.amazon.com) (precisa de dados fiscais
   e bancários — veja §4 sobre imposto para não residentes/residentes).
2. "Create → Kindle eBook". Preencha:
   - **Language:** Portuguese.
   - **Title/Subtitle:** use exatamente o do `metadata.yaml`.
   - **Author:** seu nome (o mesmo em todos os produtos = marca).
   - **Description:** o texto de vendas (veja §3). Aceita HTML básico.
   - **Keywords:** 7 campos — use "bioestatística", "pesquisa clínica",
     "carreira internacional", "CDISC SDTM ADaM", "SAP estatística",
     "trabalhar nos EUA", "farmacêutica FDA".
   - **Categories:** escolha 2–3 (ex.: Medicina › Bioestatística; Negócios ›
     Carreiras; Educação). Categorias mais específicas = mais fácil ranquear.
3. Upload do EPUB e da capa. Ative ou não o **DRM** (recomendo **sem DRM** para
   infoproduto técnico — reduz atrito).
4. **Preço e royalty:** escolha 70% se o preço estiver na faixa elegível;
   defina o preço na loja US e deixe o KDP converter, ou ajuste por mercado.
5. **KDP Select** (exclusividade Kindle por 90 dias, entra no Kindle Unlimited):
   avalie. Prós: KU paga por página lida e dá visibilidade. Contras: você não
   pode vender o **mesmo** ebook digital em outro lugar durante o período.

> **Compatibilidade com a Hotmart:** o KDP Select exige exclusividade da
> **versão digital**. Se quiser as duas plataformas ao mesmo tempo, **não**
> entre no KDP Select — ou venda na Hotmart um pacote claramente diferente
> (PDF + templates + bônus), não o EPUB idêntico. **Verificar** os termos
> atuais do KDP Select.

### 2.3 Reviews (o mais importante)

- Reviews orgânicos movem o algoritmo da Amazon. Peça (sem incentivar com
  brinde, o que viola os termos) ao fim do livro — o capítulo de encerramento
  já faz isso.
- Primeiros 10–20 reviews são os mais difíceis e mais valiosos. Mobilize sua
  rede/colegas que realmente leram.

---

## 3. Texto de vendas (description) — rascunho reutilizável

Use como base tanto na Amazon quanto na Hotmart (ajuste o CTA e a moeda):

> **Você tem formação quantitativa e sonha em trabalhar como bioestatístico ou
> programador estatístico na indústria farmacêutica dos Estados Unidos — mas
> não sabe por onde começar?**
>
> Este é o primeiro guia **em português** que conecta todos os pontos: as
> regulamentações do FDA e do ICH, o desenho de ensaios clínicos, a redação de
> um **Statistical Analysis Plan (SAP)**, os padrões **CDISC (SDTM e ADaM)** e a
> produção de **TLFs** — o trabalho que sustenta cada aprovação de medicamento
> nos EUA. E vai além da técnica: mostra os **caminhos de carreira e de visto**,
> como montar um **portfólio** e como passar na **entrevista técnica** americana.
>
> Escrito para quem sabe estatística, mas nunca trabalhou na pharma regulada.
> Do zero ao vocabulário de um profissional pronto para o mercado.
>
> **Você recebe:**
> - Guia completo, capítulo a capítulo, do panorama regulatório à submissão.
> - Exemplos práticos de código em **SAS e R**.
> - **Templates** prontos: SAP, shells de TLF e sinopse de protocolo.
> - **Checklists** de SAP, QC de TLF e submissão de dados.
> - Um **plano de 90 dias** para a sua transição de carreira.
>
> Comece hoje a construir a carreira internacional que você achava distante
> demais.

Ganchos de título/subtítulo para testar (A/B) na Hotmart: "Do Brasil ao FDA",
"Bioestatística Clínica para o Mercado Americano", "A Ponte para a Pharma dos
EUA".

---

## 4. Impostos e recebimento (leia com atenção)

- **Amazon KDP** exige uma **tax interview** (formulário fiscal). Autores fora
  dos EUA normalmente lidam com retenção; o Brasil tem tratado que pode reduzir
  a retenção sobre royalties se você fornecer os dados corretos (ex.: número de
  identificação fiscal). **Confirme com um contador** a forma correta de
  declarar e receber (pessoa física × MEI/empresa).
- **Hotmart** paga em BRL para conta brasileira e emite os relatórios; ainda
  assim, **rendimento de venda de infoproduto é tributável** — confirme o
  enquadramento (MEI costuma não cobrir; verifique CNAE/limites) com contador.

> **Atenção:** este guia não substitui um contador. Antes do primeiro pagamento,
> resolva a parte fiscal para não ter surpresa.

---

## 5. Hotmart — passo a passo (resumo)

1. Gere o **PDF**: `./build/build.sh pdf`.
2. Conta em [hotmart.com](https://hotmart.com) → "Produtos" → "Novo produto" →
   tipo **Ebook/Arquivos**.
3. Faça upload do PDF **e** dos templates/checklists como arquivos do produto
   (empacotar aumenta o valor percebido).
4. Preencha página de vendas (use o texto do §3), defina preço em BRL,
   configure formas de pagamento (cartão, Pix, boleto).
5. Ative o **programa de afiliados** (Hotmart Afiliados): defina uma comissão
   (ex.: 40–50%). Afiliados são o principal motor de tráfego na Hotmart.
6. Configure **order bump/upsell** se tiver um produto complementar (ex.: uma
   mentoria, um curso em vídeo, revisão de currículo).

---

## 6. Checklist de lançamento

- [ ] Conteúdo revisado (ver `REVISAO.md`, gerado após a redação)
- [ ] Nome do autor preenchido no `metadata.yaml`, front matter e "sobre o autor"
- [ ] Capa criada (1.600 × 2.560 px) em `assets/cover.png`
- [ ] EPUB gerado e testado no Kindle Previewer
- [ ] PDF gerado e revisado
- [ ] Templates e checklists exportados como PDFs separados (bônus Hotmart)
- [ ] Descrição de vendas finalizada (§3)
- [ ] 7 keywords + 2–3 categorias definidas (KDP)
- [ ] Tax interview do KDP concluída; enquadramento fiscal resolvido com contador
- [ ] Preço definido em cada plataforma
- [ ] Decisão sobre KDP Select (exclusividade) tomada
- [ ] Plano para os primeiros 10–20 reviews
- [ ] Página de vendas da Hotmart + afiliados configurados
