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
				L.datas AS 'DATA_SAÍDA', L.empdopnums AS 'SAÍDA_PRODUÇÃO',
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
										WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
												('FINALIZA S INDUSTRIA'))
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
	LEFT JOIN (SELECT n.datas, n.empdopnums, n.cpro2s, n.cpros, n.OP, p.nops
					FROM (SELECT l.empdopnums, m.cpro2s, m.cpros, l.datas,
										LEFT(REPLACE(
													REPLACE(
															REPLACE(
																	REPLACE(
																			REPLACE( 
																					REPLACE(Convert(varchar(max),l.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP'
							FROM SigMvCab (NOLOCK) l
								LEFT JOIN SigMvItn (NOLOCK) m ON l.empdopnums = m.empdopnums 
								WHERE (l.dopes = 'SAIDA PRODUCAO      ' OR l.dopes = 'SAIDA PRODUCAO TOTAL')
											AND l.datas >= '2020-01-01') n
 							LEFT JOIN SigOpPic (NOLOCK) p ON LEFT(p.nops, 4) = n.OP AND p.nopmaes=0 AND REPLACE(p.cpros, RTRIM(n.cpro2s), '') <> p.cpros
							WHERE p.nops <> 0
						) L ON L.nops = D.NOPS AND L.cpros = I.cpros
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			--AND A.datas >= '2020-01-01'
	 			AND (G.cpros <> I.cpros OR (G.cpros = I.cpros AND K.cgrus = 'IAU') OR (G.cpros = I.cpros AND K.cgrus IS NULL))
	 			--AND (I.cgrus IN ('IMT', 'BRI', 'PED', 'INS') OR I.cpros LIKE 'RODIO%')
	 			AND (I.cgrus <> 'SER' OR I.cpros LIKE 'RODIO%')
	 			AND C.cpros IN ('12010483OA','12010484OA','12010485OA','12010487OB','12010488OB','12010521OB','12010522OB','12010523OB','12010524OB','12010525OB','12010526OB','12010526OB','12010527OA',
	 								'12010528OA','12010529OB','12010530OB','12010619OA','12010620OB','12010621OB','12010622OA','12010623OA','12021243OB','12021244OB','12021245OA','12021246OR','12021300OA',
	 								'12021301OA','12021308OA','12021367OB','12021368OB','12021369OB','12021370OR','12021371OB','12021371OB','12021371OB','12021372OB','12021373OB','12021472OB','12021473OA',
	 								'12021474OA','12021475OA','12021476OB','12021477OA','12021478OR','12021481OA','12030465OA','12030475OB','12030484OB','12030485OB','12030486OA','12030487OA','12030487OA',
	 								'12041198OB','120412450A','12041251OA','12041252OA','12041253OA','12041255OA','12041256OA','12041257OB','12041258OB','12041345OB','12041346OB','12041347OB','12041348OB',
	 								'12041349OA','12041350OB','12041351OB','12041352OB','12041353OB','12041354OR','12041356OB','12041357OB','12041363OR','12041407OB','12041408OA','12041409OB','12041410OA',
	 								'12041411OR','12041412OB','12041413OA','12041414OA','12010472OA','12021307OB','12021479OB','12021480OB','12041244OA','12041250OA','12041355OB')
	 			AND (I.cgrus = 'PED' OR G.cpros = I.cpros)
	 			--AND A.mascnum = '200119'
	 			--AND D.nops IN ('69540003', '69540027')
	GROUP BY A.dopes, B.rclis, A.mascnum, A.nops, D.NOPS, C.CPROS, D.dpros, G.codcors, A.datas, A.PRAZOENTS, C.qtds,H.cidchaves,D.qtds, E.grupoos,
	 			F.iclis, F.rclis, E.DATAS, Convert(varchar(max),a.obses), G.reffs, H.cpros, I.cgrus,  H.qtds,C.empdopnums, C.citem2, C.citens,
	 			D.nopmaes, J.tpops, H.pesos, J.pesos , J.qtds , J.peso2s, J.empdnps , K.cpros, K.dpros, K.cgrus, I.cpros, I.dpros, G.cpros, L.datas, L.empdopnums
ORDER BY REF_ANIMALE ASC, PRAZO DESC, OP_ITEM