--drop table estoque

--27541
select a.emps,a.grupos,a.estos as 'Conta_Estoque',c.rclis as 'Desc_Conta_Estoque',b.mercs as 'Grd_Grupo',b.cgrus as 'Grp Produto',a.cpros as 'Cod_Produto',b.reffs as 'Cod_Cliente',b.dpros as 'Descricao1',
b.dpro2s as 'Descricao2',a.sqtds as 'Saldo',a.spesos as 'Peso',a.codtams as 'Tamanho',b.codcors as 'Cor',b.cunis as 'Unidade',b.custofs as 'Vl_Custo',b.moecusfs as 'Moeda Custo',
b.pvens as 'Vl_Venda',b.moevs as 'Moeda_Venda' 
from sigmvest a with(nolock)
inner join sigcdpro b with(nolock) on a.cpros=b.cpros
left outer join sigcdcli c with(nolock) on a.estos=c.iclis
where a.sqtds <> 0 --solicitado saldo <> 0 via email em 24052019
order by a.grupos,a.estos,b.mercs,b.cpros,a.sqtds
