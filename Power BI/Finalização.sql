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