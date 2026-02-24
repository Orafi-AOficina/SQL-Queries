SELECT C.emps AS 'EMPRESA', DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA_TRABALHADO', B.datas AS 'DATA-HORA', D.dopes 'TIPO PEDIDO',
			D.nops 'OP', F.cpros 'COD_PROD', F.reffs AS 'REF_ANL', F.dpros 'DESC_PROD', F.codcors AS 'COR',
			B.grupoos AS 'GRP_CONTA_ORI', B.contaos AS 'COD_CONTA_ORI', E.rclis AS 'NOME_CONTA_ORI', B.numbals AS 'BALANÇO_ORIG',
			B.grupods AS 'GRP_CONTA_ORI', B.contads AS 'COD_CONTA_DEST', G.rclis AS 'NOME_CONTA_DEST', B.numbalds AS 'BALANÇO_DEST',
			CASE
				WHEN E.inativas = 1 THEN 'INATIVA'
				WHEN E.inativas = 0 THEN 'ATIVA'
				ELSE 'VERIFICAR'
			END AS 'STATUS',
			CASE
				WHEN C.tpops = '' THEN RTRIM(B.dopps)
				WHEN C.tpops IS NULL THEN RTRIM(B.dopps)
				WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps)
				ELSE RTRIM(C.tpops)
			END AS 'OPERACAO',
			B.dopps 'TIPO_OPERACAO', B.numps AS 'NUM_OPERACAO', C.cmats AS 'INSUMO', A.dpros 'DESC_INSUMO', 
			CASE
				WHEN A.cgrus = 'IAU' THEN A.cpros 
				ELSE A.cgrus
			END AS 'GRUPO_INS',
			C.qtds AS 'QTD', C.pesos AS 'PESO', C.peso2s AS 'PESO2S', B.totpesos 'PESO_TOTAL', B.obss AS 'OBSERVAÇÃO', B.usuars AS 'USUARIO'
		FROM SigCdNec B
			LEFT JOIN SigCdNei C (NOLOCK) ON C.dopps = B.dopps AND C.numps = B.numps AND LEFT(C.emps, 2) = LEFT(B.emps, 2)
			LEFT JOIN (SELECT DISTINCT nops, dopes, cpros FROM SigOpPic (NOLOCK)) D ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SIGCDCLI G (NOLOCK) ON B.contads = G.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN SigCdPro F (NOLOCK) ON D.cpros = F.cpros
		WHERE B.dopps IN ('TRABALHADOS S/ OP   ', 'TRABALHADOS         ' ,'FINALIZAÇÃO         ', 'DESAGREGA PEDRA     ','MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ','SEPARA PEDRA        ', 'DIVISAO DE OP', 'FINALIZA OP S/BARRA' )
				AND C.cmats IN ('AU750', 'AG925', 'OFI', 'AG FINO') --SE QUISER VER SÓ AU750
				AND B.datas >= '01-05-2024' --DATA POSTERIOR À
				AND ((B.contaos = '0000000231' OR B.contads = '0000000231') OR (B.contaos = '0000000231' AND B.contads = '0000000231'))
		ORDER BY B.datas DESC
		
		
		
		
---- ANÁLISE DE METAL LIVRE NAS CONTAS
SELECT C.emps AS 'EMPRESA', DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA_TRABALHADO', B.datas AS 'DATA-HORA', D.dopes 'TIPO PEDIDO',
			D.nops 'OP', F.cpros 'COD_PROD', F.reffs AS 'REF_ANL', F.dpros 'DESC_PROD', F.codcors AS 'COR',
			B.grupoos AS 'GRP_CONTA_ORI', B.contaos AS 'COD_CONTA_ORI', E.rclis AS 'NOME_CONTA_ORI', B.numbals AS 'BALANÇO_ORIG',
			B.grupods AS 'GRP_CONTA_ORI', B.contads AS 'COD_CONTA_DEST', G.rclis AS 'NOME_CONTA_DEST', B.numbalds AS 'BALANÇO_DEST',
			CASE
				WHEN E.inativas = 1 THEN 'INATIVA'
				WHEN E.inativas = 0 THEN 'ATIVA'
				ELSE 'VERIFICAR'
			END AS 'STATUS',
			CASE
				WHEN C.tpops = '' THEN RTRIM(B.dopps)
				WHEN C.tpops IS NULL THEN RTRIM(B.dopps)
				WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps)
				ELSE RTRIM(C.tpops)
			END AS 'OPERACAO',
			B.dopps 'TIPO_OPERACAO', B.numps AS 'NUM_OPERACAO', C.cmats AS 'INSUMO', A.dpros 'DESC_INSUMO', 
			A.cgrus AS 'GRUPO_INS',
			C.qtds AS 'QTD', C.pesos AS 'PESO', C.peso2s AS 'PESO2S', B.totpesos 'PESO_TOTAL', B.obss AS 'OBSERVAÇÃO', B.usuars AS 'USUARIO'
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
			LEFT JOIN (SELECT DISTINCT nops, dopes, cpros FROM SigOpPic (NOLOCK)) D ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SIGCDCLI G (NOLOCK) ON B.contads = G.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN SigCdPro F (NOLOCK) ON D.cpros = F.cpros
		WHERE B.dopps IN ('TRABALHADOS S/ OP   ', 'TRABALHADOS         ' ,'FINALIZAÇÃO         ', 'DESAGREGA PEDRA     ','MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ','SEPARA PEDRA        ', 'DIVISAO DE OP', 'FINALIZA OP S/BARRA', 'FINALIZA S INDUSTRIA')
				 AND A.cgrus IN ('IAU', 'IMT') --AND C.cmats IN ('AU750', 'AG925', 'OFI', 'AG FINO') --SE QUISER VER SÓ AU750
				AND B.datas >= '2025-01-01' AND (B.numbals = 0 OR B.numbalds = 0)
		ORDER BY B.datas DESC	
		
		
		
		
		
