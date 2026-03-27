SELECT DISTINCT A.dopes as 'TIPO DE PEDIDO', B.rclis as 'CLIENTE', A.mascnum as 'PEDIDO', A.nops AS 'OP_PEDIDO', D.NOPS AS 'OP_ITEM',
				G.reffs AS 'REF_ANIMALE', C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', A.datas AS 'ENTRADA',
				A.PRAZOENTS AS 'ENTREGA', C.qtds AS 'QTD_INI', E.qtds AS 'SALDO', CAST(a.obses AS varchar(MAX)) as 'OBSERVAÇÃO',
				(SELECT DISTINCT MIN(datas) FROM SigPdMvf
							where dopps in ('MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ')
								AND nops = D.nops
					) AS MUDA_SETOR_ESTOQ,
				E.datas AS DATA_MOV, I.tpops AS ATIVIDADE
	FROM SigMvCab A (NOLOCK)
	INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
	LEFT JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros 
	INNER JOIN (select a.*  
					from sigpdmvf a (NOLOCK)
						join (select nops, cidchaves as cidchaves
									from SigPdMvf (NOLOCK)
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
	 					where dopps <> SPACE(20)
				) e on d.nops = e.nops
	INNER JOIN sigcdcli F (NOLOCK) on e.contads = F.iclis
	INNER JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
	INNER JOIN SigCdNei I (NOLOCK) ON E.empdnps = I.empdnps
	INNER JOIN (SELECT DISTINCT MAX(datas) AS 'DT_FINALIZA', nops AS 'nops' FROM SigPdMvf K (NOLOCK)
							where nops not in (SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
								('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
							GROUP BY nops
					) AS J ON J.nops = D.nops
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2019'
	 ORDER BY A.mascnum, D.nops, E.datas DESC