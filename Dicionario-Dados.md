# 📚 Dicionário de Dados - Tabelas SQL Server

**Versão:** 1.0  
**Data:** 27 de Fevereiro de 2026  
**Sistema:** SIGMATEC (ERP para Joalharia)  
**Banco de Dados:** SQL Server

---

## 📋 Índice

1. [Visão Geral e Convenções](#visão-geral-e-convenções)
2. [Tabelas Centrais (Sig*)](#tabelas-centrais)
3. [Hierarquia de Relacionamentos](#hierarquia-de-relacionamentos)
4. [Tipos de Dados Comuns](#tipos-de-dados-comuns)
5. [Glossário de Abreviaturas](#glossário-de-abreviaturas)

---

## Visão Geral e Convenções

**Prefixo Padrão:** Todas as tabelas de negócio começam com `Sig` (SIGMA/SIGMATEC)

**Convenções de Nomenclatura:**
- Identificadores em português com abreviaturas: `cpros` (código produto), `qtds` (quantidades), `datas`, `totas`
- Campos numéricos terminam em `s` para plural: `nopes` (número pedido), `emps` (empresas)
- Campos de descrição: `[nome]s` ou `d[sigla]s`: `dpros` (descrição produto), `rclis` (razão cliente)
- Status/códigos: campos numéricos com valores 1-N ou alfanuméricos curtos

**Tipos Principais:**
- VARCHAR(50) - Códigos e identificadores curtos
- VARCHAR(250) - Descrições
- INTEGER/NUMERIC - Quantidades, códigos, IDs
- DECIMAL(15,2) - Valores monetários
- DATETIME - Datas e timestamps

---

## Tabelas Centrais

### 1. SigMvCab - Cabeçalho de Movimentações

**Descrição:** Tabela central que registra TODAS as operações do sistema (Pedidos, Transferências, Produções, Desmanches, etc)

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `empdopnums` | VARCHAR(50) | **Chave Primária.** Identificador único da movimentação (Empresa+Documento+Série+Número) | EMP001-DOC-001-00001 |
| `datas` | DATETIME | Data da operação | 2026-02-27 10:30:00 |
| `numes` | INTEGER | Séries/tipo de documento | 1, 2, 3 |
| `emps` | VARCHAR(10) | Código da empresa | EMP001 |
| `dopes` | VARCHAR(30) | Tipo de documento (tipo de operação) | PEDIDO_ENCOMENDA, PEDIDO_FABRICA, TRANSFERENCIA, PRODUCAO |
| `contads` | VARCHAR(50) | Conta de destino (para onde vai) | ARMAZEM, PRODUCAO, CLIENTE |
| `contaos` | VARCHAR(50) | Conta de origem (de onde vem) | FORNECEDOR, ARMAZEM, PRODUCAO |
| `observacoes` | VARCHAR(MAX) | Texto com observações da operação | "Pedido prioritário", "Material fora de especificação" |
| `status` | INTEGER | Status da movimentação | 0=Aberta, 1=Fechada, 2=Cancelada |
| `usuario_criacao` | VARCHAR(50) | Quem criou | ADMIN, VENDEDOR01 |
| `data_criacao` | DATETIME | Quando foi criada | 2026-02-27 |

**Relacionamentos:**
- **SigMvItn** (1:N) - Cada movimentação tem múltiplos itens
- **SigOpPic** (1:N) - Pedido gera múltiplas OPs
- **SigCdCli** via `contads`/`contaos` - Contas origem/destino

**Exemplos de DOPES (tipos de operação):**
```
PEDIDO_ENCOMENDA        → Pedido de cliente externo
PEDIDO_FABRICA          → Produção interna
PEDIDO_PILOTO           → Produto experimental
TRANSFERENCIA           → Movimentação entre contas
DESMANCHE               → Desmontagem de produto
CONSERTO                → Reparo de produto
AJUSTE_INVENTARIO       → Correção de estoque
```

---

### 2. SigMvItn - Itens de Movimentações

**Descrição:** Detalha cada item (produto/insumo) dentro de uma movimentação

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `empdopnums` | VARCHAR(50) | **FK SigMvCab.** Referência para cabeçalho | EMP001-DOC-001-00001 |
| `sequence_number` | INTEGER | Sequência do item dentro da movimentação | 1, 2, 3, 10 |
| `cpros` | VARCHAR(50) | Código do produto/insumo | ANEL001, AU_FINO, BRILHANTE_25_VVS |
| `qtds` | DECIMAL(10,3) | Quantidade do produto | 5.500 (gramas para ouro), 12 (unidades para brincos) |
| `units` | VARCHAR(10) | Unidade de medida | G (gramas), UN (unidades), KG, ML |
| `totas` | DECIMAL(15,2) | Valor total do item | 1250.50 |
| `unit_valu` | DECIMAL(15,2) | Valor unitário | 227.36 |
| `moevs` | VARCHAR(5) | Moeda (USD, AU, BRL) | USD, AU, BRL |
| `especificacoes` | VARCHAR(250) | Detalhes técnicos do item | "Brilhante 25 quilates VVS1", "Ouro 18K" |
| `numero_serie` | VARCHAR(50) | Código de barras ou série do item | "123456789", "ANEL-2026-001" |

**Relacionamentos:**
- **SigMvCab** (N:1) - Cada item pertence a uma movimentação
- **SigCdPro** via `cpros` - Informações do produto
- **SIGPRCPO** via `cpros` - Se é produto, acessa sua composição

**Exemplos de Unidades:**
- **G** = Gramas (para materiais preciosos)
- **UN** = Unidades (para produtos finais)
- **KG** = Quilogramas
- **ML** = Mililitros (para líquidos)
- **CX** = Caixas

---

### 3. SigOpPic - Ordens de Produção

**Descrição:** Rastreia cada Ordem de Produção (OP) com hierarquia de OPs mãe/filha

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `nops` | VARCHAR(50) | **Chave Primária.** Número único da OP | OP001523, OP002100 |
| `empdopnums` | VARCHAR(50) | **FK SigMvCab.** Vinculação com pedido origem | EMP001-DOC-001-00001 |
| `cpros` | VARCHAR(50) | Código do produto a ser produzido | ANEL_NOIVA_001, BRINCO_PRATA |
| `qtds` | DECIMAL(10,3) | Quantidade a produzir | 5.000 (gramas para ouro) |
| `status_op` | INTEGER | Status da OP | 0=Aberta, 1=Em Produção, 2=Finalizada, 3=Cancelada |
| `data_abertura` | DATETIME | Quando a OP foi criada | 2026-02-27 09:00:00 |
| `data_entrega` | DATETIME | Data prevista de entrega | 2026-03-10 |
| `data_finalizacao` | DATETIME | Quando foi realmente finalizada | 2026-03-09 15:30:00 |
| `nopmaes` | VARCHAR(50) | **Número da OP mãe** (se for sub-OP) | OP001500, NULL |
| `nivel_hierarquia` | INTEGER | Profundidade na hierarquia (0=OP raiz, até 8 níveis) | 0, 1, 2, ..., 8 |
| `contads` | VARCHAR(50) | Conta de destino do produto | ESTOQUE_PRODUTO_ACABADO, CLIENTE |
| `observacoes` | VARCHAR(MAX) | Notas sobre a OP | "Prioridade alta", "Aguardando pedra do cliente" |

**Relacionamentos:**
- **SigMvCab** via `empdopnums` - Pedido que originou a OP
- **SigCdPro** via `cpros` - Produto a produzir
- **SIGPRCPO** via `cpros` - Composição (insumos necessários)
- **SigOpPic** (Self-Join) via `nopmaes` - Hierarquia de OPs

**Exemplos de Hierarquia:**
```
OP001500 (ANEL_NOIVA - 10 unidades) [Nível 0 - OP mãe]
  ├─ OP001501 (SUPORTE_OURO - 3g) [Nível 1 - Sub-OP filha]
  ├─ OP001502 (GEMA_CORTE - 5un) [Nível 1 - Sub-OP filha]
  │   └─ OP001503 (CORTE_BRILHANTE - 5un) [Nível 2 - Sub-sub-OP]
  └─ OP001504 (POLIMENTO - 10un) [Nível 1 - Sub-OP filha]
```

**Nota Importante:** A hierarquia permite rastrear como uma OP grande é quebrada em operações menores especializadas.

---

### 4. SigCdPro - Cadastro de Produtos/Insumos

**Descrição:** Tabela mestre de todos os produtos (finais) e insumos (matérias-primas)

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `cpros` | VARCHAR(50) | **Chave Primária.** Código único do produto | ANEL001, AU_FINO, BRILHANTE_25_VVS |
| `dpros` | VARCHAR(250) | Descrição completa | "Anel de Noiva em Ouro Branco 18K com Brilhantes" |
| `reffs` | VARCHAR(50) | Referência/SKU alternativa | "RFQ-2026-0001", "AU18K-001" |
| `tipo_produto` | VARCHAR(20) | Se é PF (produto final) ou INS (insumo) | PF, INS, COMPON |
| `grupo_produto` | VARCHAR(50) | Categoria | ANEIS, BRINCOS, OURO, BRILHANTES, INSUMOS |
| `codcors` | VARCHAR(20) | Código de cor/tonalidade | OURO_BRANCO_18K, OURO_AMARELO_24K, PRATA_FINA |
| `mercs` | VARCHAR(50) | Tipo de mercadoria | OURO_FINO, BRILHANTE, PLATINA, PRATA, GEMA |
| `peso_padrao` | DECIMAL(10,3) | Peso padrão do item | 2.50 (gramas) |
| `valor_unitario` | DECIMAL(15,2) | Valor base | 125.00 |
| `status_produto` | INTEGER | Se está ativo | 0=Inativo, 1=Ativo |
| `unidade_medida` | VARCHAR(10) | Unidade padrão | G, UN, KG |
| `data_cadastro` | DATETIME | Quando foi criado | 2026-01-15 |
| `observacoes` | VARCHAR(MAX) | Informações adicionais | "Fornecedor: BRASIL OURO", "Certificado GIA" |

**Relacionamentos:**
- **SigMvItn** via `cpros` - Itens de movimentação
- **SigOpPic** via `cpros` - Produtos em OPs
- **SIGPRCPO** (1:N) como produto PA (Acabado)
- **SIGPRCPO** (1:N) como insumo/material

**Diferenças Tipo Produto:**
- **PF (Produto Final):** Anel, Brinco, Colar - Venda para cliente
- **INS (Insumo):** Ouro, Brilhante, Prata - Matéria-prima
- **COMPON:** Componente intermediário usado em montagem

---

### 5. SigCdCli - Cadastro de Clientes/Contas

**Descrição:** Tabela mestre de clientes externos e contas internas (departamentos, almoxarifados)

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `iclis` | VARCHAR(50) | **Chave Primária.** Código único da conta/cliente | CLI001, ARMAZEM_01, PRODUCAO_ACESSORIOS |
| `rclis` | VARCHAR(250) | Razão social/nome completo | "João Joias LTDA", "Almoxarifado Geral", "Setor de Produção" |
| `fantasia` | VARCHAR(100) | Nome fantasia | "Joias Finas", "Armazém" |
| `cnpj_cpf` | VARCHAR(20) | CNPJ ou CPF | "12345678000190", "12345678901" |
| `tipo_conta` | VARCHAR(20) | Se é cliente externo ou conta interna | CLIENTE, FORNECEDOR, INTERNO, DEPARTAMENTO |
| `grupo` | VARCHAR(50) | Agrupamento (para análise) | CLIENTES_VIP, FORNECEDORES_METAIS, ALMOXARIFADO, PRODUCAO |
| `tabela_desconto` | VARCHAR(20) | Tabela de preços/descontos aplicável | TABELA_A, TABELA_B_VIP |
| `contaven2s` | VARCHAR(50) | Conta contábil associada | "4.1.1.01", "5.1.3.01" |
| `endereco` | VARCHAR(250) | Endereço completo | "Rua das Joias, 100, São Paulo" |
| `telefone` | VARCHAR(20) | Telefone | "(11) 3030-3030" |
| `email` | VARCHAR(100) | E-mail | "contato@joiasfinas.com.br" |
| `status_cli` | INTEGER | Se está ativo | 0=Inativo, 1=Ativo |
| `data_cadastro` | DATETIME | Quando foi cadastrado | 2020-03-15 |

**Relacionamentos:**
- **SigMvCab** via `contads`/`contaos` - Contas origem/destino de movimentações
- **Pedidos** - Cliente do pedido
- **SigMvEst** via conta - Posição de estoque por conta

**Tipos de Conta Interna:**
```
ARMAZEM_GERAL        → Almoxarifado principal
PRODUCAO_ACESSORIOS  → Setor de produção de acessórios
PRODUCAO_ANEIS       → Setor de produção de anéis
LAPIDACAO            → Setor de lapidação
ACABAMENTO           → Setor de acabamento
CONTROLE_QUALIDADE   → QA
EXPEDICAO            → Expedição
```

---

### 6. SigPdMvf - Finalizações de Produção

**Descrição:** Registra quando uma OP é finalizada e pronta para faturamento

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `nops` | VARCHAR(50) | **FK SigOpPic.** Número da OP que foi finalizada | OP001523 |
| `dopps` | VARCHAR(50) | Número da movimentação de saída | EMP001-SAIDA-001-00523 |
| `datas` | DATETIME | Data da finalização | 2026-03-09 15:30:00 |
| `empdnps` | VARCHAR(50) | Documento fiscal (se houver) | "123456", NULL |
| `quantidade_finalizada` | DECIMAL(10,3) | Quantidade efetivamente produzida | 5.000 |
| `codigo_barras` | VARCHAR(50) | Código de rastreamento | "ANEL-2026-001-001" |
| `status_nf` | INTEGER | Se já foi faturada | 0=Não Faturada, 1=Faturada |
| `observacoes` | VARCHAR(MAX) | Notas da finalização | "Sem defeitos", "Retrabalho necessário" |

**Relacionamentos:**
- **SigOpPic** via `nops` - Qual OP foi finalizada
- **SigCbNfx** via `empdnps` - Nota fiscal que faturou

**Workflow Típico:**
```
OP Aberta → [Movimentações/Etapas] → OP Finalizada → SigPdMvf (criado) → [Aguarda Faturamento] → NF Emitida
```

---

### 7. SigMvEst - Estoque

**Descrição:** Posição atual de estoque de cada insumo/produto em cada conta

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `conta` | VARCHAR(50) | **FK SigCdCli.** Em qual conta está estocado | ARMAZEM_01, PRODUCAO |
| `cpros` | VARCHAR(50) | **FK SigCdPro.** Código do insumo/produto | AU_FINO, ANEL001 |
| `estos` | DECIMAL(15,2) | Valor total em estoque | 5000.00 |
| `sqtds` | DECIMAL(10,3) | Quantidade em estoque | 12.500 (gramas) |
| `spesos` | DECIMAL(10,3) | Peso total em estoque | 125.50 (kg) |
| `data_atualizacao` | DATETIME | Última atualização | 2026-02-27 16:45:00 |
| `status_estoque` | INTEGER | Status (ativo, bloqueado, etc) | 0=Bloqueado, 1=Disponível, 2=Em Análise |

**Relacionamentos:**
- **SigCdCli** via `conta` - Localização do estoque
- **SigCdPro** via `cpros` - O que está estocado

**Nota Importante:**
> Esta tabela é tipicamente atualizada periodicamente (através de balanços) ou em tempo real dependendo da configuração do sistema. Não deve ser atualizada diretamente; mudanças devem gerar registros em SigMvCab/SigMvItn.

---

### 8. SIGPRCPO - Composição de Produtos

**Descrição:** Define a estrutura de um produto final (Bill of Materials - BOM)

**Campos Principais:**

| Campo | Tipo | Descrição | Exemplos |
|-------|------|-----------|----------|
| `cpros` | VARCHAR(50) | **FK SigCdPro.** Produto final/pai | ANEL_NOIVA_001, BRINCO_OURO |
| `mats` | VARCHAR(50) | Código do insumo/material (matéria-prima) | AU_FINO, BRILHANTE_25_VVS, PRATA_FINA |
| `sequence` | INTEGER | Ordem de montagem | 1, 2, 3 |
| `qtds` | DECIMAL(10,3) | Quantidade do material necessário | 2.500 (gramas de ouro por anel) |
| `pesos` | DECIMAL(10,3) | Peso do material | 2.500 |
| `percent_perda` | DECIMAL(5,2) | Percentual de perda esperada durante processo | 2.50 (2.5% de perda) |
| `totas` | DECIMAL(15,2) | Custo total do material | 312.50 |
| `observacoes` | VARCHAR(250) | Especificidades da composição | "Usar apenas certificado GIA", "Polir com cuidado extra" |

**Relacionamentos:**
- **SigCdPro** (N:1) via `cpros` como produto final
- **SigCdPro** (N:1) via `mats` como insumo
- **SigOpPic** (reference) - Insumos necessários por OP

**Exemplo de Composição:**
```
Anel de Noiva (ANEL_NOIVA_001) composto de:
  ├─ Ouro Fino Branco 18K (AU_18K_BRANCO)    → 2.50 g
  ├─ Brilhante 25 quilates (BRILHANTE_25)    → 1 un
  ├─ Brilhante 10 quilates (BRILHANTE_10)    → 6 un
  └─ Mão de obra / Trabalho                   → Valor fixo
```

---

## Hierarquia de Relacionamentos

### Fluxo de Dados Completo: PEDIDO → PRODUÇÃO → ESTOQUE

```
SigMvCab (Pedido)
  ↓
  ├─ SigMvItn (Itens do pedido)
  │   └─ SigCdPro (Produto)
  │       └─ SIGPRCPO (Composição)
  │           └─ SigCdPro (Insumo)
  │
  ├─ SigCdCli (Cliente)
  │
  └─ SigOpPic (OP gerada a partir do pedido)
      ├─ SigCdPro (Produto a produzir)
      │   └─ SIGPRCPO (Insumos necessários)
      │
      ├─ SigMvCab/SigMvItn (Movimentações durante produção)
      │   └─ [Etapas de produção]
      │
      └─ SigPdMvf (Finalização)
          └─ SigCbNfx (Nota Fiscal - faturamento)
```

### Rastreamento de Estoque

```
SigMvCab (Pedido de Transferência)
  ↓
  ├─ SigCdCli (Conta origem)
  ├─ SigCdCli (Conta destino)
  ├─ SigMvItn (Itens: Insumos)
  │   └─ SigCdPro (Insumo movimentado)
  │
  └─ SigMvEst (Atualização de posição)
      ├─ Conta origem: qtd ↓
      └─ Conta destino: qtd ↑
```

---

## Tipos de Dados Comuns

| Tipo SQL Server | Tamanho | Uso | Exemplos |
|-----------------|---------|-----|----------|
| **VARCHAR(N)** | Até N caracteres | Códigos, nomes, descrições | VARCHAR(50) para códigos |
| **VARCHAR(MAX)** | Até 2GB | Descrições longas, observações | Comentários de OP |
| **INTEGER** | 4 bytes | Contadores, códigos numéricos, status | Status (0, 1, 2) |
| **DECIMAL(p,s)** | Variável | Valores monetários, quantidades com decimais | DECIMAL(15,2) para reais |
| **NUMERIC(p,s)** | Variável | Sinônimo de DECIMAL | Sinônimo de DECIMAL |
| **DATETIME** | 8 bytes | Datas e horários | DATETIME |
| **DATETIME2** | 8 bytes | Datas com precisão maior | DATETIME2(7) |

---

## Glossário de Abreviaturas

Convenções usadas nos nomes de campos:

| Abreviatura | Significado | Exemplos de Campos |
|------------|-------------|------------------|
| **c** | código | `cpros` (código produto), `cclis` (código cliente) |
| **d** | descrição/dados | `dpros` (descrição produto) |
| **r** | razão (nome completo) | `rclis` (razão cliente) |
| **i** | ID/identificador | `iclis` (ID cliente) |
| **n** | número | `nopes` (número pedido), `nops` (número OP) |
| **q** | quantidade | `qtds` (quantidade) |
| **t** | total | `totas` (total) |
| **e** | estoque | `estos` (estoque), `sqtds` (estoque quantidade) |
| **s** | sistema/status | `status`, `spesos` (estoque peso) |
| **d** | data | `datas` (data) |
| **v** | valor/unidade | `totas` (total), `unit_valu` (valor unitário) |
| **p** | produto | `cpros`, `dpros` |
| **mo** | moeda | `moevs` (moeda evento) |
| **emp** | empresa | `emps`, `empdopnums` |

---

## ⚠️ Notas Especiais

1. **Chaves Primárias Compostas:**
   - `empdopnums` é geralmente a chave primária e incorpora: Empresa + Documento + Série + Número
   - Permite múltiplas empresas e séries no mesmo banco

2. **Campos de Status:**
   - Geralmente 0/1 (inativo/ativo) ou 0/1/2/3 (aberto/em progresso/fechado/cancelado)
   - Sempre consultear queries existentes para confirmar mapeamento

3. **Campos de Data:**
   - `DATETIME` é padrão SQL Server: YYYY-MM-DD HH:MM:SS.mmm
   - Queries frequentemente usam CAST/CONVERT para reformatar

4. **Quantidades e Pesos:**
   - Variam por tipo: Gramas para ouro/prata, Unidades para produtos finais
   - Campo `units` em SigMvItn especifica a unidade de `qtds`

5. **Valores Monetários:**
   - DECIMAL(15,2) padrão para precisão de centavos
   - Campo `moevs` especifica moeda (USD, AU, BRL)

---

## 📚 Como Usar Este Dicionário

### Para Entender uma Query SQL
1. Identifique a tabela principal (FROM clause)
2. Procure neste dicionário (Seção de Tabelas Centrais)
3. Leia "Campos Principais" e "Relacionamentos"
4. Use "Hierarquia de Relacionamentos" para entender joins

### Para Escrever uma Nova Query
1. Determine o domínio (Pedidos? Estoque? OPs?)
2. Identifique tabelas em "Hierarquia de Relacionamentos"
3. Consulte "Campos Principais" para saber quais campos usar
4. Verifique "Tipos de Dados" para formatar corretamente

### Para Troubleshooting
- Valores NULL inesperados? Pode ser Foreign Key não encontrada
- Quantidades erradas? Verifique campo `units` para certeza da unidade
- Status confuso? Veja exemplos nos campos de status neste dicionário

---

**Documento versão 1.0 - 27 de Fevereiro de 2026**  
*Para questões de estrutura de dados ou relacionamentos, consulte este documento ou DBA.*
