-- Saídas de Produção, são operações que enviam insumos do estoque de materia prima para os setores necessários na produção
SELECT RTRIM(A.emps) AS 'EMP', A.datars AS 'DATA-HORA', RTRIM(A.dopes) AS 'OPERARAÇAO', A.mascnum+0 AS 'NUM_OP', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG',
	RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST', RTRIM(B.cpros) AS 'COD_INS',
	RTRIM(B.dpros) AS 'DESC_INS', RTRIM(B.codbarras) AS 'CÓDIGO DE BARRAS', B.qtds AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', B.pesos AS 'QTD2', RTRIM(B.cunips) AS 'UNIT_QTD2', B.obs AS 'OBS_ITEM', A.usuars AS 'RESPONSAVEL',
	E.dtincs AS 'DATA_ENTRADA', E.grupos AS 'GRP_ESTOQUE', E.contas AS 'COD_CONTA', F.rclis AS 'CONTA', Convert(varchar(max),A.obses) AS 'OBSERVACAO', A.chkbxparcs AS 'BAIXA',
	A.dtbaixas AS 'DATA BAIXA', REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''),' ', '') AS 'OPERACAO ACEITE'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		INNER JOIN SIGOPETQ (NOLOCK) E ON B.codbarras=  E.cbars
		INNER JOIN SIGCDCLI (NOLOCK) F ON E.contas = F.iclis
	WHERE (A.dopes = 'ENTRADA TRUNKSHOW') AND A.datas >= '2023-01-01'
	ORDER BY A.datars DESC, A.mascnum

	

	
	
	
SELECT        TOP (100) PERCENT RTRIM(A.emps) AS EMP, A.datars AS [DATA-HORA], RTRIM(A.dopes) AS OPERARAÇAO, A.mascnum + 0 AS NUM_OP, RTRIM(A.grupoos) AS GRUPO_ORG, RTRIM(A.contaos) AS CONTA_ORG, RTRIM(C.rclis) 
                         AS NOME_ORG, RTRIM(A.grupods) AS GRUPO_DEST, RTRIM(A.contads) AS CONTA_DEST, RTRIM(D.rclis) AS NOME_DEST, RTRIM(B.cpros) AS COD_INS, RTRIM(B.dpros) AS DESC_INS, B.codbarras 
                         AS [CÓDIGO DE BARRAS], B.qtds AS QTD, RTRIM(B.cunis) AS UNIT_QTD, B.pesos AS QTD2, RTRIM(B.cunips) AS UNIT_QTD2, B.obs AS OBS_ITEM, RTRIM(A.usuars) AS RESPONSAVEL, E.dtincs AS DATA_ENTRADA, 
                         RTRIM(E.grupos) AS GRP_ESTOQUE, RTRIM(E.contas) AS COD_CONTA, RTRIM(F.rclis) AS CONTA, RTRIM(CONVERT(varchar(MAX), A.obses)) AS OBSERVACAO, A.chkbxparcs AS BAIXA, A.dtbaixas AS [DATA BAIXA], 
                         REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''), ' ', '') AS [OPERACAO ACEITE]
FROM            dbo.SigMvCab AS A WITH (NOLOCK) INNER JOIN
                         dbo.SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = A.empdopnums INNER JOIN
                         dbo.SIGCDCLI AS C WITH (NOLOCK) ON A.contaos = C.iclis INNER JOIN
                         dbo.SIGCDCLI AS D WITH (NOLOCK) ON A.contads = D.iclis INNER JOIN
                         dbo.SIGOPETQ AS E WITH (NOLOCK) ON B.codbarras = E.cbars INNER JOIN
                         dbo.SIGCDCLI AS F WITH (NOLOCK) ON E.contas = F.iclis
WHERE        A.dopes = 'ENTRADA TRUNKSHOW'
	




--Estoque de códigos de barra
SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.grupos AS 'GRP_ESTOQUE', a.contas AS 'COD_CONTA', c.rclis AS 'CONTA', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO',
					a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS', a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', d.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', d.dpros AS 'DESCRICAO',
					b.qtds AS 'QTD_OP', a.qtds AS 'QTD_ETQ', e.NUM_COD_BARRAS as 'NUM_BARRAS_OP', d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_METAL',
					a.peso2s as 'PESO_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO', b.obss as 'OBS_OP', g.descs AS 'COD_POF'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.cbars) as 'NUM_COD_BARRAS', ee.nops from sigopetq (nolock) ee where ee.cbars > 0 group by ee.nops) e on e.nops = a.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) f on f.nops = a.nops and (a.cbars <= f.codbarras and (a.cbars > f.PROX_CBARS or ISNULL(f.PROX_CBARS, -1) = -1 ))
	left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = f.codbarras
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigprfti (nolock) g on d.cftios = g.cods
where a.grupos IN ('GERENCIAL', '') AND a.dtincs > '01-01-2025'




