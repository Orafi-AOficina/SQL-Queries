SELECT F.Saída_Produção, F.Aceite, F.Cód_Insumo, F.Desc_Insumo, F.Unidade, F.QTD_UNID, F.Qtd_Total, F.Qtd_Baixada, F.Cod_Produto,
	F.Desc_Produto, F.Data_Saída, F.Usuário_Saída, F.Data_Aceite, F.Usuário_Aceite, G.obses AS 'Observação', F.Custo
FROM (SELECT DISTINCT A.empdopnums AS 'Saída_Produção', B.empdopnums AS 'Aceite', C.cpros AS 'Cód_Insumo', C.dpros AS 'Desc_Insumo',
			C.cunis AS 'Unidade', C.pesos AS 'QTD_UNID', C.qtds AS 'Qtd_Total', C.qtbaixas AS 'Qtd_Baixada', C.cpro2s AS 'Cod_Produto', E.dpros AS 'Desc_Produto',
			A.datars AS 'Data_Saída', A.usuars AS 'Usuário_Saída', H.datars AS 'Data_Aceite', H.usuars AS 'Usuário_Aceite',
			A.cidchaves, E.custofs AS 'Custo' --A.obses AS 'Observação', 
		FROM SigMvCab (NOLOCK) A
			LEFT JOIN SIGBXEST (NOLOCK) B ON B.empdopnumb = A.empdopnums
			LEFT JOIN SigMvItn (NOLOCK) C ON A.empdopnums = C.empdopnums
			LEFT JOIN SigMvItn (NOLOCK) D ON B.empdopnums = D.empdopnums
			LEFT JOIN SigCdPro (NOLOCK) E ON E.cpros = C.cpro2s
			LEFT JOIN SigMvCab (NOLOCK) H ON H.empdopnums = B.empdopnums
		WHERE A.datas >= '2019-01-01' AND (A.dopes = 'SAIDA PRODUCAO      ' OR A.dopes = 'SAIDA PRODUCAO TOTAL')
		) F
	LEFT JOIN SigMvCab (NOLOCK) G ON F.cidchaves = G.cidchaves
ORDER BY F.Data_Saída DESC, F.Saída_Produção ASC