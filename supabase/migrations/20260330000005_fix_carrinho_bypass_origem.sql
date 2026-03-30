/*
  # Fix Carrinho: compra do carrinho não entra no estoque da origem

  ## Lógica correta
  1. Compra do carrinho (observacao='Compra no Carrinho') NÃO afeta estoque_pontos
     - O registro fica em `compras` para fins de contas a pagar, mas não movimenta estoque
  2. Transfer origem debita apenas (origem_quantidade - compra_quantidade) = pontos do estoque real
  3. Transfer destino recebe: custo do estoque + compra_valor_total
  4. Custo médio da origem NÃO muda

  ## Exemplo
  - Livelo: 500k @ R$15/mil
  - Carrinho: compra 100k @ R$15 = R$1.500
  - Transferência: 600k para Smiles
  - Resultado: Livelo sai 500k → fica 0; Smiles entra 600k @ R$15/mil (correto)
*/

-- ==========================================
-- 1. COMPRAS: pula estoque quando é carrinho
-- ==========================================
CREATE OR REPLACE FUNCTION trigger_atualizar_estoque_compras()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'Concluído' THEN
      NEW.saldo_atual := COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0);

      -- Compra do carrinho não afeta estoque da origem (será processada pela transferência)
      IF NEW.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada',
        COALESCE(NEW.valor_total, 0),
        'compra',
        COALESCE(NEW.observacao, 'Compra de pontos/milhas'),
        NEW.id,
        'compras'
      );
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status = 'Pendente' AND NEW.status = 'Concluído' THEN
      NEW.saldo_atual := COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0);

      IF NEW.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada',
        COALESCE(NEW.valor_total, 0),
        'compra',
        COALESCE(NEW.observacao, 'Compra de pontos/milhas'),
        NEW.id,
        'compras'
      );

    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Pendente' THEN
      NEW.saldo_atual := 0;

      IF OLD.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída',
        COALESCE(OLD.valor_total, 0),
        'estorno_compra',
        'Estorno de compra de pontos/milhas',
        OLD.id,
        'compras'
      );

    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Concluído' THEN
      NEW.saldo_atual := COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0);

      IF OLD.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída',
        COALESCE(OLD.valor_total, 0),
        'ajuste_compra',
        'Ajuste de compra - reversão',
        OLD.id,
        'compras'
      );

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada',
        COALESCE(NEW.valor_total, 0),
        'compra',
        COALESCE(NEW.observacao, 'Compra de pontos/milhas (atualizada)'),
        NEW.id,
        'compras'
      );
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.status = 'Concluído' AND OLD.observacao != 'Compra no Carrinho' THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída',
        COALESCE(OLD.valor_total, 0),
        'exclusao_compra',
        'Exclusão de compra de pontos/milhas',
        OLD.id,
        'compras'
      );
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- 2. ORIGEM: debita só a parte do estoque real
-- ==========================================
CREATE OR REPLACE FUNCTION processar_transferencia_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_destino_programa_nome text;
  v_qtd_estoque           decimal;
BEGIN
  SELECT nome INTO v_destino_programa_nome
  FROM programas_fidelidade
  WHERE id = NEW.destino_programa_id;

  IF NEW.realizar_compra_carrinho = true THEN
    -- Debita apenas os pontos que vieram do estoque (não os do carrinho)
    v_qtd_estoque := COALESCE(NEW.origem_quantidade, 0) - COALESCE(NEW.compra_quantidade, 0);

    IF v_qtd_estoque <= 0 THEN
      RETURN NEW;
    END IF;

    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      v_qtd_estoque,
      'Saída',
      0,
      'Transferência de Pontos',
      'Transferência para ' || COALESCE(v_destino_programa_nome, 'destino'),
      NEW.id,
      'transferencia_pontos',
      'transferencia_saida'
    );

    RETURN NEW;
  END IF;

  -- Transferência normal
  PERFORM atualizar_estoque_pontos(
    NEW.parceiro_id,
    NEW.origem_programa_id,
    NEW.origem_quantidade,
    'Saída',
    0,
    'Transferência de Pontos',
    'Transferência para ' || COALESCE(v_destino_programa_nome, 'destino'),
    NEW.id,
    'transferencia_pontos',
    'transferencia_saida'
  );

  RETURN NEW;
END;
$$;

-- ==========================================
-- 3. DESTINO: custo = estoque × custo_médio + compra_valor_total
-- ==========================================
CREATE OR REPLACE FUNCTION processar_transferencia_destino()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_custo_medio   decimal;
  v_valor_destino        decimal;
  v_origem_programa_nome text;
  v_qtd_estoque          decimal;
BEGIN
  SELECT custo_medio INTO v_origem_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.parceiro_id
    AND programa_id = NEW.origem_programa_id;

  SELECT nome INTO v_origem_programa_nome
  FROM programas_fidelidade
  WHERE id = NEW.origem_programa_id;

  IF NEW.realizar_compra_carrinho = true THEN
    v_qtd_estoque   := COALESCE(NEW.origem_quantidade, 0) - COALESCE(NEW.compra_quantidade, 0);
    v_valor_destino := (GREATEST(v_qtd_estoque, 0) / 1000.0) * COALESCE(v_origem_custo_medio, 0)
                       + COALESCE(NEW.compra_valor_total, 0);
  ELSE
    v_valor_destino := (NEW.destino_quantidade / 1000.0) * COALESCE(v_origem_custo_medio, 0);
  END IF;

  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      v_valor_destino,
      'Transferência de Pontos',
      'Recebimento de ' || COALESCE(v_origem_programa_nome, 'origem'),
      NEW.id,
      'transferencia_pontos',
      'transferencia_entrada'
    );
  END IF;

  IF (TG_OP = 'INSERT' AND NEW.status_bonus_destino = 'Concluído' AND NEW.destino_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade_bonus,
      'Entrada',
      0,
      'Transferência de Pontos',
      'Bônus de ' || COALESCE(v_origem_programa_nome, 'origem'),
      NEW.id,
      'transferencia_pontos',
      'transferencia_bonus'
    );
  END IF;

  IF (TG_OP = 'INSERT' AND NEW.status_bonus_bumerangue = 'Concluído' AND NEW.bumerangue_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      NEW.bumerangue_quantidade_bonus,
      'Entrada',
      0,
      'Transferência de Pontos',
      'Bônus bumerangue',
      NEW.id,
      'transferencia_pontos',
      'bumerangue_retorno'
    );
  END IF;

  IF (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      v_valor_destino,
      'Transferência de Pontos',
      'Recebimento de ' || COALESCE(v_origem_programa_nome, 'origem'),
      NEW.id,
      'transferencia_pontos',
      'transferencia_entrada'
    );
  END IF;

  IF (TG_OP = 'UPDATE' AND OLD.status_bonus_destino = 'Pendente' AND NEW.status_bonus_destino = 'Concluído' AND NEW.destino_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade_bonus,
      'Entrada',
      0,
      'Transferência de Pontos',
      'Bônus de ' || COALESCE(v_origem_programa_nome, 'origem'),
      NEW.id,
      'transferencia_pontos',
      'transferencia_bonus'
    );
  END IF;

  RETURN NEW;
END;
$$;
