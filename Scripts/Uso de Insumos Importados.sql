SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO', a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS',
					j.NUM_INS_IMPORTADO,
					a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', b.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', b.dpros AS 'DESCRICAO',
					d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_TOTAL_METAL', a.peso2s as 'PESO_TOTAL_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO',
					b.obss as 'OBS_OP',  g.mercs AS 'GRANDE_GRP', g.cgrus AS 'GRP_INSUMO', f.mats AS 'COD_INSUMO', f.dpros AS 'INSUMO', h.descs as 'CLASSIFICAÇÃO_INSUMO', f.qtds AS 'PESO', f.cunis AS 'UN', f.pesos AS 'QTD', f.cunips AS 'UN2', g.obspes AS 'OBS INS', g.cclass
FROM SIGOPETQ (nolock) a
	left join (select count(ee.codbarras) as 'NUM_COD_BARRAS', ee.nops from sigoppic (nolock) ee where ee.codbarras > 0 group by ee.nops) e on e.nops = a.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) k on k.nops = a.nops and (a.cbars <= k.codbarras and (a.cbars > k.PROX_CBARS or ISNULL(k.PROX_CBARS, -1) = -1 ))
	left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = k.codbarras
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigsubmv (nolock) f on a.cbars = f.codbarras
	left join sigcdpro (nolock) g on f.mats = g.cpros
	left join sigcdcls (nolock) h on g.cclass = h.cods
	left join (SELECT aa.codbarras, COUNT(bb.cpros) AS 'NUM_INS_IMPORTADO' from sigsubmv (nolock) aa
											left join sigcdpro (nolock) bb on aa.mats = bb.cpros
											where bb.cclass = 'IMP'
											group by aa.codbarras) j ON  j.codbarras = a.cbars
where a.dtincs >= '01-01-2025' AND a.empos = 'RNG' AND j.NUM_INS_IMPORTADO > 0
order by a.dtincs DESC





