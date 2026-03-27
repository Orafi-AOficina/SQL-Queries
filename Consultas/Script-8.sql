SELECT A.datas AS 'DATA', A.emps AS 'EMPRESA', A.dopes AS 'OPERACAO', A.numes AS 'NUM_OPERACAO', C.iclis AS 'COD_CONTA', C.rclis AS 'CLIENTE',
			A.usuars AS 'USUARIO', D.reffs AS 'REF_ANL', D.obscompras AS 'COR_ANL', D.idecpros AS 'ID_VARIACAO', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESCRICAO_PRODUTO', D.codcors AS 'COR', G.mercs AS 'GRANDE_GRP',
			G.cgrus AS 'GRUPO', F.cpros AS 'COD_INSUMO', F.dpros AS 'DESC_INSUMO', F.qtds AS 'QTD1', F.cunis AS 'UN1', F.pesos AS 'QTD2', F.moevs AS 'MOEDA',
			F.units, F.univals, F.totas AS 'VALOR LINHA', E.AU AS 'CUSTO_AU', E.US AS 'CUSTO_US', D.colecoes AS 'GRUPO_VENDA'
	FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON A.empdopnums = B.empdopnums
		LEFT JOIN SigMvItn (NOLOCK) F ON F.empdopnums = B.empdopnums AND B.citem2 = 0 AND (B.citens = F.citem2 OR B.citens = F.citens)
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contads = C.iclis
		LEFT JOIN SigCdPro (NOLOCK) D ON B.cpros = D.cpros
		LEFT JOIN (SELECT empdopnums, [US]+0 AS 'US', [AU]+0 AS 'AU'
							FROM ( SELECT empdopnums, moeds, moevals FROM SigMvMov (NOLOCK) WHERE DOPES = 'ORÇAMENTO') AS origem
							PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt) E ON E.empdopnums = A.empdopnums
		LEFT JOIN SigCdPro (NOLOCK) G ON G.cpros = F.cpros
	WHERE D.mercs = 'PA' AND A.dopes = 'ORÇAMENTO' AND A.datas > '01-01-2023' AND B.citem2 = 0 AND A.usuars = 'ANA' AND D.colecoes = 'ANL' AND D.reffs = '12.03.0327'
ORDER BY A.datas DESC, A.numes DESC, B.citens ASC




SELECT empdopnums, moeds, moevals FROM SigMvMov




(SELECT empdopnums, [US]+0 AS 'US', [AU]+0 AS 'AU'
FROM ( SELECT empdopnums, moeds, moevals FROM SigMvMov WHERE DOPES = 'ORÇAMENTO') AS origem
PIVOT (SUM(moevals) FOR moeds IN ([US], [AU])) AS pvt)









select CASE WHEN a.emps = 'ORF' THEN 'ORA' ELSE a.emps end as Empresa, a.dopes as Operação, a.numes as Num_Conserto, a.datas as Data_Entrada, a.prazoents as Prazo, RTRIM(K.iclis) AS 'COD_CLIENTE', RTRIM(K.rclis) AS 'CLIENTE', A.obses AS 'OBS_PEDIDO',
			a.dtbaixas as Data_Baixa, left(a.ultgrvs,26) as Baixa, b.citens AS COD_ITEM, b.cpros as Produto, j.dpros as Descricao, j.reffs as Ref_Cliente, b.qtds as Qtds, b.pesos as Peso_Total, c.codtams as Tamanho, (B.obs) AS Obs_Item,
			CASE WHEN b.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_ITEM',
			CASE WHEN a.chksubn = 0 THEN 'FALSO' ELSE 'VERDADEIRO' END AS 'BAIXA_PEDIDO', A.usuars as USUARIO
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
where a.dopes LIKE '%ENTRADA CONSERTO%'
order by a.datas DESC, a.numes DESC, b.citens ASC







