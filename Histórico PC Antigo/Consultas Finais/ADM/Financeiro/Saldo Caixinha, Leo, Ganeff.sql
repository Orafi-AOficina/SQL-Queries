--baseada na consulta Contas a Pagar
SELECT A.datalts AS 'Lançamento', CAST(A.datas as date) as Data, A.emps, CAST(A.vencs AS date) AS 'Vencimento',
	A.dopes as 'Operação_Estoque', A.numes as 'Numero_Op_Estoque', A.grupos AS 'Grupo Conta', A.contas AS 'Conta', B.rclis AS 'Nome Conta', 
	A.valors as 'Valor_Original', A.opers AS 'Tipo', A.saldos AS 'Saldo Conta', A.saldons ,A.hists as 'Hist1', A.hist2s as 'Hist2',
	A.scontas AS 'Conta Relacionada', C.rclis as 'Nome Conta Relacionada', A.nopers AS 'Chave Movimento'
FROM SigMvCcr A
LEFT JOIN sigcdcli B ON A.contas = B.iclis
LEFT JOIN sigcdcli C ON A.scontas = C.iclis
----------FALTA ADICIONAR O CARTAO DE CREDITO!!!!!----------
WHERE A.contas IN ('100210','100217','100209','100212','100213')------ CARTAO DE CREDITOOOOO!!!! --------
--WHERE A.contas IN ('100209')------ CARTAO DE CREDITOOOOO!!!! --------
	--AND A.datas > '10-01-2020'
ORDER BY A.datas, A.datalts ASC