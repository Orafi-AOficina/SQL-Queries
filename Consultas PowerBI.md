Base de consultas feitas para o nosso powerbi com algumas breve explicações de o que cada consulta SQL fornece


--Situação de Finalização das OPs, FINALIZA S INDUSTRIA é cancelamento de pedido, FINALIZA OP S/BARRA é processo errado e FINALIZACAO é entrega de produto pela fábrica para faturamento
SELECT DISTINCT 
                         CASE WHEN D .dopes = 'FINALIZAÇÃO' AND E.emps = 'ORF' THEN 'ORA' WHEN D .dopes = 'FINALIZAÇÃO' AND E.emps <> 'ORF' THEN E.emps ELSE A.emps END AS EMPRESA, 
                         CASE WHEN D .dopes <> '' THEN D .dtalts ELSE A.datas END AS DATA, CASE WHEN D .dopes <> '' THEN RTRIM(D .dopes) ELSE RTRIM(A.dopps) END AS OPERACAO, 
                         CASE WHEN D .dopes = 'FINALIZAÇÃO' THEN E.nops ELSE B.nops END AS OP, E.cbars AS FINALIZACAO, E.qtds AS QTD, CASE WHEN D .dopes = 'FINALIZAÇÃO' THEN REPLACE(E.empdopnums, ' ', '') 
                         ELSE REPLACE(B.empdnps, ' ', '') END AS CHAVE_FINALIZACAO, E.pesos AS PESO_METAL, E.peso2s AS PESO_INSUMOS, E.pesos + E.peso2s AS PESO_TOTAL, E.pesoms AS PESO_TOTAL_CADASTRO, 
                         SUM(CASE WHEN F.TIPO_INSUMO = 'AU750' THEN F.PESO ELSE 0 END) AS PESO_AU750, SUM(CASE WHEN F.TIPO_INSUMO = 'AG925' THEN F.PESO ELSE 0 END) AS PESO_AG925, 
                         SUM(CASE WHEN F.TIPO_INSUMO = 'IMT' THEN F.PESO ELSE 0 END) AS PESO_IMT, SUM(CASE WHEN F.TIPO_INSUMO = 'BRILHANTE' THEN F.PESO ELSE 0 END) AS PESO_BRILHANTE, 
                         SUM(CASE WHEN F.TIPO_INSUMO = 'PEDRA' THEN F.PESO ELSE 0 END) AS PESO_PEDRA, SUM(CASE WHEN F.TIPO_INSUMO = 'BRILHANTE' THEN F.QTD ELSE 0 END) AS QTD_BRILHANTE, 
                         SUM(CASE WHEN F.TIPO_INSUMO = 'PEDRA' THEN F.QTD ELSE 0 END) AS QTD_PEDRA
FROM            dbo.SigPdMvf AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigOpPic AS B WITH (NOLOCK) ON A.nops = B.nops AND B.qtds > 0 LEFT OUTER JOIN
                         dbo.SigMvItn AS D WITH (NOLOCK) ON B.codbarras = D.codbarras AND D.dopes = 'DESMANCHE PEÇAS' AND B.cpros = D.cpros AND D.codbarras <> 0 LEFT OUTER JOIN
                         dbo.SIGOPETQ AS E WITH (NOLOCK) ON E.nops = B.nops AND E.cbars = B.codbarras LEFT OUTER JOIN
                             (SELECT        aa.codbarras, CASE WHEN aa.cunis = 'CT' THEN aa.qtds / 5 ELSE aa.qtds END AS PESO, aa.pesos AS QTD, 
                                                         CASE WHEN bb.cpros = 'AU750' THEN 'AU750' WHEN bb.cpros = 'AG925' THEN 'AG925' WHEN bb.cgrus = 'IMT' THEN 'IMT' WHEN bb.mercs = 'PED' AND bb.cgrus IN ('BR1', 'BR2', 'BR3', 'BR4') 
                                                         THEN 'BRILHANTE' WHEN bb.mercs = 'PED' THEN 'PEDRA' END AS TIPO_INSUMO
                               FROM            dbo.sigsubmv AS aa WITH (NOLOCK) LEFT OUTER JOIN
                                                         dbo.SigCdPro AS bb WITH (NOLOCK) ON aa.mats = bb.cpros) AS F ON E.cbars = F.codbarras
WHERE        (A.dopps IN ('FINALIZA S INDUSTRIA', 'FINALIZA OP S/BARRA', 'FINALIZAÇÃO')) AND (A.datas > '2023-01-01')
GROUP BY E.emps, A.emps, D.dtalts, A.datas, A.dopps, D.dopes, E.nops, B.nops, E.cbars, E.qtds, E.empdopnums, B.empdnps, E.pesos, E.peso2s, E.pesos, E.peso2s, E.pesoms

