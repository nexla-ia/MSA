/*
  # Grant permissões conciliacao_bancaria

  "permission denied for table" = o role authenticated/anon não tem GRANT
  na tabela. RLS só filtra linhas — o acesso base precisa ser concedido primeiro.
*/

GRANT SELECT, INSERT, UPDATE, DELETE
  ON public.conciliacao_bancaria
  TO anon, authenticated;
