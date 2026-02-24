SELECT B.datas AS 'DATA-HORA', DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA', D.dopes 'TIPO PEDIDO',
			D.numes 'PEDIDO', D.nops 'OP', F.cpros 'COD_PROD', F.dpros 'DESC_PROD', D.qtds 'QTD_PÇs',
			C.tpops AS 'TIPO', B.dopps 'OPERAÇAO', B.numps AS 'NUM_OP',
			B.grupoos AS 'GRP_ORG', B.contaos AS 'CONTA_ORG', E.rclis AS 'NOME_ORG',
			B.grupods AS 'GRP_DEST', B.contads AS 'CONTA_DEST', G.rclis AS 'NOME_DEST',
			CASE
				WHEN A.cgrus = 'IAU' THEN A.cpros 
				ELSE A.cgrus
			END AS 'GRUPO_INS',
			C.cmats AS 'COD_INS', A.dpros 'DESC_INSUMO', 
			C.qtds AS 'QTD1', C.cunis AS 'UNIT_QTD1', C.pesos AS 'PESO_QTD1_GR', C.peso2s AS 'QTD2', A.cunips AS 'UNIT_QTD2', B.totpesos 'PESO_TOTAL',
			0 AS 'VALOR', '' AS 'MOEDA', 0 AS 'VALOR_REAIS', '' AS 'RESPONSAVEL', B.obss AS 'OBS1', '' AS 'OBS2', '' AS 'COD_PROD'
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
			LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SIGCDCLI G (NOLOCK) ON B.contads = G.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN SigCdPro F (NOLOCK) ON D.cpros = F.cpros
		WHERE B.dopps IN ('TRABALHADOS S/ OP   ', 'TRABALHADOS         ' ,'FINALIZAÇÃO         ', 'DESAGREGA PEDRA     ','MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ','SEPARA PEDRA        ' )
				--AND C.cmats = 'AU750         ' --SE QUISER VER SÓ AU750
				AND B.datas >= '2020-11-10' --DATA POSTERIOR À
				--AND B.datas <= '2020-01-12' --DATA ANTERIOR À
				--AND C.tpops IN ('OURIVESARIA.TRA', 'CRAVACAO.TRAB', 'POLIMENTO.TRAB', 'PRE-POLIMENTO', 'DEVOL MATERIAL', 'MONTAGEM.TRAB')
				--AND B.contaos = '0000000139' --CÓD. CONTA ORIGEM
				--OR B.contads = '0000000072') --CÓD. CONTA DESTINO
		ORDER BY B.datas DESC
		
		
		