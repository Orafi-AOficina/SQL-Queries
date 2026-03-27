--Composição dos Insumos necessários para a Produção de cada OP em função do cadastro de cada produto que compõe ela
SELECT        A.datas AS DATA, D.nops AS OP_ITEM, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, SUM(C.totas) AS VALOR_ITEM, SUM(C.qtds) AS QTD_ITEM, C.cunis AS UNIDADE, SUM(C.pesos) AS PESO, 
                         RTRIM(H.mercs) AS GRANDE_GRP, RTRIM(H.cgrus) AS GRP, I.dgrus AS GRP_INSUMO, 
                         CASE WHEN C.cpros = 'RODIO 2,00    ' THEN 'AU750' WHEN H.cgrus = 'IAU' THEN 'AU750' WHEN H.cgrus = 'BRI' THEN 'BRILHANTES' WHEN H.cgrus = 'PED' THEN 'PEDRAS' WHEN H.cgrus = 'IMT' THEN 'INSUMOS METALICOS'
                          ELSE I.dgrus END AS GRUPO_INS, RTRIM(H.sgrus) AS COD_SUBGRUPO, RTRIM(G.descricaos) AS SUBGRUPO, RTRIM(G.descricaos) AS [Insumo Tratado]
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND (B.citens = C.citem2 OR
                         B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens) LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON C.empdopnums = D.empdopnums AND B.cpros = D.cpros AND B.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS H WITH (NOLOCK) ON C.cpros = H.cpros LEFT OUTER JOIN
                         dbo.SigCdGrp AS I WITH (NOLOCK) ON I.cgrus = H.cgrus LEFT OUTER JOIN
                         dbo.SigCdPsg AS G WITH (NOLOCK) ON H.sgrus = G.codigos AND H.cgrus = G.cgrus
WHERE        (A.datas > '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.nopmaes = 0)
GROUP BY A.datas, D.nops, C.cpros, C.dpros, C.cunis, I.dgrus, H.cgrus, I.dgrus, H.sgrus, G.descricaos, H.mercs, H.cgrus