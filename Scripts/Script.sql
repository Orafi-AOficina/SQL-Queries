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






SELECT A.datars AS 'DATA-HORA', A.datas AS 'DATA', A.dopes AS 'OPERAÇAO', A.mascnum+0 AS 'NUM_OP', A.grupoos AS 'GRUPO_ORG', A.contaos AS 'CONTA_ORG', C.rclis AS 'NOME_ORG',
	A.grupods AS 'GRUPO_DEST', A.contads AS 'CONTA_DEST', D.rclis AS 'NOME_DEST', B.cpros AS 'COD_INS',
	B.dpros AS 'DESC_INS', B.qtds AS 'QTD', B.cunis AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2',
	A.usuars AS 'RESPONSAVEL', Convert(varchar(max),A.obses) AS 'OBS SAIDA', Convert(varchar(max),B.obs) AS 'OBS ITEM',
	CASE WHEN LEFT(F.OP_SEMITRATADA, 1) IN ('1', '2', '3', '4', '5') THEN F.OP_SEMITRATADA ELSE LEFT(F.OP_SEMITRATADA, 4) END AS 'OP',
	CASE WHEN LEFT(G.OP_SEMITRATADA, 1) IN ('1', '2', '3', '4', '5') THEN G.OP_SEMITRATADA ELSE LEFT(G.OP_SEMITRATADA, 4) END AS 'OP_ITEM',
	B.citens AS 'ORDENADOR', A.empdopnums AS 'CHAVE_OPERACAO', CONCAT(B.citens, A.empdopnums) AS 'CHAVE_ITEM',
	CASE WHEN B.chksubn = 1 THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'BAIXA'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
		LEFT JOIN (SELECT aa.empdopnums,
						CASE 
        WHEN PATINDEX('%[0-9]%', aa.obses) > 0 THEN
            CASE 
                WHEN SUBSTRING(aa.obses, PATINDEX('%[0-9]%', aa.obses), 1) BETWEEN '1' AND '3' THEN
                    SUBSTRING(aa.obses, PATINDEX('%[0-9]%', aa.obses), 5)
                WHEN SUBSTRING(aa.obses, PATINDEX('%[0-9]%', aa.obses), 1) BETWEEN '4' AND '9' THEN
                    SUBSTRING(aa.obses, PATINDEX('%[0-9]%', aa.obses), 4)
                ELSE NULL
            END
        ELSE NULL
    END AS  'OP_SEMITRATADA' FROM SigMvCab (NOLOCK) aa) F ON F.empdopnums = A.empdopnums
		LEFT JOIN (SELECT bb.empdopnums, bb.citens,
						CASE 
        WHEN PATINDEX('%[0-9]%', bb.obs) > 0 THEN
            CASE 
                WHEN SUBSTRING(bb.obs, PATINDEX('%[0-9]%', bb.obs), 1) BETWEEN '1' AND '3' THEN
                    SUBSTRING(bb.obs, PATINDEX('%[0-9]%', bb.obs), 9)
                WHEN SUBSTRING(bb.obs, PATINDEX('%[0-9]%', bb.obs), 1) BETWEEN '4' AND '9' THEN
                    SUBSTRING(bb.obs, PATINDEX('%[0-9]%', bb.obs), 8)
                ELSE NULL
            END
        ELSE NULL
    END AS  'OP_SEMITRATADA' FROM SigMvItn (NOLOCK) bb) G ON G.empdopnums = B.empdopnums AND G.citens = B.citens
	WHERE A.dopes IN ('SAIDA PRODUCAO', 'SAIDA PRODUCAO TOTAL', 'SAIDA PARA CONSERTO', 'SAIDA DE RESPOSICAO')
                                 AND A.datas >= '2024-01-01'
                                 AND E.cgrus <> 'IAU'
                                 AND A.emps IN ('ORF', 'ORA')
	ORDER BY A.datars DESC, A.mascnum, B.citens
	
	
	
	

	
	
	
	
	
	
	
	
--Pedidos
SELECT A.emps AS 'EMP', F.iclis AS 'COD_CLIENTE', RTRIM(F.rclis) AS 'CLIENTE',
	RTRIM(A.dopes) AS 'TIPO PEDIDO', A.datas AS 'DATA_ENTRADA', A.prazoents AS 'PRAZO', RTRIM(A.mascnum) AS 'PEDIDO',
	A.nops AS 'OP_PREFIXO',REPLACE(A.mascnum, ' ', '')+0 AS 'PEDIDO_NUMERO', COUNT(B.nops) AS 'NUM_ITENS'
FROM SigMvCab (NOLOCK) A
		LEFT JOIN SIGCDCLI (NOLOCK) F ON A.contads = F.iclis
		LEFT JOIN SigOpPic (NOLOCK) B ON A.empdopnums = B.empdopnums AND B.nopmaes= 0
WHERE A.datas > '2024-01-01'
	AND A.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
				'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO', 'PED ENCOMENDA POF', 'PED FABRICA POF')
	AND A.emps IN('ORF', 'ORA')
GROUP BY A.emps, F.iclis, F.rclis, A.dopes, A.datas, A.prazoents, A.mascnum, A.nops, A.mascnum
ORDER BY A.datas DESC