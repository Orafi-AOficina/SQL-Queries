select DISTINCT a.dopes as MOVIMENTO ,mascnum as CODIGO,Convert(varchar(max),a.obses) as empresa, B.rclis as CLIENTE,d.NOPS AS OP,C.CPROS AS PRODUTO, D.dpros AS DESCRIÇAO,A.PRAZOENTS AS ENTREGA,C.qtds AS QUANTIDADE, E.grupods AS STATUS,
 E.contads AS STATUS,E.qtds, E.DATAS--, *  
 from sigmvcab A
 INNER JOIN SIGCDCLI B ON A.CONTADS = B.ICLIS
 INNER JOIN SigMvItn C ON A.EMPDOPNUMS = C.EMPDOPNUMS
 INNER JOIN SIGOPPIC D ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros
 INNER JOIN( select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, A.QTDS  
 from sigpdmvf a
 join ( select nops, MAX(cidchaves) as cidchaves
 from SigPdMvf
 WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in( 'FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
 group by nops
 ) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves
 where dopps <> SPACE(20) --
 ) e on d.nops = e.nops
 where a.dopes IN ('pedido FABRICA','PEDIDO ENCOMENDA','PEDIDO PILOTO','Ped Acresc Producao','ENTRADA CONSERTO    ','PEDIDO DE ACRESC','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
 ORDER BY e.DATAS
