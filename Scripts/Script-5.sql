SELECT A.emps AS 'EMP', A.codbarras AS 'COD_BARRAS', A.nops AS 'OP', B.cpros AS 'COD_PRODUTO', B.dpros AS 'DESC_PRODUTO', A.qtds AS 'QTD', B.codcors AS 'COR',
		REPLACE(STRING_AGG(RTRIM(cc.SUBGRUPO) + ' ' + CAST(LEFT(cc.QTD_UNIT_INS, LEN(cc.QTD_UNIT_INS) - 3) as varchar) + RTRIM(cc.UN), ', ') + ' / ' + CAST(LEFT(dd.QTD_UNIT_IAU, LEN(dd.QTD_UNIT_IAU) - 3) as varchar) + ' GR', 'ROSÊ DE FRA', 'ROSÊ DE FRANCE') AS 'DESCRICAO_NF',
		CAST(LEFT(dd.QTD_UNIT_IAU, LEN(dd.QTD_UNIT_IAU) - 3) as varchar) + ' GR' AS 'DESCRICAO_NF_SO_IAU'
FROM SigOpPic (NOLOCK) A
	LEFT JOIN SIGCDPRO (NOLOCK) B ON A.cpros = B.cpros
	LEFT JOIN (SELECT O.codbarras AS 'codbarras', R.descricaos AS 'SUBGRUPO', SUM(O.qtds) AS 'QTD_TOT', 
						CASE WHEN R.descricaos = 'METAL' THEN 0 ELSE ROUND(SUM(O.qtds)/A.qtds, 3) END AS 'QTD_UNIT_INS', O.cunis AS 'UN'
		FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
			LEFT JOIN SigOpPic (NOLOCK) A ON O.codbarras = A.codbarras
			LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
			LEFT JOIN (SELECT DISTINCT CASE WHEN mercs IN ('PED') THEN cgrus ELSE 'IAU' END AS cgrus,
							CASE WHEN mercs IN ('PED') THEN  cgrus ELSE 'METAL' END AS codigos,
							CASE WHEN mercs IN ('PED', 'BRI') THEN RTRIM(dgrus) ELSE 'METAL' END AS descricaos
		FROM SigCdGrp (NOLOCK)) R ON P.cgrus = R.cgrus
		WHERE R.descricaos <> 'METAL' AND A.qtds > 0
		GROUP BY O.codbarras, R.descricaos, O.cunis, A.qtds) cc ON A.codbarras = cc.codbarras
	LEFT JOIN (SELECT O.codbarras AS 'codbarras', R.descricaos AS 'SUBGRUPO', SUM(O.qtds) AS 'QTD_TOT', 
						CASE WHEN R.descricaos = 'METAL' THEN ROUND(SUM(O.qtds)/A.qtds, 3) ELSE 0 END AS 'QTD_UNIT_IAU'
		FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
			LEFT JOIN SigOpPic (NOLOCK) A ON O.codbarras = A.codbarras
			LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
			LEFT JOIN (SELECT DISTINCT CASE WHEN mercs IN ('PED') THEN cgrus ELSE 'IAU' END AS cgrus,
							CASE WHEN mercs IN ('PED') THEN  cgrus ELSE 'METAL' END AS codigos,
							CASE WHEN mercs IN ('PED', 'BRI') THEN RTRIM(dgrus) ELSE 'METAL' END AS descricaos
		FROM SigCdGrp (NOLOCK)) R ON P.cgrus = R.cgrus
		WHERE R.descricaos = 'METAL' AND A.qtds > 0
		GROUP BY O.codbarras, R.descricaos, O.cunis, A.qtds) dd ON A.codbarras = dd.codbarras
	WHERE A.codbarras > 0 AND A.dataes > '01-06-2024' --AND A.qtds > 0
GROUP BY A.emps, A.codbarras, A.nops, B.cpros, B.dpros, A.qtds, B.codcors, dd.QTD_UNIT_IAU




