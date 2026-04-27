/*
  # Grant permissões lancamentos_financeiros

  OFX import tenta inserir em lancamentos_financeiros mas recebe
  "permission denied" — mesmo padrão de conciliacao_bancaria.
*/

GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.lancamentos_financeiros
  TO anon, authenticated, service_role;

-- RLS policies (caso estejam faltando)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'lancamentos_financeiros'
      AND policyname = 'Permitir leitura lancamentos'
  ) THEN
    CREATE POLICY "Permitir leitura lancamentos"
      ON public.lancamentos_financeiros FOR SELECT
      TO anon, authenticated USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'lancamentos_financeiros'
      AND policyname = 'Permitir inserção lancamentos'
  ) THEN
    CREATE POLICY "Permitir inserção lancamentos"
      ON public.lancamentos_financeiros FOR INSERT
      TO anon, authenticated WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'lancamentos_financeiros'
      AND policyname = 'Permitir atualização lancamentos'
  ) THEN
    CREATE POLICY "Permitir atualização lancamentos"
      ON public.lancamentos_financeiros FOR UPDATE
      TO anon, authenticated USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'lancamentos_financeiros'
      AND policyname = 'Permitir exclusão lancamentos'
  ) THEN
    CREATE POLICY "Permitir exclusão lancamentos"
      ON public.lancamentos_financeiros FOR DELETE
      TO anon, authenticated USING (true);
  END IF;
END $$;
