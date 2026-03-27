-- Informação de Cadastro dos Produtos
SELECT DISTINCT 
                         TOP (100) PERCENT RTRIM(D.reffs) AS [Referência Animale], LTRIM(RTRIM(CAST(D.obscompras AS varchar))) AS [Variação Cor Animale], RTRIM(B.cpros) AS [Código Orafi], RTRIM(D.dpros) AS [Descrição Produto], 
                         RTRIM(D.codcors) AS [Cor Metal], RTRIM(E_1.DESC_SITE) AS [Composição do Produto]
FROM            dbo.SigMvCab AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON A.empdopnums = B.empdopnums LEFT OUTER JOIN
                         dbo.SigCdPro AS D WITH (NOLOCK) ON B.cpros = D.cpros LEFT OUTER JOIN
                             (SELECT DISTINCT COD_PROD, LEFT(RTRIM(COR) + ' COM ' + STRING_AGG(RTRIM(SUBGRUPO), ' / '), 100) AS DESC_SITE
                               FROM            (SELECT DISTINCT A.reffs, RTRIM(A.cpros) AS COD_PROD, RTRIM(A.dpros) AS DESC_PROD, RTRIM(F.descs) AS COR, RTRIM(E.descricaos) AS SUBGRUPO, A.datas
                                                         FROM            dbo.SigCdPro AS A WITH (NOLOCK) LEFT OUTER JOIN
                                                                                   dbo.SIGPRCPO AS C WITH (NOLOCK) ON A.cpros = C.cpros INNER JOIN
                                                                                       (SELECT DISTINCT cpros, mercs, sgrus, cgrus
                                                                                         FROM            dbo.SigCdPro WITH (NOLOCK)) AS D_1 ON C.mats = D_1.cpros LEFT OUTER JOIN
                                                                                   dbo.SigCdPsg AS E WITH (NOLOCK) ON E.codigos = D_1.sgrus LEFT OUTER JOIN
                                                                                   dbo.SigCdCor AS F WITH (NOLOCK) ON A.codcors = F.cods
                                                         WHERE        (A.mercs = 'PA') AND (D_1.mercs IN ('PED'))) AS aa_1
                               GROUP BY COD_PROD, DESC_PROD, COR, COR, datas, reffs) AS E_1 ON E_1.COD_PROD = D.cpros INNER JOIN
                             (SELECT        MAX(A.datas) AS ULT_PEDIDO, C.cpros AS COD_PROD
                               FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                                                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums LEFT OUTER JOIN
                                                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND C.cpros = D.cpros AND C.citens = D.citens LEFT OUTER JOIN
                                                         dbo.SigCdPro AS E WITH (NOLOCK) ON C.cpros = E.cpros
                               WHERE        (A.datas >= '01-01-2022') AND (A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA')) AND (D.nopmaes = 0) AND (E.colecoes = 'ANL')
                               GROUP BY C.cpros, C.dpros) AS F_1 ON F_1.COD_PROD = B.cpros
WHERE        (D.mercs = 'PA') AND (A.dopes = 'ORÇAMENTO') AND (A.datas > '01-01-2022') AND (B.citem2 = 0) AND (D.colecoes = 'ANL') AND (A.usuars IN ('ANA', 'ANA.RNG')) AND (D.reffs <> '') AND (D.reffs <> '00000000000000000000') AND 
                         (D.dpros NOT LIKE '%INATIVO%')