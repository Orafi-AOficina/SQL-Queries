--Balanço consolidado pela QTD de trabalho feita para cada um dos itens movimentados
SELECT RTRIM(A.emps) AS 'EMP', A.codigos AS 'BALANCO', RTRIM(A.emps) + '_' + CAST(A.codigos as varchar) AS 'CHAVE_BALANCO', RTRIM(A.cpros) AS 'COD_INSUMO', RTRIM(A.tpops) AS 'OPERACAO',
				A.pfalhas AS 'PERCENT_FALHA', A.pesoents AS 'PESO_ENT', A.pesosais AS 'PESO_SAI',
				A.pesobsais AS 'PESO_BASE_SAI', A.falhas AS 'FALHA_ADMITIDA', A.pesos AS 'QTD_ADMITIDA', RTRIM(A.tpops) +  RTRIM(A.cpros) AS 'CHAVE_CONFIGFALHA', RTRIM(A.emps) + '_' + CAST(A.codigos as varchar) + '_' + RTRIM(A.cpros) AS 'CHAVE_BALANCO_INSUMO'
FROM SigCdFes (NOLOCK) A
ORDER BY A.codigos DESC, A.tpops, A.cpros