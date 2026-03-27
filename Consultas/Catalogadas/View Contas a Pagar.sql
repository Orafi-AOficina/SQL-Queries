--Contas a Pagar
SELECT        A.empdopnums AS Chave_mae, CAST(A.datas AS date) AS Data, A.emps, CAST(A.vencs AS date) AS Vencimento, A.especienfs, A.dopes AS Operagco_Estoque, A.numes AS Numero_Op_Estoque, A.dopcs AS Operagco_titulo, 
                         A.nfs, A.titulos, A.grupos, A.contas, B.rclis AS Fornecedor, A.moedas, G.contas AS [Conta CC], H.rclis AS [Centro Custo], C.fpags AS Pagto, F.datarcs AS Dt_pgto_rcbto, E.empdopnums AS Chave_Mae_Financeiro, 
                         A.valors AS Valor_Original, E.valos AS Valor_Pago, E.acertos AS Pagamento, G.usualts AS Usuario, A.hists AS Hist1, A.hist2s AS Hist2
FROM            dbo.SigMvCcr AS A LEFT OUTER JOIN
                         dbo.SIGCDCLI AS B ON A.contas = B.iclis LEFT OUTER JOIN
                         dbo.SigCdPbx AS C ON A.nopers = C.nopers AND A.grupos = C.grupos AND A.contas = C.contas LEFT OUTER JOIN
                         dbo.SigOpFp AS D ON C.fpags = D.fpags LEFT OUTER JOIN
                         dbo.SigCdPit AS E ON C.nopers = E.nopers AND C.grupos = E.grupos AND C.contas = E.contas AND C.valos = E.acertos LEFT OUTER JOIN
                         dbo.SigCdPgr AS F ON E.empdopnums = F.empdopnums LEFT OUTER JOIN
                         dbo.SigMvCcr AS G WITH (NOLOCK) ON A.titulos = G.titulos AND A.docus = G.docus AND A.opers = 'c' AND G.opers = 'd' LEFT OUTER JOIN
                         dbo.SIGCDCLI AS H WITH (NOLOCK) ON G.contas = H.iclis
WHERE        (A.dopcs IN ('CONTAS A PAGAR')) AND (A.datas > '2026-01-01') AND (A.opers = 'c') AND (A.grupos NOT IN ('61')) AND (G.grupos NOT IN ('61'))