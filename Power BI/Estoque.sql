--Posições de Estoque
SELECT RTRIM(A.emps) AS 'EMP', RTRIM(A.grupos) AS 'GRP_MOV', RTRIM(D.grupos) AS 'GRP_CONTA', RTRIM(D.iclis) AS 'COD_CONTA', RTRIM(D.RCLIS) AS 'DESC_CONTA', RTRIM(D.razaos) AS 'CPF',
			RTRIM(B.cgrus) AS 'GRP_INSUMO', RTRIM(B.cpros) AS 'COD_INSUMO', RTRIM(B.DPROS) AS 'DESC_INSUMO', A.sqtds AS 'QTD', B.cunis AS 'UN', A.spesos AS 'PESOS', RTRIM(B.moedas) AS 'MOEDA'
FROM sigmvest (NOLOCK) A 
		LEFT join sigcdpro (NOLOCK) B on A.cpros = B.cpros
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.ESTOS = D.ICLIS 
	WHERE (A.sqtds <> 0 OR A.spesos <> 0) AND D.grupos NOT IN ('CLIENTE','FORNECEDOR') AND D.iclis NOT IN ('ESTOQUE')
	ORDER BY RTRIM(A.grupos), RTRIM(D.rclis)