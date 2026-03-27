--Movimentações de Materia prima fora da  indústria
SELECT RTRIM(A.emps) AS 'EMP', A.datars AS 'DATA-HORA', A.datas AS 'DATA', RTRIM(A.dopes) AS 'OPERACAO', A.mascnum+0 AS 'NUM_OP', RTRIM(A.emps) AS 'EMP_ORG', RTRIM(A.grupoos) AS 'GRUPO_ORG',
	RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG',
	CASE
		WHEN A.empds = '' THEN RTRIM(A.emps)
		ELSE RTRIM(A.empds) END AS 'EMP_DEST',
	RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST',
	RTRIM(F.cgrus) AS 'GRP_INS', RTRIM(F.cpros) AS 'COD_INS', RTRIM(F.dpros) AS 'DESC_INS', B.qtds AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2', B.opers AS 'SENTIDO',
	RTRIM(A.usuars) AS 'RESPONSAVEL', Convert(varchar(max),A.obses) AS 'OBS SAIDA', 
	CASE 
        WHEN PATINDEX('%[0-9]%', A.obses) > 0 THEN
            CASE 
                WHEN SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 1) BETWEEN '1' AND '3' THEN
                    SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 5)
                WHEN SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 1) BETWEEN '4' AND '9' THEN
                    SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 4)
                ELSE NULL
            END
        ELSE NULL
    END AS 'OP',
	B.citens AS 'ORDENADOR', A.empdopnums AS 'CHAVE_OPERACAO', CONCAT(B.citens, A.empdopnums) AS 'CHAVE_ITEM',
	A.chkbxparcs AS 'BAIXA', A.dtbaixas AS 'DATA BAIXA', REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''),' ', '') AS 'OPERACAO ACEITE', Convert(varchar(max),B.obs) AS 'OBSERVACAO ITEM'
FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		--LEFT JOIN SigCdPro (NOLOCK) E ON B.cpro2s = E.cpros
		LEFT JOIN SigCdPro (NOLOCK) F ON B.cpros = F.cpros
	WHERE A.datas >= '2023-01-01'
			AND A.dopes NOT IN ('FINALIZA NACIONAL', 'PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO ENCOMENDA', 'PEDIDO FABRICA', 'PEDIDO PILOTO', 'NF VENDA', 'ORÇAMENTO', '',
						'ENTRADA CONSERTO', 'PRE NF COMP MP FINAN', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'DV ASS.TEC.S. CUSTO', 'NF VENDA GAL', 'PED ACRESC PRODUCAO', 'PEDIDO DE ACRESC',
						'DEVOLUÇÃO DE VENDAS', 'CANCELA NF COMP PEDR', 'CANCELA NF OUT SAIDA', 'CANCELAMENTO NF')
			-- 'PRE NF COMP MP FINAN', 
			--AND B.cpros = 'PED000011'
			--AND (A.contads= 'MATPRIMA' OR A.contaos = 'MATPRIMA')
	ORDER BY A.datars DESC, A.mascnum ASC, B.citens ASC