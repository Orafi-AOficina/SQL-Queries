-- ============================================
-- Nome: NF_Venda_Futura_Com_Pendencias.sql
-- Descrição: Relação de operações NF VENDA FUTURA com pendência da operação anterior
-- Propósito: Análise de vendas futuras e rasteamento de pendências
-- Data: 27/02/2026
-- Status: VERSÃO INICIAL - Ajustar conforme especificação de relacionamento
-- ============================================

SELECT 
    -- Informações da NF Venda Futura
    A.emps AS 'EMPRESA',
    A.DOPES AS 'TIPO_OPERACAO_ATUAL',
    A.notas AS 'NUM_NF_VENDA_FUTURA',
    A.EMPDOPNUMS AS 'CHAVE_NF_FUTURA',
    A.datas AS 'DATA_NF_FUTURA',
    A.numes AS 'NUM_OPERACAO',
    
    -- Cliente/Destino
    J.rclis AS 'CLIENTE',
    J.iclis AS 'COD_CLIENTE',
    
    -- Produtos/Itens
    C.cpros AS 'CODIGO_PRODUTO',
    D.dpros AS 'DESCRICAO_PRODUTO',
    SUM(C.QTDS * C.UNITS) AS 'QUANTIDADE',
    SUM(C.valipis) AS 'IPI',
    SUM(C.QTDS * C.UNITS + C.valipis) AS 'VALOR_TOTAL',
    
    -- Status da NF
    G.stats AS 'STATUS_NF',
    P.cancelas AS 'CANCELADA',
    P.series AS 'SERIE_NF',
    
    -- Operação Anterior (Pendência)
    N.DOPES AS 'TIPO_OPERACAO_ANTERIOR',
    N.notas AS 'NUM_OPERACAO_ANTERIOR',
    N.EMPDOPNUMS AS 'CHAVE_OPERACAO_ANTERIOR',
    N.datas AS 'DATA_OPERACAO_ANTERIOR',
    
    -- Pendência da Operacao Anterior
    ISO.QTDS AS 'QTD_PENDENTE_ANTERIOR',
    ISO.UNITS AS 'UNIDADE_PENDENTE',
    (ISO.QTDS * ISO.UNITS) AS 'VALOR_PENDENTE_ANTERIOR',
    
    -- Observações
    CAST(A.obses AS varchar(max)) AS 'OBSERVACOES_ATUAL',
    CAST(N.obses AS varchar(max)) AS 'OBSERVACOES_ANTERIOR',
    
    -- Data de Referência (para agrupamento mensal)
    DATEFROMPARTS(YEAR(A.datas), MONTH(A.datas), 1) AS 'DATA_REFERENCIA'
    
FROM 
    SIGMVCAB A WITH (NOLOCK)                                    -- NF VENDA FUTURA
    LEFT JOIN SIGCDOPE B WITH (NOLOCK) 
        ON A.DOPES = B.DOPES
    LEFT JOIN SIGMVITN C WITH (NOLOCK) 
        ON A.EMPDOPNUMS = C.EMPDOPNUMS                          -- Itens da NF Futura
    LEFT JOIN SigMvNfi P WITH (NOLOCK) 
        ON P.empdopnums = A.empdopnums                          -- Info NF
    LEFT JOIN SIGCDPRO D WITH (NOLOCK) 
        ON C.CPROS = D.CPROS                                    -- Dados do Produto
    LEFT JOIN SIGCDCLI J WITH (NOLOCK) 
        ON A.contads = J.ICLIS                                  -- Cliente Destino
    LEFT JOIN SIGPRNFE G WITH (NOLOCK) 
        ON A.EMPDOPNUMS = G.EMPDOPNUMS 
        AND G.datas = (
            SELECT MAX(I.datas) 
            FROM sigprnfe I 
            WHERE A.EMPDOPNUMS = I.EMPDOPNUMS 
            GROUP BY I.empdopnums
        )                                                        -- Status NF
    
    -- RELACIONAMENTO COM OPERAÇÃO ANTERIOR
    LEFT JOIN SIGMVCAB N WITH (NOLOCK)
        ON A.CONTAOS = N.CONTADS                                -- Operação anterior: mesmo fluxo de contas
        AND N.datas < A.datas                                   -- Operação anterior no tempo
        AND N.datas = (
            SELECT MAX(Z.datas)
            FROM SIGMVCAB Z
            WHERE A.CONTAOS = Z.CONTADS
            AND Z.datas < A.datas
        )                                                        -- Pega a operação anterior mais recente
    
    LEFT JOIN SIGMVITN ISO WITH (NOLOCK)
        ON N.EMPDOPNUMS = ISO.EMPDOPNUMS                        -- Itens da operação anterior (pendências)
        AND ISO.cpros = C.cpros                                 -- Mesmo produto

WHERE 
    A.DOPES = 'NF VENDA FUTURA'
    AND C.citem2 = 0
    AND A.datas >= '2023-01-01'
    AND ISNULL(ISO.QTDS, 0) > 0                                 -- Apenas com pendências

GROUP BY 
    A.emps, A.DOPES, A.notas, A.EMPDOPNUMS, A.datas, A.numes, A.NOPS,
    J.rclis, J.iclis,
    C.cpros,
    D.dpros,
    CAST(A.obses AS varchar(max)),
    G.stats,
    P.cancelas, P.series,
    N.DOPES, N.notas, N.EMPDOPNUMS, N.datas,
    ISO.QTDS, ISO.UNITS,
    CAST(N.obses AS varchar(max)),
    DATEFROMPARTS(YEAR(A.datas), MONTH(A.datas), 1)

ORDER BY 
    A.datas DESC,
    A.notas ASC,
    C.cpros ASC
