-- Saídas de Produção, são operações que enviam insumos do estoque de materia prima para os setores necessários na produção
SELECT MAX(A.datars) AS 'DATA-HORA', RTRIM(A.dopes) AS 'OPERARAÇAO', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG', E.mercs AS 'GRANDE_GRP',
	E.cgrus AS 'GRUPO'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
	WHERE (A.dopes = 'NF COMPRA MP') AND A.datas >= '2021-01-01' AND E.mercs = 'PED'
GROUP BY A.emps, A.dopes, A.grupoos, A.contaos, C.rclis, A.grupods, A.contads, E.cgrus, E.mercs









SELECT A.emps AS 'EMP', CONVERT(date, A.datas, 103) AS 'ENTRADA', B.rclis as 'CLIENTE', A.dopes as 'TIPO DE PEDIDO', D.NOPS AS 'OP_MAE', G.reffs AS 'REF_CLIENTE',
				C.CPROS AS 'PRODUTO', G.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', C.qtds AS 'QTD_INI', CONVERT(date, A.prazoents, 103) AS 'PRAZO',
				K.cgrus AS 'GRP_COMP', K.dgrus, J.codigos, J.descricaos, C.obs,
				I.cpros AS 'COD_COMP', I.dpros AS 'DESC_COMP', H.qtds*C.qtds AS 'PESOS_TOTAL', I.cunis AS 'UN1', H.pesos*C.qtds AS 'QTD_TOTAL', I.cunips AS 'UN2', I.fabrproprs 
	FROM  SigMvCab A (NOLOCK)
		INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
		INNER JOIN SigMvItn H (NOLOCK) ON H.empdopnums = C.empdopnums AND (C.citens = H.citem2 OR (H.cpros = C.cpros AND H.citem2 = 0 AND C.citens = H.citens))
		INNER JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0 AND D.nopmaes = 0
	    INNER JOIN (SELECT a.nops
							FROM (
							    SELECT *,
							           ROW_NUMBER() OVER (PARTITION BY nops ORDER BY cidchaves DESC) AS rn,
							           -- flag: 1 se essa nops tem alguma linha de finalização
							           MAX(CASE WHEN dopps IN ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ', 'FINALIZAÇÃO OS') 
							                    THEN 1 ELSE 0 END) OVER (PARTITION BY nops) AS tem_finalizacao
							    FROM SIGPDMVF (NOLOCK)
							) a
						WHERE a.rn = 1 AND a.tem_finalizacao = 0
				) e on d.nops = e.nops
		LEFT JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
		LEFT JOIN SigCdPro I (NOLOCK) ON I.cpros = H.cpros --AND (I.cgrus IN ('IMT', 'BRI', 'PED', 'INS') OR I.mercs = 'PED')
		LEFT JOIN SigCdGrp K (NOLOCK) ON I.cgrus = K.cgrus
		LEFT JOIN SigCdPsg J (NOLOCK) ON I.sgrus = J.codigos AND I.cgrus = J.cgrus
		INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	WHERE A.dopes IN ('PEDIDO FABRICA','PEDIDO ENCOMENDA','PED FABRICA POF','PED ENCOMENDA POF','PEDIDO PILOTO','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-03-2026'
	 			AND D.nopmaes = 0
	 			--AND D.nops = 108250003
ORDER BY  OP_MAE DESC





(SELECT a.nops
	FROM (
	    SELECT *,
	           ROW_NUMBER() OVER (PARTITION BY nops ORDER BY cidchaves DESC) AS rn,
	           -- flag: 1 se essa nops tem alguma linha de finalização
	           MAX(CASE WHEN dopps IN ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ', 'FINALIZAÇÃO OS') 
	                    THEN 1 ELSE 0 END) OVER (PARTITION BY nops) AS tem_finalizacao
	    FROM SIGPDMVF (NOLOCK)
	) a
WHERE a.rn = 1 AND a.tem_finalizacao = 0)




SELECT        A.datas AS DATA, D.nops AS OP_ITEM, C.cpros AS COD_COMPOSICAO, C.dpros AS DESC_COMPOSICAO, (C.qtds) AS QTD_ITEM, C.cunis AS UNIDADE, (C.pesos) AS PESO, 
                         RTRIM(H.mercs) AS GRANDE_GRP, RTRIM(H.cgrus) AS GRP, I.dgrus AS GRP_INSUMO, 
                         CASE WHEN C.cpros = 'RODIO 2,00    ' THEN 'AU750' WHEN H.cgrus = 'IAU' THEN 'AU750' WHEN H.cgrus = 'BRI' THEN 'BRILHANTES' WHEN H.cgrus = 'PED' THEN 'PEDRAS' WHEN H.cgrus = 'IMT' THEN 'INSUMOS METALICOS'
                          ELSE I.dgrus END AS GRUPO_INS, RTRIM(H.sgrus) AS COD_SUBGRUPO, RTRIM(G.descricaos) AS SUBGRUPO, RTRIM(G.descricaos) AS [Insumo Tratado], C.*
FROM SigMvCab AS A WITH (NOLOCK)
				INNER JOIN SigMvItn AS C WITH (NOLOCK) ON A.empdopnums = C.empdopnums
				INNER JOIN SigMvItn AS B WITH (NOLOCK) ON B.empdopnums = C.empdopnums AND (B.citens = C.citem2 OR B.cpros = C.cpros AND B.citem2 = 0 AND C.citens = B.citens)
				LEFT JOIN SigOpPic AS D WITH (NOLOCK) ON C.empdopnums = D.empdopnums AND B.cpros = D.cpros AND B.citens = D.citens AND D.nopmaes = 0
				LEFT JOIN SigCdPro AS H WITH (NOLOCK) ON C.cpros = H.cpros
				LEFT JOIN SigCdGrp AS I WITH (NOLOCK) ON I.cgrus = H.cgrus
				LEFT JOIN SigCdPsg AS G WITH (NOLOCK) ON H.sgrus = G.codigos AND H.cgrus = G.cgrus
WHERE        A.datas > '2026-03-01' 
					AND (A.dopes LIKE 'PED %' OR A.dopes LIKE 'PEDIDO %') AND (A.dopes NOT LIKE '%ACRE%') AND (A.dopes NOT LIKE '%PEDRA%')
					AND D.nopmaes = 0
ORDER BY D.nops DESC
--GROUP BY A.datas, D.nops, C.cpros, C.dpros, C.cunis, I.dgrus, H.cgrus, I.dgrus, H.sgrus, G.descricaos, H.mercs, H.cgrus











--Composição do Produto
SELECT RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(D.mercs) AS 'GRANDE_GRP', RTRIM(D.cgrus) 'GRP_INSUMO', RTRIM(D.cpros) AS 'COD_INSUMOS', RTRIM(D.dpros) AS 'DESC_INSUMO',
			D.pesoms AS 'PESO_MEDIO', C.pesos AS 'PESOS', RTRIM(C.cunips) AS 'UN_PESOS', C.qtds AS 'QTD', C.qtdcvs AS 'QTD_2', RTRIM(C.unicompos) AS 'UN_QTD', D.custofs AS 'VALOR_INSUMO',
			D.margems AS 'MARGEM_INSUMO', D.pvens AS 'VAL_INSUMO_C_MARGEM', RTRIM(D.moedas) AS 'MOEDA', RTRIM(D.obspes) AS 'OBS', ROUND(C.markcvs,3) AS 'MARKUP_INS', C.obsofs AS 'OBS_INSUMO',
			Convert(varchar(max), A.dsccompras) AS 'DESCRICAO_COMPRA',
			CASE
				WHEN A.mercs = 'INS' THEN (SELECT SUM(AA.qtds) FROM SIGPRCPO (NOLOCK) AA WHERE AA.cpros = A.cpros AND AA.cgrus = 'IAU' GROUP BY AA.cpros) ELSE 0
			END AS 'PESO_IMT',
			RTRIM(H.codigos) AS 'COD_SUBGRUPO', RTRIM(H.descricaos) AS 'SUBGRUPO', RTRIM(H.descricaos) AS 'Insumo Tratado', RTRIM(E.dgrus) AS 'GRUPO_INS',
			CASE WHEN D.cgrus = 'IAU' THEN RTRIM(B.descs) ELSE RTRIM(F.descs) END AS 'COR_INS',
			CASE 
				WHEN D.cgrus IN ('IAU', 'INS', 'IMT') THEN ' '+RTRIM(B.descs)
				WHEN D.mercs = 'PED' THEN RTRIM(E.dgrus) + ' ' + ISNULL(RTRIM(F.descs), '')
			END AS 'DESC_BOOK_INS'
	FROM SigCdPro A (NOLOCK)
			LEFT JOIN SigCdCor B (NOLOCK) ON B.cods = A.codcors
			LEFT JOIN SIGPRCPO C (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
			INNER JOIN SigCdPro D (NOLOCK) ON C.mats = D.cpros
			LEFT JOIN SigCdGrp E (NOLOCK) ON D.cgrus = E.cgrus
			LEFT JOIN SigCdCor F (NOLOCK) ON F.cods = D.codcors
			LEFT JOIN SIGCDCOL G (NOLOCK) ON A.colecoes =G.colecoes
			LEFT JOIN SigCdPsg H (NOLOCK) ON D.sgrus = H.codigos AND D.cgrus = H.cgrus
		WHERE ((A.mercs = 'PA' AND A.datas >= '2021-09-01') OR (A.mercs = 'INS' AND A.cgrus = 'IMT'))
	ORDER BY COD_PROD ASC