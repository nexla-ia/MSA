/*
  # Add compra_id e conta_pagar_id em conciliacao_bancaria

  Permite vincular débitos do extrato a compras de pontos/milhas e a contas
  a pagar pendentes (entrada análoga ao venda_id que existe para créditos).
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='conciliacao_bancaria'
      AND column_name='compra_id'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria ADD COLUMN compra_id uuid;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='conciliacao_bancaria'
      AND column_name='conta_pagar_id'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria ADD COLUMN conta_pagar_id uuid;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='conciliacao_bancaria_compra_id_fkey'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD CONSTRAINT conciliacao_bancaria_compra_id_fkey
      FOREIGN KEY (compra_id) REFERENCES public.compras(id) ON DELETE SET NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='conciliacao_bancaria_conta_pagar_id_fkey'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD CONSTRAINT conciliacao_bancaria_conta_pagar_id_fkey
      FOREIGN KEY (conta_pagar_id) REFERENCES public.contas_a_pagar(id) ON DELETE SET NULL;
  END IF;
END $$;

NOTIFY pgrst, 'reload schema';
