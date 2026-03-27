SELECT A.matprincs, A.cgrus, A.cpros, A.dpros, A.cunis, A.datas, A.moedas, A.sgrus, A.codcors, A.mercs, A.dpro2s, A.cclass, A.pesometal, A.ifors, A.reffs, B.rclis, A.situas, C.ULT_MOV
	FROM SIGCDPRO (NOLOCK) A
		LEFT JOIN SIGCDCLI (NOLOCK) B ON A.ifors= B.iclis
		LEFT JOIN (SELECT MAX(A.datars) AS 'ULT_MOV_OPER', B.cpros AS 'COD_INS'
		FROM SigMvCab (NOLOCK) A
			LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		WHERE A.dopes NOT IN ('FINALIZA NACIONAL', 'PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO ENCOMENDA', 'PEDIDO FABRICA', 'PEDIDO PILOTO', 'NF VENDA', 'ORÇAMENTO', '',
							'ENTRADA CONSERTO', 'PRE NF COMP MP FINAN', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'DV ASS.TEC.S. CUSTO', 'NF VENDA GAL', 'PED ACRESC PRODUCAO', 'PEDIDO DE ACRESC',
							'DEVOLUÇÃO DE VENDAS', 'CANCELA NF COMP PEDR', 'CANCELA NF OUT SAIDA', 'CANCELAMENTO NF')
GROUP BY B.cpros) C ON C.COD_INS = A.cpros
WHERE A.CGRUS = 'IMT' OR A.CGRUS = 'INS'








--Movimentações de Materia prima fora da  indústria
(SELECT MAX(A.datars) AS 'DATA-HORA', RTRIM(B.cpros) AS 'COD_INS'
		FROM SigMvCab (NOLOCK) A
			LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		WHERE A.dopes NOT IN ('FINALIZA NACIONAL', 'PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO ENCOMENDA', 'PEDIDO FABRICA', 'PEDIDO PILOTO', 'NF VENDA', 'ORÇAMENTO', '',
							'ENTRADA CONSERTO', 'PRE NF COMP MP FINAN', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'DV ASS.TEC.S. CUSTO', 'NF VENDA GAL', 'PED ACRESC PRODUCAO', 'PEDIDO DE ACRESC',
							'DEVOLUÇÃO DE VENDAS', 'CANCELA NF COMP PEDR', 'CANCELA NF OUT SAIDA', 'CANCELAMENTO NF')
GROUP BY B.cpros)



--Composição das Movimentações de Indústria
SELECT RTRIM(B.emps) AS EMPRESA, RTRIM(B.empdnps) AS CHAVE_OPERACAO, RTRIM(B.dopps) AS TIPO_OPERACAO, CASE WHEN A.tpops = '' THEN RTRIM(B.dopps) 
                  WHEN A.tpops IS NULL THEN RTRIM(B.dopps) WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps) ELSE RTRIM(A.tpops) END AS OPERACAO, A.nops AS OP, RTRIM(C.mercs) AS GRANDE_GRP, RTRIM(D.descs) AS TIPO_ITEM_ESTOQUE, RTRIM(C.cgrus) 
                  AS GRP_INSUMO, RTRIM(A.cmats) AS INSUMO, RTRIM(C.dpros) AS DESC_INSUMO, A.pesos AS PESO_UNIT, A.qtds AS QTD_TOT, RTRIM(A.cunis) AS UN, A.custofs AS CUSTO_AU, RTRIM(A.moecusfs) AS MOEDA_CUSTO, A.peso2s AS 'PESO2S', 
                  A.qtds * A.custofs AS COMPRA_OFI, REPLACE(B.empdnps, ' ', '') AS CHAVE_FINALIZACAO, A.nops AS OP2
FROM     dbo.SigCdNei (NOLOCK) AS A LEFT OUTER JOIN
					(SELECT DISTINCT aa.empdnps AS 'ANTIGA', REPLACE(aa.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei (NOLOCK) aa 
									LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps WHERE bb.emps IS NULL) E ON A.empdnps = E.ANTIGA LEFT OUTER JOIN 
					dbo.SigCdNec AS B WITH (NOLOCK) ON A.empdnps = B.empdnps OR B.empdnps = E.NOVA LEFT OUTER JOIN
                  	dbo.SigCdPro AS C WITH (NOLOCK) ON A.cmats = C.cpros LEFT OUTER JOIN
	                dbo.SigCdGpr AS D WITH (NOLOCK) ON C.mercs = D.codigos
	                
	                
	                
	                
	                
-- Saídas de Produção, são operações que enviam insumos do estoque de materia prima para os setores necessários na produção
SELECT RTRIM(A.emps) AS 'EMP', MAX(A.datars) AS 'DATA-HORA', RTRIM(A.dopes) AS 'OPERARAÇAO', MAX(A.mascnum+0) AS 'NUM_OP', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG',
	RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST', E.cgrus, E.mercs, RTRIM(B.cpros) AS 'COD_INS',
	RTRIM(B.dpros) AS 'DESC_INS', SUM(B.qtds) AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', SUM(B.pesos) AS 'QTD2', RTRIM(B.cunips) AS 'UNIT_QTD2'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		INNER JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
	WHERE (A.dopes = 'NF COMPRA MP') AND A.datas >= '2021-01-01' AND E.cgrus IN ('IMT', 'IAU')
GROUP BY A.emps, A.dopes, A.grupoos, A.contaos, C.rclis, A.grupods, A.contads, D.rclis, E.cgrus, E.mercs, B.cpros, B.dpros, B.cunis, B.cunips



SELECT A.matprincs, A.cgrus, A.cpros, A.dpros, A.cunis, A.datas, A.moedas, A.sgrus, A.codcors, A.mercs, A.dpro2s, A.cclass, A.pesometal, A.reffs, A.ifors, B.rclis, A.situas, A.*
	FROM SIGCDPRO (NOLOCK) A
		LEFT JOIN SIGCDCLI (NOLOCK) B ON A.ifors= B.iclis
WHERE A.CGRUS = 'IMT' OR A.CGRUS = 'INS' AND A.cpros = 'MOSQ BOIA/OB6M'