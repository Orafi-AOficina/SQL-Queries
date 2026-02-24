-- Tabela dos balanços é a SigCdFcx!!!
SELECT DISTINCT DATEFROMPARTS(YEAR(A.datars),MONTH(A.datars), DAY(A.datars)) AS 'DATA_REF', A.datars AS 'DATA/HORA', A.cpros AS 'INSUMO', A.dopes AS 'OPERACAO',
	A.numes AS 'NUM_MOVIMENTO',
	(SELECT DISTINCT MIN(F.numes) FROM SigMvHst F WHERE A.estos = F.estos AND A.datars <= F.datars AND F.dopes = '') AS 'COD_BALANCO',
	A.opers AS 'TIPO', C.nops AS 'OP', D.cpros AS 'COD_PRODUTO', D.dpros AS 'DESC_PRODUTO',
	CASE
	WHEN A.opers LIKE 'S'
		THEN -A.qtds
	WHEN A.opers LIKE 'E'
		THEN A.qtds
	END AS 'QTD',
	A.estos AS 'COD_FUNCIONARIO', E.rclis AS 'NOME', A.grupos AS 'GRUPO', A.usuars AS 'RESP_MOV', C.tpops AS 'ETAPA',
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
	END AS 'STATUS', Convert(varchar(max), A.obs) AS 'OBSERVACAO'
FROM SigMvHst A (NOLOCK)
	LEFT JOIN SigCdNei C (NOLOCK) ON C.numps = A.numes AND A.dopes = C.dopps AND A.emps = C.emps AND A.cpros = C.cmats AND 
																			((A.dopes  = 'TRABALHADOS' AND A.qtds = C.qtds) OR A.dopes = 'TRABALHADOS S/ OP')
	LEFT JOIN SigOpPic D (NOLOCK) ON C.nops = D.nops --AND A.cpros = D.cpros
	LEFT JOIN SIGCDCLI E (NOLOCK) ON A.estos = E.iclis
WHERE (A.dopes = 'TRABALHADOS S/ OP   ' OR A.dopes  = 'TRABALHADOS         'OR A.dopes = 'FINALIZAÇÃO         ') AND A.cpros = 'AU750'
		AND A.datas >= '2019-01-01'-- AND E.inativas = 0 --AND A.numes = 13674-- AND A.datas <= '2019-02-10' 
		--AND C.tpops = 'OURIVESARIA.TRA'
		--AND A.estos = '0000000083' AND A.opers = 'S' AND A.datas <= '2020-09-23' --AND A.dopes = 'TRABALHADOS    ' 
ORDER BY A.datars DESC, A.opers ASC