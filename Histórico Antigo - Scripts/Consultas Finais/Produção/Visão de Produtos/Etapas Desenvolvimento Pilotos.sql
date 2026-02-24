SELECT A.cgrus AS 'GRP_PROD', A.sgrus AS 'SUBGRP_PROD', A.cpros AS 'COD_PROD', A.reffs AS 'REF_CLIENTE', A.dpros AS 'DESC_PROD', A.codcors AS 'COR', A.dtincs AS 'DTE_INCLUSAO',
			A.datas AS 'ULT_ALTERACAO', A.markupa AS 'MARKUP', A.usuincs AS 'USUARIO_INC', A.codfinp AS 'COD_LINHA', E.descs AS 'LINHA', A.pesometal AS 'PESO_METAL', A.pesoms AS 'PESO_LIQ',
			A.codacbs AS 'ACABAMENTO', A.custofs AS 'VLR_CUSTO', A.cbars AS 'COD_BARRA', A.idpro AS 'ID',	A.dpro2s AS 'DESCRITIVO', A.dsccompras AS 'DESCRICAO_COMPRA',
			B.dtinis AS 'DTE_INICIO', B.dtfims AS 'DTE_FIM', B.tarefas AS 'COD_TAREFA', C.descads AS 'TAREFA', B.obstars AS 'OBSERVAÇÃO'
	FROM SigCdPro A (NOLOCK)
		INNER JOIN sigprtar B (NOLOCK) ON A.cpros = B.cpros
		INNER JOIN sigcdcad C (NOLOCK) ON B.tarefas = C.codcads
		LEFT JOIN SIGCDFIP E (NOLOCK) ON E.cods = A.codfinp
		LEFT JOIN SigCdGpr F (NOLOCK) ON A.mercs = F.codigos
	WHERE F.descs = 'PRODUTOS'