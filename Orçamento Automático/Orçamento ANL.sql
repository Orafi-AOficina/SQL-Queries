--Itens dos Orçamentos da Animale
SELECT A.datas AS 'DATA', RTRIM(A.emps) AS 'EMPRESA', RTRIM(A.dopes) AS 'OPERACAO', A.numes AS 'NUM_OPERACAO', RTRIM(C.iclis) AS 'COD_CONTA', RTRIM(C.rclis) AS 'CLIENTE', RTRIM(A.usuars) AS 'USUARIO', 
                         B.citens AS 'ID', RTRIM(D .reffs) AS 'REF_ANL', (D .obscompras) AS 'COR_ANL', D .idecpros AS 'ID_VARIACAO', F.DATA_CADASTRO AS CADASTRO_REF, F_1.PRIM_PEDIDO, F_1.ULT_PEDIDO, RTRIM(B.cpros) 
                         AS 'COD_PRODUTO', RTRIM(B.dpros) AS 'DESCRICAO_PRODUTO', RTRIM(D .codcors) AS 'COR', E.AU AS 'CUSTO_AU', E.US AS 'CUSTO_US', RTRIM(D .colecoes) AS 'GRUPO_VENDA', RTRIM(A.tpfats) AS 'TIPO_FATUR', 
                         A.vars AS 'GROSSUP',
                             (SELECT        COUNT(DISTINCT bb.empdopnums + CAST(bb.citens AS varchar))
                               FROM            SigMvCab aa(NOLOCK) LEFT JOIN
                                                         SigMvItn bb(NOLOCK) ON aa.empdopnums = bb.empdopnums
                               WHERE        B.cpros = bb.cpros AND aa.dopes = 'ORÇAMENTO' AND aa.datas > '01-01-2021') AS 'QTD_ORÇAMENTOS',
                             (SELECT        COUNT(DISTINCT bb.empdopnums + CAST(bb.citens AS varchar))
                               FROM            SigMvCab aa(NOLOCK) LEFT JOIN
                                                         SigMvItn bb(NOLOCK) ON aa.empdopnums = bb.empdopnums
                               WHERE        B.cpros = bb.cpros AND aa.datars >= A.datars AND aa.datas > '01-01-2021' AND aa.dopes = 'ORÇAMENTO') AS 'INDEX'
FROM            SigMvCab(NOLOCK) A LEFT JOIN
                         SigMvItn(NOLOCK) B ON A.empdopnums = B.empdopnums LEFT JOIN
                         SIGCDCLI(NOLOCK) C ON A.contads = C.iclis LEFT JOIN
                         SigCdPro(NOLOCK) D ON B.cpros = D .cpros LEFT JOIN
                             (SELECT        reffs, min(dtincs) AS 'DATA_CADASTRO'
                               FROM            sigcdpro
                               GROUP BY reffs) F ON F.reffs = D .reffs LEFT JOIN
                             (SELECT        empdopnums, [US] + 0 AS 'US', [AU] + 0 AS 'AU'
                               FROM            (SELECT        empdopnums, moeds, moevals
                                                         FROM            SigMvMov(NOLOCK)
                                                         WHERE        DOPES = 'ORÇAMENTO') AS origem PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt) E ON E.empdopnums = A.empdopnums INNER JOIN
                             (SELECT        MIN(A.datas) AS PRIM_PEDIDO, MAX(A.datas) AS ULT_PEDIDO, C.cpros AS COD_PROD
                               FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                                                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums LEFT OUTER JOIN
                                                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D .empdopnums AND C.cpros = D .cpros AND C.citens = D .citens LEFT OUTER JOIN
                                                         dbo.SigCdPro AS E WITH (NOLOCK) ON C.cpros = E.cpros
                               WHERE        (A.datas >= '01-01-2021') AND (A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA')) AND (D .nopmaes = 0) AND (E.colecoes = 'ANL')
                               GROUP BY C.cpros, C.dpros) AS F_1 ON F_1.COD_PROD = B.cpros
WHERE        D .mercs = 'PA' AND A.dopes = 'ORÇAMENTO' AND A.datas > '01-01-2021' AND B.citem2 = 0 AND D .colecoes = 'ANL' AND A.usuars IN ('ANA', 'ANA.RNG') AND D .reffs <> ''