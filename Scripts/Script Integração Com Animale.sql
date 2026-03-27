--ADICIONARO IDENTIFICADOR NO PRODUTO
--ADICIONADO MOEDA, GRANDE GRUPO E GRUPO NOS ITENS
USE [DB_STAGE_IN]

GO


if exists(select * from sys.objects where name = 'grupoproduto')
	drop table grupoproduto
	

--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'grupoconta')
	drop table grupoconta
	
--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'linhas')
	drop table linhas
	
--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'grupovenda')
	drop table grupovenda

--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'subgrupos')
	drop table subgrupos

--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'contas')
	drop table contas

--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'produtos')
	delete from produtos
	
--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'movcab')
	drop table movcab
	
--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'movitn')
	drop table movitn

--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'movits')
	drop table movits

--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'movpar')
	drop table movpar
	
--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'Movexcab')
	drop table Movexcab
	
--CHECK EXISTENCIA TABELA E EXCLUSÃO
if exists(select * from sys.objects where name = 'prodalteracao')
	drop table prodalteracao
	
--select * from controle
--INSERINDO DATA DA ULTIMA CARGA
insert into controle (dtprocessamentoin,usuaprocessain,dtprocessamentoout,usuaprocessaout) values (getdate(), '4CONTROL','','')

--INSERÇÕES EM TABELAS STAGES


USE [DB_ORF]

GO

select mercs as 'Grdgrupo',cgrus as 'Codgrpprod',dgrus as 'DescGrpprod',tipoestos 
into db_stage_in.dbo.grupoproduto
from sigcdgrp with (nolock)

--GRUPO CONTAS
select classes,codigos as 'codgrpconta',descrs as 'Nomegrpconta' 
into db_stage_in.dbo.Grupoconta
from sigcdgcr with (nolock)
where codigos in ('CLIENTE','ESTOQUE','FORNECEDOR')

--linhas
select linhas as 'Codlinha',descs as 'Nomelinha' 
into db_stage_in.dbo.Linhas
from sigcdlin with (nolock)
where linhas='ANIMALE'

--Grupo de Venda
select  colecoes as 'Codgrpvenda',descs as 'Nomegrupovenda'  
into db_stage_in.dbo.GrupoVenda
from sigcdcol with (nolock)
where colecoes in ('ANL','MCP','PCO','FEI') 

--Subgrupo
select cgrus,codigos as 'codsubgrupo',descricaos as 'nomesubgrupo' 
into db_stage_in.dbo.Subgrupos
from sigcdpsg with (nolock)
where cgrus not in ('imt')

--Cadastro Contas
select dataincs,grupos as 'Grpconta',cpfs,rgs,iclis as 'Codconta',rclis as 'Nomeconta',razaos,endes,nums,bairs,ceps,cidas,estas,paises,ddds,tel1s,tel2s,emails
into db_stage_in.dbo.Contas
from sigcdcli  with (nolock)
where iclis in ('C000001558', 'C000001643', 'F000000353','ESTOQUE','C000001628','C000001798') 


--PRODUTOS
insert into db_stage_in.dbo.Produtos
(ObsCompras,Desccompleta, DescCorSite,Codacabamento,Descacabamento,Complemento,Codmodelo,
Descmodelo,Identificador,Codpro,cbars,Codgrpprod,Descricao,descritivo,Codsubgrp,Codclassfiscal,Custo,Moedacusto,
Custotal,Moedacustototal,Marckup,codlinha,codgruvenda,unidade,datacad,imagprod,corprod,Codprodfor,Inativaprod,Codfor,
TamProd,Grdgrupos,usuincs,pesocad)
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
					FROM (SELECT DISTINCT A.reffs, RTRIM(A.cpros) AS 'COD_PROD', RTRIM(A.dpros) AS 'DESC_PROD', RTRIM(F.descs) AS 'COR', RTRIM(E.descricaos) AS 'SUBGRUPO', A.datas
								FROM SigCdPro A with (NOLOCK)
										LEFT JOIN SIGPRCPO C with (NOLOCK) ON A.cpros = C.cpros --AND C.mats = I.mats
										INNER JOIN (SELECT DISTINCT cpros, sgrus, cgrus FROM SigCdPro with (NOLOCK)) D ON C.mats = D.cpros
										LEFT JOIN  SigCdPsg E with (NOLOCK) ON E.codigos = D.sgrus
										LEFT JOIN  SigCdCor F with (NOLOCK) ON A.codcors = F.cods
									WHERE A.mercs = 'PA' AND D.cgrus IN ('PED', 'BRI')) aa
					GROUP BY aa.COD_PROD, aa.DESC_PROD, aa.COR, aa.COR, aa.datas, aa.reffs) d on d.COD_PROD = a.cpros
