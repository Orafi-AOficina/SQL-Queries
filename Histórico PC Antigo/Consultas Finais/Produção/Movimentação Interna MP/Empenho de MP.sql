SELECT A.citens, A.cpros, A.dpros, A.cunis, A.empdopnums, A.qtds, A.qtbaixas, A.pesos, A.cidchaves, A.dtalts, A.chksubn, B.chksubn,
	A.cpro2s, C.dpros, B.obses, B.usuars, B.chkbxparcs, B.dtalts, B.dtbaixas, B.ultgrvs
FROM SigMvItn (NOLOCK) A
	LEFT JOIN SigMvCab (NOLOCK) B ON A.empdopnums = B.empdopnums
	LEFT JOIN SigCdPro (NOLOCK) C ON A.cpro2s = C.cpros
WHERE A.dtalts > '2019-01-01' AND A.dopes = 'EMPENHO MT PRIMA    '
--	AND A.empdopnums = 'ORFEMPENHO MT PRIMA     10043'