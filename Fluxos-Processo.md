# 🔄 Fluxos de Processo - Mapeamento de Operações e Queries

**Versão:** 1.0  
**Data:** 27 de Fevereiro de 2026  
**Sistema:** SIGMATEC (ERP para Joalharia)

---

## 📋 Índice

1. [Fluxo Principal de Negócio](#fluxo-principal-de-negócio)
2. [Fluxo 1: PEDIDO → PRODUÇÃO → ENTREGA](#fluxo-1-pedido--produção--entrega)
3. [Fluxo 2: PLANEJAMENTO DE SUPRIMENTES](#fluxo-2-planejamento-de-suprimentos)
4. [Fluxo 3: GESTÃO DE ESTOQUE E BALANÇOS](#fluxo-3-gestão-de-estoque-e-balanços)
5. [Fluxo 4: CICLO DE DESMANCHE E RECUPERAÇÃO](#fluxo-4-ciclo-de-desmanche-e-recuperação)
6. [Matriz de Dependências](#matriz-de-dependências)
7. [Fluxos Diagrama em Texto](#fluxos-diagrama-em-texto)
8. [Decisões de Onde Usar Cada Query](#decisões-de-onde-usar-cada-query)

---

## Fluxo Principal de Negócio

O sistema opera em um **fluxo cíclico de manufatura**:

```
ENTRADA (VENDA) → PLANEJAMENTO → PRODUÇÃO → FINALIZAÇÃO → COMERCIALIZAÇÃO → SAÍDA (RECEITA)
     ↓                ↓              ↓             ↓              ↓               ↓
  Pedido         Composição      Movimentações  Finalização    Notas Fiscais   Recebimento
  Cliente           Insumos        Etapas        Códigos         Faturamento       Cliente
   (Mês 0)        (Semana -1)    (Semana 0)    (Semana 1)      (Semana 1)     (Semana 2-4)
```

---

## Fluxo 1: PEDIDO → PRODUÇÃO → ENTREGA

Este é o fluxo principal de um pedido de cliente até sua conclusão.

### Sequência de Eventos

```
1️⃣  CLIENTE FAZ PEDIDO
    ↓
    Criado: SigMvCab (dopes = "PEDIDO_ENCOMENDA")
    Contém: SigMvItn (itens com produtos solicitados)
    Query: Pedidos.sql, Itens do Pedido.sql
    
2️⃣  GERAÇÃO DE OPS
    ↓
    Sistema gera: SigOpPic (uma OP por item ou agregada)
    Pode ser hierárquica: OP_PAI → OP_FILHA_1...N
    Query: OPs Geradas.sql
    
3️⃣  NECESSIDADE DE INSUMOS
    ↓
    Consultado: SIGPRCPO (Composição de Produtos)
    Resultado: Lista de insumos necessários
    Query: Composição das OPs.sql
    
4️⃣  ALOCAÇÃO / RETIRADA DE MATÉRIA-PRIMA
    ↓
    Criado: SigMvCab (dopes = "TRANSFERENCIA", contads = "PRODUCAO")
    Atualizado: SigMvEst (quantidade em conta origem ↓)
    Criado: SigMvCab (dopes = "TRANSFERENCIA", contados = "PRODUCAO")
    Atualizado: SigMvEst (quantidade em conta destino ↑)
    Query: Movimentação de Materia Prima.sql
    
5️⃣  PRODUÇÃO (MÚLTIPLAS ETAPAS)
    ↓
    Criado: SigMvCab (tipo = "PRODUCAO"), sequência de movimentações
    Atualizado: SigOpPic (status_op = "Em Produção" → Finalizada")
    Rastreado: Etapas de Produção passadas
    Query: Movimentações.sql, Etapas de Produção.sql
    
6️⃣  FINALIZAÇÃO
    ↓
    Criado: SigPdMvf (registro de finalização)
    Gerado: Código de barras para rastreamento
    SigOpPic.data_finalizacao = hoje
    Query: Finalização.sql, Etiqueta das OPs.sql
    
7️⃣  FATURAMENTO
    ↓
    Criado: SigCbNfx (Nota Fiscal)
    SigPdMvf.status_nf = "Faturada"
    Query: NFs.sql
    
8️⃣  SAÍDA / ENTREGA
    ↓
    Criado: SigMvCab (dopes = "SAIDA", contads = "CLIENTE")
    Atualizado: SigMvEst (conta ESTOQUE_PA ↓, conta CLIENTE ↑)
    Query: Saídas de Produção.sql
```

### Queries Envolvidas
| Etapa | Query Principal | Queries Suporte |
|-------|-----------------|-----------------|
| 1️⃣ Pedido | **Pedidos.sql** | Itens do Pedido.sql |
| 2️⃣ OPs | **OPs Geradas.sql** | Detalhe das OPs.sql |
| 3️⃣ Composição | **Composição das OPs.sql** | Cadastro de Produtos.sql, Composição de Produtos.sql |
| 4️⃣ Matéria-Prima | **Movimentação de Materia Prima.sql** | Estoque.sql |
| 5️⃣ Produção | **Movimentações.sql** | Etapas de Produção.sql |
| 6️⃣ Finalização | **Finalização.sql** | Etiqueta das OPs.sql |
| 7️⃣ Faturamento | **NFs.sql** | Finalizações.sql |
| 8️⃣ Saída | **Saídas de Produção.sql** | Estoque.sql |

### Responsabilidades por Setor

```
VENDAS:         Cria Pedido (1️⃣)
                Consulta: Pedidos.sql, Itens do Pedido.sql

PLANEJAMENTO:   Gera OPs (2️⃣), Calcula insumos (3️⃣)
                Consulta: OPs Geradas.sql, Composição das OPs.sql
                Autoriza: Movimentação de Materia Prima.sql (4️⃣)

ALMOXARIFADO:   Executa (4️⃣), monitora estoque
                Consulta: Estoque.sql, Movimentação de Materia Prima.sql

PRODUÇÃO:       Executa (5️⃣), registra movimentações
                Consulta: Movimentações.sql, Etapas de Produção.sql
                Gera: Etiqueta das OPs.sql

CONTROLE QA:    Finaliza (6️⃣), gera código de barras
                Consulta: Finalização.sql, Etiqueta das OPs.sql

FISCAL/NF:      Emite NF (7️⃣)
                Consulta: NFs.sql, Finalizações.sql

EXPEDIÇÃO:      Entrega (8️⃣)
                Atualiza: SigMvEst via Saídas de Produção.sql
                Consulta: Saídas de Produção.sql
```

---

## Fluxo 2: PLANEJAMENTO DE SUPRIMENTOS

Para que a produção não pare, é preciso ter insumos disponíveis.

### Sequência

```
1️⃣  PREVISÃO DE DEMANDA
    ↓
    Entrada: Pipeline de pedidos, histórico de vendas
    Query: Pedidos.sql (últimos 30 dias), OPs Geradas.sql

2️⃣  CÁLCULO DE NECESSIDADE
    ↓
    Consulta: Composição das OPs.sql, Composição de Produtos.sql
    Agregação: Soma de insumos necessários por período

3️⃣  VERIFICAÇÃO DE ESTOQUE
    ↓
    Consulta: Estoque.sql
    Comparação: Necessário vs Disponível

4️⃣  GERAÇÃO DE LISTA DE COMPRA
    ↓
    Se Necessário > Disponível:
      → Criar Pedido de Compra (SigMvCab)
    Decisão: Quantidade a encomendar

5️⃣  RECEBIMENTO DA COMPRA
    ↓
    Criado: SigMvCab (tipo = "PEDIDO_COMPRA")
    Criado: SigMvItn (itens recebidos)
    Atualizado: SigMvEst (conta FORNECEDOR → ARMAZEM)
    Query: Movimentação de Insumos.sql

6️⃣  MONITORAMENTO CONTÍNUO
    ↓
    Diário: Verificar níveis (Estoque.sql)
    Semanal: Revisar previsão (OPs Geradas.sql)
```

### Queries Críticas
```
Estoque.sql                              → Qual é a posição atual?
Composição das OPs.sql                  → Quanto de cada insumo vou usar?
OPs Geradas.sql                         → Quais OPs tenho previstas?
Movimentação de Insumos.sql             → Quantos insumos chegaram/saíram?
Movimentação de Materia Prima.sql       → Qual é o fluxo de MP?
Balanço Consolidado.sql                 → Posição de insumos por período
```

---

## Fluxo 3: GESTÃO DE ESTOQUE E BALANÇOS

Controle periódico da posição de estoque para auditoria e precisão.

### Sequência

```
1️⃣  ABERTURA DE BALANÇO PERIÓDICO
    ↓
    Criado: SigCdFcx (novo balanço para período)
    Data início: Sempre após fechamento anterior
    Típico: Mensal ou semanal

2️⃣  CONTAGEM FÍSICA (Se manual)
    ↓
    Operador: Conta itens no almoxarifado
    Entrada: Quantidade contada vs Quantidade em sistema

3️⃣  ATUALIZAÇÃO DE POSIÇÃO
    ↓
    Sistema: Correlaciona SigMvEst com movimentações
    Cálculo: Saldo Anterior + Entradas - Saídas = Saldo Atual
    Query: Estoque.sql (posição em tempo real)

4️⃣  GERAÇÃO DE RELATÓRIO DE BALANÇO
    ↓
    Consulta: Balanços.sql
    Contém: Código insumo, quantidade sistema, quantidade contada
    Análise: Diferenças (divergências)

5️⃣  CONSOLIDAÇÃO (agregação superior)
    ↓
    Query: Balanço Consolidado.sql
    Agrupa: Por insumo, por período, por conta
    Resultado: Visão executiva de saúde de estoque

6️⃣  INVESTIGAÇÃO DE DIVERGÊNCIAS
    ↓
    Se Diferença positiva / negativa > Tolerância:
      → Culpa: Perda em processo? Roubo? Erro de entrada?
      → Consultar: Movimentação de Insumos.sql, Desmanche.sql
      → Ação: Gerar ajuste de estoque

7️⃣  FECHAMENTO DO BALANÇO
    ↓
    SigCdFcx.status = "Fechado"
    Histórico: Congelado em SigMvHst para auditoria
```

### Queries Críticas

```
Estoque.sql                         → Posição atual em cada conta
Balanços.sql                        → Qual foi a contagem?
Balanço Consolidado.sql             → Consolidação por insumo/período
Movimentação de Insumos.sql         → Onde foi embora?
Desmanche.sql                       → Houve recuperação?
```

---

## Fluxo 4: CICLO DE DESMANCHE E RECUPERAÇÃO

Recuperação de materiais de joias com defeito ou devolução.

### Sequência

```
1️⃣  IDENTIFICAÇÃO DE ITEM PARA DESMANCHE
    ↓
    Causa: Defeito de qualidade, devolução de cliente, teste
    Registro: SigMvCab (tipo = "DESMANCHE")

2️⃣  DESMANCHE OPERACIONAL
    ↓
    Operação: Desmontar joia em componentes
    Criado: SigMvCab (tipo = "DESMANCHE")
    Componentes: Ouro, Pedras, etc
    Criado: SigMvItn (itens recuperados)

3️⃣  QUANTIFICAÇÃO DO MATERIAL RECUPERADO
    ↓
    Pesagem: Ouro recuperado em gramas
    Contagem: Pedras (brilhantes, gemas)
    Query: Desmanche.sql

4️⃣  ENTRADA EM ESTOQUE
    ↓
    Criado: SigMvCab (tipo = "ENTRADA", contados = "ARMAZEM")
    Atualizado: SigMvEst (quantidade ↑)
    Re-entrada: Material disponível para nova produção

5️⃣  ANÁLISE DE RECOVEY
    ↓
    Cálculo: % de material recuperado vs material original
    Exemplo: Anel com 2.5g ouro: recuperado 2.45g = 98% recovery
    KPI: Importância para sustentabilidade e custo
```

### Queries Críticas

```
Desmanche.sql                       → Quanto foi desmanchado?
Estoque.sql                         → Posição após desmanche
Movimentação de Insumos.sql         → Fluxo de entrada
Composição de Produtos.sql          → Qual era a especificação inicial?
```

---

## Matriz de Dependências

Qual query depende de qual tabela/query anterior?

```
                        ┌─────────────────────────────────┐
                        │   Cadastros Mestres             │
                        ├─────────────────────────────────┤
                        │ • Cadastro de Produtos          │
                        │ • Cadastro de Insumos           │
                        │ • Clientes (Contas)             │
                        │ • Contas                        │
                        │ • Dias Úteis                    │
                        └──────────────┬──────────────────┘
                                       │
              ┌────────────────────────┼────────────────────────┐
              │                        │                        │
              ▼                        ▼                        ▼
        ┌──────────────┐       ┌──────────────┐       ┌──────────────┐
        │  Fluxo de    │       │   Fluxo de   │       │   Fluxo de   │
        │  Pedidos     │       │  Produção    │       │   Estoque    │
        ├──────────────┤       ├──────────────┤       ├──────────────┤
        │ • Pedidos    │       │ • OPs Geradas│       │ • Estoque    │
        │ • Itens      │──────→│ • Composição │──────→│ • Balanços   │
        └──────────────┘       │   OPs       │       │ • Balanço    │
              │                │ • Detalhe OP │       │   Consolid.  │
              │                │ • Etapas     │       └──────────────┘
              │                │ • Etiquetas  │
              │                │ • Movimentaçõ│       ┌──────────────┐
              │                │ • Saídas     │──────→│  Faturamento │
              │                └──────────────┘       ├──────────────┤
              │                      │                │ • NFs        │
              │                      │                │ • Finaliz.   │
              │                      │                └──────────────┘
              │                      │
              └──────────────────────┴───────────────┐ (feedback)
                                                    │
                                                    ▼
                                          ┌──────────────────┐
                                          │ Análises Especial│
                                          ├──────────────────┤
                                          │ • Desmanche      │
                                          │ • Composição Mov │
                                          │ • Composição Prod│
                                          │ • Insumos Movim  │
                                          └──────────────────┘
```

---

## Fluxos Diagrama em Texto

### Fluxo Completo: Um Pedido na Vida

```
           ENTRADA (Cliente)
                 │
                 v
        ┌─────────────────┐
        │  Pedido criado  │  ← Pedidos.sql: Lista todos os pedidos
        │  SigMvCab       │
        └────────┬────────┘
                 │  Contém múltiplos produtos
                 v
        ┌─────────────────────┐
        │  Itens do Pedido    │  ← Itens do Pedido.sql: Detalha cada item
        │  SigMvItn           │
        └────────┬────────────┘
                 │  Para cada produto, gera 1 OP (ou agrupa)
                 v
        ┌─────────────────────┐
        │  OP Gerada          │  ← OPs Geradas.sql: Lista todas as OPs
        │  SigOpPic           │  ← Detalhe das OPs.sql: Metadados
        └────────┬────────────┘
                 │  Produto = ?  →  Qual é a composição?
                 v
        ┌─────────────────────────┐
        │  Composição da OP       │  ← Composição das OPs.sql: Insumos necessários
        │  (SIGPRCPO + SigCdPro)  │  ← Composição de Produtos.sql: BOM
        └────────┬────────────────┘
                 │  Preciso destes insumos
                 v
        ┌─────────────────────┐
        │  Verificar Estoque  │  ← Estoque.sql: Tho tenho?
        │  SigMvEst           │  ← Balanço Consolidado.sql: Consolidação
        └──────┬──────┬───────┘
               │      │
         SE TEM │      │ SE FALTA
               │      │
               v      v
    ┌─────────────┐  ┌────────────────────────┐
    │ Prosseguir  │  │ Comprar insumos        │
    │ produção    │  │ Criar Pedido Compra    │
    └──────┬──────┘  │ (transação em histórico)
           │         └────────────────────────┘
           v
    ┌──────────────────────┐
    │  Saída de MP de      │  ← Movimentação de Materia Prima.sql:
    │  Armazém p/ Produção │     Controla a saída
    │  SigMvCab (TRANSF)   │
    └──────────┬───────────┘
               │  Atualiza estoque
               v
    ┌──────────────────────┐
    │  Atualizar Estoque   │
    │  SigMvEst ↓ armazém  │
    │  SigMvEst ↑ produção │
    └──────────┬───────────┘
               │  Múltiplas etapas de produção
               v
    ┌──────────────────────────┐
    │  Movimentações Produção  │  ← Movimentações.sql: Rastreia etapas
    │ SigMvCab (múltiplas)     │  ← Etapas de Produção.sql: Quais são?
    │ → CORTE → POLIMENTO → … │  ← Composição das Movimentações.sql: Insumos
    │         (sequência)      │  ← Movimentação de Insumos.sql: Consumo
    └──────────┬───────────────┘
               │  Quando termina todas as etapas
               v
    ┌──────────────────────────┐
    │  Finalização criada      │  ← Finalização.sql: Status "pronto"
    │  SigPdMvf                │  ← Etiqueta das OPs.sql: Código de barras
    │  Código de barras: ####  │
    └──────────┬───────────────┘
               │  Pronto para venda, precisa de NF
               v
    ┌──────────────────────────┐
    │  Nota Fiscal emitida     │  ← NFs.sql: Faturamento registrado
    │  SigCbNfx                │
    │  SigPdMvf.status = "NF"  │
    └──────────┬───────────────┘
               │
               v
    ┌──────────────────────────┐
    │  Saída / Entrega         │  ← Saídas de Produção.sql: Saída confirmada
    │  SigMvCab (SAÍDA)        │
    │  Atualiza:               │
    │  SigMvEst ↓ estoque      │
    │  SigMvEst ↑ cliente      │
    └──────────┬───────────────┘
               │
               ▼
             CLIENTE (Produto entregue!)
```

### Ciclo de Desmanche

```
Joia OK? NÃO
    │
    v
┌────────────────┐
│ DESMANCHE      │  ← Desmanche.sql: Rastreia desmanche
│ SigMvCab       │
├────────────────┤
│ • Anel (2.5g)  │
│ • Brilhante 25 │
└────────┬───────┘
         │ Separa em componentes:
         │  • Ouro: 2.45g
         │  • Brilhante: 1un
         v
    ┌─────────────┐
    │ ESTOQUE     │  ← Estoque.sql: Insumos + 2.45g ouro
    │ ATUALIZADO  │  ← Balanço Consolidado.sql: Novo saldo
    └─────────────┘
         │
         v
    Disponível para
    próxima produção!
```

---

## Decisões de Onde Usar Cada Query

### 📊 Dashboard de Vendas
```
Use: Pedidos.sql
     Itens do Pedido.sql
     Clientes.sql (dimensão)
     Dias Úteis.sql (para cálculo de promessas)
```

### 📈 Painel de Produção
```
Use: OPs Geradas.sql (status das OPs)
     Movimentações.sql (progresso em tempo real)
     Etapas de Produção.sql (qual etapa agora?)
     Detalhe das OPs.sql (observações/bloqueios)
```

### 📦 Controle de Estoque
```
Use: Estoque.sql (posição atual)
     Balanço Consolidado.sql (posição por período)
     Balanços.sql (auditoria de contagem)
     Movimentação de Materia Prima.sql (fluxo)
     Movimentação de Insumos.sql (saídas/perdas)
```

### 📋 Orçamentação / Previsão
```
Use: Composição de Produtos.sql (custo padrão)
     Composição das OPs.sql (custo específico)
     Cadastro de Produtos.sql (especificações)
     Cadastro de Insumos.sql (disponibilidade)
     Dias Úteis.sql (prazo de entrega)
```

### 🎯 Análise de Performance
```
Use: OPs Geradas.sql (taxa de finalização)
     Movimentações.sql (tempo por etapa)
     Desmanche.sql (taxa de retrabalho)
     Estoque.sql (giro de estoque)
```

### 📠 Operacional/Fiscal
```
Use: NFs.sql (faturamento)
     Finalizações.sql (pendentes de NF)
     Etiqueta das OPs.sql (rastreamento)
```

---

## 🎓 Como Usar Este Documento

### Se você trabalha em:

**VENDAS:**
- Leia: Fluxo 1 (até etapa 2️⃣)
- Use: Pedidos.sql, Itens do Pedido.sql
- Entenda: Como um pedido vira OP

**PLANEJAMENTO:**
- Leia: Fluxo 1 (etapa 2️⃣ a 4️⃣) + Fluxo 2
- Use: Composição das OPs.sql, Estoque.sql
- Entenda: Quanto de insumo vou usar? Tenho disponível?

**ALMOXARIFADO:**
- Leia: Fluxo 2 + Fluxo 3
- Use: Movimentação de Materia Prima.sql, Estoque.sql, Balanços.sql
- Entenda: Saída/entrada de materiais, divergências

**PRODUÇÃO:**
- Leia: Fluxo 1 (etapa 5️⃣ a 6️⃣)
- Use: Movimentações.sql, Etapas de Produção.sql, Etiqueta das OPs.sql
- Entenda: Qual é a minha OP? Qual é a próxima etapa?

**CONTROLE QUALIDADE:**
- Leia: Fluxo 1 (etapa 6️⃣) + Fluxo 4
- Use: Finalização.sql, Etiqueta das OPs.sql, Desmanche.sql
- Entenda: Finalizações prontas, retrabalhos

**FISCAL/FINANCEIRO:**
- Leia: Fluxo 1 (etapa 7️⃣ a 8️⃣)
- Use: NFs.sql, Finalizações.sql
- Entenda: Quando foi faturado? Qual é o status?

---

**Documento versão 1.0 - 27 de Fevereiro de 2026**  
*Para entender relacionamentos e dependências entre queries, use este documento.*
