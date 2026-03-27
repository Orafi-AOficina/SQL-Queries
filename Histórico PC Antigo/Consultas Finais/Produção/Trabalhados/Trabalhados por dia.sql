-- Tabela dos balanços é a SigCdFcx!!!
SELECT G.DATA_TRABALHADO, G.COD_FUNCIONARIO, G.NOME, G.OPERACAO, G.TIPO, G.COMPLEXIDADE, SUM(G.QTD) AS 'TRABALHADOS', SUM(G.PESO) AS 'PESO', SUM(G.PESO2S) AS 'PESO2S', G.GRUPO_INS, G.SUB_GRUPO, G.STATUS
FROM
	(SELECT C.cmats AS 'INSUMO', B.contaos AS 'COD_FUNCIONARIO', E.rclis AS 'NOME',
			--(SELECT DISTINCT MIN(F.numes) FROM SigMvHst F WHERE A.estos = F.estos AND A.datars <= F.datars AND F.dopes = '') AS 'COD_BALANCO',
			DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA_TRABALHADO', B.dopps AS 'TIPO',
			C.tpops AS 'OPERACAO',
			CASE
				WHEN LEFT(H.COMPLEXIDADE, 1) = '#' THEN H.COMPLEXIDADE
				ELSE ''
			END AS 'COMPLEXIDADE', SUM(C.qtds) AS 'QTD', SUM (C.pesos) AS 'PESO', SUM(C.peso2s) AS 'PESO2S',
	--		C.qtds AS 'QTD2', B.totpesos ,
			--A.qtds AS 'QTD',
			CASE
				WHEN E.inativas = 1 THEN 'INATIVA'
				WHEN E.inativas = 0 THEN 'ATIVA'
				ELSE 'VERIFICAR'
			END AS 'STATUS',
			CASE
				WHEN A.cgrus = 'IAU' THEN A.cpros 
				ELSE A.cgrus
			END AS 'GRUPO_INS',
			CASE
				WHEN A.dpros LIKE '%FIO%' AND A.cgrus = 'PED' THEN 'FIO'
				ELSE ''
			END AS 'SUB_GRUPO'
			--, B.*, C.*--, B.*
	--	FROM SigMvHst A (NOLOCK)
	--		LEFT JOIN SigCdNei C (NOLOCK) ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps AND A.cpros = C.cmats AND 
	--																				((A.dopes  = 'TRABALHADOS' AND A.qtds = C.qtds) OR (A.dopes = 'TRABALHADOS S/ OP'))-- AND A.qtds = C.qtds)) 
	--																				OR (A.dopes = 'TRABALHADOS S/ OP' AND B.totpesos = C.qtds))
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
			LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN (select h.*, REPLACE(LEFT(Convert(varchar(max), H.obs),9), ' ','') AS 'COMPLEXIDADE' from SigCdPfc h (nolock)
										INNER JOIN (select produtos, MAX(dataalts) as 'ult_alteracao'
														from SigCdPfc (nolock)
														group by produtos) hh on hh.produtos = h.produtos and h.dataalts = hh.ult_alteracao
								) H ON D.cpros = H.produtos AND LEFT(REPLACE(H.grupos, ' ',''),5) = LEFT(REPLACE(C.tpops, '-',''), 5) 
		WHERE (B.dopps = 'TRABALHADOS S/ OP   ' OR B.dopps  = 'TRABALHADOS         ' OR B.dopps = 'FINALIZAÇÃO         ')
				--AND C.cmats = 'AU750'
				AND B.datas >= '2019-01-01'-- AND E.inativas = 0 --AND A.numes = 13674-- AND A.datas <= '2019-02-10' 
				AND C.tpops IN ('OURIVESARIA.TRA', 'CRAVACAO.TRAB', 'POLIMENTO.TRAB', 'PRE-POLIMENTO', 'DEVOL MATERIAL', 'MONTAGEM.TRAB', 'TRABALHO ENFIAÇ', 'CORTE A LASER')
	--			AND A.opers = 'S'
	--			AND B.numbals = 1708
				--AND B.contaos = '0000000072' --OR B.contads = '0000000072')--AND A.opers = 'S' AND A.datas <= '2020-09-23' --AND A.dopes = 'TRABALHADOS    ' 
		GROUP BY C.tpops, B.contaos , C.cmats , E.rclis, E.inativas, B.datas, A.cgrus, A.cpros, A.dpros, B.dopps, H.COMPLEXIDADE) AS G
GROUP BY G.DATA_TRABALHADO, G.COD_FUNCIONARIO, G.NOME, G.OPERACAO, G.STATUS, G.GRUPO_INS, G.SUB_GRUPO, G.TIPO, G.COMPLEXIDADE
ORDER BY G.DATA_TRABALHADO DESC, G.NOME, G.OPERACAO, G.GRUPO_INS, G.SUB_GRUPO