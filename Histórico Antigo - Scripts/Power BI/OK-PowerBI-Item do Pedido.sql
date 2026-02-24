--Itens do Pedido
SELECT DISTINCT A.empdopnums AS 'CHAVE_PEDIDO', D.nops AS 'OP_ITEM', E.reffs AS 'REF_CLIENTE', B.cpros AS 'COD_PRODUTO',
	B.dpros AS 'DESC_PRODUTO', E.codcors AS 'COR', B.qtds AS 'QTD',
	CASE
		WHEN F.dopps = 'FINALIZAÇÃO         ' THEN 'FINALIZADO'
		WHEN F.dopps = 'FINALIZA S INDUSTRIA' THEN 'CANCELADO'
		WHEN F.dopps = 'FINALIZA OP S/BARRA ' THEN 'FINALIZA PEDIDO INTERNO'
		ELSE 'PENDENTE'
	END AS 'STATUS'
	--, SUM(C.totas) AS 'VALOR_S/IMP', C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, C.*
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums=C.empdopnums AND (B.citens = C.citem2 OR (B.cpros = C.cpros AND B.citem2 = 0))
LEFT JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros
LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
LEFT JOIN (SELECT DISTINCT NOPS, dopps FROM SIGPDMVF (NOLOCK) where dopps in
				('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')) F ON D.nops = F.NOPS
--INNER JOIN SigMvItn (NOLOCK) G ON G.citens = B.citem2 AND G.empdopnums=C.empdopnums AND G.citem2 = 0
--LEFT JOIN SigOpPic (NOLOCK) F ON A.empdopnums = F.empdopnums AND 
WHERE A.datas > '2017-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
	AND D.nopmaes = 0
--GROUP BY A.empdopnums, D.nops, E.reffs, B.cpros, B.dpros, B.qtds, E.codcors