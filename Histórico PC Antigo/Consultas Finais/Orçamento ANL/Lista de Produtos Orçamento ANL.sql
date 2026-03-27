SELECT DISTINCT G.descs AS 'CLIENTE', A.cgrus AS 'GRP_PROD', A.cpros AS 'COD_PROD', A.reffs AS 'REF_CLIENTE', A.dpros AS 'DESC_PROD', A.codcors AS 'COR',
			A.dtincs AS 'DTE_INCLUSAO',	A.datas AS 'ULT_ALTERACAO', A.codfinp AS 'COD_LINHA', E.descs AS 'LINHA', A.pesometal AS 'PESO_METAL', A.pesoms AS 'PESO_LIQ'--, H.*
	FROM SigCdPro A (NOLOCK)
		--TABELA COM O REGISTRO DAS ATUALIZAÇÔES DE COMPOSIÇÂO DE PRODUTOS
		--LEFT JOIN SigCdPrc B (NOLOCK) ON A.cpros = B.cpros
		LEFT JOIN (SELECT c.* FROM SIGPRCP2 c (nolock)
								INNER JOIN (select cpros, MAX(dataalts) as 'ult_alteracao'
												from SIGPRCP2 (nolock)
													group by cpros) d ON c.cpros = d.cpros and c.dataalts = d.ult_alteracao
								) C ON A.cpros = C.cpros
		--TABELA COM O REGISTRO DE CADA UMA DAS ETAPAS DO PROCESSO PRODUTIVO COM TEMPOS E INSTRUÇÕES DE MONTAGEM. PARECIDO COM FICHA TÉCNICA
		--LEFT JOIN SigCdPfc D (NOLOCK) ON A.cpros = D.produtos
		LEFT JOIN SIGCDFIP E (NOLOCK) ON E.cods = A.codfinp 
		LEFT JOIN SigCdGpr F (NOLOCK) ON A.mercs = F.codigos
		LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes
		WHERE F.descs = 'PRODUTOS'
					AND A.datas >= '2020-01-01'
					AND G.descs IN ('ANIMALE')
					AND A.reffs NOT IN ('PILOTO', '') 
	ORDER BY COD_PROD ASC