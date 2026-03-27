SELECT * FROM
	(SELECT DISTINCT F.rclis AS CLIENTE, A.dopes AS TIPO_PEDIDO,
		A.datas AS ENTRADA, A.prazoents AS PRAZO, A.mascnum AS PEDIDO, A.nops AS OP_MAE, ROUND(C.totas/(1-0.276),2) AS 'VALOR', --D.nops AS 'OP', B.cpros AS 'COD', B.dpros AS 'DESCRICAO', 
	--	(SELECT SUM(J.totas) FROM SigMvItn J (NOLOCK) 
	--					WHERE J.empdopnums = C.empdopnums AND (C.citens = J.citem2 OR (J.cpros = C.cpros AND C.citem2 = 0))
	--						AND D.nops NOT IN (SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
	--												('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))) AS 'VL_OP_S/IMP',
		CAST(A.obses AS NVARCHAR(4000)) OBSERVAÇÃO,A.compet AS MES_ANL, H.COTACAO_AU, H.COTACAO_USD, K.STATUS AS 'STATUS'
		--(SELECT TOP 1 ROUND((G.units/G.pesos/0.75/1.1/1.05), 2) FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
			--														AND B.cpros = G.cpros AND G.pesos > 0) AS COTACAO_AU,
		--(SELECT TOP 1 ROUND(AVG(G.totas/G.univals/G.qtds/1.1), 2) FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
			--														AND G.moevs = 'US' AND G.univals > 0 AND G.qtds > 0) AS COTACAO_USD
		--, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO
	FROM SigMvCab (NOLOCK) A
	INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
	INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums=C.empdopnums AND (B.citens = C.citem2 OR (B.cpros = C.cpros AND B.citem2 = 0))
	INNER JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros
	INNER JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
	INNER JOIN SIGCDCLI (NOLOCK) F ON A.contads = F.iclis
	LEFT JOIN (SELECT DISTINCT
						(SELECT TOP 1 ROUND((G.units/G.pesos/0.75/1.1/1.05), 2) FROM SigMvItn (NOLOCK) G WHERE I.empdopnums = G.empdopnums
																	AND I.cpros = G.cpros AND G.pesos > 0) AS COTACAO_AU,
						(SELECT TOP 1 ROUND(AVG(G.totas/G.univals/G.qtds/1.1), 2) FROM SigMvItn (NOLOCK) G WHERE I.empdopnums = G.empdopnums
																	AND G.moevs = 'US' AND G.univals > 0 AND G.qtds > 0) AS COTACAO_USD,
						I.empdopnums
					FROM SigMvItn (NOLOCK) I
						WHERE I.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
							'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
							AND I.citem2 = 0) H ON C.empdopnums = H.empdopnums
	LEFT JOIN (SELECT nops,
							CASE
								WHEN nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')) THEN 'FINALIZADO'
								WHEN nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZA S INDUSTRIA') ) THEN 'CANCELADO'
								ELSE 'PENDENTE'
							END AS STATUS
					FROM SigPdMvf) K ON K.nops = D.nops
	--INNER JOIN SigMvItn (NOLOCK) G ON G.citens = B.citem2 AND G.empdopnums=C.empdopnums AND G.citem2 = 0
	--LEFT JOIN SigOpPic (NOLOCK) F ON A.empdopnums = F.empdopnums AND 
	WHERE A.datas > '2019-01-01'
		AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
					'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
		AND D.nopmaes = 0
		AND A.nops = 6848
	--GROUP BY A.cidchaves, A.empdopnums, A.dopes, A.datas, A.prazoents, A.mascnum, A.nops,
	--				CAST(A.obses AS NVARCHAR(4000)), A.compet, F.rclis, H.COTACAO_AU, H.COTACAO_USD, D.nops, K.STATUS,  C.cpros, C.dpros
	--ORDER BY A.datas DESC, A.mascnum
) AS TABELA
PIVOT (
	SUM(VALOR) FOR STATUS IN ([PENDENTE], [FINALIZADO], [CANCELADO])
) AS PIVOTADA
ORDER BY ENTRADA, OP_MAE