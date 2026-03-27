--Informação Geral dos Balanços
SELECT        TOP (100) PERCENT RTRIM(A.emps) AS EMPRESA, RTRIM(A.emps) + '_' + RTRIM(A.codigos) AS COD_BALANCO, RTRIM(A.grupos) AS GRUPO, RTRIM(A.contas) AS CONTA, MAX(B.datars) AS [DATA/HORA BALANÇO],
                             (SELECT        MAX(D.datars) AS Expr1
                               FROM            dbo.SigCdFcx AS C WITH (NOLOCK) LEFT OUTER JOIN
                                                         dbo.SigMvHst AS D WITH (NOLOCK) ON D.dopes = '' AND D.numes = C.codigos
                               WHERE        (A.contas = C.contas) AND (C.codigos < A.codigos)) AS [DATA INICIO], MAX(B.datars) AS [DATA FIM], RTRIM(A.usuars) AS RESPONSAVEL
FROM            dbo.SigCdFcx AS A WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.SigMvHst AS B WITH (NOLOCK) ON B.dopes = '' AND B.numes = A.codigos
GROUP BY A.emps, A.codigos, A.grupos, A.contas, A.usuars