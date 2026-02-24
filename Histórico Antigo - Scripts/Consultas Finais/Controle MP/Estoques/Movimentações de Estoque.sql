(SELECT A.datars AS 'DATA-HORA', DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), DAY(A.datas)) AS 'DATA', L.dopes AS 'TIPO PEDIDO', L.numes AS 'PEDIDO', K.nops AS 'OP', E.cpros AS 'COD_PROD',
	E.dpros AS 'DESC_PROD', B.qtds AS 'QTD_PÇs', '' AS 'TIPO',A.dopes AS 'OPERARAÇAO',--CONVERT(int,A.mascnum) AS 'NUM_OP',
	A.grupoos AS 'GRUPO_ORG', A.contaos AS 'CONTA_ORG', C.rclis AS 'NOME_ORG', A.grupods AS 'GRUPO_DEST', A.contads AS 'CONTA_DEST', D.rclis AS 'NOME_DEST',
		CASE
			WHEN E.cgrus = 'IAU' THEN E.cpros 
			ELSE E.cgrus
		END AS 'GRUPO_INS',
	B.cpros AS 'COD_INS',B.dpros AS 'DESC_INSUMO', B.qtds AS 'QTD1', B.cunis AS 'UNIT_QTD1', 0 AS 'PESO_QTD1_GR', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2', 0 AS 'PESO_TOTAL',
	B.univals AS 'VALOR', B.moedas AS 'MOEDA', B.totas AS 'VALOR_REAIS',
	CASE
		WHEN (SELECT TOP 1 COUNT(F.codbarras) FROM SigMvHst (NOLOCK) F WHERE B.codbarras = F.codbarras ORDER BY COUNT(F.codbarras) DESC) > 1 THEN 'EMITIDA'
		ELSE 'PENDENTE'
	END AS 'NF_EMITIDA',
	A.usuars AS 'RESPONSAVEL'--, B.obs AS 'OBS1', Convert(varchar(max),A.obses) AS 'OBS2', B.cpro2s AS 'COD_PROD'
FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		LEFT JOIN SigCdPro (NOLOCK) E ON B.cpros = E.cpros
		--LEFT JOIN SIGCDPRO (NOLOCK) F ON B.CPROS = F.CPROS
		LEFT JOIN SigMvItn (NOLOCK) M ON B.codbarras = M.codbarras AND E.cpros = M.cpros AND M.dopes = 'FINALIZA NACIONAL'
		LEFT JOIN SigMvCab (NOLOCK) N ON M.empdopnums = N.empdopnums
		LEFT JOIN SigPdMvf (NOLOCK) K ON REPLACE(N.empdncrds, ' ','') = REPLACE(K.empdnps, ' ', '')
		LEFT JOIN SigOpPic (NOLOCK) L ON L.nops = K.nops AND M.codbarras = L.codbarras
	WHERE A.datas >= '2020-01-01'
			AND A.dopes NOT IN ('ORÇAMENTO', 'PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO FABRICA', 'PEDIDO ENCOMENDA', 'PEDIDO PILOTO', 'ENTRADA CONSERTO',
										'DV ASS. TEC. C.CUSTO', 'DV ASS.TEC.S. CUSTO ', 'NF COMPRA DIVERSAS  ', 'NF VENDA PILOTO     ', 'PEDIDO PEDRA        ', 'PRE NF COMP MP FINAN',
										'EMPENHO MT PRIMA    ')
			AND E.cgrus NOT IN ('FER', 'OBJ', 'MCP'))
			--AND F.OP = '6778'
			--AND A.dopes LIKE 'ENVIO PILOTO        '
			--AND B.cpros = 'PUL00138      '
			--AND A.grupods <> 'CLIENTE'
--	ORDER BY A.datars DESC, A.mascnum--F.OP ASC,)
UNION
(SELECT B.datas AS 'DATA-HORA', DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA', D.dopes 'TIPO PEDIDO',
			D.numes 'PEDIDO', D.nops 'OP', F.cpros 'COD_PROD', F.dpros 'DESC_PROD', D.qtds 'QTD_PÇs',
			C.tpops AS 'TIPO', B.dopps 'OPERAÇAO',-- B.numps AS 'NUM_OP',
			B.grupoos AS 'GRP_ORG', B.contaos AS 'CONTA_ORG', E.rclis AS 'NOME_ORG',
			B.grupods AS 'GRP_DEST', B.contads AS 'CONTA_DEST', G.rclis AS 'NOME_DEST',
			CASE
				WHEN A.cgrus = 'IAU' THEN A.cpros
				ELSE A.cgrus
			END AS 'GRUPO_INS',
			C.cmats AS 'COD_INS', A.dpros 'DESC_INSUMO',
			C.qtds AS 'QTD1', C.cunis AS 'UNIT_QTD1', C.pesos AS 'PESO_QTD1_GR', C.peso2s AS 'QTD2', A.cunips AS 'UNIT_QTD2', B.totpesos 'PESO_TOTAL',
			0 AS 'VALOR', '' AS 'MOEDA', 0 AS 'VALOR_REAIS', 'PENDENTE' AS 'NF_EMITIDA', '' AS 'RESPONSAVEL' --, B.obss AS 'OBS1', '' AS 'OBS2', '' AS 'COD_PROD'
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
			LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SIGCDCLI G (NOLOCK) ON B.contads = G.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN SigCdPro F (NOLOCK) ON D.cpros = F.cpros
		WHERE B.dopps IN ('TRABALHADOS S/ OP   ', 'TRABALHADOS         ' ,'FINALIZAÇÃO         ', 'DESAGREGA PEDRA     ','MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ','SEPARA PEDRA        ' )
				--AND C.cmats = 'AU750         ' --SE QUISER VER SÓ AU750
				AND B.datas >= '2020-01-01') --DATA POSTERIOR À
				--AND B.datas <= '2020-01-12' --DATA ANTERIOR À
				--AND C.tpops IN ('OURIVESARIA.TRA', 'CRAVACAO.TRAB', 'POLIMENTO.TRAB', 'PRE-POLIMENTO', 'DEVOL MATERIAL', 'MONTAGEM.TRAB')
				--AND B.contaos = '0000000139' --CÓD. CONTA ORIGEM
				--OR B.contads = '0000000072') --CÓD. CONTA DESTINO
--		ORDER BY B.datas DESC )
	
	
--('DESAGREGA PEDRA     ', 'DIVISAO DE OP       ', 'FINALIZA OP S/BARRA ', 'FINALIZA S INDUSTRIA', 'FINALIZAÇÃO         ', 'INDUSTRIALIZAÇÃO    ', 'INDUSTRIALIZAÇÃO OS ', 
--	'MUDA SETOR C ESTOQ  ', 'MUDA SETOR S ESTOQ  ', 'SEPARA PEDRA        ', 'TRABALHADOS         ', 'TRABALHADOS OS      ', 'TRABALHADOS S/ IND  ', 'TRABALHADOS S/ OP   ')