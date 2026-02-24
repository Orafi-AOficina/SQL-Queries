SELECT DISTINCT DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), DAY(A.datas)) AS 'DATA_REF', A.cpros AS 'INSUMO', A.dopes AS 'OPERACAO',
	A.numes AS 'NUM_MOVIMENTO', A.opers AS 'TIPO', C.nops AS 'OP', D.cpros AS 'COD_PRODUTO', D.dpros AS 'DESC_PRODUTO',
	CASE
	WHEN A.opers LIKE 'S'
		THEN -A.qtds
--		THEN (SELECT DISTINCT SUM(-B.qtds) FROM SigMvHst B WHERE
--			DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), DAY(A.datas))=DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas))
--			AND A.opers = B.opers AND A.numes=B.numes)
	WHEN A.opers LIKE 'E'
		THEN A.qtds
--		THEN (SELECT DISTINCT SUM(B.qtds) FROM SigMvHst B WHERE
--			DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), DAY(A.datas))=DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas))
--			AND A.opers = B.opers AND A.numes=B.numes)
	END AS 'QTD',
	A.estos AS 'COD_FUNCIONARIO', E.rclis AS 'NOME', A.grupos AS 'GRUPO', A.usuars AS 'RESP_MOV', A.datas AS 'DATA/HORA',
	CASE
			WHEN E.inativas = 1 THEN 'INATIVA'
			WHEN E.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS'
FROM SigMvHst A (NOLOCK)
	LEFT JOIN SigCdNei C (NOLOCK) ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps
	LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops
	LEFT JOIN SIGCDCLI E (NOLOCK) ON A.estos = E.iclis
WHERE (A.dopes = 'TRABALHADOS S/ OP   ' OR A.dopes  = 'TRABALHADOS         ') AND A.cpros = 'AU750'
		AND A.datas >= '2018-01-01'
--		AND E.rclis LIKE 'BALANÇO' 
ORDER BY A.datas ASC