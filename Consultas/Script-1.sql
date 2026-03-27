SELECT RTRIM(B.emps) AS EMPRESA, RTRIM(B.empdnps) AS CHAVE_OPERACAO, RTRIM(B.dopps) AS TIPO_OPERACAO, CASE WHEN A.tpops = '' THEN RTRIM(B.dopps) 
                  WHEN A.tpops IS NULL THEN RTRIM(B.dopps) WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps) ELSE RTRIM(A.tpops) END AS OPERACAO, A.nops AS OP, RTRIM(D.descs) AS TIPO_ITEM_ESTOQUE, RTRIM(C.cgrus) 
                  AS GRP_INSUMO, RTRIM(A.cmats) AS INSUMO, RTRIM(C.dpros) AS DESC_INSUMO, A.pesos AS PESO_UNIT, A.qtds AS QTD_TOT, RTRIM(A.cunis) AS UN, A.custofs AS CUSTO_AU, RTRIM(A.moecusfs) AS MOEDA_CUSTO, A.peso2s, 
                  A.qtds * A.custofs AS COMPRA_OFI, REPLACE(B.empdnps, ' ', '') AS CHAVE_FINALIZACAO, A.nops AS OP2
FROM     dbo.SigCdNei (NOLOCK) AS A LEFT OUTER JOIN
					(SELECT DISTINCT aa.empdnps AS 'ANTIGA', REPLACE(aa.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei (NOLOCK) aa 
									LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps WHERE bb.emps IS NULL) E ON A.empdnps = E.ANTIGA LEFT OUTER JOIN 
					dbo.SigCdNec AS B WITH (NOLOCK) ON A.empdnps = B.empdnps OR B.empdnps = E.NOVA LEFT OUTER JOIN
                  	dbo.SigCdPro AS C WITH (NOLOCK) ON A.cmats = C.cpros LEFT OUTER JOIN
	                dbo.SigCdGpr AS D WITH (NOLOCK) ON C.mercs = D.codigos
WHERE  B.datas >= '01-01-2023'
ORDER BY B.datas DESC



A coluna 'CHAVE_fMovimentacao' na Tabela 'fMovimentacao' contém um valor duplicado 'ORFTRABALHADOS226906_CONSERTO/AJUSTE_0' e isso não é permitido para colunas de um lado de uma relação muitos para um ou para colunas que são usadas como a chave primária de uma tabela.
A coluna 'CHAVE_fMovimentacao' na Tabela 'fMovimentacao' contém um valor duplicado 'ORFTRABALHADOS220680_ENVIO MATERIAL_98610020' e isso não é permitido para colunas de um lado de uma relação muitos para um ou para colunas que são usadas como a chave primária de uma tabela.




SELECT B.emps AS EMPRESA, B.empdnps AS CHAVE_OPERACAO, RTRIM(B.dopps) AS TIPO_OPERACAO, CASE WHEN A.tpops = '' THEN RTRIM(B.dopps) 
                         WHEN A.tpops IS NULL THEN RTRIM(B.dopps) WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps) ELSE RTRIM(A.tpops) END AS OPERACAO, A.nops AS OP, RTRIM(D.descs) 
                         AS TIPO_ITEM_ESTOQUE, RTRIM(C.cgrus) AS GRP_INSUMO, RTRIM(A.cmats) AS INSUMO, RTRIM(C.dpros) AS DESC_INSUMO, A.pesos AS PESO_UNIT, A.qtds AS QTD_TOT, 
                         RTRIM(A.cunis) AS UN, A.custofs AS CUSTO_AU, RTRIM(A.moecusfs) AS MOEDA_CUSTO, A.peso2s AS 'PESO2S', A.qtds * A.custofs AS COMPRA_OFI, REPLACE(B.empdnps, ' ', '') 
                         AS CHAVE_FINALIZACAO, A.nops AS OP2
FROM         dbo.SigCdNec AS B LEFT OUTER JOIN
                         dbo.SigCdNei AS A WITH (NOLOCK) ON A.dopps = B.dopps AND A.numps = B.numps AND LEFT(A.emps, 2) = LEFT(B.emps, 2) LEFT OUTER JOIN
                         dbo.SigCdPro AS C WITH (NOLOCK) ON A.cmats = C.cpros LEFT OUTER JOIN
                         dbo.SigCdGpr AS D WITH (NOLOCK) ON C.mercs = D.codigos
WHERE     (B.datas >= '01-01-2023')
ORDER BY B.datas DESC







SELECT RTRIM(A.emps) AS 'EMP', A.datars AS 'DATA-HORA', A.datas AS 'DATA', RTRIM(A.dopes) AS 'OPERACAO', A.mascnum+0 AS 'NUM_OP', RTRIM(A.emps) AS 'EMP_ORG', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG',
	RTRIM(C.rclis) AS 'NOME_ORG', A.numbals AS 'BALANÇO_ORIG',
	CASE WHEN A.empds = '' THEN RTRIM(A.emps) ELSE RTRIM(A.empds) END AS 'EMP_DEST', RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST', A.numbalds AS 'BALANÇO_DEST',
	RTRIM(F.cgrus) AS 'GRP_INS', RTRIM(F.cpros) AS 'COD_INS', RTRIM(F.dpros) AS 'DESC_INS', B.qtds AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2',
	RTRIM(B.opers) AS 'SENTIDO', RTRIM(A.usuars) AS 'RESPONSAVEL', Convert(varchar(max),A.obses) AS 'OBS SAIDA', 
	LEFT(REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE( 
								REPLACE(Convert(varchar(max),A.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP',
	B.citens AS 'ORDENADOR', A.empdopnums AS 'CHAVE_OPERACAO', CONCAT(B.citens, A.empdopnums) AS 'CHAVE_ITEM',
	A.chkbxparcs AS 'BAIXA', A.dtbaixas AS 'DATA BAIXA', REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''),' ', '') AS 'OPERACAO ACEITE'
FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		--LEFT JOIN SigCdPro (NOLOCK) E ON B.cpro2s = E.cpros
		LEFT JOIN SigCdPro (NOLOCK) F ON B.cpros = F.cpros
	WHERE A.datas >= '01-01-2025'
			--AND A.dopes NOT IN ('FINALIZA NACIONAL', 'PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO ENCOMENDA', 'PEDIDO FABRICA', 'PEDIDO PILOTO', 'NF VENDA', 'ORÇAMENTO', '',
			--						'ENTRADA CONSERTO', 'PRE NF COMP MP FINAN', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'DV ASS.TEC.S. CUSTO', 'NF VENDA GAL', 'PED ACRESC PRODUCAO', 'PEDIDO DE ACRESC',
			--						'DEVOLUÇÃO DE VENDAS', 'CANCELA NF COMP PEDR', 'CANCELA NF OUT SAIDA', 'CANCELAMENTO NF', 'EMPENHO MT PRIMA', 'REQUISICAO COMPRA', 'NF COMPRA MP')
			AND A.dopes = 'TRF FILIAIS'
			AND B.cpros IN ('AU750', 'AG925', 'OFI', 'AG FINO')
			--AND (A.contads= 'MATPRIMA' OR A.contaos = 'MATPRIMA')
	ORDER BY A.datars DESC, A.mascnum ASC, B.citens ASC