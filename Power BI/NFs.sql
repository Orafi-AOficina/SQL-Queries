--Resumo de Informações das NFs com os códigos de barra incluídos em cada uma das NFs
SELECT DISTINCT A.emps AS 'EMP', A.EMPDOPNUMS AS 'CHAVE_MAE', A.datas as 'DATA_NF', A.notas AS 'NUM_NF', C.codbarras AS 'FINALIZACAO', C.qtds AS 'QTD', P.cancelas AS 'CANCELA',
				RTRIM(P.series) AS 'SERIE_NF', C.citens, RTRIM(A.ultgrvs) AS 'DEVOLUCAO', REPLACE(N.empdncrds, ' ','') AS 'CHAVE_FINALIZACAO'
	FROM SIGMVCAB A (NOLOCK)
		LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
		LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
		LEFT JOIN SigMvNfi P (NOLOCK) ON P.empdopnums = A.empdopnums
		LEFT JOIN SigMvItn M (NOLOCK) ON C.codbarras = M.codbarras AND C.cpros = M.cpros
		LEFT JOIN SigMvCab N (NOLOCK) ON M.empdopnums = N.empdopnums
	WHERE A.DOPES IN ('NF VENDA', 'NF VENDA POF', 'NF VENDA PILOTO', 'NF VENDA GAL', 'NF RET INDUSTRIA GAL', 'NF RET INDUSTRIA GAL', 'NF RET INDUSTRIALIZA')
			AND C.citem2 = 0
			AND A.datas >='2023-01-01'
			AND M.dopes = 'FINALIZA NACIONAL'