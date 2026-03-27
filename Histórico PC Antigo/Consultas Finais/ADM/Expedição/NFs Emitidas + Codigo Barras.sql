SELECT A.codbarras AS 'CÓDIGO BARRAS', E.nops AS 'OP', A.cpros AS 'CÓD. PRODUTO', A.dpros AS 'DESCRIÇÃO PRODUTO', A.qtds AS 'QTD',
--	(SELECT TOP 1 COUNT(D.codbarras) FROM SigMvHst (NOLOCK) D WHERE A.codbarras = D.codbarras ORDER BY COUNT(D.codbarras) DESC) AS 'INDEX',
	A.dtalts AS 'LIBERAÇÃO', C.pesos AS 'PESO PADRÃO', C.spesos AS 'PESO TOTAL', D.EMPDOPNUMS AS 'CHAVE_MAE', E.empdnps AS 'OPERAÇÃO_FIN',
	D.NOTAS AS 'NUM_NF', A.QTDS AS 'QTD', A.QTBAIXAS AS 'QTD BAIXADA', A.UNITS AS 'VL_UNITARIO', D.obses AS 'OBSERVÇÃO', J.notas AS 'NFs'
FROM SigMvItn (NOLOCK) A
	INNER JOIN (SELECT B.* FROM SigMvHst (NOLOCK) B WHERE B.codbarras NOT LIKE 0) C ON A.codbarras = C.codbarras
	INNER JOIN SigMvCab (NOLOCK) D ON C.empdopnums = D.empdopnums
	INNER JOIN SigPdMvf (NOLOCK) E ON REPLACE(D.empdncrds, ' ','') = REPLACE(E.empdnps, ' ', '') 
	LEFT JOIN (SELECT F.* FROM SigOpPic (NOLOCK) F) H ON E.nops = H.nops
	LEFT JOIN (SELECT G.* FROM SigMvItn (NOLOCK) G
					WHERE G.dopes IN ('NF RET INDUSTRIALIZA', 'NF VENDA', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'ENVIO ROMANEIO',
						'NF DEVOLUÇÃO COMPRA', 'NF DEVOLUÇÃO COMPRA.', 'ADIANTA MP FINANC', 'CANCELA NF COMP PEDR', 'DEV RESUMO ENT PEDRA',
						'NF RET PURIFICAÇÃO', 'NF ENT INDUSTRIA')
						AND G.codbarras NOT LIKE 0) I ON H.empdopnums = I.empdopnums
	LEFT JOIN SigMvCab J ON J.empdopnums = I.empdopnums
WHERE A.codbarras NOT LIKE 0
	AND A.dtalts > '2019-01-01'
	AND (SELECT TOP 1 COUNT(D.codbarras) FROM SigMvHst (NOLOCK) D WHERE A.codbarras = D.codbarras ORDER BY COUNT(D.codbarras) DESC) > 1
ORDER BY A.dtalts DESC