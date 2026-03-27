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
				H.pesos*D.qtds/C.qtds AS 'PESOS_COMP', H.qtds*D.qtds/C.qtds AS 'QTDS_COMP', --L.datas AS 'DATA_SAÍDA', L.empdopnums AS 'SAÍDA_PRODUÇÃO', 
				SUM(L.pesos) AS 'QTD_SAÍDA', SUM(L.qtds) AS 'QTD_TOT_SAÍDA', L.cunis AS 'UN_SAÍDA', SUM(L.qtbaixas) AS 'BAIXA_SAÍDA',
				K.cpros AS 'CÓD_MOV', K.dpros AS 'DESC_MOV', K.cgrus AS 'GRP_MOV', J.pesos AS 'PESOS_MOV' , J.qtds AS 'QTD_MOV', J.peso2s AS 'PESO2S_MOV',
				E.grupoos AS 'GRP_CONTA', F.iclis AS 'COD_CONTA', F.rclis AS 'LOCAL', E.DATAS AS 'ULTIMO MOV.', J.tpops AS 'ATIVIDADE',
				M.datas AS 'ULT_MOV_CONC', M.tpops AS 'ULT_ATIVI_CONC',
				N.ordems AS 'ORDEM', N.grupos AS 'ULT_ATIV', N.minutos AS 'ULT_TEMPO', LEFT(Convert(varchar(max),N.obs),9) AS 'ULT_COMPLEX',
				P.grupos AS 'ATUAL_ATIV', P.minutos AS 'ATUAL_TEMPO', LEFT(Convert(varchar(max),P.obs),9) AS 'ATUAL_COMPLEX',
				Q.grupos AS 'PROX_ATIV', Q.minutos AS 'PROX_TEMPO', LEFT(Convert(varchar(max),Q.obs),9) AS 'PROX_COMPLEX',
				(SELECT DISTINCT MAX(datas) FROM SigPdMvf
						where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
							AND nops = D.nops
				) AS 'FINALIZACAO',
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
												('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
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
	LEFT JOIN (SELECT n.datas, n.empdopnums, n.cpro2s, n.cpros, n.OP, p.nops, n.pesos, n.qtds, n.cunis, n.qtbaixas
					FROM (SELECT l.empdopnums, m.cpro2s, m.cpros, l.datas, m.pesos, m.qtds, m.cunis, m.qtbaixas,
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
	LEFT JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps, a.cidchaves, c.tpops, c.cmats--, c.dopps
					from sigpdmvf a (NOLOCK)
						join (select distinct aa.nops, MAX(aa.cidchaves) as cidchaves
									from SigPdMvf aa (NOLOCK)
										left join SigCdNei bb (NOLOCK) ON aa.empdnps = bb.empdnps
										WHERE aa.nops NOT IN (SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
												('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
												AND bb.tpops NOT IN ('ENVIO MATERIAL ', 'DEVOL MATERIAL ')
										group by aa.nops
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves
						left join SigCdNei c (NOLOCK) ON a.empdnps = c.empdnps
	 					where a.dopps <> SPACE(20)
				) M on D.nops = M.nops AND (M.cmats = I.cpros OR G.cpros = I.cpros)
	LEFT JOIN (select d.* from SigCdPfc d (nolock)
										INNER JOIN (select produtos, MAX(dataalts) as 'ult_alteracao'
														from SigCdPfc (nolock)
														group by produtos) dd on dd.produtos = d.produtos and d.dataalts = dd.ult_alteracao
								) N ON D.cpros = N.produtos AND ((LEFT(M.tpops, 4) = LEFT(N.grupos, 4) AND N.grupos <> ''))
	LEFT JOIN (select d.* from SigCdPfc d (nolock)
										INNER JOIN (select produtos, MAX(dataalts) as 'ult_alteracao'
														from SigCdPfc (nolock)
														group by produtos) dd on dd.produtos = d.produtos and d.dataalts = dd.ult_alteracao
								) P ON D.cpros = P.produtos AND ((P.ordems = N.ordems + 1) OR (F.iclis = 'PCP' AND P.ordems = 1)) -- OR (P.ordems = 0 AND N.ordems = 1))
	LEFT JOIN (select d.* from SigCdPfc d (nolock)
										INNER JOIN (select produtos, MAX(dataalts) as 'ult_alteracao'
														from SigCdPfc (nolock)
														group by produtos) dd on dd.produtos = d.produtos and d.dataalts = dd.ult_alteracao
								) Q ON D.cpros = Q.produtos AND (Q.ordems = P.ordems + 1) -- OR (P.ordems = 0 AND N.ordems = 2))
	--LEFT JOIN SigCdNei N (NOLOCK) ON M.empdnps = N.empdnps AND N.nops = D.nops AND (N.cmats = I.cpros OR G.cpros = I.cpros)
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '2020-01-01'
	 			AND (G.cpros <> I.cpros OR (G.cpros = I.cpros AND K.cgrus = 'IAU') OR (G.cpros = I.cpros AND K.cgrus IS NULL))
	 			--AND (I.cgrus IN ('IMT', 'BRI', 'PED', 'INS') OR I.cpros LIKE 'RODIO%')
	 			AND (I.cgrus <> 'SER' OR I.cpros LIKE 'RODIO%')
	 			--AND A.mascnum = '200119'
	 			--AND D.nops IN ('69540003', '69540027')
	GROUP BY A.dopes, B.rclis, A.mascnum, A.nops, D.NOPS, C.CPROS, D.dpros, G.codcors, A.datas, A.PRAZOENTS, C.qtds,H.cidchaves,D.qtds, E.grupoos,
	 			F.iclis, F.rclis, E.DATAS, Convert(varchar(max),a.obses), G.reffs, H.cpros, I.cgrus,  H.qtds,C.empdopnums, C.citem2, C.citens,
	 			D.nopmaes, J.tpops, H.pesos, J.pesos , J.qtds , J.peso2s, J.empdnps , K.cpros, K.dpros, K.cgrus, I.cpros, I.dpros, G.cpros, L.cunis,
	 			M.datas, M.tpops, N.ordems, N.grupos, N.minutos, Convert(varchar(max), N.obs), P.grupos, P.minutos, Convert(varchar(max), P.obs),
	 			Q.grupos, Q.minutos, Convert(varchar(max), Q.obs)
				--L.datas, L.empdopnums, L.pesos, L.qtds, , L.qtbaixas
ORDER BY PRAZO DESC, OP_ITEM