SELECT A.codbarras AS 'CÓDIGO BARRAS', L.rclis AS 'CLIENTE', J.dopes AS 'TIPO_PEDIDO', K.datas AS 'ENTRADA', K.prazoents AS 'PRAZO',
	J.numes AS 'PEDIDO', J.numps AS 'OP_GERAL', E.nops AS 'OP', A.cpros AS 'CÓD. PRODUTO', A.dpros AS 'DESCRIÇÃO PRODUTO',
	A.qtds AS 'QTD', A.dtalts AS 'LIBERAÇÃO', C.pesos AS 'PESO PADRÃO', C.spesos AS 'PESO TOTAL', 
	(SELECT DISTINCT SUM(G.totas)/H.qtds
		FROM SigMvItn (NOLOCK) G
			INNER JOIN SigMvItn (NOLOCK) H ON H.empdopnums=G.empdopnums AND (H.citens = G.citem2 OR (H.cpros = G.cpros AND H.citem2 = 0))
			LEFT JOIN SigOpPic (NOLOCK) I ON G.empdopnums = I.empdopnums AND H.cpros = I.cpros
				WHERE G.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
							'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
					AND I.nops = E.nops
			GROUP BY H.cpros, H.qtds) AS 'VALOR_UNIT_S/IMP'
FROM SigMvItn (NOLOCK) A
	INNER JOIN (SELECT B.* FROM SigMvHst (NOLOCK) B WHERE B.codbarras NOT LIKE 0) C ON A.codbarras = C.codbarras
	INNER JOIN SigMvCab (NOLOCK) D ON C.empdopnums = D.empdopnums
	--AS CHAVES DAS COLUNAS TEM UM NÚMERO DIFERENTE DE ESPAÇOS SENDO USADOS PARA A CONTRUÇÃO DELA. TIVE QUE SUBSTITUIR ESPAÇOS POR VAZIO
	INNER JOIN SigPdMvf (NOLOCK) E ON REPLACE(D.empdncrds, ' ','') = REPLACE(E.empdnps, ' ', '')
	INNER JOIN SigOpPic (NOLOCK) J ON J.nops = E.nops
	INNER JOIN SigMvCab (NOLOCK) K ON J.empdopnums = K.empdopnums
	LEFT JOIN SIGCDCLI (NOLOCK) L ON K.contads = L.iclis
WHERE A.codbarras NOT LIKE 0
	AND A.dtalts > '2019-01-01'
	AND (SELECT TOP 1 COUNT(F.codbarras) FROM SigMvHst (NOLOCK) F WHERE A.codbarras = F.codbarras ORDER BY COUNT(F.codbarras) DESC) = 1
ORDER BY A.dtalts, J.numes, E.nops