---  HISTÓRICO RIO V3
SELECT DISTINCT C.emps AS 'EMPRESA', DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA_TRABALHADO', B.datas AS 'DATA-HORA', D.dopes 'TIPO PEDIDO',
			D.numes 'PEDIDO', D.nops 'OP', F.cpros 'COD_PROD', F.reffs AS 'REF_ANL', F.dpros 'DESC_PROD', F.codcors AS 'COR',
			B.grupoos AS 'GRP_CONTA_ORI', B.contaos AS 'COD_CONTA_ORI', E.rclis AS 'NOME_CONTA_ORI', B.numbals AS 'BALANÇO_ORIG',
			B.grupods AS 'GRP_CONTA_ORI', B.contads AS 'COD_CONTA_DEST', G.rclis AS 'NOME_CONTA_DEST', B.numbalds AS 'BALANÇO_DEST',
			CASE
				WHEN E.inativas = 1 THEN 'INATIVA'
				WHEN E.inativas = 0 THEN 'ATIVA'
				ELSE 'VERIFICAR'
			END AS 'STATUS',
			C.tpops AS 'OPERACAO', B.dopps 'TIPO_OPERACAO', B.numps AS 'NUM_OPERACAO', C.cmats AS 'INSUMO', A.dpros 'DESC_INSUMO', 
			CASE
				WHEN A.cgrus = 'IAU' THEN A.cpros 
				ELSE A.cgrus
			END AS 'GRUPO_INS',
			C.qtds AS 'QTD', C.pesos AS 'PESO', C.peso2s AS 'PESO2S', B.totpesos 'PESO_TOTAL', CAST(B.obss AS VARCHAR(100)) AS 'OBSERVAÇÃO', B.usuars AS 'USUARIO',
            CASE WHEN B.dopps = 'INDUSTRIALIZAÇÃO' OR B.dopps = 'TRABALHADOS S/ OP' THEN 1
					ELSE
						(SELECT DISTINCT CASE WHEN B.dopps = 'DIVISAO DE OP' THEN COUNT(M.nops) ELSE COUNT(M.nops) END
							FROM SigPdMvf (NOLOCK) M
								WHERE M.nops = D.nops AND M.cidchaves <= B.cidchaves AND M.dopps <> 'SEPARA PEDRA') + 1 -
						(SELECT DISTINCT CASE WHEN B.dopps = 'DIVISAO DE OP' THEN 1 ELSE COUNT(M.nops) END
							FROM SigPdMvf (NOLOCK) M
								WHERE M.nops = D.nops AND M.cidchaves = B.cidchaves AND M.dopps <> 'SEPARA PEDRA') + 
						(SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = D.nops AND B.dopps LIKE 'FINALIZA%' AND K.cidchaves > B.cidchaves AND K.dopps <> 'SEPARA PEDRA') - 
						(SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = D.nops AND K.dopps LIKE 'FINALIZA%' AND K.cidchaves < B.cidchaves AND K.dopps <> 'SEPARA PEDRA') END AS 'SEQ_MOVIMENTACAO',
			CASE WHEN B.emps = 'ORA' AND B.datas <= '01-09-2025' AND B.numbals > 1000 THEN 'ORF' ELSE RTRIM(B.emps) END AS 'EMP_TESTE', D.*
			--A.qtds AS 'QTD',
			--, B.*, C.*--, B.*
	--	FROM SigMvHst A (NOLOCK)
	--		LEFT JOIN SigCdNei C (NOLOCK) ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps AND A.cpros = C.cmats AND 
	--																				((A.dopes  = 'TRABALHADOS' AND A.qtds = C.qtds) OR (A.dopes = 'TRABALHADOS S/ OP'))-- AND A.qtds = C.qtds)) 
	--																				OR (A.dopes = 'TRABALHADOS S/ OP' AND B.totpesos = C.qtds))
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps OR ('ORA' + RIGHT(C.empdnps, LEN(C.empdnps)-3)) = B.empdnps
			LEFT JOIN (SELECT DISTINCT emps, dopes, numes, nops, cpros FROM SigOpPic (nolock)) D  ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SIGCDCLI G (NOLOCK) ON B.contads = G.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN SigCdPro F (NOLOCK) ON D.cpros = F.cpros
		WHERE B.dopps IN ('TRABALHADOS S/ OP   ', 'TRABALHADOS         ' ,'FINALIZAÇÃO         ', 'DESAGREGA PEDRA     ','MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ','SEPARA PEDRA        ' )
				AND C.cmats IN ('AU750', 'AG925', 'OFI', 'AG FINO') --SE QUISER VER SÓ AU750
				AND B.datas >= '01-12-2024'
		ORDER BY B.datas DESC

		
		
		
		
		
		
		
		
		
		
		
		
