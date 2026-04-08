/*
  # Adicionar RPC admin_delete_venda

  ## Problema
  O frontend chamava set_admin_mode() em uma transação e depois DELETE em outra.
  Como set_config(..., true) é transaction-local, o modo admin se perdia
  antes do DELETE acontecer, fazendo o trigger bloquear mesmo sendo admin.

  ## Solução
  Função que executa set_config + DELETE na mesma transação.
*/

CREATE OR REPLACE FUNCTION admin_delete_venda(p_venda_id uuid, p_usuario_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_nivel_acesso text;
BEGIN
  SELECT nivel_acesso INTO v_nivel_acesso
  FROM usuarios WHERE id = p_usuario_id;

  IF v_nivel_acesso IS NULL OR v_nivel_acesso != 'ADM' THEN
    RAISE EXCEPTION 'Apenas administradores podem excluir vendas.';
  END IF;

  PERFORM set_config('app.is_admin', 'true', true);

  DELETE FROM vendas WHERE id = p_venda_id;
END;
$$;

COMMENT ON FUNCTION admin_delete_venda(uuid, uuid) IS
'Exclui uma venda como administrador. set_config e DELETE ocorrem na mesma
transação, evitando o problema de transaction-local da abordagem anterior.';
