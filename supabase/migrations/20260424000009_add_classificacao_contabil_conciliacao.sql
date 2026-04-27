/*
  # Add classificacao_contabil_id em conciliacao_bancaria

  Substitui o uso de centro_custo_id por classificacao_contabil_id na tela
  de Conciliação. A coluna centro_custo_id permanece (não é dropada) caso
  alguém tenha preenchido manualmente.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='conciliacao_bancaria'
      AND column_name='classificacao_contabil_id'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD COLUMN classificacao_contabil_id uuid;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname='conciliacao_bancaria_classificacao_contabil_id_fkey'
  ) THEN
    ALTER TABLE public.conciliacao_bancaria
      ADD CONSTRAINT conciliacao_bancaria_classificacao_contabil_id_fkey
      FOREIGN KEY (classificacao_contabil_id)
      REFERENCES public.classificacao_contabil(id) ON DELETE SET NULL;
  END IF;
END $$;

NOTIFY pgrst, 'reload schema';
