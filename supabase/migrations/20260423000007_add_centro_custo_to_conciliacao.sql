ALTER TABLE public.conciliacao_bancaria
  ADD COLUMN IF NOT EXISTS centro_custo_id uuid REFERENCES public.centro_custos(id) ON DELETE SET NULL;
