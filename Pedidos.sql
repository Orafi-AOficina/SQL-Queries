SELECT
    A.empdopnums                        AS CHAVE_PEDIDO,
    A.emps                              AS EMPRESA,
    A.mascnum                           AS NUM_PEDIDO,
    A.dopes                             AS TIPO_PEDIDO,
    A.datas                             AS DT_ENTRADA,
    A.prazoents                         AS PRAZO_ENTREGA,
    A.compet                            AS MES_COMPETENCIA,
    A.nops                              AS OP_MAE,
    B.iclis                             AS COD_CLIENTE,
    B.rclis                             AS CLIENTE,
    CAST(A.obses AS NVARCHAR(MAX))      AS OBSERVACAO,

    -- Status do pedido baseado nas OPs vinculadas
    CASE
        WHEN EXISTS (
            SELECT 1 FROM SigOpPic OP (NOLOCK)
            WHERE OP.empdopnums = A.empdopnums
              AND OP.nopmaes = 0
              AND OP.nops IN (
                  SELECT DISTINCT nops FROM SigPdMvf (NOLOCK)
                  WHERE dopps IN ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')
              )
        ) THEN 'FINALIZADO'
        WHEN EXISTS (
            SELECT 1 FROM SigOpPic OP (NOLOCK)
            WHERE OP.empdopnums = A.empdopnums
              AND OP.nopmaes = 0
              AND OP.nops IN (
                  SELECT DISTINCT nops FROM SigPdMvf (NOLOCK)
                  WHERE dopps IN ('FINALIZA S INDUSTRIA')
              )
        ) THEN 'CANCELADO'
        ELSE 'PENDENTE'
    END                                 AS STATUS

FROM SigMvCab A (NOLOCK)
INNER JOIN SigCdCli B (NOLOCK) ON A.contads = B.iclis

WHERE A.dopes IN (
    'PEDIDO DE ENCOMENDA',
    'PEDIDO DE FABRICA',
    'PEDIDO DE PILOTO',
    'PEDIDO ENCOMENDA',
    'PEDIDO FABRICA',
    'PEDIDO PILOTO',
    'PEDIDO DE ACRESC',
    'PED ACRESC PRODUCAO',
    'ENTRADA CONSERTO'
)
-- AND A.datas >= '2020-01-01'   -- filtrar por período se necessário
-- AND B.rclis LIKE '%CLIENTE%'  -- filtrar por cliente se necessário
-- AND A.emps = 'RNG'            -- filtrar por empresa se necessário

ORDER BY A.datas DESC, A.mascnum
