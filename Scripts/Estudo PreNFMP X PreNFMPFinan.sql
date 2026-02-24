SELECT a.emps, a.datars, a.datas, a.dopes, a.numes, a.obses, a.grupoos, a.contaos, c.rclis, a.grupods, a.contads, d.rclis, a.usuars, a.valinis, a.valos, a.dtemis, a.numeronota, b.cpros, b.dpros,
				b.qtds, b.cunis, b.pesos, b.cunips, b.totas, b.units, b.univals, b.moevs, b.moevals, b.moedas
FROM SigMvCab a (nolock)
	left join SigMvItn b (nolock) ON a.empdopnums = b.empdopnums
	left join sigcdcli c (nolock) on a.contaos = c.iclis
	left join sigcdcli d (nolock) on a.contads = d.iclis
where a.dopes IN ('PRE NF COMP MP FINAN') and a.chksubn <> 0
order by a.datars DESC, a.empdopnums ASC, b.citens ASC


SELECT a.emps, a.datars, a.datas, a.dopes, a.numes, a.obses, a.grupoos, a.contaos, c.rclis, a.grupods, a.contads, d.rclis, a.usuars, a.valinis, a.valos, a.dtemis, a.numeronota, b.cpros, b.dpros,
				b.qtds, b.cunis, b.pesos, b.cunips, b.totas, b.units, b.univals, b.moevs, b.moevals, b.moedas, b.*
FROM SigMvCab a (nolock)
	left join SigMvItn b (nolock) ON a.empdopnums = b.empdopnums
	left join sigcdcli c (nolock) on a.contaos = c.iclis
	left join sigcdcli d (nolock) on a.contads = d.iclis
where a.dopes IN ('NF COMPRA MP') and a.chksubn = 0
order by a.datars DESC, a.empdopnums ASC, b.citens ASC






select a.emps as 'EMPRESA', a.dopes as 'OPERAÇÃO', a.numes as 'NUM_OPER', a.datas as 'DATA', RTRIM(K.iclis) AS 'COD_CLIENTE', RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			(B.obs) AS Obs_Item, b.cpros as 'COD_PRODUTO', j.dpros AS 'DESC_PRODUTO', b.qtds as 'QTD1', b.cunis, b.pesos, b.cunips, CASE WHEN b.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_ITEM',
			CASE WHEN a.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_PEDIDO', A.usuars as USUARIO, a.dtbaixas as 'DATA_BAIXA', left(a.ultgrvs,26) as 'OPER_BAIXA', L.iclis AS 'COD_DEST', L.rclis AS 'CONTA_DESTINO', f.emps, f.dopes, f.numes
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.empsubns 
								and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) and e.empdopnums not like '%PRE NF COMP MP FINAN%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigcdope g with(nolock) on f.dopes=g.dopes
--left join sigmvpec h with(nolock) on f.emps=h.empsubns 
--								and right(h.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),f.numes)))))+ltrim(rtrim(convert(varchar(6),f.numes)))
--								and g.ndopes = iif(len(h.codigos)=9,left(h.codigos,3),left(h.codigos,2))-- and h.empdopnums like  '%ENVIO MALOTE LOG>LJ%'
--left join sigmvcab i with(nolock) on i.empdopnums=h.empdopnums 
inner join sigcdpro j with(nolock) on j.cpros=b.cpros
LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
LEFT JOIN SigCDCLI (NOLOCK) L ON A.contads = L.iclis
where (a.dopes = 'PRE NF COMPRA MP' OR a.dopes = 'PRE NF COMP MP FINAN') and a.datas > '01-01-2025' --AND f.empdopnums <> ''
order by a.ultgrvs DESC, a.datas ASC, a.numes DESC, b.citens ASC



select a.emps as 'EMPRESA', a.dopes as 'OPERAÇÃO', a.numes as 'NUM_OPER', a.datas as 'DATA', RTRIM(K.iclis) AS 'COD_CLIENTE', RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			(B.obs) AS Obs_Item, b.cpros as 'COD_PRODUTO', j.dpros AS 'DESC_PRODUTO', b.qtds as 'QTD1', b.cunis, b.pesos, b.cunips, CASE WHEN b.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_ITEM',
			CASE WHEN a.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_PEDIDO', A.usuars as USUARIO, a.dtbaixas as 'DATA_BAIXA', left(a.ultgrvs,26) as 'OPER_BAIXA', L.iclis AS 'COD_DEST', L.rclis AS 'CONTA_DESTINO', f.emps, f.dopes, f.numes
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.empsubns 
								and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) and e.empdopnums not like '%PRE NF COMP MP FINAN%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigcdope g with(nolock) on f.dopes=g.dopes
--left join sigmvpec h with(nolock) on f.emps=h.empsubns 
--								and right(h.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),f.numes)))))+ltrim(rtrim(convert(varchar(6),f.numes)))
--								and g.ndopes = iif(len(h.codigos)=9,left(h.codigos,3),left(h.codigos,2))-- and h.empdopnums like  '%ENVIO MALOTE LOG>LJ%'
--left join sigmvcab i with(nolock) on i.empdopnums=h.empdopnums 
inner join sigcdpro j with(nolock) on j.cpros=b.cpros
LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
LEFT JOIN SigCDCLI (NOLOCK) L ON A.contads = L.iclis
where (f.dopes = 'NF COMPRA MP') and a.datas > '01-01-2025' --AND f.empdopnums <> ''
order by a.ultgrvs DESC, a.datas ASC, a.numes DESC, b.citens ASC