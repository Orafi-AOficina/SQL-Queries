SELECT a.emps AS 'EMPRESA', a.grupos AS 'GRP_ESTOQUE', D.grupos AS 'GRP_CONTA', D.iclis AS 'COD_CONTA', D.RCLIS AS 'NOME_CONTA',
	b.cgrus AS 'GRUPO_INS', b.cpros AS 'COD_INSUMO',B.DPROS AS 'DESC_INSUMO', A.SQTDS AS 'SALDO', B.CUNIS AS 'UN', A.spesos AS 'QTD', B.cunips AS 'UN_QTD',
		CASE
			WHEN D.inativas = 1 THEN 'INATIVA'
			WHEN D.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS', B.obspes
	FROM sigmvest A (NOLOCK)
		LEFT join sigcdpro B (NOLOCK) ON a.cpros = B.cpros
		LEFT JOIN SIGCDPSG C (NOLOCK) ON B.CGRUS = C.CGRUS and B.sgrus = C.codigos
		LEFT JOIN SIGCDCLI D (NOLOCK) ON A.ESTOS = D.ICLIS
		LEFT JOIN SigCdGpr F (NOLOCK) ON B.mercs = F.codigos
	WHERE (A.SQTDS <> 0 OR A.spesos <> 0)
                                   AND A.emps = 'RNG' AND b.cgrus = 'BR1'
	ORDER BY A.grupos, D.iclis, B.dpros, A.emps