SELECT TOP (100) PERCENT
    RTRIM(A.emps)                                                                 AS EMP,
    A.datars                                                                      AS [DATA-HORA],
    RTRIM(A.dopes)                                                                AS OPERARAÇAO,
    A.mascnum + 0                                                                 AS NUM_OP,
    RTRIM(A.grupoos)                                                              AS GRUPO_ORG,
    RTRIM(A.contaos)                                                              AS CONTA_ORG,
    RTRIM(C.rclis)                                                                AS NOME_ORG,
    RTRIM(A.grupods)                                                              AS GRUPO_DEST,
    RTRIM(A.contads)                                                              AS CONTA_DEST,
    RTRIM(D.rclis)                                                                AS NOME_DEST,
    RTRIM(B.cpros)                                                                AS COD_INS,
    RTRIM(B.dpros)                                                                AS DESC_INS,
    B.codbarras                                                                   AS [CÓDIGO DE BARRAS],
    B.qtds                                                                        AS QTD,
    RTRIM(B.cunis)                                                                AS UNIT_QTD,
    B.pesos                                                                       AS QTD2,
    RTRIM(B.cunips)                                                               AS UNIT_QTD2,
    B.obs                                                                         AS OBS_ITEM,
    CASE
        WHEN PATINDEX('%TS[0-9]%', UPPER(CAST(B.obs AS varchar(500)))) > 0
            THEN 'TS' + LEFT(
                SUBSTRING(CAST(B.obs AS varchar(500)), PATINDEX('%TS[0-9]%', UPPER(CAST(B.obs AS varchar(500)))) + 2, 4),
                PATINDEX('%[^0-9]%', SUBSTRING(CAST(B.obs AS varchar(500)), PATINDEX('%TS[0-9]%', UPPER(CAST(B.obs AS varchar(500)))) + 2, 4) + 'X') - 1
            )
        WHEN PATINDEX('%TS[- ,./][0-9]%', UPPER(CAST(B.obs AS varchar(500)))) > 0
            THEN 'TS' + LEFT(
                SUBSTRING(CAST(B.obs AS varchar(500)), PATINDEX('%TS[- ,./][0-9]%', UPPER(CAST(B.obs AS varchar(500)))) + 3, 4),
                PATINDEX('%[^0-9]%', SUBSTRING(CAST(B.obs AS varchar(500)), PATINDEX('%TS[- ,./][0-9]%', UPPER(CAST(B.obs AS varchar(500)))) + 3, 4) + 'X') - 1
            )
        ELSE NULL
    END                                                                           AS COD_TS,
    RTRIM(A.usuars)                                                               AS RESPONSAVEL,
    E.dtincs                                                                      AS DATA_ENTRADA,
    RTRIM(E.grupos)                                                               AS GRP_ESTOQUE,
    RTRIM(E.contas)                                                               AS COD_CONTA,
    RTRIM(F.rclis)                                                                AS CONTA,
    RTRIM(CONVERT(varchar(MAX), A.obses))                                         AS OBSERVACAO,
    A.chkbxparcs                                                                  AS BAIXA,
    A.dtbaixas                                                                    AS [DATA BAIXA],
    REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''), ' ', '')                        AS [OPERACAO ACEITE]
FROM       dbo.SigMvCab  AS A WITH (NOLOCK)
INNER JOIN dbo.SigMvItn  AS B WITH (NOLOCK) ON B.empdopnums = A.empdopnums
INNER JOIN dbo.SIGCDCLI  AS C WITH (NOLOCK) ON A.contaos    = C.iclis
INNER JOIN dbo.SIGCDCLI  AS D WITH (NOLOCK) ON A.contads    = D.iclis
INNER JOIN dbo.SIGOPETQ  AS E WITH (NOLOCK) ON B.codbarras  = E.cbars
INNER JOIN dbo.SIGCDCLI  AS F WITH (NOLOCK) ON E.contas     = F.iclis
WHERE A.dopes = 'ENTRADA TRUNKSHOW'




