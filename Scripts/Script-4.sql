SELECT 
    A.emps                                AS EMP,
    CONVERT(date, A.datas, 103)           AS ENTRADA,
    B.rclis                               AS CLIENTE,
    L.descs								  AS GRP_VENDA,
    A.dopes                               AS TIPO_DE_PEDIDO,
    R.OP_ORIGINAL,
    G.reffs                               AS REF_CLIENTE,
    C.cpros                               AS PRODUTO,
    G.cproeqs							  AS PROD_EQUIV,
    G.dpros                               AS DESCRICAO,
    G.codcors                             AS COR,
    SUM(C.qtds)                           AS QTD_INI,
    R.qtd_pend_total                      AS QTD_PRODUCAO,
    CONVERT(date, A.prazoents, 103)       AS PRAZO,
    K.mercs								  AS GRANDE_GRP,
    K.cgrus                               AS GRP_COMP,
    K.dgrus 							  AS GRUPO,
    J.codigos 							  AS SUBGRUPO,
    J.descricaos						  AS NOME_SUBGRUPO,
    I.cpros                               AS COD_COMP,
    I.dpros                               AS DESC_COMP,
    SUM(H.qtds)							  AS PESOS_TOTAL,
    SUM(H.qtds * R.qtd_pend_total / C.qtds)   AS PESOS_PROD,
    I.cunis                               AS UN1,
    SUM(H.pesos)						  AS QTD_TOTAL,
    SUM(H.pesos * R.qtd_pend_total / C.qtds)  AS QTD_PROD,
    I.cunips                              AS UN2,
    CASE
	    WHEN I.fabrproprs = 1 THEN 'VERDADEIRO'
	    ELSE 'FALSO'
	END AS FABRICADO,
	I.obspes							  AS 'OBS_INSUMO',
	Convert(varchar(max), I.dsccompras) AS 'DESC_COMPRA',
	I.cclass							  AS 'CLASS. INSUMO'
FROM Vw_ResumoOPsPendentes R
    INNER JOIN SIGOPPIC M (NOLOCK) 
        ON M.nops = R.OP_ORIGINAL 
        AND M.nopmaes = 0 
        AND M.qtds <> 0
        AND R.dopes = M.dopes
    INNER JOIN SigMvItn C (NOLOCK) 
        ON M.EMPDOPNUMS = C.EMPDOPNUMS 
        AND M.cpros = C.cpros 
        AND M.citens = C.citens
    INNER JOIN SigMvCab A (NOLOCK) 
        ON A.EMPDOPNUMS = C.EMPDOPNUMS
    INNER JOIN SIGCDCLI B (NOLOCK) 
        ON A.CONTADS = B.ICLIS
    CROSS APPLY (
        SELECT H.cpros, H.qtds, H.pesos
        FROM SigMvItn H (NOLOCK)
        WHERE H.empdopnums = C.empdopnums
          AND (C.citens = H.citem2 
               OR (H.cpros = C.cpros AND H.citem2 = 0 AND C.citens = H.citens))
    ) H
    LEFT JOIN SigCdPro G (NOLOCK) 
        ON C.cpros = G.cpros
    LEFT JOIN SigCdPro I (NOLOCK) 
        ON I.cpros = H.cpros
    LEFT JOIN SigCdGrp K (NOLOCK) 
        ON I.cgrus = K.cgrus
    LEFT JOIN SigCdPsg J (NOLOCK) 
        ON I.sgrus = J.codigos AND I.cgrus = J.cgrus
    LEFT JOIN SIGCDCOL L (NOLOCK)
    	ON G.colecoes = L.colecoes
WHERE A.dopes IN ('PEDIDO FABRICA','PEDIDO ENCOMENDA','PED FABRICA POF',
                   'PED ENCOMENDA POF','PEDIDO PILOTO','PEDIDO DE ENCOMENDA',
                   'PEDIDO DE FABRICA','PEDIDO DE PILOTO')
    AND A.datas >= '20250101'
    AND I.cgrus NOT IN ('SER', 'IAU')
    AND K.mercs <> 'PA'
GROUP BY 
    A.emps, A.datas, B.rclis, A.dopes, R.OP_ORIGINAL,
    G.reffs, C.cpros, G.dpros, G.codcors, A.prazoents,
    R.qtd_pend_total,
    K.cgrus, K.dgrus, J.codigos, J.descricaos,
    I.cpros, I.dpros, I.cunis, I.cunips, I.fabrproprs,
    L.descs, K.mercs, G.cproeqs, I.obspes,
    Convert(varchar(max), I.dsccompras), I.cclass