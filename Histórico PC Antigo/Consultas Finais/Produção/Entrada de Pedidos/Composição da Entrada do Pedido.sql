SELECT A.cidchaves AS UKEY_PEDIDO, A.empdopnums, F.rclis AS FORNECEDOR, A.dopes AS TIPO_PEDIDO, A.datas AS DATA_ENTRADA,
	A.prazoents AS PRAZO_ENTREG, A.mascnum AS PEDIDO, A.nops AS OP_MAE, D.nops AS OP, E.reffs AS REF_CLIENTE,
	B.cpros AS COD_PRODUTO,	B.dpros AS DESC_PRODUTO, B.qtds AS QTD, E.codcors AS COR, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, 
	C.totas AS VALOR_ITEM, C.qtds AS QTD_ITEM, C.cunis AS UNIDADE, C.pesos AS PESO, A.compet AS MES_COMPETENCIA_ANL,
	I.DGRUS AS GRP_INSUMO,
	CASE 
		WHEN C.cpros = 'RODIO 2,00    ' THEN 'AU750'
		WHEN H.cgrus = 'BRI' THEN 'BRILHANTES'
		WHEN H.cgrus = 'PED' THEN 'PEDRAS'
		WHEN H.cgrus = 'IMT' THEN 'INSUMOS METÁLICOS'
	END AS GRUPO_INS
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums=C.empdopnums AND (B.citens = C.citem2 OR (B.cpros = C.cpros AND B.citem2 = 0))
--INNER JOIN SigMvItn (NOLOCK) G ON G.citens = B.citem2 AND G.empdopnums=C.empdopnums AND G.citem2 = 0
LEFT JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros
--LEFT JOIN SigOpPic (NOLOCK) F ON A.empdopnums = F.empdopnums AND 
LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
LEFT JOIN SIGCDCLI (NOLOCK) F ON A.contads = F.iclis
LEFT JOIN SigCdPro (NOLOCK) H ON C.cpros = H.cpros
LEFT JOIN SigCdGrp AS I (NOLOCK) ON I.CGRUS = H.cgrus
WHERE A.datas > '2018-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
	AND D.nopmaes = 0
	--AND D.nops = 67530002
ORDER BY A.datas DESC, A.mascnum, C.citens, B.cpros