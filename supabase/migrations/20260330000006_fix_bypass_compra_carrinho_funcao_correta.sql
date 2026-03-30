/*
  # Fix bypass compra carrinho na função correta

  A função que o trigger de compras usa é trigger_compras_after_estoque(),
  não trigger_atualizar_estoque_compras(). Adicionando o bypass nela.
*/

CREATE OR REPLACE FUNCTION public.trigger_compras_after_estoque()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'Concluído' THEN
      -- Compra do carrinho não afeta estoque (processada pela transferência)
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
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída',
        COALESCE(OLD.valor_total, 0),
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

      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída',
        COALESCE(OLD.valor_total, 0),
        'ajuste_compra',
        'Ajuste de compra - reversão',
        OLD.id,
        'compras'
      );

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
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída',
        COALESCE(OLD.valor_total, 0),
        'exclusao_compra',
        'Exclusão de compra de pontos/milhas',
        OLD.id,
        'compras'
      );
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$function$;
