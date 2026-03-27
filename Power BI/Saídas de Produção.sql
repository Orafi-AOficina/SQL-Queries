-- Saídas de Produção, são operações que enviam insumos do estoque de materia prima para os setores necessários na produção
SELECT A.emps AS 'EMP', A.datars AS 'DATA-HORA', A.datas AS 'DATA', A.dopes AS 'OPERARAÇAO', A.mascnum+0 AS 'NUM_OP', A.grupoos AS 'GRUPO_ORG', A.contaos AS 'CONTA_ORG', C.rclis AS 'NOME_ORG',
	A.grupods AS 'GRUPO_DEST', A.contads AS 'CONTA_DEST', D.rclis AS 'NOME_DEST', B.cpros AS 'COD_INS',
	B.dpros AS 'DESC_INS', B.qtds AS 'QTD', B.cunis AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2',
	A.usuars AS 'RESPONSAVEL', Convert(varchar(max),A.obses) AS 'OBS SAIDA',
	LEFT(REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE( 
								REPLACE(Convert(varchar(max),A.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP', A.chkbxparcs AS 'BAIXA', A.dtbaixas AS 'DATA BAIXA', REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''),' ', '') AS 'OPERACAO ACEITE'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
	WHERE (A.dopes = 'SAIDA PRODUCAO' OR A.dopes = 'SAIDA PRODUCAO TOTAL') AND A.datas >= '2023-01-01'
	ORDER BY A.datars DESC, A.mascnum