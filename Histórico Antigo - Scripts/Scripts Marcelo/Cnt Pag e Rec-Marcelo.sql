use DB_RELATORIOS
go

if exists (select * from sys.tables where name='Titulos_Pagar')
drop table Titulos_Pagar 
go


if exists (select * from sys.tables where name='Titulos_Receber')
drop table Titulos_Receber
go

  --contas a pagar
select  DISTINCT tipos,a.empdopnums as 'Chave_mae',Chave_Mae_Financeiro,Data,a.emps,Vencimento,especienfs,Operação_Estoque,Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,Valor_Original,a.moedas,Valor_Faltante_Momento,ValorPago,[Conta CC],[Centro Custo],Pagto,Dt_pgto_rcbto,Hist1,Hist2
into Titulos_Pagar 
 from (
select a.docus,e.tipos,a.empdopnums,e.empdopnums as 'Chave_Mae_Financeiro',cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors as 'Valor_Original',a.moedas,e.acertos as 'ValorPago',e.valos as 'Valor_faltante_Momento',c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2' 
from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b on a.contas=b.iclis
left outer join db_orf.dbo.sigcdpbx c on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas
left outer join db_orf.dbo.sigopfp d on c.fpags=d.fpags 
left outer join db_orf.dbo.sigcdpit e on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas and c.valos=e.acertos
left outer join db_orf.dbo.sigcdpgr f on e.empdopnums=f.empdopnums
where dopcs in ('CONTAS A PAGAR') and a.datas>'2018-01-01' and a.opers='c' and a.grupos not in ('61') 
) a
left outer join (
select a.docus,a.empdopnums,titulos,a.grupos,contas as 'Conta CC',b.rclis as 'Centro Custo',a.usualts 
from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b on a.contas=b.iclis
where dopcs in ('CONTAS A PAGAR') and a.datas>'2018-01-01' and opers='d' and a.grupos not in ('61')) b on a.titulos=b.titulos and a.docus=b.docus
order by a.Dt_pgto_rcbto


 --contas a receber
select  DISTINCT a.empdopnums as 'Chave_Mae',Data,a.emps,Vencimento,especienfs,Operação_Estoque,Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,valors,moedas,valpags,[Conta CC],[Centro Custo],Pagto,Dt_pgto_rcbto,Hist1,Hist2
into Titulos_Receber
from (
select a.empdopnums,cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors,a.moedas,valpags,c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2'  from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b on a.contas=b.iclis
left outer join db_orf.dbo.sigcdpbx c on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas and a.emps=c.emps
left outer join db_orf.dbo.sigopfp d on c.fpags=d.fpags 
left outer join db_orf.dbo.sigcdpit e on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas
left outer join db_orf.dbo.sigcdpgr f on e.empdopnums=f.empdopnums
where dopcs in ('CONTAS A RECEBER') and a.datas>'2018-01-01' and a.opers='D' and a.grupos not in ('61')
--and a.titulos='000319/1'  
) a
left outer join (
select a.empdopnums,titulos,a.grupos,contas as 'Conta CC',b.rclis as 'Centro Custo',a.usualts from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b on a.contas=b.iclis
where dopcs in ('CONTAS A RECEBER') and a.datas>'2018-01-01' and opers='C'and a.grupos not in ('61')
) b on a.titulos=b.titulos

UNION ALL

 -- Adiantamentos
select  DISTINCT a.empdopnums as 'Chave_Mae',Data,a.emps,Vencimento,especienfs,Operação_Estoque,Numero_Op_Estoque,Operação_titulo,nfs,a.titulos,a.grupos,a.contas,fornecedor,valors,moedas,valpags,'' AS [Conta CC],'' AS [Centro Custo],Pagto,Dt_pgto_rcbto,Hist1,Hist2
from (
select a.empdopnums,cast (a.datas as date) as Data,a.emps,cast(a.vencs as date) as 'Vencimento',a.especienfs,a.dopes as 'Operação_Estoque',a.numes as 'Numero_Op_Estoque',dopcs as 'Operação_titulo',nfs,titulos,a.grupos,a.contas,b.rclis as 'Fornecedor',valors,a.moedas,valpags,c.fpags as 'Pagto',f.datarcs as 'Dt_pgto_rcbto',a.hists as 'Hist1',a.hist2s as 'Hist2'  from db_orf.dbo.sigmvccr a
left outer join db_orf.dbo.sigcdcli b with(nolock) on a.contas=b.iclis
left outer join db_orf.dbo.sigcdpbx c with(nolock)  on a.nopers=c.nopers and a.grupos=c.grupos and a.contas=c.contas and a.emps=c.emps
left outer join db_orf.dbo.sigopfp d with(nolock) on c.fpags=d.fpags 
left outer join db_orf.dbo.sigcdpit e with(nolock) on c.nopers=e.nopers and c.grupos=e.grupos and c.contas=e.contas
left outer join db_orf.dbo.sigcdpgr f with(nolock) on e.empdopnums=f.empdopnums
where a.dopes in (
'AD METAL CLIENTE','ADIANTA MP FINANC','BX METAL CLIENTE','CANCELA NF COMP PEDR','CANCELAMENTO NF','DEV RESUMO ENT BRI','DEV RESUMO ENT PEDRA','DEVOLUÇÃO DE VENDAS','DV ASS. TEC. C.CUSTO','ENVIO ROMANEIO','NF COMPRA DIVERSAS','NF COMPRA MP','NF COMPRA PEDRA','NF DEVOLUÇÃO COMPRA','NF DEVOLUÇÃO COMPRA.','NF DEVOLUCAO VENDA',  
'NF ENT INDUSTRIA','NF INDUSTRIALIZACAO','NF RET INDUSTRIA','NF RET INDUSTRIALIZA','NF RET MERC INDUSTRI','NF RET PURIFICAÇÃO','NF RET REMESSA IND.','NF SIMPLES FATURA','NF SIMPLES FATURA.','NF VENDA','NF VENDA ENT FUTURA','NF VENDA PILOTO','PRE NF COM MP TOTAL.','PRE NF COMPRA MP',         
'RESUMO ENT BRILHANTE','RESUMO ENT MP','RESUMO ENT MP TOTAL','RESUMO ENT PEDRA','SIMPLES_FATURAMENTO' )
 and a.datas>'2018-01-01'  and a.grupos not in ('61') and a.dopcs='' and a.opers='D'
--and a.titulos='000319/1'  
) a






