SELECT DISTINCT
    D.nops AS 'OP',
    D.dataes AS 'DATA_OP',
    A.prazoents AS 'PRAZO_PEDIDO',
    D.codbarras AS 'FINALIZACAO',
    NF.NUM_NF,
    NF.DATA_NF
FROM dbo.SigMvCab AS A WITH (NOLOCK)
-- 1. O "outro caminho": descendo para os itens do pedido
INNER JOIN dbo.SigMvItn AS C WITH (NOLOCK) 
    ON A.empdopnums = C.empdopnums
-- 2. Conectando a OP validando documento, produto e linha do item
INNER JOIN dbo.SigOpPic AS D WITH (NOLOCK) 
    ON A.empdopnums = D.empdopnums 
   AND C.cpros = D.cpros 
   AND C.citens = D.citens
-- 3. Trazendo as NFs pelo Código de Barras (Finalização)
LEFT JOIN (
    SELECT DISTINCT
        C_NF.codbarras AS FINALIZACAO,
        A_NF.notas AS NUM_NF,
        A_NF.datas AS DATA_NF
    FROM SIGMVCAB A_NF (NOLOCK)
    INNER JOIN SIGMVITN C_NF (NOLOCK) 
        ON A_NF.empdopnums = C_NF.empdopnums
    LEFT JOIN SigMvItn M_NF (NOLOCK) 
        ON C_NF.codbarras = M_NF.codbarras 
       AND C_NF.cpros = M_NF.cpros
    WHERE A_NF.dopes IN ('NF VENDA', 'NF VENDA POF', 'NF VENDA PILOTO', 
                         'NF VENDA GAL', 'NF RET INDUSTRIA GAL', 'NF RET INDUSTRIALIZA')
      AND C_NF.citem2 = 0
      AND A_NF.datas >= '2025-01-01'
      AND M_NF.dopes = 'FINALIZA NACIONAL'
) AS NF
    ON NF.FINALIZACAO = D.codbarras
WHERE (A.datas >= '2025-01-01') 
  AND (A.dopes LIKE 'PED %' OR A.dopes LIKE 'PEDIDO %') 
  AND (A.dopes NOT LIKE '%ACRE%') 
  AND (A.dopes NOT LIKE '%PEDRA%')
  AND (D.qtds > 0)
ORDER BY 
    D.nops DESC
