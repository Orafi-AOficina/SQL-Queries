SELECT A.emps AS 'EMPRESA', A.codigos AS 'COD_BALANCO', A.grupos AS 'GRUPO',
		A.contas AS 'CONTA', C.rclis AS 'NOME', B.datars AS 'DATA/HORA', A.datais AS 'DATA INICIO', B.qtds AS 'FALHA_REAL',
		A.datas AS 'DATA FIM', A.usuars AS 'RESPONSAVEL',
		CASE
			WHEN C.inativas = 1 THEN 'INATIVA'
			WHEN C.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS'
FROM SigCdFcx A (NOLOCK)
LEFT JOIN SigMvHst B (NOLOCK) ON B.dopes = '' AND B.cpros = 'AU750' AND B.numes = A.codigos
LEFT JOIN SIGCDCLI C (NOLOCK) ON A.contas = C.iclis
ORDER BY B.datars DESC