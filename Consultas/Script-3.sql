SELECT A.idcontas AS 'NUM_LOJA', A.faxs 'COD_LOJA', B.descs AS 'TIPO_LOJA', A.iclis AS 'COD_CLIENTE', A.rclis AS 'CLIENTE', A.razaos AS 'RAZAO SOCIAL', A.cpfs AS 'CNPJ',
			A.obs 'NOME LOJA', A.cidas AS 'CIDADE', A.estas AS 'ESTADO', A.tabds AS 'TBL_DESCONTO', A.contaven2s AS 'COD_CONTA_MAE', C.rclis AS 'CONTA_MAE'
FROM SIGCDCLI (NOLOCK) A
	LEFT JOIN SigCdFpb (NOLOCK) B ON A.fpubls = B.cods
	LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaven2s = C.iclis
WHERE A.grupos = 'CLIENTE'
ORDER BY A.idcontas ASC, A.iclis ASC









SELECT DISTINCT RTRIM(A.idcontas) AS 'NUM_LOJA', RTRIM(A.faxs) 'COD_LOJA', RTRIM(B.descs) AS 'TIPO_LOJA', RTRIM(A.iclis) AS 'COD_CLIENTE', RTRIM(A.rclis) AS 'CLIENTE', RTRIM(A.razaos) AS 'RAZAO SOCIAL',
			RTRIM(A.cpfs) AS 'CNPJ', CAST(A.obs AS varchar) AS 'NOME LOJA', RTRIM(A.cidas) AS 'CIDADE', RTRIM(A.estas) AS 'ESTADO', RTRIM(A.tabds) AS 'TBL_DESCONTO', RTRIM(A.contaven2s) AS 'COD_CONTA_MAE',
			RTRIM(C.rclis) AS 'CONTA_MAE'
FROM SigMvCab AS D WITH (NOLOCK)
		LEFT OUTER JOIN SIGCDCLI AS A WITH (NOLOCK) ON D.contads = A.iclis
		LEFT JOIN SigCdFpb (NOLOCK) B ON A.fpubls = B.cods
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaven2s = C.iclis
WHERE (D.dopes LIKE 'PED %' OR D.dopes LIKE 'PEDIDO %' OR D.dopes LIKE '%CONSERT%' OR D.dopes LIKE '%CONSERT%' OR D.dopes LIKE '%TRUNKSH%')
ORDER BY RTRIM(A.rclis)







SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO', a.dopeos AS 'TIPO_PEDIDO', a.cbars AS 'COD_BARRAS',
					a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', b.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', b.dpros AS 'DESCRICAO',
					d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_TOTAL_METAL', a.peso2s as 'PESO_TOTAL_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO',
					b.obss as 'OBS_OP', f.mats AS 'COD_INSUMO', f.dpros AS 'INSUMO', f.qtds AS 'PESO', f.cunis AS 'UN', f.pesos AS 'QTD', f.cunips AS 'UN2'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.codbarras) as 'NUM_COD_BARRAS', ee.nops from sigoppic (nolock) ee where ee.codbarras > 0 group by ee.nops) e on e.nops = a.nops
	left join sigoppic (nolock) b on a.nops = b.nops and (a.cbars = b.codbarras or e.NUM_COD_BARRAS = 1)
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigsubmv (nolock) f on a.cbars = f.codbarras
where a.dtincs >= '01-01-2021'







select CASE WHEN a.emps = 'ORF' THEN 'ORA' ELSE a.emps end as Empresa, a.dopes as Operação, a.numes as Num_Conserto, a.datas as Data_Entrada, a.prazoents as Prazo, RTRIM(K.iclis) AS 'COD_CLIENTE', RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			a.dtbaixas as Data_Baixa, left(a.ultgrvs,26) as Baixa, b.cpros as Produto, j.dpros, j.reffs as Ref_Cliente, b.qtds as Qtds, c.codtams as Tamanho, (B.obs) AS Obs_Item,
			CASE WHEN b.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_ITEM',
			CASE WHEN a.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_PEDIDO', A.usuars as USUARIO, b.pesos, b.*
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
where (a.dopes LIKE '%RETORNO CONSERTO HS%' or a.dopes LIKE '%entrada CONSERTO HS%') and b.cpros IN ('AN02059', 'BR02045', 'BR02009', 'BR02067') 
order by b.cpros, a.datas DESC, a.numes DESC, b.citens ASC