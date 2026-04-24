/*
  # Fix: reverter_transferencia_pontos usava tipo_movimentacao errado

  ## Problema
  Ao estornar uma transferência, a função chamava atualizar_estoque_pontos com:
    - origem (crédito): p_tipo_movimentacao = 'transferencia_saida'  ← aparecia como Transferência - Saída -X no histórico
    - destino (débito):  p_tipo_movimentacao = 'transferencia_entrada' ← aparecia como Transferência - Entrada +X

  Ambos invertidos visualmente, embora o saldo_atual fosse atualizado corretamente.

  ## Solução
  Usar 'estorno_transferencia' como tipo_movimentacao em ambos os casos.
  O frontend detecta pela observação ('Estorno: transferência para' = crédito, 'de' = débito).
*/

CREATE OR REPLACE FUNCTION reverter_transferencia_pontos(p_transfer_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_transfer          transferencia_pontos%ROWTYPE;
  v_mov               RECORD;
  v_warnings          text[] := ARRAY[]::text[];
  v_origem_nome       text;
  v_destino_nome      text;
  v_saldo_disponivel  numeric;
  v_reverso_qtd       numeric;
BEGIN
  SELECT * INTO v_transfer FROM transferencia_pontos WHERE id = p_transfer_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transferência % não encontrada', p_transfer_id;
  END IF;

  SELECT nome INTO v_origem_nome
  FROM programas_fidelidade WHERE id = v_transfer.origem_programa_id;

  SELECT nome INTO v_destino_nome
  FROM programas_fidelidade WHERE id = v_transfer.destino_programa_id;

  FOR v_mov IN
    SELECT *
    FROM estoque_movimentacoes
    WHERE referencia_id = p_transfer_id
      AND referencia_tabela = 'transferencia_pontos'
    ORDER BY created_at ASC
  LOOP

    IF v_mov.tipo = 'transferencia_saida' THEN
      -- Origem foi debitada → creditar de volta
      PERFORM atualizar_estoque_pontos(
        v_mov.parceiro_id,
        v_mov.programa_id,
        v_mov.quantidade,
        'Entrada',
        v_mov.valor_total,
        'Estorno de Transferência',
        'Estorno: transferência para ' || COALESCE(v_destino_nome, 'destino'),
        p_transfer_id,
        'estorno_transferencia',
        'estorno_transferencia'  -- FIX: era 'transferencia_saida' → aparecia como Saída no histórico
      );

    ELSIF v_mov.tipo IN ('transferencia_entrada', 'transferencia_bonus', 'bumerangue_retorno') THEN
      -- Destino foi creditado → reverter debitando (limitado ao saldo)
      SELECT saldo_atual INTO v_saldo_disponivel
      FROM estoque_pontos
      WHERE parceiro_id = v_mov.parceiro_id AND programa_id = v_mov.programa_id;

      v_saldo_disponivel := COALESCE(v_saldo_disponivel, 0);
      v_reverso_qtd := LEAST(v_mov.quantidade, v_saldo_disponivel);

      IF v_reverso_qtd < v_mov.quantidade THEN
        v_warnings := array_append(v_warnings,
          format(
            'Reversão parcial: %s pts disponíveis de %s pts necessários em %s',
            v_reverso_qtd::text,
            v_mov.quantidade::text,
            COALESCE(v_destino_nome, v_mov.programa_id::text)
          )
        );
      END IF;

      IF v_reverso_qtd > 0 THEN
        PERFORM atualizar_estoque_pontos(
          v_mov.parceiro_id,
          v_mov.programa_id,
          v_reverso_qtd,
          'Saída',
          0,
          'Estorno de Transferência',
          'Estorno: transferência de ' || COALESCE(v_origem_nome, 'origem'),
          p_transfer_id,
          'estorno_transferencia',
          'estorno_transferencia'  -- FIX: era 'transferencia_entrada' → aparecia como Entrada no histórico
        );
      END IF;

    END IF;
  END LOOP;

  DELETE FROM contas_receber
  WHERE origem_tipo = 'transferencia_pontos'
    AND origem_id = p_transfer_id;

  RETURN jsonb_build_object(
    'success', true,
    'warnings', to_jsonb(v_warnings)
  );
END;
$$;