left outer join SigCdCor e with (nolock) on a.codcors = e.cods
where colecoes in ('ANL','MCP','PCO','FEI') and a.cproeqs = ''



--Cabeçalhos Movimentações
select compet as 'Mescolecao',codobs as 'EmpsIntegracao',datas as 'datamov',dtalts as 'dataalt',prazoents as 'Dataent',empdopnums as 'empnomenumemov',emps,dopes as 'nomemov',numes as 'numemov',notas as 'numesnfmov',grupoos as 'grporimov',contaos as 'contaorimov',grupods as 'grupodestmov',contads as 'contadsmov',usuars,valos as 'Total',VARS,VALVARS,obses as 'obsmov',npedclis as 'numemovcli',fpubls as 'repique'
into db_stage_in.dbo.Movcab
from sigmvcab with (nolock)
where contads in ('C000001558','F000000353','C000001628','C000001798', 'C000001643') and dopes in ('PEDIDO DE PILOTO','PEDIDO DE FABRICA','PEDIDO DE ENCOMENDA','PEDIDO DE ACRESC')    
order by datas


--Itens Movimentações
select b.empdopnums as 'empnomenumemov',b.citens as 'Citensmov', CASE WHEN c.cproeqs = '' THEN b.cpros ELSE d.cpros END as 'codpromov',b.qtds as 'qtdsmov',b.pesos as 'pesomov',b.units as 'unitmov',
			b.totas as 'totalmov',B.MOEDAS,B.VALRATS,c.mercs as 'Grdgrupos',
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
left outer join SigCdPro d with (nolock) on c.cproeqs = d.cpros
where a.contads in ('C000001558', 'C000001643','F000000353','C000001628','C000001798')  
and a.dopes in ('PEDIDO DE PILOTO','PEDIDO DE FABRICA','PEDIDO DE ENCOMENDA','PEDIDO DE ACRESC')  
                           

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
select a.dataalts, a.usuaalts, a.idecpros as 'Identificador', a.cpros as 'Codpro', a.cbars, a.cgrus as 'Codgrpprod', a.dpros as 'Descricao', a.dpro2s as 'descritivo', a.sgrus as 'Codsubgrp',
			a.clfiscals as 'Codclassfiscal', a.pcuss as 'Custo', a.moecs as 'Moedacusto', a.custofs as'Custotal', a.moecusfs as 'Moedacustototal', a.margems  as 'Marckup',
			a.pvens as 'Venda', a.moevs as 'Moedvenda', a.linhas as 'codlinha', a.colecoes as 'codgruvenda', a.cunis as 'unidade',
			a.dtincs as 'datacad', a.figjpgs as 'imagprod', a.codcors as 'corprod', a.reffs as 'Codprodfor', a.situas as 'Inativaprod', a.ifors as 'Codfor', a.codtams as 'TamProd',
			a.mercs as 'Grdgrupos', a.usuincs, a.pesoms as 'pesocad'  
into db_stage_in.dbo.prodalteracao
from sigcdprc a with (nolock)
	left outer join SigCdPro b with (nolock) on b.cpros = a.cpros
where a.colecoes in ('ANL','MCP','PCO','FEI') and a.dataalts>'01-01-2018' and b.cproeqs = ''
order by a.dataalts DESC, a.cpros
