SELECT A.cidchaves AS 'UKEY_NF', A.emps + A.notas AS 'CHAVE', A.EMPDOPNUMS AS 'CHAVE_MAE', A.datas AS 'DATA',
	A.emps AS 'EMPRESA', A.notas AS 'NUM_NF', A.DOPES AS 'OPERACAO', A.NUMES AS 'NUM_OPS', --SUM(C.QTDS*C.UNITS + C.valipis) AS 'VALOR',
	CASE 
		WHEN A.dopes IN ('ENVIO ROMANEIO', 'NF VENDA', 'NF VENDA PILOTO', 'NF RET INDUSTRIALIZA',
		'NF DEVOLU플O COMPRA.', 'DV ASS. TEC. C.CUSTO') THEN J.rclis
		ELSE F.RCLIS
	END AS 'CLIENTE',
	A.NOPS AS 'NUM_OP', CAST(A.obses AS varchar(max)) AS 'OBSERV플O', DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), 1) AS 'DATA_REF',
	L.dopes AS 'TIPO_PEDIDO', L.numes AS 'PEDIDO', L.numps AS 'OP_GERAL', G.stats AS 'STATUS', M.cpros, C.dpros, N.empdncrds, L.citens, --, K.nops AS 'OP'
	P.cdescs, P.cmats, P.pesos, P.qtds, R.cgrus
	--, A.obses AS 'OBSERVACAO' DEVERIA TER OBSERVA플O DA NF!!!
FROM SIGMVCAB A (NOLOCK)
LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
LEFT JOIN SIGCDPRO D (NOLOCK) ON C.CPROS=D.CPROS	
LEFT JOIN SIGCDGRP E (NOLOCK) ON D.CGRUS=E.cgrus
LEFT JOIN SIGCDCLI F (NOLOCK) ON A.CONTAOS=F.ICLIS
LEFT JOIN SIGPRNFE G (NOLOCK) ON A.EMPDOPNUMS=G.EMPDOPNUMS AND G.datas = (SELECT MAX(I.datas) FROM sigprnfe I WHERE A.EMPDOPNUMS=I.EMPDOPNUMS GROUP BY I.empdopnums)
LEFT JOIN SIGOPPIC H (NOLOCK) ON A.NOPS=H.NUMPS AND LTRIM(CONVERT(NVARCHAR,C.OBS))=CONVERT(NVARCHAR,H.NOPS)
LEFT JOIN SIGCDCLI J (NOLOCK) ON A.contads=J.ICLIS
LEFT JOIN SigMvItn M (NOLOCK) ON C.codbarras = M.codbarras AND C.cpros = M.cpros AND M.dopes = 'FINALIZA NACIONAL'
LEFT JOIN SigMvCab N (NOLOCK) ON M.empdopnums = N.empdopnums
LEFT JOIN SigPdMvf K (NOLOCK) ON REPLACE(N.empdncrds, ' ','') = REPLACE(K.empdnps, ' ', '')
LEFT JOIN SigOpPic L (NOLOCK) ON L.nops = K.nops AND M.codbarras = L.codbarras
LEFT JOIN SigCdNei P (NOLOCK) ON K.empdnps = P.empdnps
LEFT JOIN SIGCDPRO R (NOLOCK) ON R.cpros=P.cmats
--WHERE B.tipoops in ('1','9') 
WHERE A.DOPES IN ('NF RET INDUSTRIALIZA', 'NF VENDA', 'NF VENDA PILOTO', 'NF DEVOLU플O COMPRA', 
			'NF DEVOLU플O COMPRA.', 'DEV RESUMO ENT PEDRA',	'NF RET PURIFICA플O', 'NF ENT INDUSTRIA')
	--AND C.citem2 = 0
	AND A.datas >='2018-12-01'
	AND (G.stats NOT LIKE '' OR G.stats IS NULL)
	AND (R.cgrus = 'IMT' OR R.cgrus = 'IAU')
--GROUP BY A.cidchaves, A.notas, A.dopes, A.numes, F.rclis, A.nops, A.datas, A.emps, A.empdopnums, CAST(A.obses AS varchar(max)), J.rclis,
	--			L.dopes, L.numes, L.numps, G.stats--, N.empdncrds--, M.cpros, C.dpros, L.citens
ORDER BY DATA_REF ASC, A.notas ASC, L.numps, A.DOPES ASC, A.datas ASC