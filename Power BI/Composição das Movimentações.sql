--Composição das Movimentações de Indústria
SELECT RTRIM(B.emps) AS EMPRESA, RTRIM(B.empdnps) AS CHAVE_OPERACAO, RTRIM(B.dopps) AS TIPO_OPERACAO, CASE WHEN A.tpops = '' THEN RTRIM(B.dopps) 
                  WHEN A.tpops IS NULL THEN RTRIM(B.dopps) WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps) ELSE RTRIM(A.tpops) END AS OPERACAO, A.nops AS OP, RTRIM(C.mercs) AS GRANDE_GRP, RTRIM(D.descs) AS TIPO_ITEM_ESTOQUE, RTRIM(C.cgrus) 
                  AS GRP_INSUMO, RTRIM(A.cmats) AS INSUMO, RTRIM(C.dpros) AS DESC_INSUMO, A.pesos AS PESO_UNIT, A.qtds AS QTD_TOT, RTRIM(A.cunis) AS UN, A.custofs AS CUSTO_AU, RTRIM(A.moecusfs) AS MOEDA_CUSTO, A.peso2s AS 'PESO2S', 
                  A.qtds * A.custofs AS COMPRA_OFI, REPLACE(B.empdnps, ' ', '') AS CHAVE_FINALIZACAO, A.nops AS OP2
FROM     dbo.SigCdNei (NOLOCK) AS A LEFT OUTER JOIN
					(SELECT DISTINCT aa.empdnps AS 'ANTIGA', REPLACE(aa.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei (NOLOCK) aa 
									LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps WHERE bb.emps IS NULL) E ON A.empdnps = E.ANTIGA LEFT OUTER JOIN 
					dbo.SigCdNec AS B WITH (NOLOCK) ON A.empdnps = B.empdnps OR B.empdnps = E.NOVA LEFT OUTER JOIN
                  	dbo.SigCdPro AS C WITH (NOLOCK) ON A.cmats = C.cpros LEFT OUTER JOIN
	                dbo.SigCdGpr AS D WITH (NOLOCK) ON C.mercs = D.codigos
WHERE  B.datas >= '01-01-2023'
ORDER BY B.datas DESC