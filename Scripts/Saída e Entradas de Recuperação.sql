SELECT 
	A.emps AS 'EMPRESA', A.EMPDOPNUMS AS 'CHAVE_MAE',C.dtalts AS 'ENTRADA',A.NOTAS AS 'NUM_NF',
	C.opers AS 'TIPO_MOV', A.DOPES AS 'OPERACAO',A.NUMES AS 'NUM_OPS',E.DGRUS AS 'GRP_PRODUTO',C.CPROS AS 'COD_PRODUTO',
	C.DPROS AS 'DESC_PRODUTO',C.QTDS AS 'QTD',C.QTBAIXAS AS 'QTD BAIXADA',C.UNITS AS 'VL_UNITARIO',
	C.CUNIS AS 'UNIDADE', C.pesos AS 'QTD2', C.cunips, J.rclis AS 'DESTINO', F.RCLIS AS 'ORIGEM', A.obses AS 'OBSERVAÇÃO'
FROM SIGMVCAB A (NOLOCK)
LEFT JOIN SIGCDOPE B (NOLOCK) ON A.DOPES=B.DOPES
LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
LEFT JOIN SIGCDPRO D (NOLOCK) ON C.CPROS=D.CPROS
LEFT JOIN SIGCDGRP E (NOLOCK) ON D.CGRUS=E.cgrus
LEFT JOIN SIGCDCLI F (NOLOCK) ON A.CONTAOS=F.ICLIS
LEFT JOIN SIGCDCLI J (NOLOCK) ON A.contads=J.ICLIS
LEFT JOIN SIGPRNFE G (NOLOCK) ON A.EMPDOPNUMS=G.EMPDOPNUMS AND G.datas = (SELECT MAX(I.datas) FROM sigprnfe I WHERE A.EMPDOPNUMS=I.EMPDOPNUMS GROUP BY I.empdopnums)
--WHERE B.tipoops in ('1','9') 
WHERE A.dopes IN ('RECUPERAÇAO INTERNA', 'NF RET PURIFICAÇÃO C')
	AND C.citem2 = 0
	AND C.opers = 'E'
	AND C.dtalts >'2025-01-01'
	AND (G.stats NOT LIKE '' OR G.stats IS NULL)
ORDER BY C.dtalts DESC, A.DOPES ASC








select a.emps as Empresa, a.dopes as Operação, a.numes as Num_Conserto, a.datas as Data_Entrada, a.prazoents as Prazo, RTRIM(K.iclis) AS 'COD_CLIENTE', RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			a.dtbaixas as Data_Baixa, left(a.ultgrvs,26) as Baixa, b.citens AS COD_ITEM, b.cpros as Produto, j.dpros as Descricao, j.reffs as Ref_Cliente, b.qtds as Qtds, b.qtbaixas as QTD_Baixada,  b.pesos as Peso_Total, c.codtams as Tamanho, (B.obs) AS Obs_Item,
			b.chksubn AS 'BAIXA_ITEM', a.chksubn AS 'BAIXA_PEDIDO', A.usuars as USUARIO
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigmvits c with(nolock) on a.empdopnums=c.empdopnums and b.citens=c.citens
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.empsubns 
								and right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) --and e.empdopnums like '%TRF PRE VENDA EMP%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigcdope g with(nolock) on f.dopes=g.dopes
left join sigmvpec h with(nolock) on f.emps=h.empsubns 
								and right(h.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),f.numes)))))+ltrim(rtrim(convert(varchar(6),f.numes)))
								and g.ndopes = iif(len(h.codigos)=9,left(h.codigos,3),left(h.codigos,2)) --and h.empdopnums like  '%ENVIO MALOTE LOG>LJ%'
left join sigmvcab i with(nolock) on i.empdopnums=h.empdopnums 
inner join sigcdpro j with(nolock) on j.cpros=b.cpros
LEFT JOIN SigCDCLI (NOLOCK) K ON A.contaos = K.iclis
where a.datas >= '01-01-2026' AND A.dopes IN ('NF REFINO', 'NF PURIFICACAO')
order by a.datas DESC, a.numes DESC, b.citens ASC