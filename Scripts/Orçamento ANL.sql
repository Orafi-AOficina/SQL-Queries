--COMPLETA
SELECT A.datas AS 'DATA', A.emps AS 'EMPRESA', A.dopes AS 'OPERACAO', A.numes AS 'NUM_OPERACAO', C.iclis AS 'COD_CONTA', C.rclis AS 'CLIENTE',
			A.usuars AS 'USUARIO', B.citens AS 'ID', D.reffs AS 'REF_ANL', D.obscompras AS 'COR_ANL', D.idecpros AS 'ID_VARIACAO', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESCRICAO_PRODUTO', D.codcors AS 'COR', G.mercs AS 'GRANDE_GRP',
			G.cgrus AS 'GRUPO', F.cpros AS 'COD_INSUMO', F.dpros AS 'DESC_INSUMO', F.qtds AS 'QTD1', F.cunis AS 'UN1', F.pesos AS 'QTD2', F.moevs AS 'MOEDA',
			F.units, F.univals, F.totas AS 'VALOR LINHA', E.AU AS 'CUSTO_AU', E.US AS 'CUSTO_US', D.colecoes AS 'GRUPO_VENDA', A.tpfats AS 'TIPO_FATUR', A.vars AS 'GROSSUP'
	FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON A.empdopnums = B.empdopnums
		LEFT JOIN SigMvItn (NOLOCK) F ON F.empdopnums = B.empdopnums AND B.citem2 = 0 AND (B.citens = F.citem2 OR B.citens = F.citens)
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contads = C.iclis
		LEFT JOIN SigCdPro (NOLOCK) D ON B.cpros = D.cpros
		LEFT JOIN (SELECT empdopnums, [US]+0 AS 'US', [AU]+0 AS 'AU'
							FROM ( SELECT empdopnums, moeds, moevals FROM SigMvMov (NOLOCK) WHERE DOPES = 'ORÇAMENTO') AS origem
							PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt) E ON E.empdopnums = A.empdopnums
		LEFT JOIN SigCdPro (NOLOCK) G ON G.cpros = F.cpros
	WHERE D.mercs = 'PA' AND A.dopes = 'ORÇAMENTO' AND A.datas > '01-01-2023' AND B.citem2 = 0 AND D.colecoes = 'ANL'
ORDER BY A.datas DESC, A.numes DESC, B.citens ASC



--Produtos
SELECT A.datas AS 'DATA', A.emps AS 'EMPRESA', A.dopes AS 'OPERACAO', A.numes AS 'NUM_OPERACAO', C.iclis AS 'COD_CONTA', C.rclis AS 'CLIENTE',
			A.usuars AS 'USUARIO', B.citens AS 'ID', D.reffs AS 'REF_ANL', D.obscompras AS 'COR_ANL', D.idecpros AS 'ID_VARIACAO', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESCRICAO_PRODUTO', D.codcors AS 'COR',
			E.AU AS 'CUSTO_AU', E.US AS 'CUSTO_US', D.colecoes AS 'GRUPO_VENDA', A.tpfats AS 'TIPO_FATUR', A.vars AS 'GROSSUP'
	FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON A.empdopnums = B.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contads = C.iclis
		LEFT JOIN SigCdPro (NOLOCK) D ON B.cpros = D.cpros
		LEFT JOIN (SELECT empdopnums, [US]+0 AS 'US', [AU]+0 AS 'AU'
							FROM ( SELECT empdopnums, moeds, moevals FROM SigMvMov (NOLOCK) WHERE DOPES = 'ORÇAMENTO') AS origem
							PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt) E ON E.empdopnums = A.empdopnums
	WHERE D.mercs = 'PA' AND A.dopes = 'ORÇAMENTO' AND A.datas > '01-01-2023' AND B.citem2 = 0 AND D.colecoes = 'ANL'
ORDER BY A.datas DESC, A.numes DESC, B.citens ASC





--Composição Orçamento
SELECT A.datas AS 'DATA', A.emps AS 'EMPRESA', A.dopes AS 'OPERACAO', A.numes AS 'NUM_OPERACAO', B.citens AS 'ID', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESCRICAO_PRODUTO', G.mercs AS 'GRANDE_GRP',
			G.cgrus AS 'GRUPO', F.cpros AS 'COD_INSUMO', F.dpros AS 'DESC_INSUMO', F.qtds AS 'QTD1', F.cunis AS 'UN1', F.pesos AS 'QTD2', F.moevs AS 'MOEDA',
			F.totas AS 'VALOR LINHA', E.AU AS 'CUSTO_AU', E.US AS 'CUSTO_US', D.colecoes AS 'GRUPO_VENDA', A.tpfats AS 'TIPO_FATUR'
	FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON A.empdopnums = B.empdopnums
		LEFT JOIN SigMvItn (NOLOCK) F ON F.empdopnums = B.empdopnums AND B.citem2 = 0 AND (B.citens = F.citem2 OR B.citens = F.citens)
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contads = C.iclis
		LEFT JOIN SigCdPro (NOLOCK) D ON B.cpros = D.cpros
		LEFT JOIN (SELECT empdopnums, [US]+0 AS 'US', [AU]+0 AS 'AU'
							FROM ( SELECT empdopnums, moeds, moevals FROM SigMvMov (NOLOCK) WHERE DOPES = 'ORÇAMENTO') AS origem
							PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt) E ON E.empdopnums = A.empdopnums
		LEFT JOIN SigCdPro (NOLOCK) G ON G.cpros = F.cpros
	WHERE D.mercs = 'PA' AND A.dopes = 'ORÇAMENTO' AND A.datas > '01-01-2023' AND B.citem2 = 0 AND D.colecoes = 'ANL'
ORDER BY A.datas DESC, A.numes DESC, B.citens ASC