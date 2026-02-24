SELECT A.cidchaves AS UKEY_PEDIDO, D.cidchaves AS UKEY_ITEMPEDIDO, A.datas AS DATA_ENTRADA, A.dopes AS TIPO_PEDIDO,
			A.mascnum AS PEDIDO, A.nops AS OP_MAE, D.nops AS OP, D.nopmaes AS OP_QUEBRADA, F.cpros AS COD_PRODUTO,
			F.dpros AS DESCRIÇAO, F.codcors AS COR, D.pesos/C.qtds AS PESO_INDIV_AU750, C.qtds AS QUANT_TOT,
			((SELECT SUM(X.totas) FROM SigMvItn X
				WHERE X.citem2 = C.citens AND X.numes = C.numes AND X.dopes = C.dopes) + C.totas) / A.vars AS VAL_UNIT,
			E.qtds AS QTD_BAIXADA,
			((SELECT SUM(X.totas) FROM SigMvItn X
				WHERE X.citem2 = C.citens AND X.numes = C.numes AND X.dopes = C.dopes) + C.totas) / A.vars * E.qtds AS VAL_ITEM,
			A.prazoents AS PRAZO_ENTREGA, A.valos AS VAL_TOTAL, A.valvars AS VAL_IMP, A.vars/100 AS PERCENT_IMP, A.obses, A.empdopnums
	FROM SigMvCab (NOLOCK) AS A
	INNER JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
	INNER JOIN SigOpPic (NOLOCK) D ON A.empdopnums = D.empdopnums AND C.cpros = D.cpros
	INNER JOIN SigCdPro (NOLOCK) F ON C.cpros = F.cpros
	INNER JOIN(select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, A.QTDS  
 				from sigpdmvf (NOLOCK) a
 				join ( select nops, MAX(cidchaves) as cidchaves from SigPdMvf (NOLOCK)
--					WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in( 'FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
	 				group by nops
 				) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves
 				where dopps <> SPACE(20) --
 				) E on D.nops = E.nops
--LEFT OUTER JOIN  DB_ORF_REL.dbo.SigOpPic IGOPPIC H WITH(NOLOCK) ON A.NOPS=H.NUMPS
-- AND LTRIM(CONVERT(NVARCHAR,C.OBS))=CONVERT(NVARCHAR,H.NOPS)
	--ADD EM 26062019 PARA TRAZER NUMERO SUFIXO OP
	WHERE A.datas > '2019-01-01'
	AND A.dopes IN('PEDIDO DE ENCOMENDA', 'PEDIDO DE FABRICA', 'PEDIDO DE PILOTO',
					'PEDIDO FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','ENTRADA CONSERTO')
	ORDER BY A.datas DESC, A.nops, D.nops