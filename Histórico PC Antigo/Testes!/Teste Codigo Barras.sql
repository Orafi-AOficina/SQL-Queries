SELECT DISTINCT A.codbarras, A.cpros, A.dpros, COUNT(A.codbarras), MAX(A.dtalts),
	CASE
		WHEN COUNT(A.codbarras) = 1 THEN 'AGUARDANDO NF'
		WHEN COUNT(A.codbarras) > 1 THEN 'NF EMITIDA'
	END
FROM SigMvItn A
WHERE A.codbarras NOT LIKE 0
	AND A.dtalts > '2019-01-01'
GROUP BY A.codbarras, A.cpros, A.dpros
ORDER BY COUNT(A.codbarras), MAX(A.dtalts), A.codbarras, A.dpros