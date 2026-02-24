SELECT TOP 100 A.codbarras AS 'CÓDIGO BARRAS', E.nops AS 'OP', A.cpros AS 'CÓD. PRODUTO', A.dpros AS 'DESCRIÇÃO PRODUTO', A.qtds AS 'QTD',
	A.dtalts AS 'LIBERAÇÃO', C.pesos AS 'PESO PADRÃO', C.spesos AS 'PESO TOTAL', I.* --SUM(G.totas)/H.qtds, I.*
--	(SELECT DISTINCT SUM(G.totas)/H.qtds
--		FROM SigMvItn (NOLOCK) G
--			INNER JOIN SigMvItn (NOLOCK) H ON H.empdopnums=G.empdopnums AND (H.citens = G.citem2 OR (H.cpros = G.cpros AND H.citem2 = 0))
--			LEFT JOIN SigOpPic (NOLOCK) I ON G.empdopnums = I.empdopnums AND H.cpros = I.cpros
--				WHERE G.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
--							'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
--					AND I.nops = E.nops
--			GROUP BY I.nops, H.cpros, H.qtds) AS 'VALOR_UNIT_S/IMP'
FROM SigMvItn (NOLOCK) A
	INNER JOIN (SELECT B.* FROM SigMvHst (NOLOCK) B WHERE B.codbarras NOT LIKE 0) C ON A.codbarras = C.codbarras
	INNER JOIN SigMvCab (NOLOCK) D ON C.empdopnums = D.empdopnums
	--AS CHAVES DAS COLUNAS TEM UM NÚMERO DIFERENTE DE ESPAÇOS SENDO USADOS PARA A CONTRUÇÃO DELA. TIVE QUE SUBSTITUIR ESPAÇOS POR VAZIO
	INNER JOIN SigPdMvf (NOLOCK) E ON REPLACE(D.empdncrds, ' ','') = REPLACE(E.empdnps, ' ', '')
	LEFT JOIN SigOpPic (NOLOCK) I ON E.nops = I.nops
	LEFT JOIN SigMvItn (NOLOCK) G ON G.empdopnums = I.empdopnums 
	INNER JOIN SigMvItn (NOLOCK) H ON H.empdopnums=G.empdopnums AND (H.citens = G.citem2 OR (H.cpros = G.cpros AND H.citem2 = 0))
WHERE G.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
							'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
		AND A.codbarras NOT LIKE 0
		AND A.dtalts > '2019-01-01'
		AND (SELECT TOP 1 COUNT(F.codbarras) FROM SigMvHst (NOLOCK) F WHERE A.codbarras = F.codbarras ORDER BY COUNT(F.codbarras) DESC) = 1
--GROUP BY A.codbarras, E.nops, A.cpros, A.dpros, A.qtds,	A.dtalts, C.pesos, C.spesos, H.qtds, I.*