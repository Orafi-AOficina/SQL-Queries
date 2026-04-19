# Queries Base — Status de Pedido

Todas com `WITH (NOLOCK)`. Banco `DB_ORF`. Conexão via `sqlcmd -S 10.10.0.5 -U svc_reader -P $env:SQL_PASS -d DB_ORF -Q "..."`.

**Importante**: sempre tratar `ORF → ORA` no SELECT. Sempre filtrar transações >= 2023-01-01.

---

## 1. Resolver Identificador

### Por número de pedido (PEDIDO)
```sql
SELECT TOP 20
    CASE WHEN EMP = 'ORF' THEN 'ORA' ELSE EMP END AS EMPRESA,
    CHAVE_PEDIDO,
    CLIENTE,
    [TIPO PEDIDO],
    DATA_ENTRADA,
    PRAZO,
    PEDIDO,
    PEDIDO_CLIENTE
FROM Vw_PowerBI_tblPedidos WITH (NOLOCK)
WHERE PEDIDO LIKE '%<NUM>%'
   OR PEDIDO_CLIENTE LIKE '%<NUM>%'
ORDER BY DATA_ENTRADA DESC;
```

### Por cliente (últimos N pedidos em curso)

**Importante**: consultar `glossario-comercial.md` → seção Clientes/Aliases. Um mesmo cliente aparece com vários nomes no cadastro. Ex: Animale = `INSUMOS ANIMALE` OU `CIDADE MARAVILHOSA`.

```sql
SELECT TOP 50
    LTRIM(RTRIM(CLIENTE)) AS CLIENTE, OP, [TIPO DE PEDIDO], PRAZO, QTD,
    LTRIM(RTRIM(LOCAL)) AS LOCAL,
    [ULTIMA MOV.], ATIVIDADE, [DESC PRODUTO], REF_CLIENTE
FROM Vw_StatusOPsPendentes WITH (NOLOCK)
WHERE CLIENTE LIKE '%<ALIAS_1>%'
   OR CLIENTE LIKE '%<ALIAS_2>%'
ORDER BY PRAZO ASC;
```

### Por ref do cliente (quando cliente fala "o 1234-A")
```sql
SELECT TOP 20 OP, CLIENTE, REF_CLIENTE, [DESC PRODUTO], QTD, PRAZO, LOCAL
FROM Vw_StatusOPsPendentes WITH (NOLOCK)
WHERE REF_CLIENTE LIKE '%<REF>%';
```

### Quando ambíguo — pedir esclarecimento
Se `COUNT(*) > 3` no resultado, apresentar uma lista curta com Cliente + Pedido + Data Entrada + Qtd e perguntar: "Encontrei N possibilidades. Qual você quer?"

---

## 2. Status Consolidado (fonte principal)

```sql
SELECT
    EMPRESA, CLIENTE, [TIPO DE PEDIDO], PEDIDO, OP, OP_MAE,
    [DESC PRODUTO], REF_CLIENTE, COR, QTD,
    LOCAL, [ULTIMA MOV.], ATIVIDADE, [CÓD_CONTA],
    DATA_ENTRADA = [DATA ENTRADA], PRAZO, OBSERVACAO
FROM Vw_StatusOPsPendentes WITH (NOLOCK)
WHERE OP IN (<lista_ops>)
   OR PEDIDO = '<pedido>';
```

**Regra**: se o campo `PEDIDO` vier vazio, a OP pode estar fora de pedido (estoque). Sinalizar isso.

---

## 3. Linha do Tempo de uma OP

Quando precisar entender "quanto tempo ficou em cada setor", consultar `fMovimentacao` via query direta em `SigMvCab` + `SigCdNec`:

```sql
-- Alternativa rápida: usar Vw_PowerBI_tblOPs + SigMvCab para sequência
SELECT
    m.emps AS EMPRESA,
    m.nops AS OP,
    m.dtes AS DATA,
    m.horas AS HORA,
    m.contaos AS CONTA_ORIGEM,
    m.contads AS CONTA_DESTINO,
    m.dpros AS OPERACAO,
    m.cidchaves AS SEQ
FROM SigMvCab m WITH (NOLOCK)
WHERE m.nops = '<OP>'
  AND m.emps IN ('RNG','ORA','ORF')
  AND m.dtes >= '2023-01-01'
ORDER BY m.cidchaves ASC;
```

