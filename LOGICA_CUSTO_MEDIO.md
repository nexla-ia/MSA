# Lógica de Custo Médio Ponderado - Sistema ERP

## 📊 Visão Geral

O sistema utiliza **custo médio ponderado** para controlar o valor do estoque de pontos/milhas. Todas as movimentações são processadas pela função central `atualizar_estoque_pontos()`.

---

## 🎯 Função Central: `atualizar_estoque_pontos()`

### Estrutura da Tabela `estoque_pontos`

```sql
- id (uuid)
- parceiro_id (uuid)
- programa_id (uuid)
- saldo_atual (numeric) -- Quantidade de pontos
- valor_total (numeric) -- Valor monetário total (R$)
- custo_medio (numeric) -- Custo por 1000 pontos (R$/mil)
- updated_at (timestamp)
```

### Fórmulas

#### ENTRADA (Compra/Crédito)
```
valor_total_novo = valor_total_anterior + valor_entrada
saldo_novo = saldo_anterior + quantidade_entrada

custo_medio_novo = (valor_total_novo / saldo_novo) × 1000
```

#### SAÍDA (Venda/Transferência)
```
valor_saida = quantidade_saida × (custo_medio_atual / 1000)
valor_total_novo = valor_total_anterior - valor_saida
saldo_novo = saldo_anterior - quantidade_saida

custo_medio_novo = custo_medio_atual (MANTÉM!)
```

---

## 📥 ENTRADAS (Aumentam Estoque)

### 1. Compras de Pontos/Milhas (`compras`)

**Trigger:** `trigger_atualizar_estoque_compras()`

**Condição:** Status = `"Concluído"`

**Valores:**
- Quantidade: `pontos_milhas + bonus`
- Valor: `valor_total`

**Exemplo:**
```
Estoque: 10.000 pts @ R$ 40/mil = R$ 400
Compra: 5.000 pts por R$ 250

Novo estoque:
  Saldo = 15.000 pts
  Valor = R$ 650
  Custo médio = (650 / 15.000) × 1000 = R$ 43,33/mil
```

✅ **Valor entra no custo médio**

---

### 2. Compras Bonificadas (`compra_bonificada`)

**Trigger:** `trigger_atualizar_estoque_compra_bonificada()`

**Valores:**
- Quantidade: `quantidade_pontos`
- Valor: `custo_total`

✅ **Valor entra no custo médio**

---

### 3. Créditos de Clube - MENSAL (`programas_clubes`)

**Função:** `processar_creditos_clubes()`

**Quando:** Dia = `dia_cobranca` do clube

**Valores:**
- Quantidade: `quantidade_pontos`
- Valor: `valor` (mensalidade do clube)

**Exemplo:**
```
Clube Smiles: R$ 799,90/mês = 20.000 pontos

Estoque antes: 15.000 pts @ R$ 43,33/mil = R$ 650
Crédito clube: 20.000 pts por R$ 799,90

Novo estoque:
  Saldo = 35.000 pts
  Valor = R$ 1.449,90
  Custo médio = (1.449,90 / 35.000) × 1000 = R$ 41,43/mil
```

✅ **Valor da mensalidade entra no custo médio**
📝 **Origem:** `'clube_credito_mensal'`

---

### 4. Créditos de Clube - BÔNUS (`programas_clubes`)

**Função:** `processar_creditos_clubes()`

**Quando:**
- Trimestral: A cada 3 meses
- Anual: A cada 12 meses
- Mensal: Todo mês

**Valores:**
- Quantidade: `bonus_quantidade_pontos`
- Valor: `0` (bônus gratuito)

**Exemplo:**
```
Bônus trimestral: 10.000 pts (grátis)

Estoque antes: 35.000 pts @ R$ 41,43/mil = R$ 1.449,90
Bônus: 10.000 pts por R$ 0

Novo estoque:
  Saldo = 45.000 pts
  Valor = R$ 1.449,90 (mantém!)
  Custo médio = (1.449,90 / 45.000) × 1000 = R$ 32,22/mil
```

