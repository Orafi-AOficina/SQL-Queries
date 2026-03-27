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