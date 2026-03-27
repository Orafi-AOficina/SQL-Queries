use db_relatorios
drop table pagamentos
drop table recebimentos 

--recebimentos
select  DISTINCT empdopnums as 'Chave_Mae',Data,a.emps,Vencimento,especienfs,Operação_Estoque,Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,valors,moedas,valpags,Hist1,Hist2
into Pagamentos
from (
select a.empdopnums,cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors,a.moedas,valpags,c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2'  from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b with(nolock) on a.contas=b.iclis
left outer join db_orf.dbo.sigcdpbx c with(nolock)  on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas and a.emps=c.emps
left outer join db_orf.dbo.sigopfp d with(nolock) on c.fpags=d.fpags 
left outer join db_orf.dbo.sigcdpit e with(nolock) on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas
left outer join db_orf.dbo.sigcdpgr f with(nolock) on e.empdopnums=f.empdopnums
where a.dopes in ('RECEBIMENTO') 
 and a.datas>'2018-01-01'  and a.grupos not in ('61') and a.dopcs='' )a

 
 -- Pagamentos 
select  DISTINCT empdopnums as 'Chave_Mae',Data,a.emps,Vencimento,especienfs,Operação_Estoque,Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,valors,moedas,valpags,Hist1,Hist2
into Recebimentos
from (
select a.empdopnums,cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors,a.moedas,valpags,c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2'  from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b with(nolock) on a.contas=b.iclis
left outer join db_orf.dbo.sigcdpbx c with(nolock)  on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas and a.emps=c.emps
left outer join db_orf.dbo.sigopfp d with(nolock) on c.fpags=d.fpags 
left outer join db_orf.dbo.sigcdpit e with(nolock) on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas
left outer join db_orf.dbo.sigcdpgr f with(nolock) on e.empdopnums=f.empdopnums
where a.dopes in ('PAGAMENTO') 
 and a.datas>'2018-01-01'  and a.grupos not in ('61') and a.dopcs='' )a
 --select base
--select  DISTINCT empdopnums as 'Chave_Mae',Data,a.emps,Vencimento,especienfs,Operação_Estoque,Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,valors,moedas,valpags,Hist1,Hist2
--from (
--select a.empdopnums,cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors,a.moedas,valpags,c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2'  from db_orf.dbo.sigmvccr a
--left outer join db_orf.dbo.sigcdcli b with(nolock) on a.contas=b.iclis
--left outer join db_orf.dbo.sigcdpbx c with(nolock)  on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas and a.emps=c.emps
--left outer join db_orf.dbo.sigopfp d with(nolock) on c.fpags=d.fpags 
--left outer join db_orf.dbo.sigcdpit e with(nolock) on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas
--left outer join db_orf.dbo.sigcdpgr f with(nolock) on e.empdopnums=f.empdopnums
--where a.dopes in ('PAGAMENTO') 
-- and a.datas>'2018-01-01'  and a.grupos not in ('61') and a.dopcs='' )a and a.opers='D'
--and a.titulos='000319/1'  
--) a
--left outer join (
--select a.empdopnums,titulos,a.grupos,contas as 'Conta CC',b.rclis as 'Centro Custo',a.usualts from db_orf.dbo.sigmvccr a
--left outer join db_orf.dbo.sigcdcli b with(nolock) on a.contas=b.iclis
--where a.dopes in ('PAGAMENTO','RECEBIMENTO')
-- and a.datas>'2018-01-01' and a.grupos not in ('61') and a.dopcs='' and a.opers='C'
--) b on a.titulos=b.titulos