❌ **Não entra valor** (dilui o custo médio)
📝 **Origem:** `'clube_credito_bonus'`

---

### 5. Créditos Retroativos

**Função:** `processar_pontos_clube_retroativos()`

**Lógica:** Divide valor total pelos meses retroativos

**Valores:**
- Quantidade: `quantidade_pontos / num_meses`
- Valor: `valor_clube / num_meses`

✅ **Valor proporcional entra no custo médio**

---

### 6. Transferência Entre Pessoas - DESTINO

**Função:** `processar_transferencia_pessoas_destino()`

**Valores:**
- Quantidade: `quantidade` recebida
- Valor: `(quantidade × custo_medio_origem / 1000) + taxa`

**Exemplo:**
```
Origem tem custo médio de R$ 40/mil
Transfere 5.000 pts com taxa de R$ 50

Valor creditado no destino:
  Valor pontos = 5.000 × (40 / 1000) = R$ 200
  Taxa = R$ 50
  Total = R$ 250
```

✅ **Herda custo médio da origem + taxa**

**Bônus:**
- Quantidade: `bonus_destino`
- Valor: `0`

❌ **Bônus não tem custo**

---

## 📤 SAÍDAS (Diminuem Estoque)

### Regra Universal de SAÍDA

```
1. Calcular valor da saída:
   valor_saida = quantidade × (custo_medio_atual / 1000)

2. Atualizar estoque:
   saldo_novo = saldo_atual - quantidade
   valor_novo = valor_total - valor_saida
   custo_medio = MANTÉM (não recalcula!)

3. Registrar no histórico:
   - tipo: 'saida'
   - quantidade: pontos saídos
   - valor_total: valor_saida calculado
   - custo_medio_anterior: custo vigente
   - custo_medio_posterior: MESMO valor (mantém)
```

---

### 1. Vendas (`vendas`)

**Função:** `processar_venda()`

**Cálculo:**
```sql
CMV = quantidade_milhas × (custo_medio / 1000)
```

**Campos registrados:**
- `custo_medio`: Custo por 1000 pontos no momento da venda
- `cmv`: Valor total do custo (IMUTÁVEL)

**Exemplo:**
```
Estoque: 45.000 pts @ R$ 32,22/mil = R$ 1.449,90
Venda: 10.000 pts

CMV = 10.000 × (32,22 / 1000) = R$ 322,20

Novo estoque:
  Saldo = 35.000 pts
  Valor = 1.449,90 - 322,20 = R$ 1.127,70
  Custo médio = R$ 32,22/mil (MANTÉM!)

Verificação: 35.000 × 32,22 / 1000 = 1.127,70 ✓
```

✅ **Valor é subtraído do estoque**
📊 **CMV registrado para análise de rentabilidade**

**Reversão de Venda:**
- Função: `reverter_venda()`
- Devolve quantidade E valor (CMV) ao estoque
- Tipo: `'Entrada'` com valor = CMV original

---

### 2. Transferência de Pontos (`transferencia_pontos`)

**Função:** `processar_transferencia_origem()`

**Origem (débito):**
```sql
PERFORM atualizar_estoque_pontos(
  parceiro_id,
  origem_programa_id,
  origem_quantidade,
  'Saída',
  0  -- Valor calculado automaticamente
);
```

**Destino (crédito):**
```sql
PERFORM atualizar_estoque_pontos(
  parceiro_id,
  destino_programa_id,
  destino_quantidade,
  'Entrada',
  valor_calculado  -- Baseado no custo da origem
);
```

✅ **Valor é subtraído na origem**
✅ **Valor é adicionado no destino**

---

### 3. Transferência Entre Pessoas - ORIGEM

**Função:** `processar_transferencia_pessoas_origem()`

**Débito:**
```sql
quantidade_total = quantidade + custo_quantidade (se houver)

PERFORM atualizar_estoque_pontos(
  origem_parceiro_id,
  programa_id,
  quantidade_total,
  'Saída',
  0  -- Valor calculado automaticamente
);
```

