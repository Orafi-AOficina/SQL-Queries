SELECT A.datars AS 'DATA-HORA', A.datas AS 'DATA', A.dopes AS 'OPERARAÇAO', A.mascnum AS 'NUM_OP', A.grupoos AS 'GRUPO_ORG', A.contaos AS 'CONTA_ORG', C.rclis AS 'NOME_ORG',
	A.grupods AS 'GRUPO_DEST', A.contads AS 'CONTA_DEST', D.rclis AS 'NOME_DEST', F.OP AS 'OP', G.cpros AS 'COD_PROD', G.dpros AS 'DESC_PROD', G.nops AS 'OP_MAE', B.cpros AS 'COD_INS',
	B.dpros AS 'DESC_INS', B.qtds AS 'QTD', B.cunis AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2', B.univals AS 'VALOR', B.moedas AS 'MOEDA', B.totas AS 'VALOR_REAIS',
	A.usuars AS 'RESPONSAVEL', B.obs AS 'OBS', Convert(varchar(max),A.obses), F.OP, B.cpro2s
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		INNER JOIN (SELECT E.cidchaves, LEFT(REPLACE(
												REPLACE(
														REPLACE(
																REPLACE(
																		REPLACE( 
																				REPLACE(Convert(varchar(max),E.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP'
						FROM SigMvCab (NOLOCK) E) F ON A.cidchaves = F.cidchaves
		LEFT JOIN SigOpPic (NOLOCK) G ON LEFT(G.nops, 4) = F.OP AND G.nopmaes=0 AND REPLACE(G.cpros, RTRIM(B.cpro2s), '') <> G.cpros --AND B.cpro2s = G.cpros
	WHERE (A.dopes = 'SAIDA PRODUCAO      ' OR A.dopes = 'SAIDA PRODUCAO TOTAL') AND A.datas >= '2020-01-01'
			AND (A.contaos IN ('MATPRIMA','PCP 3     ', 'PCP ANL   ') OR A.contads IN ('MATPRIMA','PCP 3     ', 'PCP ANL   '))
			AND B.cpro2s <> ''
			--AND F.OP = '6778'
	ORDER BY A.datars DESC, A.mascnum--F.OP ASC,