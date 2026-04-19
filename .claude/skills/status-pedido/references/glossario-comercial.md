# Glossário Comercial — Tradução Técnico → Comercial

Sempre que o SQL retornar um termo técnico, traduzir antes de mostrar ao usuário. Se um termo não estiver aqui, prefira descrição em linguagem comum em vez de repetir o termo bruto.

## Setores / Operações

| ERP / PBI | Comercial |
|-----------|-----------|
| FUNDICAO | Fundição (peça ainda sendo "nascida" em ouro) |
| OURIVESARIA.TRA / OURIVESARIA | Ourivesaria (montagem manual da peça) |
| CRAVACAO.TRAB / CRAVAÇÃO | Cravação (cravação das pedras) |
| POLIMENTO | Polimento (acabamento final) |
| FINALIZAÇÃO | Finalização (peça recebendo código de barras — praticamente pronta) |
| EXPEDIÇÃO / SEP | Expedição (pronta pra sair) |
| PCP | Planejamento (ainda antes da produção começar) |
| CORT.LASER | Corte a laser |
| ACEITE | Aceite do cliente |

## Status e Campos

| ERP / PBI | Comercial |
|-----------|-----------|
| OP / nops | Não usar "OP" com comercial. Falar "lote" ou "item de produção". Sócios entendem OP — pra eles, pode manter. |
| OP_MAE | "Lote principal do item do pedido" — evitar, resumir em termos de peças |
| ULT_MOVIMENTACAO | "Última movimentação em [data]" |
| QTD_PEND | "Peças ainda em produção" |
| QTD | "Peças totais do pedido" |
| CB / FINALIZACAO | "Código de barras" / "peça pronta" |
| PRAZO | "Prazo acordado" |
| DATA_ENTRADA | "Entrada do pedido" |
| LOCAL / COD_CONTA | "Setor atual" / "colaborador responsável" — nunca expor código da conta. Se identificar colaborador, usar primeiro nome. |
| NF | "Nota fiscal" / "faturamento" |
| DESMANCHE | "Peça desmontada para retrabalho" — evento negativo, tratar com cuidado |

## Empresas

| ERP | Comercial |
|-----|-----------|
| RNG | Manaus |
| ORA / ORF | Rio de Janeiro |

Nota: regra Orafi — sempre tratar `ORF` como `ORA` antes de mostrar.

## Clientes

- Mencionar cliente pelo nome curto usual: "Animale", "Carolina Neves", "CL Jóias", "Maria Eulália".
- Nunca expor código do cliente (cclis) na resposta.
- **Aliases** (o mesmo cliente aparece com nomes diferentes no cadastro — ao buscar, cruzar todas as variantes):

| Nome curto | Variantes no banco (usar `CLIENTE LIKE`) |
|------------|------------------------------------------|
| Animale | `%ANIMALE%`, `%CIDADE MARAVILHOSA%` (razão social) |
| CL Jóias | `%CL JOIAS%` (inclui MATRIZ e franquias como `FRANQUIA CL - ...`) |
| Carolina Neves | `%CAROLINA NEVES%`, `%ESMERALDA%` (razão social Esmeralda Comercio de Joias) |
| Maria Eulália | `%MARIA EULALIA%` |
| Kora Kora | `%KORA KORA%` |
| Carla Amorim | `%CARLA AMORIM%` |

Quando usuário falar nome curto, buscar TODOS os aliases num único `OR`. Exibir na resposta o nome curto unificado.

- Campos de cliente/local vêm com **padding de espaços** — sempre aplicar `LTRIM(RTRIM(...))` ou tratar na exibição.

## Tipos de Pedido

| ERP | Comercial |
|-----|-----------|
| PILOTO | "Piloto" (peça nova, sem histórico) |
| ENCOMENDA | "Encomenda" (prazo curto, alta prioridade) |
| FÁBRICA | "Fábrica" (produção normal) |
| NOVIDADE | "Novidade" (lançamento) |
| REPIQUE | "Repique" (reposição) |
| ESTOQUE | "Reposição de estoque" |
| CONSERTO | "Conserto" |

## Terminologia que NUNCA expor ao comercial

- Nome de tabela (SigMvCab, SigOpPic, etc.)
- Nome de view (Vw_StatusOPsPendentes, etc.)
- SEQ_MOVIMENTACAO, cidchaves, empdopnums, CHAVE_*
- AU750 / AG925 (dizer "ouro 18K" / "prata 925" se for inevitável)
- Códigos internos de produto (cpros) — usar descrição ou ref cliente
- cclis, ccols, codpros — sempre usar nome

## Frases-Padrão Úteis

- "Ainda não saiu do planejamento" → quando só tem movimentação em PCP
- "Está com a ourivesaria desde X" → peça em ourivesaria há muito tempo
- "Já está finalizando — faltam N peças pra fechar" → quase pronto
- "Pronto pra expedir, aguardando NF" → finalizada sem NF ainda
- "Em risco por atraso em [setor]" → justificar classificação
- "Histórico desse produto tende a [X]" → quando há padrão relevante
