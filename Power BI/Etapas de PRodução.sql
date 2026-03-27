--Etapas de Produção cadastradas em cada produto seguindo ficha técnica (não é uma informação validada, está incompleta e cheia de erros!)
SELECT RTRIM(A.produtos) AS 'COD_PRODUTOS', A.ordems AS 'N_ETAPA', A.ordems +1 AS 'N_ETAPA_PROXIMA', A.dataalts AS 'DATA_ATUALIZACAO', RTRIM(A.grupos) AS 'OPERACAO', A.minutos AS 'TEMPO',
		CASE
			WHEN A.obs LIKE '%SIMPLES%' THEN 'SIMPLES'
			WHEN A.obs LIKE '%#MEDIO%' THEN 'MEDIO'
			WHEN A.obs LIKE '%COMPLEXO%' THEN 'COMPLEXO'
		END AS 'COMPLEXIDADE', A.obs AS 'OBS',
		CONCAT(A.ordems,'_'+RTRIM(A.produtos)) AS 'INDEX_ETAPA', CONCAT((A.ordems+1), '_'+RTRIM(A.produtos)) AS 'INDEX_ETAPA_PROXIMA', RTRIM(A.produtos) + '_' + RTRIM(A.grupos) AS 'INDEX_ETAPA_PRODUTO' 
	FROM SigCdPfc (NOLOCK) A
		WHERE A.dataalts = (SELECT DISTINCT MAX(dataalts) FROM SigCdPfc WHERE A.produtos = produtos GROUP BY produtos)
				AND A.dataalts >= '2021-09-01'