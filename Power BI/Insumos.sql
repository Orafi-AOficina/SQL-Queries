--Cadastro de Insumos
SELECT RTRIM(C.descs)  AS 'TIPO_CADASTRO', RTRIM(H.cgrus) AS 'GRP_INSUMO', RTRIM(A.sgrus) AS 'COD_SUBGRUPO', RTRIM(G.descricaos) AS 'SUBGRUPO',
			RTRIM(A.cpros) AS 'COD_INSUMO', RTRIM(A.dpros) AS 'DESC_INSUMO', A.cunis AS 'UN', A.dtincs AS 'DTE_CAD_INS', A.datas AS 'ULT_ALT_INS', MAX(D.dtincs) AS 'ULT_CAD_PROD',
			MAX(D.datas) AS 'ULT_ALT_PROD', MAX(E.ULT_OP) AS 'ULT_OP',
			CASE
				WHEN A.situas = 1 THEN 'ATIVO'
				WHEN A.situas = 2 THEN 'INATIVO'
				ELSE 'ERRO' 
			END AS 'STATUS_PROD',
			A.cbars AS 'CODBARRA_PROD'
	FROM SigCdPro A (NOLOCK)
		LEFT JOIN SigCdGpr C (NOLOCK) ON A.mercs = C.codigos
		LEFT JOIN SigCdPsg G (NOLOCK)  ON A.sgrus = G.codigos AND A.cgrus = G.cgrus
		LEFT JOIN SigCdGrp H (NOLOCK)  ON A.cgrus = H.cgrus
		LEFT JOIN SIGCDCLF I (NOLOCK)  ON A.clfiscals = I.codigos
		LEFT JOIN SIGPRCPO B (NOLOCK) ON A.cpros = B.mats --AND C.mats = I.mats
		LEFT JOIN SigCdPro D (NOLOCK) ON B.cpros = D.cpros
		LEFT JOIN (SELECT MAX(dtgeras) AS 'ULT_OP', cpros FROM SigOpPic (NOLOCK) GROUP BY cpros) E ON E.cpros  = D.cpros
	WHERE A.mercs = 'INS'
	GROUP BY C.descs, H.cgrus, H.dgrus, A.sgrus, G.descricaos, A.cpros, A.dpros, A.dtincs, A.datas, A.situas, I.codigos, I.descricaos, A.cbars, A.cunis
	ORDER BY A.datas DESC