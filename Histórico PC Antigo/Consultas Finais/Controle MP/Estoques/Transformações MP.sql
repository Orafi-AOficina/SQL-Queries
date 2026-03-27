SELECT A.datars, A.datas, A.dopes, A.mascnum, A.grupoos, A.contaos, C.rclis, A.grupods, A.contads, D.rclis, B.cpros, B.dpros, B.opers, B.qtds, B.cunis, B.pesos, B.cunips, B.univals, B.moedas, B.totas AS 'VALOR_REAIS',
	A.usuars, B.obs
FROM SigMvCab (NOLOCK) A
	INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
	INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
	INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
	WHERE A.dopes IN ('TRANSFORMA MT PRIMA ') AND A.datas >= '2020-01-01'
	ORDER BY A.datars DESC, A.mascnum, B.citens