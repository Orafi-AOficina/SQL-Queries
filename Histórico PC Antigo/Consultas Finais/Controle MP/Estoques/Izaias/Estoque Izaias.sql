SELECT DISTINCT a.emps AS 'EMPRESA', a.grupos AS 'GRP_CONTA', D.iclis AS 'COD_CONTA', D.RCLIS AS 'NOME_CONTA', MAX(E.datas) AS 'DT_BALANÇO', b.cgrus AS 'GRUPO_INS', C.CODIGOS AS 'SUBGRUPO_INS',
	b.cpros AS 'COD_INSUMO',B.DPROS AS 'DESC_INSUMO', A.SQTDS AS 'SALDO', B.CUNIS AS 'UN', A.spesos AS 'QTD', B.cunips AS 'UN_QTD', B.custofs AS 'CUSTO_EST', B.moedas AS 'MOEDA',
		CASE
			WHEN D.inativas = 1 THEN 'INATIVA'
			WHEN D.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS', F.descs, MAX(H.datas)
	FROM sigmvest A (NOLOCK)
		LEFT join sigcdpro B (NOLOCK) ON a.cpros = B.cpros
		LEFT JOIN SIGCDPSG C (NOLOCK) ON B.CGRUS = C.CGRUS and B.sgrus = C.codigos
		LEFT JOIN SIGCDCLI D (NOLOCK) ON A.ESTOS = D.ICLIS
		LEFT JOIN SigCdFcx E (NOLOCK) ON A.grupos = E.grupos AND A.estos = E.contas
		LEFT JOIN SigCdGpr F (NOLOCK) ON B.mercs = F.codigos
		LEFT JOIN SigCdNei G (NOLOCK) ON G.cmats = B.cpros 
		LEFT JOIN SigPdMvf H (NOLOCK) ON G.empdnps = H.empdnps
	WHERE A.SQTDS <> 0 AND
		A.GRUPOS IN ('PCP','OURIVESARI','CRAVAÇÃO','POLIMENTO','FUNDICAO','ESTOQUE','FUNCIONARI','FORNECEDOR') AND
		D.iclis IN ('F000000580') --AND
--		AND B.cpros IN ('GE.VD.0014', 'GE.VD.0015')
		--F.descs <> 'PRODUTOS'
		GROUP BY a.cidchaves, a.emps, a.grupos, D.iclis, D.rclis, b.cgrus, b.cpros, b.dpros, a.sqtds, b.cunis, c.codigos, D.inativas, D.dtalts , A.spesos , B.cunips, B.custofs , B.moedas, F.descs 
--C.CGRUS IN ('IMT','IMF','IAU') AND
--C.CODIGOS IN ('METAL','CORREN','ESFERA','MOSQUE','PLACA','TARR  ''0.85 ','0.88  ','0.90  ','0.93  ','0.95  ','0.98  ', '1.136 ','1.22  ','M24')
--AND b.cpros = 'AU750'
--B.cgrus NOT IN ('AL', 'AN', 'ARG', 'BR', 'BRA', 'COL', 'PIN', 'PUL') 
