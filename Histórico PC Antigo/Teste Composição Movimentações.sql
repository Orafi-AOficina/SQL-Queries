SELECT DISTINCT A.dopes as 'TIPO DE PEDIDO', B.rclis as 'CLIENTE', A.mascnum as 'PEDIDO', A.nops AS 'OP_PEDIDO', D.NOPS AS 'OP_ITEM', D.nopmaes AS 'OP_MAE',
				CASE
					WHEN D.nopmaes = 0 THEN D.nops
					WHEN D.nopmaes > 0 AND (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes) = 0 THEN D.nopmaes 
					WHEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))= 0 THEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes)
					ELSE (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))
				END AS 'OP_ORIGINAL',
				G.reffs AS 'REF_ANIMALE', C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', C.qtds AS 'QTD_INI', D.qtds AS 'SALDO', A.datas AS 'ENTRADA', A.PRAZOENTS AS 'PRAZO',
				(SELECT SUM(J.totas) FROM SigMvItn J (NOLOCK)
					WHERE J.empdopnums = C.empdopnums AND (C.citens = J.citem2 OR (J.cpros = C.cpros AND C.citem2 = 0)))*D.qtds/C.qtds AS 'VL_OP_S/IMP',
				CASE
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')) THEN 'FINALIZADO'
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZA S INDUSTRIA') ) THEN 'CANCELADO'
					ELSE 'PENDENTE'
				END AS 'STATUS',
				CASE
					WHEN G.cpros = I.cpros THEN 'PEÇA'
					WHEN H.cpros LIKE 'RODIO%' THEN 'RODIO'
					WHEN I.cgrus = 'INS' THEN 'IMT'
					WHEN I.cgrus = 'BRI' THEN 'BRILHANTES'
					WHEN I.cgrus = 'PED' THEN 'PEDRAS'
					WHEN I.cgrus = 'IMT' THEN 'IMT'
				END AS 'GRP_COMP',
				I.cpros AS 'COD_COMP', I.dpros AS 'DESC_COMP',
				CASE
					WHEN H.cpros LIKE 'RODIO%' THEN H.qtds*D.qtds/C.qtds
					WHEN I.cgrus = 'INS' THEN H.qtds*D.qtds/C.qtds
					WHEN I.cgrus = 'BRI' THEN H.pesos*D.qtds/C.qtds
					WHEN I.cgrus = 'PED' THEN H.pesos*D.qtds/C.qtds
					WHEN I.cgrus = 'IMT' THEN H.qtds*D.qtds/C.qtds
				END AS 'QTD_COMP',
				H.pesos AS 'PESOS_COMP', H.qtds AS 'QTDS_COMP',
				K.cpros AS 'CÓD_MOV', K.dpros AS 'DESC_MOV', K.cgrus AS 'GRP_MOV', J.pesos AS 'PESOS_MOV' , J.qtds AS 'QTD_MOV', J.peso2s AS 'PESO2S_MOV',
				E.grupoos AS 'GRP_CONTA', F.iclis AS 'COD_CONTA', F.rclis AS 'LOCAL',	E.DATAS AS 'ULTIMO MOV.', J.tpops AS 'ATIVIDADE',
				(SELECT DISTINCT MAX(datas) FROM SigPdMvf
						where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
							AND nops = D.nops
				) AS FINALIZACAO,
				CASE WHEN LEFT(D.dpros,4) IN ('TARR', 'MOSQ') THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'TARRAXA/MOSQUETAO',
				J.empdnps, Convert(varchar(max),a.obses) as 'OBSERVAÇÃO'
	FROM SigMvCab A (NOLOCK)
	INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
	INNER JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0
	INNER JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps, a.cidchaves 
					from sigpdmvf a (NOLOCK)
						join (select nops, MAX(cidchaves) as cidchaves
									from SigPdMvf (NOLOCK)
										--WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
											--	('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
										group by nops 
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves
	 					where dopps <> SPACE(20)
				) e on d.nops = e.nops
	LEFT JOIN sigcdcli F (NOLOCK) on e.contaos = F.iclis
	LEFT JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
	LEFT JOIN SigMvItn H (NOLOCK) ON H.empdopnums = C.empdopnums AND (C.citens = H.citem2 OR (H.cpros = C.cpros AND C.citem2 = 0))
	LEFT JOIN SigCdPro I (NOLOCK) ON I.cpros = H.cpros
	FULL JOIN SigCdNei J (NOLOCK) ON E.empdnps = J.empdnps AND J.nops = D.nops AND (J.cmats = I.cpros OR G.cpros = I.cpros)
	LEFT JOIN SigCdPro K (NOLOCK) ON K.cpros = J.cmats 
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2019'
	 			AND (G.cpros <> I.cpros OR (G.cpros = I.cpros AND K.cgrus = 'IAU') OR (G.cpros = I.cpros AND K.cgrus IS NULL))
	 			--AND (I.cgrus IN ('IMT', 'BRI', 'PED', 'INS') OR I.cpros LIKE 'RODIO%')
	 			AND (I.cgrus <> 'SER' OR I.cpros LIKE 'RODIO%')
	 			--AND A.mascnum = '200119'
	 			--AND D.nops IN ('69540003', '69540027')
	GROUP BY A.dopes, B.rclis, A.mascnum, A.nops, D.NOPS, C.CPROS, D.dpros, G.codcors, A.datas, A.PRAZOENTS, C.qtds,H.cidchaves,D.qtds, E.grupoos,
	 			F.iclis, F.rclis, E.DATAS, Convert(varchar(max),a.obses), G.reffs, H.cpros, I.cgrus,  H.qtds,C.empdopnums, C.citem2, C.citens,
	 			D.nopmaes, J.tpops, H.pesos, J.pesos , J.qtds , J.peso2s, J.empdnps , K.cpros, K.dpros, K.cgrus, I.cpros, I.dpros, G.cpros
ORDER BY PRAZO DESC, OP_ITEM