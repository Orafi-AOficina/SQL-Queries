SELECT DISTINCT
	A.cpros AS 'COD_INSUMO', A.dpros AS 'DESC_INSUMO', A.cgrus AS 'GRUPO_INSUMO', A.cunis AS 'UN',
	B.dopes, B.dtalts, B.empdopnums, B.pesos, B.qtds, B.totas, B.units, B.moedas
FROM SigCdPro A (NOLOCK)
	INNER JOIN (select a.cpros, a.dpros, a.dopes, a.dtalts, a.empdopnums, a.pesos, a.qtds, a.totas, a.units, a.moedas, a.obs
					from SigMvItn a (NOLOCK)  
						join (select cpros, MAX(dtalts) as dtalts 
									from SigMvItn (NOLOCK)
										WHERE dopes in ('NF COMPLEMENTAR', 'NF ENT INSUT ANL', 'NF RET INDUTRIALIZA','NF RET MERC IND', 'NF RET MERC IND', 'NF SAIDA DIVERSAS',
													'NF ENT INDUSTRIA','NF PURIFICACAO','PRE NF COMP MP TOTAL','PRE NF COMPRA MP','PRE NF COMPRA PEDRA', 'NF COMPRA MP', 'NF COMPRA MP.',
													'NF COMPRA PEDRA', 'NF RET PURIFICAÇÃO','NF RET REM INS N IND','NF RET REMESSA IND.', 'RESUMO ENT MP', 'RESUMO ENT MP.',
													'RET INSUMOS NÃO IND,','RET_INSUMOS_IND')
													and opers = 'E'
										group by cpros
								) b ON a.cpros = b.cpros AND a.dtalts = B.dtalts
						WHERE a.dopes in ('NF COMPLEMENTAR', 'NF ENT INSUT ANL', 'NF RET INDUTRIALIZA','NF RET MERC IND', 'NF RET MERC IND', 'NF SAIDA DIVERSAS',
													'NF ENT INDUSTRIA','NF PURIFICACAO','PRE NF COMP MP TOTAL','PRE NF COMPRA MP','PRE NF COMPRA PEDRA', 'NF COMPRA MP', 'NF COMPRA MP.',
													'NF COMPRA PEDRA', 'NF RET PURIFICAÇÃO','NF RET REM INS N IND','NF RET REMESSA IND.', 'RESUMO ENT MP', 'RESUMO ENT MP.',
													'RET INSUMOS NÃO IND,','RET_INSUMOS_IND')
													and a.opers = 'E'
				) B on A.cpros = B.cpros
WHERE A.mercs = 'INS' AND B.dtalts > '01-01-2018'
ORDER BY A.cpros