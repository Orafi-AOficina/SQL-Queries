SELECT *,
	DATEDIFF(day,ENTRADA, FINALIZACAO)*SALDO AS 'LT_x_PEÇA', DATEDIFF(day, PRAZO, FINALIZACAO) AS 'DESVIO_PRAZO',
	CASE WHEN DATEDIFF(day, PRAZO, FINALIZACAO) > 0 THEN DATEDIFF(day, PRAZO, FINALIZACAO)*SALDO ELSE 0 END AS 'ATRASO_x_PEÇA',
	MONTH(PRAZO) AS 'MES_PRAZO', YEAR(PRAZO) AS 'ANO_PRAZO' ,MONTH(FINALIZACAO) AS 'MES_FINALI', YEAR(FINALIZACAO) AS 'ANO_FINALI',
	CASE WHEN LEFT(DESCRIÇAO,4) IN ('TARR', 'MOSQ') THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'TARRAXA/MOSQUETAO'
	FROM
	(SELECT DISTINCT A.dopes as 'TIPO DE PEDIDO', B.rclis as 'CLIENTE', A.mascnum as 'PEDIDO', A.nops AS 'OP_PEDIDO', D.NOPS AS 'OP_ITEM', D.nopmaes AS 'OP_MAE',
				CASE
					WHEN D.nopmaes = 0 THEN D.nops
					WHEN D.nopmaes > 0 AND (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes) = 0 THEN D.nopmaes 
					WHEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))= 0 THEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes)
					ELSE (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))
				END AS 'OP_ORIGINAL',
				G.reffs AS 'REF_ANIMALE', C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', C.qtds AS 'QTD_INI', D.qtds AS 'SALDO',
				O.notas AS 'NF', A.datas AS 'ENTRADA', D.dataes AS 'ENTRADA_OP', A.PRAZOENTS AS 'PRAZO',
				(SELECT DISTINCT MAX(datas) FROM SigPdMvf
						where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
							AND nops = D.nops
				) AS FINALIZACAO, O.datas AS 'EMISSAO NF',
				CASE
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')) THEN 'FINALIZADO'
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZA S INDUSTRIA') ) THEN 'CANCELADO'
					ELSE 'PENDENTE'
				END AS 'STATUS',
				E.grupods AS 'GRUPO', E.contads AS 'CÓD_CONTA', F.rclis AS 'LOCAL',	E.DATAS AS 'ULTIMA MOV.', J.tpops AS 'ATIVIDADE', Convert(varchar(max),a.obses) as 'OBSERVAÇÃO',
				CASE
					WHEN H.cpros = 'RODIO 2,00' THEN H.qtds*D.qtds/C.qtds
					WHEN I.cgrus = 'INS' THEN H.qtds*D.qtds/C.qtds
					WHEN I.cgrus = 'BRI' THEN H.pesos*D.qtds/C.qtds
					WHEN I.cgrus = 'PED' THEN H.pesos*D.qtds/C.qtds
					WHEN I.cgrus = 'IMT' THEN H.qtds*D.qtds/C.qtds
				END AS 'QTD',
				(SELECT SUM(J.totas) FROM SigMvItn J (NOLOCK)
					WHERE J.empdopnums = C.empdopnums AND (C.citens = J.citem2 OR (J.cpros = C.cpros AND C.citem2 = 0)))*D.qtds/C.qtds AS 'VL_OP_S/IMP',
				CASE
					WHEN H.cpros = 'RODIO 2,00' THEN 'CUSTO_AU750'
					WHEN I.cgrus = 'INS' THEN 'IMT'
					WHEN I.cgrus = 'BRI' THEN 'BRILHANTES'
					WHEN I.cgrus = 'PED' THEN 'PEDRAS'
					WHEN I.cgrus = 'IMT' THEN 'IMT'
				END AS GRP_INS,
				M.codbarras AS 'CÓD. BARRAS', J.empdnps AS 'CHAVE FINALIZAÇÃO', K.empdopnums AS 'CHAVE FINAL NAC', N.empdopnums AS 'CHAVE NF'
	FROM SigMvCab A (NOLOCK)
	INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
	INNER JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0
	INNER JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps
					from sigpdmvf a (NOLOCK)
					--	join (select nops, cidchaves as cidchaves
						join (select nops, MAX(cidchaves) as cidchaves
									from SigPdMvf (NOLOCK)
										--WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
											--	('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
										group by nops 
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
	 					where dopps <> SPACE(20)
				) e on d.nops = e.nops
	LEFT JOIN SigCdNei J (NOLOCK) ON E.empdnps = J.empdnps
	LEFT JOIN SigMvCab K (NOLOCK) ON REPLACE(K.empdncrds, ' ','') = REPLACE(E.empdnps, ' ', '') AND K.dopes = 'FINALIZA NACIONAL   '
	LEFT JOIN SIGMvItn M (NOLOCK) ON K.empdopnums = M.empdopnums AND M.cpros = C.cpros
	LEFT JOIN SigMvItn N (NOLOCK) ON C.cpros = N.cpros AND M.codbarras = N.codbarras AND N.dopes IN ('NF RET INDUSTRIALIZA', 'NF VENDA', 'NF VENDA PILOTO', 'ENVIO ROMANEIO')
	LEFT JOIN SigMvCab O (NOLOCK) ON N.empdopnums = O.empdopnums --AND O.dopes IN ('NF RET INDUSTRIALIZA', 'NF VENDA', 'NF VENDA PILOTO', 'ENVIO ROMANEIO')
	LEFT JOIN sigcdcli F (NOLOCK) on e.contads = F.iclis
	LEFT JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
	LEFT JOIN SigMvItn H (NOLOCK) ON H.empdopnums = C.empdopnums AND (C.citens = H.citem2 OR (H.cpros = C.cpros AND C.citem2 = 0))
	LEFT JOIN SigCdPro I (NOLOCK) ON I.cpros = H.cpros
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2020'
	 			--AND D.nops IN ('69540003', '69540027')
--	ORDER BY D.nops
--	GROUP BY A.dopes, B.rclis, A.mascnum, A.nops, D.NOPS, C.CPROS, D.dpros, G.codcors, A.datas, A.PRAZOENTS, C.qtds,H.cidchaves,
--	 			D.qtds, E.grupods, E.contads, F.rclis, E.DATAS, Convert(varchar(max),a.obses), G.reffs, H.cpros, I.cgrus, H.qtds,
--	 			C.empdopnums, C.citem2, C.citens, D.nopmaes, J.tpops, H.pesos, J.empdnps
) AS TABELA
PIVOT
	(SUM(QTD) FOR GRP_INS IN ([CUSTO_AU750], [BRILHANTES], [PEDRAS], [IMT])
) AS PIVOTADA
ORDER BY PRAZO, OP_ITEM --STATUS DESC, ENTRADA ASC, PEDIDO ASC, OP_ITEM ASC