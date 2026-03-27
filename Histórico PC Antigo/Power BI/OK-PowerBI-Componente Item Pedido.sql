--Componentes do Item do Pedido
SELECT A.datas, D.nops AS 'OP_ITEM', C.cpros AS 'COD_COMPOSICAO', C.dpros AS 'DESC_COMPOSICAO', 
	C.totas AS 'VALOR_ITEM', C.qtds AS 'QTD_ITEM', C.cunis AS 'UNIDADE', C.pesos AS 'PESO', I.DGRUS AS 'GRP_INSUMO',
	CASE 
		WHEN C.cpros = 'RODIO 2,00    ' THEN 'AU750'
		WHEN H.cgrus = 'IAU' THEN 'AU750'
		WHEN H.cgrus = 'BRI' THEN 'BRILHANTES'
		WHEN H.cgrus = 'PED' THEN 'PEDRAS'
		WHEN H.cgrus = 'IMT' THEN 'INSUMOS METÁLICOS'
		ELSE I.dgrus
	END AS 'GRUPO_INS'
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums=C.empdopnums AND (B.citens = C.citem2 OR (B.cpros = C.cpros AND B.citem2 = 0))
LEFT JOIN SigOpPic (NOLOCK) D ON C.empdopnums = D.empdopnums AND B.cpros = D.cpros
LEFT JOIN SigCdPro (NOLOCK) H ON C.cpros = H.cpros
LEFT JOIN SigCdGrp AS I (NOLOCK) ON I.CGRUS = H.cgrus
WHERE A.datas > '2016-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
	AND D.nopmaes = 0