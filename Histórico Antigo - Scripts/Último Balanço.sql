SELECT A.grupos AS 'GRUPO',
		A.contas AS 'CONTA', C.rclis AS 'NOME', MIN(B.datars) AS 'PRIM_BALANCO',
		MAX(B.datars) AS 'ULT_BALANCO', COUNT(B.datars) AS 'NUM_BALANCO'
		--, A.datais AS 'DATA INICIO', A.datas AS 'DATA FIM', A.usuars AS 'RESPONSAVEL'
FROM SigCdFcx A (NOLOCK)
INNER JOIN SigMvHst B (NOLOCK) ON B.dopes = '' AND B.cpros = 'AU750' AND B.numes = A.codigos
LEFT JOIN SIGCDCLI C (NOLOCK) ON A.contas = C.iclis 
GROUP BY A.grupos, A.contas, C.rclis
ORDER BY C.rclis ASC