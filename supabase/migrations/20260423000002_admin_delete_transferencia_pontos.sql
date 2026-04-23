/*
  # Função admin_delete_transferencia_pontos

  ## Problema
  O trigger processar_transferencia_origem_delete dispara no DELETE e chama
  atualizar_estoque_pontos('Saída', ...) sem checar admin mode.
  Como o set_config é transaction-local, chamá-lo num RPC separado não funciona.

  ## Solução
  Uma única função que:
  1. Verifica se é ADM
  2. Seta app.is_admin = true (mesmo transaction)
  3. Deleta contas_receber da transferência
  4. Deleta o registro — o trigger dispara e herda o bypass via atualizar_estoque_pontos

  O frontend para admin usa só este RPC, sem chamar reverter_transferencia_pontos
  nem delete() separado (que eram a causa do duplo reversal).
*/

CREATE OR REPLACE FUNCTION public.admin_delete_transferencia_pontos(
  p_transfer_id uuid,
  p_usuario_id  uuid
)
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
    RAISE EXCEPTION 'Apenas administradores podem usar esta função.';
  END IF;

  -- Admin mode: atualizar_estoque_pontos e o trigger herdam o bypass
  PERFORM set_config('app.is_admin', 'true', true);

  -- Remove contas_receber geradas por esta transferência
  DELETE FROM contas_receber
  WHERE origem_tipo = 'transferencia_pontos'
    AND origem_id = p_transfer_id;

  -- Deleta a transferência; trigger processar_transferencia_origem_delete
  -- faz a reversão de estoque automaticamente (já com bypass ativo)
  DELETE FROM transferencia_pontos WHERE id = p_transfer_id;
END;
$$;

COMMENT ON FUNCTION public.admin_delete_transferencia_pontos(uuid, uuid) IS
'Exclui transferência de pontos como administrador.
set_config, DELETE de contas_receber e DELETE da transferência ocorrem na
mesma transação — o trigger de reversão de estoque herda o bypass de saldo.';
