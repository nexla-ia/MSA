/*
  # Exclusão completa de transferência de pontos

  Quando uma transferência é excluída, deve:
  1. Reverter pontos diretamente em estoque_pontos (sem criar entradas de estorno)
  2. Apagar todos os registros de histórico (estoque_movimentacoes) gerados por ela
  3. Apagar registros financeiros (contas_receber, contas_pagar)
  4. Apagar o registro da transferência

  Diferente de reverter_transferencia_pontos (que criava estorno no histórico),
  esta função limpa completamente como se a operação nunca tivesse existido.
*/

CREATE OR REPLACE FUNCTION public.excluir_transferencia_hard(
  p_transfer_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_mov         RECORD;
  v_saldo_atual numeric;
  v_valor_total numeric;
  v_novo_saldo  numeric;
  v_novo_valor  numeric;
BEGIN
  -- Verificar se a transferência existe
  IF NOT EXISTS (SELECT 1 FROM transferencia_pontos WHERE id = p_transfer_id) THEN
    RAISE EXCEPTION 'Transferência % não encontrada', p_transfer_id;
  END IF;

  -- 1. Reverter o impacto de cada movimentação diretamente em estoque_pontos
  --    (sem chamar atualizar_estoque_pontos para não criar novo histórico)
  FOR v_mov IN
    SELECT *
    FROM estoque_movimentacoes
    WHERE referencia_id   = p_transfer_id
      AND referencia_tabela = 'transferencia_pontos'
    ORDER BY created_at ASC
  LOOP
    SELECT saldo_atual, valor_total
    INTO v_saldo_atual, v_valor_total
    FROM estoque_pontos
    WHERE parceiro_id = v_mov.parceiro_id AND programa_id = v_mov.programa_id;

    IF NOT FOUND THEN CONTINUE; END IF;

    IF v_mov.tipo = 'transferencia_saida' THEN
      -- Origem foi debitada → devolver pontos e valor monetário
      v_novo_saldo := v_saldo_atual + v_mov.quantidade;
      v_novo_valor := v_valor_total + v_mov.valor_total;

    ELSIF v_mov.tipo IN ('transferencia_entrada', 'transferencia_bonus', 'bumerangue_retorno') THEN
      -- Destino foi creditado → remover pontos
      v_novo_saldo := GREATEST(0, v_saldo_atual - v_mov.quantidade);
      -- Entradas de transferência geralmente têm valor_total = 0 (só movem pontos)
      -- Se houve valor monetário (bônus com custo), subtrair também
      IF v_mov.valor_total > 0 THEN
        v_novo_valor := GREATEST(0, v_valor_total - v_mov.valor_total);
      ELSE
        v_novo_valor := v_valor_total;
      END IF;

    ELSE
      CONTINUE;
    END IF;

    UPDATE estoque_pontos
    SET
      saldo_atual = v_novo_saldo,
      valor_total = GREATEST(0, v_novo_valor),
      custo_medio = CASE
        WHEN v_novo_saldo > 0 THEN (GREATEST(0, v_novo_valor) / v_novo_saldo) * 1000
        ELSE 0
      END,
      updated_at  = now()
    WHERE parceiro_id = v_mov.parceiro_id AND programa_id = v_mov.programa_id;

  END LOOP;

  -- 2. Apagar TODO o histórico desta transferência (original + qualquer estorno anterior)
  DELETE FROM estoque_movimentacoes
  WHERE referencia_id = p_transfer_id
    AND referencia_tabela IN ('transferencia_pontos', 'estorno_transferencia');

  -- 3. Apagar registros financeiros gerados pela transferência
  DELETE FROM contas_receber
  WHERE origem_tipo = 'transferencia_pontos' AND origem_id = p_transfer_id;

  DELETE FROM contas_pagar
  WHERE origem_tipo = 'transferencia_pontos' AND origem_id = p_transfer_id;

  -- 4. Apagar a transferência
  DELETE FROM transferencia_pontos WHERE id = p_transfer_id;

END;
$$;

COMMENT ON FUNCTION public.excluir_transferencia_hard(uuid) IS
'Exclui transferência de pontos completamente: reverte saldo em estoque_pontos sem criar
entradas de estorno, apaga todos os registros de histórico e financeiros associados.
Resultado: como se a operação nunca tivesse existido.';
