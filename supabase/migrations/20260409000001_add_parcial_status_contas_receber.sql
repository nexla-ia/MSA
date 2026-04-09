/*
  # Adicionar status 'parcial' em contas_receber

  Permite registrar pagamentos parciais: a conta original recebe status 'parcial'
  com o valor_pago preenchido, e uma nova conta é criada para o saldo restante.
*/

DO $$
DECLARE
  c_name text;
BEGIN
  SELECT conname INTO c_name
  FROM pg_constraint
  WHERE conrelid = 'contas_receber'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%status_pagamento%';

  IF c_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE contas_receber DROP CONSTRAINT %I', c_name);
  END IF;
END $$;

ALTER TABLE contas_receber
  ADD CONSTRAINT contas_receber_status_pagamento_check
  CHECK (status_pagamento IN ('pendente', 'pago', 'atrasado', 'cancelado', 'parcial'));
