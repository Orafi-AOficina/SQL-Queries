# Interpretação de Status — Risco e Previsão

Regras explícitas para não "sentir" o risco — sempre derivar de número.

## Classificação de Risco (por OP / por pedido)

Para cada OP ativa, calcular dois sinais:

### Sinal 1 — Prazo vs. Dias Restantes

| Situação | Sinal |
|----------|-------|
| Prazo já passou | 🔴 Vermelho |
| Faltam 0-3 dias e ainda falta etapa que leva >3 dias em média | 🔴 Vermelho |
| Faltam 4-7 dias e etapas restantes somam > dias restantes | 🟡 Amarelo |
| Faltam 4-7 dias e etapas restantes somam ≤ dias restantes | 🟢 Verde |
| Faltam >7 dias e fluxo normal | 🟢 Verde |

### Sinal 2 — Tempo no Setor Atual vs. Média Histórica

Se tempo no setor atual for:

| Razão sobre média | Sinal |
|-------------------|-------|
| ≤ 100% (dentro do normal) | 🟢 Verde |
| 101-150% | 🟢 Verde com observação |
| 151-200% | 🟡 Amarelo |
| > 200% | 🔴 Vermelho |
| > 400% ou > 15 dias parada | 🔴 Vermelho + marcar "parada" |

### Risco Final

- Pegar o **pior** dos dois sinais.
- Justificativa SEMPRE cita o número: "5 dias em cravação (média do grupo: 3 dias)" ou "prazo em 2 dias e ainda faltam polimento + expedição (histórico: 4 dias)".

## Classificação para Conjunto de OPs (mesmo pedido)

Se o pedido tem N OPs:

| Distribuição | Sinal do pedido |
|--------------|-----------------|
| Todas 🟢 | 🟢 Verde |
| ≥1 🟡 e nenhuma 🔴 | 🟡 Amarelo |
| ≥1 🔴 | 🔴 Vermelho |
| ≥30% das OPs 🔴 | 🔴 Crítico (mencionar explicitamente) |

Na resposta: mencionar quantas peças estão em cada categoria — não só o pior caso.

## Previsão de Entrega

Fluxo padrão de setores (onde ainda não passou, contar):

```
FUNDIÇÃO → OURIVESARIA → CRAVAÇÃO → POLIMENTO → FINALIZAÇÃO → EXPEDIÇÃO
```

### Algoritmo

1. Identificar setor atual (campo `LOCAL` em `Vw_StatusOPsPendentes`).
2. Listar setores pendentes (posteriores ao atual no fluxo padrão).
3. Somar tempo médio (histórico do grupo de produto) de cada setor pendente.
4. Adicionar tempo estimado RESTANTE no setor atual:
   - Se tempo atual < média: `média - tempo_atual`
   - Se tempo atual ≥ média: assumir 50% da média como restante (sinal de atraso no setor)
5. Resultado é **faixa** (ex: "8 a 11 dias"), não ponto — incerteza é honesta.

### Ajustes

- Produto não tem histórico suficiente (grupo com <10 amostras): dar faixa larga e avisar ("baseado em produtos similares, não neste específico").
- Pedido piloto: previsão sempre tem +50% de buffer.
- Se detectar insumo faltando: previsão fica "indefinida até entrada do insumo" — não chutar.

## Pontos de Atenção Proativos

Independente da pergunta, SE detectar:

- **OP parada** (>15 dias sem movimentação): mencionar.
- **Cliente com padrão** (muitos pedidos amarelo/vermelho simultaneamente): observar.
- **Insumo crítico faltando** (ouro, brilhante, pedra principal): avisar.
- **Etapa anômala** (ex: voltou de FINALIZAÇÃO para POLIMENTO — indica retrabalho): sinalizar.
- **OP sem pedido vinculado** (quando o usuário perguntou sobre pedido): flag — pode ser erro de digitação ou peça de estoque.

## Casos Limite

- **Sem movimentação registrada** (OP existe mas `fMovimentacao` vazia): "ainda não saiu do planejamento". Contar quantos dias desde `DATA_ENTRADA` e comparar com tempo médio que PCP demora pra liberar.
- **Última movimentação muito antiga** (>30 dias): provavelmente peça finalizada mas não baixada, ou cancelada sem flag. Marcar como "situação atípica — vale confirmar com produção".
- **OP com `QTD_PEND > QTD_TOTAL`**: inconsistência de dados, avisar a Rafael (não tentar interpretar).