**Exemplo:**
```
Estoque: 35.000 pts @ R$ 32,22/mil = R$ 1.127,70
Transfere: 5.000 pts

Valor debitado = 5.000 × (32,22 / 1000) = R$ 161,10

Novo estoque:
  Saldo = 30.000 pts
  Valor = 1.127,70 - 161,10 = R$ 966,60
  Custo médio = R$ 32,22/mil (MANTÉM!)
```

✅ **Valor é subtraído da origem**

---

## 📝 Histórico: `estoque_movimentacoes`

Todas as movimentações são registradas com:

```sql
- id
- parceiro_id
- programa_id
- tipo ('entrada' ou 'saida')
- quantidade
- valor_total (calculado)
- saldo_anterior
- saldo_posterior
- custo_medio_anterior
- custo_medio_posterior
- origem (ex: 'compra', 'venda', 'clube_credito_mensal')
- observacao
- referencia_id (FK para registro original)
- referencia_tabela (nome da tabela)
- created_at
```

### Integridade Histórica

✅ **Cada registro é IMUTÁVEL**
✅ **Saídas registram o custo médio VIGENTE no momento**
✅ **Novas entradas NÃO recalculam saídas anteriores**

---

## 🔄 Fluxo Completo de Exemplo

```
INÍCIO: Estoque vazio

1. COMPRA: 10.000 pts por R$ 400
   → Saldo: 10.000 | Valor: R$ 400 | CM: R$ 40,00/mil

2. CLUBE MENSAL: 20.000 pts por R$ 799,90
   → Saldo: 30.000 | Valor: R$ 1.199,90 | CM: R$ 40,00/mil

3. CLUBE BÔNUS: 10.000 pts por R$ 0
   → Saldo: 40.000 | Valor: R$ 1.199,90 | CM: R$ 30,00/mil

4. VENDA: 15.000 pts
   CMV = 15.000 × 30,00 / 1000 = R$ 450,00
   → Saldo: 25.000 | Valor: R$ 749,90 | CM: R$ 30,00/mil ✓

5. COMPRA: 5.000 pts por R$ 200
   → Saldo: 30.000 | Valor: R$ 949,90 | CM: R$ 31,66/mil

6. VENDA: 10.000 pts
   CMV = 10.000 × 31,66 / 1000 = R$ 316,60
   → Saldo: 20.000 | Valor: R$ 633,30 | CM: R$ 31,66/mil ✓
```

---

## ✅ Validação de Integridade

A qualquer momento, deve ser verdade:

```
valor_total = saldo_atual × (custo_medio / 1000)
```

Se essa equação não for verdadeira, há inconsistência no estoque!

---

## 🚀 Funções que Usam a Lógica Correta

✅ `atualizar_estoque_pontos()` - Função central
✅ `trigger_atualizar_estoque_compras()` - Compras
✅ `trigger_atualizar_estoque_compra_bonificada()` - Compras bonificadas
✅ `processar_creditos_clubes()` - Créditos de clube
✅ `processar_venda()` - Vendas
✅ `reverter_venda()` - Reversão de vendas
✅ `processar_transferencia_origem()` - Transferências de pontos
✅ `processar_transferencia_destino()` - Recebimento de pontos
✅ `processar_transferencia_pessoas_origem()` - Transferências entre pessoas (origem)
✅ `processar_transferencia_pessoas_destino()` - Transferências entre pessoas (destino)

---

## 📅 Data de Atualização

**Última atualização:** 04/02/2026

**Migrations aplicadas:**
- `20260204135000_fix_saida_subtract_valor_from_estoque.sql`
- `20260204140000_fix_transferencia_pessoas_usar_atualizar_estoque.sql`
- `20260204141000_fix_transferencia_pessoas_destino_usar_atualizar_estoque.sql`
- `20260204142000_fix_vendas_usar_atualizar_estoque.sql`
- `20260204143000_fix_reverter_venda_usar_atualizar_estoque.sql`
