-- Tabela dos balanços é a SigCdFcx!!!
SELECT B.datas AS 'DATA/HORA', C.cmats AS 'INSUMO', B.dopps AS 'OPERACAO', B.numps AS 'NUM_MOVIMENTO', --A.opers AS 'TIPO', 
	C.nops AS 'OP', D.cpros AS 'COD_INSUMO', D.dpros AS 'DESC_INSUMO',
--	CASE WHEN A.opers LIKE 'S' THEN -A.qtds
--		WHEN A.opers LIKE 'E' THEN A.qtds END AS 'QTD',
	B.totpesos AS 'PESOS_TOTAL', C.pesos AS 'PESOS', C.qtds AS 'QTD', 
	B.grupoos AS 'GRUPO_ORIGEM', E.iclis AS 'COD ORIGEM', E.rclis AS 'CONTA ORIGEM', (SELECT DISTINCT MIN(G.numes) FROM SigMvHst G WHERE E.iclis = G.estos AND B.datars < G.datars AND G.dopes = '') AS 'BALANCO_ORIGEM',
	B.grupods AS 'GRUPO_DESTINO', F.iclis AS 'COD DESTINO', F.rclis AS 'CONTA DESTINO', (SELECT DISTINCT MIN(H.numes) FROM SigMvHst H WHERE F.iclis = H.estos AND B.datars < H.datars AND H.dopes = '') AS 'BALANCO_DESTINO',
	B.usuars AS 'RESP_MOV', C.tpops AS 'ETAPA',
	CASE 
		WHEN C.tpops = 'OURIVESARIA.TRA' THEN 'OURIVESARI'
		WHEN C.tpops = 'ENVIO MATERIAL' OR C.tpops = 'DEVOL MATERIAL' THEN 'FUNDICAO'
		WHEN C.tpops = 'CRAVACAO.TRAB' THEN 'CRAVAÇÃO'
		WHEN C.tpops = 'POLIMENTO.TRAB' OR C.tpops = 'PRE-POLIMENTO' THEN 'POLIMENTO'
		ELSE 'OUTROS'
	END AS 'GRUPO_BALANÇO',
	CASE
		WHEN E.inativas = 1 THEN 'INATIVA'
		WHEN E.inativas = 0 THEN 'ATIVA'
		ELSE 'VERIFICAR'
	END AS 'STATUS',
	B.obss AS 'OBSERVACAO'
--FROM SigMvHst A (NOLOCK)
FROM SigCdNei C (NOLOCK) --ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps AND A.cpros = C.cmats
	LEFT JOIN SigCdNec B (NOLOCK) ON C.empdnps = B.empdnps
	LEFT JOIN SigCdPro D (NOLOCK) ON C.cmats = D.cpros
	LEFT JOIN SIGCDCLI E (NOLOCK) ON B.contaos = E.iclis
	LEFT JOIN SIGCDCLI F (NOLOCK) ON B.contads = F.iclis
WHERE B.dopps = 'TRABALHADOS S/ OP   '
		AND B.datas >= '2019-07-01' --AND A.numes = 13674-- AND A.datas <= '2019-02-10'
		--AND A.estos = '0000000142'
	--GROUP BY A.datas, A.qtds, A.cpros, A.dopes, A.numes, A.estos, A.datars , A.opers, C.nops, D.cpros, D.dpros, C.pesos, C.qtds, E.rclis, A.grupos, A.usuars , E.inativas --, A.obs, C.tpops ,
ORDER BY B.datas DESC