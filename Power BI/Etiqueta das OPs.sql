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