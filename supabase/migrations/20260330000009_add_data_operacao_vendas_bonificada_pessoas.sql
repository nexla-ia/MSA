/*
  # Passa data_operacao nos triggers de vendas, compra bonificada e transferencia pessoas

  Complementa a migration 20260330000008: atualiza os 3 triggers restantes
  para gravar a data real da operação no histórico de movimentações.
*/

-- ============================================================
-- 1. processar_venda — passa NEW.data_venda
-- ============================================================
CREATE OR REPLACE FUNCTION processar_venda()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_saldo_atual  numeric;
  v_custo_medio  numeric;
  v_cmv          numeric;
BEGIN
  SELECT saldo_atual, custo_medio
  INTO v_saldo_atual, v_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.parceiro_id
    AND programa_id = NEW.programa_id
  FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, valor_total, custo_medio)
    VALUES (NEW.parceiro_id, NEW.programa_id, 0, 0, 0);
    v_saldo_atual := 0;
    v_custo_medio := 0;
  END IF;

  IF v_saldo_atual < NEW.quantidade_milhas THEN
    RAISE EXCEPTION 'Saldo insuficiente. Saldo atual: %, Quantidade solicitada: %',
      v_saldo_atual, NEW.quantidade_milhas;
  END IF;

  v_cmv := (NEW.quantidade_milhas * v_custo_medio / 1000);

  NEW.saldo_anterior := v_saldo_atual;
  NEW.custo_medio    := v_custo_medio;
  NEW.cmv            := v_cmv;

  IF NEW.tipo_cliente IN ('cliente_final', 'agencia_convencional') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      NEW.quantidade_milhas,
      'Saída',
      0,
      'venda',
      'Venda #' || NEW.id::text,
      NEW.id,
      'vendas',
      NULL,
      COALESCE(NEW.data_venda::timestamptz, now())
    );

    NEW.estoque_reservado    := false;
    NEW.quantidade_reservada := 0;
  ELSE
    NEW.estoque_reservado    := true;
    NEW.quantidade_reservada := NEW.quantidade_milhas;
  END IF;

  RETURN NEW;
END;
$$;

-- ============================================================
-- 2. trigger_atualizar_estoque_compra_bonificada — passa NEW.data_compra
-- ============================================================
CREATE OR REPLACE FUNCTION trigger_atualizar_estoque_compra_bonificada()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      COALESCE(NEW.quantidade_pontos, 0),
      'Entrada',
      COALESCE(NEW.custo_total, 0),
      'compra_bonificada',
      'Compra bonificada: ' || COALESCE(NEW.produto, ''),
      NEW.id,
      'compra_bonificada',
      NULL,
      COALESCE(NEW.data_compra::timestamptz, now())
    );

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.quantidade_pontos > 0 THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        COALESCE(OLD.quantidade_pontos, 0),
        'Saída',
        0,
        'ajuste_compra_bonificada',
        'Reversão por atualização de compra bonificada',
        OLD.id,
        'compra_bonificada',
        NULL,
        now()
      );
    END IF;

    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      COALESCE(NEW.quantidade_pontos, 0),
      'Entrada',
      COALESCE(NEW.custo_total, 0),
      'compra_bonificada',
      'Compra bonificada: ' || COALESCE(NEW.produto, ''),
      NEW.id,
      'compra_bonificada',
      NULL,
      COALESCE(NEW.data_compra::timestamptz, now())
    );

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.quantidade_pontos > 0 THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        COALESCE(OLD.quantidade_pontos, 0),
        'Saída',
        0,
        'exclusao_compra_bonificada',
        'Reversão por exclusão de compra bonificada: ' || COALESCE(OLD.produto, ''),
        OLD.id,
        'compra_bonificada',
        NULL,
        now()
      );
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- ============================================================
-- 3. processar_transferencia_pessoas_completa — passa NEW.data_transferencia
-- ============================================================
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_completa()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_origem_saldo         numeric;
  v_origem_custo_medio   numeric;
  v_origem_parceiro_nome text;
  v_destino_parceiro_nome text;
  v_valor_recebido       numeric;
  v_custo_transferencia  numeric;
  v_bonus_destino        integer;
  v_total_debitar        numeric;
BEGIN
  IF (TG_OP = 'INSERT' AND LOWER(NEW.status) = 'concluído') OR
     (TG_OP = 'UPDATE' AND LOWER(OLD.status) != 'concluído' AND LOWER(NEW.status) = 'concluído') THEN

    SELECT saldo_atual, custo_medio
    INTO v_origem_saldo, v_origem_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;

    IF v_origem_saldo IS NULL THEN
      RAISE EXCEPTION 'Estoque de origem não encontrado para parceiro_id=% programa_id=%',
        NEW.origem_parceiro_id, NEW.programa_id;
    END IF;

    v_origem_custo_medio := COALESCE(v_origem_custo_medio, 0);
    v_bonus_destino      := COALESCE(NEW.bonus_destino, 0);
    v_total_debitar      := NEW.quantidade + v_bonus_destino;

    IF v_origem_saldo < v_total_debitar THEN
      RAISE EXCEPTION 'Saldo insuficiente no estoque de origem. Disponível: %, Necessário: % (% + % bônus)',
        v_origem_saldo, v_total_debitar, NEW.quantidade, v_bonus_destino;
    END IF;

    SELECT nome_parceiro INTO v_destino_parceiro_nome FROM parceiros WHERE id = NEW.destino_parceiro_id;
    SELECT nome_parceiro INTO v_origem_parceiro_nome  FROM parceiros WHERE id = NEW.origem_parceiro_id;

    PERFORM atualizar_estoque_pontos(
      NEW.origem_parceiro_id,
      NEW.programa_id,
      v_total_debitar,
      'Saída',
      0,
      'transferencia_pessoas',
      'Transferência para ' || COALESCE(v_destino_parceiro_nome, 'destino'),
      NEW.id,
      'transferencia_pessoas',
      NULL,
      COALESCE(NEW.data_transferencia::timestamptz, now())
    );

    v_valor_recebido := (NEW.quantidade * v_origem_custo_medio / 1000);

    IF NEW.tem_custo = true THEN
      v_custo_transferencia := COALESCE(NEW.valor_custo, 0);
    ELSE
      v_custo_transferencia := 0;
    END IF;

    PERFORM atualizar_estoque_pontos(
      NEW.destino_parceiro_id,
      NEW.destino_programa_id,
      NEW.quantidade,
      'Entrada',
      v_valor_recebido + v_custo_transferencia,
      'transferencia_pessoas',
      'Recebido de ' || COALESCE(v_origem_parceiro_nome, 'origem'),
      NEW.id,
      'transferencia_pessoas',
      NULL,
      COALESCE(NEW.data_transferencia::timestamptz, now())
    );

    IF v_bonus_destino > 0 THEN
      PERFORM atualizar_estoque_pontos(
        NEW.destino_parceiro_id,
        NEW.destino_programa_id,
        v_bonus_destino,
        'Entrada',
        v_bonus_destino * v_origem_custo_medio / 1000,
        'transferencia_pessoas_bonus',
        'Bônus de transferência de ' || COALESCE(v_origem_parceiro_nome, 'origem'),
        NEW.id,
        'transferencia_pessoas',
        NULL,
        COALESCE(NEW.data_transferencia::timestamptz, now())
      );
    END IF;

  END IF;

  RETURN NEW;
END;
$$;
