-- Tabela dos balanços é a SigCdFcx!!!
SELECT G.COD_BALANCO, G.COD_FUNCIONARIO, G.NOME, G.MATRICULA, G.OPERACAO, SUM(G.QTD) AS 'TRABALHADOS', D.qtds AS 'FALHA_REAL', D.qtds/SUM(G.QTD) AS '%FALHA', D.datars AS 'DATA/HORA', A.datais AS 'DATA INICIO',
			A.datas AS 'DATA FIM', A.usuars AS 'RESPONSAVEL', G.STATUS
FROM
	(SELECT C.cmats AS 'INSUMO', B.contaos AS 'COD_FUNCIONARIO', E.rclis AS 'NOME', E.razaos AS 'MATRICULA',
			--(SELECT DISTINCT MIN(F.numes) FROM SigMvHst F WHERE A.estos = F.estos AND A.datars <= F.datars AND F.dopes = '') AS 'COD_BALANCO',
			B.numbals AS 'COD_BALANCO',
			C.tpops AS 'OPERACAO', SUM(C.qtds) AS 'QTD',
	--		C.qtds AS 'QTD2', B.totpesos ,
			--A.qtds AS 'QTD',
			CASE
				WHEN E.inativas = 1 THEN 'INATIVA'
				WHEN E.inativas = 0 THEN 'ATIVA'
				ELSE 'VERIFICAR'
			END AS 'STATUS'--, B.*, C.*--, B.*
	--	FROM SigMvHst A (NOLOCK)
	--		LEFT JOIN SigCdNei C (NOLOCK) ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps AND A.cpros = C.cmats AND 
	--																				((A.dopes  = 'TRABALHADOS' AND A.qtds = C.qtds) OR (A.dopes = 'TRABALHADOS S/ OP'))-- AND A.qtds = C.qtds)) 
	--																				OR (A.dopes = 'TRABALHADOS S/ OP' AND B.totpesos = C.qtds))
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
	--		LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
		WHERE (B.dopps = 'TRABALHADOS S/ OP   ' OR B.dopps  = 'TRABALHADOS         ' OR B.dopps = 'FINALIZAÇÃO         ')
				AND C.cmats = 'AU750'
				--AND B.datas >= '2019-01-01'--
				AND E.inativas = 0 --AND A.numes = 13674-- AND A.datas <= '2019-02-10' 
				AND C.tpops IN ('OURIVESARIA.TRA', 'CRAVACAO.TRAB', 'POLIMENTO.TRAB', 'PRE-POLIMENTO', 'DEVOL MATERIAL')
	--			AND A.opers = 'S'
	--			AND B.numbals = 1708
				--AND B.contaos = '0000000072' --OR B.contads = '0000000072')--AND A.opers = 'S' AND A.datas <= '2020-09-23' --AND A.dopes = 'TRABALHADOS    ' 
		GROUP BY C.tpops, B.contaos , C.cmats , E.rclis, E.inativas, B.numbals, E.razaos) AS G
	LEFT JOIN SigCdFcx A (NOLOCK) ON A.codigos = G.COD_BALANCO
	LEFT JOIN SigMvHst D (NOLOCK) ON D.dopes = '' AND D.cpros = 'AU750' AND D.numes = A.codigos
	WHERE G.OPERACAO <> 'DEVOL MATERIAL'
GROUP BY G.COD_BALANCO, G.COD_FUNCIONARIO, G.NOME, G.MATRICULA, G.OPERACAO, G.STATUS, D.datars, A.datais, D.qtds, A.datas, A.usuars
ORDER BY D.datars DESC