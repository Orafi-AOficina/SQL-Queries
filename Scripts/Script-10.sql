SELECT RTRIM(A.emps) AS 'EMP', A.datars AS 'DATA-HORA', RTRIM(A.dopes) AS 'OPERACAO', A.mascnum+0 AS 'NUM_OP', RTRIM(A.grupoos) AS 'GRUPO_ORG',
	RTRIM(A.contaos) AS 'CONTA_ORG', RTRIM(C.rclis) AS 'NOME_ORG',
	RTRIM(A.grupods) AS 'GRUPO_DEST', RTRIM(A.contads) AS 'CONTA_DEST', RTRIM(D.rclis) AS 'NOME_DEST',
	RTRIM(F.cgrus) AS 'GRP_INS', RTRIM(F.cpros) AS 'COD_INS', RTRIM(F.dpros) AS 'DESC_INS', B.qtds AS 'QTD', RTRIM(B.cunis) AS 'UNIT_QTD', B.pesos AS 'QTD2', B.cunips AS 'UNIT_QTD2',
	RTRIM(A.usuars) AS 'RESPONSAVEL', Convert(varchar(max),A.obses) AS 'OBS SAIDA', 
	CASE 
        WHEN PATINDEX('%[0-9]%', A.obses) > 0 THEN
            CASE 
                WHEN SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 1) BETWEEN '1' AND '3' THEN
                    SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 5)
                WHEN SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 1) BETWEEN '4' AND '9' THEN
                    SUBSTRING(A.obses, PATINDEX('%[0-9]%', A.obses), 4)
                ELSE NULL
            END
        ELSE NULL
    END AS 'OP',
	A.empdopnums AS 'CHAVE_OPERACAO', Convert(varchar(max),B.obs) AS 'OBSERVACAO ITEM', B.*
FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
		LEFT JOIN SIGCDCLI (NOLOCK) C ON A.contaos = C.iclis
		LEFT JOIN SIGCDCLI (NOLOCK) D ON A.contads = D.iclis
		--LEFT JOIN SigCdPro (NOLOCK) E ON B.cpro2s = E.cpros
		LEFT JOIN SigCdPro (NOLOCK) F ON B.cpros = F.cpros
	WHERE A.datas >= '2020-01-01'
			AND A.dopes IN ('NF COMPRA MP', 'ENT COMPRA COM NF')
			-- 'PRE NF COMP MP FINAN', 
			--AND B.cpros = 'PED000011'
			--AND (A.contads= 'MATPRIMA' OR A.contaos = 'MATPRIMA')
	ORDER BY A.datars DESC, A.mascnum ASC, B.citens ASC
	
	
	
	
	
SELECT DISTINCT A.dopes, A.chkbxparcs
	FROM SigMvCab (NOLOCK) A
		LEFT JOIN SigMvItn (NOLOCK) B ON B.empdopnums = A.empdopnums
	WHERE A.dopes IN ('NF COMPRA MP', 'ENT COMPRA COM NF')
	
	
	
	
	
	
	
