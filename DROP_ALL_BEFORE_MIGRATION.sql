/*
================================================================================
  SCRIPT DE LIMPEZA - MSA Milhas e Turismo ERP
================================================================================
  
  Este script remove todas as policies, triggers, functions e tabelas existentes
  para permitir uma execução limpa do arquivo RODAR_TODAS_MIGRATIONS.sql
  
  IMPORTANTE:
  - Execute este arquivo ANTES de rodar RODAR_TODAS_MIGRATIONS.sql
  - Isto vai APAGAR TODOS OS DADOS do banco
  - Use apenas em ambiente de desenvolvimento/testes
  
================================================================================
*/

-- Desabilita temporariamente os triggers
SET session_replication_role = 'replica';

-- Remove todas as policies RLS de todas as tabelas
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Remove todos os triggers
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
    ) LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I', 
            r.trigger_name, r.event_object_table);
    END LOOP;
END $$;

-- Remove todas as funções
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
    ) LOOP
        EXECUTE format('DROP FUNCTION IF EXISTS %I.%I(%s) CASCADE', 
            r.nspname, r.proname, r.args);
    END LOOP;
END $$;

-- Remove todas as tabelas
DROP TABLE IF EXISTS vendas_documentos CASCADE;
DROP TABLE IF EXISTS vendas CASCADE;
DROP TABLE IF EXISTS transferencia_pessoas CASCADE;
DROP TABLE IF EXISTS transferencia_pontos CASCADE;
DROP TABLE IF EXISTS tipos_compra CASCADE;
DROP TABLE IF EXISTS estoque_movimentacoes CASCADE;
DROP TABLE IF EXISTS estoque_pontos CASCADE;
DROP TABLE IF EXISTS compra_bonificada CASCADE;
DROP TABLE IF EXISTS compras CASCADE;
DROP TABLE IF EXISTS parceiro_documentos CASCADE;
DROP TABLE IF EXISTS atividades CASCADE;
DROP TABLE IF EXISTS conta_familia_historico CASCADE;
DROP TABLE IF EXISTS conta_familia CASCADE;
DROP TABLE IF EXISTS programas_clubes CASCADE;
DROP TABLE IF EXISTS usuario_permissoes CASCADE;
DROP TABLE IF EXISTS permissoes CASCADE;
DROP TABLE IF EXISTS perfis CASCADE;
DROP TABLE IF EXISTS status_programa CASCADE;
DROP TABLE IF EXISTS latam CASCADE;
DROP TABLE IF EXISTS smiles CASCADE;
DROP TABLE IF EXISTS azul CASCADE;
DROP TABLE IF EXISTS tap CASCADE;
DROP TABLE IF EXISTS accor CASCADE;
DROP TABLE IF EXISTS esfera CASCADE;
DROP TABLE IF EXISTS gov CASCADE;
DROP TABLE IF EXISTS coopera CASCADE;
DROP TABLE IF EXISTS km CASCADE;
DROP TABLE IF EXISTS hotmilhas CASCADE;
DROP TABLE IF EXISTS livelo CASCADE;
DROP TABLE IF EXISTS pagol CASCADE;
DROP TABLE IF EXISTS parceiros CASCADE;
DROP TABLE IF EXISTS logs CASCADE;
DROP TABLE IF EXISTS centro_custos CASCADE;
DROP TABLE IF EXISTS classificacao_contabil CASCADE;
DROP TABLE IF EXISTS contas_bancarias CASCADE;
DROP TABLE IF EXISTS cartoes_credito CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS lojas CASCADE;
DROP TABLE IF EXISTS programas_fidelidade CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- Remove o storage bucket se existir
DELETE FROM storage.buckets WHERE id = 'parceiro-documentos';
DELETE FROM storage.buckets WHERE id = 'vendas-documentos';

-- Reabilita os triggers
SET session_replication_role = 'origin';

-- Limpa as migrations registradas
DELETE FROM supabase_migrations.schema_migrations;