SELECT 
	A.emps AS 'EMPRESA', A.EMPDOPNUMS AS 'CHAVE_MAE',C.dtalts AS 'ENTRADA',A.NOTAS AS 'NUM_NF',
	C.opers AS 'TIPO_MOV', A.DOPES AS 'OPERACAO',A.NUMES AS 'NUM_OPS',E.DGRUS AS 'GRP_PRODUTO',C.CPROS AS 'COD_PRODUTO',
	C.DPROS AS 'DESC_PRODUTO', C.codbarras AS 'COD_BARRAS', C.QTDS AS 'QTD', C.CUNIS AS 'UNIDADE', C.pesos AS 'QTD2', C.cunips, C.QTBAIXAS AS 'QTD BAIXADA',
	F.iclis AS 'CÓD. ORIGEM', F.RCLIS AS 'ORIGEM', J.iclis AS 'CÓD. DESTINO', J.rclis AS 'DESTINO', A.obses AS 'OBSERVAÇÃO'
FROM SIGMVCAB A (NOLOCK)
LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
LEFT JOIN SIGCDPRO D (NOLOCK) ON C.CPROS=D.CPROS
LEFT JOIN SIGCDGRP E (NOLOCK) ON D.CGRUS=E.cgrus
LEFT JOIN SIGCDCLI F (NOLOCK) ON A.CONTAOS=F.ICLIS
LEFT JOIN SIGCDCLI J (NOLOCK) ON A.contads=J.ICLIS
LEFT JOIN SIGPRNFE G (NOLOCK) ON A.EMPDOPNUMS=G.EMPDOPNUMS AND G.datas = (SELECT MAX(I.datas) FROM sigprnfe I WHERE A.EMPDOPNUMS=I.EMPDOPNUMS GROUP BY I.empdopnums)
--WHERE B.tipoops in ('1','9') 
WHERE A.DOPES IN ('NF PURIFICACAO', 'NF REFINO')
	AND C.citem2 = 0
	AND C.opers = 'S'
	AND C.dtalts >'2026-01-01'
	AND (G.stats NOT LIKE '' OR G.stats IS NULL)
ORDER BY C.dtalts DESC, A.DOPES ASC



select a.emps as 'EMP', a.dopes as 'OPERAÇÃO', a.numes as 'NUM_CONSERTO', a.datas as 'DATA_ENTRADA', 
			b.citens AS 'COD ITEM', b.cpros as 'COD PRODUTO', j.dpros as 'DESCRICAO PRODUTO', b.codbarras AS 'COD. BARRAS', b.qtds as QTD1, b.cunis AS 'UN1',  b.pesos as QTD2, b.cunips AS 'UN2', (B.obs) AS 'OBS ITEM', b.qtbaixas as 'QTD BAIXADA',
			a.dtbaixas as 'DATA BAIXA', left(a.ultgrvs,26) as BAIXA, a.chksubn AS 'BAIXA_PEDIDO', RTRIM(A.grupoos) AS 'GRP ORIGEM', RTRIM(K.iclis) AS 'COD. ORIGEM', RTRIM(K.rclis) AS 'CONTA ORIGEM',
			RTRIM(A.grupods) AS 'GRP DESTINO', RTRIM(K.iclis) AS 'COD. DESTINO', RTRIM(K.rclis) AS 'CONTA DESTINO',	A.obses AS 'OBS_PEDIDO', A.usuars as USUARIO
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.empsubns 
								and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) --and e.empdopnums like '%TRF PRE VENDA EMP%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigcdope g with(nolock) on f.dopes=g.dopes
left join sigmvpec h with(nolock) on f.emps=h.empsubns 
								and right(h.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),f.numes)))))+ltrim(rtrim(convert(varchar(6),f.numes)))
								and g.ndopes = iif(len(h.codigos)=9,left(h.codigos,3),left(h.codigos,2)) --and h.empdopnums like  '%ENVIO MALOTE LOG>LJ%'
left join sigmvcab i with(nolock) on i.empdopnums=h.empdopnums 
inner join sigcdpro j with(nolock) on j.cpros=b.cpros
LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
LEFT JOIN SigCDCLI (NOLOCK) L ON A.contads = L.iclis
where a.datas >= '01-01-2026' AND A.dopes = 'NF RET PURIFICAÇÃO C'
order by a.datas DESC, a.numes DESC, b.citens ASC