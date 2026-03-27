SELECT A.emps + A.notas AS 'CHAVE', A.EMPDOPNUMS AS 'CHAVE_MAE', A.emps AS 'EMPRESA', DATEFROMPARTS(YEAR(A.datas),MONTH(A.datas), 1) AS 'DATA_REF',
	A.datas AS 'DATA_NF', O.datas AS 'DT_ENTRADA', O.prazoents AS 'PRAZO', A.notas AS 'NUM_NF', A.DOPES AS 'OPERACAO', A.NUMES AS 'NUM_OPS',
	CASE 
		WHEN A.dopes IN ('ENVIO ROMANEIO', 'NF VENDA', 'NF VENDA PILOTO', 'NF RET INDUSTRIALIZA', 'NF DEVOLUÇÃO COMPRA.', 'DV ASS. TEC. C.CUSTO') THEN J.rclis
			ELSE F.RCLIS
	END AS 'CLIENTE',
	L.dopes AS 'TIPO_PEDIDO', L.numes AS 'PEDIDO', O.compet AS 'MES_ANL', L.numps AS 'OP_GERAL', K.nops AS 'OP', M.codbarras AS 'CODIGO_BARRAS', G.stats AS 'STATUS',
	D.cpros AS 'COD_PROD', D.reffs AS 'REF_ANL', D.dpros AS 'DESCRICAO', D.codcors AS 'COR', C.QTDS AS 'QTD', C.QTBAIXAS AS 'QTD BAIXADA', C.UNITS AS 'VALOR_UNIT', C.units*C.qtds AS 'VALOR_PROD', C.valipis AS 'IPI',
	--SUM(C.QTDS*C.UNITS + C.valipis) AS 'VALOR_TOTAL', C.valdescs AS 'DESCONTO',-- C.aliqicms, C.baseicms, C.aliqs , C.bcipis, C.icms, C.baseip, C.vpis , C.aliqpis , C.vcofins , C.aliqcofs , C.valbases , C.cfops,
	CAST(A.obses AS varchar(max)) AS 'OBSERVÇÃO', N.empdncrds AS 'FINALIZACAO', P.datalts AS 'Lançamento', P.valors as 'Valor_Original', P.opers AS 'Tipo', P.saldos AS 'Saldo Conta', P.saldons, P.hists as 'Hist1', P.hist2s as 'Hist2',
	P.scontas AS 'Conta Relacionada', P.*
FROM SigMvCab A (NOLOCK)
	LEFT JOIN SigCdOpe B (NOLOCK) ON A.DOPES=B.DOPES
	LEFT JOIN SIGMVITN C (NOLOCK) ON A.EMPDOPNUMS=C.EMPDOPNUMS
	LEFT JOIN SIGCDPRO D (NOLOCK) ON C.CPROS=D.CPROS	
	LEFT JOIN SIGCDGRP E (NOLOCK) ON D.CGRUS=E.cgrus
	LEFT JOIN SIGCDCLI F (NOLOCK) ON A.CONTAOS=F.ICLIS
	LEFT JOIN SIGPRNFE G (NOLOCK) ON A.EMPDOPNUMS=G.EMPDOPNUMS AND G.datas = (SELECT MAX(I.datas) FROM sigprnfe I WHERE A.EMPDOPNUMS=I.EMPDOPNUMS GROUP BY I.empdopnums)
	LEFT JOIN SIGOPPIC H (NOLOCK) ON A.NOPS=H.NUMPS AND LTRIM(CONVERT(NVARCHAR,C.OBS))=CONVERT(NVARCHAR,H.NOPS)
	LEFT JOIN SIGCDCLI J (NOLOCK) ON A.contads=J.ICLIS
	LEFT JOIN SigMvItn M (NOLOCK) ON C.codbarras = M.codbarras AND C.cpros = M.cpros AND M.dopes = 'FINALIZA NACIONAL'
	LEFT JOIN SigMvCab N (NOLOCK) ON M.empdopnums = N.empdopnums
	LEFT JOIN SigPdMvf K (NOLOCK) ON REPLACE(N.empdncrds, ' ','') = REPLACE(K.empdnps, ' ', '')
	LEFT JOIN SigOpPic L (NOLOCK) ON L.nops = K.nops AND M.codbarras = L.codbarras
	LEFT JOIN SigMvCab O (NOLOCK) ON O.empdopnums = L.empdopnums AND O.dopes IN ('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO', 'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
	LEFT JOIN SIgMvCcr P (NOLOCK) ON P.empdopnums = A.empdopnums
WHERE A.DOPES IN ('NF RET INDUSTRIALIZA', 'NF VENDA', 'NF VENDA PILOTO', 'DV ASS. TEC. C.CUSTO', 'ENVIO ROMANEIO',
			'NF DEVOLUÇÃO COMPRA', 'NF DEVOLUÇÃO COMPRA.', 'ADIANTA MP FINANC', 'DEV RESUMO ENT PEDRA',
			'NF RET PURIFICAÇÃO', 'NF ENT INDUSTRIA')
	AND C.citem2 = 0
	AND A.datas >='2018-12-01'
	AND (G.stats NOT LIKE '' OR G.stats IS NULL OR G.stats = '   ')
	AND J.rclis LIKE '%PARTICULAR%'
	--AND Q.opers='D'
	--AND Q.grupos not in ('61')  
	--AND A.notas = '008094'
	--AND L.numps = 7005
--GROUP BY A.cidchaves, A.notas, A.dopes, A.numes, F.rclis, A.nops, A.datas, A.emps, A.empdopnums, CAST(A.obses AS varchar(max)), J.rclis,
--				L.dopes, L.numes, L.numps, G.stats, M.codbarras , N.empdncrds, D.cpros, D.reffs, D.dpros, D.codcors , L.citens, K.nops, C.qtds , 
--				C.qtbaixas, C.units, C.valipis, C.valdescs , N.datas , O.compet , O.datas , O.prazoents 
ORDER BY A.datas DESC, A.notas ASC, L.numps ASC, A.DOPES ASC