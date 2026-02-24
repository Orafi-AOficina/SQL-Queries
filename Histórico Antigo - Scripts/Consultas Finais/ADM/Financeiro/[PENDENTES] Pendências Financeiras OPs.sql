SELECT A.cidchaves AS UKEY_PEDIDO, A.empdopnums, A.dopes AS TIPO_PEDIDO, A.datas AS DATA_ENTRADA, A.mascnum AS PEDIDO, A.nops AS OP_MAE,
	D.nops AS OP, E.reffs AS REF_CLIENTE, B.cpros AS COD_PRODUTO, B.dpros AS DESC_PRODUTO, C.pesos AS QTD_UNID, C.qtds AS QTD_TOTAL,
	C.qtbxprods AS QTD_LIBERADA, C.cunis AS UNIDADE, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO,
	A.compet AS MES_COMPETENCIA_ANL, I.PESO_IMT
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
LEFT JOIN SigMvItn (NOLOCK) B ON B.citens = C.citem2 AND B.empdopnums=C.empdopnums
LEFT JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros
LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
INNER JOIN (SELECT DISTINCT MAX(datas) AS 'DT_FINALIZA', nops AS 'nops' FROM SigPdMvf K (NOLOCK)
					where nops not in (SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
						('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
					GROUP BY nops
			) AS G ON G.nops = D.nops
LEFT JOIN (SELECT DISTINCT SUM(G.qtds*H.custofs) AS PESO_IMT, G.empdopnums, G.citens
				FROM SigMvItn G
					LEFT JOIN SigCdPro H ON G.cpros = H.cpros
							WHERE G.moevs = 'AU' AND G.univals > 0 AND G.qtds > 0
							GROUP BY G.empdopnums, G.citens) I ON C.empdopnums = I.empdopnums AND I.citens = C.citens
WHERE A.datas > '2018-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
ORDER BY A.datas DESC, D.nops, C.dpros