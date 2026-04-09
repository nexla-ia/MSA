/*
  # Fix: undo de UPDATE de compra deve usar Entrada negativa, não Saída

  ## Problema
  No trigger UPDATE (Concluído → Concluído), o undo da compra antiga
  chamava atualizar_estoque_pontos(..., 'Saída', OLD.valor_total).

  Porém, no branch 'Saída' da função, o valor monetário é recalculado como:
    v_valor_movimentacao = quantidade × custo_medio_atual / 1000
  — ignorando completamente o OLD.valor_total passado.

  Isso faz o undo remover um valor diferente do que foi originalmente adicionado,
  corrompendo o custo_medio quando o valor_milheiro de uma compra é editado.

  ## Correção
  Usar 'Entrada' com quantidade e valor_total negativos no undo.
  O branch 'Entrada' subtrai exatamente o OLD.valor_total do acumulado,
  recalculando o custo_medio corretamente.
*/

CREATE OR REPLACE FUNCTION trigger_atualizar_estoque_compras()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'Concluído' THEN
      IF NEW.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada',
        COALESCE(NEW.valor_total, 0),
        'compra',
        'Compra de pontos/milhas',
        NEW.id,
        'compras'
      );
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status = 'Pendente' AND NEW.status = 'Concluído' THEN
      IF NEW.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada',
        COALESCE(NEW.valor_total, 0),
        'compra',
        'Compra de pontos/milhas',
        NEW.id,
        'compras'
      );

    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Pendente' THEN
      IF OLD.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
        'Entrada',
        -COALESCE(OLD.valor_total, 0),
        'estorno_compra',
        'Estorno de compra de pontos/milhas',
        OLD.id,
        'compras'
      );

    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Concluído' AND (
      OLD.pontos_milhas <> NEW.pontos_milhas OR
      OLD.bonus <> NEW.bonus OR
      OLD.valor_total <> NEW.valor_total OR
      OLD.parceiro_id <> NEW.parceiro_id OR
      OLD.programa_id <> NEW.programa_id
    ) THEN
      IF OLD.observacao = 'Compra no Carrinho' THEN
        RETURN NEW;
      END IF;

      -- Undo: usar Entrada negativa para subtrair o valor exato da compra antiga
      -- (branch Saída ignora p_valor_total e usa custo_medio atual — incorreto para undo)
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
        'Entrada',
        -COALESCE(OLD.valor_total, 0),
        'ajuste_compra',
        'Ajuste de compra - reversão',
        OLD.id,
        'compras'
      );

      -- Apply: adicionar os novos valores
      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada',
        COALESCE(NEW.valor_total, 0),
        'compra',
        'Compra de pontos/milhas (atualizada)',
        NEW.id,
        'compras'
      );
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.status = 'Concluído' AND OLD.observacao != 'Compra no Carrinho' THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
        'Entrada',
        -COALESCE(OLD.valor_total, 0),
        'exclusao_compra',
        'Exclusão de compra de pontos/milhas',
        OLD.id,
        'compras'
      );
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
