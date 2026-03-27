--Composição dos itens do orçamento
SELECT A.datars AS 'DATA', RTRIM(A.emps) AS 'EMPRESA', RTRIM(A.dopes) AS 'OPERACAO', A.numes AS 'NUM_OPERACAO', B.citens AS 'ID', RTRIM(B.cpros) AS 'COD_PRODUTO', RTRIM(B.dpros) 
                         AS 'DESCRICAO_PRODUTO', RTRIM(G.mercs) AS 'GRANDE_GRP', RTRIM(G.cgrus) AS 'GRUPO', RTRIM(F.cpros) AS 'COD_INSUMO', RTRIM(F.dpros) AS 'DESC_INSUMO', F.qtds AS 'QTD1', RTRIM(F.cunis) AS 'UN1', 
                         F.pesos AS 'QTD2', RTRIM(F.moevs) AS 'MOEDA', F.totas AS 'VALOR LINHA', E.AU AS 'CUSTO_AU', E.US AS 'CUSTO_US', RTRIM(D .colecoes) AS 'GRUPO_VENDA', RTRIM(A.tpfats) AS 'TIPO_FATUR'
FROM            SigMvCab(NOLOCK) A LEFT JOIN
                         SigMvItn(NOLOCK) B ON A.empdopnums = B.empdopnums LEFT JOIN
                         SigMvItn(NOLOCK) F ON F.empdopnums = B.empdopnums AND B.citem2 = 0 AND (B.citens = F.citem2 OR
                         B.citens = F.citens) LEFT JOIN
                         SIGCDCLI(NOLOCK) C ON A.contads = C.iclis LEFT JOIN
                         SigCdPro(NOLOCK) D ON B.cpros = D .cpros LEFT JOIN
                             (SELECT        empdopnums, [US] + 0 AS 'US', [AU] + 0 AS 'AU'
                               FROM            (SELECT        empdopnums, moeds, moevals
                                                         FROM            SigMvMov(NOLOCK)
                                                         WHERE        DOPES = 'ORÇAMENTO') AS origem PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt) E ON E.empdopnums = A.empdopnums LEFT JOIN
                         SigCdPro(NOLOCK) G ON G.cpros = F.cpros INNER JOIN
                             (SELECT        MIN(A.datas) AS PRIM_PEDIDO, MAX(A.datas) AS ULT_PEDIDO, C.cpros AS COD_PROD
                               FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                                                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums LEFT OUTER JOIN
                                                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D .empdopnums AND C.cpros = D .cpros AND C.citens = D .citens LEFT OUTER JOIN
                                                         dbo.SigCdPro AS E WITH (NOLOCK) ON C.cpros = E.cpros
                               WHERE        (A.datas >= '01-01-2021') AND (A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA')) AND (D .nopmaes = 0) AND (E.colecoes = 'ANL')
                               GROUP BY C.cpros, C.dpros) AS F_1 ON F_1.COD_PROD = B.cpros
WHERE        D .mercs = 'PA' AND A.dopes = 'ORÇAMENTO' AND A.datas > '01-01-2021' AND B.citem2 = 0 AND D .colecoes = 'ANL' AND A.usuars IN ('ANA', 'ANA.RNG')