SELECT DISTINCT A.emps AS 'EMPRESA', C.mercs AS 'GRANDE_GRP', B.cgrus AS 'GRUPO_INS', C.dgrus AS 'DESC_GRUPO', B.codcors AS 'COR', D.descs AS 'NOME_COR', B.cunis AS 'UN_PADRAO'
	FROM sigmvest A (NOLOCK)
		LEFT join sigcdpro B (NOLOCK) ON a.cpros = B.cpros
		LEFT JOIN SigCdGrp C (NOLOCK) ON B.cgrus = C.cgrus
		LEFT JOIN SigCdCor D (NOLOCK) ON B.codcors = D.cods
	WHERE (A.SQTDS <> 0 OR A.spesos <> 0)
			AND (A.emps = 'ORA' OR A.emps = 'RNG') AND C.mercs <> 'PA'
	ORDER BY A.emps, B.cgrus, B.codcors
	
	
	
	
	
SELECT DISTINCT a.emps AS 'EMPRESA', a.grupos AS 'GRP_ESTOQUE', D.grupos AS 'GRP_CONTA', D.iclis AS 'COD_CONTA', D.RCLIS AS 'NOME_CONTA', --MAX(E.datas) AS 'DT_BALANÇO',
	B.mercs AS 'GRANDE_GRP', b.cgrus AS 'GRUPO_INS', F.dgrus AS 'NOME_GRUPO', C.CODIGOS AS 'SUBGRUPO_INS',
	b.cpros AS 'COD_INSUMO',B.DPROS AS 'DESC_INSUMO', B.codcors AS 'COR', A.SQTDS AS 'SALDO', B.CUNIS AS 'UN', A.spesos AS 'QTD', B.cunips AS 'UN_QTD', B.custofs AS 'CUSTO_EST', B.moedas AS 'MOEDA',
		CASE
			WHEN D.inativas = 1 THEN 'INATIVA'
			WHEN D.inativas = 0 THEN 'ATIVA'
			ELSE 'VERIFICAR'
		END AS 'STATUS'
		(SELECT MAX(aa.datars) FROM SigMvCab (NOLOCK) aa INNER JOIN SigMvItn (NOLOCK) bb ON bb.empdopnums = aa.empdopnums
							WHERE aa.emps = A.emps
									AND bb.cpros = b.cpros
									AND aa.grupoos = D.grupos  
									AND aa.contaos = D.iclis) AS 'ULT SAIDA NA CONTA',
		(SELECT MAX(aa.datars) FROM SigMvCab (NOLOCK) aa INNER JOIN SigMvItn (NOLOCK) bb ON bb.empdopnums = aa.empdopnums
							WHERE aa.emps = A.emps
									AND bb.cpros = b.cpros
									AND aa.grupods = D.grupos  
									AND aa.contads = D.iclis) AS 'ULT ENTRADA NA CONTA',
		(SELECT MAX(aa.datars) FROM SigMvCab (NOLOCK) aa INNER JOIN SigMvItn (NOLOCK) bb ON bb.empdopnums = aa.empdopnums
							WHERE aa.emps = A.emps
									AND bb.cpros = b.cpros) AS 'ULT MOV NA EMPRESA'
	FROM sigmvest A (NOLOCK)
		LEFT join sigcdpro B (NOLOCK) ON a.cpros = B.cpros
		LEFT JOIN SIGCDPSG C (NOLOCK) ON B.CGRUS = C.CGRUS and B.sgrus = C.codigos
		LEFT JOIN SIGCDCLI D (NOLOCK) ON A.ESTOS = D.ICLIS
		LEFT JOIN SigCdGrp F (NOLOCK) ON B.cgrus = F.cgrus
	WHERE (A.SQTDS <> 0 OR A.spesos <> 0)
                                   AND (A.emps = 'ORA' OR A.emps = 'RNG')
	ORDER BY A.grupos, D.iclis, B.dpros, A.emps
	
	
	
SELECT emps, dopes, COUNT(numes), MIN(DATAS), MAX(DATAS) FROM sigmvcab (nolock)
where dopes IN ('PEDIDO ESTOQUE', 'PEDIDO DE PILOTO', 'PEDIDO DE FABRICA', 'PED FABRICA POF', 'PEDIDO DE ENCOMENDA', 'PED ENCOMENDA POF')
GROUP BY EMPS, DOPES