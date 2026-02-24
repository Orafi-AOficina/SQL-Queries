select a.dopes as MOVIMENTO,Convert(varchar(max),a.obses) as empresa, B.rclis as CLIENTE,d.NOPS AS OP, C.CPROS AS PRODUTO, 
			D.dpros AS DESCRIÇAO, A.PRAZOENTS AS ENTREGA ,C.qtds AS QUANTIDADE, E.grupods AS STATUS,
			E.contads AS STATUS2,f.rclis,E.qtds, E.DATAS, C.*
from sigmvcab A
INNER JOIN SIGCDCLI B ON A.CONTADS = B.ICLIS
INNER JOIN SigMvItn C ON A.EMPDOPNUMS = C.EMPDOPNUMS
INNER JOIN SIGOPPIC D ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros 
INNER JOIN (select a.* --a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, A.QTDS
				from sigpdmvf a
					join (select nops, cidchaves as cidchaves 
								from SigPdMvf 
							--		WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
								--			('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA ')and datas >=01/01/2018)
									--group by nops
							) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
					where dopps <> SPACE(20) --
			) e on d.nops = e.nops
LEFT JOIN sigcdcli F on e.contads = F.iclis
where a.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','PED ACRESC PRODUCAO ','ENTRADA CONSERTO','ENTRADA CONSERTO    ',
			'PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
AND D.nops = 67200016
ORDER BY e.DATAS