select a.dtalts,a.empdopnums,b.emps,b.dtalts, b.dopes,b.numes, a.cpros,a.codbarras,a.mats,a.dpros,a.pesos,a.cunips,a.qtds,a.cunis
from sigsubmv a
inner join sigmvitn B on a.codbarras = b.codbarras
where a.dtalts >='2017-06-01'
and b.dtalts >='2017-06-01'
and b.dopes in ('nf venda','nf venda piloto','NF RET INDUSTRIALIZA')
and a.codbarras <> 0
group by a.dtalts,a.empdopnums,b.emps,b.dtalts, b.dopes,b.numes, a.cpros,a.codbarras,a.mats,a.dpros,a.pesos,a.cunips,a.qtds,a.cunis
order by a.dtalts

--AND B.dopes = '' --AND B.cpros = 'AU750'