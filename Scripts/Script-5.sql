WITH movimentacoes AS (
    SELECT 
        B.nops,
        B.codpds,
        B.empdnps,
        B.datas       AS data_mov,
        B.datars      AS datars_mov,
        B.cidchaves,
        B.dopps,
        A.emps,
        A.empdnps     AS chave_operacao,
        A.dopps       AS tipo_operacao_cab,
        A.numps       AS num_oper,
        A.grupoos,
        A.contaos,
        A.grupods,
        A.contads,
        A.totpesos,
        A.numbals,
        A.numbalds,
        A.usuars,
        A.datas       AS data_cab,
        A.datars      AS datars_cab,
        A.obss,
        A.docus,

        -- Resolve operação (mesma lógica do original)
        CASE
            WHEN C.tpops = '' OR C.tpops IS NULL THEN RTRIM(A.dopps)
            WHEN A.dopps = 'DIVISAO DE OP'           THEN RTRIM(A.dopps)
            ELSE RTRIM(C.tpops)
        END AS OPERACAO,

        -- Resolve OP
        CASE 
            WHEN A.dopps = 'TRABALHADOS S/ OP' THEN 0
            WHEN A.dopps IN ('MUDA SETOR C ESTOQ','INDUSTRIALIZAÇÃO','FINALIZA S INDUSTRIA') THEN B.nops
            ELSE ISNULL(C.nops, 0)
        END AS OP,

        -- Resolve data/hora correta
        CASE 
            WHEN A.dopps = 'TRABALHADOS S/ OP'       THEN A.datas
            WHEN B.datas > '20000101'                 THEN B.datas
            ELSE A.datas
        END AS DATA_HORA,

        -- Contas origem/destino (nomes)
        E.rclis AS NOME_CONTA_ORI,
        G.rclis AS NOME_CONTA_DEST,

        -- Produto
        F.cpros AS COD_PRODUTO,

        -- Balanço com tratamento ORF/ORA
        CASE WHEN A.emps = 'ORA' AND A.datas <= '20250901' AND A.numbals > 1000 
             THEN 'ORF' ELSE RTRIM(A.emps) 
        END + '_' + CAST(A.numbals AS varchar) AS BALANCO,

        CASE WHEN A.emps = 'ORA' AND A.datas <= '20250901' AND A.numbalds > 1000 
             THEN 'ORF' ELSE RTRIM(A.emps) 
        END + '_' + CAST(A.numbalds AS varchar) AS BALANCO_DEST,

        REPLACE(A.empdnps, ' ', '') AS CHAVE_FINALIZACAO,

        -- Window functions substituindo 12 subqueries correlacionadas
        ROW_NUMBER() OVER (
            PARTITION BY CASE 
                WHEN A.dopps = 'TRABALHADOS S/ OP' THEN 0
                WHEN A.dopps IN ('MUDA SETOR C ESTOQ','INDUSTRIALIZAÇÃO','FINALIZA S INDUSTRIA') THEN B.nops
                ELSE ISNULL(C.nops, 0)
            END
            ORDER BY B.cidchaves DESC
        ) AS rn_ultima,

        -- Contagem de finalizações da OP (pra manter compatibilidade)
        SUM(CASE WHEN B.dopps LIKE 'FINALIZA%' THEN 1 ELSE 0 END) OVER (
            PARTITION BY B.nops
        ) AS total_finalizacoes,

        -- Contagem de finalizações anteriores
        SUM(CASE WHEN B.dopps LIKE 'FINALIZA%' AND B.cidchaves < B.cidchaves THEN 1 ELSE 0 END) OVER (
            PARTITION BY B.nops
        ) AS finalizacoes_anteriores,

        -- Sequência da movimentação dentro da OP
        ROW_NUMBER() OVER (
            PARTITION BY B.nops 
            ORDER BY B.cidchaves ASC
        ) AS SEQ_MOVIMENTACAO,

        B.cidchaves AS [INDEX]

    FROM SigCdNec (NOLOCK) A
        LEFT JOIN (
            SELECT DISTINCT aa.empdnps AS ANTIGA, 
                   REPLACE(aa.empdnps, 'ORF', 'ORA') AS NOVA 
            FROM SigCdNei (NOLOCK) aa 
            LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps 
            WHERE bb.emps IS NULL
        ) D ON A.empdnps = D.NOVA

        LEFT JOIN (
            SELECT nops, codpds, empdnps, 
                   MIN(datas) AS datas, 
                   MIN(CAST(cidchaves AS BIGINT)) AS cidchaves, 
                   MIN(datars) AS datars, 
                   dopps
            FROM SigPdMvf (NOLOCK) 
            GROUP BY nops, codpds, empdnps, dopps
        ) B ON (A.empdnps = B.empdnps OR D.ANTIGA = B.empdnps)

        LEFT JOIN (
            SELECT DISTINCT tpops, dopps, emps, nops, numps, empdnps, cidchaves 
            FROM SigCdNei (NOLOCK)
        ) C ON (C.empdnps = B.empdnps AND C.nops = B.nops) 
            OR (ISNULL(C.nops, -1) = -1 AND (A.empdnps = C.empdnps OR C.empdnps = D.ANTIGA)) 
            OR (C.empdnps = A.empdnps AND A.dopps = 'TRABALHADOS S/ OP')

        LEFT JOIN SIGCDCLI E (NOLOCK) ON A.contaos = E.iclis
        LEFT JOIN SigCdPro F (NOLOCK) ON B.codpds = F.cpros
        LEFT JOIN SIGCDCLI G (NOLOCK) ON A.contads = G.iclis

    WHERE A.datas >= '20230101'
)
SELECT *
FROM movimentacoes
WHERE rn_ultima = 1
  AND OP > 0