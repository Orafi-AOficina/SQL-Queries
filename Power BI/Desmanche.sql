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