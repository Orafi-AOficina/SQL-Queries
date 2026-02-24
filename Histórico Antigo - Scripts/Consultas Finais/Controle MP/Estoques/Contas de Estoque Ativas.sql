SELECT DISTINCT A.emps AS 'EMPRESA', A.grupos AS 'GRP_ESTOQUE', D.grupos AS 'GRP_CONTA', D.iclis AS 'COD_CONTA', D.RCLIS AS 'NOME_CONTA', D.razaos AS 'DESCRITIVO', --MAX(E.datas) AS 'DT_BALANÇO',	
	--COUNT(B.cpros) AS 'NUM_INSUMOS', --SUM(A.sqtds), SUM(A.spesos),
	--B.cpros, B.dpros, A.sqtds, A.spesos, E.DT_BALANCO, 
		CASE
			WHEN D.inativas = 1 THEN 'INATIVA'
			WHEN D.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS' --, F.descs--, MAX(H.datas)
	FROM sigmvest A (NOLOCK)
		LEFT JOIN sigcdpro B (NOLOCK) ON A.cpros = B.cpros
		LEFT JOIN SIGCDPSG C (NOLOCK) ON B.CGRUS = C.CGRUS and B.sgrus = C.codigos
		LEFT JOIN SIGCDCLI D (NOLOCK) ON A.ESTOS = D.ICLIS
		LEFT JOIN (SELECT G.emps AS 'EMP', G.codigos AS 'CODIGO', G.grupos AS 'GRUPO', G.contas AS 'CONTA', G.datas AS 'DATAS', G.usuars AS 'USUAR', I.DT_BALANCO AS 'DT_BALANCO'
						FROM SigCdFcx G (NOLOCK)
						INNER JOIN 
							(SELECT H.grupos AS 'grupos', H.contas as 'contas', MAX(datas) AS DT_BALANCO
										FROM SigCdFcx H (NOLOCK)
											GROUP BY H.grupos, H.contas)
							I ON G.grupos = I.grupos AND G.contas = I.contas AND I.DT_BALANCO = G.datas
					) E ON A.grupos = E.GRUPO AND A.estos = E.CONTA AND A.emps = E.EMP
		LEFT JOIN SigCdGpr F (NOLOCK) ON B.mercs = F.codigos
	WHERE (A.SQTDS <> 0 OR A.spesos <> 0) AND 
		D.inativas = 0
		--AND D.iclis = '0000000116'
		--GROUP BY A.emps, A.grupos, D.grupos, D.iclis, D.rclis, D.inativas, D.razaos
		ORDER BY D.grupos, D.rclis, A.emps