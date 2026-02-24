select E.*, a.emps as Empresa, a.dopes as Operação, a.numes as Num_Conserto, a.datas as Data_Entrada, a.prazoents as Prazo, RTRIM(K.iclis) AS 'COD_CLIENTE', RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			a.dtbaixas as Data_Baixa, left(a.ultgrvs,26) as Baixa, b.citens AS COD_ITEM, b.cpros as Produto, j.dpros as Descricao, j.reffs as Ref_Cliente, b.qtds as Qtds, b.qtbaixas as QTD_Baixada,  b.pesos as Peso_Total, c.codtams as Tamanho, (B.obs) AS Obs_Item,
			b.chksubn AS 'BAIXA_ITEM', a.chksubn AS 'BAIXA_PEDIDO', A.usuars as USUARIO
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.empsubns 
								and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) and e.empdopnums like '%DV ASS.%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigcdope g with(nolock) on f.dopes=g.dopes
left join sigmvpec h with(nolock) on f.emps=h.empsubns 
								and right(h.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),f.numes)))))+ltrim(rtrim(convert(varchar(6),f.numes)))
								and g.ndopes = iif(len(h.codigos)=9,left(h.codigos,3),left(h.codigos,2)) and h.empdopnums like  '%DV ASS.%'
left join sigmvcab i with(nolock) on i.empdopnums=h.empdopnums 
inner join sigcdpro j with(nolock) on j.cpros=b.cpros
LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
where a.dopes LIKE '%ENTRADA CONSERTO%' and a.datas >= '01-01-2025' AND A.numes = 992
order by a.datas DESC, a.numes DESC, b.citens ASC






select a.emps as Empresa, a.dopes as Operação, a.numes as Num_Conserto, RTRIM(K.rclis) AS 'CLIENTE', b.obs,
			a.dtbaixas as Data_Baixa, b.citens AS COD_ITEM, b.cpros as Produto, j.dpros as Descricao, b.qtbaixas as QTD_Baixada, b.chksubn AS 'BAIXA_ITEM', a.chksubn AS 'BAIXA_PEDIDO'
	from sigmvcab a with(nolock)
		inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
		left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
		left join sigcdope d with(nolock) on a.dopes=d.dopes
		left join sigmvpec e with(nolock) on a.emps=e.empsubns 
										and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
										and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) and e.empdopnums like '%DV ASS.%'
		left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
		left join sigmvitn g with(nolock) on g.empdopnums=f.empdopnums and g.cpros = b.cpros
		left join sigcdpro j with(nolock) on j.cpros=b.cpros
		LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
where a.dopes LIKE '%ENTRADA CONSERTO%' and a.datas >= '01-01-2025' AND A.numes = 992
order by a.datas DESC, a.numes DESC, b.citens ASC