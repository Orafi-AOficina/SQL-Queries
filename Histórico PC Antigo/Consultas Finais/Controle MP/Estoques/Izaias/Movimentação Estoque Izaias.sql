SELECT A.datars AS 'DATA-HORA', A.datas AS 'DATA', A.dopes AS 'OPERARAÇAO', A.mascnum AS 'NUM_OP', A.grupoos AS 'GRUPO_ORG', A.contaos AS 'CONTA_ORG', C.rclis AS 'NOME_ORG',
	A.grupods AS 'GRUPO_DEST', A.contads AS 'CONTA_DEST', D.rclis AS 'NOME_DEST', B.cpros AS 'COD_INS', B.dpros AS 'DESC_INS', B.qtds AS 'QTD', B.cunis AS 'UNIT_QTD',
	B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2', B.univals AS 'VALOR', B.moedas AS 'MOEDA', B.totas AS 'VALOR_REAIS', A.usuars AS 'RESPONSAVEL', B.obs AS 'OBS'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
	WHERE (A.dopes = 'SAIDA PRODUCAO      ' OR A.dopes = 'SAIDA PRODUCAO TOTAL') AND A.datas >= '2020-01-01'
			AND (A.contaos IN ('F000000580') OR A.contads IN ('F000000580'))
	ORDER BY A.datars, A.mascnum, B.citens