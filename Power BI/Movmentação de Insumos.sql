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