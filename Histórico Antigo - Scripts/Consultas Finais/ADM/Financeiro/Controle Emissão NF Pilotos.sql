SELECT A.cidchaves AS 'UKEY_NF', A.EMPDOPNUMS AS 'CHAVE_MAE', A.datas AS 'DATA', A.DOPES AS 'OPERACAO', A.NUMES AS 'NUM_OPS',
	J.rclis 'CLIENTE', L.dopes AS 'TIPO_PEDIDO', L.numes AS 'PEDIDO', L.numps AS 'OP_GERAL', D.reffs AS 'REF_CLIENTE',
	 C.cpros AS 'CODIGO', C.dpros AS 'DESCRICAO', C.qtds AS 'QTD', C.units AS 'VALOR_INICIAL', C.unit2s AS 'VALOR_FINAL',
	C.valrats AS 'VARIACAO', C.pesos AS 'PESOS', C.codbarras AS 'COD_BARRAS', A.dtbaixas AS 'DATA_BAIXA',
	CASE
		WHEN A.chksubn = 1 THEN 'BAIXADO'
		WHEN A.chksubn = 0 THEN 'EM ABERTO'
	END AS 'STATUS',
	DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), 1) AS 'DATA_REF', A.obses AS 'OBSERVACAO', K.nops, P.*
FROM SIGMVCAB A (NOLOCK)
	LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
	LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
	LEFT JOIN SIGCDPRO D (NOLOCK) ON C.CPROS=D.CPROS
	LEFT JOIN SIGCDGRP E (NOLOCK) ON D.CGRUS=E.cgrus
	LEFT JOIN SIGCDCLI F (NOLOCK) ON A.CONTAOS=F.ICLIS
	LEFT JOIN SIGPRNFE G (NOLOCK) ON A.EMPDOPNUMS=G.EMPDOPNUMS AND G.datas = (SELECT MAX(I.datas) 
																	FROM sigprnfe I WHERE A.EMPDOPNUMS=I.EMPDOPNUMS GROUP BY I.empdopnums)
	LEFT JOIN SIGOPPIC H (NOLOCK) ON A.NOPS=H.NUMPS AND LTRIM(CONVERT(NVARCHAR,C.OBS))=CONVERT(NVARCHAR,H.NOPS)
	LEFT JOIN SIGCDCLI J (NOLOCK) ON A.contads=J.ICLIS
	LEFT JOIN SigMvItn M (NOLOCK) ON C.codbarras = M.codbarras AND C.cpros = M.cpros AND M.dopes = 'FINALIZA NACIONAL'
	LEFT JOIN SigMvCab N (NOLOCK) ON M.empdopnums = N.empdopnums
	LEFT JOIN SigPdMvf K (NOLOCK) ON REPLACE(N.empdncrds, ' ','') = REPLACE(K.empdnps, ' ', '')
	LEFT JOIN SigOpPic L (NOLOCK) ON L.nops = K.nops AND M.codbarras = L.codbarras
	LEFT JOIN (SELECT Q.emps + Q.notas AS 'CHAVE', Q.EMPDOPNUMS AS 'CHAVE_MAE', Q.datas AS 'DATA',
					Q.emps AS 'EMPRESA', Q.notas AS 'NUM_NF', Q.DOPES AS 'OPERACAO', Q.NUMES AS 'NUM_OPS', SUM(R.QTDS*R.UNITS + R.valipis) AS 'VALOR',
					CAST(Q.obses AS varchar(max)) AS 'OBSERVÇÃO', R.codbarras AS 'codbarras'
					FROM SigMvCab Q (NOLOCK)
							LEFT JOIN SigMvItn R (NOLOCK) ON Q.empdopnums = R.empdopnums
								WHERE Q.dopes = 'NF VENDA PILOTO'
									AND R.citem2 = 0 AND Q.datas >='2018-12-01'
					GROUP BY Q.emps, Q.notas, Q.empdopnums, Q.datas, Q.dopes, Q.numes, CAST(Q.obses AS varchar(max)), R.codbarras) P ON P.codbarras = M.codbarras
WHERE A.DOPES IN ( 'ENVIO PILOTO')
	AND C.citem2 = 0
	AND A.datas >='2018-12-01'
	AND (G.stats NOT LIKE '' OR G.stats IS NULL)
ORDER BY A.empdopnums DESC