SELECT O.codbarras AS 'codbarras', R.descricaos AS 'SUBGRUPO', SUM(O.qtds) AS 'QTD_TOT', 
						CASE WHEN R.descricaos = 'METAL' THEN 0 ELSE ROUND(SUM(O.qtds)/A.qtds, 3) END AS 'QTD_UNIT_INS', O.cunis AS 'UN'
		FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
			LEFT JOIN SigOpPic (NOLOCK) A ON O.codbarras = A.codbarras
			LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
			LEFT JOIN (SELECT DISTINCT CASE WHEN mercs IN ('PED') THEN cgrus ELSE 'IAU' END AS cgrus,
							CASE WHEN mercs IN ('PED') THEN  cgrus ELSE 'METAL' END AS codigos,
							CASE WHEN mercs IN ('PED', 'BRI') THEN RTRIM(dgrus) ELSE 'METAL' END AS descricaos
		FROM SigCdGrp (NOLOCK)) R ON P.cgrus = R.cgrus
		WHERE R.descricaos <> 'METAL' AND A.qtds > 0
		GROUP BY O.codbarras, R.descricaos, O.cunis, A.qtds











SELECT O.codbarras AS 'codbarras', R.descricaos AS 'SUBGRUPO', SUM(O.qtds) AS 'QTD_TOT', 
						CASE WHEN R.descricaos = 'METAL' THEN ROUND(SUM(O.qtds)/A.qtds, 3) ELSE 0 END AS 'QTD_UNIT_IAU'
		FROM sigsubmv O (NOLOCK) --ON A.codbarras = O.codbarras AND A.empdopnums = O.empdopnums
			LEFT JOIN SigOpPic (NOLOCK) A ON O.codbarras = A.codbarras
			LEFT JOIN SIGCDPRO P (NOLOCK) ON P.cpros = O.mats
			LEFT JOIN (SELECT DISTINCT CASE WHEN mercs IN ('PED') THEN cgrus ELSE 'IAU' END AS cgrus,
							CASE WHEN mercs IN ('PED') THEN  cgrus ELSE 'METAL' END AS codigos,
							CASE WHEN mercs IN ('PED', 'BRI') THEN RTRIM(dgrus) ELSE 'METAL' END AS descricaos
		FROM SigCdGrp (NOLOCK)) R ON R.cgrus = P.cgrus
		WHERE R.descricaos = 'METAL' AND A.qtds > 0
		GROUP BY O.codbarras, R.descricaos, O.cunis, A.qtds
		
		
SELECT DISTINCT CASE WHEN mercs IN ('PED') THEN dgrus ELSE 'IAU' END AS cgrus,
							CASE WHEN mercs IN ('PED') THEN  cgrus ELSE 'METAL' END AS codigos,
							CASE WHEN mercs IN ('PED', 'BRI') THEN RTRIM(dgrus) ELSE 'METAL' END AS descricaos
		FROM SigCdGrp (NOLOCK)
		
		
		
		
SELECT DISTINCT CASE WHEN cgrus IN ('PED', 'BRI', 'IMT') THEN cgrus ELSE 'IAU' END AS cgrus,
										CASE WHEN cgrus IN ('PED', 'BRI', 'IMT') THEN codigos ELSE 'METAL' END AS codigos,
										CASE WHEN cgrus IN ('PED', 'BRI') THEN RTRIM(descricaos) ELSE 'METAL' END AS descricaos
										FROM SigCdPsg (NOLOCK)
										
										
										
										
										
										
										
										
--ADICIONARO IDENTIFICADOR NO PRODUTO
--ADICIONADO MOEDA, GRANDE GRUPO E GRUPO NOS ITENS

select mercs as 'Grdgrupo',cgrus as 'Codgrpprod',dgrus as 'DescGrpprod',tipoestos 
--into db_stage_in.dbo.grupoproduto
from sigcdgrp with (nolock)

--GRUPO CONTAS
select classes,codigos as 'codgrpconta',descrs as 'Nomegrpconta' 
--into db_stage_in.dbo.Grupoconta
from sigcdgcr with (nolock)
where codigos in ('CLIENTE','ESTOQUE','FORNECEDOR')

