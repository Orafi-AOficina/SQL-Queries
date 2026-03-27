-- COLOCAR O DISTINCT ABAIXO
--SELECT A.cidchaves AS UKEY_PEDIDO, A.empdopnums, F.iclis AS COD_CLIENTE, F.rclis AS CLIENTE, A.dopes AS TIPO_PEDIDO, A.datas AS DATA_ENTRADA,
SELECT DISTINCT A.cidchaves AS UKEY_PEDIDO, A.empdopnums, F.iclis AS COD_CLIENTE, F.rclis AS CLIENTE, A.dopes AS TIPO_PEDIDO, A.datas AS DATA_ENTRADA,
	A.prazoents AS PRAZO_ENTREGA, A.mascnum AS PEDIDO, A.nops AS OP_MAE, D.nops AS OP, E.reffs AS REF_CLIENTE,
	B.cpros AS COD_PRODUTO, B.dpros AS DESC_PRODUTO, E.codcors AS COR, B.qtds AS QTD, SUM(C.totas) AS 'VALOR_S/IMP',
	A.compet AS MES_COMPETENCIA_ANL,
	ROUND((SELECT TOP 1 G.units/G.pesos/0.75/1.1/1.05 FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND B.cpros = G.cpros AND G.pesos > 0), 2) AS COTACAO_AU,
	ROUND((SELECT TOP 1 AVG(G.totas/G.univals/G.qtds/1.1) FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND G.moevs = 'US' AND G.univals > 0 AND G.qtds > 0), 2) AS COTACAO_USD,
	(SELECT DISTINCT SUM(G.pesos*G.qtds)*0.75 FROM SigMvItn G WHERE C.empdopnums = G.empdopnums
																AND B.cpros = G.cpros AND G.pesos > 0) AS PESO_OFI,
--	(SELECT DISTINCT SUM(G.qtds*H.custofs), G.empdopnums, C.citens FROM SigMvItn G LEFT JOIN SigCdPro H ON G.cpros = H.cpros
	--									WHERE C.empdopnums = G.empdopnums AND C.citens = G.citem2
		--										AND G.moevs = 'AU' AND G.univals > 0 AND G.qtds > 0) AS PESO_IMT
		SUM(I.PESO_IMT) AS 'PESO_IMT'
	--SUM(C.pesos) AS PESO_AU, SUM(C.qtds) AS PESO_IMT
--	, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, C.*
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = C.empdopnums AND (B.citens = C.citem2 OR (B.cpros = C.cpros AND B.citem2 = 0))
LEFT JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros
LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
LEFT JOIN SIGCDCLI (NOLOCK) F ON A.contads = F.iclis
LEFT JOIN (SELECT DISTINCT SUM(G.qtds*H.custofs) AS PESO_IMT, G.empdopnums, G.citens
				FROM SigMvItn G
					LEFT JOIN SigCdPro H ON G.cpros = H.cpros
							WHERE G.moevs = 'AU' AND G.univals > 0 AND G.qtds > 0
							GROUP BY G.empdopnums, G.citens) I ON C.empdopnums = I.empdopnums AND I.citens = C.citens
--INNER JOIN SigMvItn (NOLOCK) G ON G.citens = B.citem2 AND G.empdopnums=C.empdopnums AND G.citem2 = 0
--LEFT JOIN SigOpPic (NOLOCK) F ON A.empdopnums = F.empdopnums AND 
WHERE A.datas > '2020-02-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
	AND D.nopmaes = 0
	AND A.mascnum = 20210
GROUP BY A.cidchaves, A.empdopnums, A.dopes, A.datas, A.prazoents, A.mascnum, A.nops, D.nops, E.reffs, B.cpros,
				B.dpros, B.qtds, A.compet, F.iclis, F.rclis, E.codcors, C.empdopnums
ORDER BY A.datas DESC, A.mascnum, D.nops