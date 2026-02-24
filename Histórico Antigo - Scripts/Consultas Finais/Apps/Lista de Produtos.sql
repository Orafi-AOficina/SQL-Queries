SELECT DISTINCT A.colecoes AS 'MARCA', A.reffs AS 'REFERENCIA', A.cpros AS 'COD_PROD', A.dpros AS 'DESC_PROD'--, A.mercs--, *
	FROM DB_ORF_REL.dbo.SigCdPro AS A
WHERE 
	A.mercs NOT IN ('INS', 'DIV', 'FER', 'SER')
	--AND A.mercs = 'SER'
	--AND A.colecoes = 'ANL'
ORDER BY A.colecoes