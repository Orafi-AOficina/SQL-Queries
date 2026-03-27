SELECT DISTINCT A.emps + A.notas AS 'CHAVE_NF', A.EMPDOPNUMS AS 'CHAVE_MAE', A.datas AS 'DATA', A.emps AS 'EMPRESA', A.DOPES AS 'OPERACAO', A.NUMES AS 'NUM_OPS',
		A.notas AS 'NUM_NF', SUM(C.QTDS*C.UNITS) AS 'VALOR_S/IPI', SUM(C.valipis) AS 'IPI', SUM(C.QTDS*C.UNITS + C.valipis) AS 'VALOR_TOT',
		J.rclis AS 'CLIENTE', CAST(A.obses AS varchar(max)) AS 'OBSERVÇÃO', G.stats AS 'STATUS', C.cfops AS 'CFOP', C.opers AS 'TIPO', P.cancelas AS 'CANCELA', P.series AS 'SERIE_NF',
		DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), 1) AS 'DATA_REF',
		L.dopes AS 'TIPO_PEDIDO', L.numes AS 'PEDIDO', L.numps AS 'OP_GERAL', G.stats AS 'STATUS', A.ultgrvs AS 'DEVOLUCAO'
		-- Q.qtds/Q.pesos AS 'QTD_UNIT', SEMPRE TEM ERRO DE DIVISÃO POR 0!!! UM DIA CORRIGIR!
	FROM SIGMVCAB A (NOLOCK)
		LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
		LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
		LEFT JOIN SigMvNfi P (NOLOCK) ON P.empdopnums = A.empdopnums
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
--WHERE B.tipoops in ('1','9') 
	WHERE A.DOPES IN ('NF VENDA FUTURA')
			AND C.citem2 = 0
			AND A.datas >='2023-01-01'
			AND (G.stats NOT LIKE '' OR G.stats IS NULL OR G.stats = '   ')
			--AND J.rclis = 'RBX RIO COMERCIO DE ROUPAS S.A.'
			--AND A.empdopnums = 'ORFNF VENDA              5667'
			--AND A.notas = '008094'
	GROUP BY A.notas, A.dopes, A.numes, A.nops, A.datas, A.emps, A.empdopnums, CAST(A.obses AS varchar(max)), J.rclis, G.stats, C.cfops, C.opers, P.cancelas, P.series,
				L.dopes, L.numes, L.numps, G.stats, A.ultgrvs
	ORDER BY A.datas ASC, A.notas ASC, A.DOPES ASC