-- ============================================================
-- Movimentações v2 — Refatoração de performance
-- Autoria: Claude Code | Data: 2026-03-28
--
-- Principais mudanças em relação à v1:
--   1. CTE ORF_ORA    → substitui subquery inline do JOIN D
--   2. CTE MOV_AGG    → substitui subquery inline do JOIN B (mesma lógica, declarada uma vez)
--   3. CTE MOV_STATS  → window functions que eliminam 11 subqueries correlatas de contagem
--      As 11 subqueries rodavam por linha — agora são calculadas em 1 única varredura do SigPdMvf
--   4. JOIN F (SigCdPro) removido — estava na query original mas nunca era usado no SELECT
--   5. Lógica idêntica à original — resultados devem ser byte-a-byte iguais
-- ============================================================

WITH

-- Mapeamento legado: chaves ORF que não têm mais registro em SigCdNec (migradas para ORA)
ORF_ORA AS (
    SELECT DISTINCT
        aa.empdnps                          AS ANTIGA,
        REPLACE(aa.empdnps, 'ORF', 'ORA')  AS NOVA
    FROM SigCdNei aa (NOLOCK)
    LEFT JOIN SigCdNec bb (NOLOCK) ON aa.empdnps = bb.empdnps
    WHERE bb.emps IS NULL
),

-- Pré-agregação de SigPdMvf (equivalente ao subquery B da query original)
MOV_AGG AS (
    SELECT
        nops, codpds, empdnps, dopps,
        MIN(datas)                      AS datas,
        MIN(CAST(cidchaves AS BIGINT))  AS cidchaves,
        MIN(datars)                     AS datars
    FROM SigPdMvf (NOLOCK)
    GROUP BY nops, codpds, empdnps, dopps
),

-- Estatísticas pré-calculadas por (nops, cidchaves) usando window functions
-- Substitui as 11 subqueries correlatas que contavam linhas do SigPdMvf por linha
-- RANGE (vs ROWS) garante que cidchaves empatados recebam o mesmo valor — compatível com os COUNT originais
MOV_STATS AS (
    SELECT DISTINCT
        nops,
        CAST(cidchaves AS BIGINT)   AS cidchaves,

        -- Linhas do mesmo nops com cidchaves <= atual (equivale ao subquery cnt_up_to original)
        COUNT(*) OVER (
            PARTITION BY nops
            ORDER BY CAST(cidchaves AS BIGINT)
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )   AS cnt_up_to_incl,

        -- Linhas do mesmo nops com cidchaves = atual
        COUNT(*) OVER (
            PARTITION BY nops, cidchaves
        )   AS cnt_at,

        -- Linhas do mesmo nops com cidchaves >= atual (equivale ao subquery cnt_from original)
        COUNT(*) OVER (
            PARTITION BY nops
            ORDER BY CAST(cidchaves AS BIGINT)
            RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
        )   AS cnt_from_incl,

        -- Finalizações do mesmo nops com cidchaves <= atual (inclusive)
        SUM(CASE WHEN dopps LIKE 'FINALIZA%' THEN 1 ELSE 0 END) OVER (
            PARTITION BY nops
            ORDER BY CAST(cidchaves AS BIGINT)
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )   AS finaliza_up_to_incl,

        -- Finalizações do mesmo nops com cidchaves = atual (para calcular "estritamente antes")
        SUM(CASE WHEN dopps LIKE 'FINALIZA%' THEN 1 ELSE 0 END) OVER (
            PARTITION BY nops, cidchaves
        )   AS finaliza_at

    FROM SigPdMvf (NOLOCK)
)

