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
				H.pesos AS 'PESOS_COMP', H.qtds AS 'QTDS_COMP', --L.datas AS 'DATA_SAÍDA', L.empdopnums AS 'SAÍDA_PRODUÇÃO', 
				L.pesos AS 'QTD_SAÍDA', L.qtds AS 'QTD_TOT_SAÍDA', L.cunis AS 'UN_SAÍDA', L.qtbaixas AS 'BAIXA_SAÍDA',
				K.cpros AS 'CÓD_MOV', K.dpros AS 'DESC_MOV', K.cgrus AS 'GRP_MOV', J.pesos AS 'PESOS_MOV' , J.qtds AS 'QTD_MOV', J.peso2s AS 'PESO2S_MOV',
				E.grupoos AS 'GRP_CONTA', F.iclis AS 'COD_CONTA', F.rclis AS 'LOCAL',
				--(SELECT DISTINCT MAX(datas) FROM SigPdMvf
					--	where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
						--	AND nops = D.nops)
				M.FINALIZA AS 'FINALIZACAO', M.ANO_FINALI AS 'ANO_FINALI', M.MES_FINALI AS 'MES_FINALI',
				CASE
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')) THEN 'FINALIZADO'
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZA S INDUSTRIA') ) THEN 'CANCELADO'
					ELSE 'PENDENTE'
				END AS 'STATUS',
				CASE WHEN LEFT(D.dpros,4) IN ('TARR', 'MOSQ') THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'TARRAXA/MOSQUETAO',
				CASE
					WHEN D.nopmaes <> 0 THEN 'N/A'	
					WHEN G.cpros = I.cpros THEN 'N/A'
					WHEN I.cgrus = 'SER' THEN 'N/A'
					WHEN I.cpros = 'PLACA OA' THEN 'N/A'
					WHEN ((I.dpros LIKE '%TARR%' OR I.dpros LIKE '%MOSQ%' OR I.dpros LIKE '%PLACA%') AND M.FINALIZA > '2020-01-01' AND K.cpros IS NULL) THEN 'N/A'
					WHEN (I.dpros LIKE '%TARR%' OR I.dpros LIKE '%MOSQ%' OR I.dpros LIKE '%PLACA%') AND L.qtds >= H.qtds*0.85 THEN 'VERDADEIRO'
					WHEN I.cgrus = 'BRI' AND H.pesos <= L.pesos THEN 'VERDADEIRO'
					WHEN I.dpros LIKE '%PEROLA%' AND L.qtds >= H.qtds*0.7 THEN 'VERDADEIRO'
					WHEN (I.dpros NOT LIKE '%TARR%' AND I.dpros NOT LIKE '%MOSQ%' AND I.dpros NOT LIKE '%PLACA%') AND I.cgrus <> 'BRI' AND L.qtds >= H.qtds THEN 'VERDADEIRO'
					WHEN (I.dpros NOT LIKE '%TARR%' AND I.dpros NOT LIKE '%MOSQ%' AND I.dpros NOT LIKE '%PLACA%') AND I.cgrus <> 'BRI' AND L.pesos >= H.pesos*D.qtds/C.qtds*0.85 THEN 'VERDADEIRO'
					ELSE 'FALSO'
				END AS 'DEU_SAÍDA?', Convert(varchar(max),L.OBS) as 'OBSERVAÇÃO'
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
		LEFT JOIN (SELECT n.cpro2s, n.cpros, n.OP, p.nops, SUM(n.pesos) as pesos, SUM(n.qtds) as qtds, n.cunis, SUM(n.qtbaixas) as qtbaixas, n.OBS
						FROM (SELECT m.cpro2s, m.cpros, l.datas, m.pesos, m.qtds, m.cunis, m.qtbaixas, Convert(varchar(max),l.obses) AS 'OBS',
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
											--PODE SER PUXADA PENDÊNCIA PARA OPs QUEBRADAS OU SÓ PARA AS ORIGINAIS!?!? SE SIM, A MÉTRICA PRECISA SER ALTERADA!!!!
 								INNER JOIN SigOpPic (NOLOCK) p ON LEFT(p.nops, 4) = n.OP AND p.nopmaes = 0 AND RTRIM(n.cpro2s) = RTRIM(p.cpros)
									WHERE p.nops <> 0 AND p.nopmaes = 0
								GROUP BY n.cpro2s, n.cpros, n.OP, p.nops, n.cunis, n.OBS
							) L ON L.nops = D.NOPS AND L.cpros = I.cpros
		LEFT JOIN (SELECT DISTINCT MAX(datas) AS FINALIZA, YEAR(MAX(datas)) AS ANO_FINALI, MONTH(MAX(datas)) AS MES_FINALI, nops FROM SigPdMvf (NOLOCK)
							where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
								GROUP BY nops
								) M ON M.nops = D.nops
		WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '2020-01-01'
	 			AND (G.cpros <> I.cpros OR (G.cpros = I.cpros AND K.cgrus = 'IAU') OR (G.cpros = I.cpros AND K.cgrus IS NULL))
	 			--AND (I.cgrus IN ('IMT', 'BRI', 'PED', 'INS') OR I.cpros LIKE 'RODIO%')
	 			AND (I.cgrus <> 'SER' OR I.cpros LIKE 'RODIO%')
				--TEMOS QUE IGNORAR AS OPs QUEBRADAS, POIS ELAS TEM 
	 			AND D.nopmaes = 0
	 			--AND D.nops = 71920001
	 			AND M.FINALIZA > '2021-01-01'
	 			--AND A.mascnum = '200119'
	 			--AND D.nops IN ('69540003', '69540027')
	--GROUP BY A.dopes, B.rclis, A.mascnum, A.nops, D.NOPS, C.CPROS, D.dpros, G.codcors, A.datas, A.PRAZOENTS, C.qtds,H.cidchaves,D.qtds, E.grupoos,
	-- 			F.iclis, F.rclis, E.DATAS, Convert(varchar(max),a.obses), G.reffs, H.cpros, I.cgrus,  H.qtds,C.empdopnums, C.citem2, C.citens,
	-- 			D.nopmaes, J.tpops, H.pesos, J.pesos , J.qtds , J.peso2s, J.empdnps , K.cpros, K.dpros, K.cgrus, I.cpros, I.dpros, G.cpros, L.cunis, L.OBS, L.OP,L.cpro2s, L.cpros, --, L.datas, L.empdopnums--,
	-- 			M.FINALIZA, M.ANO_FINALI, M.MES_FINALI
ORDER BY PRAZO DESC, OP_ITEM