SELECT DISTINCT RTRIM(A.emps) AS 'EMPRESA', RTRIM(A.empdnps) AS 'CHAVE_OPERACAO', A.numps AS 'NUM_OPER',
			CASE 
					WHEN A.dopps = 'TRABALHADOS S/ OP' THEN  FORMAT(A.datas, 'yyyy-MM-dd HH:mm')
					WHEN B.datas > '01-01-2000' THEN FORMAT(B.datas, 'yyyy-MM-dd HH:mm')
					ELSE FORMAT(A.datas, 'yyyy-MM-dd HH:mm')
			END AS 'DATA_HORA',
			CASE
					WHEN A.dopps = 'TRABALHADOS S/ OP' THEN  FORMAT(A.datars, 'yyyy-MM-dd HH:mm')
					WHEN B.datas > '01-01-2000' THEN FORMAT(B.datars, 'yyyy-MM-dd HH:mm')
					ELSE FORMAT(A.datars, 'yyyy-MM-dd HH:mm')
			END AS 'DATA_HORA_INICIO_OPERACAO',
			RTRIM(A.dopps) AS 'TIPO_OPERACAO',
			CASE
				WHEN C.tpops = '' THEN RTRIM(A.dopps)
				WHEN C.tpops IS NULL THEN RTRIM(A.dopps)
				WHEN A.dopps = 'DIVISAO DE OP' THEN RTRIM(A.dopps)
				ELSE RTRIM(C.tpops)
			END AS 'OPERACAO',
			CASE 
				WHEN A.dopps = 'TRABALHADOS S/ OP' THEN 0
				WHEN A.dopps IN ('MUDA SETOR C ESTOQ', 'INDUSTRIALIZAÇÃO', 'FINALIZA S INDUSTRIA') THEN B.nops
				--WHEN ISNULL(C.nops, 0) = 0 THEN B.nops
				ELSE ISNULL(C.nops, 0) --C.nenvs
			END AS 'OP',
			CASE 
				WHEN A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(C.nops, 0) = 0 THEN 0
				ELSE (SELECT MIN(a.qtds) FROM SigPdMvf (NOLOCK) a WHERE B.nops = a.nops AND a.datars <= B.datars AND a.dopps IN ('DIVISAO DE OP', 'INDUSTRIALIZAÇÃO'))
			END AS 'QTD_OP',
			CASE WHEN ISNULL(B.nops, 0) = 0 THEN '' ELSE RTRIM(B.codpds) END AS 'COD_PRODUTO',-- D.codbarras AS 'FINALIZACAO',
			RTRIM(A.grupoos) AS 'GRP_CONTA_ORI', RTRIM(A.contaos) AS 'COD_CONTA_ORI', RTRIM(E.rclis) AS 'NOME_CONTA_ORI',
			RTRIM(A.grupods) AS 'GRP_CONTA_DEST', RTRIM(A.contads) AS 'COD_CONTA_DEST', RTRIM(G.rclis) AS 'NOME_CONTA_DEST',
			A.totpesos 'PESO_TOTAL',
			CONCAT((CASE 
						WHEN A.dopps = 'TRABALHADOS S/ OP' THEN CASE WHEN LEN(RTRIM(A.docus)) = 8 THEN CONCAT(CAST(RTRIM(A.docus) AS INT), '_') END
						ELSE ''
					END),
			CAST(A.obss AS varchar(max)))  AS 'OBSERVAÇÃO',
			CASE WHEN A.emps = 'ORA' AND A.datas <= '01-09-2025' AND A.numbals > 1000 THEN 'ORF' ELSE RTRIM(A.emps) END + '_' + CAST(A.numbals AS varchar) AS 'BALANÇO',
			CASE WHEN A.emps = 'ORA' AND A.datas <= '01-09-2025' AND A.numbalds > 1000  THEN 'ORF' ELSE RTRIM(A.emps) END + '_' + CAST(A.numbalds AS varchar) AS 'BALANÇO_DEST', A.usuars AS 'USUARIO',
			CASE 
				WHEN A.dopps = 'TRABALHADOS S/ OP' THEN  REPLACE(A.empdnps, ' ', '')
				ELSE REPLACE(A.empdnps, ' ', '')
			END AS 'CHAVE_FINALIZACAO',
			CASE
				WHEN (SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND K.dopps LIKE 'FINALIZA%' AND K.cidchaves = B.cidchaves) = 1 THEN 'VERDADEIRO'
				WHEN (SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND K.dopps LIKE 'FINALIZA%' AND K.cidchaves < B.cidchaves) > 0 THEN 'FALSO'
				WHEN (SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND K.cidchaves >= B.cidchaves) = 1 THEN 'VERDADEIRO'
				ELSE 'FALSO'
			END AS 'ULT_MOVIMENTACAO',
			CASE WHEN A.dopps = 'INDUSTRIALIZAÇÃO' OR A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(B.nops, 0) = 0 THEN 1
					ELSE
						(SELECT DISTINCT CASE WHEN A.dopps = 'DIVISAO DE OP' THEN COUNT(M.nops) ELSE COUNT(M.nops) END
							FROM SigPdMvf (NOLOCK) M
								WHERE M.nops = B.nops AND M.cidchaves <= B.cidchaves) + 1 -
						(SELECT DISTINCT CASE WHEN A.dopps = 'DIVISAO DE OP' THEN 1 ELSE COUNT(M.nops) END
							FROM SigPdMvf (NOLOCK) M
								WHERE M.nops = B.nops AND M.cidchaves = B.cidchaves) + 
						(SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND A.dopps LIKE 'FINALIZA%' AND K.cidchaves > B.cidchaves) - 
						(SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND K.dopps LIKE 'FINALIZA%' AND K.cidchaves < B.cidchaves) END AS 'SEQ_MOVIMENTACAO',
			CASE WHEN A.dopps = 'INDUSTRIALIZAÇÃO' OR A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(B.nops, 0) = 0 THEN 0
					ELSE
						(SELECT DISTINCT CASE WHEN A.dopps = 'DIVISAO DE OP' THEN COUNT(M.nops) ELSE COUNT(M.nops) END
							FROM SigPdMvf (NOLOCK) M
								WHERE M.nops = B.nops AND M.cidchaves <= B.cidchaves) -
						(SELECT DISTINCT CASE WHEN A.dopps = 'DIVISAO DE OP' THEN 1 ELSE COUNT(M.nops) END
								FROM SigPdMvf (NOLOCK) M
									WHERE M.nops = B.nops AND M.cidchaves = B.cidchaves) + 
						(SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND A.dopps LIKE 'FINALIZA%' AND K.cidchaves > B.cidchaves) - 
						(SELECT COUNT(K.datas)
								FROM SigPdMvf (NOLOCK) K
									WHERE K.nops = B.nops AND K.dopps LIKE 'FINALIZA%' AND K.cidchaves < B.cidchaves)  END AS 'SEQ_MOVIMENTACAO_ANTERIOR',
			CASE WHEN ISNULL(B.nops, 0) = 0 THEN 0 ELSE B.cidchaves END AS 'INDEX'
		FROM SigCdNec (NOLOCK) A
			LEFT JOIN (SELECT DISTINCT aa.empdnps AS 'ANTIGA', REPLACE(aa.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei (NOLOCK) aa LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps WHERE bb.emps IS NULL) D ON A.empdnps = D.NOVA
			LEFT JOIN (SELECT DISTINCT tpops, dopps, emps, nops, numps, empdnps FROM SigCdNei (NOLOCK)) C ON A.empdnps = C.empdnps OR C.empdnps = D.ANTIGA
			LEFT JOIN (SELECT DISTINCT nops, codpds, empdnps, MIN(datas) as 'datas', MIN(CAST(cidchaves AS BIGINT)) as 'cidchaves', MIN(datars) as 'datars', dopps
								FROM SigPdMvf (NOLOCK) 
							GROUP BY nops, codpds, empdnps, dopps) B ON (C.empdnps = B.empdnps AND C.nops = B.nops) OR (ISNULL(C.nops, -1) = -1 AND (A.empdnps = B.empdnps OR D.ANTIGA = B.empdnps))
			LEFT JOIN SIGCDCLI E (NOLOCK) ON A.contaos = E.iclis
			LEFT JOIN SigCdPro F (NOLOCK) ON B.codpds = F.cpros
			LEFT JOIN SIGCDCLI G (NOLOCK) ON A.contads = G.iclis
		WHERE A.datas >= '01-01-2023'