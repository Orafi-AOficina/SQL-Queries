SELECT A.cpros, A.reffs, A.dpros, B.descs AS 'LINHA'
	FROM SigCdPro A (NOLOCK)
		INNER JOIN SIGCDFIP B (NOLOCK) ON B.cods = A.codfinp 