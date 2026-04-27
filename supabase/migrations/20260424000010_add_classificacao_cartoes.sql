/*
  # Add classificacao_contabil_id em cartoes_credito

  Permite vincular um cartão à uma classificação contábil padrão. Despesas
  deste cartão herdam essa classificação automaticamente.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='cartoes_credito'
      AND column_name='classificacao_contabil_id'
  ) THEN
    ALTER TABLE public.cartoes_credito
      ADD COLUMN classificacao_contabil_id uuid;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='cartoes_credito_classificacao_contabil_id_fkey'
  ) THEN
    ALTER TABLE public.cartoes_credito
      ADD CONSTRAINT cartoes_credito_classificacao_contabil_id_fkey
      FOREIGN KEY (classificacao_contabil_id)
      REFERENCES public.classificacao_contabil(id) ON DELETE SET NULL;
  END IF;
END $$;

NOTIFY pgrst, 'reload schema';
