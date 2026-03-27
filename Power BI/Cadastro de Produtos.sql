--Cadastro de Produto
SELECT RTRIM(C.descs)  AS 'TIPO_CADASTRO', RTRIM(D.colecoes) AS 'COD_GRP_VENDA', RTRIM(D.descs) AS 'GRUPO_VENDA', RTRIM(H.cgrus) AS 'GRP_PROD',
			RTRIM(H.dgrus) AS 'DESC_GRUPO', RTRIM(A.sgrus) AS 'COD_SUBGRUPO', RTRIM(G.descricaos) AS 'SUBGRUPO', RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.reffs) AS 'REF_CLIENTE',
			RTRIM(REPLACE(A.reffs,'.','')) AS 'REF_CLIENTE_TRATADA', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(J.cods) AS 'COR', RTRIM(J.descs) AS 'DESC_COR', A.matprincs AS 'METAL_PRINCIPAL',
			RTRIM(A.codtams) AS 'COD_TAMANHO', RTRIM(F.descs) AS 'TAMANHO', A.dtincs AS 'DTE_INCLUSAO', A.datas AS 'ULT_ALTERACAO', RTRIM(E.linhas) AS 'COD_LINHA', RTRIM(E.descs) AS 'LINHA',
			RTRIM(A.codfinp) AS 'COD_MODELO', RTRIM(B.descs) AS 'MODELO',
			CASE WHEN A.pesometal < A.pesoms THEN A.pesometal ELSE A.pesoms END AS 'PESO_METAL_CADASTRO', A.pesoms AS 'PESO_LIQ_CADASTRO',
			CASE
				WHEN A.situas = 1 THEN 'ATIVO'
				WHEN A.situas = 2 THEN 'INATIVO'
				ELSE 'ERRO' 
			END AS 'STATUS_PROD', A.obscompras AS 'COR_ANL', RTRIM(A.dpro2s) AS 'DESC_ANIMALE', RTRIM(A.idecpros) AS 'IDENTIFICADOR', RTRIM(A.codident) AS 'REF_DESENVOLVIMENTO',
			A.descfis AS 'DESC_FISCAL', RTRIM(I.codigos) AS 'COD_CLASS_FISCAL', RTRIM(I.descricaos) AS 'CLASS_FISCAL',
			CASE
				WHEN A.figjpgs IS NULL THEN 'VERDADEIRO'
				ELSE 'FALSO'
			END AS 'FOTO CADASTRADA', A.cbars AS 'CODBARRA_PROD', A.dpro3s AS 'DESC_SITE_OFICIAL', E.descs, C.descs
	FROM SigCdPro A (NOLOCK)
		LEFT JOIN SIGCDFIP B (NOLOCK) ON B.cods = A.codfinp
		LEFT JOIN SigCdGpr C (NOLOCK) ON A.mercs = C.codigos
		LEFT JOIN SIGCDCOL D (NOLOCK) ON A.colecoes =D.colecoes
		LEFT JOIN SigCdLin E (NOLOCK)  ON A.linhas = E.linhas
		LEFT JOIN SigCdTam F (NOLOCK)  ON A.codtams = F.cods
		LEFT JOIN SigCdPsg G (NOLOCK)  ON A.sgrus = G.codigos AND A.cgrus = G.cgrus
		LEFT JOIN SigCdGrp H (NOLOCK)  ON A.cgrus = H.cgrus
		LEFT JOIN SIGCDCLF I (NOLOCK)  ON A.clfiscals = I.codigos
		LEFT JOIN SigCdCor J (NOLOCK) ON A.codcors = J.cods
	WHERE ((C.descs = 'PRODUTOS'  AND A.datas >= '2021-09-01') OR (C.descs = 'INSUMOS' AND A.cgrus = 'IMT'))
	ORDER BY A.datas DESC