SELECT DISTINCT
    RTRIM(A.emps)           AS EMPRESA,
    RTRIM(A.empdnps)        AS CHAVE_OPERACAO,
    A.numps                 AS NUM_OPER,

    CASE
        WHEN A.dopps = 'TRABALHADOS S/ OP' THEN FORMAT(A.datas,  'yyyy-MM-dd HH:mm')
        WHEN B.datas > '01-01-2000'         THEN FORMAT(B.datas,  'yyyy-MM-dd HH:mm')
        ELSE                                     FORMAT(A.datas,  'yyyy-MM-dd HH:mm')
    END AS DATA_HORA,

    CASE
        WHEN A.dopps = 'TRABALHADOS S/ OP' THEN FORMAT(A.datars, 'yyyy-MM-dd HH:mm')
        WHEN B.datas > '01-01-2000'         THEN FORMAT(B.datars, 'yyyy-MM-dd HH:mm')
        ELSE                                     FORMAT(A.datars, 'yyyy-MM-dd HH:mm')
    END AS DATA_HORA_INICIO_OPERACAO,

    RTRIM(A.dopps) AS TIPO_OPERACAO,

    CASE
        WHEN C.tpops IS NULL OR C.tpops = '' THEN RTRIM(A.dopps)   -- simplificado (mesmo resultado)
        WHEN A.dopps = 'DIVISAO DE OP'        THEN RTRIM(A.dopps)
        ELSE                                       RTRIM(C.tpops)
    END AS OPERACAO,

    CASE
        WHEN A.dopps = 'TRABALHADOS S/ OP'                                               THEN 0
        WHEN A.dopps IN ('MUDA SETOR C ESTOQ','INDUSTRIALIZAÇÃO','FINALIZA S INDUSTRIA') THEN B.nops
        ELSE ISNULL(C.nops, 0)
    END AS OP,

    CASE
        WHEN A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(C.nops, 0) = 0 THEN 0
        ELSE (
            SELECT MIN(a2.qtds) FROM SigPdMvf (NOLOCK) a2
            WHERE a2.nops = B.nops
              AND a2.datars <= B.datars
              AND a2.dopps IN ('DIVISAO DE OP','INDUSTRIALIZAÇÃO')
        )
    END AS QTD_OP,

    CASE WHEN ISNULL(C.nops, 0) = 0 THEN '' ELSE RTRIM(B.codpds) END AS COD_PRODUTO,

    RTRIM(A.grupoos)  AS GRP_CONTA_ORI,
    RTRIM(A.contaos)  AS COD_CONTA_ORI,
    RTRIM(E.rclis)    AS NOME_CONTA_ORI,
    RTRIM(A.grupods)  AS GRP_CONTA_DEST,
    RTRIM(A.contads)  AS COD_CONTA_DEST,
    RTRIM(G.rclis)    AS NOME_CONTA_DEST,

    A.totpesos AS PESO_TOTAL,

    CONCAT(
        CASE
            WHEN A.dopps = 'TRABALHADOS S/ OP'
                THEN CASE WHEN LEN(RTRIM(A.docus)) = 8 THEN CONCAT(CAST(RTRIM(A.docus) AS INT), '_') END
            ELSE ''
        END,
        CAST(A.obss AS varchar(max))
    ) AS OBSERVAÇÃO,

    CASE WHEN A.emps = 'ORA' AND A.datas <= '01-09-2025' AND A.numbals  > 1000 THEN 'ORF' ELSE RTRIM(A.emps) END
        + '_' + CAST(A.numbals  AS varchar) AS BALANÇO,
    CASE WHEN A.emps = 'ORA' AND A.datas <= '01-09-2025' AND A.numbalds > 1000 THEN 'ORF' ELSE RTRIM(A.emps) END
        + '_' + CAST(A.numbalds AS varchar) AS BALANÇO_DEST,

    A.usuars AS USUARIO,

    CASE
        WHEN A.dopps = 'TRABALHADOS S/ OP' THEN REPLACE(A.empdnps, ' ', '')
        ELSE                                     REPLACE(A.empdnps, ' ', '')
    END AS CHAVE_FINALIZACAO,

    -- ULT_MOVIMENTACAO: 3 subqueries correlatas → lookup no CTE MOV_STATS
    CASE
        WHEN S.finaliza_at    = 1 THEN 'VERDADEIRO'     -- esta linha É uma finalização
        WHEN (S.finaliza_up_to_incl - S.finaliza_at) > 0 THEN 'FALSO'  -- há finalização anterior
        WHEN S.cnt_from_incl  = 1 THEN 'VERDADEIRO'     -- é o último registro da OP
        ELSE 'FALSO'
    END AS ULT_MOVIMENTACAO,

    -- SEQ_MOVIMENTACAO: 4 subqueries correlatas → cálculo via CTE MOV_STATS
    -- Equivalência: (cnt_up_to - cnt_at + 1) + finaliza_ajuste - finaliza_before
    CASE
        WHEN A.dopps = 'INDUSTRIALIZAÇÃO' OR A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(C.nops, 0) = 0
            THEN 1
        ELSE
            (S.cnt_up_to_incl - S.cnt_at)   -- linhas estritamente antes
            + 1                              -- posição corrente
            + CASE WHEN A.dopps LIKE 'FINALIZA%'
                   THEN S.cnt_from_incl - S.cnt_at  -- linhas após (só somadas se A é finalização)
                   ELSE 0 END
            - (S.finaliza_up_to_incl - S.finaliza_at)  -- finaliza_before (estritamente antes)
    END AS SEQ_MOVIMENTACAO,

    -- SEQ_MOVIMENTACAO_ANTERIOR: idêntico ao SEQ_MOVIMENTACAO mas sem o +1
    CASE
        WHEN A.dopps = 'INDUSTRIALIZAÇÃO' OR A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(C.nops, 0) = 0
            THEN 0
        ELSE
            (S.cnt_up_to_incl - S.cnt_at)
            + CASE WHEN A.dopps LIKE 'FINALIZA%'
                   THEN S.cnt_from_incl - S.cnt_at
                   ELSE 0 END
            - (S.finaliza_up_to_incl - S.finaliza_at)
    END AS SEQ_MOVIMENTACAO_ANTERIOR,

    CASE WHEN ISNULL(C.nops, 0) = 0 THEN 0 ELSE B.cidchaves END AS [INDEX]

FROM SigCdNec A (NOLOCK)
    LEFT JOIN ORF_ORA D
        ON A.empdnps = D.NOVA
    LEFT JOIN MOV_AGG B
        ON A.empdnps = B.empdnps OR D.ANTIGA = B.empdnps
    LEFT JOIN (
        SELECT DISTINCT tpops, dopps, emps, nops, numps, empdnps, cidchaves
        FROM SigCdNei (NOLOCK)
    ) C
        ON  (C.empdnps = B.empdnps AND C.nops = B.nops)
        OR  (ISNULL(C.nops, -1) = -1 AND (A.empdnps = C.empdnps OR C.empdnps = D.ANTIGA))
        OR  (C.empdnps = A.empdnps AND A.dopps = 'TRABALHADOS S/ OP')
    LEFT JOIN MOV_STATS S
        ON S.nops = B.nops AND S.cidchaves = B.cidchaves
    LEFT JOIN SIGCDCLI E (NOLOCK)
        ON A.contaos = E.iclis
    LEFT JOIN SIGCDCLI G (NOLOCK)
        ON A.contads = G.iclis

WHERE A.datas >= '01-01-2023'