SELECT G.descs AS 'CLIENTE', A.cgrus AS 'GRP_PROD', A.sgrus AS 'SUBGRP_PROD', A.cpros AS 'COD_PROD', A.reffs AS 'REF_CLIENTE', A.dpros AS 'DESC_PROD', A.codcors AS 'COR', A.dtincs AS 'DTE_INCLUSAO',
			A.datas AS 'ULT_ALTERACAO', D.usuaalts AS 'USUARIO_ALT', A.codfinp AS 'COD_LINHA', E.descs AS 'LINHA', A.pesometal AS 'PESO_METAL', A.pesoms AS 'PESO_LIQ', 
			D.ordems AS 'ORDEM', D.grupos AS 'ATIVIDADE', D.minutos AS 'TEMPO(MIN)', D.obs AS 'OBSERVAÇÃO'
	FROM SigCdPro A (NOLOCK)
		--TABELA COM O REGISTRO DE CADA UMA DAS ETAPAS DO PROCESSO PRODUTIVO COM TEMPOS E INSTRUÇÕES DE MONTAGEM. PARECIDO COM FICHA TÉCNICA
		LEFT JOIN (select d.* from SigCdPfc d (nolock)
										INNER JOIN (select produtos, MAX(dataalts) as 'ult_alteracao'
														from SigCdPfc (nolock)
														group by produtos) dd on dd.produtos = d.produtos and d.dataalts = dd.ult_alteracao
								) D ON A.cpros = D.produtos
		LEFT JOIN SIGCDFIP E (NOLOCK) ON E.cods = A.codfinp 
		LEFT JOIN SigCdGpr F (NOLOCK) ON A.mercs = F.codigos
		LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes 
			WHERE F.descs = 'PRODUTOS'
						AND G.descs IN ('ANIMALE')
						--AND D.grupos = 'PRE POLIME'
						--AND A.cpros IN ('AN00547       ','COL00514')
	ORDER BY A.datas DESC, A.cpros ASC