SELECT 
		EMPDOPNUMS, DATA_EMI, EMP, VENCIMENTO, DETALHE, OP_ESTOQ, NUM_OP_ESTOQ, OP_TITULO, NF, ID_ADMT, TITULO, GRUPO, CONTA,
		FORNEC,	VALOR_NF, MOEDA, VALOR_PAGO, OBS1, OBS2,
		SUM(ADIANTAMENTO) AS ADIANTAMENTO, MAX(DT_ADIANTAMENTO)AS DATA_ADIANT,
		SUM(PAGAMENTO_NF) AS VL_PAGO_NF, MAX(DT_PAGAMENTO_NF) AS DATA_PGMTO_NF
FROM
(SELECT * FROM
	(select A.empdopnums AS EMPDOPNUMS, A.datalts as DATA_EMI, A.emps AS EMP, A.vencs as VENCIMENTO,
		A.especienfs AS DETALHE, A.dopes as OP_ESTOQ, A.numes as NUM_OP_ESTOQ, C.nopercs AS ID_ADMT, A.dopcs as OP_TITULO,
		A.nfs AS NF, A.titulos AS TITULO, A.grupos AS GRUPO, A.contas AS CONTA, B.rclis as FORNEC, A.valors AS VALOR_NF,
		A.moedas AS MOEDA, A.valpags AS VALOR_PAGO, A.hists as OBS1, A.hist2s as OBS2, E.acertos AS ACERTOS,
		F.datarcs as 'Dt_rcbto',
		CASE
			WHEN C.dopecs = 'ADIANTAMENTO CLIENTE' THEN 'ADIANTAMENTO'
			ELSE 'PAGAMENTO_NF'
		END AS TIPO1,
		CASE
			WHEN C.dopecs = 'ADIANTAMENTO CLIENTE' THEN 'DT_ADIANTAMENTO'
			ELSE 'DT_PAGAMENTO_NF'
		END AS TIPO2
	from sigmvccr (NOLOCK) A
	left outer join sigcdcli (NOLOCK) B on A.contas = B.iclis
	left outer join sigcdpbx (NOLOCK) C on A.nopers = C.nopers and A.grupos = C.grupos and A.contas = C.contas and A.emps = C.emps
	left outer join sigopfp (NOLOCK) D on C.fpags = D.fpags 
	left outer join sigcdpit (NOLOCK) E on C.nopers = E.nopers and C.grupos = E.grupos and C.contas = E.contas
	left outer join sigcdpgr (NOLOCK) F on E.empdopnums = F.empdopnums
	left outer join SigMvCcr (NOLOCK) G on C.nopercs = G.nopers and A.grupos = G.grupos and A.contas = G.contas and A.emps = G.emps
	where A.datas>'2018-01-01' and A.grupos not in ('61') and A.opers='D' AND A.dopcs in ('CONTAS A RECEBER') 
		AND A.datas > '2019-01-01' AND (E.acertos = C.valos OR (F.datarcs = G.datas AND C.dopecs = 'ADIANTAMENTO CLIENTE'))
		--and A.nfs = '007163'
) AS TABELA1
PIVOT (SUM(ACERTOS) FOR TIPO1 IN ([ADIANTAMENTO], [PAGAMENTO_NF]))
AS PIVOTADA1
) AS TABELA2
PIVOT (MAX(Dt_rcbto) FOR TIPO2 IN ([DT_ADIANTAMENTO], [DT_PAGAMENTO_NF]))
AS PIVOTADA2
GROUP BY EMPDOPNUMS, DATA_EMI, EMP, VENCIMENTO, DETALHE, OP_ESTOQ, NUM_OP_ESTOQ, OP_TITULO, NF, TITULO, GRUPO, CONTA,
			FORNEC, VALOR_NF, MOEDA, VALOR_PAGO, OBS1, OBS2, ID_ADMT