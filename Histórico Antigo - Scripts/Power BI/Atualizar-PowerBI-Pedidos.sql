--Pedidos
SELECT DISTINCT A.cidchaves AS 'UKEY_PEDIDO', A.empdopnums AS 'CHAVE_PEDIDO', F.iclis AS 'COD_CLIENTE', F.rclis AS 'CLIENTE',
	A.dopes AS 'TIPO_PEDIDO', A.datas AS 'DATA_ENTRADA', A.prazoents AS 'PRAZO', A.mascnum AS 'PEDIDO',
	A.nops AS 'OP_PREFIXO', CAST(A.obses AS NVARCHAR(4000)) AS 'OBSERVA��O',
	A.compet AS 'MES_ANL',
	CASE
		WHEN F.iclis IN ('C000001558') THEN ROUND((SELECT TOP 1 G.units/G.pesos/0.75/1.1/1.05 
															FROM SigMvItn G WHERE A.empdopnums = G.empdopnums
																AND B.cpros = G.cpros AND G.pesos > 0), 2)
		ELSE NULL
	END AS COTACAO_AU,
	CASE
		WHEN F.iclis IN ('C000001558', 'C000001602') THEN ROUND((SELECT TOP 1 AVG(G.totas/G.univals/G.qtds/1.1)
															FROM SigMvItn G WHERE A.empdopnums = G.empdopnums
																AND G.moevs = 'US' AND G.univals > 0 AND G.qtds > 0), 2)
		ELSE NULL
	END AS COTACAO_USD
FROM SigMvCab (NOLOCK) A
INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = C.empdopnums AND (B.citens = C.citem2 OR (B.cpros = C.cpros AND B.citem2 = 0))
LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
LEFT JOIN SIGCDCLI (NOLOCK) F ON A.contads = F.iclis
WHERE A.datas > '2019-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')