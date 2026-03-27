--Detalhamento de informações das OPs com infomações de quais observações foram feitas para cada item finalizado de uma OP.
SELECT        TOP (100) PERCENT D.nops AS OP, D.obss AS OBS_OP, D.codbarras AS FINALIZAÇÃO
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros AND C.citens = D.citens
WHERE        (A.datas > '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%')
ORDER BY 'OP' DESC