**Traduzir na saída**: para cada linha, converter `contads` via `tblContas` ou já-conhecido mapeamento de grupos (FUNDICAO, OURIVESARI, CRAVAÇÃO, POLIMENTO, SEP).

---

## 4. Tempo Médio por Setor (histórico)

Para projetar previsão e classificar risco, comparar tempo atual no setor vs. histórico do mesmo produto.

```sql
-- Tempo médio (dias) que produtos do mesmo grupo ficaram em cada setor
-- Rodar uma vez e cachear mentalmente durante a sessão
WITH mov_sequenciada AS (
    SELECT
        m.nops,
        p.grpros AS GRP_PRODUTO,
        m.contads AS SETOR,
        m.dtes AS DATA_ENTRADA_SETOR,
        LEAD(m.dtes) OVER (PARTITION BY m.nops ORDER BY m.cidchaves) AS DATA_SAIDA_SETOR
    FROM SigMvCab m WITH (NOLOCK)
    JOIN SigOpPic op WITH (NOLOCK) ON op.nops = m.nops AND op.emps = m.emps
    JOIN SigCdPro p WITH (NOLOCK) ON p.cpros = op.cpros
    WHERE m.dtes >= '2023-01-01'
)
SELECT
    GRP_PRODUTO, SETOR,
    AVG(DATEDIFF(DAY, DATA_ENTRADA_SETOR, DATA_SAIDA_SETOR)) AS DIAS_MEDIO,
    COUNT(*) AS N
FROM mov_sequenciada
WHERE DATA_SAIDA_SETOR IS NOT NULL
  AND DATA_SAIDA_SETOR >= DATA_ENTRADA_SETOR
GROUP BY GRP_PRODUTO, SETOR
HAVING COUNT(*) >= 10;
```

**Nota**: essa query é pesada. Rodar uma vez e aplicar mentalmente; ou limitar por `GRP_PRODUTO = '<grupo>'` específico do pedido analisado.

---

## 5. Agregado: Pedidos em Risco por Cliente

```sql
SELECT
    CLIENTE, PEDIDO, OP, [DESC PRODUTO], QTD, PRAZO, LOCAL,
    DATEDIFF(DAY, GETDATE(), PRAZO) AS DIAS_RESTANTES
FROM Vw_StatusOPsPendentes WITH (NOLOCK)
WHERE CLIENTE LIKE '%<NOME>%'
  AND (
       DATEDIFF(DAY, GETDATE(), PRAZO) <= 7           -- vence em 7 dias
    OR DATEDIFF(DAY, GETDATE(), PRAZO) < 0            -- já atrasado
  )
ORDER BY PRAZO ASC;
```

---

## 6. Insumos Faltando para um Pedido

Se o usuário pergunta "por que não está andando?", checar se tem insumo faltando:

```sql
SELECT GRANDE_GRP, GRP_COMP, DESC_COMP,
       QTD1_TOTAL, QTD1_PROD,
       (QTD1_TOTAL - QTD1_PROD) AS FALTA,
       CLASS_INSUMO = [CLASS. INSUMO]
FROM Vw_ComposicaoOPsPendentes WITH (NOLOCK)
WHERE OP_ORIGINAL = '<OP>'
  AND (QTD1_TOTAL - QTD1_PROD) > 0;
```

---

## Padrão de Execução

1. Tentar sempre a view consolidada primeiro (`Vw_StatusOPsPendentes`) — cobre 80% dos casos.
2. Descer para `SigMvCab` / `fMovimentacao` só quando precisar de linha do tempo ou histórico.
3. Nunca rodar query sem filtro (retornaria milhões de linhas). Sempre filtrar por OP, cliente, pedido ou período específico.
4. Testar com `TOP 10` se tiver dúvida sobre volume.
5. Se query falhar por VPN, rodar `ensure_vpn()` e tentar de novo.
