SELECT DISTINCT A.empdopnums AS 'Saída_Produção', B.empdopnums AS 'Aceite', G.cgrus AS 'Grp_Insumo', G.cpros AS 'Cód_Insumo', G.dpros AS 'Desc_Insumo',
			C.pesos AS 'QTD_UNID', C.qtds AS 'Qtd_Total', C.cunis AS 'Unidade', C.qtbaixas AS 'Qtd_Baixada', J.numes AS 'PEDIDO', J.numps AS 'OP_PEDIDO', J.nops AS 'OP_MAE',
			C.cpro2s AS 'Cod_Produto', E.dpros AS 'Desc_Produto',
			A.datars AS 'Data_Saída', A.usuars AS 'Usuário_Saída', H.datars AS 'Data_Aceite', H.usuars AS 'Usuário_Aceite',
			I.OP AS 'OP_OBS', Convert(varchar(max),A.obses) as 'OBSERVAÇÃO'
	FROM SigMvCab (NOLOCK) A
		LEFT JOIN SIGBXEST (NOLOCK) B ON B.empdopnumb = A.empdopnums
		LEFT JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
		LEFT JOIN SigMvItn (NOLOCK) D ON B.empdopnums = D.empdopnums
		LEFT JOIN SigCdPro (NOLOCK) E ON E.cpros = C.cpro2s
		LEFT JOIN SigCdPro (NOLOCK) G ON G.cpros = C.cpros
		LEFT JOIN SigMvCab (NOLOCK) H ON H.empdopnums = B.empdopnums
		LEFT JOIN (SELECT E.empdopnums, LEFT(REPLACE(
												REPLACE(
														REPLACE(
																REPLACE(
																		REPLACE( 
																				REPLACE(Convert(varchar(max),E.obses), ' ',''),'[',''),';',''),':',''),'OP', '' ),']',''),4) AS 'OP'
						FROM SigMvCab (NOLOCK) E
							WHERE E.dopes = 'SAIDA PRODUCAO      ' OR E.dopes = 'SAIDA PRODUCAO TOTAL'
						) I ON A.empdopnums = I.empdopnums
		LEFT JOIN SigOpPic (NOLOCK) J ON LEFT(J.nops, 4) = I.OP AND J.nopmaes=0 AND REPLACE(J.cpros, RTRIM(C.cpro2s), '') <> J.cpros --AND B.cpro2s = G.cpros
	WHERE A.datas >=  GETDATE() - 45 --'2020-01-01'
		AND (A.dopes = 'SAIDA PRODUCAO      ' OR A.dopes = 'SAIDA PRODUCAO TOTAL')
--		AND G.cpros = 'PED000008'
--		AND A.mascnum IN (13148, 13153, 13154, 13165, 13166, 13214, 13215, 13239, 13241, 13255, 13286, 13300, 13303, 13338, 13393, 13408, 13445, 13458, 13460, 13464, 13468, 13492, 13504, 13506, 13580, 13597, 13613, 13614, 13620, 13644, 13675, 13708, 13751, 13756, 13772, 13795, 13810, 13811, 13820, 13851, 13856, 13886, 13894, 13896, 13899, 13932, 13935, 13957, 13961, 13989, 13990, 14010, 14023, 14027, 14029, 14031, 14038, 14043, 14045, 14046, 14060, 14064, 14073, 14079, 14100, 14119, 14122, 14135, 14154, 14163, 14182, 14194, 14221, 14224, 14257, 14286, 14292, 14314, 14319, 14330, 14345, 14362, 14391, 14392, 14395, 14396, 14421, 14427, 14434, 14439, 14440, 14443, 14465, 14467)
	ORDER BY H.datars, A.datars DESC