--OPs Geradas
-- Uma única OP pode referenciar vários itens de vários pedidos diferentes, mesmo que geralmente ela só se refira à um item de 1 único pedido. Isso acontece, porque é operacionalmente mais vantajoso processar uma OP
-- do mesmo produto mesmo que tenha pequenas variações de tamanho ou de cliente final do que várias OPs menores totalmente individualizadas
SELECT DISTINCT TOP (100) PERCENT CASE WHEN A.emps = 'ORF' THEN 'ORA' ELSE A.emps END AS EMPRESA, A.dataes AS DATA_OP, RTRIM(A.dopps) AS TIPO, A.nops AS OP,
                             (SELECT        SUM(qtds) AS Expr1
                               FROM            dbo.SigOpPic AS AA WITH (NOLOCK)
                               WHERE        (qtds > 0) AND (A.empdopnops = empdopnops) AND (A.nops = nops)) AS QTD, A.codbarras AS FINALIZACAO, A.empdnps AS CHAVE_INDUSTRIALIZACAO_PEDIDO, 
                         A.empdopnops AS CHAVE_INDUSTRIALIZACAO_ITEM, 
                         CASE WHEN H.nopmaes > 0 THEN H.nopmaes WHEN G.nopmaes > 0 THEN G.nopmaes WHEN F.nopmaes > 0 THEN F.nopmaes WHEN E.nopmaes > 0 THEN E.nopmaes WHEN D .nopmaes > 0 THEN D .nopmaes WHEN C.nopmaes
                          > 0 THEN C.nopmaes WHEN B.nopmaes > 0 THEN B.nopmaes WHEN A.nopmaes > 0 THEN A.nopmaes ELSE A.nops END AS OP_MAE, CASE WHEN CHARINDEX('#', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('#', 
                         A.obss) + LEN('#'), 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('PEDIDO ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('PEDIDO ', A.obss) + LEN('PEDIDO ') + 1, 4) 
                         + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('pedido ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('pedido ', A.obss) + LEN('pedido ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) 
                         WHEN CHARINDEX('Pedido ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('Pedido ', A.obss) + LEN('Pedido ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('PEDIDO: ', A.obss) 
                         > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('PEDIDO: ', A.obss) + LEN('PEDIDO: ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('pedido: ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, 
                         CHARINDEX('pedido: ', A.obss) + LEN('pedido: ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('Pedido: ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('Pedido: ', A.obss) + LEN('Pedido: ') + 1, 4) 
                         + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('PEDIDO', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('PEDIDO', A.obss) + LEN('PEDIDO') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) 
                         WHEN CHARINDEX('pedido', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('pedido', A.obss) + LEN('pedido') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('Pedido', A.obss) 
                         > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('Pedido', A.obss) + LEN('Pedido') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('DIDO', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('DIDO', 
                         A.obss) + LEN('DIDO') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('dido', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('dido', A.obss) + LEN('dido') + 1, 4) 
                         + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN
                             (SELECT        COUNT(AA.nops)
                               FROM            SigOpPic(NOLOCK) AA
                               WHERE        AA.qtds > 0 AND A.nops = AA.nops) > 1 THEN 'VERIFICAR OBS NA OP' ELSE CAST(A.obss AS VARCHAR(MAX)) END AS OBS
FROM            dbo.SigOpPic AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigOpPic AS B WITH (NOLOCK) ON A.nopmaes = B.nops AND A.citens = B.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS C WITH (NOLOCK) ON B.nopmaes = C.nops AND B.citens = C.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON C.nopmaes = D.nops AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS E WITH (NOLOCK) ON D.nopmaes = E.nops AND D.citens = E.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS F WITH (NOLOCK) ON E.nopmaes = F.nops AND E.citens = F.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS G WITH (NOLOCK) ON F.nopmaes = G.nops AND F.citens = G.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS H WITH (NOLOCK) ON G.nopmaes = H.nops AND G.citens = H.citens
WHERE        (A.dataes >= '2023-01-01') AND (A.qtds > 0)
ORDER BY 'OP'