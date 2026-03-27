--Dias úteis com trabalho na fábrica
--Dias com movimentação na fábrica
SELECT DISTINCT CAST(A.datas AS DATE) AS 'DATA'
		FROM SigCdNec (NOLOCK) A
		WHERE A.datas >= '2021-09-01'