-- Composição das Movimentações de Indústria
SELECT        TOP (100) PERCENT B.emps AS EMPRESA, B.empdnps AS CHAVE_OPERACAO, RTRIM(B.dopps) AS TIPO_OPERACAO, CASE WHEN A.tpops = '' THEN RTRIM(B.dopps) WHEN A.tpops IS NULL THEN RTRIM(B.dopps) 
                         WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps) ELSE RTRIM(A.tpops) END AS OPERACAO, A.nops AS OP, RTRIM(D.descs) AS TIPO_ITEM_ESTOQUE, RTRIM(C.mercs) AS GRANDE_GRP, RTRIM(C.cgrus) 
                         AS GRP_INSUMO, RTRIM(A.cmats) AS INSUMO, RTRIM(C.dpros) AS DESC_INSUMO, A.pesos AS PESO_UNIT, A.qtds AS QTD_TOT, RTRIM(A.cunis) AS UN, A.custofs AS CUSTO_AU, RTRIM(A.moecusfs) AS MOEDA_CUSTO, 
                         A.peso2s, A.qtds * A.custofs AS COMPRA_OFI, REPLACE(B.empdnps, ' ', '') AS CHAVE_FINALIZACAO, A.nops AS OP2
FROM            dbo.SigCdNec AS B LEFT OUTER JOIN
                         dbo.SigCdNei AS A WITH (NOLOCK) ON A.dopps = B.dopps AND A.numps = B.numps AND LEFT(A.emps, 2) = LEFT(B.emps, 2) LEFT OUTER JOIN
                         dbo.SigCdPro AS C WITH (NOLOCK) ON A.cmats = C.cpros LEFT OUTER JOIN
                         dbo.SigCdGpr AS D WITH (NOLOCK) ON C.mercs = D.codigos
WHERE        (B.datas >= '01-01-2023')