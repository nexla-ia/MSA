/*
  # Criar tabela venda_lotes

  Registra quais lotes (compras) foram usados em cada venda por lote,
  com a quantidade debitada e o custo do lote.
*/

CREATE TABLE IF NOT EXISTS venda_lotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venda_id uuid NOT NULL REFERENCES vendas(id) ON DELETE CASCADE,
  compra_id uuid NOT NULL REFERENCES compras(id) ON DELETE CASCADE,
  pontos_usados decimal(15, 2) NOT NULL,
  valor_milheiro decimal(10, 4) NOT NULL,
  data_entrada date,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_venda_lotes_venda_id ON venda_lotes(venda_id);
CREATE INDEX IF NOT EXISTS idx_venda_lotes_compra_id ON venda_lotes(compra_id);

ALTER TABLE venda_lotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leitura de venda_lotes"
  ON venda_lotes FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "Permitir inserção de venda_lotes"
  ON venda_lotes FOR INSERT TO anon, authenticated WITH CHECK (true);

CREATE POLICY "Permitir exclusão de venda_lotes"
  ON venda_lotes FOR DELETE TO anon, authenticated USING (true);
