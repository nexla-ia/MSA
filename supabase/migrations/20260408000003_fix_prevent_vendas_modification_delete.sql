/*
  # Fix trigger prevent_vendas_modification para DELETE

  ## Problema
  Em triggers BEFORE DELETE, NEW é NULL. A função retornava RETURN NEW
  (= NULL) mesmo para admins, o que cancelava o DELETE silenciosamente
  sem lançar exceção — o frontend recebia sucesso mas o registro permanecia.

  ## Solução
  Usar TG_OP para retornar OLD (permite DELETE) ou NEW (permite UPDATE).
*/

CREATE OR REPLACE FUNCTION prevent_vendas_modification()
RETURNS TRIGGER AS $$
DECLARE
  v_is_admin text;
BEGIN
  BEGIN
    v_is_admin := current_setting('app.is_admin', true);
  EXCEPTION
    WHEN OTHERS THEN
      v_is_admin := 'false';
  END;

  IF v_is_admin = 'true' THEN
    -- Para DELETE: retornar OLD permite a exclusão
    -- Para UPDATE: retornar NEW permite a atualização
    IF TG_OP = 'DELETE' THEN
      RETURN OLD;
    ELSE
      RETURN NEW;
    END IF;
  END IF;

  RAISE EXCEPTION 'Operação não permitida: Registros de vendas não podem ser editados ou excluídos. Apenas administradores podem fazer essa operação.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
