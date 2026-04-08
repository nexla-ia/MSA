/*
  # Fix admin_delete_venda: reverter estoque antes de deletar

  ## Problema
  reverter_venda() é AFTER UPDATE — só dispara quando status muda para 'cancelada'.
  O DELETE direto não dispara esse trigger, então os pontos não voltavam ao estoque.

  ## Solução
  1. UPDATE status = 'cancelada' (dispara reverter_venda → pontos voltam ao estoque)
  2. DELETE do registro
  Tudo na mesma transação com app.is_admin = 'true'.
*/

CREATE OR REPLACE FUNCTION admin_delete_venda(p_venda_id uuid, p_usuario_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_nivel_acesso text;
  v_status       text;
BEGIN
  SELECT nivel_acesso INTO v_nivel_acesso
  FROM usuarios WHERE id = p_usuario_id;

  IF v_nivel_acesso IS NULL OR v_nivel_acesso != 'ADM' THEN
    RAISE EXCEPTION 'Apenas administradores podem excluir vendas.';
  END IF;

  PERFORM set_config('app.is_admin', 'true', true);

  -- Buscar status atual
  SELECT status INTO v_status FROM vendas WHERE id = p_venda_id;

  -- Se não estiver cancelada, cancelar primeiro para reverter estoque
  IF v_status IS DISTINCT FROM 'cancelada' THEN
    UPDATE vendas SET status = 'cancelada', updated_at = now() WHERE id = p_venda_id;
  END IF;

  -- Agora deletar o registro
  DELETE FROM vendas WHERE id = p_venda_id;
END;
$$;
