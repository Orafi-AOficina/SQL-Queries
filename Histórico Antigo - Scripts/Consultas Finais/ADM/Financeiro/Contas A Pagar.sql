SELECT A.empdopnums AS 'Chave_mae', CAST(A.datas as date) as Data, A.emps, CAST(A.vencs AS date) AS 'Vencimento', A.especienfs,
	A.dopes as 'Operação_Estoque', A.numes as 'Numero_Op_Estoque', A.dopcs as 'Operação_titulo', A.nfs, A.titulos, A.grupos, 
	A.contas, B.rclis as 'Fornecedor', A.moedas, G.contas as 'Conta CC', H.rclis as 'Centro Custo', C.fpags as 'Pagto',
	F.datarcs as 'Dt_pgto_rcbto', E.empdopnums as 'Chave_Mae_Financeiro', A.valors as 'Valor_Original',
	E.valos as 'Valor_Pago', E.acertos as 'Pagamento', G.usualts AS 'Usuário', A.hists as 'Hist1', A.hist2s as 'Hist2'
FROM SigMvCcr A
LEFT JOIN sigcdcli B ON A.contas = B.iclis
LEFT JOIN sigcdpbx C ON A.nopers = C.nopers AND A.grupos = C.grupos AND A.contas = C.contas
LEFT JOIN sigopfp D ON C.fpags = D.fpags 
LEFT JOIN sigcdpit E ON C.nopers = E.nopers AND C.grupos = E.grupos AND C.contas = E.contas AND C.valos = E.acertos
LEFT JOIN sigcdpgr F ON E.empdopnums = F.empdopnums
LEFT JOIN SigMvCcr G (NOLOCK) ON A.titulos = G.titulos AND A.docus = G.docus AND A.opers = 'c' AND G.opers = 'd'
LEFT JOIN SIGCDCLI H (NOLOCK) ON G.contas = H.iclis
WHERE A.dopcs IN ('CONTAS A PAGAR')
	AND A.datas>'2018-01-01'
	AND A.opers='c'
	AND A.grupos NOT IN ('61')
	AND G.grupos NOT IN ('61')
ORDER BY F.datarcs ASC, H.rclis ASC, E.acertos