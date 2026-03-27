SELECT  A.emps, A.dopes, B.opers, A.datas, A.dtalts, A.grupoos, A.contaos, A.grupods, A.contads, B.cpros, B.dpros, B.qtds, B.cunis, B.pesos, B.cunips, B.moedas, B.moevals, B.units, B.univals,
	A.valinis, A.valos, A.obses, A.empdopnums, B.citens, A.usuars
FROM SigMvCab A
	INNER JOIN SigMvItn B ON A.empdopnums = B.empdopnums
WHERE A.dopes IN ('BAIXA SALDO         ','LANÇA SALDOS        ')
ORDER BY A.datas DESC