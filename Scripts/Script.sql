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
			LEFT JOIN (SELECT DISTINCT aa.empdnps AS 'ANTIGA', REPLACE(aa.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei (NOLOCK) aa
										LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps WHERE bb.emps IS NULL) D ON A.empdnps = D.NOVA
			LEFT JOIN (SELECT DISTINCT tpops, dopps, emps, nops, numps, empdnps FROM SigCdNei (NOLOCK)) C ON A.empdnps = C.empdnps OR C.empdnps = D.ANTIGA
			LEFT JOIN (SELECT DISTINCT nops, codpds, empdnps, MIN(datas) as 'datas', MIN(CAST(cidchaves AS BIGINT)) as 'cidchaves', MIN(datars) as 'datars', dopps
								FROM SigPdMvf (NOLOCK) 
							GROUP BY nops, codpds, empdnps, dopps) B ON (C.empdnps = B.empdnps AND C.nops = B.nops) OR (ISNULL(C.nops, -1) = -1 AND (A.empdnps = B.empdnps OR D.ANTIGA = B.empdnps))
			LEFT JOIN SIGCDCLI E (NOLOCK) ON A.contaos = E.iclis
			LEFT JOIN SigCdPro F (NOLOCK) ON B.codpds = F.cpros
			LEFT JOIN SIGCDCLI G (NOLOCK) ON A.contads = G.iclis
		WHERE A.datas >= '01-01-2023'
		
		
		
		
		
A coluna 'CHAVE_fMovimentacao' na Tabela 'fMovimentacao' contém um valor duplicado 'ORFMUDASETORCESTOQ30070_MUDA SETOR C ESTOQ_0' e isso não é permitido para colunas de um lado de uma relação muitos para um ou para colunas que são usadas como a chave primária de uma tabela.


2420
2434
30070
232220


SELECT emps, MIN(numps), dopps FROM SigPdMvf WHERE emps = 'ORF' AND datars > '01-01-2023' GROUP BY emps, dopps



SELECT DISTINCT A.tpops, A.dopps, A.emps, A.nops, A.numps, A.empdnps, B.datars FROM SigCdNei (NOLOCK) A LEFT JOIN SigPdMvf B (NOLOCK) ON A.empdnps = B.empdnps
							WHERE B.datars > '01-01-2022' and A.numps = 232220 --A.emps = 'ORF'--(nops >= 66000001 OR (nops = 0 OR AND NOT (emps = 'ORF' and numps < 1500)
							
							
							
							
							
(SELECT DISTINCT A.empdnps AS 'ANTIGO', REPLACE(A.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei A LEFT JOIN SigCdNec B ON A.empdnps = B.empdnps WHERE B.emps IS NULL)







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
			LEFT JOIN (SELECT DISTINCT aa.tpops, aa.dopps, aa.emps, aa.nops, aa.numps, aa.empdnps FROM SigCdNei (NOLOCK) aa LEFT JOIN SigPdMvf bb (NOLOCK) ON aa.empdnps = bb.empdnps
							WHERE bb.datars > '01-01-2022') C ON A.dopps = C.dopps AND A.numps = C.numps AND LEFT(A.emps,2) = LEFT(C.emps, 2) --A.empdnps = C.empdnps OR REPLACE(C.empdnps, 'ORF', 'ORA') = A.empdnps
			LEFT JOIN (SELECT DISTINCT nops, codpds, empdnps, MIN(datas) as 'datas', MIN(CAST(cidchaves AS BIGINT)) as 'cidchaves', MIN(datars) as 'datars', dopps
							FROM SigPdMvf (NOLOCK) WHERE datas >= '01-01-2022'
							GROUP BY nops, codpds, empdnps, dopps) B ON (C.empdnps = B.empdnps AND C.nops = B.nops) OR (ISNULL(C.nops, 0) = 0 AND A.empdnps = B.empdnps)
			LEFT JOIN SIGCDCLI E (NOLOCK) ON A.contaos = E.iclis
			LEFT JOIN SigCdPro F (NOLOCK) ON B.codpds = F.cpros
			LEFT JOIN SIGCDCLI G (NOLOCK) ON A.contads = G.iclis
		WHERE A.datas >= '01-01-2023'