--linhas
select linhas as 'Codlinha',descs as 'Nomelinha' 
--into db_stage_in.dbo.Linhas
from sigcdlin with (nolock)
where linhas='ANIMALE'

--Grupo de Venda
select  colecoes as 'Codgrpvenda',descs as 'Nomegrupovenda'  
--into db_stage_in.dbo.GrupoVenda
from sigcdcol with (nolock)
where colecoes in ('ANL','MCP','PCO','FEI') 

--Subgrupo
select cgrus,codigos as 'codsubgrupo',descricaos as 'nomesubgrupo' 
--into db_stage_in.dbo.Subgrupos
from sigcdpsg with (nolock)
where cgrus not in ('imt')

--Cadastro Contas
select dataincs,grupos as 'Grpconta',cpfs,rgs,iclis as 'Codconta',rclis as 'Nomeconta',razaos,endes,nums,bairs,ceps,cidas,estas,paises,ddds,tel1s,tel2s,emails
--into db_stage_in.dbo.Contas
from sigcdcli  with (nolock)
where iclis in ('C000001558', 'C000001643', 'F000000353','ESTOQUE','C000001628','C000001798') 


--PRODUTOS
--insert into db_stage_in.dbo.Produtos
--(ObsCompras,Desccompleta, DescCorSite,Codacabamento,Descacabamento,Complemento,Codmodelo,
--Descmodelo,Identificador,Codpro,cbars,Codgrpprod,Descricao,descritivo,Codsubgrp,Codclassfiscal,Custo,Moedacusto,
--Custotal,Moedacustototal,Marckup,codlinha,codgruvenda,unidade,datacad,imagprod,corprod,Codprodfor,Inativaprod,Codfor,
--TamProd,Grdgrupos,usuincs,pesocad)
select isnull(a.obscompras,space(10)) as 'ObsCompras', convert(varchar(40), a.dpro3s) as 'Desccompleta', 
case when LEN(d.DESC_SITE) > 5 THEN convert(varchar(100), d.DESC_SITE) else e.descs end as 'DescCorSite',
a.codacbs as 'Codacabamento',isnull(c.descrs,space(10)) as 'Descacabamento',a.obspeds as 'Complemento',
a.codfinp as 'Codmodelo',isnull(b.descs,space(10)) as 'Descmodelo',idecpros as 'Identificador',
cpros as 'Codpro',cbars as 'cbars',cgrus as 'Codgrpprod',dpros as 'Descricao',dpro2s as 'descritivo',sgrus as 'Codsubgrp',
clfiscals as 'Codclassfiscal',pcuss as 'Custo',moecs as 'Moedacusto',custofs as'Custotal',moecusfs as 'Moedacustototal',
margems  as 'Marckup', linhas as 'codlinha',colecoes as 'codgruvenda',cunis as 'unidade',
dtincs as 'datacad', figjpgs as 'imagprod',codcors as 'corprod',reffs as 'Codprodfor',situas as 'Inativaprod', 
convert(varchar(10),isnull(obscompras,space(10)))  as 'Codfor',isnull(codtams,space(10)) as 'TamProd',
mercs as 'Grdgrupos', usuincs as 'usuincs', pesoms as 'pesocad' 
from sigcdpro a with (nolock)
left outer join sigcdfip b with (nolock) on a.codfinp=b.cods
left outer join sigcdaca c with (nolock) on a.codacbs=c.cods
left outer join (SELECT DISTINCT aa.COD_PROD AS 'COD_PROD', LEFT(RTRIM(aa.COR) + ' COM ' + STRING_AGG(RTRIM(aa.SUBGRUPO), ' / '), 100) AS 'DESC_SITE'
					FROM (SELECT DISTINCT A.reffs, RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(F.descs) AS 'COR', RTRIM(E.dgrus) AS 'SUBGRUPO', A.datas
								FROM SigCdPro A with (NOLOCK)
										LEFT JOIN SIGPRCPO C with (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
										INNER JOIN (SELECT DISTINCT cpros, sgrus, cgrus FROM SigCdPro with (NOLOCK)) D ON C.mats = D.cpros
										LEFT JOIN  SigCdGrp E with (NOLOCK) ON E.cgrus = D.cgrus
										LEFT JOIN  SigCdCor F with (NOLOCK) ON A.codcors = F.cods
									WHERE E.mercs = 'PED') aa
					GROUP BY aa.COD_PROD, aa.DESC_PROD, aa.COR, aa.COR, aa.datas, aa.reffs) d on d.COD_PROD = a.cpros
left outer join SigCdCor e with (nolock) on a.codcors = e.cods
where colecoes in ('ANL','MCP','PCO','FEI') and d.DESC_SITE LIKE '%DIVERSO%' and dtincs > '2025-01-01'




--Cabeçalhos Movimentações
select compet as 'Mescolecao',codobs as 'EmpsIntegracao',datas as 'datamov',dtalts as 'dataalt',prazoents as 'Dataent',empdopnums as 'empnomenumemov',emps,dopes as 'nomemov',numes as 'numemov',notas as 'numesnfmov',grupoos as 'grporimov',contaos as 'contaorimov',grupods as 'grupodestmov',contads as 'contadsmov',usuars,valos as 'Total',VARS,VALVARS,obses as 'obsmov',npedclis as 'numemovcli',fpubls as 'repique'
into db_stage_in.dbo.Movcab
from sigmvcab with (nolock)
where contads in ('C000001558','F000000353','C000001628','C000001798', 'C000001643') and dopes in ('PEDIDO DE PILOTO','PEDIDO DE FABRICA','PEDIDO DE ENCOMENDA','PEDIDO DE ACRESC')    
order by datas


--Itens Movimentações
select b.empdopnums as 'empnomenumemov',b.citens as 'Citensmov',b.cpros as 'codpromov',b.qtds as 'qtdsmov',b.pesos as 'pesomov',b.units as 'unitmov',b.totas as 'totalmov',B.MOEDAS,B.VALRATS,c.mercs as 'Grdgrupos',
CASE WHEN C.MERCS='DIV'
THEN 'DIVERSOS'
	ELSE
CASE WHEN C.MERCS='INS'
THEN 'INSUMOS'
	ELSE
CASE WHEN C.MERCS='PA'
THEN 'PRODUTO ACABADO'
	ELSE 
CASE WHEN C.MERCS='SER'
THEN 'SERVICO'
END END END END AS 'DESC GRDGRUPO',										
c.cgrus as 'Codgrpprod'
into db_stage_in.dbo.Movitn
from sigmvcab a with (nolock)
inner join sigmvitn b with (nolock) on a.empdopnums=b.empdopnums
left join sigcdpro c (nolock) on b.cpros=c.cpros
where a.contads in ('C000001558', 'C000001643','F000000353','C000001628','C000001798')  
and a.dopes in ('PEDIDO DE PILOTO','PEDIDO DE FABRICA','PEDIDO DE ENCOMENDA','PEDIDO DE ACRESC')  
--AND A.empdopnums='ORFPEDIDO DE PILOTO    999999'  
                           

--Itens Movimentações cor e tamanho
select b.empdopnums as 'empnomenumemov',b.citens as 'Citensmov',b.cpros as 'codpromov',b.qtds as 'qtdsmov',b.pesos as 'pesomov',b.codcors as 'cormov',b.codtams as 'tammov'  
into db_stage_in.dbo.Movits 
from sigmvcab a with (nolock)
inner join sigmvits b with (nolock) on a.empdopnums=b.empdopnums
where a.contads in ('C000001558', 'C000001643', 'F000000353','C000001628','C000001798') 
ORDER BY B.CITENS

--parcelas
select b.empdopnums as 'empnomenumemov',b.vencs as 'datavenc', fpags  as 'fpagmov',b.valos as 'valparcelamov',b.moefpgs as 'moeparcelamov',parcs as 'Qtdparcelamov' 
into db_stage_in.dbo.Movpar
from sigmvcab a with (nolock)
inner join sigmvpar b with (nolock) on a.empdopnums=b.empdopnums
where a.contads in ('C000001558', 'C000001643', 'F000000353','C000001628','C000001798')


 --cabeçalhos excluidos
select dataexcl,empdopnums as 'empnomenumemov',emps,dopes as 'nomemov',numes as 'numemov',notas as 'numesnfmov',grupoos as 'grporimov',contaos as 'contaorimov',grupods as 'grupodestmov',contads as 'contadsmov',usuars,valos as 'Total',VARS,VALVARS 
into db_stage_in.dbo.Movexcab
from SigExMvc with (nolock)
where contads in ('C000001558', 'C000001643', 'F000000353','C000001628','C000001798') and dopes in ('PEDIDO DE PILOTO','PEDIDO DE FABRICA','PEDIDO DE ENCOMENDA','PEDIDO DE ACRESC')

--Cadastros produtos alterados.
select dataalts,usuaalts,idecpros as 'Identificador',cpros as 'Codpro',cbars,cgrus as 'Codgrpprod',dpros as 'Descricao',dpro2s as 'descritivo',sgrus as 'Codsubgrp',clfiscals as 'Codclassfiscal',pcuss as 'Custo',moecs as 'Moedacusto',custofs as'Custotal',moecusfs as 'Moedacustototal',margems  as 'Marckup',
pvens as 'Venda',moevs as 'Moedvenda', linhas as 'codlinha',colecoes as 'codgruvenda',cunis as 'unidade',
dtincs as 'datacad', figjpgs as 'imagprod',codcors as 'corprod',reffs as 'Codprodfor',situas as 'Inativaprod',ifors as 'Codfor',codtams as 'TamProd',
mercs as 'Grdgrupos', usuincs, pesoms as 'pesocad'  
into db_stage_in.dbo.prodalteracao
from sigcdprc with (nolock) where colecoes in ('ANL','MCP','PCO','FEI') and dataalts>'01-01-2018'
order by cpros,dataalts










SELECT a.empos AS 'EMP', a.dtincs AS 'DATA_FINALIZA', a.dtmovs AS 'ULT_MOVIMENTACAO', a.dopes AS 'OPERAÇÃO', a.numes AS 'NUM_OPERACAO', a.dopeos AS 'TIPO_PEDIDO', a.numeos AS 'NUM_PEDIDO', a.cbars AS 'COD_BARRAS',
					a.nops AS 'OP', d.colecoes AS 'GRUPO_VENDA', b.cpros AS 'COD_PRODUTO', d.reffs AS 'REF_CLIENTE', b.dpros AS 'DESCRICAO',
					d.matprincs AS 'MAT_PRINCIPAL', a.pesos AS 'PESO_TOTAL_METAL', a.peso2s as 'PESO_TOTAL_INSUMOS', a.pesos + a.peso2s AS 'PESO_TOTAL', a.pesoms AS 'PESO_TOTAL_CADASTRO',
					b.obss as 'OBS_OP',  g.cgrus AS 'GRP_INSUMO', f.mats AS 'COD_INSUMO', f.dpros AS 'INSUMO', f.qtds AS 'PESO', f.cunis AS 'UN', f.pesos AS 'QTD', f.cunips AS 'UN2'
FROM SIGOPETQ (nolock) a
	left join (select count(ee.codbarras) as 'NUM_COD_BARRAS', ee.nops from sigoppic (nolock) ee where ee.codbarras > 0 group by ee.nops) e on e.nops = a.nops
	left join sigoppic (nolock) b on a.nops = b.nops and (a.cbars = b.codbarras or e.NUM_COD_BARRAS = 1)
	left join sigcdcli (nolock) c on a.contas = c.iclis
	left join sigcdpro (nolock) d on a.cpros = d.cpros
	left join sigsubmv (nolock) f on a.cbars = f.codbarras
	left join sigcdpro (nolock) g on f.mats = g.cpros
where a.dtincs >= '01-01-2021'
order by a.dtincs DESC