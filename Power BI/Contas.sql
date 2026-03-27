--Contas de Estoque e Cadastro de Clientes do Sistema
--Contas do Sistema
SELECT RTRIM(A.grupos) AS 'GRUPO_CONTA', RTRIM(A.iclis) AS 'COD_CONTA', RTRIM(A.rclis) AS 'DESC_CONTA', RTRIM(A.razaos) AS 'CPF', RTRIM(REPLACE(REPLACE(A.razaos,'.',''),'-','')) AS 'CPF2',
				CASE WHEN A.inativas = 0 THEN 'ATIVA' ELSE 'INATIVA' END AS 'STATUS_CONTA', A.dataincs AS 'DATA_CADASTRO', A.dtalts AS 'DATA_ALT'
	FROM SigCdCli (NOLOCK) A
	ORDER BY A.inativas, A.rclis