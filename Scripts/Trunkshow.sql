-- Saídas de Produção, são operações que enviam insumos do estoque de materia prima para os setores necessários na produção
SELECT RTRIM(A.emps) AS 'EMP', A.datars AS 'DATA-HORA', RTRIM(A.dopes) AS 'OPERARAÇAO', A.mascnum+0 AS 'NUM_OP', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG',
	RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST', RTRIM(B.cpros) AS 'COD_INS',
	RTRIM(B.dpros) AS 'DESC_INS', RTRIM(B.codbarras) AS 'CÓDIGO DE BARRAS', B.qtds AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', B.pesos AS 'QTD2', RTRIM(B.cunips) AS 'UNIT_QTD2', B.obs AS 'OBS_ITEM', A.usuars AS 'RESPONSAVEL',
	E.dtincs AS 'DATA_ENTRADA', E.grupos AS 'GRP_ESTOQUE', E.contas AS 'COD_CONTA', F.rclis AS 'CONTA', Convert(varchar(max),A.obses) AS 'OBSERVACAO', A.chkbxparcs AS 'BAIXA',
	A.dtbaixas AS 'DATA BAIXA', REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''),' ', '') AS 'OPERACAO ACEITE'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		INNER JOIN SIGOPETQ (NOLOCK) E ON B.codbarras=  E.cbars
		INNER JOIN SIGCDCLI (NOLOCK) F ON E.contas = F.iclis
	WHERE (A.dopes = 'ENTRADA TRUNKSHOW') AND A.datas >= '2023-01-01'
	ORDER BY A.datars DESC, A.mascnum

	

	
	
	
SELECT        TOP (100) PERCENT RTRIM(A.emps) AS EMP, A.datars AS [DATA-HORA], RTRIM(A.dopes) AS OPERARAÇAO, A.mascnum + 0 AS NUM_OP, RTRIM(A.grupoos) AS GRUPO_ORG, RTRIM(A.contaos) AS CONTA_ORG, RTRIM(C.rclis) 
                         AS NOME_ORG, RTRIM(A.grupods) AS GRUPO_DEST, RTRIM(A.contads) AS CONTA_DEST, RTRIM(D.rclis) AS NOME_DEST, RTRIM(B.cpros) AS COD_INS, RTRIM(B.dpros) AS DESC_INS, B.codbarras 
                         AS [CÓDIGO DE BARRAS], B.qtds AS QTD, RTRIM(B.cunis) AS UNIT_QTD, B.pesos AS QTD2, RTRIM(B.cunips) AS UNIT_QTD2, B.obs AS OBS_ITEM, RTRIM(A.usuars) AS RESPONSAVEL, E.dtincs AS DATA_ENTRADA, 
                         RTRIM(E.grupos) AS GRP_ESTOQUE, RTRIM(E.contas) AS COD_CONTA, RTRIM(F.rclis) AS CONTA, RTRIM(CONVERT(varchar(MAX), A.obses)) AS OBSERVACAO, A.chkbxparcs AS BAIXA, A.dtbaixas AS [DATA BAIXA], 
                         REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''), ' ', '') AS [OPERACAO ACEITE]
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = A.empdopnums INNER JOIN
                         dbo.SIGCDCLI AS C WITH (NOLOCK) ON A.contaos = C.iclis INNER JOIN
                         dbo.SIGCDCLI AS D WITH (NOLOCK) ON A.contads = D.iclis INNER JOIN
                         dbo.SIGOPETQ AS E WITH (NOLOCK) ON B.codbarras = E.cbars INNER JOIN
                         dbo.SIGCDCLI AS F WITH (NOLOCK) ON E.contas = F.iclis
WHERE        A.dopes = 'ENTRADA TRUNKSHOW'
	




--Estoque de códigos de barra
SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.grupos AS 'GRP_ESTOQUE', a.contas AS 'COD_CONTA', c.rclis AS 'CONTA', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO',
					a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS', a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', d.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', d.dpros AS 'DESCRICAO',
					b.qtds AS 'QTD_OP', a.qtds AS 'QTD_ETQ', e.NUM_COD_BARRAS as 'NUM_BARRAS_OP', d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_METAL',
					a.peso2s as 'PESO_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO', b.obss as 'OBS_OP', g.descs AS 'COD_POF'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.cbars) as 'NUM_COD_BARRAS', ee.nops from sigopetq (nolock) ee where ee.cbars > 0 group by ee.nops) e on e.nops = a.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) f on f.nops = a.nops and (a.cbars <= f.codbarras and (a.cbars > f.PROX_CBARS or ISNULL(f.PROX_CBARS, -1) = -1 ))
	left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = f.codbarras
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigprfti (nolock) g on d.cftios = g.cods
where a.grupos IN ('GERENCIAL', '') AND a.dtincs > '01-01-2025'