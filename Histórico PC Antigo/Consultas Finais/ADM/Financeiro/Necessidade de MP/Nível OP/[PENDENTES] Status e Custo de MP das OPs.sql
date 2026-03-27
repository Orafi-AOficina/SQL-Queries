SELECT DISTINCT A.dopes as 'TIPO DE PEDIDO', B.rclis as 'CLIENTE', A.mascnum as 'PEDIDO', A.nops AS 'OP_PEDIDO', D.NOPS AS 'OP_ITEM', D.nopmaes AS 'OP_MAE',
				CASE
					WHEN D.nopmaes = 0 THEN D.nops
					WHEN D.nopmaes > 0 AND (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes) = 0 THEN D.nopmaes 
					WHEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))= 0 THEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes)
					ELSE (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))
				END AS 'OP_ORIGINAL',
				G.reffs AS 'REF_ANIMALE', C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', A.datas AS 'ENTRADA',
				A.PRAZOENTS AS 'PRAZO', C.qtds AS 'QTD_INI', E.qtds AS 'SALDO', E.grupods AS 'GRUPO', E.contads AS 'CÓD_CONTA',
				F.rclis AS 'LOCAL',	E.DATAS AS 'ULTIMA MOV.', J.tpops AS 'ATIVIDADE', Convert(varchar(max),a.obses) as 'OBSERVAÇÃO',
				(SELECT DISTINCT MAX(datas) FROM SigPdMvf
						where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
							AND nops = D.nops
				) AS FINALIZACAO,
				CASE
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')) THEN 'FINALIZADO'
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZA S INDUSTRIA') ) THEN 'CANCELADO'
					ELSE 'PENDENTE'
				END AS 'STATUS',
				(SELECT SUM(J.totas) FROM SigMvItn J (NOLOCK) 
					WHERE J.empdopnums = C.empdopnums AND (C.citens = J.citem2 OR (J.cpros = C.cpros AND C.citem2 = 0)))*D.qtds/C.qtds AS 'VL_OP_S/IMP',
				ROUND((SELECT SUM(J.totas) FROM SigMvItn J (NOLOCK) 
					WHERE J.empdopnums = C.empdopnums AND (C.citens = J.citem2 OR (J.cpros = C.cpros AND C.citem2 = 0)))*D.qtds/C.qtds/(1-0.276),2) AS 'VL_OP_C/IMP',
	ROUND((SELECT TOP 1 G.units/G.pesos/0.75/1.1/1.05 FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND C.cpros = G.cpros AND G.pesos > 0), 2) AS COTACAO_AU,
	ROUND((SELECT TOP 1 AVG(G.totas/G.univals/G.qtds/1.1) FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND G.moevs = 'US' AND G.univals > 0 AND G.qtds > 0), 2)*D.qtds/C.qtds AS COTACAO_USD,
				(SELECT DISTINCT SUM(G.pesos*G.qtds)*0.75 FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND C.cpros = G.cpros AND G.pesos > 0)*D.qtds/C.qtds AS PESO_OFI,
				(SELECT DISTINCT SUM(G.univals*G.qtds)*1.1 FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND G.moevs = 'US' AND G.univals > 0 AND G.qtds > 0 AND C.citens = G.citem2)*D.qtds/C.qtds AS CUSTO_USD,
				(SELECT DISTINCT SUM(G.univals*G.qtds)*1.1 FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND G.moevs = 'R' AND G.univals > 0 AND G.qtds > 0 AND C.citens = G.citem2)*D.qtds/C.qtds AS CUSTO_BRL
				, C.empdopnums 
	FROM SigMvCab A (NOLOCK)
	INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
	INNER JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0
	INNER JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, A.QTDS, a.empdnps
					from sigpdmvf a (NOLOCK)
					--	join (select nops, cidchaves as cidchaves
						join (select nops, MAX(cidchaves) as cidchaves
									from SigPdMvf (NOLOCK)
										WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
												('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
										group by nops 
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
	 					where dopps <> SPACE(20) --
				) e on d.nops = e.nops
	LEFT JOIN sigcdcli F (NOLOCK) on e.contads = F.iclis
	LEFT JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
	LEFT JOIN SigMvItn H (NOLOCK) ON H.empdopnums = C.empdopnums AND (C.citens = H.citem2 OR (H.cpros = C.cpros AND C.citem2 = 0))
	LEFT JOIN SigCdPro I (NOLOCK) ON I.cpros = H.cpros
	LEFT JOIN SigCdNei J (NOLOCK) ON E.empdnps = J.empdnps
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2019'
	 			--AND D.nops IN ('69540003')
	GROUP BY A.dopes, B.rclis, A.mascnum, A.nops, D.NOPS, D.nopmaes, D.qtds, C.CPROS, D.dpros, G.codcors, A.datas, A.PRAZOENTS, C.qtds,H.cidchaves,
	 			E.qtds, E.grupods, E.contads, F.rclis, E.DATAS, Convert(varchar(max),a.obses), G.reffs, H.cpros, I.cgrus, H.qtds,
	 			C.empdopnums, C.citem2, C.citens, J.tpops
	 			
	 			
--teste qtd AU750
SELECT SUM(G.pesos*G.qtds)*0.75 FROM SigMvItn G WHERE G.empdopnums = 'ORFPEDIDO DE FABRICA    20234' AND 'COL00415      ' = G.cpros AND G.pesos > 0