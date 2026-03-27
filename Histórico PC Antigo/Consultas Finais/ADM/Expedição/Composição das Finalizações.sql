SELECT A.codbarras AS 'CÓDIGO BARRAS', L.rclis AS 'CLIENTE', J.dopes AS 'TIPO_PEDIDO', K.datas AS 'ENTRADA', K.prazoents AS 'PRAZO',
	J.numes AS 'PEDIDO', J.numps AS 'OP_GERAL', E.nops AS 'OP', A.cpros AS 'CÓD. PRODUTO', A.dpros AS 'DESCRIÇÃO PRODUTO',
	A.qtds AS 'QTD', A.dtalts AS 'LIBERAÇÃO', C.pesos AS 'PESO PADRÃO', C.spesos AS 'PESO TOTAL', 
	(SELECT TOP 1 SUM(G.totas)/H.qtds
		FROM SigMvItn (NOLOCK) G
			INNER JOIN SigMvItn (NOLOCK) H ON H.empdopnums=G.empdopnums AND (H.citens = G.citem2 OR (H.cpros = G.cpros AND H.citem2 = 0))
			LEFT JOIN SigOpPic (NOLOCK) I ON G.empdopnums = I.empdopnums AND H.cpros = I.cpros
				WHERE G.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
							'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
					AND I.nops = E.nops
			GROUP BY H.cpros, H.qtds) AS 'PREV_VALOR_S/IMP', 
	D.empdncrds AS 'FINALIZAÇÃO', P.cgrus AS 'GRUPO_MP', P.cpros AS 'COD_MP', P.dpros AS 'DESC_MP',
	O.pesos AS 'PESO_UNIT',	O.qtds AS 'QTD_TOT',-- O.qtds/O.pesos AS 'QTD_UNIT',
	O.custofs AS 'CUSTO_AU', O.moecusfs AS 'MOEDA_CUSTO'
FROM SigMvItn (NOLOCK) A
	INNER JOIN (SELECT B.* FROM SigMvHst (NOLOCK) B WHERE B.codbarras NOT LIKE 0) C ON A.codbarras = C.codbarras
	INNER JOIN SigMvCab (NOLOCK) D ON C.empdopnums = D.empdopnums
	--AS CHAVES DAS COLUNAS TEM UM NÚMERO DIFERENTE DE ESPAÇOS SENDO USADOS PARA A CONTRUÇÃO DELA. TIVE QUE SUBSTITUIR ESPAÇOS POR VAZIO
	INNER JOIN SigPdMvf (NOLOCK) E ON REPLACE(D.empdncrds, ' ','') = REPLACE(E.empdnps, ' ', '')
	INNER JOIN SigOpPic (NOLOCK) J ON J.nops = E.nops
	INNER JOIN SigMvCab (NOLOCK) K ON J.empdopnums = K.empdopnums
	LEFT JOIN SIGCDCLI (NOLOCK) L ON K.contads = L.iclis
	LEFT JOIN SigPdMvf M (NOLOCK) ON REPLACE(D.empdncrds, ' ','') = REPLACE(M.empdnps, ' ', '')
	LEFT JOIN SigOpPic N (NOLOCK) ON N.nops = E.nops AND A.codbarras = N.codbarras
	LEFT JOIN SigCdNei O (NOLOCK) ON M.empdnps = O.empdnps
	LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.cmats
WHERE A.codbarras NOT LIKE 0
	AND A.dtalts > '2020-01-01'
	AND A.dopes IN ('FINALIZA NACIONAL   ') --adicionei essa linha para tirar casos de finalizações duplicadas
	--AND D.empdncrds = 'ORFFINALIZAÇÃO          13675'
	--AND (SELECT TOP 1 COUNT(F.codbarras) FROM SigMvHst (NOLOCK) F WHERE A.codbarras = F.codbarras ORDER BY COUNT(F.codbarras) DESC) = 1
ORDER BY A.dtalts, J.numes, E.nops