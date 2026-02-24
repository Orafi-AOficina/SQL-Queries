SELECT L.rclis AS 'CLIENTE', J.dopes AS 'TIPO_PEDIDO', --K.datas AS 'ENTRADA', K.prazoents AS 'PRAZO',
			J.numes AS 'PEDIDO', J.numps AS 'OP_GERAL', E.nops AS 'OP', A.cpros AS 'CÓD. PRODUTO', A.dpros AS 'DESCRIÇÃO PRODUTO',
			A.qtds AS 'QTD', A.codbarras AS 'FINALIZAÇÃO', MAX(A.dtalts) AS 'LIBERAÇÃO',
			CASE 
				WHEN (SELECT TOP 1 COUNT(F.codbarras) FROM SigMvHst (NOLOCK) F WHERE A.codbarras = F.codbarras ORDER BY COUNT(F.codbarras) DESC) > 1 THEN 'VERDADEIRO'
				ELSE 'FALSO' END AS 'EXISTE NF'
	FROM SigMvItn (NOLOCK) A
		INNER JOIN (SELECT B.* FROM SigMvHst (NOLOCK) B WHERE B.codbarras NOT LIKE 0) C ON A.codbarras = C.codbarras
		INNER JOIN SigMvCab (NOLOCK) D ON C.empdopnums = D.empdopnums
		--AS CHAVES DAS COLUNAS TEM UM NÚMERO DIFERENTE DE ESPAÇOS SENDO USADOS PARA A CONTRUÇÃO DELA. TIVE QUE SUBSTITUIR ESPAÇOS POR VAZIO
		INNER JOIN SigPdMvf (NOLOCK) E ON REPLACE(D.empdncrds, ' ','') = REPLACE(E.empdnps, ' ', '')
		INNER JOIN SigOpPic (NOLOCK) J ON J.nops = E.nops
		INNER JOIN SigMvCab (NOLOCK) K ON J.empdopnums = K.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) L ON K.contads = L.iclis
	WHERE A.codbarras NOT LIKE 0
		AND A.dtalts > '2020-12-01'
		--AND L.rclis IN ('KORA KORA', 'HELGA')
		--AND (SELECT TOP 1 COUNT(F.codbarras) FROM SigMvHst (NOLOCK) F WHERE A.codbarras = F.codbarras ORDER BY COUNT(F.codbarras) DESC) = 1
--	ORDER BY J.numes, E.nops
	GROUP BY L.rclis, J.dopes, J.numes, J.numps, E.nops, A.cpros, A.dpros, A.qtds, A.codbarras