--Cadastro de Insumos
SELECT RTRIM(C.descs)  AS 'TIPO_CADASTRO', RTRIM(H.cgrus) AS 'GRP_INSUMO', RTRIM(A.sgrus) AS 'COD_SUBGRUPO', RTRIM(G.descricaos) AS 'SUBGRUPO',
			RTRIM(A.cpros) AS 'COD_INSUMO', RTRIM(A.dpros) AS 'DESC_INSUMO', A.cunis AS 'UN', A.dtincs AS 'DTE_CAD_INS', A.datas AS 'ULT_ALT_INS', MAX(D.dtincs) AS 'ULT_CAD_PROD',
			MAX(D.datas) AS 'ULT_ALT_PROD', MAX(E.ULT_OP) AS 'ULT_OP',
			CASE
				WHEN A.situas = 1 THEN 'ATIVO'
				WHEN A.situas = 2 THEN 'INATIVO'
				ELSE 'ERRO' 
			END AS 'STATUS_PROD',
			A.cbars AS 'CODBARRA_PROD'
	FROM SigCdPro A (NOLOCK)
		LEFT JOIN SigCdGpr C (NOLOCK) ON A.mercs = C.codigos
		LEFT JOIN SigCdPsg G (NOLOCK)  ON A.sgrus = G.codigos AND A.cgrus = G.cgrus
		LEFT JOIN SigCdGrp H (NOLOCK)  ON A.cgrus = H.cgrus
		LEFT JOIN SIGCDCLF I (NOLOCK)  ON A.clfiscals = I.codigos
		LEFT JOIN SIGPRCPO B (NOLOCK) ON A.cpros = B.mats --AND C.mats = I.mats
		LEFT JOIN SigCdPro D (NOLOCK) ON B.cpros = D.cpros
		LEFT JOIN (SELECT MAX(dtgeras) AS 'ULT_OP', cpros FROM SigOpPic (NOLOCK) GROUP BY cpros) E ON E.cpros  = D.cpros
	WHERE A.mercs = 'INS'
	GROUP BY C.descs, H.cgrus, H.dgrus, A.sgrus, G.descricaos, A.cpros, A.dpros, A.dtincs, A.datas, A.situas, I.codigos, I.descricaos, A.cbars, A.cunis
	ORDER BY A.datas DESC

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


--Pedidos
SELECT        TOP (100) PERCENT CASE WHEN A.emps = 'ORF' THEN 'ORA' ELSE A.emps END AS EMP, A.empdopnums AS CHAVE_PEDIDO, F.iclis AS COD_CLIENTE, RTRIM(F.rclis) AS CLIENTE, RTRIM(A.dopes) AS [TIPO PEDIDO], 
                         A.datas AS DATA_ENTRADA, A.prazoents AS PRAZO, RTRIM(A.mascnum) AS PEDIDO, A.nops AS OP_PREFIXO, CAST(A.obses AS NVARCHAR(4000)) AS OBSERVAÇÃO, RTRIM(A.compet) AS MES_ANL, A.ultgrvs, 
                         REPLACE(A.mascnum, ' ', '') + 0 AS PEDIDO_NUMERO, '' AS PEDIDO_ANIMALE, A.npedclis AS PEDIDO_CLIENTE, A.tabds AS TAB_VARIAÇÃO, A.usuars AS USUARIO, A.fpubls AS COD_PUB, 
                         B.descs AS FORMA_PUBLICIDADE
FROM            dbo.SigMvCab AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SIGCDCLI AS F WITH (NOLOCK) ON A.contads = F.iclis LEFT OUTER JOIN
                         dbo.SigCdFpb AS B WITH (NOLOCK) ON A.fpubls = B.cods
WHERE        (A.datas >= '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%')
ORDER BY 'DATA_ENTRADA' DESC


