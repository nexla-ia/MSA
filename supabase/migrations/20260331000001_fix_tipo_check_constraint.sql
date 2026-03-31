/*
  # Adiciona tipos ausentes na constraint estoque_movimentacoes_tipo_check

  Os triggers usam 'transferencia_bonus', 'transferencia_pessoas_bonus' e
  'bumerangue_retorno' mas a constraint não os incluía, causando erro ao
  inserir movimentações de bônus.
*/

ALTER TABLE estoque_movimentacoes
  DROP CONSTRAINT IF EXISTS estoque_movimentacoes_tipo_check;

ALTER TABLE estoque_movimentacoes
  ADD CONSTRAINT estoque_movimentacoes_tipo_check
  CHECK (tipo = ANY (ARRAY[
    'entrada'::text,
    'saida'::text,
    'transferencia_entrada'::text,
    'transferencia_saida'::text,
    'transferencia_pessoas_entrada'::text,
    'transferencia_pessoas_saida'::text,
    'transferencia_bonus'::text,
    'transferencia_pessoas_bonus'::text,
    'bumerangue_retorno'::text
  ]));
