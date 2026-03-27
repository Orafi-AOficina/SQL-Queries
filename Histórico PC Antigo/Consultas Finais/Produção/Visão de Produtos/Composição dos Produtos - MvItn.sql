SELECT A.cidchaves AS UKEY_PEDIDO, A.empdopnums, A.dopes AS TIPO_PEDIDO, A.datas AS DATA_ENTRADA, A.mascnum AS PEDIDO, A.nops AS OP_MAE,
	D.nops AS OP, E.reffs AS REF_CLIENTE, B.cpros AS COD_PRODUTO, B.dpros AS DESC_PRODUTO, C.qtds AS QTD_TOTAL,
	C.qtbxprods AS QTD_LIBERADA, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, B.*
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
INNER JOIN SigMvItn (NOLOCK) B ON B.citens = C.citem2 AND B.empdopnums=C.empdopnums
--INNER JOIN SigMvItn (NOLOCK) G ON G.citens = B.citem2 AND G.empdopnums=C.empdopnums AND G.citem2 = 0
LEFT JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros
--LEFT JOIN SigOpPic (NOLOCK) F ON A.empdopnums = F.empdopnums AND 
LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
--LEFT JOIN (SELECT )
WHERE A.datas > '2018-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
ORDER BY A.datas DESC, D.nops, C.dpros