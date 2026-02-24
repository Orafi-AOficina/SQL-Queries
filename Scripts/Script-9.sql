SELECT DISTINCT A.cpros, A.dpros  --, A.dopes
FROM SigMvItn A
		LEFT JOIN SIgMvCab C ON A.empdopnums = C.empdopnums
		LEFT JOIN SigCdPro B ON A.cpros = B.cpros
WHERE B.cgrus = 'OUT' AND C.datas > '01-01-2023'





select a.emps as 'EMPRESA', a.dopes as 'OPERAÇÃO', a.numes as 'NUM_OPER', a.datas as 'DATA', k.iclis, RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			(B.obs) AS Obs_Item, b.cpros as 'COD_PRODUTO', j.dpros AS 'DESC_PRODUTO', b.qtds as 'QTD1', b.cunis, b.pesos, b.cunips, CASE WHEN b.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_ITEM',
			CASE WHEN a.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_PEDIDO', A.usuars as USUARIO, a.dtbaixas as 'DATA_BAIXA', left(a.ultgrvs,26) as 'OPER_BAIXA', a.contads, L.iclis AS 'COD_DEST', L.rclis AS 'CONTA_DESTINO'
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.empsubns 
								and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) and e.empdopnums like '%TRF PRE VENDA EMP%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigcdope g with(nolock) on f.dopes=g.dopes
left join sigmvpec h with(nolock) on f.emps=h.empsubns 
								and right(h.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),f.numes)))))+ltrim(rtrim(convert(varchar(6),f.numes)))
								and g.ndopes = iif(len(h.codigos)=9,left(h.codigos,3),left(h.codigos,2)) and h.empdopnums like  '%ENVIO MALOTE LOG>LJ%'
left join sigmvcab i with(nolock) on i.empdopnums=h.empdopnums 
inner join sigcdpro j with(nolock) on j.cpros=b.cpros
LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
LEFT JOIN SigCDCLI (NOLOCK) L ON A.contads = L.iclis
where a.dopes LIKE '%TRUNK%' and b.opers = 'E'
order by a.datas ASC, a.numes DESC, b.citens ASC









