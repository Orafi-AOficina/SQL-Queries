SELECT DISTINCT G.descs AS 'CLIENTE', A.cgrus AS 'GRP_PROD', A.sgrus AS 'SUBGRP_PROD', A.cpros AS 'COD_PROD', A.reffs AS 'REF_CLIENTE', A.dpros AS 'DESC_PROD', A.codcors AS 'COR', A.dtincs AS 'DTE_INCLUSAO',
			A.datas AS 'ULT_ALTERACAO', A.markupa AS 'MARKUP', A.usuincs AS 'USUARIO_INC', A.codfinp AS 'COD_LINHA', E.descs AS 'LINHA', A.pesometal AS 'PESO_METAL', A.pesoms AS 'PESO_LIQ', 
			A.custofs AS 'VLR_CUSTO', C.cgrus 'GRP_INSUMO', C.mats AS 'COD_INSUMOS', C.dcompos AS 'DESC_INSUMO', C.qtds AS 'QTD', C.qtdcvs AS 'QTD_2', C.unicompos AS 'UN_QTD', C.pesos AS 'PESOS',
			C.cunips AS 'UN_PESOS',	C.pcompos AS 'VALOR', C.vlrcvs AS 'VALOR_2', C.moeds AS 'MOEDA', C.qtds * C.vlrcvs AS 'TOTAL', C.obscompos AS 'OBS', C.markcvs AS 'MARKUP_INS',
			C.vlrpvs AS 'VALOR*MKP', A.codacbs AS 'ACABAMENTO', A.cbars AS 'COD_BARRA', A.clfiscals AS 'COD_FISCAL', A.idpro AS 'ID',	A.dpro2s AS 'DESCRITIVO',  Convert(varchar(max), A.dsccompras) AS 'DESCRICAO_COMPRA'
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
		LEFT JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps, a.cidchaves, a.codpds
					from sigpdmvf a (NOLOCK)
						join (select nops, MAX(cidchaves) as cidchaves
									from SigPdMvf (NOLOCK)
										--WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
											--	('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
									group by nops 
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves
	 						where dopps <> SPACE(20)
						) H on H.codpds = A.cpros
		WHERE F.descs = 'PRODUTOS'
					--AND G.descs IN ('ANIMALE')
					--AND A.cpros IN ('COL00510','COL00514')
	ORDER BY DTE_INCLUSAO DESC, COD_PROD ASC