--OPs Geradas
-- Uma única OP pode referenciar vários itens de vários pedidos diferentes, mesmo que geralmente ela só se refira à um item de 1 único pedido. Isso acontece, porque é operacionalmente mais vantajoso processar uma OP
-- do mesmo produto mesmo que tenha pequenas variações de tamanho ou de cliente final do que várias OPs menores totalmente individualizadas
SELECT DISTINCT TOP (100) PERCENT CASE WHEN A.emps = 'ORF' THEN 'ORA' ELSE A.emps END AS EMPRESA, A.dataes AS DATA_OP, RTRIM(A.dopps) AS TIPO, A.nops AS OP,
                             (SELECT        SUM(qtds) AS Expr1
                               FROM            dbo.SigOpPic AS AA WITH (NOLOCK)
                               WHERE        (qtds > 0) AND (A.empdopnops = empdopnops) AND (A.nops = nops)) AS QTD, A.codbarras AS FINALIZACAO, A.empdnps AS CHAVE_INDUSTRIALIZACAO_PEDIDO, 
                         A.empdopnops AS CHAVE_INDUSTRIALIZACAO_ITEM, 
                         CASE WHEN H.nopmaes > 0 THEN H.nopmaes WHEN G.nopmaes > 0 THEN G.nopmaes WHEN F.nopmaes > 0 THEN F.nopmaes WHEN E.nopmaes > 0 THEN E.nopmaes WHEN D .nopmaes > 0 THEN D .nopmaes WHEN C.nopmaes
                          > 0 THEN C.nopmaes WHEN B.nopmaes > 0 THEN B.nopmaes WHEN A.nopmaes > 0 THEN A.nopmaes ELSE A.nops END AS OP_MAE, CASE WHEN CHARINDEX('#', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('#', 
                         A.obss) + LEN('#'), 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('PEDIDO ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('PEDIDO ', A.obss) + LEN('PEDIDO ') + 1, 4) 
                         + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('pedido ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('pedido ', A.obss) + LEN('pedido ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) 
                         WHEN CHARINDEX('Pedido ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('Pedido ', A.obss) + LEN('Pedido ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('PEDIDO: ', A.obss) 
                         > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('PEDIDO: ', A.obss) + LEN('PEDIDO: ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('pedido: ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, 
                         CHARINDEX('pedido: ', A.obss) + LEN('pedido: ') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('Pedido: ', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('Pedido: ', A.obss) + LEN('Pedido: ') + 1, 4) 
                         + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('PEDIDO', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('PEDIDO', A.obss) + LEN('PEDIDO') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) 
                         WHEN CHARINDEX('pedido', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('pedido', A.obss) + LEN('pedido') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('Pedido', A.obss) 
                         > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('Pedido', A.obss) + LEN('Pedido') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('DIDO', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('DIDO', 
                         A.obss) + LEN('DIDO') + 1, 4) + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN CHARINDEX('dido', A.obss) > 0 THEN '#' + SUBSTRING(A.obss, CHARINDEX('dido', A.obss) + LEN('dido') + 1, 4) 
                         + ' _ ' + CAST(A.obss AS VARCHAR(MAX)) WHEN
                             (SELECT        COUNT(AA.nops)
                               FROM            SigOpPic(NOLOCK) AA
                               WHERE        AA.qtds > 0 AND A.nops = AA.nops) > 1 THEN 'VERIFICAR OBS NA OP' ELSE CAST(A.obss AS VARCHAR(MAX)) END AS OBS
FROM            dbo.SigOpPic AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigOpPic AS B WITH (NOLOCK) ON A.nopmaes = B.nops AND A.citens = B.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS C WITH (NOLOCK) ON B.nopmaes = C.nops AND B.citens = C.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON C.nopmaes = D.nops AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS E WITH (NOLOCK) ON D.nopmaes = E.nops AND D.citens = E.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS F WITH (NOLOCK) ON E.nopmaes = F.nops AND E.citens = F.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS G WITH (NOLOCK) ON F.nopmaes = G.nops AND F.citens = G.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS H WITH (NOLOCK) ON G.nopmaes = H.nops AND G.citens = H.citens
WHERE        (A.dataes >= '2023-01-01') AND (A.qtds > 0)
ORDER BY 'OP'


--Resumo de Informações das NFs com os códigos de barra incluídos em cada uma das NFs
SELECT DISTINCT A.emps AS 'EMP', A.EMPDOPNUMS AS 'CHAVE_MAE', A.datas as 'DATA_NF', A.notas AS 'NUM_NF', C.codbarras AS 'FINALIZACAO', C.qtds AS 'QTD', P.cancelas AS 'CANCELA',
				RTRIM(P.series) AS 'SERIE_NF', C.citens, RTRIM(A.ultgrvs) AS 'DEVOLUCAO', REPLACE(N.empdncrds, ' ','') AS 'CHAVE_FINALIZACAO'
	FROM SIGMVCAB A (NOLOCK)
		LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
		LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
		LEFT JOIN SigMvNfi P (NOLOCK) ON P.empdopnums = A.empdopnums
		LEFT JOIN SigMvItn M (NOLOCK) ON C.codbarras = M.codbarras AND C.cpros = M.cpros
		LEFT JOIN SigMvCab N (NOLOCK) ON M.empdopnums = N.empdopnums
	WHERE A.DOPES IN ('NF VENDA', 'NF VENDA POF', 'NF VENDA PILOTO', 'NF VENDA GAL', 'NF RET INDUSTRIA GAL', 'NF RET INDUSTRIA GAL', 'NF RET INDUSTRIALIZA')
			AND C.citem2 = 0
			AND A.datas >='2023-01-01'
			AND M.dopes = 'FINALIZA NACIONAL'


--Movmentação de Insumos
SELECT        TOP (100) PERCENT A.datas AS DATA, CASE WHEN A.dopes = 'PEDIDO PEDRA' THEN 'REQUISICAO INSUMO' ELSE RTRIM(A.dopes) END AS OPERACAO, RTRIM(B.numes) AS [NUM OP], A.dtalts AS [DATA ALTERACAO], 
                         RTRIM(A.contaos) AS [COD FORNECEDOR], RTRIM(C.rclis) AS FORNECEDOR, A.obses AS OBS, RTRIM(A.empdopnums) AS [CHAVE OPERACAO], 
                         CASE WHEN A.dopes = 'PEDIDO PEDRA' THEN RTRIM(LTRIM(CONVERT(varchar(MAX), B.obs))) WHEN A.dopes = 'EMPENHO MT PRIMA' THEN CONVERT(varchar(MAX), D .nops) END AS OP, RTRIM(B.cpros) AS [COD INSUMO], 
                         RTRIM(B.dpros) AS [DESCRICAO INSUMO], RTRIM(B.cunis) AS UN, B.qtds AS PESO_TOTAL, B.pesos AS QTD, B.moevals AS COTACAO, RTRIM(B.moedas) AS MOEDA, RTRIM(A.ultgrvs) AS [OPERACAO BAIXA], 
                         A.chkbxparcs AS BAIXA, B.qtbaixas, B.aqtds, B.qtbxprods, B.qtprods, B.tpesos, B.chksubn, RTRIM(A.usuars) AS USUARIO, 0 AS [VALOR 1], 0 AS [VALOR 2], 0 AS VALOR_1, 0 AS VALOR_2
FROM            dbo.SigMvCab AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON A.empdopnums = B.empdopnums LEFT OUTER JOIN
                         dbo.SIGCDCLI AS C WITH (NOLOCK) ON A.contaos = C.iclis LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.nops = D.numps AND B.cpro2s = D.cpros AND D.nopmaes = 0
WHERE        (A.dopes IN ('SAIDA PRODUCAO', 'SAIDA PRODUCAO TOTAL')) AND (A.datas > '2023-01-01')
ORDER BY 'DATA' DESC



--Movimentações de Indústria
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
			CASE WHEN ISNULL(C.nops, 0) = 0 THEN '' ELSE RTRIM(B.codpds) END AS 'COD_PRODUTO', --B.empdnps, C.nops, B.datars, -- D.codbarras AS 'FINALIZACAO',
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
			CASE WHEN A.dopps = 'INDUSTRIALIZAÇÃO' OR A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(C.nops, 0) = 0 THEN 1
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
			CASE WHEN A.dopps = 'INDUSTRIALIZAÇÃO' OR A.dopps = 'TRABALHADOS S/ OP' OR ISNULL(C.nops, 0) = 0 THEN 0
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
			CASE WHEN ISNULL(C.nops, 0) = 0 THEN 0 ELSE B.cidchaves END AS 'INDEX'
		FROM SigCdNec (NOLOCK) A
			LEFT JOIN (SELECT DISTINCT aa.empdnps AS 'ANTIGA', REPLACE(aa.empdnps, 'ORF', 'ORA') AS 'NOVA' From SigCdNei (NOLOCK) aa LEFT JOIN SigCdNec (NOLOCK) bb ON aa.empdnps = bb.empdnps WHERE bb.emps IS NULL) D ON A.empdnps = D.NOVA
			LEFT JOIN (SELECT DISTINCT nops, codpds, empdnps, MIN(datas) as 'datas', MIN(CAST(cidchaves AS BIGINT)) as 'cidchaves', MIN(datars) as 'datars', dopps
								FROM SigPdMvf (NOLOCK) 
							GROUP BY nops, codpds, empdnps, dopps) B ON (A.empdnps = B.empdnps OR D.ANTIGA = B.empdnps)
			LEFT JOIN (SELECT DISTINCT tpops, dopps, emps, nops, numps, empdnps, cidchaves FROM SigCdNei (NOLOCK)) C ON (C.empdnps = B.empdnps AND C.nops = B.nops) OR (ISNULL(C.nops, -1) = -1 AND (A.empdnps = C.empdnps OR C.empdnps = D.ANTIGA)) OR (C.empdnps = A.empdnps AND A.dopps = 'TRABALHADOS S/ OP')
			LEFT JOIN SIGCDCLI E (NOLOCK) ON A.contaos = E.iclis
			LEFT JOIN SigCdPro F (NOLOCK) ON B.codpds = F.cpros
			LEFT JOIN SIGCDCLI G (NOLOCK) ON A.contads = G.iclis
		WHERE A.datas >= '01-01-2023'




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




--Itens dos Pedidos, versão revisada e atualizada
SELECT        TOP (100) PERCENT C.empdopnums AS CHAVE_PEDIDO, C.citens AS ITEM_PEDIDO, D.nops AS OP_MAE, RTRIM(E.reffs) AS REF_CLIENTE, RTRIM(E.cpros) AS COD_PRODUTO, E.dpros AS DESC_PRODUTO, E.codcors AS COR,
                         C.qtds AS QTD, RTRIM(CONVERT(varchar, A.numes) + C.cpros) AS CHAVE_ORCAMENTO, CAST(C.obs AS NVARCHAR(4000)) AS DETALHAMENTO_PEDIDO, CASE WHEN CHARINDEX('#', C.obs) = NULL THEN NULL 
                         WHEN CHARINDEX('#', C.obs) = 0 THEN NULL ELSE RTRIM(REPLACE(REPLACE(LEFT(RIGHT(CAST(C.OBS AS NVARCHAR(4000)), LEN(CAST(C.OBS AS NVARCHAR(4000))) - CHARINDEX('#', C.obs)), 5), ',', ''), '/', '')) 
                         END AS PEDIDO_ECOMMERCE, C.empdopnums + '_' + CAST(C.citens AS VARCHAR) AS CHAVE_ITEM_PEDIDO
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND C.cpros = D.cpros AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS E WITH (NOLOCK) ON C.cpros = E.cpros
WHERE        (A.datas >= '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.nopmaes = 0)
ORDER BY 'OP_MAE', 'ITEM_PEDIDO' DESC


--Itens dos Pedidos, versão original
SELECT        MIN(A.empdopnums) AS CHAVE_PEDIDO, D.nops AS OP_MAE, MIN(RTRIM(E.reffs)) AS REF_CLIENTE, MIN(E.cgrus) AS GRP_PRODUTO, MIN(RTRIM(B.cpros)) AS COD_PRODUTO, MIN(B.dpros) AS DESC_PRODUTO, 
                         MIN(E.codcors) AS COR,
                             (SELECT        SUM(qtds) AS Expr1
                               FROM            dbo.SigOpPic AS X WITH (NOLOCK)
                               WHERE        (numps = D.numps) AND (B.cpros = cpros)
                               GROUP BY numps) AS QTD, MIN(RTRIM(CONVERT(varchar, A.numes) + B.cpros)) AS CHAVE_ORCAMENTO, NULL AS OBS_OP, NULL AS PEDIDO_ECOMMERCE
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS E WITH (NOLOCK) ON B.cpros = E.cpros
WHERE        (A.datas > '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.nopmaes = 0)
GROUP BY D.nops, B.cpros, D.numps



--Etiquetas, Códigos de Barra ou Finalizacao (o nome mais correto é código de barra) são nomes diferentes para a mesma coisa. Basicamente toda OP finalizada "envelopa" todos os itens em um Lote de produto com controle individualizado
-- e que só permite operações com todos os itens dentro desse lote juntos. Essa tabela oferece uma lista de todas as OPs finalizadas e dos códigos de barra gerados
-- Uma OP pode ter vários códigos de barra a depender do tipo de pedido ou do agrupameto que os pedidos tiveram na geração da OP.
SELECT        TOP (100) PERCENT D.nops AS OP, RTRIM(E.reffs) AS REF_CLIENTE, RTRIM(E.cpros) AS COD_PRODUTO, E.dpros AS DESC_PRODUTO, E.codcors AS COR, C.empdopnums AS CHAVE_PEDIDO, C.citens AS ITEM_PEDIDO, 
                         D.codbarras AS FINALIZACAO, C.empdopnums + '_' + CAST(C.citens AS VARCHAR) AS CHAVE_ITEM_PEDIDO, D.qtds AS QTD_ETIQUETA
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND C.cpros = D.cpros AND C.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS E WITH (NOLOCK) ON C.cpros = E.cpros
WHERE        (A.datas >= '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.qtds > 0)
ORDER BY 'CHAVE_PEDIDO', 'ITEM_PEDIDO', 'OP'



--Etapas de Produção cadastradas em cada produto seguindo ficha técnica (não é uma informação validada, está incompleta e cheia de erros!)
SELECT RTRIM(A.produtos) AS 'COD_PRODUTOS', A.ordems AS 'N_ETAPA', A.ordems +1 AS 'N_ETAPA_PROXIMA', A.dataalts AS 'DATA_ATUALIZACAO', RTRIM(A.grupos) AS 'OPERACAO', A.minutos AS 'TEMPO',
		CASE
			WHEN A.obs LIKE '%SIMPLES%' THEN 'SIMPLES'
			WHEN A.obs LIKE '%#MEDIO%' THEN 'MEDIO'
			WHEN A.obs LIKE '%COMPLEXO%' THEN 'COMPLEXO'
		END AS 'COMPLEXIDADE', A.obs AS 'OBS',
		CONCAT(A.ordems,'_'+RTRIM(A.produtos)) AS 'INDEX_ETAPA', CONCAT((A.ordems+1), '_'+RTRIM(A.produtos)) AS 'INDEX_ETAPA_PROXIMA', RTRIM(A.produtos) + '_' + RTRIM(A.grupos) AS 'INDEX_ETAPA_PRODUTO' 
	FROM SigCdPfc (NOLOCK) A
		WHERE A.dataalts = (SELECT DISTINCT MAX(dataalts) FROM SigCdPfc WHERE A.produtos = produtos GROUP BY produtos)
				AND A.dataalts >= '2021-09-01'



--Posições de Estoque
SELECT RTRIM(A.emps) AS 'EMP', RTRIM(A.grupos) AS 'GRP_MOV', RTRIM(D.grupos) AS 'GRP_CONTA', RTRIM(D.iclis) AS 'COD_CONTA', RTRIM(D.RCLIS) AS 'DESC_CONTA', RTRIM(D.razaos) AS 'CPF',
			RTRIM(B.cgrus) AS 'GRP_INSUMO', RTRIM(B.cpros) AS 'COD_INSUMO', RTRIM(B.DPROS) AS 'DESC_INSUMO', A.sqtds AS 'QTD', B.cunis AS 'UN', A.spesos AS 'PESOS', RTRIM(B.moedas) AS 'MOEDA'
FROM sigmvest (NOLOCK) A 
		LEFT join sigcdpro (NOLOCK) B on A.cpros = B.cpros
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.ESTOS = D.ICLIS 
	WHERE (A.sqtds <> 0 OR A.spesos <> 0) AND D.grupos NOT IN ('CLIENTE','FORNECEDOR') AND D.iclis NOT IN ('ESTOQUE')
	ORDER BY RTRIM(A.grupos), RTRIM(D.rclis)




--Dias úteis com trabalho na fábrica
--Dias com movimentação na fábrica
SELECT DISTINCT CAST(A.datas AS DATE) AS 'DATA'
		FROM SigCdNec (NOLOCK) A
		WHERE A.datas >= '2021-09-01'




--Detalhamento de informações das OPs com infomações de quais observações foram feitas para cada item finalizado de uma OP.
SELECT        TOP (100) PERCENT D.nops AS OP, D.obss AS OBS_OP, D.codbarras AS FINALIZAÇÃO
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON A.empdopnums = D.empdopnums AND B.cpros = D.cpros AND C.citens = D.citens
WHERE        (A.datas > '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%')
ORDER BY 'OP' DESC




-- Detalhamento dos itens com falha em cada um dos balanços!

/* balanços com alguma falha em au750*/
SELECT RTRIM(A.emps) AS 'EMPRESA', RTRIM(A.emps) + '_' + RTRIM(A.codigos) AS 'COD_BALANCO', RTRIM(A.grupos) AS 'GRUPO', RTRIM(A.contas) AS 'CONTA', 
                         B.datars AS 'DATA/HORA BALANÇO', RTRIM(C.mercs) AS 'GRANDE_GRP', RTRIM(C.cgrus) AS 'GRP_INSUMO', RTRIM(B.cpros) AS 'COD_INSUMO', RTRIM(C.dpros) AS 'DESC_INSUMO', 
                         (CASE WHEN B.opers = 'E' THEN - 1 ELSE 1 END) * B.qtds AS 'FALHA_REAL', (CASE WHEN B.opers = 'E' THEN - 1 ELSE 1 END) * B.pesos AS 'QTD_FALHA', B.opers AS 'SENTIDO', 
                         CASE WHEN A.datais > '01-01-2000' THEN A.datais ELSE F.dataincs END AS 'DATA INICIO', A.datas AS 'DATA FIM', RTRIM(A.usuars) AS 'RESPONSAVEL'
FROM            SigCdFcx A(NOLOCK) LEFT JOIN
                         SigMvHst B(NOLOCK) ON B.dopes = '' AND B.numes = A.codigos AND A.emps = B.emps LEFT JOIN
                         SigCdCli F(NOLOCK) ON F.iclis = A.contas LEFT JOIN
                         SigCdPro C(NOLOCK) ON C.cpros = B.cpros
UNION
/* balanços com falha 0 em au750*/
SELECT DISTINCT 
                         RTRIM(A.emps) AS 'EMPRESA', RTRIM(A.emps) + '_' + RTRIM(A.codigos) AS 'COD_BALANCO', RTRIM(A.grupos) AS 'GRUPO', RTRIM(A.contas) AS 'CONTA', CASE WHEN MAX(B.datars) < '01-01-2040' THEN MAX(B.datars) 
                         ELSE A.datas END AS 'DATA/HORA BALANÇO', 'INS' AS 'GRANDE_GRP', 'IAU' AS 'GRP_INSUMO', 'AU750' AS 'COD_INSUMO', 'OURO 18K' AS 'DESC_INSUMO', 0 AS 'FALHA_REAL', 0 AS 'QTD_FALHA', 'S' AS 'SENTIDO', 
                         CASE WHEN A.datais > '01-01-2000' THEN A.datais ELSE F.dataincs END AS 'DATA INICIO', A.datas 'DATA FIM', RTRIM(A.usuars) AS 'RESPONSAVEL'
FROM            SigCdFcx A(NOLOCK) LEFT JOIN
                         SigMvHst B(NOLOCK) ON B.dopes = '' AND B.numes = A.codigos AND A.emps = B.emps LEFT JOIN
                         SigCdCli F(NOLOCK) ON F.iclis = A.contas
WHERE        (SELECT        COUNT(E.cpros)
                          FROM            SigMvHst E(NOLOCK)
                          WHERE        E.dopes = '' AND E.numes = A.codigos AND A.emps = E.emps AND E.cpros = 'AU750') = 0
GROUP BY A.emps, A.codigos, A.grupos, A.contas, A.usuars, A.datas, A.datais, F.dataincs




--O Desmanche é o processo inverso à finalização. Se a finalização transforma os insumos que estão no estoque em um produto o desmanche transforma o produto finalizado no estoque de produtos acabados
-- novamente em insumos para que eles possam ser derretidos e reutilizados pela fábrica em outros produtos 
SELECT DISTINCT 
                         TOP (100) PERCENT A.emps AS EMPRESA, C.empdopnums AS CHAVE_OPERACAO, C.dtalts AS DATA_HORA, RTRIM(C.dopes) AS OPERACAO, RTRIM(C.dopes) AS TIPO_OPERACAO, A.nops AS OP, 
                         C.codbarras AS FINALIZACAO, NULL AS GRP_CONTA_ORI, NULL AS COD_CONTA_ORI, NULL AS NOME_CONTA_ORI, NULL AS GRP_CONTA_DEST, NULL AS COD_CONTA_DEST, NULL AS NOME_CONTA_DEST, NULL 
                         AS PESO_TOTAL, NULL AS OBSERVAÇÃO, NULL AS CHAVE_FINALIZACAO
FROM            dbo.SigPdMvf AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigOpPic AS B WITH (NOLOCK) ON A.nops = B.nops AND B.qtds > 0 LEFT OUTER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON B.codbarras = C.codbarras AND C.dopes = 'DESMANCHE PEÇAS' AND B.cpros = C.cpros AND C.codbarras <> 0
WHERE        (C.dtalts >= '2023-01-01') AND (C.dopes = 'DESMANCHE PEÇAS')
ORDER BY 'DATA_HORA' DESC




--Contas de Estoque e Cadastro de Clientes do Sistema
--Contas do Sistema
SELECT RTRIM(A.grupos) AS 'GRUPO_CONTA', RTRIM(A.iclis) AS 'COD_CONTA', RTRIM(A.rclis) AS 'DESC_CONTA', RTRIM(A.razaos) AS 'CPF', RTRIM(REPLACE(REPLACE(A.razaos,'.',''),'-','')) AS 'CPF2',
				CASE WHEN A.inativas = 0 THEN 'ATIVA' ELSE 'INATIVA' END AS 'STATUS_CONTA', A.dataincs AS 'DATA_CADASTRO', A.dtalts AS 'DATA_ALT'
	FROM SigCdCli (NOLOCK) A
	ORDER BY A.inativas, A.rclis



--Composição do Cadastro de Produtos
--Composição do Produto
SELECT RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(D.mercs) AS 'GRANDE_GRP', RTRIM(D.cgrus) 'GRP_INSUMO', RTRIM(D.cpros) AS 'COD_INSUMOS', RTRIM(D.dpros) AS 'DESC_INSUMO',
			D.pesoms AS 'PESO_MEDIO', C.pesos AS 'PESOS', RTRIM(C.cunips) AS 'UN_PESOS', C.qtds AS 'QTD', C.qtdcvs AS 'QTD_2', RTRIM(C.unicompos) AS 'UN_QTD', D.custofs AS 'VALOR_INSUMO',
			D.margems AS 'MARGEM_INSUMO', D.pvens AS 'VAL_INSUMO_C_MARGEM', RTRIM(D.moedas) AS 'MOEDA', RTRIM(D.obspes) AS 'OBS', ROUND(C.markcvs,3) AS 'MARKUP_INS', C.obsofs AS 'OBS_INSUMO',
			Convert(varchar(max), A.dsccompras) AS 'DESCRICAO_COMPRA',
			CASE
				WHEN A.mercs = 'INS' THEN (SELECT SUM(AA.qtds) FROM SIGPRCPO (NOLOCK) AA WHERE AA.cpros = A.cpros AND AA.cgrus = 'IAU' GROUP BY AA.cpros) ELSE 0
			END AS 'PESO_IMT',
			RTRIM(H.codigos) AS 'COD_SUBGRUPO', RTRIM(H.descricaos) AS 'SUBGRUPO', RTRIM(H.descricaos) AS 'Insumo Tratado', RTRIM(E.dgrus) AS 'GRUPO_INS',
			CASE WHEN D.cgrus = 'IAU' THEN RTRIM(B.descs) ELSE RTRIM(F.descs) END AS 'COR_INS',
			CASE 
				WHEN D.cgrus IN ('IAU', 'INS', 'IMT') THEN ' '+RTRIM(B.descs)
				WHEN D.mercs = 'PED' THEN RTRIM(E.dgrus) + ' ' + ISNULL(RTRIM(F.descs), '')
			END AS 'DESC_BOOK_INS'
	FROM SigCdPro A (NOLOCK)
			LEFT JOIN SigCdCor B (NOLOCK) ON B.cods = A.codcors
			LEFT JOIN SIGPRCPO C (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
			INNER JOIN SigCdPro D (NOLOCK) ON C.mats = D.cpros
			LEFT JOIN SigCdGrp E (NOLOCK) ON D.cgrus = E.cgrus
			LEFT JOIN SigCdCor F (NOLOCK) ON F.cods = D.codcors
			LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes
			LEFT JOIN SigCdPsg H (NOLOCK) ON D.sgrus = H.codigos AND D.cgrus = H.cgrus
		WHERE ((A.mercs = 'PA' AND A.datas >= '2021-09-01') OR (A.mercs = 'INS' AND A.cgrus = 'IMT'))
	ORDER BY COD_PROD ASC




--Composição dos Insumos necessários para a Produção de cada OP em função do cadastro de cada produto que compõe ela
SELECT        A.datas AS DATA, D.nops AS OP_ITEM, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, SUM(C.totas) AS VALOR_ITEM, SUM(C.qtds) AS QTD_ITEM, C.cunis AS UNIDADE, SUM(C.pesos) AS PESO, 
                         RTRIM(H.mercs) AS GRANDE_GRP, RTRIM(H.cgrus) AS GRP, I.dgrus AS GRP_INSUMO, 
                         CASE WHEN C.cpros = 'RODIO 2,00    ' THEN 'AU750' WHEN H.cgrus = 'IAU' THEN 'AU750' WHEN H.cgrus = 'BRI' THEN 'BRILHANTES' WHEN H.cgrus = 'PED' THEN 'PEDRAS' WHEN H.cgrus = 'IMT' THEN 'INSUMOS METALICOS'
                          ELSE I.dgrus END AS GRUPO_INS, RTRIM(H.sgrus) AS COD_SUBGRUPO, RTRIM(G.descricaos) AS SUBGRUPO, RTRIM(G.descricaos) AS [Insumo Tratado]
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND (B.citens = C.citem2 OR
                         B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens) LEFT OUTER JOIN
                         dbo.SigOpPic AS D WITH (NOLOCK) ON C.empdopnums = D.empdopnums AND B.cpros = D.cpros AND B.citens = D.citens LEFT OUTER JOIN
                         dbo.SigCdPro AS H WITH (NOLOCK) ON C.cpros = H.cpros LEFT OUTER JOIN
                         dbo.SigCdGrp AS I WITH (NOLOCK) ON I.cgrus = H.cgrus LEFT OUTER JOIN
                         dbo.SigCdPsg AS G WITH (NOLOCK) ON H.sgrus = G.codigos AND H.cgrus = G.cgrus
WHERE        (A.datas > '2023-01-01') AND (A.dopes LIKE 'PED %' OR
                         A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%') AND (D.nopmaes = 0)
GROUP BY A.datas, D.nops, C.cpros, C.dpros, C.cunis, I.dgrus, H.cgrus, I.dgrus, H.sgrus, G.descricaos, H.mercs, H.cgrus





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
WHERE  B.datas >= '01-01-2023'
ORDER BY B.datas DESC





-- Composição das Movimentações de Indústria
SELECT        TOP (100) PERCENT B.emps AS EMPRESA, B.empdnps AS CHAVE_OPERACAO, RTRIM(B.dopps) AS TIPO_OPERACAO, CASE WHEN A.tpops = '' THEN RTRIM(B.dopps) WHEN A.tpops IS NULL THEN RTRIM(B.dopps) 
                         WHEN B.dopps = 'DIVISAO DE OP' THEN RTRIM(B.dopps) ELSE RTRIM(A.tpops) END AS OPERACAO, A.nops AS OP, RTRIM(D.descs) AS TIPO_ITEM_ESTOQUE, RTRIM(C.mercs) AS GRANDE_GRP, RTRIM(C.cgrus) 
                         AS GRP_INSUMO, RTRIM(A.cmats) AS INSUMO, RTRIM(C.dpros) AS DESC_INSUMO, A.pesos AS PESO_UNIT, A.qtds AS QTD_TOT, RTRIM(A.cunis) AS UN, A.custofs AS CUSTO_AU, RTRIM(A.moecusfs) AS MOEDA_CUSTO, 
                         A.peso2s, A.qtds * A.custofs AS COMPRA_OFI, REPLACE(B.empdnps, ' ', '') AS CHAVE_FINALIZACAO, A.nops AS OP2
FROM            dbo.SigCdNec AS B LEFT OUTER JOIN
                         dbo.SigCdNei AS A WITH (NOLOCK) ON A.dopps = B.dopps AND A.numps = B.numps AND LEFT(A.emps, 2) = LEFT(B.emps, 2) LEFT OUTER JOIN
                         dbo.SigCdPro AS C WITH (NOLOCK) ON A.cmats = C.cpros LEFT OUTER JOIN
                         dbo.SigCdGpr AS D WITH (NOLOCK) ON C.mercs = D.codigos
WHERE        (B.datas >= '01-01-2023')




--Cadastro de Clientes
SELECT DISTINCT RTRIM(A.idcontas) AS 'NUM_LOJA', RTRIM(A.faxs) 'COD_LOJA', RTRIM(B.descs) AS 'TIPO_LOJA', RTRIM(A.iclis) AS 'COD_CLIENTE', RTRIM(A.rclis) AS 'CLIENTE', RTRIM(A.razaos) AS 'RAZAO SOCIAL',
			RTRIM(A.cpfs) AS 'CNPJ', CAST(A.obs AS varchar) AS 'NOME LOJA', RTRIM(A.cidas) AS 'CIDADE', RTRIM(A.estas) AS 'ESTADO', RTRIM(A.tabds) AS 'TBL_DESCONTO', RTRIM(A.contaven2s) AS 'COD_CONTA_MAE',
			RTRIM(C.rclis) AS 'CONTA_MAE'
FROM SigMvCab AS D WITH (NOLOCK)
		LEFT OUTER JOIN SIGCDCLI AS A WITH (NOLOCK) ON D.contads = A.iclis
		LEFT JOIN SigCdFpb (NOLOCK) B ON A.fpubls = B.cods
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaven2s = C.iclis
WHERE (D.dopes LIKE 'PED %' OR D.dopes LIKE 'PEDIDO %' OR D.dopes LIKE '%CONSERT%' OR D.dopes LIKE '%CONSERT%' OR D.dopes LIKE '%TRUNKSH%')
ORDER BY RTRIM(A.rclis)






--Cadastro de Produto
SELECT RTRIM(C.descs)  AS 'TIPO_CADASTRO', RTRIM(D.colecoes) AS 'COD_GRP_VENDA', RTRIM(D.descs) AS 'GRUPO_VENDA', RTRIM(H.cgrus) AS 'GRP_PROD',
			RTRIM(H.dgrus) AS 'DESC_GRUPO', RTRIM(A.sgrus) AS 'COD_SUBGRUPO', RTRIM(G.descricaos) AS 'SUBGRUPO', RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.reffs) AS 'REF_CLIENTE',
			RTRIM(REPLACE(A.reffs,'.','')) AS 'REF_CLIENTE_TRATADA', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(J.cods) AS 'COR', RTRIM(J.descs) AS 'DESC_COR', A.matprincs AS 'METAL_PRINCIPAL',
			RTRIM(A.codtams) AS 'COD_TAMANHO', RTRIM(F.descs) AS 'TAMANHO', A.dtincs AS 'DTE_INCLUSAO', A.datas AS 'ULT_ALTERACAO', RTRIM(E.linhas) AS 'COD_LINHA', RTRIM(E.descs) AS 'LINHA',
			RTRIM(A.codfinp) AS 'COD_MODELO', RTRIM(B.descs) AS 'MODELO',
			CASE WHEN A.pesometal < A.pesoms THEN A.pesometal ELSE A.pesoms END AS 'PESO_METAL_CADASTRO', A.pesoms AS 'PESO_LIQ_CADASTRO',
			CASE
				WHEN A.situas = 1 THEN 'ATIVO'
				WHEN A.situas = 2 THEN 'INATIVO'
				ELSE 'ERRO' 
			END AS 'STATUS_PROD', A.obscompras AS 'COR_ANL', RTRIM(A.dpro2s) AS 'DESC_ANIMALE', RTRIM(A.idecpros) AS 'IDENTIFICADOR', RTRIM(A.codident) AS 'REF_DESENVOLVIMENTO',
			A.descfis AS 'DESC_FISCAL', RTRIM(I.codigos) AS 'COD_CLASS_FISCAL', RTRIM(I.descricaos) AS 'CLASS_FISCAL',
			CASE
				WHEN A.figjpgs IS NULL THEN 'VERDADEIRO'
				ELSE 'FALSO'
			END AS 'FOTO CADASTRADA', A.cbars AS 'CODBARRA_PROD', A.dpro3s AS 'DESC_SITE_OFICIAL', E.descs, C.descs
	FROM SigCdPro A (NOLOCK)
		LEFT JOIN SIGCDFIP B (NOLOCK) ON B.cods = A.codfinp
		LEFT JOIN SigCdGpr C (NOLOCK) ON A.mercs = C.codigos
		LEFT JOIN SIGCDCOL D (NOLOCK) ON A.colecoes =D.colecoes
		LEFT JOIN SigCdLin E (NOLOCK)  ON A.linhas = E.linhas
		LEFT JOIN SigCdTam F (NOLOCK)  ON A.codtams = F.cods
		LEFT JOIN SigCdPsg G (NOLOCK)  ON A.sgrus = G.codigos AND A.cgrus = G.cgrus
		LEFT JOIN SigCdGrp H (NOLOCK)  ON A.cgrus = H.cgrus
		LEFT JOIN SIGCDCLF I (NOLOCK)  ON A.clfiscals = I.codigos
		LEFT JOIN SigCdCor J (NOLOCK) ON A.codcors = J.cods
	WHERE ((C.descs = 'PRODUTOS'  AND A.datas >= '2021-09-01') OR (C.descs = 'INSUMOS' AND A.cgrus = 'IMT'))
	ORDER BY A.datas DESC





--Informação Geral dos Balanços
SELECT        TOP (100) PERCENT RTRIM(A.emps) AS EMPRESA, RTRIM(A.emps) + '_' + RTRIM(A.codigos) AS COD_BALANCO, RTRIM(A.grupos) AS GRUPO, RTRIM(A.contas) AS CONTA, MAX(B.datars) AS [DATA/HORA BALANÇO],
                             (SELECT        MAX(D.datars) AS Expr1
                               FROM            dbo.SigCdFcx AS C WITH (NOLOCK) LEFT OUTER JOIN
                                                         dbo.SigMvHst AS D WITH (NOLOCK) ON D.dopes = '' AND D.numes = C.codigos
                               WHERE        (A.contas = C.contas) AND (C.codigos < A.codigos)) AS [DATA INICIO], MAX(B.datars) AS [DATA FIM], RTRIM(A.usuars) AS RESPONSAVEL
FROM            dbo.SigCdFcx AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigMvHst AS B WITH (NOLOCK) ON B.dopes = '' AND B.numes = A.codigos
GROUP BY A.emps, A.codigos, A.grupos, A.contas, A.usuars





--Balanço consolidado pela QTD de trabalho feita para cada um dos itens movimentados
SELECT RTRIM(A.emps) AS 'EMP', A.codigos AS 'BALANCO', RTRIM(A.emps) + '_' + CAST(A.codigos as varchar) AS 'CHAVE_BALANCO', RTRIM(A.cpros) AS 'COD_INSUMO', RTRIM(A.tpops) AS 'OPERACAO',
				A.pfalhas AS 'PERCENT_FALHA', A.pesoents AS 'PESO_ENT', A.pesosais AS 'PESO_SAI',
				A.pesobsais AS 'PESO_BASE_SAI', A.falhas AS 'FALHA_ADMITIDA', A.pesos AS 'QTD_ADMITIDA', RTRIM(A.tpops) +  RTRIM(A.cpros) AS 'CHAVE_CONFIGFALHA', RTRIM(A.emps) + '_' + CAST(A.codigos as varchar) + '_' + RTRIM(A.cpros) AS 'CHAVE_BALANCO_INSUMO'
FROM SigCdFes (NOLOCK) A
ORDER BY A.codigos DESC, A.tpops, A.cpros