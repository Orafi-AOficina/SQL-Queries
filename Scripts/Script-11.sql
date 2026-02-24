SELECT A.emps AS 'EMP', A.codbarras AS 'COD_BARRAS', A.nops AS 'OP', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESC_PRODUTO', A.qtds AS 'QTD', B.codcors AS 'COR', dd.QTD_ETQ,
		REPLACE(COALESCE(STRING_AGG(RTRIM(cc.SUBGRUPO) + ' ' + CAST(LEFT(cc.QTD_UNIT_INS, LEN(cc.QTD_UNIT_INS) - 3) as varchar) + RTRIM(cc.UN), ', ')  + ' / ', ''), 'ROSÊ DE FRA', 'ROSÊ DE FRANCE') + CAST(LEFT(dd.QTD_UNIT_IAU, LEN(dd.QTD_UNIT_IAU) - 3) as varchar) + ' GR' AS 'DESCRICAO_NF',
		CAST(LEFT(dd.QTD_UNIT_IAU, LEN(dd.QTD_UNIT_IAU) - 3) as varchar) + ' GR' AS 'DESCRICAO_NF_SO_IAU'
FROM SigOpPic (NOLOCK) A
	LEFT JOIN SIGCDPRO (NOLOCK) B ON A.cpros = B.cpros
	LEFT JOIN (SELECT O.codbarras AS 'codbarras',
						CASE WHEN P.cclass = 'IMP' THEN R.descricaos + ' ' + Q.descs ELSE R.descricaos END AS 'SUBGRUPO',
						SUM(O.qtds) AS 'QTD_TOT', X.qtds AS 'QTD_ETQ',
						CASE WHEN R.descricaos = 'METAL' THEN 0 ELSE ROUND(SUM(O.qtds)/X.qtds, 3) END AS 'QTD_UNIT_INS', O.cunis AS 'UN'
					FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
						LEFT JOIN SIGOPETQ (NOLOCK) X ON O.codbarras = X.cbars
						LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
						LEFT JOIN (SELECT DISTINCT CASE WHEN mercs = 'PED' THEN cgrus ELSE 'IAU' END AS cgrus,
															CASE WHEN mercs = 'PED' THEN  cgrus ELSE 'METAL' END AS codigos,
															CASE WHEN mercs = 'PED' THEN RTRIM(dgrus) ELSE 'METAL' END AS descricaos
										FROM SigCdGrp (NOLOCK)) R ON P.cgrus = R.cgrus
						LEFT JOIN SIGCDCLS Q (NOLOCK) ON P.cclass = Q.cods
					WHERE R.descricaos <> 'METAL' AND X.qtds > 0
					GROUP BY O.codbarras, R.descricaos, O.cunis, X.qtds, P.cclass, Q.descs) cc ON A.codbarras = cc.codbarras
	LEFT JOIN (SELECT O.codbarras AS 'codbarras', R.descricaos AS 'SUBGRUPO', SUM(O.qtds) AS 'QTD_TOT',  X.qtds AS 'QTD_ETQ',
									CASE WHEN R.descricaos = 'METAL' THEN ROUND(SUM(O.qtds)/X.qtds, 3) ELSE 0 END AS 'QTD_UNIT_IAU'
					FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
						LEFT JOIN SIGOPETQ (NOLOCK) X ON O.codbarras = X.cbars
						LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
						LEFT JOIN (SELECT DISTINCT CASE WHEN mercs = 'PED' THEN cgrus WHEN cgrus = 'IMT' THEN 'IMT' ELSE 'IAU' END AS cgrus,
												CASE WHEN mercs = 'PED' THEN  cgrus  WHEN cgrus = 'IMT' THEN 'METAL' ELSE 'METAL' END AS codigos,
												CASE WHEN mercs = 'PED' THEN RTRIM(dgrus)  WHEN cgrus = 'IMT' THEN 'METAL' ELSE 'METAL' END AS descricaos
										FROM SigCdGrp (NOLOCK)) R ON P.cgrus = R.cgrus
					WHERE R.descricaos = 'METAL' AND X.qtds > 0
					GROUP BY O.codbarras, R.descricaos, O.cunis, X.qtds) dd ON A.codbarras = dd.codbarras
	WHERE A.codbarras > 0 AND A.dataes > '01-06-2024'
GROUP BY A.emps, A.codbarras, A.nops, B.cpros, B.dpros, A.qtds, B.codcors, dd.QTD_UNIT_IAU, dd.QTD_ETQ





SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO', a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS',
					a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', d.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', d.dpros AS 'DESCRICAO',
					d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_TOTAL_METAL', a.peso2s as 'PESO_TOTAL_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO',
					b.obss as 'OBS_OP',  g.cgrus AS 'GRP_INSUMO', f.mats AS 'COD_INSUMO', f.dpros AS 'INSUMO', h.descs as 'CLASSIFICAÇÃO_INSUMO', f.qtds AS 'PESO', f.cunis AS 'UN', f.pesos AS 'QTD', f.cunips AS 'UN2'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.codbarras) as 'NUM_COD_BARRAS', ee.nops from sigoppic (nolock) ee where ee.codbarras > 0 group by ee.nops) e on e.nops = a.nops
	left join sigoppic (nolock) b on a.nops = b.nops and (a.cbars = b.codbarras or e.NUM_COD_BARRAS = 1)
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigsubmv (nolock) f on a.cbars = f.codbarras
	left join sigcdpro (nolock) g on f.mats = g.cpros
	left join sigcdcls (nolock) h on g.cclass = h.cods
where a.dtincs >= '01-01-2021'





SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.grupos AS 'GRP_ESTOQUE', a.contas AS 'COD_CONTA', c.rclis AS 'CONTA', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO',
					a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS', a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', d.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', d.dpros AS 'DESCRICAO',
					b.qtds AS 'QTD_OP', a.qtds AS 'QTD_ETQ', e.NUM_COD_BARRAS as 'NUM_BARRAS_OP', d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_METAL',
					a.peso2s as 'PESO_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO', b.obss as 'OBS_OP'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.cbars) as 'NUM_COD_BARRAS', ee.nops from sigopetq (nolock) ee where ee.cbars > 0 group by ee.nops) e on e.nops = a.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) f on f.nops = a.nops and (a.cbars <= f.codbarras and (a.cbars > f.PROX_CBARS or ISNULL(f.PROX_CBARS, -1) = -1 ))
	left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = f.codbarras
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
where a.grupos = 'ESTOQUE'


select aa.nops, aa.codbarras, max(bb.codbarras) from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras where aa.nops = 100440005 group by aa.nops, aa.codbarras