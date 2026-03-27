SELECT DISTINCT G.descs AS 'CLIENTE', A.cgrus AS 'GRP_PROD', A.sgrus AS 'SUBGRP_PROD', A.cpros AS 'COD_PROD', A.reffs AS 'REF_CLIENTE', A.dpros AS 'DESC_PROD', A.codcors AS 'COR', A.dtincs AS 'DTE_INCLUSAO',
			A.datas AS 'ULT_ALTERACAO', A.markupa AS 'MARKUP', A.codfinp AS 'COD_LINHA', E.descs AS 'LINHA', A.pesometal AS 'PESO_METAL', A.pesoms AS 'PESO_LIQ', 
			D.cgrus 'GRP_INSUMO', D.cpros AS 'COD_INSUMOS', D.dpros AS 'DESC_INSUMO', D.pesoms AS 'PESO_MEDIO', C.qtds AS 'QTD', C.qtdcvs AS 'QTD_2', C.unicompos AS 'UN_QTD', C.pesos AS 'PESOS',
			--C.cunips AS 'UN_PESOS',	C.pcompos AS 'VALOR', C.vlrcvs AS 'VALOR_2', C.moeds AS 'MOEDA', C.qtds * C.vlrcvs AS 'TOTAL', C.obscompos AS 'OBS', C.markcvs AS 'MARKUP_INS', D.margems AS 'MARGEM_INS',
			C.cunips AS 'UN_PESOS',	D.custofs AS 'VALOR', D.pvens AS 'VALOR_2', D.moedas AS 'MOEDA', C.qtds * D.pvens AS 'TOTAL', D.obspes AS 'OBS', ROUND(C.markcvs,3) AS 'MARKUP_INS', D.margems AS 'MARGEM_INS',			
			--D.custofs AS 'VALOR_B', D.pvens AS 'VALOR_2_B', D.moedas AS 'MOEDA_B', C.qtds * D.pvens AS 'TOTAL_B', D.obspes AS 'OBS_B', D.markupa AS 'MARKUP_INS_B',
			A.dpro2s AS 'DESCRITIVO',  Convert(varchar(max), A.dsccompras) AS 'DESCRICAO_COMPRA', H.nops AS 'ULT_OP_PRODUZIDA', H.empdnps AS 'ULT_FINALIZACAO', H.datas AS 'DATA_FINALIZACAO'
	FROM SigCdPro A (NOLOCK)
		--TABELA COM O REGISTRO DAS ATUALIZAÇÔES DE COMPOSIÇÂO DE PRODUTOS
		--LEFT JOIN SigCdPrc B (NOLOCK) ON A.cpros = B.cpros
		--LEFT JOIN (SELECT c.* FROM SIGPRCP2 c (nolock)
		--						INNER JOIN (select cpros, MAX(dataalts) as 'ult_alteracao'
		--										from SIGPRCP2 (nolock)
		--											group by cpros) d ON c.cpros = d.cpros and c.dataalts = d.ult_alteracao
		--						) C ON A.cpros = C.cpros
		--TABELA COM O REGISTRO DE CADA UMA DAS ETAPAS DO PROCESSO PRODUTIVO COM TEMPOS E INSTRUÇÕES DE MONTAGEM. PARECIDO COM FICHA TÉCNICA
		--LEFT JOIN SigCdPfc D (NOLOCK) ON A.cpros = D.produtos
		LEFT JOIN SIGPRCPO C (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
		LEFT JOIN SigCdPro D ON C.mats = D.cpros
		LEFT JOIN SIGCDFIP E (NOLOCK) ON E.cods = A.codfinp 
		LEFT JOIN SigCdGpr F (NOLOCK) ON A.mercs = F.codigos
		LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes 
		LEFT JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps, a.cidchaves, a.codpds
					from sigpdmvf a (NOLOCK)
						join (select k.cpros , MAX(j.cidchaves) as cidchaves
									from SigPdMvf (NOLOCK) j
										left join SigOpPic k on j.nops = k.nops
										--WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
											--	('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
									group by k.cpros
								) B ON A.cidchaves = B.cidchaves
	 						where dopps <> SPACE(20)
						) H on H.codpds = A.cpros
		WHERE F.descs = 'PRODUTOS'
					--AND G.descs IN ('ANIMALE')
					AND A.datas >= '2020-01-01'
					--AND A.cpros = 'COL00107'
	ORDER BY DTE_INCLUSAO DESC, COD_PROD ASC