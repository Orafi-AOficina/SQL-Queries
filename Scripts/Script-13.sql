SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.grupos AS 'GRP_ESTOQUE', a.contas AS 'COD_CONTA', c.rclis AS 'CONTA', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO', a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS',
					a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', b.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', b.dpros AS 'DESCRICAO',
					d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_TOTAL_METAL', a.peso2s as 'PESO_TOTAL_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO',
					b.obss as 'OBS_OP',  g.mercs AS 'GRANDE_GRP', g.cgrus AS 'GRP_INSUMO', f.mats AS 'COD_INSUMO', f.dpros AS 'INSUMO', h.descs as 'CLASSIFICAÇÃO_INSUMO', f.qtds AS 'PESO', f.cunis AS 'UN', f.pesos AS 'QTD', f.cunips AS 'UN2'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.codbarras) as 'NUM_COD_BARRAS', ee.nops from sigoppic (nolock) ee where ee.codbarras > 0 group by ee.nops) e on e.nops = a.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) k on k.nops = a.nops and (a.cbars <= k.codbarras and (a.cbars > k.PROX_CBARS or ISNULL(k.PROX_CBARS, -1) = -1 ))
	left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = k.codbarras
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigsubmv (nolock) f on a.cbars = f.codbarras
	left join sigcdpro (nolock) g on f.mats = g.cpros
	left join sigcdcls (nolock) h on g.cclass = h.cods
where a.grupos IN ('ESTOQUE', 'PCP', 'GERENCIAL') AND a.dtincs > '01-01-2025' AND d.matprincs = 'AU750'







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
where a.grupos IN ('ESTOQUE', 'PCP', 'GERENCIAL') AND a.dtincs > '01-01-2025'