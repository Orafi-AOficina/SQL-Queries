SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.grupos AS 'GRP_ESTOQUE', a.contas AS 'COD_CONTA', c.rclis AS 'CONTA', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO',
					a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS', a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', d.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', d.dpros AS 'DESCRICAO',
					b.qtds AS 'QTD_OP', a.qtds AS 'QTD_ETQ', e.NUM_COD_BARRAS as 'NUM_BARRAS_OP', d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_METAL',
					a.peso2s as 'PESO_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO', b.obss as 'OBS_OP', g.descs AS 'FEITIO'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.cbars) as 'NUM_COD_BARRAS', ee.nops from sigopetq (nolock) ee where ee.cbars > 0 group by ee.nops) e on e.nops = a.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) f on f.nops = a.nops and (a.cbars <= f.codbarras and (a.cbars > f.PROX_CBARS or ISNULL(f.PROX_CBARS, -1) = -1 ))
	left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = f.codbarras
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigprfti (nolock) g on d.cftios = g.cods
where a.grupos IN ('ESTOQUE', 'PCP', 'GERENCIAL') and d.colecoes = 'CL'











SELECT RTRIM(A.emps) AS 'EMP', A.datars AS 'DATA-HORA', A.datas AS 'DATA', RTRIM(A.dopes) AS 'OPERACAO', A.mascnum+0 AS 'NUM_OP', RTRIM(A.emps) AS 'EMP_ORG', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG',
	RTRIM(C.rclis) AS 'NOME_ORG', A.numbals AS 'BALANÇO_ORIG',
	CASE WHEN A.empds = '' THEN RTRIM(A.emps) ELSE RTRIM(A.empds) END AS 'EMP_DEST', RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST', A.numbalds AS 'BALANÇO_DEST',
	RTRIM(F.cgrus) AS 'GRP_INS', RTRIM(F.cpros) AS 'COD_INS', RTRIM(F.dpros) AS 'DESC_INS', B.qtds AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2',
	RTRIM(B.opers) AS 'SENTIDO', RTRIM(A.usuars) AS 'RESPONSAVEL', Convert(varchar(max),A.obses) AS 'OBS SAIDA', 
	LEFT(REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE( 
								REPLACE(Convert(varchar(max),A.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP',
	B.citens AS 'ORDENADOR', A.empdopnums AS 'CHAVE_OPERACAO', CONCAT(B.citens, A.empdopnums) AS 'CHAVE_ITEM',
	A.chkbxparcs AS 'BAIXA', A.dtbaixas AS 'DATA BAIXA', REPLACE(REPLACE(A.ultgrvs, '-Car_EstPe', ''),' ', '') AS 'OPERACAO ACEITE'
FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		--LEFT JOIN SigCdPro (NOLOCK) E ON B.cpro2s = E.cpros
		LEFT JOIN SigCdPro (NOLOCK) F ON B.cpros = F.cpros
	WHERE A.datas >= '15-11-2024'
			AND A.dopes IN ('TRANSFORMA METAL', 'ORÇAMENTO')
			AND A.dopes NOT IN ('FINALIZA NACIONAL', 'PEDIDO DE ENCOMENDA', 'PED ENCOMENDA POF', 'PED FABRICA POF', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO ENCOMENDA', 'PEDIDO FABRICA', 'PEDIDO PILOTO', 'NF VENDA', '',
									'ENTRADA CONSERTO', 'PRE NF COMP MP FINAN', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'DV ASS.TEC.S. CUSTO', 'NF VENDA GAL', 'PED ACRESC PRODUCAO', 'PEDIDO DE ACRESC',
									'DEVOLUÇÃO DE VENDAS', 'CANCELA NF COMP PEDR', 'CANCELA NF OUT SAIDA', 'CANCELAMENTO NF', 'EMPENHO MT PRIMA', 'REQUISICAO COMPRA', 'NF COMPRA MP', 'PRE NF MP TOTAL FINA', 'NF PURIFICACAO')
			-- 'PRE NF COMP MP FINAN', 
			--AND B.cpros IN ('AU750', 'AG925', 'OFI', 'AG FINO')
			--AND ((A.contads= '0000000229' OR A.contaos = '0000000229') OR (A.contads= '0000000229' AND A.contaos = '0000000229'))
	ORDER BY A.datars DESC, A.mascnum ASC, B.citens ASC