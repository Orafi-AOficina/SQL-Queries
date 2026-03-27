# 🏗️ Padrões SQL e Convenções de Código

**Versão:** 1.0  
**Data:** 27 de Fevereiro de 2026  
**Sistema:** SIGMATEC (ERP para Joalharia)  
**Banco de Dados:** SQL Server

---

## 📋 Índice

1. [Visão Geral de Padrões](#visão-geral-de-padrões)
2. [Padrão de Query Básica](#padrão-de-query-básica)
3. [Padrões de JOINs](#padrões-de-joins)
4. [Padrões de Lógica Condicional](#padrões-de-lógica-condicional)
5. [Padrões de Manipulação de String](#padrões-de-manipulação-de-string)
6. [Padrões de Conversão de Dados](#padrões-de-conversão-de-dados)
7. [Padrões de Agregação e GROUP BY](#padrões-de-agregação-e-group-by)
8. [Padrões Avançados](#padrões-avançados)
9. [Antipadrões a Evitar](#antipadrões-a-evitar)
10. [Checklist para Novas Queries](#checklist-para-novas-queries)
11. [Exemplos de Uso](#exemplos-de-uso)

---

## Visão Geral de Padrões

### Convenções Observadas no Repositório

✅ **Boas práticas encontradas:**
- Uso consistente de `WITH (NOLOCK)` em leituras
- Aliases descritivos para tabelas
- Nomes de campos em português com convenção de abreviatura
- Indentação com espaços (nem sempre consistente)
- Comentários explicativos antes de seções complexas

⚠️ **Inconsistências encontradas:**
- Variação em indentação (alguns 4 espaços, alguns 2, alguns nenhum)
- Mix de aspas simples vs nenhuma em aliases
- Alguns campos sem alias
- Comentários em português em alguns arquivos, ausentes em outros

---

## Padrão de Query Básica

### Estrutura Recomendada

```sql
-- ============================================
-- Nome: Nome_Descritivo_Query.sql
-- Descrição: O que esta query faz
-- Propósito: Para qual domínio/dashboard
-- Última atualização: YYYY-MM-DD
-- ============================================

SELECT
    A.[campo1],
    A.[campo2],
    B.[campo3],
    'Valor Constante' AS [descricao_campo]
FROM
    [NomeBD].[dbo].[SigMvCab] AS A WITH (NOLOCK)
    INNER JOIN [NomeBD].[dbo].[SigCdPro] AS B WITH (NOLOCK)
        ON A.[cpros] = B.[cpros]
WHERE
    A.[datas] >= '2026-01-01'
    AND A.[status] = 1
ORDER BY
    A.[datas] DESC,
    A.[numes] ASC;
```

### Convenções Específicas

#### 1. **WITH (NOLOCK)**
```sql
-- Sempre use WITH (NOLOCK) em queries de leitura/relatório
-- Evita locks desnecessários em tabelas maiores
-- Aceita dados em leitura sujo (pode haver transações não commitadas)
-- NÃO use se você estiver escrevendo (INSERT/UPDATE) ou precisa de consistência garantida

FROM SigMvCab WITH (NOLOCK)  ← CORRETO
FROM SigMvCab                 ← Também funciona, mas mais lento
```

#### 2. **Aliases de Tabela**
```sql
-- Use letras simples: A, B, C, D, ...
-- Facilita leitura e reduz digitação

FROM SigMvCab AS A
INNER JOIN SigCdPro AS B
INNER JOIN SigCdCli AS C
LEFT JOIN SigMvEst AS D
```

#### 3. **Campos entre Colchetes**
```sql
-- Colchetes [ ] são opcionais, mas recomendados se:
-- - Campo tem espaço: [data de criação]
-- - Campo é palavra reservada SQL: [status], [user]

SELECT [cpros], [dtata], [status] FROM SigCdPro  ← CORRETO
SELECT cpros, datas, status FROM SigCdPro        ← Também funciona
```

#### 4. **Aliases de Coluna (AS)**
```sql
-- Use AS explicitamente para clareza
-- Siga padrão de nomenclatura: MAIUSCULA_OU_PortuguesDescritivo

SELECT
    [cpros] AS 'Codigo Produto',
    [dpros] AS 'Descricao',
    [qtds] AS 'Quantidade Estoque'
```

---

## Padrões de JOINs

### INNER JOIN (Obrigatório)
```sql
-- Use quando o relacionamento é 1:1 ou há garantia de existência

SELECT
    A.[nopes] AS 'Numero Pedido',
    B.[dpros] AS 'Produto'
FROM
    SigMvCab AS A WITH (NOLOCK)
    INNER JOIN SigCdPro AS B WITH (NOLOCK)
        ON A.[cpros] = B.[cpros]
-- Resultado: Apenas pedidos com produto válido
```

### LEFT JOIN (Opcional)
```sql
-- Use quando quer manter todos os registros da tabela esquerda
-- Mesmo que a tabela direita não tenha correspondência

SELECT
    A.[nopes] AS 'Numero Pedido',
    ISNULL(B.[dpros], 'Produto Deletado') AS 'Produto'
FROM
    SigMvCab AS A WITH (NOLOCK)
    LEFT JOIN SigCdPro AS B WITH (NOLOCK)
        ON A.[cpros] = B.[cpros]
-- Resultado: Mesmo que não tenha produto no cadastro
```

### LEFT JOIN com WHERE (Cuidado!)
```sql
-- ❌ ERRADO - transforma LEFT em INNER
SELECT A.[nopes], B.[dpros]
FROM SigMvCab AS A WITH (NOLOCK)
LEFT JOIN SigCdPro AS B WITH (NOLOCK)
    ON A.[cpros] = B.[cpros]
WHERE B.[cpros] IS NOT NULL  ← Elimina NULLs, anulando o LEFT

-- ✅ CORRETO - mantém LEFT JOIN
SELECT A.[nopes], B.[dpros]
FROM SigMvCab AS A WITH (NOLOCK)
LEFT JOIN SigCdPro AS B WITH (NOLOCK)
    ON A.[cpros] = B.[cpros]
    AND B.[status] = 1  ← Filtro já no JOIN, não no WHERE
```

### Multiple JOINs (Padrão Arquivos Power BI)
```sql
-- Encadear JOINs em sequência lógica
-- Sempre on = relacionamento direto

SELECT
    A.[nopes],
    B.[dpros],
    C.[rclis],
    D.[estes]
FROM
    SigMvCab AS A WITH (NOLOCK)
    INNER JOIN SigCdPro AS B WITH (NOLOCK)
        ON A.[cpros] = B.[cpros]
    LEFT JOIN SigCdCli AS C WITH (NOLOCK)
        ON A.[contads] = C.[iclis]
    LEFT JOIN SigMvEst AS D WITH (NOLOCK)
        ON B.[cpros] = D.[cpros]
        AND C.[iclis] = D.[conta]
```

### Self-Join (Hierarquias)
```sql
-- Usado para OPs mãe/filha ou categorias aninhadas
-- Padrão em OPs Geradas.sql

SELECT
    parent.[nops] AS 'OP Pai',
    child.[nops] AS 'OP Filha',
    child.[nopmaes] AS 'Referencia Pai'
FROM
    SigOpPic AS parent WITH (NOLOCK)
    INNER JOIN SigOpPic AS child WITH (NOLOCK)
        ON parent.[nops] = child.[nopmaes]
WHERE
    parent.[nops] = 'OP001500'  -- Achar todas as filhas de OP001500
```

---

## Padrões de Lógica Condicional

### CASE WHEN Simples
```sql
-- Use para categorizar valores

SELECT
    [nopes],
    CASE
        WHEN [status] = 0 THEN 'Aberta'
        WHEN [status] = 1 THEN 'Em Progresso'
        WHEN [status] = 2 THEN 'Finalizada'
        WHEN [status] = 3 THEN 'Cancelada'
        ELSE 'Desconhecido'
    END AS 'Status Nome'
FROM SigMvCab
```

### CASE WHEN com Lógica Complexa
```sql
-- Use para decisões com múltiplas condições

SELECT
    [nopes],
    CASE
        WHEN [datas] < DATEADD(DAY, -30, GETDATE()) AND [status] = 0
            THEN 'ATRASADO'
        WHEN [datas] >= DATEADD(DAY, -30, GETDATE()) AND [status] = 0
            THEN 'NO_PRAZO'
        WHEN [status] IN (1, 2)
            THEN 'EM_PROGRESSO'
        ELSE 'FINALIZADO'
    END AS 'Classificacao'
FROM SigMvCab
```

### CASE WHEN em ORDER BY
```sql
-- Use para ordenar por lógica customizada

SELECT [nopes], [status]
FROM SigMvCab
ORDER BY
    CASE [status]
        WHEN 0 THEN 1  -- Abertas primeiro
        WHEN 1 THEN 2  -- Depois em progresso
        WHEN 2 THEN 3  -- Depois finalizada
        ELSE 4         -- Canceladas por último
    END,
    [datas] DESC
```

### CASE WHEN Nested (Aninhado)
```sql
-- Aceitar só em casos complexos; considerar CTE alternativamente

SELECT
    [nopes],
    CASE
        WHEN [valor] > 10000
            THEN CASE
                WHEN [prioridade] = 1 THEN 'VIP_ALTA'
                ELSE 'VIP_NORMAL'
            END
        ELSE 'REGULAR'
    END AS 'Categoria'
FROM SigMvCab
```

---

## Padrões de Manipulação de String

### Limpeza de Strings
```sql
-- Remover espaços em branco início/fim

SELECT
    LTRIM(RTRIM([dpros])) AS 'Descricao Limpa'
FROM SigCdPro
```

### Concatenação
```sql
-- Combinar múltiplos campos

SELECT
    [dpros] + ' (' + [codcors] + ')' AS 'Descricao Completa'
FROM SigCdPro

-- OU (SQL Server 2012+)
SELECT
    CONCAT([dpros], ' (', [codcors], ')') AS 'Descricao Completa'
FROM SigCdPro

-- OU (SQL Server 2017+, mais limpo)
SELECT
    STRING_CONCAT([dpros], ' (', [codcors], ')') AS 'Descricao Completa'
FROM SigCdPro
```

### Extração de Substring
```sql
-- Pegar parte de uma string

SELECT
    SUBSTRING([cpros], 1, 3) AS 'Primeiro 3 Caracteres'
FROM SigCdPro

-- Exemplo: "ANEL001" → "ANE"
```

### Busca de Posição (CHARINDEX)
```sql
-- Encontrar posição de um caractere

SELECT
    [cpros],
    CHARINDEX('-', [cpros]) AS 'Posicao Hifen'
FROM SigCdPro WHERE CHARINDEX('-', [cpros]) > 0
```

### Substituição (REPLACE)
```sql
-- Substituir padrão por outro

SELECT
    REPLACE([dpros], 'Ouro', 'AU') AS 'Descricao Simplificada'
FROM SigCdPro
```

### Conversão de Maiúscula/Minúscula
```sql
SELECT
    UPPER([dpros]) AS 'Maiuscula',
    LOWER([dpros]) AS 'Minuscula',
    [dpros] AS 'Original'
FROM SigCdPro
```

---

## Padrões de Conversão de Dados

### CAST vs CONVERT
```sql
-- CAST (padrão SQL, mais portável)
SELECT CAST([datas] AS VARCHAR(10)) AS 'Data Texto'
SELECT CAST([qtds] AS INTEGER) AS 'Quantidade Inteiro'

-- CONVERT (SQL Server específico, mais flexível em formato)
SELECT CONVERT(VARCHAR(10), [datas], 103) AS 'Data DD/MM/YYYY'  ← 103 é o formato
SELECT CONVERT(DECIMAL(10,2), [qtds]) AS 'Quantidade 2 casas'

-- Formatos comuns CONVERT:
-- 103 = DD/MM/YYYY
-- 120 = YYYY-MM-DD HH:MM:SS (ISO 8601)
-- 121 = YYYY-MM-DD HH:MM:SS.mmm
```

### Conversão de Data
```sql
-- De DATETIME para DATE (remove hora)
SELECT CAST([datas] AS DATE) AS 'So Data'

-- De DATE para DATETIME
SELECT CAST([data_pedido] AS DATETIME)

-- Formato legível
SELECT FORMAT([datas], 'dd/MM/yyyy HH:mm:ss') AS 'Data Formatada'
```

### Conversão de Número
```sql
-- Para inteiro (trunca decimais)
SELECT CAST([qtds] AS INTEGER)

-- Para decimal com casas definidas
SELECT CAST([valor] AS DECIMAL(15, 2))

-- String para número (cuidado com formatos!)
SELECT CAST('123.45' AS DECIMAL(10,2))  ← Usado separador. (ponto)
```

### ISNULL (Substituir NULL)
```sql
-- Se valor é NULL, retorna alternativa

SELECT
    ISNULL([dpros], 'Produto Desconhecido') AS 'Descricao'
FROM SigCdPro

-- Exemplo: Se [dpros] é NULL, mostra 'Produto Desconhecido'
```

### NULLIF (Convertar Valor para NULL)
```sql
-- Se duas expressões são iguais, retorna NULL

SELECT
    NULLIF([valor], 0) AS 'Valor (sem zeros)'
FROM SigMvCab

-- Exemplo: Se [valor] = 0, mostra NULL
```

---

## Padrões de Agregação e GROUP BY

### SUM, COUNT, AVG, MIN, MAX
```sql
-- Agregações básicas

SELECT
    [cpros],
    COUNT(*) AS 'Total Movimentacoes',
    SUM([qtds]) AS 'Quantidade Total',
    AVG([totas]) AS 'Valor Medio',
    MIN([datas]) AS 'Primeira Data',
    MAX([datas]) AS 'Ultima Data'
FROM SigMvCab WITH (NOLOCK)
GROUP BY [cpros]
```

### GROUP BY com Múltiplos Campos
```sql
-- Agregar por múltiplas dimensões

SELECT
    A.[contads],
    A.[cpros],
    B.[ddros],
    COUNT(*) AS 'Total Operacoes',
    SUM([qtds]) AS 'Quantidade'
FROM
    SigMvCab AS A WITH (NOLOCK)
    INNER JOIN SigCdPro AS B WITH (NOLOCK)
        ON A.[cpros] = B.[cpros]
GROUP BY
    A.[contads],
    A.[cpros],
    B.[dpros]  -- Always include in GROUP BY if in SELECT
```

### HAVING (Filtro em Agregação)
```sql
-- Usar WHERE para filtrar ANTES da agregação
-- Usar HAVING para filtrar DEPOIS da agregação

SELECT
    [cpros],
    COUNT(*) AS 'Total'
FROM SigMvCab WITH (NOLOCK)
WHERE [datas] >= '2026-01-01'  ← Filtro ANTES
GROUP BY [cpros]
HAVING COUNT(*) > 10           ← Filtro DEPOIS (apenas grupos com 10+ ops)
```

### Agregação com ISNULL
```sql
-- Tratar NULL em agregações

SELECT
    [cpros],
    COUNT(*) AS 'Total',
    SUM(ISNULL([qtds], 0)) AS 'Quantidade Total Segura'
FROM SigMvCab
GROUP BY [cpros]
```

---

## Padrões Avançados

### PIVOT (Conversão Linhas para Colunas)
```sql
-- Converter moedas de linhas para colunas (padrão em Pedidos.sql)

SELECT
    [nopes],
    ISNULL([USD], 0) AS 'Valor USD',
    ISNULL([AU], 0) AS 'Valor AU',
    ISNULL([BRL], 0) AS 'Valor BRL'
FROM
(
    SELECT [nopes], [moeda], [valor]
    FROM SigMvCab
    WHERE [datas] >= '2026-01-01'
) AS origem
PIVOT
(
    SUM([valor])
    FOR [moeda] IN ([USD], [AU], [BRL])
) AS tabela_pivotada
```

### Subquery Correlacionada
```sql
-- Referenciar tabela externa dentro de subquery

SELECT
    A.[nopes],
    (
        SELECT COUNT(*)
        FROM SigMvItn AS B
        WHERE B.[empdopnums] = A.[empdopnums]
    ) AS 'Quantidade Itens'
FROM SigMvCab AS A

-- ⚠️ Cuidado com performance: Executa subquery para cada linha!
```

### CTE (Common Table Expression)
```sql
-- Tornar query mais legível (SQL Server 2005+)
-- ⚠️ Pouco usado no repositório, mas recomendado

WITH pedidos_recentes AS (
    SELECT [nopes], [cpros], [datas]
    FROM SigMvCab WITH (NOLOCK)
    WHERE [datas] >= DATEADD(DAY, -7, GETDATE())
)
SELECT
    PR.[nopes],
    PR.[cpros],
    P.[dpros]
FROM pedidos_recentes AS PR
INNER JOIN SigCdPro AS P WITH (NOLOCK)
    ON PR.[cpros] = P.[cpros]
ORDER BY PR.[datas] DESC
```

### CTE Recursiva (Hierarquias)
```sql
-- Alternativa mais legível para self-joins (atualmente OPs usa joins diretos)

WITH ops_hierarquia AS (
    -- Âncora: OPs sem pai (nível 0)
    SELECT [nops], [nopmaes], 0 AS 'nivel'
    FROM SigOpPic
    WHERE [nopmaes] IS NULL
    
    UNION ALL
    
    -- Recursão: OPs filhas
    SELECT child.[nops], child.[nopmaes], parent.'nivel' + 1
    FROM SigOpPic AS child
    INNER JOIN ops_hierarquia AS parent
        ON child.[nopmaes] = parent.[nops]
    WHERE parent.'nivel' < 8  -- Limitar profundidade para evitar loop infinito
)
SELECT * FROM ops_hierarquia
ORDER BY 'nivel', [nops]
```

---

## Antipadrões a Evitar

### ❌ SELECT *
```sql
-- EVITAR: Traz todas as colunas (desperdício de banda)
SELECT * FROM SigMvCab

-- FAZER: Especificar apenas colunas necessárias
SELECT [nopes], [datas], [cpros] FROM SigMvCab
```

### ❌ JOINs Sem Índice
```sql
-- EVITAR: JOIN em campo não indexado
FROM SigMvCab AS A
INNER JOIN SigCdPro AS B ON SUBSTRING(A.[cpros], 1, 3) = B.[cpros]

-- FAZER: JOIN direto no campo
FROM SigMvCab AS A
INNER JOIN SigCdPro AS B ON A.[cpros] = B.[cpros]
```

### ❌ OR em JOINs
```sql
-- EVITAR (difícil de otimizar):
INNER JOIN SigCdPro AS B
    ON A.[cpros] = B.[cpros] OR A.[codigo_alt] = B.[codigo_alt]

-- FAZER: Dois JOINs separados, depois UNION
SELECT ... FROM SigMvCab A
INNER JOIN SigCdPro B ON A.[cpros] = B.[cpros]
UNION ALL
SELECT ... FROM SigMvCab A
INNER JOIN SigCdPro B ON A.[codigo_alt] = B.[codigo_alt]
```

### ❌ LEFT JOIN com ISNULL na Condição
```sql
-- EVITAR (transforma LEFT em INNER):
SELECT A.[nopes], B.[dpros]
FROM SigMvCab AS A
LEFT JOIN SigCdPro AS B
    ON ISNULL(A.[cpros], '') = B.[cpros]

-- FAZER: Colocar ISNULL no SELECT, não no JOIN
SELECT A.[nopes], ISNULL(B.[dpros], 'Desconhecido')
FROM SigMvCab AS A
LEFT JOIN SigCdPro AS B
    ON A.[cpros] = B.[cpros]
```

### ❌ Lógica de Negócio em WHERE
```sql
-- EVITAR (mistura filtro com lógica):
SELECT [nopes], [status]
FROM SigMvCab
WHERE (([status] = 0 AND [datas] < '2026-01-01') OR [status] IN (1,2))

-- FAZER: Use CASE ou CTE para clareza
SELECT
    [nopes],
    CASE
        WHEN [status] = 0 AND [datas] < '2026-01-01' THEN 'ATRASADO'
        WHEN [status] IN (1,2) THEN 'PROGRESSO'
        ELSE 'FINALIZADO'
    END AS 'Classificacao'
FROM SigMvCab
WHERE [datas] >= '2025-01-01'
```

### ❌ Funções em WHERE/JOIN (evita índices)
```sql
-- EVITAR: Função em WHERE
WHERE YEAR([datas]) = 2026

-- FAZER: Range direto
WHERE [datas] >= '2026-01-01' AND [datas] < '2027-01-01'

-- EVITAR: Função em JOIN
ON UPPER(A.[cpros]) = UPPER(B.[cpros])

-- FAZER: Assumir consistência ou limpar na origem
ON A.[cpros] = B.[cpros]
```

---

## Checklist para Novas Queries

Use este checklist ao criar uma nova query:

- [ ] Cabeçalho com descrição, propósito, data
- [ ] Todas as tabelas com alias (A, B, C, ...)
- [ ] WITH (NOLOCK) em tabelas de leitura
- [ ] JOINs em sequência lógica
- [ ] Campos entre colchetes [campo]
- [ ] Aliases AS 'Nome Descritivo' em português
- [ ] ORDER BY para consistência
- [ ] WHERE sobre campos já indexados (não funções)
- [ ] ISNULL() para NULLs esperados
- [ ] Testes performance (CTRL+L para execution plan)
- [ ] Comentários em seções complexas
- [ ] Sem SELECT * (apenas campos necessários)
- [ ] Indentação consistente (4 espaços)

---

## Exemplos de Uso

### Exemplo 1: Query de Pedidos Atrasados

```sql
-- ============================================
-- Nome: Pedidos_Atrasados.sql
-- Descrição: Pedidos que passaram da data prevista
-- ============================================

SELECT
    A.[nopes] AS 'Numero Pedido',
    A.[datas] AS 'Data Criacao',
    B.[rclis] AS 'Cliente',
    C.[dpros] AS 'Produto',
    DATEDIFF(DAY, A.[datas], GETDATE()) AS 'Dias Em Aberto',
    CASE
        WHEN DATEDIFF(DAY, A.[datas], GETDATE()) > 30 THEN 'CRITICO'
        WHEN DATEDIFF(DAY, A.[datas], GETDATE()) > 15 THEN 'ATRASADO'
        ELSE 'OK'
    END AS 'Status Prazo'
FROM
    SigMvCab AS A WITH (NOLOCK)
    LEFT JOIN SigCdCli AS B WITH (NOLOCK)
        ON A.[contads] = B.[iclis]
    INNER JOIN SigCdPro AS C WITH (NOLOCK)
        ON A.[cpros] = C.[cpros]
WHERE
    A.[dopes] = 'PEDIDO_ENCOMENDA'
    AND A.[status] = 0  -- Aberto
    AND A.[datas] < DATEADD(DAY, -15, GETDATE())
ORDER BY
    DATEDIFF(DAY, A.[datas], GETDATE()) DESC
```

### Exemplo 2: Query de Estoque com Balanço

```sql
-- ============================================
-- Nome: Estoque_Posicao_Conta.sql
-- Descrição: Estoque atual por conta e insumo
-- ============================================

SELECT
    B.[iclis] AS 'Codigo Conta',
    B.[rclis] AS 'Nome Conta',
    A.[cpros] AS 'Codigo Insumo',
    C.[dpros] AS 'Descricao Insumo',
    A.[sqtds] AS 'Quantidade (g)',
    A.[estos] AS 'Valor Total',
    ISNULL(A.[spesos], 0) AS 'Peso Total (kg)',
    CASE
        WHEN A.[status_estoque] = 0 THEN 'Bloqueado'
        WHEN A.[status_estoque] = 1 THEN 'Disponível'
        ELSE 'Em Análise'
    END AS 'Status Estoque',
    A.[data_atualizacao] AS 'Ultima Atualizacao'
FROM
    SigMvEst AS A WITH (NOLOCK)
    INNER JOIN SigCdCli AS B WITH (NOLOCK)
        ON A.[conta] = B.[iclis]
    LEFT JOIN SigCdPro AS C WITH (NOLOCK)
        ON A.[cpros] = C.[cpros]
WHERE
    A.[status_estoque] IN (0, 1)
ORDER BY
    B.[rclis],
    A.[cpros]
```

### Exemplo 3: Query com PIVOT (Moedas)

```sql
-- ============================================
-- Nome: Pedidos_MultiMoeda.sql
-- Descrição: Pedidos com valores em múltiplas moedas
-- ============================================

SELECT
    [nopes] AS 'Numero Pedido',
    [datas] AS 'Data',
    ISNULL([BRL], 0) AS 'Valor BRL',
    ISNULL([USD], 0) AS 'Valor USD',
    ISNULL([AU], 0) AS 'Valor AU'
FROM
(
    SELECT
        A.[nopes],
        A.[datas],
        A.[moevs],
        SUM(A.[totas]) AS 'total'
    FROM
        SigMvItn AS A WITH (NOLOCK)
        INNER JOIN SigMvCab AS B WITH (NOLOCK)
            ON A.[empdopnums] = B.[empdopnums]
    WHERE
        B.[dopes] = 'PEDIDO_ENCOMENDA'
    GROUP BY
        A.[nopes],
        A.[datas],
        A.[moevs]
) AS origem
PIVOT
(
    SUM([total])
    FOR [moevs] IN ([BRL], [USD], [AU])
) AS tabela_pivotada
ORDER BY
    [datas] DESC
```

---

## 📝 Notas Finais

### Performance
- Queries no repositório priorizam **legibilidade** sobre otimização máxima
- Para queries usadas em dashboards rápidos, considerar **índices** nas colunas de JOIN e WHERE
- Use `CTRL+L` no SQL Server Management Studio para ver Execution Plan

### Manutenção
- Sempre atualizar comentário de "Última atualização" ao modificar query
- Documentar mudanças em CHANGELOG se afeta múltiplos dashboards
- Testar em DEV antes de mover para PROD

### Evolução
- Gradualmente converter cálculos complexos para **CTEs** (melhor para manutenção)
- Considerar **Views SQL** para queries reutilizadas
- Documentar **índices recomendados** em comentários

---

**Documento versão 1.0 - 27 de Fevereiro de 2026**  
*Para desenvolvimento de novas queries ou otimização de existentes, use este documento como referência.*
