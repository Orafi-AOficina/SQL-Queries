SELECT *, 
	DATEDIFF(day,ENTRADA, FINALIZACAO)*SALDO AS 'LT_x_PEÇA',
	CASE WHEN DATEDIFF(day, PRAZO, FINALIZACAO) > 0 THEN DATEDIFF(day, PRAZO, FINALIZACAO)*SALDO ELSE 0 END AS 'ATRASO_x_PEÇA',
	MONTH(PRAZO) AS 'MES_PRAZO', YEAR(PRAZO) AS 'ANO_PRAZO' ,MONTH(FINALIZACAO) AS 'MES_FINALI', YEAR(FINALIZACAO) AS 'ANO_FINALI',
	CASE WHEN LEFT(DESCRIÇAO,4) IN ('TARR', 'MOSQ') THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'TARRAXA/MOSQUETAO'
	FROM
	(SELECT DISTINCT A.dopes as 'TIPO_PEDIDO', B.rclis as 'CLIENTE', A.mascnum as 'PEDIDO', A.nops AS 'OP_PEDIDO', D.NOPS AS 'OP_ITEM', D.nopmaes AS 'OP_MAE',
				CASE
					WHEN D.nopmaes = 0 THEN D.nops
					WHEN D.nopmaes > 0 AND (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes) = 0 THEN D.nopmaes 
					WHEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))= 0 THEN (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes)
					ELSE (SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=(SELECT TOP 1 nopmaes FROM SigOpPic WHERE nops=D.nopmaes))
				END AS 'OP_ORIGINAL',
				CASE WHEN D.nopmaes NOT LIKE 0 OR (SELECT TOP 1 COUNT(nops) FROM SigOpPic WHERE D.nops = nopmaes) > 0 THEN 'VERDADEIRO' ELSE 'FALSO' END AS 'TEVE_QUEBRA',
				G.reffs AS 'REF_ANIMALE', C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', A.datas AS 'ENTRADA',
				A.PRAZOENTS AS 'PRAZO', C.qtds AS 'Qtd_Original',D.qtds AS 'SALDO', 
				CASE WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZAÇÃO','FINALIZA OP S/BARRA ')) THEN 'FINALIZADO'
					WHEN D.nops IN (SELECT DISTINCT NOPS FROM SigPdMvf where dopps in ('FINALIZA S INDUSTRIA') ) THEN 'CANCELADO'
					ELSE 'PENDENTE'
				END AS 'STATUS',
				Convert(varchar(max),a.obses) as 'OBSERVAÇÃO',
				(SELECT DISTINCT MIN(datas) FROM SigPdMvf
							where dopps in ('MUDA SETOR C ESTOQ  ','MUDA SETOR S ESTOQ  ')
								AND nops = D.nops
					) AS MUDA_SETOR_ESTOQ,
				(SELECT DISTINCT MAX(datas) FROM SigPdMvf
							where dopps in ('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')
								AND nops = D.nops
					) AS FINALIZACAO,
				E.datas AS DATA_MOV, I.tpops AS ATIVIDADE
	FROM SigMvCab A (NOLOCK)
	INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
	INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
	LEFT JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0
	INNER JOIN (select a.*  
					from sigpdmvf a (NOLOCK)
						join (select nops, cidchaves as cidchaves
									from SigPdMvf (NOLOCK)
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
	 					where dopps <> SPACE(20)
				) e on d.nops = e.nops
	INNER JOIN sigcdcli F (NOLOCK) on e.contaos = F.iclis
	INNER JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
	LEFT JOIN SigCdNei I (NOLOCK) ON E.empdnps = I.empdnps
	WHERE A.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
	 			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2019'
	 			--AND (D.nops > 0 AND C.qtds < (SELECT qtds FROM SigMvItn WHERE D.nopmaes)
	 			--AND D.NOPS IN ('69980002','64730003','64750002','64760001')
	 			--AND A.nops = '6998'
) AS TABELA
PIVOT
(MIN(DATA_MOV) FOR ATIVIDADE IN ( [OURIVESARIA.TRA], [CRAVACAO.TRAB  ], 
			[PRE-POLIMENTO  ],	[MONTAGEM.TRAB  ], [POLIMENTO.TRAB ])
) AS PIVOTADA
ORDER BY ENTRADA, PEDIDO, OP_ITEM --TABELA.ATIVIDADE --A.datas ASC, A.mascnum ASC, D.nops ASC