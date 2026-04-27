/*
  # Add FKs conciliacao_bancaria

  PostgREST precisa das foreign keys declaradas para resolver joins aninhados.
  Sem elas, .select('*, venda:vendas(...)') retorna PGRST200.
*/

DO $$
BEGIN
  -- FK para vendas
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'conciliacao_bancaria_venda_id_fkey'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD CONSTRAINT conciliacao_bancaria_venda_id_fkey
      FOREIGN KEY (venda_id) REFERENCES public.vendas(id) ON DELETE SET NULL;
  END IF;

  -- FK para lancamentos_financeiros
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'conciliacao_bancaria_lancamento_id_fkey'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD CONSTRAINT conciliacao_bancaria_lancamento_id_fkey
      FOREIGN KEY (lancamento_id) REFERENCES public.lancamentos_financeiros(id) ON DELETE SET NULL;
  END IF;

  -- FK para centro_custos
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'conciliacao_bancaria_centro_custo_id_fkey'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD CONSTRAINT conciliacao_bancaria_centro_custo_id_fkey
      FOREIGN KEY (centro_custo_id) REFERENCES public.centro_custos(id) ON DELETE SET NULL;
  END IF;
END $$;

NOTIFY pgrst, 'reload schema';
