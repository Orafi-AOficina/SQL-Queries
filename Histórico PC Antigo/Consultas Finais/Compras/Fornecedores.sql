SELECT A.emps AS 'EMP', A.dataincs AS 'DT_CADASTRO', A.dtalts AS 'DT_ALTERACAO', A.grupos AS 'GRP_CONTA',  A.iclis AS 'COD_CONTA', A.rclis AS 'NOME FANTASIA', A.razaos AS 'RAZAO SOCIAL',
					A.cpfs AS 'CNPJ', A.rgs AS 'I.E.', A.endes AS 'ENDEREÇO', A.nums AS 'NUM', A.compls 'COMPLEMENTO', A.bairs AS 'BAIRRO', A.cidas AS 'CIDADE', A.estas AS 'ESTADO',
					A.paises AS 'PAÍS', A.ceps AS 'CEP', A.emails AS 'EMAILS', A.ddds AS 'DDD', A.tel1s AS 'TEL1', A.tel2s AS 'TEL2', A.tel3s AS 'TEL3',
					A.obs AS 'OBSERVAÇÃO', B.nbancos AS 'COD_BANCO', B.nagencias AS 'AGENCIA', B.contas AS 'CONTA'
FROM SIGCDCLI (NOLOCK) A
	LEFT JOIN SIGCDCEB (NOLOCK) B ON A.iclis = B.iclis
	--LEFT JOIN SIGCDCLL (NOLOCK) C ON A.iclis = C.iclis
	--SIGCDCLL
WHERE A.grupos = 'FORNECEDOR'
	--AND A.rclis LIKE '%DIOGO%'  --237   -  1856    - 6310796 
ORDER BY A.rclis ASC