--Itens dos Pedidos, versão revisada e atualizada
SELECT        TOP (100) PERCENT C.empdopnums AS CHAVE_PEDIDO, C.citens AS ITEM_PEDIDO, D.nops AS OP_MAE, RTRIM(E.reffs) AS REF_CLIENTE, RTRIM(E.cpros) AS COD_PRODUTO, E.dpros AS DESC_PRODUTO, E.codcors AS COR,
                         C.qtds AS QTD, RTRIM(CONVERT(varchar, A.numes) + C.cpros) AS CHAVE_ORCAMENTO, CAST(C.obs AS NVARCHAR(4000)) AS DETALHAMENTO_PEDIDO, CASE WHEN CHARINDEX('#', C.obs) = NULL THEN NULL 
                         WHEN CHARINDEX('#', C.obs) = 0 THEN NULL ELSE RTRIM(REPLACE(REPLACE(LEFT(RIGHT(CAST(C.OBS AS NVARCHAR(4000)), LEN(CAST(C.OBS AS NVARCHAR(4000))) - CHARINDEX('#', C.obs)), 5), ',', ''), '/', '')) 
                         END AS PEDIDO_ECOMMERCE, C.empdopnums + '_' + CAST(C.citens AS VARCHAR) AS CHAVE_ITEM_PEDIDO
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND C.cpros = D.cpros AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS E WITH (NOLOCK) ON C.cpros = E.cpros
WHERE        (A.datas >= '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.nopmaes = 0)
ORDER BY 'OP_MAE', 'ITEM_PEDIDO' DESC


--Itens dos Pedidos, versão original
SELECT        MIN(A.empdopnums) AS CHAVE_PEDIDO, D.nops AS OP_MAE, MIN(RTRIM(E.reffs)) AS REF_CLIENTE, MIN(E.cgrus) AS GRP_PRODUTO, MIN(RTRIM(B.cpros)) AS COD_PRODUTO, MIN(B.dpros) AS DESC_PRODUTO, 
                         MIN(E.codcors) AS COR,
                             (SELECT        SUM(qtds) AS Expr1
                               FROM            dbo.SigOpPic AS X WITH (NOLOCK)
                               WHERE        (numps = D.numps) AND (B.cpros = cpros)
                               GROUP BY numps) AS QTD, MIN(RTRIM(CONVERT(varchar, A.numes) + B.cpros)) AS CHAVE_ORCAMENTO, NULL AS OBS_OP, NULL AS PEDIDO_ECOMMERCE
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS E WITH (NOLOCK) ON B.cpros = E.cpros
WHERE        (A.datas > '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.nopmaes = 0)
GROUP BY D.nops, B.cpros, D.numps