SELECT DISTINCT CONVERT(date, A.datas, 103) AS 'ENTRADA', B.rclis as 'CLIENTE', A.dopes as 'TIPO DE PEDIDO', D.NOPS AS 'OP_MAE', G.reffs AS 'REF_CLIENTE',
				C.CPROS AS 'PRODUTO', D.dpros AS 'DESCRIÇAO', G.codcors AS 'COR', C.qtds AS 'QTD_INI', CONVERT(date, A.prazoents, 103) AS 'PRAZO',
				CASE
					WHEN H.cpros LIKE 'RODIO%' THEN 'CUSTO_AU750'
					WHEN I.cgrus = 'INS' THEN 'IMT'
					WHEN I.cgrus = 'BR1' OR I.cgrus = 'BR2' THEN 'BRILHANTES'
					WHEN I.mercs = 'PED' THEN 'PEDRAS'
					WHEN I.cgrus = 'IMT' THEN 'IMT'
				END AS 'GRP_COMP',
				I.cpros AS 'COD_COMP', I.dpros AS 'DESC_COMP',
				CASE
					WHEN H.cpros LIKE 'RODIO%' THEN H.qtds*D.qtds/C.qtds
					WHEN I.cgrus = 'INS' THEN H.qtds*D.qtds/C.qtds
					WHEN I.cgrus = 'BR1' OR I.cgrus = 'BR2' THEN H.pesos*D.qtds/C.qtds
					WHEN I.mercs = 'PED' THEN H.pesos*D.qtds/C.qtds
					WHEN I.cgrus = 'IMT' THEN H.qtds*D.qtds/C.qtds
				END AS 'QTD_COMP',
				CASE
					WHEN I.cgrus LIKE '%IMT%' THEN 'G' ELSE 'UN'
				END AS 'UN', A.emps
	FROM SigMvCab A (NOLOCK)
		INNER JOIN SIGCDCLI B (NOLOCK) ON A.CONTADS = B.ICLIS
		INNER JOIN SigMvItn C (NOLOCK) ON A.EMPDOPNUMS = C.EMPDOPNUMS
		INNER JOIN SIGOPPIC D (NOLOCK) ON A.EMPDOPNUMS = D.EMPDOPNUMS AND C.cpros = D.cpros AND C.citens = D.citens AND D.qtds <> 0
	               INNER JOIN (select a.grupods, a.contads, a.grupoos, a.contaos, a.datas, a.numps, a.dopps, a.emps, a.nops, a.QTDS, a.empdnps
					from sigpdmvf a (NOLOCK)
					--	join (select nops, cidchaves as cidchaves
						join (select nops, MAX(cidchaves) as cidchaves
									from SigPdMvf (NOLOCK)
										WHERE nops NOT IN(SELECT DISTINCT NOPS FROM SIGPDMVF where dopps in
												('FINALIZAÇÃO','FINALIZA S INDUSTRIA','FINALIZA OP S/BARRA '))
										group by nops 
								) B ON A.nops = B.nops AND A.cidchaves = B.cidchaves 
	 					where dopps <> SPACE(20)
				) e on d.nops = e.nops
		LEFT JOIN SigCdPro G (NOLOCK) ON C.cpros = G.cpros
		LEFT JOIN SigMvItn H (NOLOCK) ON H.empdopnums = C.empdopnums AND (C.citens = H.citem2 OR (H.cpros = C.cpros AND C.citem2 = 0))
		LEFT JOIN SigCdPro I (NOLOCK) ON I.cpros = H.cpros
	WHERE A.dopes IN ('PEDIDO FABRICA','PEDIDO ENCOMENDA','PED FABRICA POF','PED ENCOMENDA POF','PEDIDO PILOTO','PEDIDO DE ENCOMENDA','PEDIDO DE FABRICA','PEDIDO DE PILOTO')
	 			AND A.datas >= '01-01-2023'
	 			AND D.nopmaes = 0
	 			AND LEFT(D.dpros,4) NOT IN ('TARR', 'MOSQ')
	 			AND (I.cgrus IN ('IMT', 'BRI', 'PED', 'INS') OR I.mercs = 'PED')
	GROUP BY A.dopes, B.rclis, D.nops, C.cpros, D.dpros, G.codcors, A.datas, A.prazoents , C.qtds, D.qtds, G.reffs, H.cpros, I.cgrus, H.qtds, H.pesos, I.cpros, I.dpros, A.emps, I.mercs
ORDER BY PRAZO DESC, OP_MAE









select  a.emps as Loja,a.dopes as Operação,a.numes as Numero,b.cpros as Cod_Produto, b.dpros as Produto, b.qtds as Qtds, b.cunis as Un1, b.pesos as Peso, b.cunips as Un2, a.datars as Data_Emp,e.empdopnums as Retorno,f.datars as Data_Retorno,
g.cpros as produto, g.qtds as Qtds,f.datas as Data_Ret, b.*
from sigmvcab a with(nolock)
inner join sigmvitn b with(nolock) on a.empdopnums=b.empdopnums
left join sigcdope d with(nolock) on a.dopes=d.dopes
left join sigmvpec e with(nolock) on a.emps=e.emps  and
								 right(e.codigos,6) = replicate('0',6-len(ltrim(rtrim(convert(varchar(6),a.numes)))))+ltrim(rtrim(convert(varchar(6),a.numes)))
								and d.ndopes = iif(len(e.codigos)=9,left(e.codigos,3),left(e.codigos,2)) and e.empdopnums like '%RET. EMPRESTIMO MP%'
left join sigmvcab f with(nolock) on f.empdopnums=e.empdopnums 
left join sigmvitn g with(nolock) on f.empdopnums=g.empdopnums
left join sigcdpro h with(nolock) on b.cpros = h.cpros
where a.dopes in ('TRF FILIAIS') OR (a.dopes in ('TRF EMPRESAS') AND A.emps IN ('ORF', 'RNG') AND A.empds IN ('ORF', 'RNG')) AND h.cgrus = 'IAU' order by 2