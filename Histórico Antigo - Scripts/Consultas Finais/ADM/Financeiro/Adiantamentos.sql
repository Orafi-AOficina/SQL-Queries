SELECT DISTINCT A.empdopnums,CAST(A.datas AS DATE) AS 'LANÇAMENTO', A.emps, CAST(A.dtemis AS DATE) AS 'RECEBIMENTO',
	A.dopes as 'Operação_Estoque', A.numes as 'PEDIDO', A.titulos AS 'TITULO', A.grupos AS 'GRUPO_CONTA', A.contas AS 'COD_CONTA',
	b.rclis as 'Fornecedor', A.valors, A.moedas, A.valpags, A.hist2s as 'Hist2'
	, C.nopercs AS ID_ADIANTAMENTO
FROM SigMvCcr A (NOLOCK)
LEFT OUTER JOIN SIGCDCLI B (NOLOCK) ON A.contas = B.iclis
LEFT OUTER JOIN SigCdPbx C (NOLOCK)  ON A.nopers = C.nopercs AND A.grupos = C.grupos AND A.contas = C.contas AND A.emps = C.emps
LEFT OUTER JOIN SigOpFp D (NOLOCK) ON C.fpags = D.fpags
LEFT OUTER JOIN SigCdPit E (NOLOCK) ON C.nopers = E.nopers AND C.grupos = E.grupos AND C.contas = E.contas
LEFT OUTER JOIN SigCdPgr F (NOLOCK) ON E.empdopnums = F.empdopnums
WHERE A.dopes = 'ADIANTAMENTO CLIENTE' AND A.grupos = 'CLIENTE' AND A.opers = 'C' AND A.titulos NOT LIKE ''
ORDER BY RECEBIMENTO