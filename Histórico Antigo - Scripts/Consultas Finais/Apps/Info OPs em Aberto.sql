SELECT DISTINCT A.dopes as 'TIPO DE PEDIDO', B.rclis as 'CLIENTE', A.mascnum as 'PEDIDO', A.nops AS 'OP_PEDIDO', D.NOPS AS 'OP_ITEM', D.nopmaes AS 'OP_MAE',
				CASE
					WHEN D.nopmaes = 0 THEN D.nops
					WHEN D.nopmaes > 0 AND (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes) = 0 THEN D.nopmaes 
					WHEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))= 0 THEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes)
					ELSE (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))
				END AS 'OP_ORIGINAL',
				G.reffs AS 'REF_ANIMALE', C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', C.qtds AS 'QTD_INI', D.qtds AS 'SALDO', A.datas AS 'ENTRADA', A.PRAZOENTS AS 'PRAZO',
				E.grupods AS 'GRUPO', E.contads AS 'CÓD_CONTA', F.rclis AS 'LOCAL',	E.DATAS AS 'ULTIMA MOV.', J.tpops AS 'ATIVIDADE',
				CASE WHEN LEFT(D.dpros,4) IN ('TARR', 'MOSQ') THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'TARRAXA/MOSQUETAO',
				P.ordems AS 'NUM_ETAPA',
				P.grupos AS 'ATUAL_ATIV', P.minutos AS 'ATUAL_TEMPO', LEFT(Convert(varchar(max),P.obs),9) AS 'ATUAL_COMPLEX',
				Q.grupos AS 'PROX_ATIV', Q.minutos AS 'PROX_TEMPO', LEFT(Convert(varchar(max),Q.obs),9) AS 'PROX_COMPLEX'
	FROM SigMvCab A (NOLOCK)
	INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
	INNER JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0
	INNER JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps
					from sigpdmvf a (NOLOCK)
					--	join (select nops, cidchaves as cidchaves
						join (select nops, MAX(cidchaves) as cidchaves
									from SigPdMvf (NOLOCK)
										WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
												('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
										group by nops 
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
	 					where dopps <> SPACE(20)
				) e on d.nops = e.nops
	LEFT JOIN sigcdcli F (NOLOCK) on e.contads = F.iclis
	LEFT JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
	LEFT JOIN SigCdNei J (NOLOCK) ON E.empdnps = J.empdnps
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
				) M on D.nops = M.nops
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
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2019'
ORDER BY A.PRAZOENTS DESC, A.mascnum ASC