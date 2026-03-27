USE DB_ORF_REL
  --contas a pagar
select  DISTINCT tipos,a.empdopnums as 'Chave_mae',Chave_Mae_Financeiro,Data,a.emps,Vencimento,especienfs,Operação_Estoque,
		Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,Valor_Original,a.moedas,Valor_Faltante_Momento,
		ValorPago,[Conta CC],[Centro Custo],Pagto,Dt_pgto_rcbto,Hist1,Hist2
into #Titulos_Pagar
 from (
select a.docus,e.tipos,a.empdopnums,e.empdopnums as 'Chave_Mae_Financeiro',cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors as 'Valor_Original',a.moedas,e.acertos as 'ValorPago',e.valos as 'Valor_faltante_Momento',c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2' 
from DB_ORF_REL.dbo.SigMvCcr a
left outer join DB_ORF_REL.dbo.sigcdcli b on a.contas=b.iclis
left outer join DB_ORF_REL.dbo.sigcdpbx c on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas
left outer join DB_ORF_REL.dbo.sigopfp d on c.fpags=d.fpags 
left outer join DB_ORF_REL.dbo.sigcdpit e on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas and c.valos=e.acertos
left outer join DB_ORF_REL.dbo.sigcdpgr f on e.empdopnums=f.empdopnums
where dopcs in ('CONTAS A PAGAR') and a.datas>'2018-01-01' and a.opers='c' and a.grupos not in ('61') 
) a
left outer join (
select a.docus,a.empdopnums,titulos,a.grupos,contas as 'Conta CC',b.rclis as 'Centro Custo',a.usualts 
from DB_ORF_REL.dbo.sigmvccr a
left outer join DB_ORF_REL.dbo.sigcdcli b on a.contas=b.iclis
where dopcs in ('CONTAS A PAGAR') and a.datas>'2018-01-01' and opers='d' and a.grupos not in ('61'))
b on a.titulos=b.titulos and a.docus=b.docus
order by a.Dt_pgto_rcbto
SELECT * FROM #Titulos_Pagar