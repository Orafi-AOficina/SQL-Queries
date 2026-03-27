--Composição do Cadastro de Produtos
--Composição do Produto
SELECT RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(D.mercs) AS 'GRANDE_GRP', RTRIM(D.cgrus) 'GRP_INSUMO', RTRIM(D.cpros) AS 'COD_INSUMOS', RTRIM(D.dpros) AS 'DESC_INSUMO',
			D.pesoms AS 'PESO_MEDIO', C.pesos AS 'PESOS', RTRIM(C.cunips) AS 'UN_PESOS', C.qtds AS 'QTD', C.qtdcvs AS 'QTD_2', RTRIM(C.unicompos) AS 'UN_QTD', D.custofs AS 'VALOR_INSUMO',
			D.margems AS 'MARGEM_INSUMO', D.pvens AS 'VAL_INSUMO_C_MARGEM', RTRIM(D.moedas) AS 'MOEDA', RTRIM(D.obspes) AS 'OBS', ROUND(C.markcvs,3) AS 'MARKUP_INS', C.obsofs AS 'OBS_INSUMO',
			Convert(varchar(max), A.dsccompras) AS 'DESCRICAO_COMPRA',
			CASE
				WHEN A.mercs = 'INS' THEN (SELECT SUM(AA.qtds) FROM SIGPRCPO (NOLOCK) AA WHERE AA.cpros = A.cpros AND AA.cgrus = 'IAU' GROUP BY AA.cpros) ELSE 0
			END AS 'PESO_IMT',
			RTRIM(H.codigos) AS 'COD_SUBGRUPO', RTRIM(H.descricaos) AS 'SUBGRUPO', RTRIM(H.descricaos) AS 'Insumo Tratado', RTRIM(E.dgrus) AS 'GRUPO_INS',
			CASE WHEN D.cgrus = 'IAU' THEN RTRIM(B.descs) ELSE RTRIM(F.descs) END AS 'COR_INS',
			CASE 
				WHEN D.cgrus IN ('IAU', 'INS', 'IMT') THEN ' '+RTRIM(B.descs)
				WHEN D.mercs = 'PED' THEN RTRIM(E.dgrus) + ' ' + ISNULL(RTRIM(F.descs), '')
			END AS 'DESC_BOOK_INS'
	FROM SigCdPro A (NOLOCK)
			LEFT JOIN SigCdCor B (NOLOCK) ON B.cods = A.codcors
			LEFT JOIN SIGPRCPO C (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
			INNER JOIN SigCdPro D (NOLOCK) ON C.mats = D.cpros
			LEFT JOIN SigCdGrp E (NOLOCK) ON D.cgrus = E.cgrus
			LEFT JOIN SigCdCor F (NOLOCK) ON F.cods = D.codcors
			LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes
			LEFT JOIN SigCdPsg H (NOLOCK) ON D.sgrus = H.codigos AND D.cgrus = H.cgrus
		WHERE ((A.mercs = 'PA' AND A.datas >= '2021-09-01') OR (A.mercs = 'INS' AND A.cgrus = 'IMT'))
	ORDER BY COD_PROD ASC