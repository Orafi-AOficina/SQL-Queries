SELECT DATEFROMPARTS(YEAR(B.datas),MONTH(B.datas), DAY(B.datas)) AS 'DATA_TRABALHADO', B.datas AS 'DATA-HORA', D.dopes 'TIPO PEDIDO',
			D.numes 'PEDIDO', D.nops 'OP', F.cpros 'COD_PROD', F.dpros 'DESC_PROD', D.qtds 'QTD PÇs',
			B.grupoos AS 'GRP_CONTA_ORI', B.contaos AS 'COD_CONTA_ORI', E.rclis AS 'NOME_CONTA_ORI',
			B.grupods AS 'GRP_CONTA_ORI', B.contads AS 'COD_CONTA_DEST', G.rclis AS 'NOME_CONTA_DEST',
			CASE
				WHEN E.inativas = 1 THEN 'INATIVA'
				WHEN E.inativas = 0 THEN 'ATIVA'
				ELSE 'VERIFICAR'
			END AS 'STATUS',
			C.tpops AS 'OPERACAO', B.dopps 'TIPO_OPERACAO',
			CASE
				WHEN LEFT(H.COMPLEXIDADE, 1) = '#' THEN H.COMPLEXIDADE
				ELSE ''
			END AS 'COMPLEXIDADE', C.cmats AS 'INSUMO', A.dpros 'DESC_INSUMO', 
			CASE
				WHEN A.cgrus = 'IAU' THEN A.cpros 
				ELSE A.cgrus
			END AS 'GRUPO_INS',
			C.qtds AS 'QTD', C.pesos AS 'PESO', C.peso2s AS 'PESO2S', B.totpesos 'PESO_TOTAL', B.obss AS 'OBSERVAÇÃO'
			--A.qtds AS 'QTD',
			--, B.*, C.*--, B.*
	--	FROM SigMvHst A (NOLOCK)
	--		LEFT JOIN SigCdNei C (NOLOCK) ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps AND A.cpros = C.cmats AND 
	--																				((A.dopes  = 'TRABALHADOS' AND A.qtds = C.qtds) OR (A.dopes = 'TRABALHADOS S/ OP'))-- AND A.qtds = C.qtds)) 
	--																				OR (A.dopes = 'TRABALHADOS S/ OP' AND B.totpesos = C.qtds))
		FROM SigCdNei C
			LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
			LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops --AND A.cpros = D.cpros
			LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
			LEFT JOIN SIGCDCLI G (NOLOCK) ON B.contads = G.iclis
			LEFT JOIN SigCdPro A (NOLOCK) ON A.cpros = C.cmats
			LEFT JOIN SigCdPro F (NOLOCK) ON D.cpros = F.cpros
			LEFT JOIN (select h.*, REPLACE(LEFT(Convert(varchar(max), H.obs),9), ' ','') AS 'COMPLEXIDADE' from SigCdPfc h (nolock)
										INNER JOIN (select produtos, MAX(dataalts) as 'ult_alteracao'
														from SigCdPfc (nolock)
														group by produtos) hh on hh.produtos = h.produtos and h.dataalts = hh.ult_alteracao
								) H ON F.cpros = H.produtos AND LEFT(REPLACE(H.grupos, ' ',''),5) = LEFT(REPLACE(C.tpops, '-',''), 5) 
		WHERE B.dopps IN ('TRABALHADOS S/ OP   ', 'TRABALHADOS         ' ,'FINALIZAÇÃO         ', 'DESAGREGA PEDRA     ','MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ','SEPARA PEDRA        ' )
				--AND C.cmats = 'AU750' --SE QUISER VER SÓ AU750
				AND B.datas >= '2020-11-10' --DATA POSTERIOR À
				--AND B.datas <= '2020-01-12' --DATA ANTERIOR À
				--AND C.tpops IN ('OURIVESARIA.TRA', 'CRAVACAO.TRAB', 'POLIMENTO.TRAB', 'PRE-POLIMENTO', 'DEVOL MATERIAL', 'MONTAGEM.TRAB')
				--AND B.contaos = '0000000139' --CÓD. CONTA ORIGEM
				--OR B.contads = '0000000072') --CÓD. CONTA DESTINO
				AND H.COMPLEXIDADE <> ''
		ORDER BY DATA_TRABALHADO DESC