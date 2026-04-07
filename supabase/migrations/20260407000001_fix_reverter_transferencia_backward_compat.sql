/*
  # Fix reverter_transferencia_pontos — compatibilidade com registros antigos

  Antes da migration 20260311210000, as movimentações de transferência eram gravadas com:
    - tipo = 'saida' / 'entrada'  (em vez de 'transferencia_saida' / 'transferencia_entrada')
    - referencia_tabela = NULL     (em vez de 'transferencia_pontos')

  A versão anterior da função só buscava registros com o novo formato, então
  transferências criadas antes de 2026-03-11 nunca tinham seus estoques revertidos.

  Esta migration substitui a função para aceitar ambos os formatos.
*/

CREATE OR REPLACE FUNCTION reverter_transferencia_pontos(p_transfer_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_transfer          transferencia_pontos%ROWTYPE;
  v_mov               RECORD;
  v_warnings          text[] := ARRAY[]::text[];
  v_origem_nome       text;
  v_destino_nome      text;
  v_saldo_disponivel  numeric;
  v_reverso_qtd       numeric;
BEGIN
  -- Carregar a transferência
  SELECT * INTO v_transfer FROM transferencia_pontos WHERE id = p_transfer_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Transferência % não encontrada', p_transfer_id;
  END IF;

  SELECT nome INTO v_origem_nome
  FROM programas_fidelidade WHERE id = v_transfer.origem_programa_id;

  SELECT nome INTO v_destino_nome
  FROM programas_fidelidade WHERE id = v_transfer.destino_programa_id;

  -- Processar cada movimentação ligada a esta transferência (mais antiga primeiro).
  -- Aceita tanto o formato antigo (referencia_tabela IS NULL, tipo 'saida'/'entrada')
  -- quanto o formato novo (referencia_tabela = 'transferencia_pontos',
  -- tipo 'transferencia_saida'/'transferencia_entrada').
  FOR v_mov IN
    SELECT *
    FROM estoque_movimentacoes
    WHERE referencia_id = p_transfer_id
      AND (
        referencia_tabela = 'transferencia_pontos'
        OR referencia_tabela IS NULL
      )
      AND tipo IN (
        'transferencia_saida', 'saida',
        'transferencia_entrada', 'entrada',
        'transferencia_bonus', 'bumerangue_retorno'
      )
    ORDER BY created_at ASC
  LOOP

    IF v_mov.tipo IN ('transferencia_saida', 'saida') THEN
      -- Origem foi debitada → creditar de volta (com o valor original)
      PERFORM atualizar_estoque_pontos(
        v_mov.parceiro_id,
        v_mov.programa_id,
        v_mov.quantidade,
        'Entrada',
        v_mov.valor_total,
        'Estorno de Transferência',
        'Estorno: transferência para ' || COALESCE(v_destino_nome, 'destino'),
        p_transfer_id,
        'estorno_transferencia',
        'transferencia_saida'
      );

    ELSIF v_mov.tipo IN ('transferencia_entrada', 'entrada', 'transferencia_bonus', 'bumerangue_retorno') THEN
      -- Destino/origem foi creditada → reverter debitando (limitado ao saldo disponível)
      SELECT saldo_atual INTO v_saldo_disponivel
      FROM estoque_pontos
      WHERE parceiro_id = v_mov.parceiro_id AND programa_id = v_mov.programa_id;

      v_saldo_disponivel := COALESCE(v_saldo_disponivel, 0);
      v_reverso_qtd := LEAST(v_mov.quantidade, v_saldo_disponivel);

      IF v_reverso_qtd < v_mov.quantidade THEN
        v_warnings := array_append(v_warnings,
          format(
            'Reversão parcial: %s pts disponíveis de %s pts necessários em %s',
            v_reverso_qtd::text,
            v_mov.quantidade::text,
            COALESCE(v_destino_nome, v_mov.programa_id::text)
          )
        );
      END IF;

      IF v_reverso_qtd > 0 THEN
        PERFORM atualizar_estoque_pontos(
          v_mov.parceiro_id,
          v_mov.programa_id,
          v_reverso_qtd,
          'Saída',
          0,
          'Estorno de Transferência',
          'Estorno: transferência de ' || COALESCE(v_origem_nome, 'origem'),
          p_transfer_id,
          'estorno_transferencia',
          'transferencia_entrada'
        );
      END IF;

    END IF;
  END LOOP;

  -- Remover contas_receber geradas por esta transferência
  DELETE FROM contas_receber
  WHERE origem_tipo = 'transferencia_pontos'
    AND origem_id = p_transfer_id;

  RETURN jsonb_build_object(
    'success', true,
    'warnings', to_jsonb(v_warnings)
  );
END;
$$;

COMMENT ON FUNCTION reverter_transferencia_pontos IS
'Reverte todas as movimentações de estoque geradas por uma transferência de pontos.
Compatível com registros antigos (tipo saida/entrada, referencia_tabela NULL)
e novos (tipo transferencia_saida/transferencia_entrada, referencia_tabela = transferencia_pontos).
Cria entradas de estorno (crédito na origem, débito no destino).
Se o destino não tiver saldo suficiente, faz reversão parcial e retorna aviso.
Não deleta o registro em transferencia_pontos — o caller é responsável por isso.';
