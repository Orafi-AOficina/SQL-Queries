SELECT A.empdopnums, F.rclis AS FORNECEDOR, A.dopes AS TIPO_PEDIDO, A.datas AS DATA_ENTRADA,
	A.prazoents AS PRAZO_ENTREG, A.mascnum AS PEDIDO, A.nops AS OP_MAE, SUM(B.qtds) AS QTD_PECAS, C.cpros AS COD_COMPOSICAO,
	C.dpros AS DESC_COMPOSICAO, SUM(C.totas) AS VALOR_ITEM, SUM(C.qtds) AS QTD_ITEM, C.cunis AS UNIDADE, SUM(C.pesos) AS PESO,
	A.compet AS MES_COMPETENCIA_ANL,
	I.DGRUS AS GRP_INSUMO,
	CASE
		WHEN C.cpros = 'RODIO 2,00    ' THEN 'AU750'
		WHEN H.cgrus = 'BRI' THEN 'BRILHANTES'
		WHEN H.cgrus = 'PED' THEN 'PEDRAS'
		WHEN H.cgrus = 'IMT' OR I.dgrus = 'INSUMOS ORAFI' THEN 'INSUMOS METÁLICOS'
		WHEN I.dgrus = 'SERVIÇOS' THEN 'SERVIÇOS'
		WHEN I.dgrus IN ('ANEL', 'PULSEIRA', 'BRINCO', 'ALIANCA', 'COLAR', 'BRACELETE') THEN 'PEÇA'
		WHEN I.dgrus = 'OUTROS' THEN 'OUTROS'
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
--	AND D.nops = 69080005
GROUP BY A.empdopnums, F.rclis, A.dopes, A.datas, A.prazoents, A.mascnum, A.nops, C.cpros, C.dpros, C.cunis, A.compet, I.dgrus, H.cgrus
ORDER BY A.datas DESC, A.mascnum, C.cpros