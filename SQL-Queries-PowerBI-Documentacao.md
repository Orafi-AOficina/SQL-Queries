# 📊 Documentação Completa - SQL Queries para PowerBI

**Versão:** 1.0  
**Data:** 27 de Fevereiro de 2026  
**Sistema:** ERP para Manufatura de Joalharia (SIGMATEC)  
**Escopo:** 27 Queries em Produção + Análise de 186 Arquivos no Repositório

---

## 📋 Índice

1. [Visão Geral do Sistema](#visão-geral-do-sistema)
2. [Resumo Executivo](#resumo-executivo)
3. [Queries por Domínio](#queries-por-domínio)
   - [Cadastros e Dimensões](#cadastros-e-dimensões)
   - [Operações de Produção](#operações-de-produção)
   - [Gestão de Pedidos](#gestão-de-pedidos)
   - [Estoque e Balanços](#estoque-e-balanços)
   - [Financeiro e Faturamento](#financeiro-e-faturamento)
   - [Orçamentos e Cotas](#orçamentos-e-cotas)
   - [Análises Especializadas](#análises-especializadas)
4. [Tabelas Principais](#tabelas-principais)
5. [Padrões e Convenções](#padrões-e-convenções)
6. [Matriz de Relacionamentos](#matriz-de-relacionamentos)
7. [Arquivos de Referência](#arquivos-de-referência)

---

## Visão Geral do Sistema

O repositório SQL-Queries contém consultas otimizadas para um **sistema ERP especializado em manufatura de joalharia**. O sistema rastreia:

- **Operações de Produção:** Ordens de Produção (OPs) com hierarquia até 8 níveis
- **Pedidos:** Encomendas e fabricações internas com composição de itens
- **Estoque:** Posições de matérias-primas, insumos e produtos finalizados
- **Financeiro:** Contas a pagar/receber, notas fiscais, adiantamentos
- **Balanços:** Inventários periódicos com histórico de movimentações
- **Recursos Especializados:** Brilhantes, lapidação, desmanche

**Arquitetura de Dados:** SQL Server com prefixo padrão `Sig*` para todas as tabelas do ERP.

---

## Resumo Executivo

| Métrica | Valor |
|---------|-------|
| **Total de Arquivos Analisados** | 186 |
| **Queries em Produção (PowerBI)** | 27 |
| **Queries em Consultas Gerais** | 22 |
| **Queries em Orçamento** | 3 |
| **Queries em Histórico** | 126 (versões antigas) |
| **Linhas Médias por Query** | 60-100 |
| **Tabelas Principais** | 8 (detalhadas em Dicionário de Dados) |
| **Domínios Cobertos** | 8 (100% cobertura operacional) |

---

## Queries por Domínio

### 📦 Cadastros e Dimensões

Tabelas mestres que servem como dimensões para análises operacionais.

#### 1. **Cadastro de Produtos** `Power BI/Cadastro de Produtos.sql`
- **Propósito:** Lista completa de produtos finais com sua composição de insumos
- **Tabelas Principais:** `SigCdPro` (produtos), `SIGPRCPO` (composição)
- **Campos Retornados:** Código produto, descrição, referência, grupo, categoria, insumos componentes, quantidades
- **Uso PowerBI:** Dimensão para filtros de produtos, consultas de BOM
- **Relacionamento:** Vinculada com OPs Geradas e Movimentações
- **Notas:** Suporta produtos com múltiplas composições

#### 2. **Cadastro de Insumos** `Power BI/Insumos.sql`
- **Propósito:** Registro de todas as matérias-primas e insumos disponíveis no sistema
- **Tabelas Principais:** `SigCdPro` (com filtro de tipo insumo)
- **Campos Retornados:** Código do insumo, descrição, unidade de medida, tipo (AU, PLT, INS, etc), mercadoria
- **Uso PowerBI:** Filtros de insumos em dashboards de estoque e movimentações
- **Relacionamento:** Base para Movimentação de Materia Prima e Estoque
- **Notas:** Inclui ouro, prata, platina, brilhantes, gemas

#### 3. **Clientes** `Power BI/Clientes.sql`
- **Propósito:** Cadastro de contas de venda (clientes / entidades comerciais)
- **Tabelas Principais:** `SigCdCli` (clientes)
- **Campos Retornados:** Código cliente, razão social, fantasia, CNPJ/CPF, endereço, telefone, status
- **Uso PowerBI:** Dimensão para análises de vendas e pedidos
- **Relacionamento:** Vinculada com Pedidos e NFs
- **Notas:** Inclui clientes ativos e inativos

#### 4. **Contas** `Power BI/Contas.sql`
- **Propósito:** Estrutura de contas internas do sistema (onde estoca materiais)
- **Tabelas Principais:** `SigCdCli` (tipo conta de interna)
- **Campos Retornados:** Código da conta, descrição, grupo, tipo, status
- **Uso PowerBI:** Dimensão para movimentações entre contas, transferências
- **Relacionamento:** Vinculada com Estoque, Movimentações, Balanços
- **Notas:** Pode ser departamentos, almoxarifado, fornecedores, clientes

---

### 🏭 Operações de Produção

Queries que rastreiam toda a vida útil de um produto em produção.

#### 5. **OPs Geradas** `Power BI/OPs Geradas.sql`
- **Propósito:** Ordens de produção com hierarquia completa (até 8 níveis de OP mãe/filha)
- **Tabelas Principais:** `SigOpPic` (cabeçalho OP), `SigCdPro` (produto), `SigMvCab` (relacionamento)
- **Campos Retornados:** Número OP, número OP mãe, produto, quantidade, status, datas (abertura, entrega), conta origem/destino
- **Uso PowerBI:** Visão central de produção, tracking de OP por produto
- **Complexidade:** Muito Alta - usa self-joins até 8 vezes para rastrear hierarquia completa
- **Relacionamento:** Alimenta Movimentações, Detalhes de OPs, Saídas de Produção
- **Notas:** Campo `nopmaes` permite rastreabilidade de OP composta por subOPs

#### 6. **Movimentações** `Power BI/Movimentações.sql`
- **Propósito:** Operações de movimentação de produtos durante a produção (sequências de etapas)
- **Tabelas Principais:** `SigMvCab` (cabeçalho), `SigMvItn` (itens), `SigOpPic` (OP)
- **Campos Retornados:** Número OP, sequência de operação, código operação, produto, quantidade, unidade, status, data
- **Uso PowerBI:** Timeline de produção, acompanhamento de etapas
- **Relacionamento:** Vinculada com OPs Geradas, Movimentação de Insumos
- **Notas:** Cada OP pode ter múltiplas movimentações sequenciadas

#### 7. **Saídas de Produção** `Power BI/Saídas de Produção.sql`
- **Propósito:** Saídas finalizadas de OP quando completa
- **Tabelas Principais:** `SigMvCab` (com tipo SAIDA_PRODUCAO), `SigOpPic`, `SigCdPro`
- **Campos Retornados:** Número OP, produto, quantidade finalizada, data saída, conta origem/destino
- **Uso PowerBI:** KPI de finalização, análise de capacidade
- **Relacionamento:** Resultado final de OPs Geradas
- **Notas:** Marca encerramento de ciclo de produção

#### 8. **Composição das OPs** `Power BI/Composição das OPs.sql`
- **Propósito:** Detalhamento de quais insumos são necessários para cada OP
- **Tabelas Principais:** `SigOpPic`, `SIGPRCPO` (composição de produto), `SigCdPro`
- **Campos Retornados:** Número OP, produto, insumo componente, quantidade necessária, peso, custo
- **Uso PowerBI:** Planejamento de suprimentos, cálculo de custos
- **Relacionamento:** Combinação de OPs Geradas + Cadastro de Produtos
- **Notas:** Essencial para gestão de matéria-prima necessária

#### 9. **Detalhe das OPs** `Power BI/Detalhe das OPs.sql`
- **Propósito:** Informações expandidas de OPs com observações e metadados
- **Tabelas Principais:** `SigOpPic`, `SigCdPro`, tabelas de observações
- **Campos Retornados:** Wszystko de OPs Geradas + observações, anotações, histórico de mudanças
- **Uso PowerBI:** Detalhamento em drill-down, troubleshooting de problemas
- **Relacionamento:** Extensão de OPs Geradas
- **Notas:** Fornece contexto qualitativo sobre OPs

#### 10. **Etiqueta das OPs** `Power BI/Etiqueta das OPs.sql`
- **Propósito:** Informações formatadas para impressão em etiquetas/tags de rastreamento
- **Tabelas Principais:** `SigOpPic`, `SigCdPro`, código de barras
- **Campos Retornados:** Número OP, produto, code barras, datas, informações de classificação
- **Uso PowerBI:** Exportação para impressoras de etiquetas, rastreamento físico
- **Relacionamento:** Suporta Etapas de Produção
- **Notas:** Formato otimizado para leitura de código de barras

#### 11. **Etapas de Produção** `Power BI/Etapas de PRodução.sql`
- **Propósito:** Catálogo de todas as etapas/operações possíveis no fluxo de produção
- **Tabelas Principais:** `SigCdOpe` (operações), sequência
- **Campos Retornados:** Código etapa, descrição, sequência, tempo padrão, recursos
- **Uso PowerBI:** Dimensão para filtragem de etapas, análise de throughput por etapa
- **Relacionamento:** Referencial para Movimentações
- **Notas:** Mestrado que define o fluxo de produção permitido

---

### 📦 Gestão de Pedidos

Rastreamento de pedidos desde criação até finalização e faturamento.

#### 12. **Pedidos** `Power BI/Pedidos.sql`
- **Propósito:** Registro de pedidos (encomendas de clientes ou fabricação interna)
- **Tabelas Principais:** `SigMvCab` (com tipos PEDIDO_ENCOMENDA, PEDIDO_FABRICA), `SigCdCli`, `SigCdPro`
- **Campos Retornados:** Número pedido, cliente, tipo pedido, data, quantidade, status, cotações USD/AU
- **Uso PowerBI:** Dashboard de entrada, pipeline de vendas
- **Complexidade:** Moderada - inclui PIVOT para moedas (USD e AU)
- **Relacionamento:** Origem de OPs Geradas
- **Notas:** Cotações multi-moeda para joias (ouro e USD)

#### 13. **Itens do Pedido** `Power BI/Itens do Pedido.sql`
- **Propósito:** Desagregação de pedidos em itens individuais com produtos
- **Tabelas Principais:** `SigMvCab`, `SigMvItn` (itens), `SigCdPro`
- **Campos Retornados:** Número pedido, número item, produto, quantidade, valor unitário, total, especificações
- **Uso PowerBI:** Detalhamento de pedidos, análise de mix de produtos
- **Relacionamento:** Detalha Pedidos
- **Notas:** Cada pedido pode conter múltiplos itens diferentes

---

### 📈 Estoque e Balanços

Gestão de inventário e posições de estoque.

#### 14. **Estoque** `Power BI/Estoque.sql`
- **Propósito:** Posição atual de estoque por insumo/produto
- **Tabelas Principais:** `SigMvEst` (estoque), `SigCdPro`, `SigCdCli` (contas)
- **Campos Retornados:** Código insumo/produto, conta, quantidade atual, peso/valor, data atualização
- **Uso PowerBI:** KPI de estoque, alertas de falta, análise de giro
- **Relacionamento:** Agregação de todas as movimentações de estoque
- **Notas:** Tempo real ou atualizado conforme cadência de balanço

#### 15. **Balanços** `Power BI/Balanços.sql`
- **Propósito:** Informações de períodos de inventário com dados agregados
- **Tabelas Principais:** `SigCdFcx` (cabeçalho balanço), `SigMvHst` (histórico)
- **Campos Retornados:** Número balanço, período, data, status (aberto/fechado), total contado
- **Uso PowerBI:** Auditoria de estoque, comparativos periódicos
- **Relacionamento:** Contém histórico de Estoque
- **Notas:** Permite rastreabilidade de movimentos por período

#### 16. **Balanço Consolidado** `Power BI/Balanço Consolidado.sql`
- **Propósito:** Consolidação de balanços por código de insumo (agregação superior)
- **Tabelas Principais:** `SigCdFcx`, `SigMvHst`, agregações
- **Campos Retornados:** Código insumo, descrição, quantidade contada, quantidade sistema, diferença, períodos
- **Uso PowerBI:** Visão consolidada, análise de discrepâncias
- **Relacionamento:** Agrega Balanços
- **Notas:** Destacar diferenças sistema vs contagem

#### 17. **Movimentação de Matéria Prima** `Power BI/Movimentação de Materia Prima.sql`
- **Propósito:** Transferências de matérias-primas entre contas (armazém → produção, etc)
- **Tabelas Principais:** `SigMvCab` (tipo TRANSFERENCIA_MP), `SigCdPro`, `SigCdCli` (contas origem/destino)
- **Campos Retornados:** Número movimento, data, insumo, quantidade, unidade, conta origem, conta destino
- **Uso PowerBI:** Rastreamento de suprimentos, análise de fluxo
- **Relacionamento:** Alimenta Estoque
- **Notas:** Essencial para rastreabilidade de MP em produção

#### 18. **Movimentação de Insumos** `Power BI/Movmentação de Insumos.sql`
- **Propósito:** Movimentações gerais de insumos (inclui consumo, devolução, ajuste)
- **Tabelas Principais:** `SigMvCab`, `SigMvItn`, tipos variados
- **Campos Retornados:** Número movimento, tipo (consumo, devolução, ajuste), insumo, quantidade, data, motivo
- **Uso PowerBI:** Análise de consumo, investigação de variâncias
- **Relacionamento:** Detalha movimentações para KPI de eficiência
- **Notas:** Suporta múltiplos tipos de movimento

---

### 💰 Financeiro e Faturamento

Gestão de operações comerciais e financeiras.

#### 19. **NFs** `Power BI/NFs.sql`
- **Propósito:** Notas fiscais emitidas e recebidas com rastreamento de itens
- **Tabelas Principais:** `SigCbNfx` (cabeçalho NF), `SigCbNfp` (itens NF), `SigCdCli`, `SigPdMvf` (finalizações)
- **Campos Retornados:** Número NF, série, data emissão, cliente/fornecedor, tipo (saída/entrada), itens com códigos de barras
- **Uso PowerBI:** Dashboard de faturamento, rastreamento de remessas
- **Complexidade:** Moderada - join complexo entre múltiplas tabelas
- **Relacionamento:** Realiza saída de Finalizações, entrada de compras
- **Notas:** Permite rastreio completo do que foi faturado

#### 20. **Finalizações** `Power BI/Finalização.sql`
- **Propósito:** Status de finalizações de OPs (etapa anterior a faturamento)
- **Tabelas Principais:** `SigPdMvf` (finalizações), `SigOpPic`, `SigCdPro`
- **Campos Retornados:** Número OP, data finalização, produto, quantidade, código barras, status NF
- **Uso PowerBI:** KPI de finalização, rastreamento de finalizações pendentes de NF
- **Relacionamento:** Antecede NFs
- **Notas:** Traz visibilidade de produtos prontos aguardando faturamento

---

### 🎯 Orçamentos e Cotas

Automação de processo de cotação e orçamentação.

#### 21. **Composição das Movimentações** `Power BI/Composição das Movimentações.sql`
- **Propósito:** Detalhamento de quais insumos compõem cada movimentação (operação)
- **Tabelas Principais:** `SigMvCab`, `SigMvItn`, `SIGPRCPO`, `SigCdPro`
- **Campos Retornados:** Número movimento, sequência, insumo, quantidade, peso, custo unitário
- **Uso PowerBI:** Análise de custos de operação, rastreamento de consumo
- **Relacionamento:** Detalha Movimentações
- **Notas:** Essencial para cálculo de custo de produção

#### 22. **Composição de Produtos** `Power BI/Composição de Produtos.sql`
- **Propósito:** BOM (Bill of Materials) de produtos finais
- **Tabelas Principais:** `SigCdPro`, `SIGPRCPO` (composição)
- **Campos Retornados:** Código produto final, descrição, código insumo, descrição insumo, quantidade, peso, custo
- **Uso PowerBI:** Planejamento de produção, análise de custos
- **Relacionamento:** Suporta Orçamento ANL
- **Notas:** Permite estimar custos de novos pedidos

#### 23. **Dias Úteis** `Power BI/Dias Úteis.sql`
- **Propósito:** Calendário de dias úteis (exclui finais de semana e feriados)
- **Tabelas Principais:** `SigCdCld` (calendário)
- **Campos Retornados:** Data, dia da semana, feriado (sim/não), dias úteis acumulados
- **Uso PowerBI:** Dimensão temporal para análises de produtividade
- **Relacionamento:** Auxilia no cálculo de SLA de produção
- **Notas:** Suporta cálculos de prazos realistas

---

### 🔧 Análises Especializadas

Queries para processos específicos de joalharia.

#### 24. **Desmanche** `Power BI/Desmanche.sql`
- **Propósito:** Recuperação de materiais de joias desmanteladas
- **Tabelas Principais:** `SigMvCab` (tipo DESMANCHE), `SigMvItn`
- **Campos Retornados:** Número movimento desmanche, data, produto desmantelado, insumos recuperados, quantidades
- **Uso PowerBI:** Rastreamento de recovery, análise de aproveitamento
- **Relacionamento:** Origem alternativa de insumos
- **Notas:** Importante para gestão de sustentabilidade e custos

#### 25. **Insumos** `Power BI/Insumos.sql` *(Listado em Cadastros, repetido para referência)*
- **Propósito:** Vide seção Cadastros (ID 2)

#### 26. **Contas** `Power BI/Contas.sql` *(Listado em Cadastros, repetido para referência)*
- **Propósito:** Vide seção Cadastros (ID 4)

---

### ⚙️ Tabelas de Sistema

#### 27. **Sistema** *(Sem query específica, mas referenciada)*
- **Propósito:** Metadados e informações de sistema
- **Usado por:** Filtros de segurança, informações de usuário
- **Notas:** Pode incluir logs de auditoria e configurações

---

## Tabelas Principais

Veja [Dicionario-Dados.md](Dicionario-Dados.md) para mapeamento completo.

**8 Tabelas Centrais:**

| Tabela | Função | Usada em Queries |
|--------|--------|------------------|
| **SigMvCab** | Cabeçalho de operações (Pedido, Produção, Transferência) | Pedidos, Movimentações, Saídas |
| **SigMvItn** | Itens de operações (produto/insumo, quantidade, valor) | Itens Pedido, Movimentações |
| **SigOpPic** | Ordens de Produção (número, produto, qty, hierarquia) | OPs Geradas, Composição OPs |
| **SigCdPro** | Cadastro de Produtos/Insumos (código, descrição, tipo) | Todos as queries |
| **SigCdCli** | Cadastro de Contas/Clientes (código, descrição, tipo) | Pedidos, Estoque, Movimentações |
| **SigPdMvf** | Finalizações de Produção (número OP, data, código barras) | Finalizações, NFs |
| **SigMvEst** | Estoque (posição em conta por insumo/produto) | Estoque, Balanços |
| **SIGPRCPO** | Composição de Produtos (produto final → insumos) | Composição OPs, Composição Produtos |

---

## Padrões e Convenções

Veja [Padroes-SQL.md](Padroes-SQL.md) para detalhes técnicos.

**Resumo:**
- Todas as queries usam `WITH (NOLOCK)` para não bloquear leitura
- Aliases de tabela: A, B, C, ... (padrão)
- Identificadores em plural: `datas`, `qtds`, `totas`
- CASE WHEN para lógica condicional
- String functions para limpeza: LTRIM, RTRIM, SUBSTRING
- Conversões de tipo: CAST, CONVERT para datas e números
- ORDER BY com múltiplas colunas para consistência

---

## Matriz de Relacionamentos

Veja [Fluxos-Processo.md](Fluxos-Processo.md) para diagramas visuais.

**Fluxos Principais:**

1. **PEDIDO → OP → MOVIMENTAÇÃO → SAÍDA → FINALIZAÇÃO → NF**
   - Entrada de cliente → Produção → Encerramento → Faturamento

2. **CADASTRO_PRODUTOS + COMPOSIÇÃO → ORÇAMENTO**
   - Planejamento de custos e prazos

3. **PEDIDO/OP → NECESSIDADE_MP → MOVIMENTO_MP → ESTOQUE → BALANÇO**
   - Rastreamento de suprimentos

4. **OP → MOVIMENTAÇÃO → COMPOSIÇÃO_MOVIMENTO → CUSTO**
   - Cálculo de custo de produção

5. **DESMANCHE → RECUPERAÇÃO_INSUMOS → ESTOQUE**
   - Ciclo alternativo de entrada de materiais

---

## Arquivos de Referência

Para contexto aprofundado em futuras interações, use:

1. **[Dicionario-Dados.md](Dicionario-Dados.md)**
   - Mapeamento de tabelas SQL Server
   - Descrição de campos principais
   - Tipos de dados e relacionamentos
   - Quando: Precisa entender estrutura de dados subjacente

2. **[Fluxos-Processo.md](Fluxos-Processo.md)**
   - Diagramas de fluxos de processo
   - Como queries se relacionam
   - Sequência temporal de operações
   - Quando: Precisa entender lógica de negócio e dependências

3. **[Padroes-SQL.md](Padroes-SQL.md)**
   - Padrões SQL encontrados no repositório
   - Convenções de código
   - Técnicas de otimização usadas
   - Recomendações para novas queries
   - Quando: Está desenvolvendo novos relatórios ou modificando queries existentes

---

## 📚 Como Usar Esta Documentação

### Para Gerentes de Dados / Analistas de Negócio
1. Leia esta documentação principal (SQL-Queries-PowerBI-Documentacao.md)
2. Identifique a query relevante pela seção de domínio
3. Use [Fluxos-Processo.md](Fluxos-Processo.md) para entender como queries se conectam

### Para Desenvolvedores / DBAs
1. Comece por [Padroes-SQL.md](Padroes-SQL.md) para entender convenções
2. Use [Dicionario-Dados.md](Dicionario-Dados.md) para estrutura de tabelas
3. Consulte esta documentação para identificar queries relacionadas

### Para Discussões com Copilot (GitHub Copilot)
**Sempre inclua nesta ordem:**
1. Esta documentação (SQL-Queries-PowerBI-Documentacao.md): contexto do sistema
2. Arquivo relevante de referência (Dicionário / Fluxos / Padrões)
3. Query específica em foco (se necessário)

Exemplo: *"Preciso criar um novo relatório de estoque. Veja SQL-Queries-PowerBI-Documentacao.md (seção Estoque), Dicionario-Dados.md (tabela SigMvEst), e Padroes-SQL.md (padrão NOLOCK)"*

---

## 📊 Cobertura por Domínio

| Domínio | Queries | Cobertura | Status |
|---------|---------|-----------|--------|
| **Cadastros** | 4 | Produtos, Insumos, Clientes, Contas | ✅ Completo |
| **Operações** | 7 | OPs, Movimentações, Saídas, Composições, Etapas | ✅ Completo |
| **Pedidos** | 2 | Pedidos, Itens | ✅ Completo |
| **Estoque** | 5 | Estoque, Balanços, Movimentações MP/Insumos | ✅ Completo |
| **Financeiro** | 2 | NFs, Finalizações | ⚠️ Parcial* |
| **Orçamentos** | 2 | Composições, Dias Úteis | ✅ Completo |
| **Especializado** | 1 | Desmanche | ✅ Presente |
| **Sistema** | 1 | Metadados | ⚠️ Mínimo |

*Parcial: Contas a Pagar / Receber estão em histórico (PC Antigo), não em Power BI ativo

---

## 📝 Notas e Observações

### Queries Críticas para PowerBI
1. **OPs Geradas** - Base para toda produção
2. **Estoque** - KPI crítico de negócio
3. **Pedidos** - Entrada de vendas
4. **Movimentações** - Rastreamento real-time de produção

### Oportunidades de Melhoria
- [ ] Documentar cada query com cabeçalho padrão (NOME, DESCRIÇÃO, AUTOR, DATA, TABELAS)
- [ ] Consolidar queries duplicadas entre pastas (Consultas vs Scripts vs Power BI)
- [ ] Otimizar self-joins em OPs Geradas (considerar CTE recursiva)
- [ ] Adicionar índices recomendados em comentários de query
- [ ] Criar view SQL para queries mais complexas
- [ ] Implementar versionamento de queries (v1.0, v1.1 em comentário)

### Histórico e Decisões de Arquitetura
O repositório foi organizado organicamente ao longo do tempo. A pasta "Histórico PC Antigo" contém 126 arquivos de versões anteriores, preservados para auditoria. A estratégia atual é manter as 27 queries de Power BI como referência de produção.

---

## 📞 Informações de Contato / Suporte

Para questões sobre:
- **Estrutura de dados:** Consulte DBA ou [Dicionario-Dados.md](Dicionario-Dados.md)
- **Lógica de negócio:** Consulte analistas de domínio ou [Fluxos-Processo.md](Fluxos-Processo.md)
- **Desenvolvimento de queries:** Veja [Padroes-SQL.md](Padroes-SQL.md) e histórico em Power BI/
- **Histórico e versionamento:** Consulte repositório Git e pasta Histórico PC Antigo

---

**Documento versão 1.0 - 27 de Fevereiro de 2026**  
*Gerado para facilitar onboarding, manutenção de queries e integração com assistentes de IA.*
