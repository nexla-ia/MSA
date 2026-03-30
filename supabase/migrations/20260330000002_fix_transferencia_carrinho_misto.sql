/*
  # Fix Transferência Carrinho Misto

  ## Problema
  Quando realizar_compra_carrinho = true com pontos mistos (parte do estoque + parte
  do carrinho), o trigger:
  1. Pulava TODO o débito da origem (deveria debitar apenas a parte do estoque)
  2. Usava só compra_valor_total para valorar o destino (deveria incluir custo da
     parte do estoque também)

  ## Correção
  - Origem: debita (origem_quantidade - compra_quantidade) do estoque
  - Destino: valorado como custo da parte do estoque + compra_valor_total
  - Se compra_quantidade = origem_quantidade (100% carrinho), nenhum débito da origem
*/

-- ==========================================
-- 1. ORIGEM: debita só a parte do estoque
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
  -- Buscar nome do programa de destino para rastreabilidade
  SELECT nome INTO v_destino_programa_nome
  FROM programas_fidelidade
  WHERE id = NEW.destino_programa_id;

  IF NEW.realizar_compra_carrinho = true THEN
    -- Compra no carrinho: debita somente a parte que vem do estoque
    -- (origem_quantidade - compra_quantidade). Se 100% veio do carrinho,
    -- compra_quantidade = origem_quantidade → nenhum débito.
    v_qtd_estoque := COALESCE(NEW.origem_quantidade, 0) - COALESCE(NEW.compra_quantidade, 0);

    IF v_qtd_estoque <= 0 THEN
      -- Todos os pontos vieram do carrinho — sem débito da origem
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

  -- Transferência normal: debita toda a origem (quantidade POSITIVA)
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
-- 2. DESTINO: valor = custo estoque + compra carrinho
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
  v_observacao_destino   text;
  v_qtd_estoque          decimal;
BEGIN
  -- Buscar custo médio da origem
  SELECT custo_medio INTO v_origem_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.parceiro_id
    AND programa_id = NEW.origem_programa_id;

  -- Buscar nome do programa de origem
  SELECT nome INTO v_origem_programa_nome
  FROM programas_fidelidade
  WHERE id = NEW.origem_programa_id;

  -- Definir valor e observação conforme tipo
  IF NEW.realizar_compra_carrinho = true THEN
    -- Parte do estoque: (origem_quantidade - compra_quantidade) × custo_médio
    v_qtd_estoque   := COALESCE(NEW.origem_quantidade, 0) - COALESCE(NEW.compra_quantidade, 0);
    v_valor_destino := (GREATEST(v_qtd_estoque, 0) / 1000.0) * COALESCE(v_origem_custo_medio, 0)
                       + COALESCE(NEW.compra_valor_total, 0);
    v_observacao_destino := 'Compra no Carrinho';
  ELSE
    v_valor_destino      := (NEW.destino_quantidade / 1000.0) * COALESCE(v_origem_custo_medio, 0);
    v_observacao_destino := 'Recebimento de ' || COALESCE(v_origem_programa_nome, 'origem');
  END IF;

  -- INSERT com status Concluído: creditar pontos principais
  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      v_valor_destino,
      'Transferência de Pontos',
      v_observacao_destino,
      NEW.id,
      'transferencia_pontos',
      'transferencia_entrada'
    );
  END IF;

  -- INSERT com bônus destino Concluído
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

  -- INSERT com bônus bumerangue Concluído
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

  -- UPDATE de Pendente para Concluído: creditar pontos principais
  IF (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      v_valor_destino,
      'Transferência de Pontos',
      v_observacao_destino,
      NEW.id,
      'transferencia_pontos',
      'transferencia_entrada'
    );
  END IF;

  -- UPDATE de status_bonus_destino de Pendente para Concluído
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
