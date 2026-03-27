--Cadastro de Clientes
SELECT DISTINCT RTRIM(A.idcontas) AS 'NUM_LOJA', RTRIM(A.faxs) 'COD_LOJA', RTRIM(B.descs) AS 'TIPO_LOJA', RTRIM(A.iclis) AS 'COD_CLIENTE', RTRIM(A.rclis) AS 'CLIENTE', RTRIM(A.razaos) AS 'RAZAO SOCIAL',
			RTRIM(A.cpfs) AS 'CNPJ', CAST(A.obs AS varchar) AS 'NOME LOJA', RTRIM(A.cidas) AS 'CIDADE', RTRIM(A.estas) AS 'ESTADO', RTRIM(A.tabds) AS 'TBL_DESCONTO', RTRIM(A.contaven2s) AS 'COD_CONTA_MAE',
			RTRIM(C.rclis) AS 'CONTA_MAE'
FROM SigMvCab AS D WITH (NOLOCK)
		LEFT OUTER JOIN SIGCDCLI AS A WITH (NOLOCK) ON D.contads = A.iclis
		LEFT JOIN SigCdFpb (NOLOCK) B ON A.fpubls = B.cods
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaven2s = C.iclis
WHERE (D.dopes LIKE 'PED %' OR D.dopes LIKE 'PEDIDO %' OR D.dopes LIKE '%CONSERT%' OR D.dopes LIKE '%CONSERT%' OR D.dopes LIKE '%TRUNKSH%')
ORDER BY RTRIM(A.rclis)