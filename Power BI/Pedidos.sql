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