SELECT DISTINCT a.emps AS 'EMPRESA', a.grupos AS 'GRP_ESTOQUE', D.grupos AS 'GRP_CONTA', D.iclis AS 'COD_CONTA', D.RCLIS AS 'NOME_CONTA', --MAX(E.datas) AS 'DT_BALANÇO',
	b.cgrus AS 'GRUPO_INS', C.CODIGOS AS 'SUBGRUPO_INS',
	b.cpros AS 'COD_INSUMO',B.DPROS AS 'DESC_INSUMO', A.SQTDS AS 'SALDO', B.CUNIS AS 'UN', A.spesos AS 'QTD', B.cunips AS 'UN_QTD', B.custofs AS 'CUSTO_EST', B.moedas AS 'MOEDA',
		CASE
			WHEN D.inativas = 1 THEN 'INATIVA'
			WHEN D.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS', F.descs--, MAX(H.datas)
	FROM sigmvest A (NOLOCK)
		LEFT join sigcdpro B (NOLOCK) ON a.cpros = B.cpros
		LEFT JOIN SIGCDPSG C (NOLOCK) ON B.CGRUS = C.CGRUS and B.sgrus = C.codigos
		LEFT JOIN SIGCDCLI D (NOLOCK) ON A.ESTOS = D.ICLIS
--		LEFT JOIN SigCdFcx E (NOLOCK) ON A.grupos = E.grupos AND A.estos = E.contas
		LEFT JOIN SigCdGpr F (NOLOCK) ON B.mercs = F.codigos
		--LEFT JOIN SigCdNei G (NOLOCK) ON G.cmats = B.cpros 
		--LEFT JOIN SigPdMvf H (NOLOCK) ON G.empdnps = H.empdnps
	WHERE (A.SQTDS <> 0 OR A.spesos <> 0)
		AND ((D.grupos = 'CLIENTE' AND D.iclis = 'C000001602')
				OR (D.grupos = 'FORNECEDOR' AND D.iclis IN ('F000000075', 'F000000290', 'F000000490', 'F000000580'))
				OR (D.grupos = 'ESTOQUE' AND D.iclis NOT IN ('ESTOQUE'))
				OR (D.grupos = 'FUNCIONARI')
				OR (D.grupos = 'PCP' AND D.iclis NOT IN ('CONSERTO','PERDAS', ''))
				OR (D.grupos = 'SEP'))
		AND D.inativas = 0
	ORDER BY D.grupos, D.rclis, B.dpros, A.emps