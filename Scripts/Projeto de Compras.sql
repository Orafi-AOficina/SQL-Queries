-- Saídas de Produção, são operações que enviam insumos do estoque de materia prima para os setores necessários na produção
SELECT MAX(A.datars) AS 'DATA-HORA', RTRIM(A.dopes) AS 'OPERARAÇAO', RTRIM(A.grupoos) AS 'GRUPO_ORG', RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG', E.mercs AS 'GRANDE_GRP',
	E.cgrus AS 'GRUPO'
FROM SigMvCab (NOLOCK) A
		INNER JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		INNER JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		INNER JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
	WHERE (A.dopes = 'NF COMPRA MP') AND A.datas >= '2021-01-01' AND E.mercs = 'PED'
GROUP BY A.emps, A.dopes, A.grupoos, A.contaos, C.rclis, A.grupods, A.contads, E.cgrus, E.mercs







SELECT dataincs AS 'DATA_CADASTRO', iclis AS 'COD_CONTA', rclis AS 'CONTA', razaos AS 'RAZAO_SOCIAL', cpfs AS 'CNPJ', rgs AS 'INSC_ESTADUAL', inscmuns AS 'INSC_MUNNICIPAL',
			paises AS 'PAIS', estas AS 'ESTADO', cidas AS 'CIDADE', bairs AS 'BAIRRO', endes AS 'ENDERECO', nums AS 'NUMERO', compls AS 'COMPLEMENTO', ceps AS 'CEP',
			contato AS 'CONTATO', ddds AS 'DDD', tel1s AS 'TEL1', tel2s AS 'TEL2', faxs AS 'TEL3', emails AS 'EMAIL',
			CASE
				WHEN optsimples = 'R' THEN 'LUCRO REAL'
				WHEN optsimples = 'S' THEN 'SIMPLES NACIONAL'
				WHEN optsimples = 'P' THEN 'LUCRO PRESUMIDO'
				WHEN optsimples = 'A' THEN 'LUCRO ARBITRADO'
				WHEN optsimples = 'M' THEN 'MEI'
				WHEN optsimples = 'N' THEN 'N/D'
			END AS 'REG_TRIBUTARIO',
			microemps AS 'MICRO_EMREPSA',
			estcobs AS 'ESTADO_COB', cidcobs AS 'CIDADE_COB', baicobs AS 'BAIRRO_COB', endcobs AS 'ENDERECO_COB', cepcobs AS 'CEP_COB', suframas AS 'INSC_SUFRAMA', obs AS 'OBSERVACAO', situas AS 'SITUACAO', *
	FROM SIGCDCLI (NOLOCK)
	WHERE grupos = 'FORNECEDOR' AND REPLACE(REPLACE(REPLACE(REPLACE(cpfs, ' ', ''), '-', ''),'.', ''),'/','') <> ''
	ORDER BY rclis ASC













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
	
	
	
	
	
	
SELECT A.emps AS 'EMPRESA', A.grupos AS 'GRUPO_CONTA', A.contas AS 'COD_CONTA', C.rclis AS 'CONTA', A.cpros AS 'COD_PRODUTO', B.dpros AS 'PRODUTO', A.qmins AS 'QTD_MIN', A.qideal AS 'QTD_IDEAL'
FROM SigCdMin (NOLOCK) A
		LEFT JOIN SigCdPro (NOLOCK) B ON A.cpros = B.cpros
		LEFT JOIN SigCdCLI (NOLOCK) C ON A.contas = C.iclis
		
		
		
		
		
		
		
		
		
		
		
SELECT a.emps AS 'EMPRESA', a.grupos AS 'GRP_ESTOQUE', D.grupos AS 'GRP_CONTA', D.iclis AS 'COD_CONTA', D.RCLIS AS 'NOME_CONTA',
		b.cgrus AS 'GRUPO_INS', b.cpros AS 'COD_INSUMO',B.DPROS AS 'DESC_INSUMO', B.cproeqs AS 'COD_EQUIV', A.SQTDS AS 'SALDO', B.CUNIS AS 'UN', A.spesos AS 'QTD', B.cunips AS 'UN_QTD', B.ltminsv AS LOTE_MIN,
		E.qmins AS 'ESTOQUE_MIN', E.qideal AS 'REPOSICAO',
		CASE
			WHEN B.mercs = 'PED' THEN B.cunips
			ELSE B.cunis
		END AS 'UN_REF',
		CASE
			WHEN D.inativas = 1 THEN 'INATIVA'
			WHEN D.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS', B.obspes
	FROM sigmvest A (NOLOCK)
		LEFT join sigcdpro B (NOLOCK) ON a.cpros = B.cpros
		LEFT JOIN SIGCDPSG C (NOLOCK) ON B.CGRUS = C.CGRUS and B.sgrus = C.codigos
		LEFT JOIN SIGCDCLI D (NOLOCK) ON A.ESTOS = D.ICLIS
		LEFT JOIN SigCdGpr F (NOLOCK) ON B.mercs = F.codigos
		LEFT JOIN SigCdMin E (NOLOCK) ON A.cpros = E.cpros AND A.emps = E.emps AND A.estos = E.contas AND A.grupos = E.grupos
	WHERE (A.SQTDS <> 0 OR A.spesos <> 0)
                                   AND (A.emps = 'RNG' OR A.emps = 'ORA') AND A.estos = 'MATPRIMA'
	ORDER BY A.grupos, D.iclis, B.dpros, A.emps
	
	
	
	
	
SELECT E.emps AS 'EMPRESA', E.grupos AS 'GRP_ESTOQUE', E.contas AS 'COD_CONTA', b.cgrus AS 'GRUPO_INS', b.cpros AS 'COD_INSUMO', B.DPROS AS 'DESC_INSUMO', B.cproeqs AS 'COD_EQUIV',
		B.ltminsv AS LOTE_MIN, E.qmins AS 'ESTOQUE_MIN', E.qideal AS 'REPOSICAO',
		CASE
			WHEN B.mercs = 'PED' THEN B.cunips
			ELSE B.cunis
		END AS 'UN_REF'
	FROM sigcdpro B (NOLOCK)
		LEFT JOIN SigCdMin E (NOLOCK) ON B.cpros = E.cpros
	ORDER BY B.dpros