SELECT G.descs AS 'CLIENTE', A.cgrus AS 'GRP_PROD', A.cpros AS 'COD_PROD', A.cproeqs 'PROD_EQUIVALENTE', CASE WHEN A.cproeqs <> '' THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'VARIANTE_IMP',
			A.reffs AS 'REF_CLIENTE', A.dpros AS 'DESC_PROD', A.codcors AS 'COR', A.dtincs AS 'DTE_INCLUSAO', A.datas AS 'ULT_ALTERACAO', A.pesometal AS 'PESO_METAL',
			A.pesoms AS 'PESO_LIQ', D.mercs AS 'GRANDE_GRP', D.cgrus 'GRP_INSUMO', D.cpros AS 'COD_INSUMOS', D.dpros AS 'DESC_INSUMO',
			C.qtds AS 'QTD', C.unicompos AS 'UN', C.pesos AS 'QTD2', C.cunips AS 'UN2', D.obspes AS 'OBS_INSUMO', Convert(varchar(max), A.dsccompras) AS 'DESCRICAO_COMPRA',
			H.nops AS 'ULT_OP_PRODUZIDA', H.empdnps AS 'ULT_FINALIZACAO', H.datas AS 'DATA_FINALIZACAO', D.cclass AS 'CLASS. INSUMO', A.obspes AS 'CÓD. REGISTRO', J.codigos AS 'CARACTERISTICA_IMPORT'
	FROM SigCdPro A (NOLOCK)
		LEFT JOIN SIGPRCPO C (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
		LEFT JOIN SigCdPro D ON C.mats = D.cpros
		LEFT JOIN SIGCDFIP E (NOLOCK) ON E.cods = A.codfinp 
		LEFT JOIN SigCdGpr F (NOLOCK) ON A.mercs = F.codigos
		LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes 
		LEFT JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps, a.cidchaves, a.codpds
					from sigpdmvf a (NOLOCK)
						join (select k.cpros , MAX(j.cidchaves) as cidchaves
									from SigPdMvf (NOLOCK) j
										left join SigOpPic k on j.nops = k.nops
										--WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
											--	('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
									group by k.cpros
								) B ON A.cidchaves = B.cidchaves
	 						where dopps <> SPACE(20)
						) H on H.codpds = A.cpros
		LEFT JOIN SIGPRCAR (NOLOCK) J on J.cpros = A.cpros AND J.codigos = 'INS IMPORTADO'
		WHERE F.descs = 'PRODUTOS'
					AND A.datas >= '2025-01-01'
	ORDER BY DTE_INCLUSAO DESC, COD_PROD ASC





--Cadastro Produto
SELECT RTRIM(C.descs)  AS 'TIPO_CADASTRO', RTRIM(D.colecoes) AS 'COD_GRP_VENDA', RTRIM(D.descs) AS 'GRUPO_VENDA', RTRIM(H.cgrus) AS 'GRP_PROD',
			RTRIM(H.dgrus) AS 'DESC_GRUPO', RTRIM(A.sgrus) AS 'COD_SUBGRUPO', RTRIM(G.descricaos) AS 'SUBGRUPO', RTRIM(A.cpros) AS 'COD_PROD',
			RTRIM(A.reffs) AS 'REF_CLIENTE', RTRIM(REPLACE(A.reffs,'.','')) AS 'REF_CLIENTE_TRATADA', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(J.cods) AS 'COR',
			RTRIM(J.descs) AS 'DESC_COR', RTRIM(A.cproeqs) 'COD_EQUIVALENTE', CASE WHEN A.cproeqs <> '' THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'VARIANTE_IMP', A.matprincs AS 'METAL_PRINCIPAL',
			RTRIM(A.codtams) AS 'COD_TAMANHO', RTRIM(F.descs) AS 'TAMANHO', A.dtincs AS 'DTE_INCLUSAO', A.datas AS 'ULT_ALTERACAO', RTRIM(E.linhas) AS 'COD_LINHA', RTRIM(E.descs) AS 'LINHA',
			RTRIM(A.codfinp) AS 'COD_MODELO', RTRIM(B.descs) AS 'MODELO',
			CASE WHEN A.pesometal < A.pesoms THEN A.pesometal ELSE A.pesoms END AS 'PESO_METAL_CADASTRO', A.pesoms AS 'PESO_LIQ_CADASTRO',
			CASE
				WHEN A.situas = 1 THEN 'ATIVO'
				WHEN A.situas = 2 THEN 'INATIVO'
				ELSE 'ERRO' 
			END AS 'STATUS_PROD', A.obscompras AS 'COR_ANL', RTRIM(A.dpro2s) AS 'DESC_ANIMALE', RTRIM(A.idecpros) AS 'IDENTIFICADOR', RTRIM(A.codident) AS 'REF_DESENVOLVIMENTO',
			A.descfis AS 'DESC_FISCAL', RTRIM(I.codigos) AS 'COD_CLASS_FISCAL', RTRIM(I.descricaos) AS 'CLASS_FISCAL',
			CASE
				WHEN A.figjpgs IS NULL THEN 'VERDADEIRO'
				ELSE 'FALSO'
			END AS 'FOTO CADASTRADA', A.cbars AS 'CODBARRA_PROD', A.dpro3s AS 'DESC_SITE_OFICIAL', E.descs, C.descs,
			RTRIM(A.obspes) AS 'CÓD. REGISTRO', RTRIM(A.codident) AS 'COD. IDENTIFICACAO', RTRIM(A.cclass) AS 'CLASS. INSUMO', RTRIM(K.dpros) AS 'PRODUTO EQUIVALENTE',
			CASE
				WHEN L.codigos = 'INS IMPORTADO' THEN 'VERDADEIRO'
				ELSE 'FALSO'
			END AS 'INSUMO IMPORTADO'
	FROM SigCdPro A (NOLOCK)
		LEFT JOIN SIGCDFIP B (NOLOCK) ON B.cods = A.codfinp
		LEFT JOIN SigCdGpr C (NOLOCK) ON A.mercs = C.codigos
		LEFT JOIN SIGCDCOL D (NOLOCK) ON A.colecoes =D.colecoes
		LEFT JOIN SigCdLin E (NOLOCK) ON A.linhas = E.linhas
		LEFT JOIN SigCdTam F (NOLOCK) ON A.codtams = F.cods
		LEFT JOIN SigCdPsg G (NOLOCK) ON A.sgrus = G.codigos AND A.cgrus = G.cgrus
		LEFT JOIN SigCdGrp H (NOLOCK) ON A.cgrus = H.cgrus
		LEFT JOIN SIGCDCLF I (NOLOCK) ON A.clfiscals = I.codigos
		LEFT JOIN SigCdCor J (NOLOCK) ON A.codcors = J.cods
		LEFT JOIN SIGCDPRO K (NOLOCK) ON A.cproeqs = K.cpros
		LEFT JOIN SIGPRCAR L (NOLOCK) ON L.cpros  = A.cpros AND L.codigos = 'INS IMPORTADO'
	WHERE ((C.descs = 'PRODUTOS'  AND A.datas >= '2021-09-01') OR (C.descs = 'INSUMOS' AND A.cgrus = 'IMT'))
	ORDER BY A.datas DESC
	
	
	
	
	
	
	
	
SELECT A.emps AS 'EMP', D.cbars AS 'COD_BARRAS', A.nops AS 'OP', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESC_PRODUTO', A.qtds AS 'QTD', B.codcors AS 'COR', dd.QTD_ETQ,
		REPLACE(COALESCE(STRING_AGG(RTRIM(cc.SUBGRUPO) + ' ' + CAST(LEFT(cc.QTD_UNIT_INS, LEN(cc.QTD_UNIT_INS) - 3) as varchar) + RTRIM(cc.UN), ', ')  + ' / ', ''), 'ROSÊ DE FRA', 'ROSÊ DE FRANCE') + CAST(LEFT(dd.QTD_UNIT_IAU, LEN(dd.QTD_UNIT_IAU) - 3) as varchar) + ' GR' AS 'DESCRICAO_NF',
		CAST(LEFT(dd.QTD_UNIT_IAU, LEN(dd.QTD_UNIT_IAU) - 3) as varchar) + ' GR' AS 'DESCRICAO_NF_SO_IAU'
FROM SIGOPETQ (NOLOCK) D
	left join (select count(ee.codbarras) as 'NUM_COD_BARRAS', ee.nops from sigoppic (nolock) ee where ee.codbarras > 0 group by ee.nops) e on e.nops = D.nops
	left join (select aa.nops, aa.codbarras, max(bb.codbarras) as 'PROX_CBARS' from sigoppic (nolock) aa left join sigoppic (nolock) bb on aa.nops = bb.nops and aa.codbarras > bb.codbarras group by aa.nops, aa.codbarras) k on k.nops = D.nops and (D.cbars <= k.codbarras and (D.cbars > k.PROX_CBARS or ISNULL(k.PROX_CBARS, -1) = -1 ))
	--left join sigoppic (nolock) b on a.nops = b.nops and b.codbarras = k.codbarras
	LEFT JOIN SigOpPic (NOLOCK) A ON D.nops = A.nops and A.codbarras = k.codbarras
	LEFT JOIN SIGCDPRO (NOLOCK) B ON A.cpros = B.cpros
	LEFT JOIN (SELECT O.codbarras AS 'codbarras',
						CASE WHEN R.cgrus IN ('BR1', 'BR2') THEN 'DIAMANTE' ELSE R.descricaos END +
						CASE WHEN P.cclass = 'IMP' THEN ' IMPORTADO' ELSE '' END AS 'SUBGRUPO',
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
					GROUP BY O.codbarras, R.descricaos, O.cunis, X.qtds, P.cclass, Q.descs, R.cgrus) cc ON A.codbarras = cc.codbarras
	LEFT JOIN (SELECT O.codbarras AS 'codbarras', R.descricaos AS 'SUBGRUPO', SUM(O.qtds) AS 'QTD_TOT',  X.qtds AS 'QTD_ETQ',
									CASE WHEN R.descricaos = 'METAL' THEN ROUND(SUM(O.qtds)/X.qtds, 3) ELSE 0 END AS 'QTD_UNIT_IAU'
					FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
						LEFT JOIN SIGOPETQ (NOLOCK) X ON O.codbarras = X.cbars
						LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
						LEFT JOIN (SELECT DISTINCT CASE WHEN mercs = 'PED' THEN cgrus WHEN cgrus = 'IMT' THEN 'IMT' ELSE 'IAU' END AS cgrus,
												CASE WHEN mercs = 'PED' THEN  cgrus  WHEN cgrus = 'IMT' THEN 'METAL' ELSE 'METAL' END AS codigos,
												CASE WHEN mercs = 'PED' THEN RTRIM(dgrus)  WHEN cgrus = 'IMT' THEN 'METAL' ELSE 'METAL' END AS descricaos
										FROM SigCdGrp (NOLOCK)) R ON P.cgrus = R.cgrus
					WHERE R.descricaos = 'METAL' AND X.qtds > 0 AND O.qtds > 0
					GROUP BY O.codbarras, R.descricaos, O.cunis, X.qtds) dd ON A.codbarras = dd.codbarras
	WHERE A.codbarras > 0 AND A.dataes > '01-01-2026'
GROUP BY A.emps, D.cbars, A.nops, B.cpros, B.dpros, A.qtds, B.codcors, dd.QTD_UNIT_IAU, dd.QTD_ETQ