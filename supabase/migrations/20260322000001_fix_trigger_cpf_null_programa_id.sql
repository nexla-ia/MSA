/*
  # Fix trigger_incrementar_cpf — null programa_id

  ## Problema
  Ao criar um Programa/Clube sem selecionar programa,
  o trigger tentava inserir em parceiro_programa_cpfs_controle
  com programa_id = NULL, violando o NOT NULL constraint.

  ## Solução
  Adicionar verificação de programa_id IS NOT NULL
  e parceiro_id IS NOT NULL antes de chamar incrementar_cpf_emitido.
*/

CREATE OR REPLACE FUNCTION trigger_incrementar_cpf()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.tem_clube = false
     AND NEW.status_programa_id IS NOT NULL
     AND NEW.programa_id IS NOT NULL
     AND NEW.parceiro_id IS NOT NULL
  THEN
    PERFORM incrementar_cpf_emitido(NEW.parceiro_id, NEW.programa_id);
  END IF;

  RETURN NEW;
END;
$$;
