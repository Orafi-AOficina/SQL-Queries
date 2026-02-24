SELECT A.grupos AS 'GRUPO_MOV', C.grupos AS 'GRUPO_CONTA',
		C.iclis AS 'CONTA', C.rclis AS 'NOME', C.razaos AS 'MATRÍCULA', 
		CASE
			WHEN C.inativas = 1 THEN 'INATIVA'
			WHEN C.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS',
		MIN(B.datars) AS 'PRIM_BALANCO', MAX(B.datars) AS 'ULT_BALANCO', COUNT(B.datars) AS 'NUM_DE_BALANCOS'
		--, A.datais AS 'DATA INICIO', A.datas AS 'DATA FIM', A.usuars AS 'RESPONSAVEL'
FROM SigCdFcx A (NOLOCK)
	LEFT JOIN SigMvHst B (NOLOCK) ON B.numes = A.codigos --AND B.cpros = 'AU750' B.dopes = '' AND 
	RIGHT JOIN SIGCDCLI C (NOLOCK) ON A.contas = C.iclis
WHERE C.inativas = 0
	AND C.grupos = 'FUNCIONARI'
GROUP BY A.grupos, C.iclis, C.rclis, C.razaos, C.inativas, C.grupos
ORDER BY C.inativas DESC, C.rclis ASC