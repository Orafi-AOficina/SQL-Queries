# Padrões de Resposta

Templates para estruturar a narrativa de saída. Adaptar tom conforme o contexto, mas manter a ordem das seções.

## Template 1 — Pedido Único (caso mais comum)

```
**Pedido <PEDIDO> — <CLIENTE>** · <QTD> peças · entrada em <DATA> · prazo <PRAZO>

**Status:** <🟢/🟡/🔴> <uma frase com a síntese>

**Onde estão as peças:**
- <N1> peças em <setor1> — <frase curta sobre tempo ou situação>
- <N2> peças em <setor2> — <...>
- <N3> já finalizadas

**Previsão de entrega:** <faixa em dias> · <justificativa breve>

**Risco:** <cor> — <justificativa com número>

**Pontos de atenção:**
- <só se houver algo relevante>

<Abertura para continuar>
```

### Exemplo preenchido

```
**Pedido PED-12345 — Animale** · 40 peças · entrada em 02/04 · prazo 25/04

**Status:** 🟡 Pedido caminhando, mas com risco moderado de atraso em parte das peças.

**Onde estão as peças:**
- 15 peças em cravação (desde 10/04 — já acima da média de 3 dias para esse produto)
- 18 peças em polimento (entrou há 2 dias — dentro do normal)
- 7 já finalizadas

**Previsão de entrega:** 23 a 27 de abril · baseado no tempo restante de cravação + polimento + expedição para esse grupo de produto.

**Risco:** 🟡 Amarelo — as 15 peças em cravação estão há 5 dias no setor, quando o padrão é 3. Se não destravar essa semana, o prazo fica apertado.

**Pontos de atenção:**
- Cravador responsável (João) aparece em outras 3 OPs Animale em andamento — pode ter fila.

Quer que eu veja o que mais está na fila da cravação ou confira se tem insumo faltando?
```

---

## Template 2 — Múltiplos Pedidos / Agregado por Cliente

```
**<N> pedidos encontrados para <CLIENTE>** · <resumo rápido: X verdes, Y amarelos, Z vermelhos>

**🔴 Atenção imediata (<N>):**
- <Pedido> · <Qtd> peças · prazo <dia> · <motivo em 1 linha>
- ...

**🟡 Risco moderado (<N>):**
- <Pedido> · <Qtd> peças · prazo <dia> · <motivo em 1 linha>
- ...

**🟢 Em dia (<N>):**
- <Pedidos listados só por número, sem detalhe>

<Abertura>
```

### Exemplo

```
**6 pedidos encontrados para Animale com prazo nos próximos 7 dias** · 2 verdes, 3 amarelos, 1 vermelho

**🔴 Atenção imediata (1):**
- PED-11800 · 25 peças · prazo 19/04 (amanhã) · 18 peças ainda em cravação, média de atraso: 4 dias

**🟡 Risco moderado (3):**
- PED-12050 · 40 peças · prazo 23/04 · parte em polimento com tempo elevado
- PED-12210 · 15 peças · prazo 24/04 · esperando cravação iniciar
- PED-12340 · 30 peças · prazo 25/04 · insumo pendente (brilhante 1.2mm)

**🟢 Em dia (2):** PED-12410, PED-12530

Quer que eu aprofunde em algum deles? O PED-11800 é o mais urgente.
```

---

## Template 3 — Pergunta Aberta / Exploratória

Quando o usuário faz pergunta aberta ("como está a Animale essa semana?") sem identificador, começar com uma visão de alto nível e oferecer drill-down:

```
**Animale — panorama da semana**

- <N> pedidos em produção totalizando <Q> peças
- <N_risco> em risco de atraso (<detalhe muito rápido>)
- <algo não-óbvio que cruzou dos dados>

<Abertura oferecendo drill-down>
```

### Exemplo

```
**Animale — panorama da semana**

- 14 pedidos em produção totalizando 387 peças
- 3 pedidos em risco de atraso (PED-11800, PED-12050, PED-12340)
- Observação: 4 pedidos dependem do mesmo insumo pendente (brilhante 1.2mm) — vale confirmar com compras.

Quer que eu detalhe os 3 em risco ou que investigue a questão do insumo?
```

---

## Regras de Redação

- Ordem das peças: **sempre do setor mais atrasado para o mais próximo da finalização** (dá peso a quem precisa de atenção).
- Datas: formato `DD/MM` ou `DD/MM/AAAA` se ano não for óbvio.
- Usar negrito pra chaves (Pedido, Cliente, Status, Previsão, Risco) — facilita leitura rápida por sócio.
- Emojis de semáforo (🟢🟡🔴) são OK — são leitura visual imediata, não enfeite.
- Nunca incluir gramas/pesos sem autorização explícita + confirmação de perfil sócio.
- Nunca mencionar nome de tabela, view, código de conta, código de produto.
- Nome de colaborador: só primeiro nome. Se for expor capacidade/performance de pessoa específica, avisar que é dado sensível.

## Abertura de Próximo Passo

Sempre fechar com uma pergunta curta oferecendo continuidade. Exemplos:

- "Quer que eu veja o que mais está na fila da cravação?"
- "Quer que eu confira se tem insumo faltando?"
- "Quer que eu investigue por que [X] está parado?"
- "Vale eu olhar esse insumo nos outros pedidos?"
- "Quer que eu prepare um briefing pra reunião com [cliente]?"

Evitar: "posso ajudar com mais alguma coisa?" — genérico e não agrega.
