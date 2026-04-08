/*
  # Fix trigger DELETE de compras — NULL observacao impedia reversão do estoque

  ## Problema
  Na condição do DELETE:
    IF OLD.status = 'Concluído' AND OLD.observacao != 'Compra no Carrinho'

  Em SQL, NULL != 'Compra no Carrinho' retorna NULL (não TRUE).
  Então compras com observacao NULL nunca tinham seus pontos devolvidos ao estoque.

  ## Solução
  Usar COALESCE para tratar NULL como string vazia antes da comparação.
*/

CREATE OR REPLACE FUNCTION public.trigger_compras_after_estoque()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_saldo_atual       decimal;
  v_custo_medio_atual decimal;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'Concluído' THEN
      IF NEW.observacao = 'Compra no Carrinho' THEN
        SELECT saldo_atual, custo_medio INTO v_saldo_atual, v_custo_medio_atual
        FROM estoque_pontos
        WHERE parceiro_id = NEW.parceiro_id AND programa_id = NEW.programa_id;

        INSERT INTO estoque_movimentacoes (
          parceiro_id, programa_id, tipo, quantidade,
          saldo_anterior, saldo_posterior,
          custo_medio_anterior, custo_medio_posterior,
          valor_total, origem, observacao,
          referencia_id, referencia_tabela,
          data_operacao
        ) VALUES (
          NEW.parceiro_id, NEW.programa_id, 'entrada', NEW.pontos_milhas,
          v_saldo_atual, v_saldo_atual,
          v_custo_medio_atual, v_custo_medio_atual,
          COALESCE(NEW.valor_total, 0), 'compra', 'Compra no Carrinho',
          NEW.id, 'compras',
          COALESCE(NEW.data_entrada, CURRENT_DATE)
        );

        RETURN NEW;
      END IF;

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id, NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada', COALESCE(NEW.valor_total, 0),
        'compra', 'Compra de pontos/milhas',
        NEW.id, 'compras', NULL,
        COALESCE(NEW.data_entrada, CURRENT_DATE)
      );
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status = 'Pendente' AND NEW.status = 'Concluído' THEN
      IF NEW.observacao = 'Compra no Carrinho' THEN RETURN NEW; END IF;

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id, NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada', COALESCE(NEW.valor_total, 0),
        'compra', 'Compra de pontos/milhas',
        NEW.id, 'compras', NULL,
        COALESCE(NEW.data_entrada, CURRENT_DATE)
      );

    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Pendente' THEN
      IF OLD.observacao = 'Compra no Carrinho' THEN RETURN NEW; END IF;

      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id, OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída', COALESCE(OLD.valor_total, 0),
        'estorno_compra', 'Estorno de compra de pontos/milhas',
        OLD.id, 'compras', NULL, CURRENT_DATE
      );

    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Concluído' AND (
      OLD.pontos_milhas <> NEW.pontos_milhas OR OLD.bonus <> NEW.bonus OR
      OLD.valor_total <> NEW.valor_total OR OLD.parceiro_id <> NEW.parceiro_id OR
      OLD.programa_id <> NEW.programa_id
    ) THEN
      IF OLD.observacao = 'Compra no Carrinho' THEN RETURN NEW; END IF;

      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id, OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída', COALESCE(OLD.valor_total, 0),
        'ajuste_compra', 'Ajuste de compra - reversão',
        OLD.id, 'compras', NULL, CURRENT_DATE
      );

      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id, NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        'Entrada', COALESCE(NEW.valor_total, 0),
        'compra', 'Compra de pontos/milhas (atualizada)',
        NEW.id, 'compras', NULL,
        COALESCE(NEW.data_entrada, CURRENT_DATE)
      );
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    -- COALESCE evita que NULL != 'Compra no Carrinho' retorne NULL (falso) em vez de TRUE
    IF OLD.status = 'Concluído' AND COALESCE(OLD.observacao, '') != 'Compra no Carrinho' THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id, OLD.programa_id,
        COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0),
        'Saída', COALESCE(OLD.valor_total, 0),
        'exclusao_compra', 'Exclusão de compra de pontos/milhas',
        OLD.id, 'compras', NULL, CURRENT_DATE
      );
    END IF;
  END IF;

  IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$function$;
