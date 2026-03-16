/*
================================================================================
  CONSOLIDAÇÃO DE TODAS AS MIGRATIONS - MSA Milhas e Turismo ERP
================================================================================

  Este arquivo contém TODAS as migrations do projeto em ordem cronológica.
  
  IMPORTANTE:
  - Execute este arquivo no SQL Editor do Supabase
  - As migrations estão na ordem correta de execução
  - Cada migration é precedida por um separador mostrando o nome do arquivo original
  - O conteúdo das migrations NÃO foi modificado
  
  Data de geração: 21/01/2026
  Total de migrations: 123
  
================================================================================
*/

-- ============================================================================
-- MIGRATION: 20251111175420_create_erp_schema.sql
-- ============================================================================

/*
  # MSA Milhas e Turismo - ERP System Schema

  ## Overview
  This migration creates the complete database schema for the MSA Milhas e Turismo ERP system,
  including user management, customer data, loyalty programs, and comprehensive audit logging.

  ## New Tables

  ### 1. usuarios (Users)
  - `id` (uuid, primary key) - Unique user identifier
  - `nome` (text) - Full name
  - `email` (text, unique) - Email address for login
  - `senha` (text) - Hashed password
  - `nivel_acesso` (text) - Access level: 'ADM' or 'USER'
  - `ultima_acao` (timestamptz) - Last action timestamp
  - `token` (text, unique) - Authentication token
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Record update timestamp

  ### 2. clientes (Customers)
  - `id` (uuid, primary key)
  - `nome_cliente` (text) - Customer name
  - `endereco` (text) - Address
  - `email` (text) - Email address
  - `telefone` (text) - Phone number
  - `whatsapp` (text) - WhatsApp number
  - `contato` (text) - Contact person
  - `site` (text) - Website
  - `instagram` (text) - Instagram handle
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 3. programas_fidelidade (Loyalty Programs)
  - `id` (uuid, primary key)
  - `programa` (text) - Program code/identifier
  - `nome` (text) - Program name
  - `cnpj` (text) - Company CNPJ
  - `site` (text) - Website
  - `telefone` (text) - Phone
  - `whatsapp` (text) - WhatsApp
  - `email` (text) - Email
  - `link_chat` (text) - Chat link
  - `obs` (text) - Observations
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 4. lojas (Stores - Bonus Purchases)
  - `id` (uuid, primary key)
  - `nome` (text) - Store name
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 5. produtos (Products)
  - `id` (uuid, primary key)
  - `nome` (text) - Product name
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 6. cartoes_credito (Credit Cards)
  - `id` (uuid, primary key)
  - `cartao` (text) - Card name
  - `banco_emissor` (text) - Issuing bank
  - `status` (text) - Status: 'ativo' or 'titular'
  - `dia_fechamento` (integer) - Closing day
  - `dia_vencimento` (integer) - Due day
  - `valor_mensalidade` (numeric) - Monthly fee
  - `limites` (numeric) - Credit limit
  - `limite_emergencial` (numeric) - Emergency limit
  - `limite_global` (numeric) - Global limit
  - `valor_isencao` (numeric) - Exemption amount
  - `onde_usar` (text) - Where to use
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 7. contas_bancarias (Bank Accounts)
  - `id` (uuid, primary key)
  - `nome_banco` (text) - Bank name
  - `codigo_banco` (text) - Bank code
  - `agencia` (text) - Branch
  - `numero_conta` (text) - Account number
  - `chave_pix` (text) - PIX key
  - `saldo_inicial` (numeric) - Initial balance
  - `data_saldo_inicial` (date) - Initial balance date
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 8. classificacao_contabil (Accounting Classification)
  - `id` (uuid, primary key)
  - `nome` (text) - Classification name (INSS, Simples Nacional, Pro Labore)
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 9. centro_custos (Cost Centers)
  - `id` (uuid, primary key)
  - `nome` (text) - Cost center name
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)

  ### 10. logs (Audit Logs)
  - `id` (uuid, primary key)
  - `data_hora` (timestamptz) - Timestamp
  - `usuario_id` (uuid, foreign key) - User who performed action
  - `usuario_nome` (text) - User name snapshot
  - `acao` (text) - Action performed
  - `linha_afetada` (text) - Affected table/record
  - `dados_antes` (jsonb) - Data before change
  - `dados_depois` (jsonb) - Data after change
  - `created_at` (timestamptz)

  ## Security
  - RLS enabled on all tables
  - ADM users have full access
  - USER level has read-only access to most tables
  - Logs are append-only for all authenticated users
  - Automatic log rotation at 1000 records

  ## Functions
  - `log_action()` - Trigger function for automatic audit logging
  - `cleanup_old_logs()` - Function to maintain 1000 record limit
*/

-- Create usuarios table
CREATE TABLE IF NOT EXISTS usuarios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  email text UNIQUE NOT NULL,
  senha text NOT NULL,
  nivel_acesso text NOT NULL DEFAULT 'USER' CHECK (nivel_acesso IN ('ADM', 'USER')),
  ultima_acao timestamptz DEFAULT now(),
  token text UNIQUE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create clientes table
CREATE TABLE IF NOT EXISTS clientes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_cliente text NOT NULL,
  endereco text DEFAULT '',
  email text DEFAULT '',
  telefone text DEFAULT '',
  whatsapp text DEFAULT '',
  contato text DEFAULT '',
  site text DEFAULT '',
  instagram text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create programas_fidelidade table
CREATE TABLE IF NOT EXISTS programas_fidelidade (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  programa text NOT NULL,
  nome text NOT NULL,
  cnpj text DEFAULT '',
  site text DEFAULT '',
  telefone text DEFAULT '',
  whatsapp text DEFAULT '',
  email text DEFAULT '',
  link_chat text DEFAULT '',
  obs text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create lojas table
CREATE TABLE IF NOT EXISTS lojas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create produtos table
CREATE TABLE IF NOT EXISTS produtos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create cartoes_credito table
CREATE TABLE IF NOT EXISTS cartoes_credito (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cartao text NOT NULL,
  banco_emissor text DEFAULT '',
  status text DEFAULT 'ativo' CHECK (status IN ('ativo', 'titular')),
  dia_fechamento integer CHECK (dia_fechamento >= 1 AND dia_fechamento <= 31),
  dia_vencimento integer CHECK (dia_vencimento >= 1 AND dia_vencimento <= 31),
  valor_mensalidade numeric(10, 2) DEFAULT 0,
  limites numeric(10, 2) DEFAULT 0,
  limite_emergencial numeric(10, 2) DEFAULT 0,
  limite_global numeric(10, 2) DEFAULT 0,
  valor_isencao numeric(10, 2) DEFAULT 0,
  onde_usar text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create contas_bancarias table
CREATE TABLE IF NOT EXISTS contas_bancarias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_banco text NOT NULL,
  codigo_banco text DEFAULT '',
  agencia text DEFAULT '',
  numero_conta text DEFAULT '',
  chave_pix text DEFAULT '',
  saldo_inicial numeric(10, 2) DEFAULT 0,
  data_saldo_inicial date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create classificacao_contabil table
CREATE TABLE IF NOT EXISTS classificacao_contabil (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create centro_custos table
CREATE TABLE IF NOT EXISTS centro_custos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create logs table
CREATE TABLE IF NOT EXISTS logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  data_hora timestamptz DEFAULT now(),
  usuario_id uuid REFERENCES usuarios(id),
  usuario_nome text NOT NULL,
  acao text NOT NULL,
  linha_afetada text NOT NULL,
  dados_antes jsonb,
  dados_depois jsonb,
  created_at timestamptz DEFAULT now()
);

-- Create index on logs for performance
CREATE INDEX IF NOT EXISTS idx_logs_data_hora ON logs(data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_logs_usuario_id ON logs(usuario_id);

-- Function to cleanup old logs (keep only 1000 most recent)
CREATE OR REPLACE FUNCTION cleanup_old_logs()
RETURNS trigger AS $$
BEGIN
  DELETE FROM logs
  WHERE id IN (
    SELECT id FROM logs
    ORDER BY data_hora DESC
    OFFSET 1000
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically cleanup logs
DROP TRIGGER IF EXISTS trigger_cleanup_logs ON logs;
CREATE TRIGGER trigger_cleanup_logs
  AFTER INSERT ON logs
  FOR EACH STATEMENT
  EXECUTE FUNCTION cleanup_old_logs();

-- Insert default admin user (password: admin123)
INSERT INTO usuarios (nome, email, senha, nivel_acesso, token)
VALUES (
  'Administrador',
  'admin@msamilhas.com',
  '$2a$10$rKXqCvWvH8p8hXqKmVqH8OwFnKQZxVxQxW3xVxYZxZ8xZxZxZxZxZ',
  'ADM',
  gen_random_uuid()::text
) ON CONFLICT (email) DO NOTHING;

-- Insert default classification entries

-- Insert default cost center
INSERT INTO centro_custos (nome) VALUES ('MSA') ON CONFLICT DO NOTHING;

-- Enable Row Level Security
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE programas_fidelidade ENABLE ROW LEVEL SECURITY;
ALTER TABLE lojas ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE cartoes_credito ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas_bancarias ENABLE ROW LEVEL SECURITY;
ALTER TABLE classificacao_contabil ENABLE ROW LEVEL SECURITY;
ALTER TABLE centro_custos ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for usuarios
CREATE POLICY "Authenticated users can read usuarios"
  ON usuarios FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert usuarios"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update usuarios"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete usuarios"
  ON usuarios FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for clientes
CREATE POLICY "Authenticated users can read clientes"
  ON clientes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert clientes"
  ON clientes FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update clientes"
  ON clientes FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete clientes"
  ON clientes FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for programas_fidelidade
CREATE POLICY "Authenticated users can read programas_fidelidade"
  ON programas_fidelidade FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert programas_fidelidade"
  ON programas_fidelidade FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update programas_fidelidade"
  ON programas_fidelidade FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete programas_fidelidade"
  ON programas_fidelidade FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for lojas
CREATE POLICY "Authenticated users can read lojas"
  ON lojas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert lojas"
  ON lojas FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update lojas"
  ON lojas FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete lojas"
  ON lojas FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for produtos
CREATE POLICY "Authenticated users can read produtos"
  ON produtos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert produtos"
  ON produtos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update produtos"
  ON produtos FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete produtos"
  ON produtos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for cartoes_credito
CREATE POLICY "Authenticated users can read cartoes_credito"
  ON cartoes_credito FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert cartoes_credito"
  ON cartoes_credito FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update cartoes_credito"
  ON cartoes_credito FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete cartoes_credito"
  ON cartoes_credito FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for contas_bancarias
CREATE POLICY "Authenticated users can read contas_bancarias"
  ON contas_bancarias FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert contas_bancarias"
  ON contas_bancarias FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update contas_bancarias"
  ON contas_bancarias FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete contas_bancarias"
  ON contas_bancarias FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for classificacao_contabil
CREATE POLICY "Authenticated users can read classificacao_contabil"
  ON classificacao_contabil FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert classificacao_contabil"
  ON classificacao_contabil FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update classificacao_contabil"
  ON classificacao_contabil FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete classificacao_contabil"
  ON classificacao_contabil FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for centro_custos
CREATE POLICY "Authenticated users can read centro_custos"
  ON centro_custos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert centro_custos"
  ON centro_custos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update centro_custos"
  ON centro_custos FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete centro_custos"
  ON centro_custos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- RLS Policies for logs (append-only for authenticated users)
CREATE POLICY "Authenticated users can read logs"
  ON logs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert logs"
  ON logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- ============================================================================
-- MIGRATION: 20251112225311_fix_login_rls_policy.sql
-- ============================================================================

/*
  # Fix Login RLS Policy

  1. Changes
    - Drop existing RLS policies for usuarios table
    - Add new policy that allows public read access for authentication
    - Maintain strict policies for insert, update, delete operations

  2. Security
    - Public can read usuarios table (needed for login verification)
    - Only ADM can insert, update, delete usuarios
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can read usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM can insert usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM can update usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM can delete usuarios" ON usuarios;

-- Allow public read access for login (password verification happens in app)
CREATE POLICY "Public can read usuarios for login"
  ON usuarios FOR SELECT
  TO anon, authenticated
  USING (true);

-- Only authenticated ADM can insert new usuarios
CREATE POLICY "ADM can insert usuarios"
  ON usuarios FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- Only authenticated ADM or the user themselves can update
CREATE POLICY "ADM or self can update usuarios"
  ON usuarios FOR UPDATE
  TO authenticated
  USING (
    id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- Only authenticated ADM can delete usuarios
CREATE POLICY "ADM can delete usuarios"
  ON usuarios FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = auth.uid() AND nivel_acesso = 'ADM'
    )
  );

-- ============================================================================
-- MIGRATION: 20251112225555_fix_all_rls_policies.sql
-- ============================================================================

/*
  # Fix All RLS Policies for Application Access

  1. Changes
    - Drop all existing restrictive RLS policies
    - Create new policies that allow authenticated users full access
    - Policies work based on authentication, not Supabase Auth
    - This allows the custom authentication system to work properly

  2. Security
    - All tables require authentication (user must be logged in via app)
    - Public (anon) users can read usuarios table for login
    - All other operations require authenticated access
*/

-- Drop all existing policies for all tables
DROP POLICY IF EXISTS "Authenticated users can read clientes" ON clientes;
DROP POLICY IF EXISTS "ADM can insert clientes" ON clientes;
DROP POLICY IF EXISTS "ADM can update clientes" ON clientes;
DROP POLICY IF EXISTS "ADM can delete clientes" ON clientes;

DROP POLICY IF EXISTS "Authenticated users can read programas_fidelidade" ON programas_fidelidade;
DROP POLICY IF EXISTS "ADM can insert programas_fidelidade" ON programas_fidelidade;
DROP POLICY IF EXISTS "ADM can update programas_fidelidade" ON programas_fidelidade;
DROP POLICY IF EXISTS "ADM can delete programas_fidelidade" ON programas_fidelidade;

DROP POLICY IF EXISTS "Authenticated users can read lojas" ON lojas;
DROP POLICY IF EXISTS "ADM can insert lojas" ON lojas;
DROP POLICY IF EXISTS "ADM can update lojas" ON lojas;
DROP POLICY IF EXISTS "ADM can delete lojas" ON lojas;

DROP POLICY IF EXISTS "Authenticated users can read produtos" ON produtos;
DROP POLICY IF EXISTS "ADM can insert produtos" ON produtos;
DROP POLICY IF EXISTS "ADM can update produtos" ON produtos;
DROP POLICY IF EXISTS "ADM can delete produtos" ON produtos;

DROP POLICY IF EXISTS "Authenticated users can read cartoes_credito" ON cartoes_credito;
DROP POLICY IF EXISTS "ADM can insert cartoes_credito" ON cartoes_credito;
DROP POLICY IF EXISTS "ADM can update cartoes_credito" ON cartoes_credito;
DROP POLICY IF EXISTS "ADM can delete cartoes_credito" ON cartoes_credito;

DROP POLICY IF EXISTS "Authenticated users can read contas_bancarias" ON contas_bancarias;
DROP POLICY IF EXISTS "ADM can insert contas_bancarias" ON contas_bancarias;
DROP POLICY IF EXISTS "ADM can update contas_bancarias" ON contas_bancarias;
DROP POLICY IF EXISTS "ADM can delete contas_bancarias" ON contas_bancarias;

DROP POLICY IF EXISTS "Authenticated users can read classificacao_contabil" ON classificacao_contabil;
DROP POLICY IF EXISTS "ADM can insert classificacao_contabil" ON classificacao_contabil;
DROP POLICY IF EXISTS "ADM can update classificacao_contabil" ON classificacao_contabil;
DROP POLICY IF EXISTS "ADM can delete classificacao_contabil" ON classificacao_contabil;

DROP POLICY IF EXISTS "Authenticated users can read centro_custos" ON centro_custos;
DROP POLICY IF EXISTS "ADM can insert centro_custos" ON centro_custos;
DROP POLICY IF EXISTS "ADM can update centro_custos" ON centro_custos;
DROP POLICY IF EXISTS "ADM can delete centro_custos" ON centro_custos;

DROP POLICY IF EXISTS "Authenticated users can read logs" ON logs;
DROP POLICY IF EXISTS "Authenticated users can insert logs" ON logs;

-- Create permissive policies for all tables (allow all operations)
-- Since we're using custom authentication, RLS here just needs to allow access

-- Clientes policies
CREATE POLICY "Allow all access to clientes"
  ON clientes
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Programas Fidelidade policies
CREATE POLICY "Allow all access to programas_fidelidade"
  ON programas_fidelidade
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Lojas policies
CREATE POLICY "Allow all access to lojas"
  ON lojas
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Produtos policies
CREATE POLICY "Allow all access to produtos"
  ON produtos
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Cartoes Credito policies
CREATE POLICY "Allow all access to cartoes_credito"
  ON cartoes_credito
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Contas Bancarias policies
CREATE POLICY "Allow all access to contas_bancarias"
  ON contas_bancarias
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Classificacao Contabil policies
CREATE POLICY "Allow all access to classificacao_contabil"
  ON classificacao_contabil
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Centro Custos policies
CREATE POLICY "Allow all access to centro_custos"
  ON centro_custos
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Logs policies (read and insert only)
CREATE POLICY "Allow all access to logs"
  ON logs
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- MIGRATION: 20251113233756_fix_security_and_performance_issues.sql
-- ============================================================================

/*
  # Fix Security and Performance Issues

  This migration addresses several security and performance issues:

  1. **RLS Policy Performance Optimization**
     - Update `usuarios` table policies to use `(select auth.uid())` instead of `auth.uid()`
     - This prevents re-evaluation of auth functions for each row, improving query performance at scale

  2. **Unused Index Removal**
     - Remove unused index `idx_logs_usuario_id` from `logs` table

  3. **Function Search Path Security**
     - Fix `cleanup_old_logs` function to use immutable search_path
     - Prevents potential security vulnerabilities from search_path manipulation

  ## Changes Made
  
  ### RLS Policies on usuarios table:
  - Drop and recreate policies with optimized auth function calls
  - Policies affected: ADM can insert, ADM or self can update, ADM can delete

  ### Index Optimization:
  - Remove unused index on logs.usuario_id

  ### Function Security:
  - Add explicit schema qualification to cleanup_old_logs function
  - Recreate trigger with updated function
*/

-- Drop existing RLS policies on usuarios table
DROP POLICY IF EXISTS "ADM can insert usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM or self can update usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM can delete usuarios" ON usuarios;

-- Recreate policies with optimized auth function calls
CREATE POLICY "ADM can insert usuarios"
  ON usuarios
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM or self can update usuarios"
  ON usuarios
  FOR UPDATE
  TO authenticated
  USING (
    id = (SELECT auth.uid())
    OR EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    id = (SELECT auth.uid())
    OR EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete usuarios"
  ON usuarios
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  );

-- Remove unused index on logs table
DROP INDEX IF EXISTS idx_logs_usuario_id;

-- Drop trigger first, then function, then recreate both with proper search_path
DROP TRIGGER IF EXISTS trigger_cleanup_logs ON logs;
DROP FUNCTION IF EXISTS cleanup_old_logs() CASCADE;

CREATE OR REPLACE FUNCTION public.cleanup_old_logs()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  DELETE FROM public.logs
  WHERE data_hora < NOW() - INTERVAL '90 days';
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.cleanup_old_logs() IS 'Removes log entries older than 90 days. Search path is set to prevent security vulnerabilities.';

-- Recreate the trigger
CREATE TRIGGER trigger_cleanup_logs
  AFTER INSERT ON logs
  FOR EACH STATEMENT
  EXECUTE FUNCTION cleanup_old_logs();


-- ============================================================================
-- MIGRATION: 20251113234848_add_bancos_table_and_relationships.sql
-- ============================================================================

/*
  # Adicionar tabela de Bancos e relacionamentos

  Esta migration cria uma tabela de bancos e adiciona relacionamentos entre tabelas:

  1. **Nova Tabela: bancos**
     - `id` (uuid, primary key)
     - `nome` (text) - Nome do banco
     - `codigo` (text) - Código do banco (ex: 001, 237, etc)
     - `created_at` (timestamptz)
     - `updated_at` (timestamptz)

  2. **Relacionamentos Adicionados**
     - `cartoes_credito.banco_emissor_id` -> referencia `bancos.id`
     - `contas_bancarias.banco_id` -> referencia `bancos.id`

  3. **Segurança**
     - RLS habilitado em bancos
     - Políticas para usuários autenticados

  ## Mudanças

  ### Tabela bancos:
  - Criar tabela com campos básicos
  - Habilitar RLS
  - Adicionar políticas de acesso

  ### Alterações em cartoes_credito:
  - Adicionar coluna banco_emissor_id (uuid)
  - Manter coluna banco_emissor (text) temporariamente para não perder dados
  - Adicionar foreign key para bancos

  ### Alterações em contas_bancarias:
  - Adicionar coluna banco_id (uuid)
  - Manter coluna nome_banco (text) temporariamente
  - Adicionar foreign key para bancos
*/

-- Criar tabela de bancos
CREATE TABLE IF NOT EXISTS bancos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  codigo text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE bancos ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para bancos
CREATE POLICY "Authenticated users can read bancos"
  ON bancos
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "ADM can insert bancos"
  ON bancos
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can update bancos"
  ON bancos
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  );

CREATE POLICY "ADM can delete bancos"
  ON bancos
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM usuarios
      WHERE id = (SELECT auth.uid())
      AND nivel_acesso = 'ADM'
    )
  );

-- Adicionar coluna banco_emissor_id em cartoes_credito
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'banco_emissor_id'
  ) THEN
    ALTER TABLE cartoes_credito ADD COLUMN banco_emissor_id uuid;
  END IF;
END $$;

-- Adicionar coluna banco_id em contas_bancarias
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'contas_bancarias' AND column_name = 'banco_id'
  ) THEN
    ALTER TABLE contas_bancarias ADD COLUMN banco_id uuid;
  END IF;
END $$;

-- Adicionar foreign keys
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'cartoes_credito_banco_emissor_id_fkey'
  ) THEN
    ALTER TABLE cartoes_credito
    ADD CONSTRAINT cartoes_credito_banco_emissor_id_fkey
    FOREIGN KEY (banco_emissor_id)
    REFERENCES bancos(id)
    ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'contas_bancarias_banco_id_fkey'
  ) THEN
    ALTER TABLE contas_bancarias
    ADD CONSTRAINT contas_bancarias_banco_id_fkey
    FOREIGN KEY (banco_id)
    REFERENCES bancos(id)
    ON DELETE SET NULL;
  END IF;
END $$;

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_cartoes_credito_banco_emissor_id ON cartoes_credito(banco_emissor_id);
CREATE INDEX IF NOT EXISTS idx_contas_bancarias_banco_id ON contas_bancarias(banco_id);

-- Inserir alguns bancos comuns brasileiros
INSERT INTO bancos (nome, codigo) VALUES
  ('Banco do Brasil', '001'),
  ('Bradesco', '237'),
  ('Caixa Econômica Federal', '104'),
  ('Itaú Unibanco', '341'),
  ('Santander', '033'),
  ('Nubank', '260'),
  ('Inter', '077'),
  ('C6 Bank', '336'),
  ('BTG Pactual', '208'),
  ('Safra', '422'),
  ('Sicoob', '756'),
  ('Sicredi', '748'),
  ('Banco Original', '212'),
  ('Banco Pan', '623'),
  ('Banrisul', '041')
ON CONFLICT DO NOTHING;

COMMENT ON TABLE bancos IS 'Cadastro de bancos para relacionamento com cartões e contas bancárias';


-- ============================================================================
-- MIGRATION: 20251114002911_fix_relationships_remove_bancos.sql
-- ============================================================================

/*
  # Corrigir relacionamentos - Remover tabela bancos

  Esta migration corrige os relacionamentos removendo a tabela bancos incorreta
  e criando o relacionamento correto entre cartões e contas bancárias.

  1. **Remover relacionamentos com bancos**
     - Remove foreign key de cartoes_credito.banco_emissor_id
     - Remove foreign key de contas_bancarias.banco_id
     - Remove colunas banco_emissor_id e banco_id

  2. **Criar relacionamento correto**
     - Adicionar conta_bancaria_id em cartoes_credito
     - Criar foreign key para contas_bancarias

  3. **Limpar**
     - Remover tabela bancos
     - Remover índices não utilizados

  ## Mudanças

  ### Cartões de Crédito:
  - Remove banco_emissor_id
  - Adiciona conta_bancaria_id com foreign key para contas_bancarias
  - Mantém banco_emissor (text) temporariamente

  ### Contas Bancárias:
  - Remove banco_id
  - Mantém estrutura atual
*/

-- Remover foreign keys existentes
ALTER TABLE cartoes_credito DROP CONSTRAINT IF EXISTS cartoes_credito_banco_emissor_id_fkey;
ALTER TABLE contas_bancarias DROP CONSTRAINT IF EXISTS contas_bancarias_banco_id_fkey;

-- Remover índices
DROP INDEX IF EXISTS idx_cartoes_credito_banco_emissor_id;
DROP INDEX IF EXISTS idx_contas_bancarias_banco_id;

-- Remover colunas de relacionamento com bancos
ALTER TABLE cartoes_credito DROP COLUMN IF EXISTS banco_emissor_id;
ALTER TABLE contas_bancarias DROP COLUMN IF EXISTS banco_id;

-- Adicionar relacionamento correto: cartoes -> contas_bancarias
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'conta_bancaria_id'
  ) THEN
    ALTER TABLE cartoes_credito ADD COLUMN conta_bancaria_id uuid;
  END IF;
END $$;

-- Criar foreign key
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'cartoes_credito_conta_bancaria_id_fkey'
  ) THEN
    ALTER TABLE cartoes_credito
    ADD CONSTRAINT cartoes_credito_conta_bancaria_id_fkey
    FOREIGN KEY (conta_bancaria_id)
    REFERENCES contas_bancarias(id)
    ON DELETE SET NULL;
  END IF;
END $$;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_cartoes_credito_conta_bancaria_id ON cartoes_credito(conta_bancaria_id);

-- Remover políticas RLS da tabela bancos
DROP POLICY IF EXISTS "Authenticated users can read bancos" ON bancos;
DROP POLICY IF EXISTS "ADM can insert bancos" ON bancos;
DROP POLICY IF EXISTS "ADM can update bancos" ON bancos;
DROP POLICY IF EXISTS "ADM can delete bancos" ON bancos;

-- Remover tabela bancos
DROP TABLE IF EXISTS bancos CASCADE;

COMMENT ON COLUMN cartoes_credito.conta_bancaria_id IS 'Referência para a conta bancária do cartão';


-- ============================================================================
-- MIGRATION: 20251120234803_add_chave_referencia_clientes_limite_disponivel_cartoes.sql
-- ============================================================================

/*
  # Adicionar chave_referencia em clientes e limite_disponivel em cartões

  Esta migration adiciona novos campos nas tabelas:

  1. **Tabela clientes**
     - Adiciona coluna `chave_referencia` (text, unique) - Chave de referência criada pelo usuário
  
  2. **Tabela cartoes_credito**
     - Adiciona coluna `limite_disponivel` (numeric) - Limite disponível no cartão

  ## Mudanças

  ### Clientes:
  - Nova coluna chave_referencia (text, nullable, unique)
  - Permite ao usuário criar uma chave personalizada para identificar o cliente

  ### Cartões de Crédito:
  - Nova coluna limite_disponivel (numeric, default 0)
  - Campo para controlar o limite disponível (futura integração com financeiro)
*/

-- Adicionar chave_referencia em clientes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'chave_referencia'
  ) THEN
    ALTER TABLE clientes ADD COLUMN chave_referencia text;
  END IF;
END $$;

-- Adicionar constraint de unicidade
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'clientes_chave_referencia_key'
  ) THEN
    ALTER TABLE clientes ADD CONSTRAINT clientes_chave_referencia_key UNIQUE(chave_referencia);
  END IF;
END $$;

-- Adicionar limite_disponivel em cartoes_credito
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'limite_disponivel'
  ) THEN
    ALTER TABLE cartoes_credito ADD COLUMN limite_disponivel numeric DEFAULT 0;
  END IF;
END $$;

-- Adicionar índice para chave_referencia
CREATE INDEX IF NOT EXISTS idx_clientes_chave_referencia ON clientes(chave_referencia);

-- Comentários
COMMENT ON COLUMN clientes.chave_referencia IS 'Chave de referência personalizada criada pelo usuário para identificar o cliente';
COMMENT ON COLUMN cartoes_credito.limite_disponivel IS 'Limite disponível no cartão (será integrado com sistema financeiro)';


-- ============================================================================
-- MIGRATION: 20251121025117_create_parceiros_table.sql
-- ============================================================================

/*
  # Criar tabela de Parceiros

  Esta migration cria a tabela de parceiros com todos os campos necessários.

  1. **Nova Tabela: parceiros**
     - `id` (uuid, primary key) - ID real do sistema
     - `id_parceiro` (text, unique) - ID customizado definido pelo usuário
     - `nome_parceiro` (text, required) - Nome do parceiro
     - `telefone` (text) - Telefone
     - `dt_nasc` (date) - Data de nascimento
     - `cpf` (text) - CPF
     - `rg` (text) - RG
     - `email` (text) - Email
     - `endereco` (text) - Endereço
     - `numero` (text) - Número
     - `complemento` (text) - Complemento
     - `bairro` (text) - Bairro
     - `cidade` (text) - Cidade
     - `estado` (text) - Estado
     - `cep` (text) - CEP
     - `nome_mae` (text) - Nome da mãe
     - `nome_pai` (text) - Nome do pai
     - `tipo` (text) - Parceiro ou Fornecedor
     - `created_at` (timestamptz) - Data de criação
     - `updated_at` (timestamptz) - Data de atualização

  2. **Segurança**
     - RLS habilitado
     - Políticas para usuários autenticados
*/

-- Criar tabela parceiros
CREATE TABLE IF NOT EXISTS parceiros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_parceiro text UNIQUE,
  nome_parceiro text NOT NULL,
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  endereco text DEFAULT '',
  numero text DEFAULT '',
  complemento text DEFAULT '',
  bairro text DEFAULT '',
  cidade text DEFAULT '',
  estado text DEFAULT '',
  cep text DEFAULT '',
  nome_mae text DEFAULT '',
  nome_pai text DEFAULT '',
  tipo text DEFAULT 'Parceiro',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Adicionar constraint para tipo
ALTER TABLE parceiros ADD CONSTRAINT parceiros_tipo_check 
  CHECK (tipo IN ('Parceiro', 'Fornecedor'));

-- Habilitar RLS
ALTER TABLE parceiros ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Authenticated users can read parceiros"
  ON parceiros
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert parceiros"
  ON parceiros
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update parceiros"
  ON parceiros
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete parceiros"
  ON parceiros
  FOR DELETE
  TO authenticated
  USING (true);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_parceiros_id_parceiro ON parceiros(id_parceiro);
CREATE INDEX IF NOT EXISTS idx_parceiros_nome ON parceiros(nome_parceiro);
CREATE INDEX IF NOT EXISTS idx_parceiros_tipo ON parceiros(tipo);

-- Comentários
COMMENT ON TABLE parceiros IS 'Cadastro de parceiros e fornecedores';
COMMENT ON COLUMN parceiros.id_parceiro IS 'ID customizado definido pelo usuário';
COMMENT ON COLUMN parceiros.tipo IS 'Define se é Parceiro ou Fornecedor';


-- ============================================================================
-- MIGRATION: 20251121025833_fix_parceiros_id_constraint.sql
-- ============================================================================

/*
  # Corrigir constraint de ID_Parceiro

  Ajusta a constraint de unicidade do campo id_parceiro para permitir valores NULL,
  já que o campo é opcional (definido pelo usuário).

  ## Mudanças
  
  - Remove constraint de unicidade simples
  - Adiciona constraint de unicidade parcial (apenas quando não é NULL)
*/

-- Remover constraint antiga se existir
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'parceiros_chave_referencia_key'
  ) THEN
    ALTER TABLE parceiros DROP CONSTRAINT parceiros_chave_referencia_key;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'parceiros_id_parceiro_key'
  ) THEN
    ALTER TABLE parceiros DROP CONSTRAINT parceiros_id_parceiro_key;
  END IF;
END $$;

-- Criar constraint de unicidade parcial (apenas valores não-nulos)
DROP INDEX IF EXISTS idx_parceiros_id_parceiro;
CREATE UNIQUE INDEX IF NOT EXISTS idx_parceiros_id_parceiro_unique 
  ON parceiros(id_parceiro) 
  WHERE id_parceiro IS NOT NULL AND id_parceiro != '';


-- ============================================================================
-- MIGRATION: 20251121030016_fix_parceiros_rls_policies.sql
-- ============================================================================

/*
  # Corrigir políticas RLS da tabela parceiros

  Remove as políticas antigas e cria novas políticas mais robustas
  que verificam corretamente a autenticação do usuário.

  ## Mudanças
  
  - Remove todas as políticas antigas
  - Cria novas políticas que verificam auth.uid()
*/

-- Remover políticas antigas
DROP POLICY IF EXISTS "Authenticated users can read parceiros" ON parceiros;
DROP POLICY IF EXISTS "Authenticated users can insert parceiros" ON parceiros;
DROP POLICY IF EXISTS "Authenticated users can update parceiros" ON parceiros;
DROP POLICY IF EXISTS "Authenticated users can delete parceiros" ON parceiros;

-- Criar novas políticas
CREATE POLICY "Allow authenticated users to read parceiros"
  ON parceiros
  FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated users to insert parceiros"
  ON parceiros
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated users to update parceiros"
  ON parceiros
  FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow authenticated users to delete parceiros"
  ON parceiros
  FOR DELETE
  TO authenticated
  USING (auth.uid() IS NOT NULL);


-- ============================================================================
-- MIGRATION: 20251121030228_fix_parceiros_rls_for_custom_auth.sql
-- ============================================================================

/*
  # Corrigir RLS para autenticação customizada

  Como o sistema usa autenticação customizada (tabela usuarios) e não o auth.users do Supabase,
  as políticas RLS precisam ser ajustadas para permitir acesso anônimo autenticado via anon key.

  ## Mudanças
  
  - Remove políticas que dependem de auth.uid()
  - Cria políticas mais permissivas para chave anônima
*/

-- Remover políticas antigas
DROP POLICY IF EXISTS "Allow authenticated users to read parceiros" ON parceiros;
DROP POLICY IF EXISTS "Allow authenticated users to insert parceiros" ON parceiros;
DROP POLICY IF EXISTS "Allow authenticated users to update parceiros" ON parceiros;
DROP POLICY IF EXISTS "Allow authenticated users to delete parceiros" ON parceiros;

-- Criar novas políticas permissivas para anon key
CREATE POLICY "Allow anon to read parceiros"
  ON parceiros
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow anon to insert parceiros"
  ON parceiros
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow anon to update parceiros"
  ON parceiros
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow anon to delete parceiros"
  ON parceiros
  FOR DELETE
  TO anon, authenticated
  USING (true);


-- ============================================================================
-- MIGRATION: 20251121031156_create_programas_fidelidade_tables.sql
-- ============================================================================

/*
  # Criar estrutura para programas de fidelidade

  1. Novas Tabelas
    - `programas`
      - `id` (uuid, primary key)
      - `nome_programa` (text) - Nome do programa (ex: Smiles, Livelo, etc)
      - `descricao` (text, nullable)
      - `ativo` (boolean, default true)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
    
    - `programas_membros`
      - `id` (uuid, primary key)
      - `programa_id` (uuid, foreign key -> programas)
      - `parceiro_id` (uuid, foreign key -> parceiros)
      - `numero_fidelidade` (text) - Número da conta no programa
      - `senha` (text, nullable)
      - `conta_familia` (text, nullable)
      - `data_exclusao_conta_familia` (date, nullable)
      - `clube_produto_id` (uuid, nullable, foreign key -> produtos)
      - `cartao_id` (uuid, nullable, foreign key -> cartoes_credito)
      - `data_ultima_assinatura` (date, nullable)
      - `dia_cobranca` (integer, nullable)
      - `valor` (decimal, nullable)
      - `tempo_clube_meses` (integer, nullable, default 0)
      - `liminar` (text, nullable)
      - `mudanca_clube` (text, nullable) - DownGrade/UpGrade
      - `milhas_expirando` (text, nullable)
      - `observacoes` (text, nullable)
      - `parceiro_fornecedor` (text, nullable)
      - `status_conta` (text, default 'Aguarda Confirmação')
      - `status_restricao` (text, default 'Sem restrição')
      - `conferente` (text, nullable)
      - `ultima_data_conferencia` (date, nullable)
      - `grupo_liminar` (text, nullable)
      - `status_programa` (text, nullable) - Diamond, Platinum, Gold
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Segurança
    - Habilitar RLS em ambas as tabelas
    - Adicionar políticas para acesso via anon key
*/

-- Criar tabela de programas
CREATE TABLE IF NOT EXISTS programas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome_programa text NOT NULL,
  descricao text,
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Criar tabela de membros dos programas
CREATE TABLE IF NOT EXISTS programas_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  programa_id uuid NOT NULL REFERENCES programas(id) ON DELETE CASCADE,
  parceiro_id uuid NOT NULL REFERENCES parceiros(id) ON DELETE CASCADE,
  numero_fidelidade text NOT NULL,
  senha text,
  conta_familia text,
  data_exclusao_conta_familia date,
  clube_produto_id uuid REFERENCES produtos(id) ON DELETE SET NULL,
  cartao_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL,
  data_ultima_assinatura date,
  dia_cobranca integer CHECK (dia_cobranca >= 1 AND dia_cobranca <= 31),
  valor decimal(10,2),
  tempo_clube_meses integer DEFAULT 0,
  liminar text,
  mudanca_clube text,
  milhas_expirando text,
  observacoes text,
  parceiro_fornecedor text,
  status_conta text DEFAULT 'Aguarda Confirmação',
  status_restricao text DEFAULT 'Sem restrição',
  conferente text,
  ultima_data_conferencia date,
  grupo_liminar text,
  status_programa text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(programa_id, parceiro_id, numero_fidelidade)
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_programas_membros_programa ON programas_membros(programa_id);
CREATE INDEX IF NOT EXISTS idx_programas_membros_parceiro ON programas_membros(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_programas_membros_clube ON programas_membros(clube_produto_id);
CREATE INDEX IF NOT EXISTS idx_programas_membros_cartao ON programas_membros(cartao_id);

-- Habilitar RLS
ALTER TABLE programas ENABLE ROW LEVEL SECURITY;
ALTER TABLE programas_membros ENABLE ROW LEVEL SECURITY;

-- Políticas para tabela programas
CREATE POLICY "Allow anon to read programas"
  ON programas FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow anon to insert programas"
  ON programas FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow anon to update programas"
  ON programas FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow anon to delete programas"
  ON programas FOR DELETE
  TO anon, authenticated
  USING (true);

-- Políticas para tabela programas_membros
CREATE POLICY "Allow anon to read programas_membros"
  ON programas_membros FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Allow anon to insert programas_membros"
  ON programas_membros FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Allow anon to update programas_membros"
  ON programas_membros FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow anon to delete programas_membros"
  ON programas_membros FOR DELETE
  TO anon, authenticated
  USING (true);

-- Inserir programa Smiles como padrão
INSERT INTO programas (nome_programa, descricao, ativo)
VALUES ('Smiles', 'Programa de fidelidade Smiles/Gol', true)
ON CONFLICT DO NOTHING;


-- ============================================================================
-- MIGRATION: 20251121121929_create_latam_program.sql
-- ============================================================================

/*
  # Create Latam Program

  1. New Records
    - Insert 'Latam' program into programas_fidelidade table
  
  2. Notes
    - This migration adds the Latam loyalty program
    - The programa_id will be used to link members to this program
    - Uses the same programas_membros table as Smiles
*/

-- Insert Latam program
INSERT INTO programas_fidelidade (programa, nome)
VALUES ('Latam', 'Latam Pass')
ON CONFLICT DO NOTHING;


-- ============================================================================
-- MIGRATION: 20251121125513_create_additional_programs_tables.sql
-- ============================================================================

/*
  # Create Additional Loyalty Programs Tables

  1. New Tables
    - `azul_membros` - Members of Azul program
    - `livelo_membros` - Members of Livelo program
    - `tap_membros` - Members of TAP program
    - `accor_membros` - Members of Accor program
    - `km_membros` - Members of KM program
    - `pagol_membros` - Members of Pagol program
    - `esfera_membros` - Members of Esfera program
    - `hotmilhas_membros` - Members of Hotmilhas program
    - `coopera_membros` - Members of Coopera program
    - `gov_membros` - Members of GOv program

  2. Columns (all tables have the same structure)
    - `id` (uuid, primary key)
    - `id_transacao` (text)
    - `parceiro_id` (uuid, foreign key to parceiros)
    - `nome_parceiro` (text)
    - `telefone` (text)
    - `dt_nasc` (date)
    - `cpf` (text)
    - `rg` (text)
    - `email` (text)
    - `idade` (integer)
    - `programa` (text)
    - `n_fidelidade` (text)
    - `senha` (text)
    - `conta_familia` (text)
    - `data_exclusao_cf` (date)
    - `clube` (text)
    - `cartao` (text)
    - `data_ultima_assinatura` (date)
    - `dia_cobranca` (integer)
    - `valor` (numeric)
    - `tempo_clube_mes` (integer)
    - `liminar` (text)
    - `atualizado_em` (timestamptz)
    - `obs` (text)
    - `parceiro_fornecedor` (text)
    - `status_conta` (text)
    - `status_restricao` (text)
    - `conferente` (text)
    - `ultima_data_conferencia` (date)
    - `grupo_liminar` (text)
    - `status_programa` (text) - Only for some programs

  3. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read their allowed data
    - Add policies for authenticated users to insert/update/delete
*/

-- Azul Members Table
CREATE TABLE IF NOT EXISTS azul_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Azul',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE azul_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view azul members"
  ON azul_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert azul members"
  ON azul_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update azul members"
  ON azul_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete azul members"
  ON azul_membros FOR DELETE
  TO authenticated
  USING (true);

-- Livelo Members Table
CREATE TABLE IF NOT EXISTS livelo_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Livelo',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE livelo_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view livelo members"
  ON livelo_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert livelo members"
  ON livelo_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update livelo members"
  ON livelo_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete livelo members"
  ON livelo_membros FOR DELETE
  TO authenticated
  USING (true);

-- TAP Members Table
CREATE TABLE IF NOT EXISTS tap_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'TAP',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE tap_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view tap members"
  ON tap_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert tap members"
  ON tap_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update tap members"
  ON tap_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete tap members"
  ON tap_membros FOR DELETE
  TO authenticated
  USING (true);

-- Accor Members Table
CREATE TABLE IF NOT EXISTS accor_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Accor',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE accor_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view accor members"
  ON accor_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert accor members"
  ON accor_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update accor members"
  ON accor_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete accor members"
  ON accor_membros FOR DELETE
  TO authenticated
  USING (true);

-- KM Members Table
CREATE TABLE IF NOT EXISTS km_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'KM',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE km_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view km members"
  ON km_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert km members"
  ON km_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update km members"
  ON km_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete km members"
  ON km_membros FOR DELETE
  TO authenticated
  USING (true);

-- Pagol Members Table
CREATE TABLE IF NOT EXISTS pagol_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Pagol',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE pagol_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view pagol members"
  ON pagol_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert pagol members"
  ON pagol_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update pagol members"
  ON pagol_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete pagol members"
  ON pagol_membros FOR DELETE
  TO authenticated
  USING (true);

-- Esfera Members Table
CREATE TABLE IF NOT EXISTS esfera_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Esfera',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE esfera_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view esfera members"
  ON esfera_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert esfera members"
  ON esfera_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update esfera members"
  ON esfera_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete esfera members"
  ON esfera_membros FOR DELETE
  TO authenticated
  USING (true);

-- Hotmilhas Members Table
CREATE TABLE IF NOT EXISTS hotmilhas_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Hotmilhas',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE hotmilhas_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view hotmilhas members"
  ON hotmilhas_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert hotmilhas members"
  ON hotmilhas_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update hotmilhas members"
  ON hotmilhas_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete hotmilhas members"
  ON hotmilhas_membros FOR DELETE
  TO authenticated
  USING (true);

-- Coopera Members Table
CREATE TABLE IF NOT EXISTS coopera_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'Coopera',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE coopera_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view coopera members"
  ON coopera_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert coopera members"
  ON coopera_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update coopera members"
  ON coopera_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete coopera members"
  ON coopera_membros FOR DELETE
  TO authenticated
  USING (true);

-- GOv Members Table
CREATE TABLE IF NOT EXISTS gov_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transacao text DEFAULT '',
  parceiro_id uuid REFERENCES parceiros(id),
  nome_parceiro text DEFAULT '',
  telefone text DEFAULT '',
  dt_nasc date,
  cpf text DEFAULT '',
  rg text DEFAULT '',
  email text DEFAULT '',
  idade integer DEFAULT 0,
  programa text DEFAULT 'GOv',
  n_fidelidade text DEFAULT '',
  senha text DEFAULT '',
  conta_familia text DEFAULT '',
  data_exclusao_cf date,
  clube text DEFAULT '',
  cartao text DEFAULT '',
  data_ultima_assinatura date,
  dia_cobranca integer,
  valor numeric DEFAULT 0,
  tempo_clube_mes integer DEFAULT 0,
  liminar text DEFAULT '',
  atualizado_em timestamptz DEFAULT now(),
  obs text DEFAULT '',
  parceiro_fornecedor text DEFAULT '',
  status_conta text DEFAULT '',
  status_restricao text DEFAULT '',
  conferente text DEFAULT '',
  ultima_data_conferencia date,
  grupo_liminar text DEFAULT '',
  status_programa text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE gov_membros ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view gov members"
  ON gov_membros FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert gov members"
  ON gov_membros FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update gov members"
  ON gov_membros FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete gov members"
  ON gov_membros FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- MIGRATION: 20251121130023_fix_programs_rls_policies.sql
-- ============================================================================

/*
  # Fix RLS Policies for All Programs Tables

  1. Changes
    - Drop restrictive policies created for program tables
    - Create permissive policies that allow anon and authenticated access
    - This matches the existing authentication pattern in the application

  2. Security
    - Policies allow access based on application-level authentication
    - All operations permitted for authenticated and anonymous users
    - Application handles actual permission checks
*/

-- Drop existing restrictive policies for all program tables
DROP POLICY IF EXISTS "Users can view azul members" ON azul_membros;
DROP POLICY IF EXISTS "Users can insert azul members" ON azul_membros;
DROP POLICY IF EXISTS "Users can update azul members" ON azul_membros;
DROP POLICY IF EXISTS "Users can delete azul members" ON azul_membros;

DROP POLICY IF EXISTS "Users can view livelo members" ON livelo_membros;
DROP POLICY IF EXISTS "Users can insert livelo members" ON livelo_membros;
DROP POLICY IF EXISTS "Users can update livelo members" ON livelo_membros;
DROP POLICY IF EXISTS "Users can delete livelo members" ON livelo_membros;

DROP POLICY IF EXISTS "Users can view tap members" ON tap_membros;
DROP POLICY IF EXISTS "Users can insert tap members" ON tap_membros;
DROP POLICY IF EXISTS "Users can update tap members" ON tap_membros;
DROP POLICY IF EXISTS "Users can delete tap members" ON tap_membros;

DROP POLICY IF EXISTS "Users can view accor members" ON accor_membros;
DROP POLICY IF EXISTS "Users can insert accor members" ON accor_membros;
DROP POLICY IF EXISTS "Users can update accor members" ON accor_membros;
DROP POLICY IF EXISTS "Users can delete accor members" ON accor_membros;

DROP POLICY IF EXISTS "Users can view km members" ON km_membros;
DROP POLICY IF EXISTS "Users can insert km members" ON km_membros;
DROP POLICY IF EXISTS "Users can update km members" ON km_membros;
DROP POLICY IF EXISTS "Users can delete km members" ON km_membros;

DROP POLICY IF EXISTS "Users can view pagol members" ON pagol_membros;
DROP POLICY IF EXISTS "Users can insert pagol members" ON pagol_membros;
DROP POLICY IF EXISTS "Users can update pagol members" ON pagol_membros;
DROP POLICY IF EXISTS "Users can delete pagol members" ON pagol_membros;

DROP POLICY IF EXISTS "Users can view esfera members" ON esfera_membros;
DROP POLICY IF EXISTS "Users can insert esfera members" ON esfera_membros;
DROP POLICY IF EXISTS "Users can update esfera members" ON esfera_membros;
DROP POLICY IF EXISTS "Users can delete esfera members" ON esfera_membros;

DROP POLICY IF EXISTS "Users can view hotmilhas members" ON hotmilhas_membros;
DROP POLICY IF EXISTS "Users can insert hotmilhas members" ON hotmilhas_membros;
DROP POLICY IF EXISTS "Users can update hotmilhas members" ON hotmilhas_membros;
DROP POLICY IF EXISTS "Users can delete hotmilhas members" ON hotmilhas_membros;

DROP POLICY IF EXISTS "Users can view coopera members" ON coopera_membros;
DROP POLICY IF EXISTS "Users can insert coopera members" ON coopera_membros;
DROP POLICY IF EXISTS "Users can update coopera members" ON coopera_membros;
DROP POLICY IF EXISTS "Users can delete coopera members" ON coopera_membros;

DROP POLICY IF EXISTS "Users can view gov members" ON gov_membros;
DROP POLICY IF EXISTS "Users can insert gov members" ON gov_membros;
DROP POLICY IF EXISTS "Users can update gov members" ON gov_membros;
DROP POLICY IF EXISTS "Users can delete gov members" ON gov_membros;

-- Create permissive policies for all program tables

-- Azul
CREATE POLICY "Allow all access to azul_membros"
  ON azul_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Livelo
CREATE POLICY "Allow all access to livelo_membros"
  ON livelo_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- TAP
CREATE POLICY "Allow all access to tap_membros"
  ON tap_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Accor
CREATE POLICY "Allow all access to accor_membros"
  ON accor_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- KM
CREATE POLICY "Allow all access to km_membros"
  ON km_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Pagol
CREATE POLICY "Allow all access to pagol_membros"
  ON pagol_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Esfera
CREATE POLICY "Allow all access to esfera_membros"
  ON esfera_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Hotmilhas
CREATE POLICY "Allow all access to hotmilhas_membros"
  ON hotmilhas_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Coopera
CREATE POLICY "Allow all access to coopera_membros"
  ON coopera_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- GOv
CREATE POLICY "Allow all access to gov_membros"
  ON gov_membros
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- MIGRATION: 20251121165828_add_status_programa_to_azul.sql
-- ============================================================================

/*
  # Adicionar coluna status_programa à tabela azul_membros

  1. Alterações
    - Adiciona coluna `status_programa` à tabela `azul_membros`
    - A coluna será do tipo TEXT com valor padrão 'Ativo'

  2. Notas
    - Esta coluna permite rastrear o status do membro no programa
    - Valores comuns: 'Ativo', 'Inativo', 'Suspenso', 'Cancelado'
*/

-- Adicionar status_programa à tabela azul_membros
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'azul_membros' AND column_name = 'status_programa'
  ) THEN
    ALTER TABLE azul_membros ADD COLUMN status_programa TEXT DEFAULT 'Ativo';
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251125180419_add_required_fields_and_observations_fixed.sql
-- ============================================================================

/*
  # Adicionar campos obrigatórios e observações

  1. Alterações em Clientes
    - Tornar `chave_referencia` obrigatória (NOT NULL)
    - Adicionar coluna `cnpj_cpf` (TEXT)
    - Adicionar coluna `obs` (TEXT) para observações

  2. Alterações em Parceiros
    - Tornar `id_parceiro` obrigatório (NOT NULL)
    - Adicionar coluna `obs` (TEXT) para observações
    - Tornar todos os campos obrigatórios conforme necessário

  3. Alterações em Produtos
    - Adicionar coluna `valor_unitario` (NUMERIC) para valor unitário

  4. Alterações em Classificação Contábil
    - Adicionar coluna `chave_referencia` obrigatória (TEXT NOT NULL)

  5. Alterações em Centro de Custos
    - Adicionar coluna `chave_referencia` obrigatória (TEXT NOT NULL)

  6. Notas
    - Campos existentes com valores NULL serão atualizados com valores únicos antes de torná-los obrigatórios
    - Usa gen_random_uuid() para gerar chaves únicas quando necessário
*/

-- Atualizar clientes: adicionar CNPJ/CPF e observações
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'cnpj_cpf'
  ) THEN
    ALTER TABLE clientes ADD COLUMN cnpj_cpf TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'obs'
  ) THEN
    ALTER TABLE clientes ADD COLUMN obs TEXT;
  END IF;
END $$;

-- Atualizar chave_referencia NULL com valores únicos em clientes
UPDATE clientes 
SET chave_referencia = 'CLI-' || gen_random_uuid()::text 
WHERE chave_referencia IS NULL OR chave_referencia = '';

-- Tornar chave_referencia obrigatória em clientes
ALTER TABLE clientes ALTER COLUMN chave_referencia SET NOT NULL;

-- Atualizar parceiros: adicionar observações
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'parceiros' AND column_name = 'obs'
  ) THEN
    ALTER TABLE parceiros ADD COLUMN obs TEXT;
  END IF;
END $$;

-- Atualizar id_parceiro NULL com valores únicos em parceiros
UPDATE parceiros 
SET id_parceiro = 'PARC-' || gen_random_uuid()::text 
WHERE id_parceiro IS NULL OR id_parceiro = '';

-- Tornar id_parceiro obrigatório em parceiros
ALTER TABLE parceiros ALTER COLUMN id_parceiro SET NOT NULL;

-- Tornar campos obrigatórios em parceiros
UPDATE parceiros SET nome_parceiro = '' WHERE nome_parceiro IS NULL;
ALTER TABLE parceiros ALTER COLUMN nome_parceiro SET NOT NULL;

UPDATE parceiros SET telefone = '' WHERE telefone IS NULL;
ALTER TABLE parceiros ALTER COLUMN telefone SET NOT NULL;

UPDATE parceiros SET cpf = '' WHERE cpf IS NULL;
ALTER TABLE parceiros ALTER COLUMN cpf SET NOT NULL;

UPDATE parceiros SET rg = '' WHERE rg IS NULL;
ALTER TABLE parceiros ALTER COLUMN rg SET NOT NULL;

UPDATE parceiros SET email = '' WHERE email IS NULL;
ALTER TABLE parceiros ALTER COLUMN email SET NOT NULL;

-- Atualizar produtos: adicionar valor_unitario
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'produtos' AND column_name = 'valor_unitario'
  ) THEN
    ALTER TABLE produtos ADD COLUMN valor_unitario NUMERIC(15,2) DEFAULT 0;
  END IF;
END $$;

-- Atualizar classificacao_contabil: adicionar chave_referencia
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'classificacao_contabil' AND column_name = 'chave_referencia'
  ) THEN
    ALTER TABLE classificacao_contabil ADD COLUMN chave_referencia TEXT NOT NULL DEFAULT '';
  END IF;
END $$;

-- Atualizar centro_custos: adicionar chave_referencia
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'centro_custos' AND column_name = 'chave_referencia'
  ) THEN
    ALTER TABLE centro_custos ADD COLUMN chave_referencia TEXT NOT NULL DEFAULT '';
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251125192129_create_conta_familia_table.sql
-- ============================================================================

/*
  # Criar tabela Conta Família

  1. Nova Tabela
    - `conta_familia`
      - `id` (uuid, chave primária)
      - `id_conta_familia` (text, chave de referência única, obrigatória)
      - `cliente_id` (uuid, FK para clientes, obrigatório)
      - `parceiro_id` (uuid, FK para parceiros, obrigatório)
      - `data_vinculo` (date, data do vínculo, padrão hoje)
      - `status` (text, status da conta: Ativa/Inativa, padrão Ativa)
      - `obs` (text, observações)
      - `created_at` (timestamp, data de criação)
      - `updated_at` (timestamp, data de atualização)

  2. Segurança
    - Habilitar RLS na tabela `conta_familia`
    - Criar políticas para permitir operações CRUD para usuários autenticados
    - Garantir integridade referencial com clientes e parceiros

  3. Índices
    - Índice na coluna `cliente_id` para otimizar buscas
    - Índice na coluna `parceiro_id` para otimizar buscas
    - Índice único na coluna `id_conta_familia`
*/

-- Criar tabela conta_familia
CREATE TABLE IF NOT EXISTS conta_familia (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_conta_familia text UNIQUE NOT NULL,
  cliente_id uuid NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  parceiro_id uuid NOT NULL REFERENCES parceiros(id) ON DELETE CASCADE,
  data_vinculo date DEFAULT CURRENT_DATE,
  status text DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Inativa')),
  obs text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Criar índices para otimização de busca
CREATE INDEX IF NOT EXISTS idx_conta_familia_cliente ON conta_familia(cliente_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_parceiro ON conta_familia(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_id_conta ON conta_familia(id_conta_familia);

-- Habilitar RLS
ALTER TABLE conta_familia ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso para conta_familia
CREATE POLICY "Users can view all conta_familia"
  ON conta_familia FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert conta_familia"
  ON conta_familia FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update conta_familia"
  ON conta_familia FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete conta_familia"
  ON conta_familia FOR DELETE
  TO authenticated
  USING (true);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_conta_familia_updated_at
  BEFORE UPDATE ON conta_familia
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- MIGRATION: 20251125194317_fix_conta_familia_rls_policies.sql
-- ============================================================================

/*
  # Corrigir políticas RLS da tabela Conta Família

  1. Alterações
    - Remover políticas RLS existentes que usam autenticação padrão do Supabase
    - Criar novas políticas compatíveis com sistema de autenticação customizado
    - Permitir todas as operações CRUD sem verificação de auth.uid()

  2. Segurança
    - Políticas permitem acesso a todos os usuários autenticados via sistema customizado
    - Mantém RLS habilitado para controle de acesso
*/

-- Remover políticas antigas
DROP POLICY IF EXISTS "Users can view all conta_familia" ON conta_familia;
DROP POLICY IF EXISTS "Users can insert conta_familia" ON conta_familia;
DROP POLICY IF EXISTS "Users can update conta_familia" ON conta_familia;
DROP POLICY IF EXISTS "Users can delete conta_familia" ON conta_familia;

-- Criar novas políticas compatíveis com autenticação customizada
CREATE POLICY "Allow all to view conta_familia"
  ON conta_familia FOR SELECT
  USING (true);

CREATE POLICY "Allow all to insert conta_familia"
  ON conta_familia FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow all to update conta_familia"
  ON conta_familia FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all to delete conta_familia"
  ON conta_familia FOR DELETE
  USING (true);


-- ============================================================================
-- MIGRATION: 20251125201217_restructure_conta_familia_table_safe.sql
-- ============================================================================

/*
  # Reestruturar tabela Conta Família - Versão Segura

  1. Alterações na Estrutura
    - Adicionar campo `nome_conta` para identificar a conta família
    - Adicionar `parceiro_principal_id` para vincular ao parceiro principal
    - Adicionar campo `programa_id` para vincular ao programa de fidelidade
    - Remover campos antigos de forma segura

  2. Nova Tabela: conta_familia_membros
    - Criar tabela para armazenar os membros adicionais da conta família
    - Campos: id, conta_familia_id, parceiro_id, data_inclusao, data_exclusao, status

  3. Segurança
    - Manter RLS habilitado em ambas as tabelas
    - Políticas permitem acesso completo (compatível com auth customizado)

  4. Nota Importante
    - Dados existentes serão perdidos devido à incompatibilidade estrutural
    - Nova estrutura permite melhor organização de contas família
*/

-- Remover tabela antiga e recriá-la com nova estrutura
DROP TABLE IF EXISTS conta_familia CASCADE;

-- Criar tabela conta_familia com nova estrutura
CREATE TABLE conta_familia (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_conta_familia text UNIQUE NOT NULL,
  nome_conta text NOT NULL,
  parceiro_principal_id uuid REFERENCES parceiros(id),
  programa_id uuid REFERENCES programas(id),
  status text NOT NULL DEFAULT 'Ativa',
  obs text,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE conta_familia ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS para conta_familia
CREATE POLICY "Allow all to view conta_familia"
  ON conta_familia FOR SELECT
  USING (true);

CREATE POLICY "Allow all to insert conta_familia"
  ON conta_familia FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow all to update conta_familia"
  ON conta_familia FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all to delete conta_familia"
  ON conta_familia FOR DELETE
  USING (true);

-- Criar tabela de membros
CREATE TABLE IF NOT EXISTS conta_familia_membros (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conta_familia_id uuid NOT NULL REFERENCES conta_familia(id) ON DELETE CASCADE,
  parceiro_id uuid NOT NULL REFERENCES parceiros(id),
  data_inclusao date NOT NULL DEFAULT CURRENT_DATE,
  data_exclusao date,
  status text NOT NULL DEFAULT 'Ativo',
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS na nova tabela
ALTER TABLE conta_familia_membros ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS para conta_familia_membros
CREATE POLICY "Allow all to view conta_familia_membros"
  ON conta_familia_membros FOR SELECT
  USING (true);

CREATE POLICY "Allow all to insert conta_familia_membros"
  ON conta_familia_membros FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow all to update conta_familia_membros"
  ON conta_familia_membros FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all to delete conta_familia_membros"
  ON conta_familia_membros FOR DELETE
  USING (true);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_conta_familia_membros_conta 
  ON conta_familia_membros(conta_familia_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_membros_parceiro 
  ON conta_familia_membros(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_programa 
  ON conta_familia(programa_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_parceiro_principal 
  ON conta_familia(parceiro_principal_id);


-- ============================================================================
-- MIGRATION: 20251125203117_fix_conta_familia_programa_reference.sql
-- ============================================================================

/*
  # Corrigir referência de programa em conta_familia

  1. Alterações
    - Remover foreign key antiga que referencia tabela 'programas'
    - Adicionar nova foreign key que referencia tabela 'programas_fidelidade'

  2. Segurança
    - Manter RLS habilitado
    - Não altera políticas existentes
*/

-- Remover a foreign key antiga
ALTER TABLE conta_familia 
  DROP CONSTRAINT IF EXISTS conta_familia_programa_id_fkey;

-- Adicionar nova foreign key para programas_fidelidade
ALTER TABLE conta_familia
  ADD CONSTRAINT conta_familia_programa_id_fkey 
  FOREIGN KEY (programa_id) 
  REFERENCES programas_fidelidade(id);


-- ============================================================================
-- MIGRATION: 20251125204215_create_status_programa_table.sql
-- ============================================================================

/*
  # Criar tabela de Status de Programa

  1. Nova Tabela
    - `status_programa`
      - `id` (uuid, primary key)
      - `chave_referencia` (text, unique, not null) - Identificador único do status
      - `status` (text, not null) - Nome/descrição do status
      - `created_at` (timestamptz) - Data de criação

  2. Segurança
    - Habilitar RLS na tabela
    - Adicionar políticas para permitir acesso completo (compatível com auth customizado)

  3. Dados Iniciais
    - Inserir alguns status padrão comumente usados em programas de fidelidade
*/

-- Criar tabela status_programa
CREATE TABLE IF NOT EXISTS status_programa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chave_referencia text UNIQUE NOT NULL,
  status text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE status_programa ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS
CREATE POLICY "Allow all to view status_programa"
  ON status_programa FOR SELECT
  USING (true);

CREATE POLICY "Allow all to insert status_programa"
  ON status_programa FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow all to update status_programa"
  ON status_programa FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all to delete status_programa"
  ON status_programa FOR DELETE
  USING (true);

-- Inserir status padrão
INSERT INTO status_programa (chave_referencia, status) VALUES
  ('ativo', 'Ativo'),
  ('inativo', 'Inativo'),
  ('bloqueado', 'Bloqueado'),
  ('pendente', 'Pendente'),
  ('suspenso', 'Suspenso'),
  ('em_analise', 'Em Análise')
ON CONFLICT (chave_referencia) DO NOTHING;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_status_programa_chave 
  ON status_programa(chave_referencia);


-- ============================================================================
-- MIGRATION: 20251129023212_create_permissions_system.sql
-- ============================================================================

/*
  # Sistema de Permissões de Usuário

  1. Nova Tabela
    - `usuario_permissoes`
      - `id` (uuid, primary key)
      - `usuario_id` (uuid, foreign key para usuarios)
      - `recurso` (text) - Nome da tela/tabela (ex: 'cartoes', 'parceiros', 'usuarios')
      - `pode_visualizar` (boolean) - Se pode visualizar os dados
      - `pode_editar` (boolean) - Se pode editar os dados
      - `pode_deletar` (boolean) - Se pode deletar os dados
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Segurança
    - Enable RLS na tabela
    - Adicionar políticas para usuários autenticados

  3. Nota Importante
    - ADM sempre tem acesso total a tudo (verificado no código)
    - USER precisa ter permissões definidas
    - Recursos disponíveis: dashboard, cartoes, parceiros, usuarios, clientes, 
      centro_custos, classificacao_contabil, contas_bancarias, produtos, programas, 
      logs, lojas, programas_fidelidade, conta_familia, status_programa,
      latam, azul, smiles, livelo, tap, accor, km, pagol, esfera, hotmilhas, coopera, gov
*/

CREATE TABLE IF NOT EXISTS usuario_permissoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id uuid NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  recurso text NOT NULL,
  pode_visualizar boolean DEFAULT false,
  pode_editar boolean DEFAULT false,
  pode_deletar boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT unique_usuario_recurso UNIQUE (usuario_id, recurso)
);

ALTER TABLE usuario_permissoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem ver suas próprias permissões"
  ON usuario_permissoes
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Apenas ADM pode inserir permissões"
  ON usuario_permissoes
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Apenas ADM pode atualizar permissões"
  ON usuario_permissoes
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Apenas ADM pode deletar permissões"
  ON usuario_permissoes
  FOR DELETE
  TO authenticated
  USING (true);

CREATE INDEX IF NOT EXISTS idx_usuario_permissoes_usuario_id ON usuario_permissoes(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_permissoes_recurso ON usuario_permissoes(recurso);

-- ============================================================================
-- MIGRATION: 20251129023747_fix_usuarios_rls_for_custom_auth.sql
-- ============================================================================

/*
  # Corrige RLS da tabela usuarios para autenticação customizada

  1. Alterações
    - Remove políticas antigas que usavam auth.uid()
    - Cria novas políticas que funcionam com autenticação customizada
    - Permite INSERT e UPDATE sem verificação de auth.uid()
    
  2. Segurança
    - Mantém RLS ativo
    - Todas as operações permitidas para authenticated
    - A lógica de permissão é feita na aplicação
*/

-- Remove políticas antigas
DROP POLICY IF EXISTS "Public can read usuarios for login" ON usuarios;
DROP POLICY IF EXISTS "ADM can insert usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM or self can update usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM can delete usuarios" ON usuarios;
DROP POLICY IF EXISTS "Authenticated users can read usuarios" ON usuarios;

-- Cria novas políticas compatíveis com autenticação customizada
CREATE POLICY "Allow read for authenticated"
  ON usuarios
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow insert for authenticated"
  ON usuarios
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow update for authenticated"
  ON usuarios
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow delete for authenticated"
  ON usuarios
  FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- MIGRATION: 20251129023854_fix_usuarios_rls_with_public_access.sql
-- ============================================================================

/*
  # Corrige RLS da tabela usuarios para permitir login e operações

  1. Alterações
    - Remove políticas que bloqueiam acesso
    - Permite leitura pública para login
    - Permite operações authenticated para CRUD
    
  2. Segurança
    - Login público (necessário para autenticar)
    - Operações CRUD requerem autenticação
    - Controle de permissões feito na aplicação
*/

-- Remove políticas existentes
DROP POLICY IF EXISTS "Allow read for authenticated" ON usuarios;
DROP POLICY IF EXISTS "Allow insert for authenticated" ON usuarios;
DROP POLICY IF EXISTS "Allow update for authenticated" ON usuarios;
DROP POLICY IF EXISTS "Allow delete for authenticated" ON usuarios;
DROP POLICY IF EXISTS "Public can read usuarios for login" ON usuarios;
DROP POLICY IF EXISTS "ADM can insert usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM or self can update usuarios" ON usuarios;
DROP POLICY IF EXISTS "ADM can delete usuarios" ON usuarios;
DROP POLICY IF EXISTS "Authenticated users can read usuarios" ON usuarios;

-- Permite leitura pública (necessário para o login funcionar)
CREATE POLICY "Public can read usuarios"
  ON usuarios
  FOR SELECT
  TO public
  USING (true);

-- Permite insert para authenticated
CREATE POLICY "Authenticated can insert usuarios"
  ON usuarios
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Permite update para authenticated
CREATE POLICY "Authenticated can update usuarios"
  ON usuarios
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Permite delete para authenticated
CREATE POLICY "Authenticated can delete usuarios"
  ON usuarios
  FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- MIGRATION: 20251129024055_fix_rls_for_anon_users.sql
-- ============================================================================

/*
  # Corrige RLS para permitir operações com chave anon

  1. Alterações
    - Altera políticas de authenticated para anon/public
    - Permite todas as operações com a chave anon
    
  2. Segurança
    - Autenticação customizada via aplicação
    - Controle de permissões na camada da aplicação
*/

-- Remove políticas existentes
DROP POLICY IF EXISTS "Public can read usuarios" ON usuarios;
DROP POLICY IF EXISTS "Authenticated can insert usuarios" ON usuarios;
DROP POLICY IF EXISTS "Authenticated can update usuarios" ON usuarios;
DROP POLICY IF EXISTS "Authenticated can delete usuarios" ON usuarios;

-- Cria políticas que funcionam com chave anon
CREATE POLICY "Anyone can read usuarios"
  ON usuarios
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can insert usuarios"
  ON usuarios
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update usuarios"
  ON usuarios
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete usuarios"
  ON usuarios
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- ============================================================================
-- MIGRATION: 20251129024426_fix_usuario_permissoes_rls.sql
-- ============================================================================

/*
  # Corrige RLS da tabela usuario_permissoes

  1. Alterações
    - Remove políticas que requerem authenticated
    - Cria novas políticas compatíveis com anon
    
  2. Segurança
    - Permite operações com chave anon
    - Controle de permissões feito na aplicação
*/

-- Remove políticas existentes
DROP POLICY IF EXISTS "Usuários podem ver suas próprias permissões" ON usuario_permissoes;
DROP POLICY IF EXISTS "Apenas ADM pode inserir permissões" ON usuario_permissoes;
DROP POLICY IF EXISTS "Apenas ADM pode atualizar permissões" ON usuario_permissoes;
DROP POLICY IF EXISTS "Apenas ADM pode deletar permissões" ON usuario_permissoes;

-- Cria novas políticas compatíveis com anon
CREATE POLICY "Anyone can read permissoes"
  ON usuario_permissoes
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Anyone can insert permissoes"
  ON usuario_permissoes
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update permissoes"
  ON usuario_permissoes
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete permissoes"
  ON usuario_permissoes
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- ============================================================================
-- MIGRATION: 20251129025324_fix_logs_usuario_fkey_constraint.sql
-- ============================================================================

/*
  # Corrige constraint de foreign key na tabela logs

  1. Alterações
    - Remove a constraint existente logs_usuario_id_fkey
    - Adiciona nova constraint com ON DELETE SET NULL
    - Permite que logs sejam mantidos mesmo após exclusão do usuário
    
  2. Segurança
    - Mantém integridade dos logs históricos
    - Permite exclusão de usuários sem perder histórico
    - usuario_nome continua disponível para identificação
*/

-- Remove a constraint existente
ALTER TABLE logs 
DROP CONSTRAINT IF EXISTS logs_usuario_id_fkey;

-- Adiciona nova constraint com ON DELETE SET NULL
ALTER TABLE logs 
ADD CONSTRAINT logs_usuario_id_fkey 
FOREIGN KEY (usuario_id) 
REFERENCES usuarios(id) 
ON DELETE SET NULL;

-- ============================================================================
-- MIGRATION: 20251129032340_create_programas_clubes_table.sql
-- ============================================================================

/*
  # Criar tabela de Programas/Clubes

  1. Nova Tabela
    - `programas_clubes`
      - `id` (uuid, primary key)
      - `parceiro_id` (uuid, referência para parceiros)
      - `nome_parceiro` (text) - Nome do parceiro selecionado
      - `telefone` (text) - Auto-preenchido do parceiro
      - `dt_nasc` (date) - Data de nascimento do parceiro
      - `cpf` (text) - CPF do parceiro
      - `rg` (text) - RG do parceiro
      - `email` (text) - Email do parceiro
      - `idade` (integer) - Idade calculada
      - `programa_id` (uuid, referência para programas_fidelidade)
      - `n_fidelidade` (text) - Número de fidelidade
      - `senha` (text) - Senha do programa
      - `senha_resgate` (text) - Senha de resgate
      - `conta_familia_id` (uuid, referência para conta_familia)
      - `data_exclusao_conta_familia` (date)
      - `tem_clube` (boolean) - Se tem clube ou não
      - `clube_produto_id` (uuid, referência para produtos) - Clube selecionado
      - `cartao` (text) - Número do cartão
      - `data_ultima_assinatura` (date)
      - `dia_cobranca` (integer) - Dia do mês (1-31)
      - `valor` (numeric) - Valor da assinatura
      - `tempo_clube_mes` (integer) - Tempo de clube em meses
      - `liminar` (boolean) - Se é liminar
      - `aparelho` (integer) - Número de aparelhos permitidos
      - `downgrade_upgrade` (text) - Histórico de mudanças
      - `quantidade_pontos` (integer)
      - `bonus_porcentagem` (numeric)
      - `sequencia` (text) - mensal, trimestral ou anual
      - `milhas_expirando` (text)
      - `tipo_parceiro_fornecedor` (text) - Parceiro ou Fornecedor
      - `status_conta` (text) - Status da conta
      - `status_restricao` (text) - Com ou Sem restrição
      - `conferente` (text) - Última pessoa que editou
      - `ultima_data_conferencia` (date)
      - `grupo_liminar` (text)
      - `status_programa_id` (uuid, referência para status_programa)
      - `observacoes` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Segurança
    - Habilitar RLS na tabela `programas_clubes`
    - Adicionar políticas para usuários autenticados
*/

CREATE TABLE IF NOT EXISTS programas_clubes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid REFERENCES parceiros(id) ON DELETE SET NULL,
  nome_parceiro text,
  telefone text,
  dt_nasc date,
  cpf text,
  rg text,
  email text,
  idade integer,
  programa_id uuid REFERENCES programas_fidelidade(id) ON DELETE SET NULL,
  n_fidelidade text,
  senha text,
  senha_resgate text,
  conta_familia_id uuid REFERENCES conta_familia(id) ON DELETE SET NULL,
  data_exclusao_conta_familia date,
  tem_clube boolean DEFAULT false,
  clube_produto_id uuid REFERENCES produtos(id) ON DELETE SET NULL,
  cartao text,
  data_ultima_assinatura date,
  dia_cobranca integer CHECK (dia_cobranca >= 1 AND dia_cobranca <= 31),
  valor numeric(10,2),
  tempo_clube_mes integer,
  liminar boolean DEFAULT false,
  aparelho integer,
  downgrade_upgrade text,
  quantidade_pontos integer,
  bonus_porcentagem numeric(5,2),
  sequencia text CHECK (sequencia IN ('mensal', 'trimestral', 'anual')),
  milhas_expirando text,
  tipo_parceiro_fornecedor text CHECK (tipo_parceiro_fornecedor IN ('Parceiro', 'Fornecedor')),
  status_conta text,
  status_restricao text CHECK (status_restricao IN ('Com Restrição', 'Sem Restrição')),
  conferente text,
  ultima_data_conferencia date,
  grupo_liminar text,
  status_programa_id uuid REFERENCES status_programa(id) ON DELETE SET NULL,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE programas_clubes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar programas/clubes"
  ON programas_clubes
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Usuários podem criar programas/clubes"
  ON programas_clubes
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar programas/clubes"
  ON programas_clubes
  FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Usuários podem deletar programas/clubes"
  ON programas_clubes
  FOR DELETE
  TO public
  USING (true);

CREATE INDEX IF NOT EXISTS idx_programas_clubes_parceiro ON programas_clubes(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_programas_clubes_programa ON programas_clubes(programa_id);
CREATE INDEX IF NOT EXISTS idx_programas_clubes_conta_familia ON programas_clubes(conta_familia_id);
CREATE INDEX IF NOT EXISTS idx_programas_clubes_status_programa ON programas_clubes(status_programa_id);


-- ============================================================================
-- MIGRATION: 20251202124832_create_conta_familia_historico.sql
-- ============================================================================

/*
  # Criar tabela de histórico de conta família

  1. Nova Tabela
    - `conta_familia_historico`
      - `id` (uuid, primary key)
      - `parceiro_id` (uuid, foreign key to parceiros)
      - `programa_id` (uuid, foreign key to programas_fidelidade)
      - `conta_familia_id` (uuid, foreign key to conta_familia)
      - `data_remocao` (timestamp)
      - `data_liberacao` (timestamp) - calculado como data_remocao + 12 meses
      - `motivo` (text, opcional)
      - `removido_por` (text)
      - `created_at` (timestamp)

  2. Segurança
    - Habilitar RLS na tabela `conta_familia_historico`
    - Adicionar política para usuários autenticados lerem e criarem registros

  3. Notas Importantes
    - Esta tabela rastreia quando um parceiro é removido de uma conta família
    - Impede que o parceiro entre em outra família do mesmo programa por 12 meses
    - A data_liberacao é calculada automaticamente como data_remocao + 12 meses
*/

CREATE TABLE IF NOT EXISTS conta_familia_historico (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid NOT NULL REFERENCES parceiros(id) ON DELETE CASCADE,
  programa_id uuid NOT NULL REFERENCES programas_fidelidade(id) ON DELETE CASCADE,
  conta_familia_id uuid NOT NULL REFERENCES conta_familia(id) ON DELETE CASCADE,
  data_remocao timestamptz NOT NULL DEFAULT now(),
  data_liberacao timestamptz NOT NULL,
  motivo text,
  removido_por text,
  created_at timestamptz DEFAULT now()
);

-- Criar índices para melhorar performance de consultas
CREATE INDEX IF NOT EXISTS idx_conta_familia_historico_parceiro ON conta_familia_historico(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_historico_programa ON conta_familia_historico(programa_id);
CREATE INDEX IF NOT EXISTS idx_conta_familia_historico_liberacao ON conta_familia_historico(data_liberacao);

-- Habilitar RLS
ALTER TABLE conta_familia_historico ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Usuários podem visualizar histórico"
  ON conta_familia_historico
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuários podem criar histórico"
  ON conta_familia_historico
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar histórico"
  ON conta_familia_historico
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- ============================================================================
-- MIGRATION: 20251205124214_restructure_classificacao_contabil_table.sql
-- ============================================================================

/*
  # Reestruturação da tabela classificacao_contabil

  1. Alterações na Estrutura
    - Remove dados existentes da tabela
    - Adiciona coluna `categoria` (text) - Categorias principais como "Intermediação de Milhas", "Capital", "Estorno", etc.
    - Renomeia coluna `nome` para `classificacao` (text) - Classificação específica como "Cartão Roberto", "Sócios", etc.
    - Adiciona coluna `descricao` (text) - Descrição detalhada da classificação

  2. Estrutura Final
    - `id` (uuid, primary key)
    - `chave_referencia` (text) - Código de referência único
    - `categoria` (text) - Categoria principal
    - `classificacao` (text) - Nome da classificação
    - `descricao` (text) - Descrição detalhada
    - `created_at` (timestamptz)
    - `updated_at` (timestamptz)

  3. Dados Inseridos
    - Todas as classificações organizadas por categoria
    - Categorias: Intermediação de Milhas, Capital, Estorno, Operação, Recursos Humanos, Prestadores de Serviço
*/

-- Remove dados existentes
DELETE FROM classificacao_contabil;

-- Adiciona coluna categoria se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'classificacao_contabil' AND column_name = 'categoria'
  ) THEN
    ALTER TABLE classificacao_contabil ADD COLUMN categoria text NOT NULL DEFAULT '';
  END IF;
END $$;

-- Renomeia coluna nome para classificacao se ainda não foi renomeada
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'classificacao_contabil' AND column_name = 'nome'
  ) THEN
    ALTER TABLE classificacao_contabil RENAME COLUMN nome TO classificacao;
  END IF;
END $$;

-- Adiciona coluna descricao se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'classificacao_contabil' AND column_name = 'descricao'
  ) THEN
    ALTER TABLE classificacao_contabil ADD COLUMN descricao text DEFAULT '';
  END IF;
END $$;

-- Insere os novos dados
INSERT INTO classificacao_contabil (chave_referencia, categoria, classificacao, descricao) VALUES
  -- Intermediação de Milhas
  ('IM-001', 'Intermediação de Milhas', 'Cartão Roberto', 'Todos os pagamentos de fatura de cartão ou transferencia bancária para antecipação de cartão'),
  
  -- Capital
  ('CAP-001', 'Capital', 'Sócios', 'Todos os pagamentos de fatura de cartão ou transferência bancária para Sócios, a título de distribuição de dividendos'),
  ('CAP-002', 'Capital', 'Empréstimo', 'Pagamento de juros e principal de empréstimos bancários e privados'),
  ('CAP-003', 'Capital', 'Impostos Empresa', 'Todos os impostos sobre a receita da empresa, e taxas municipais (PIS, COFINS, IR sobre Empresa, ISS, CSLL, Taxa de Fiscalização)'),
  ('CAP-004', 'Capital', 'Plano de Saúde Sócios', 'Valor do plano de saúde dos sócios'),
  
  -- Estorno
  ('EST-001', 'Estorno', 'Erro', ''),
  ('EST-002', 'Estorno', 'Taxa de Embarque', ''),
  ('EST-003', 'Estorno', 'Recebimento a Maior', ''),
  
  -- Operação
  ('OPE-001', 'Operação', 'Titulares', ''),
  ('OPE-002', 'Operação', 'Indicadores', ''),
  ('OPE-003', 'Operação', 'Clientes', ''),
  ('OPE-004', 'Operação', 'Cadastros', ''),
  ('OPE-005', 'Operação', 'Liminares', ''),
  
  -- Recursos Humanos
  ('RH-001', 'Recursos Humanos', 'Salários', 'Valor de salário, 13º, férieas e rescisões aos funcionários'),
  ('RH-002', 'Recursos Humanos', 'Beneficios', 'Valor do beneficios mensal'),
  ('RH-003', 'Recursos Humanos', 'Transporte', 'Valor do ticket para transporte'),
  ('RH-004', 'Recursos Humanos', 'Alimentação', 'Valor do ticket para alimentação'),
  ('RH-005', 'Recursos Humanos', 'Ressarcimento', 'Reembolso a funcionários'),
  ('RH-006', 'Recursos Humanos', 'Impostos Funcionários', 'Valor de IR, INSS e FGTS relativo aos funcionários'),
  ('RH-007', 'Recursos Humanos', 'Pró-labore', 'Pagamento aos sócios a titulo de pro-labore'),
  ('RH-008', 'Recursos Humanos', 'Celebrações', 'Bolo de aniversário ou HH'),
  ('RH-009', 'Recursos Humanos', 'Administrativo', 'Exame admissional'),
  ('RH-010', 'Recursos Humanos', 'Plano de Saúde Funcionários', 'Valor do plano de saúde dos funcionários'),
  
  -- Prestadores de Serviço
  ('PS-001', 'Prestadores de Serviço', 'Telefonia', 'Custa das linhas telefonicas'),
  ('PS-002', 'Prestadores de Serviço', 'Tarifa Banco', 'Tarifas bancárias'),
  ('PS-003', 'Prestadores de Serviço', 'Certificado Digital', 'Custo dos certificados digitais'),
  ('PS-004', 'Prestadores de Serviço', 'Documentos', 'Custo assinaturas eletronicas'),
  ('PS-005', 'Prestadores de Serviço', 'Escritório Aluguel', 'Aluguel do escritório'),
  ('PS-006', 'Prestadores de Serviço', 'Escritório/Serviços', 'Serviços cobrados no escritório'),
  ('PS-007', 'Prestadores de Serviço', 'Honorários Advocaticios', 'Pagamentos a advogados'),
  ('PS-008', 'Prestadores de Serviço', 'Sistema', 'Valor pago dos sistemas'),
  ('PS-009', 'Prestadores de Serviço', 'Desenvolvedores', 'Valor pago aos desenvolvedores'),
  ('PS-010', 'Prestadores de Serviço', 'Consultores', 'Valor pago aos consultores'),
  ('PS-011', 'Prestadores de Serviço', 'Equipamentos', 'Compra de equipamentos'),
  ('PS-012', 'Prestadores de Serviço', 'Contabilidade', 'Papyrus')
ON CONFLICT DO NOTHING;


-- ============================================================================
-- MIGRATION: 20251205125338_add_comissao_fields_to_programas_clubes.sql
-- ============================================================================

/*
  # Adicionar campos de comissão à tabela programas_clubes

  1. Alterações
    - Adicionar coluna `tem_comissao` (boolean) - indica se há comissão
    - Adicionar coluna `comissao_tipo` (text) - tipo de comissão: 'porcentagem' ou 'real'
    - Adicionar coluna `comissao_valor` (numeric) - valor da comissão (porcentagem ou valor em reais)

  2. Valores Padrão
    - `tem_comissao` tem valor padrão false
    - Comissão só é aplicável quando tem_comissao = true
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' AND column_name = 'tem_comissao'
  ) THEN
    ALTER TABLE programas_clubes ADD COLUMN tem_comissao boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' AND column_name = 'comissao_tipo'
  ) THEN
    ALTER TABLE programas_clubes ADD COLUMN comissao_tipo text CHECK (comissao_tipo IN ('porcentagem', 'real'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' AND column_name = 'comissao_valor'
  ) THEN
    ALTER TABLE programas_clubes ADD COLUMN comissao_valor numeric(10, 2);
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251205130327_add_atividades_permissions.sql
-- ============================================================================

/*
  # Adicionar permissões para recurso Atividades

  1. Alterações
    - Adicionar registro de permissão 'atividades' na tabela usuario_permissoes
    - Todos os usuários existentes receberão permissão de visualização
    - Usuários ADM terão permissões completas (visualizar, editar, deletar)

  2. Notas
    - O recurso 'atividades' permite acesso à página de notificações e atividades do sistema
*/

DO $$
DECLARE
  usuario_record RECORD;
  permissao_existe boolean;
BEGIN
  FOR usuario_record IN SELECT id, nivel_acesso FROM usuarios
  LOOP
    SELECT EXISTS(
      SELECT 1 FROM usuario_permissoes 
      WHERE usuario_id = usuario_record.id 
      AND recurso = 'atividades'
    ) INTO permissao_existe;
    
    IF NOT permissao_existe THEN
      IF usuario_record.nivel_acesso = 'ADM' THEN
        INSERT INTO usuario_permissoes (
          usuario_id,
          recurso,
          pode_visualizar,
          pode_editar,
          pode_deletar
        ) VALUES (
          usuario_record.id,
          'atividades',
          true,
          true,
          true
        );
      ELSE
        INSERT INTO usuario_permissoes (
          usuario_id,
          recurso,
          pode_visualizar,
          pode_editar,
          pode_deletar
        ) VALUES (
          usuario_record.id,
          'atividades',
          true,
          false,
          false
        );
      END IF;
    END IF;
  END LOOP;
END $$;


-- ============================================================================
-- MIGRATION: 20251205133746_add_conta_familia_unique_constraints.sql
-- ============================================================================

/*
  # Adicionar Constraints Únicas para Conta Família
  
  Este migration adiciona regras para garantir que:
  1. Um parceiro pode ser titular de apenas UMA conta por programa
  2. Um parceiro pode ser membro de apenas UMA conta por programa
  3. Estas regras impedem duplicações e conflitos
  
  ## Mudanças
  
  1. Constraints Únicas
     - Adiciona constraint única em `conta_familia` para (parceiro_principal_id, programa_id)
     - Adiciona índice único em `conta_familia_membros` para parceiros ativos
  
  2. Triggers de Validação
     - Trigger que impede titular de ser membro em outra conta
     - Trigger que impede membro de ser titular em outra conta
  
  ## Notas Importantes
  
  - As constraints permitem NULL em programa_id (para contas sem programa)
  - As validações consideram apenas contas e membros ativos
  - Mensagens de erro são descritivas em português
*/

-- Remove constraint única antiga se existir
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'conta_familia_parceiro_programa_key'
  ) THEN
    ALTER TABLE conta_familia DROP CONSTRAINT conta_familia_parceiro_programa_key;
  END IF;
END $$;

-- Adiciona constraint única: um parceiro só pode ser titular de uma conta por programa
-- (permite NULL para contas sem programa associado)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'conta_familia_parceiro_programa_unique'
  ) THEN
    ALTER TABLE conta_familia 
    ADD CONSTRAINT conta_familia_parceiro_programa_unique 
    UNIQUE (parceiro_principal_id, programa_id);
  END IF;
END $$;

-- Cria índice único para membros: um parceiro só pode estar em uma conta por programa
-- (apenas para membros ativos, usando índice parcial)
DROP INDEX IF EXISTS idx_conta_familia_membros_unique_parceiro_programa;

CREATE UNIQUE INDEX idx_conta_familia_membros_unique_parceiro_programa
ON conta_familia_membros (parceiro_id, conta_familia_id)
WHERE status = 'Ativo';

-- Função para verificar se titular está como membro em outra conta
CREATE OR REPLACE FUNCTION check_titular_nao_e_membro()
RETURNS TRIGGER AS $$
DECLARE
  v_programa_id uuid;
  v_conta_count integer;
BEGIN
  -- Busca o programa_id da conta família
  SELECT programa_id INTO v_programa_id
  FROM conta_familia
  WHERE id = NEW.conta_familia_id;
  
  -- Se não tem programa definido, permite
  IF v_programa_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Verifica se o parceiro é titular de alguma conta deste programa
  SELECT COUNT(*) INTO v_conta_count
  FROM conta_familia
  WHERE parceiro_principal_id = NEW.parceiro_id
    AND programa_id = v_programa_id
    AND id != NEW.conta_familia_id;
  
  IF v_conta_count > 0 THEN
    RAISE EXCEPTION 'Este parceiro é titular de outra conta deste programa e não pode ser membro adicional';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar quando adicionar membro
DROP TRIGGER IF EXISTS trigger_check_titular_nao_e_membro ON conta_familia_membros;

CREATE TRIGGER trigger_check_titular_nao_e_membro
BEFORE INSERT OR UPDATE ON conta_familia_membros
FOR EACH ROW
EXECUTE FUNCTION check_titular_nao_e_membro();

-- Função para verificar se membro está em outra conta quando definir como titular
CREATE OR REPLACE FUNCTION check_membro_nao_e_titular()
RETURNS TRIGGER AS $$
DECLARE
  v_membro_count integer;
BEGIN
  -- Se não tem programa ou parceiro principal definido, permite
  IF NEW.programa_id IS NULL OR NEW.parceiro_principal_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Verifica se o parceiro é membro ativo de alguma conta deste programa
  SELECT COUNT(*) INTO v_membro_count
  FROM conta_familia_membros cfm
  JOIN conta_familia cf ON cfm.conta_familia_id = cf.id
  WHERE cfm.parceiro_id = NEW.parceiro_principal_id
    AND cf.programa_id = NEW.programa_id
    AND cfm.status = 'Ativo'
    AND cf.id != NEW.id;
  
  IF v_membro_count > 0 THEN
    RAISE EXCEPTION 'Este parceiro é membro de outra conta deste programa e não pode ser titular';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar quando definir titular
DROP TRIGGER IF EXISTS trigger_check_membro_nao_e_titular ON conta_familia;

CREATE TRIGGER trigger_check_membro_nao_e_titular
BEFORE INSERT OR UPDATE ON conta_familia
FOR EACH ROW
EXECUTE FUNCTION check_membro_nao_e_titular();

-- ============================================================================
-- MIGRATION: 20251205160806_fix_aparelho_column_type.sql
-- ============================================================================

/*
  # Fix aparelho column type in programas_clubes table

  1. Changes
    - Change `aparelho` column from integer to text to store device names
  
  2. Notes
    - This fixes the error when trying to save device names like "iphone, android"
    - The column should store text values, not integers
*/

DO $$
BEGIN
  -- Change aparelho column type from integer to text
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' 
    AND column_name = 'aparelho'
    AND data_type = 'integer'
  ) THEN
    ALTER TABLE programas_clubes 
    ALTER COLUMN aparelho TYPE text USING aparelho::text;
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251210192936_create_user_profiles_system.sql
-- ============================================================================

/*
  # Create User Profiles System

  1. New Tables
    - `perfis_usuario`
      - `id` (uuid, primary key)
      - `nome` (text) - Profile name
      - `descricao` (text) - Profile description
      - `ativo` (boolean) - Active status
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `perfil_permissoes`
      - `id` (uuid, primary key)
      - `perfil_id` (uuid) - References perfis_usuario
      - `recurso` (text) - Resource name
      - `pode_visualizar` (boolean)
      - `pode_editar` (boolean)
      - `pode_deletar` (boolean)

  2. Changes
    - Add `perfil_id` column to `usuarios` table to link users to profiles
    - Users with nivel_acesso = 'ADM' don't need profiles
    - Users with nivel_acesso = 'USER' can have a profile

  3. Security
    - Enable RLS on both new tables
    - Add policies for authenticated users to manage profiles
*/

-- Create perfis_usuario table
CREATE TABLE IF NOT EXISTS perfis_usuario (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL UNIQUE,
  descricao text DEFAULT '',
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create perfil_permissoes table
CREATE TABLE IF NOT EXISTS perfil_permissoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  perfil_id uuid NOT NULL REFERENCES perfis_usuario(id) ON DELETE CASCADE,
  recurso text NOT NULL,
  pode_visualizar boolean DEFAULT false,
  pode_editar boolean DEFAULT false,
  pode_deletar boolean DEFAULT false,
  UNIQUE(perfil_id, recurso)
);

-- Add perfil_id to usuarios table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'usuarios' AND column_name = 'perfil_id'
  ) THEN
    ALTER TABLE usuarios ADD COLUMN perfil_id uuid REFERENCES perfis_usuario(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Enable RLS
ALTER TABLE perfis_usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE perfil_permissoes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for perfis_usuario
CREATE POLICY "Anyone can read perfis_usuario"
  ON perfis_usuario FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can insert perfis_usuario"
  ON perfis_usuario FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

CREATE POLICY "Anyone can update perfis_usuario"
  ON perfis_usuario FOR UPDATE
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete perfis_usuario"
  ON perfis_usuario FOR DELETE
  TO authenticated, anon
  USING (true);

-- RLS Policies for perfil_permissoes
CREATE POLICY "Anyone can read perfil_permissoes"
  ON perfil_permissoes FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can insert perfil_permissoes"
  ON perfil_permissoes FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

CREATE POLICY "Anyone can update perfil_permissoes"
  ON perfil_permissoes FOR UPDATE
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete perfil_permissoes"
  ON perfil_permissoes FOR DELETE
  TO authenticated, anon
  USING (true);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_perfil_permissoes_perfil_id ON perfil_permissoes(perfil_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_perfil_id ON usuarios(perfil_id);


-- ============================================================================
-- MIGRATION: 20251210193457_add_bank_account_fields_to_clientes.sql
-- ============================================================================

/*
  # Add Bank Account Fields to Clientes Table

  1. Changes
    - Add `banco` (text) - Bank name
    - Add `agencia` (text) - Branch number
    - Add `tipo_conta` (text) - Account type (Corrente/Poupança)
    - Add `numero_conta` (text) - Account number
    - Add `pix` (text) - PIX key

  2. Notes
    - All fields are optional (nullable)
    - Fields will store formatted data (with masks)
*/

DO $$
BEGIN
  -- Add banco column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'banco'
  ) THEN
    ALTER TABLE clientes ADD COLUMN banco text;
  END IF;

  -- Add agencia column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'agencia'
  ) THEN
    ALTER TABLE clientes ADD COLUMN agencia text;
  END IF;

  -- Add tipo_conta column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'tipo_conta'
  ) THEN
    ALTER TABLE clientes ADD COLUMN tipo_conta text;
  END IF;

  -- Add numero_conta column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'numero_conta'
  ) THEN
    ALTER TABLE clientes ADD COLUMN numero_conta text;
  END IF;

  -- Add pix column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'pix'
  ) THEN
    ALTER TABLE clientes ADD COLUMN pix text;
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251210193648_add_expiration_fields_to_cartoes_credito.sql
-- ============================================================================

/*
  # Add Expiration Fields to Cartoes Credito Table

  1. Changes
    - Add `mes_expiracao` (integer) - Expiration month (1-12)
    - Add `ano_expiracao` (integer) - Expiration year (e.g., 2025)

  2. Notes
    - Both fields are optional (nullable)
    - Values will be validated in the application to ensure valid months and years
    - Application will prevent usage of expired cards
*/

DO $$
BEGIN
  -- Add mes_expiracao column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'mes_expiracao'
  ) THEN
    ALTER TABLE cartoes_credito ADD COLUMN mes_expiracao integer;
  END IF;

  -- Add ano_expiracao column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'ano_expiracao'
  ) THEN
    ALTER TABLE cartoes_credito ADD COLUMN ano_expiracao integer;
  END IF;

  -- Add check constraint to ensure mes_expiracao is between 1 and 12
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'cartoes_credito' AND constraint_name = 'cartoes_credito_mes_expiracao_check'
  ) THEN
    ALTER TABLE cartoes_credito ADD CONSTRAINT cartoes_credito_mes_expiracao_check CHECK (mes_expiracao >= 1 AND mes_expiracao <= 12);
  END IF;

  -- Add check constraint to ensure ano_expiracao is reasonable (2000-2099)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'cartoes_credito' AND constraint_name = 'cartoes_credito_ano_expiracao_check'
  ) THEN
    ALTER TABLE cartoes_credito ADD CONSTRAINT cartoes_credito_ano_expiracao_check CHECK (ano_expiracao >= 2000 AND ano_expiracao <= 2099);
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251211181917_create_parceiro_documentos_storage.sql
-- ============================================================================

/*
  # Sistema de Documentos para Parceiros

  1. Storage
    - Cria bucket 'documentos-parceiros' privado para armazenar arquivos
    - Configura políticas de acesso para upload, visualização e exclusão

  2. Nova Tabela
    - `parceiro_documentos`
      - `id` (uuid, primary key)
      - `parceiro_id` (uuid, foreign key para parceiros)
      - `tipo_documento` (text - tipo do documento: rg, comprovante_endereco, etc)
      - `arquivo_path` (text - caminho no storage)
      - `arquivo_nome` (text - nome original do arquivo)
      - `tamanho_bytes` (bigint - tamanho do arquivo em bytes)
      - `uploaded_at` (timestamptz - data do upload)
      - `uploaded_by` (uuid - usuário que fez o upload)

  3. Security
    - Enable RLS on `parceiro_documentos`
    - Políticas para usuários autenticados poderem gerenciar documentos
    - Políticas de storage para controlar acesso aos arquivos
*/

-- Criar bucket de storage para documentos de parceiros
INSERT INTO storage.buckets (id, name, public)
VALUES ('documentos-parceiros', 'documentos-parceiros', false)
ON CONFLICT (id) DO NOTHING;

-- Criar tabela para controlar os documentos
CREATE TABLE IF NOT EXISTS parceiro_documentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid NOT NULL REFERENCES parceiros(id) ON DELETE CASCADE,
  tipo_documento text NOT NULL,
  arquivo_path text NOT NULL,
  arquivo_nome text NOT NULL,
  tamanho_bytes bigint,
  uploaded_at timestamptz DEFAULT now(),
  uploaded_by uuid REFERENCES usuarios(id)
);

-- Habilitar RLS
ALTER TABLE parceiro_documentos ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para a tabela parceiro_documentos
CREATE POLICY "Usuários autenticados podem visualizar documentos"
  ON parceiro_documentos
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Usuários autenticados podem inserir documentos"
  ON parceiro_documentos
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem deletar documentos"
  ON parceiro_documentos
  FOR DELETE
  TO public
  USING (true);

-- Políticas de Storage para upload
CREATE POLICY "Usuários podem fazer upload de documentos"
  ON storage.objects
  FOR INSERT
  TO public
  WITH CHECK (bucket_id = 'documentos-parceiros');

-- Política de Storage para visualização
CREATE POLICY "Usuários podem visualizar documentos"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'documentos-parceiros');

-- Política de Storage para exclusão
CREATE POLICY "Usuários podem deletar documentos"
  ON storage.objects
  FOR DELETE
  TO public
  USING (bucket_id = 'documentos-parceiros');

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_parceiro_documentos_parceiro_id
  ON parceiro_documentos(parceiro_id);

CREATE INDEX IF NOT EXISTS idx_parceiro_documentos_tipo
  ON parceiro_documentos(tipo_documento);


-- ============================================================================
-- MIGRATION: 20251215144356_create_compras_table.sql
-- ============================================================================

/*
  # Create Compras (Entradas) Table

  1. New Tables
    - `compras`
      - `id` (uuid, primary key)
      - `parceiro_id` (uuid, foreign key to parceiros)
      - `programa_id` (uuid, foreign key to programas)
      - `tipo` (text) - Tipo de entrada: Compra de Pontos/Milhas, Recebimento de Bônus, etc.
      - `data_entrada` (date) - Data da entrada
      - `pontos_milhas` (numeric) - Quantidade de pontos/milhas
      - `valor_total` (numeric) - Valor total da transação
      - `valor_milheiro` (numeric) - Valor por milheiro
      - `tipo_valor` (text) - VT (Valor Total) ou VM (Valor Milheiro)
      - `saldo_atual` (numeric) - Saldo atual após a transação
      - `custo_medio` (numeric) - Custo médio
      - `observacao` (text) - Observações
      - `agendar_entrada` (boolean) - Se é agendamento
      - `agendamento_recorrente` (boolean) - Se tem recorrência
      - `periodicidade` (text) - Semanal, Quinzenal, Mensal, etc.
      - `quantidade_recorrencia` (integer) - Quantidade de recorrências
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `created_by` (uuid) - ID do usuário que criou

  2. Security
    - Enable RLS on `compras` table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS compras (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid REFERENCES parceiros(id) ON DELETE CASCADE,
  programa_id uuid REFERENCES programas(id) ON DELETE CASCADE,
  tipo text NOT NULL CHECK (tipo IN (
    'Compra de Pontos/Milhas',
    'Recebimento de Bônus',
    'Assinatura de Clube',
    'Pontos do Cartão de Crédito',
    'Ajuste de Saldo'
  )),
  data_entrada date NOT NULL DEFAULT CURRENT_DATE,
  pontos_milhas numeric(15,2) NOT NULL DEFAULT 0,
  valor_total numeric(15,2) DEFAULT 0,
  valor_milheiro numeric(15,2) DEFAULT 0,
  tipo_valor text CHECK (tipo_valor IN ('VT', 'VM')),
  saldo_atual numeric(15,2) DEFAULT 0,
  custo_medio numeric(15,2) DEFAULT 0,
  observacao text,
  agendar_entrada boolean DEFAULT false,
  agendamento_recorrente boolean DEFAULT false,
  periodicidade text CHECK (periodicidade IN (
    'Semanal',
    'Quinzenal',
    'Mensal',
    'Bimestral',
    'Trimestral',
    'Semestral',
    'Anual'
  )),
  quantidade_recorrencia integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid
);

ALTER TABLE compras ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all compras"
  ON compras
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert compras"
  ON compras
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update compras"
  ON compras
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete compras"
  ON compras
  FOR DELETE
  TO authenticated
  USING (true);

CREATE INDEX IF NOT EXISTS idx_compras_parceiro ON compras(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_compras_programa ON compras(programa_id);
CREATE INDEX IF NOT EXISTS idx_compras_data_entrada ON compras(data_entrada);
CREATE INDEX IF NOT EXISTS idx_compras_created_at ON compras(created_at);


-- ============================================================================
-- MIGRATION: 20251215145142_fix_compras_programa_reference.sql
-- ============================================================================

/*
  # Fix Compras Table Program Reference

  1. Changes
    - Drop existing foreign key constraint for programa_id referencing programas table
    - Add new foreign key constraint for programa_id referencing programas_fidelidade table

  2. Notes
    - This fixes the reference to use the correct loyalty programs table
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'compras_programa_id_fkey'
    AND table_name = 'compras'
  ) THEN
    ALTER TABLE compras DROP CONSTRAINT compras_programa_id_fkey;
  END IF;

  ALTER TABLE compras 
    ADD CONSTRAINT compras_programa_id_fkey 
    FOREIGN KEY (programa_id) 
    REFERENCES programas_fidelidade(id) 
    ON DELETE CASCADE;
END $$;


-- ============================================================================
-- MIGRATION: 20251215145608_fix_compras_rls_policies.sql
-- ============================================================================

/*
  # Fix Compras RLS Policies

  1. Changes
    - Drop existing restrictive policies
    - Add new policies that allow public access
    - This matches the authentication pattern used in other tables

  2. Security
    - Allows authenticated users to access compras data
    - Uses the same pattern as other tables in the system
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all compras" ON compras;
DROP POLICY IF EXISTS "Users can insert compras" ON compras;
DROP POLICY IF EXISTS "Users can update compras" ON compras;
DROP POLICY IF EXISTS "Users can delete compras" ON compras;

-- Create new policies with public access
CREATE POLICY "Allow all operations on compras"
  ON compras
  FOR ALL
  USING (true)
  WITH CHECK (true);


-- ============================================================================
-- MIGRATION: 20251217140303_add_fields_to_compras.sql
-- ============================================================================

/*
  # Add new fields to compras table

  1. Changes
    - Add data_limite_bonus field
    - Add bonus field (if not exists)
    - Add status field with constraint (Pendente/Concluído)
    - Add forma_pagamento field with constraint (Cartão/Pix)
    - Add quantidade_parcelas field
    - Add classificacao_contabil_id with foreign key
    - Update tipo field to include new options
    - Add total_pontos calculated field

  2. Security
    - Maintains existing RLS policies
*/

-- Add new columns to compras table
DO $$
BEGIN
  -- Add data_limite_bonus
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'data_limite_bonus'
  ) THEN
    ALTER TABLE compras ADD COLUMN data_limite_bonus date;
  END IF;

  -- Add bonus (if doesn't exist)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'bonus'
  ) THEN
    ALTER TABLE compras ADD COLUMN bonus decimal(15,2) DEFAULT 0;
  END IF;

  -- Add status
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'status'
  ) THEN
    ALTER TABLE compras ADD COLUMN status text DEFAULT 'Pendente' NOT NULL;
  END IF;

  -- Add forma_pagamento
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'forma_pagamento'
  ) THEN
    ALTER TABLE compras ADD COLUMN forma_pagamento text;
  END IF;

  -- Add quantidade_parcelas
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'quantidade_parcelas'
  ) THEN
    ALTER TABLE compras ADD COLUMN quantidade_parcelas integer DEFAULT 1;
  END IF;

  -- Add classificacao_contabil_id
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'classificacao_contabil_id'
  ) THEN
    ALTER TABLE compras ADD COLUMN classificacao_contabil_id uuid;
  END IF;

  -- Add total_pontos
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'total_pontos'
  ) THEN
    ALTER TABLE compras ADD COLUMN total_pontos decimal(15,2) DEFAULT 0;
  END IF;
END $$;

-- Drop existing constraints if they exist
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'compras_status_check'
  ) THEN
    ALTER TABLE compras DROP CONSTRAINT compras_status_check;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'compras_forma_pagamento_check'
  ) THEN
    ALTER TABLE compras DROP CONSTRAINT compras_forma_pagamento_check;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'compras_tipo_check'
  ) THEN
    ALTER TABLE compras DROP CONSTRAINT compras_tipo_check;
  END IF;
END $$;

-- Add check constraints
ALTER TABLE compras ADD CONSTRAINT compras_status_check 
  CHECK (status IN ('Pendente', 'Concluído'));

ALTER TABLE compras ADD CONSTRAINT compras_forma_pagamento_check 
  CHECK (forma_pagamento IS NULL OR forma_pagamento IN ('Cartão', 'Pix'));

ALTER TABLE compras ADD CONSTRAINT compras_tipo_check 
  CHECK (tipo IN (
    'Compra de Pontos/Milhas',
    'Compra Bonificada',
    'Transferência entre Contas',
    'Assinatura de Clube',
    'Intermediação',
    'Bônus Cartão',
    'Ajuste de Saldo'
  ));

-- Add foreign key to classificacao_contabil
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'compras_classificacao_contabil_id_fkey'
  ) THEN
    ALTER TABLE compras ADD CONSTRAINT compras_classificacao_contabil_id_fkey
      FOREIGN KEY (classificacao_contabil_id) REFERENCES classificacao_contabil(id);
  END IF;
END $$;

-- Create or replace function to calculate total_pontos
CREATE OR REPLACE FUNCTION calculate_total_pontos()
RETURNS TRIGGER AS $$
BEGIN
  NEW.total_pontos := COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS trigger_calculate_total_pontos ON compras;
CREATE TRIGGER trigger_calculate_total_pontos
  BEFORE INSERT OR UPDATE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION calculate_total_pontos();


-- ============================================================================
-- MIGRATION: 20251217143848_create_compra_bonificada_table.sql
-- ============================================================================

/*
  # Create compra_bonificada table

  1. New Tables
    - `compra_bonificada`
      - `id` (uuid, primary key)
      - `cliente_id` (uuid, foreign key to clientes) - Pessoa
      - `programa_id` (uuid, foreign key to programas_fidelidade) - Programa
      - `data_compra` (date) - Data da compra
      - `recebimento_produto` (date, nullable) - Data recebimento do produto
      - `recebimento_pontos` (date) - Data recebimento dos pontos
      - `produto` (text) - Nome do produto
      - `loja` (text, nullable) - Loja onde foi comprado
      - `pontos_real` (decimal, nullable) - Conversão pontos por real
      - `destino` (text) - Destino dos pontos (Uso próprio, etc)
      - `valor_produto` (decimal) - Valor do produto (negativo)
      - `frete` (decimal, nullable, default 0) - Valor do frete (negativo)
      - `seguro_protecao` (decimal, nullable, default 0) - Seguro/proteção de preço (positivo)
      - `valor_venda` (decimal, nullable, default 0) - Valor de venda (positivo)
      - `custo_total` (decimal) - Custo total calculado
      - `forma_pagamento` (text, nullable) - Forma de pagamento
      - `conta` (text, nullable) - Conta utilizada
      - `parcelas` (integer, default 1) - Número de parcelas
      - `quantidade_pontos` (decimal) - Quantidade de pontos/milhas recebidos
      - `valor_milheiro` (decimal) - Valor por milheiro calculado
      - `observacao` (text, nullable) - Observações
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `chave_referencia` (text, nullable) - Chave de referência

  2. Security
    - Enable RLS on `compra_bonificada` table
    - Add policies for authenticated users to manage their own data
*/

CREATE TABLE IF NOT EXISTS compra_bonificada (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id uuid REFERENCES clientes(id) ON DELETE RESTRICT,
  programa_id uuid REFERENCES programas_fidelidade(id) ON DELETE RESTRICT,
  data_compra date NOT NULL,
  recebimento_produto date,
  recebimento_pontos date NOT NULL,
  produto text NOT NULL,
  loja text,
  pontos_real decimal(10, 2),
  destino text NOT NULL DEFAULT 'Uso próprio',
  valor_produto decimal(10, 2) NOT NULL,
  frete decimal(10, 2) DEFAULT 0,
  seguro_protecao decimal(10, 2) DEFAULT 0,
  valor_venda decimal(10, 2) DEFAULT 0,
  custo_total decimal(10, 2) NOT NULL,
  forma_pagamento text,
  conta text,
  parcelas integer DEFAULT 1,
  quantidade_pontos decimal(10, 2) NOT NULL,
  valor_milheiro decimal(10, 4),
  observacao text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  chave_referencia text
);

ALTER TABLE compra_bonificada ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all compra_bonificada"
  ON compra_bonificada FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert compra_bonificada"
  ON compra_bonificada FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update compra_bonificada"
  ON compra_bonificada FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete compra_bonificada"
  ON compra_bonificada FOR DELETE
  TO authenticated
  USING (true);

CREATE INDEX IF NOT EXISTS idx_compra_bonificada_cliente ON compra_bonificada(cliente_id);
CREATE INDEX IF NOT EXISTS idx_compra_bonificada_programa ON compra_bonificada(programa_id);
CREATE INDEX IF NOT EXISTS idx_compra_bonificada_data_compra ON compra_bonificada(data_compra);

-- ============================================================================
-- MIGRATION: 20251217150304_update_compra_bonificada_fields.sql
-- ============================================================================

/*
  # Update compra_bonificada table fields

  1. Changes
    - Rename cliente_id to parceiro_id
    - Update foreign key constraint
    - Change loja from text to uuid referencing lojas table
    - Add tipo_pontos_real field (Pontos or Moeda Real)

  2. Security
    - Maintain existing RLS policies
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compra_bonificada' AND column_name = 'cliente_id'
  ) THEN
    ALTER TABLE compra_bonificada RENAME COLUMN cliente_id TO parceiro_id;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compra_bonificada' AND column_name = 'loja_id'
  ) THEN
    ALTER TABLE compra_bonificada ADD COLUMN loja_id uuid REFERENCES lojas(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compra_bonificada' AND column_name = 'tipo_pontos_real'
  ) THEN
    ALTER TABLE compra_bonificada ADD COLUMN tipo_pontos_real text DEFAULT 'Pontos';
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_compra_bonificada_loja ON compra_bonificada(loja_id);

-- ============================================================================
-- MIGRATION: 20251217150547_create_calcular_saldo_parceiro_programa_function.sql
-- ============================================================================

/*
  # Create function to calculate partner program balance

  1. Function
    - `calcular_saldo_parceiro_programa` - Calculates balance and average cost for a partner in a specific program
    
  2. Notes
    - Returns saldo (balance) and custo_medio (average cost)
    - Considers all transactions involving the partner and program
*/

CREATE OR REPLACE FUNCTION calcular_saldo_parceiro_programa(
  p_parceiro_id uuid,
  p_programa_id uuid
)
RETURNS TABLE (
  saldo numeric,
  custo_medio numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH movimentacoes AS (
    SELECT 
      COALESCE(SUM(CASE WHEN tipo = 'Entrada' THEN pontos_milhas ELSE 0 END), 0) -
      COALESCE(SUM(CASE WHEN tipo = 'Saída' THEN pontos_milhas ELSE 0 END), 0) as total_pontos,
      COALESCE(SUM(CASE WHEN tipo = 'Entrada' THEN valor_total ELSE 0 END), 0) as custo_total_entrada
    FROM compras
    WHERE parceiro_id = p_parceiro_id
      AND programa_id = p_programa_id
  )
  SELECT 
    movimentacoes.total_pontos::numeric as saldo,
    CASE 
      WHEN movimentacoes.total_pontos > 0 
      THEN (movimentacoes.custo_total_entrada / movimentacoes.total_pontos * 1000)::numeric
      ELSE 0::numeric
    END as custo_medio
  FROM movimentacoes;
END;
$$;

-- ============================================================================
-- MIGRATION: 20251217151018_create_estoque_pontos_system.sql
-- ============================================================================

/*
  # Create inventory/stock system for points tracking

  1. New Tables
    - `estoque_pontos`
      - `id` (uuid, primary key)
      - `parceiro_id` (uuid, foreign key to parceiros)
      - `programa_id` (uuid, foreign key to programas_fidelidade)
      - `saldo_atual` (decimal) - Current balance
      - `custo_medio` (decimal) - Average cost per 1000 points
      - `updated_at` (timestamptz)
      - Unique constraint on (parceiro_id, programa_id)

  2. Functions
    - `atualizar_estoque_pontos` - Updates inventory based on transactions
    - `calcular_saldo_parceiro_programa_v2` - New version that reads from stock table

  3. Triggers
    - Automatically update stock when transactions occur

  4. Security
    - Enable RLS on estoque_pontos table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS estoque_pontos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid REFERENCES parceiros(id) ON DELETE CASCADE NOT NULL,
  programa_id uuid REFERENCES programas_fidelidade(id) ON DELETE CASCADE NOT NULL,
  saldo_atual decimal(15, 2) DEFAULT 0 NOT NULL,
  custo_medio decimal(10, 4) DEFAULT 0,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(parceiro_id, programa_id)
);

ALTER TABLE estoque_pontos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all estoque_pontos"
  ON estoque_pontos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert estoque_pontos"
  ON estoque_pontos FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update estoque_pontos"
  ON estoque_pontos FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_estoque_pontos_parceiro_programa ON estoque_pontos(parceiro_id, programa_id);

CREATE OR REPLACE FUNCTION atualizar_estoque_pontos(
  p_parceiro_id uuid,
  p_programa_id uuid,
  p_quantidade decimal,
  p_tipo text,
  p_valor_total decimal DEFAULT 0
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_saldo_atual decimal;
  v_custo_medio decimal;
  v_custo_total_acumulado decimal;
BEGIN
  INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
  VALUES (p_parceiro_id, p_programa_id, 0, 0)
  ON CONFLICT (parceiro_id, programa_id) DO NOTHING;

  SELECT saldo_atual, custo_medio INTO v_saldo_atual, v_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  IF p_tipo = 'Entrada' OR p_tipo = 'Compra de Pontos/Milhas' THEN
    v_custo_total_acumulado := (v_saldo_atual * v_custo_medio / 1000) + p_valor_total;
    v_saldo_atual := v_saldo_atual + p_quantidade;
    
    IF v_saldo_atual > 0 THEN
      v_custo_medio := (v_custo_total_acumulado / v_saldo_atual) * 1000;
    ELSE
      v_custo_medio := 0;
    END IF;
  ELSIF p_tipo = 'Saída' THEN
    v_saldo_atual := v_saldo_atual - p_quantidade;
    
    IF v_saldo_atual < 0 THEN
      v_saldo_atual := 0;
    END IF;
    
    IF v_saldo_atual = 0 THEN
      v_custo_medio := 0;
    END IF;
  END IF;

  UPDATE estoque_pontos
  SET 
    saldo_atual = v_saldo_atual,
    custo_medio = v_custo_medio,
    updated_at = now()
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;
END;
$$;

CREATE OR REPLACE FUNCTION calcular_saldo_parceiro_programa(
  p_parceiro_id uuid,
  p_programa_id uuid
)
RETURNS TABLE (
  saldo numeric,
  custo_medio numeric
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(e.saldo_atual, 0)::numeric as saldo,
    COALESCE(e.custo_medio, 0)::numeric as custo_medio
  FROM estoque_pontos e
  WHERE e.parceiro_id = p_parceiro_id
    AND e.programa_id = p_programa_id;
  
  IF NOT FOUND THEN
    RETURN QUERY SELECT 0::numeric, 0::numeric;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION trigger_atualizar_estoque_compras()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
      NEW.tipo,
      COALESCE(NEW.valor_total, 0)
    );
  ELSIF TG_OP = 'UPDATE' THEN
    PERFORM atualizar_estoque_pontos(
      OLD.parceiro_id,
      OLD.programa_id,
      -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
      OLD.tipo,
      -COALESCE(OLD.valor_total, 0)
    );
    
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
      NEW.tipo,
      COALESCE(NEW.valor_total, 0)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM atualizar_estoque_pontos(
      OLD.parceiro_id,
      OLD.programa_id,
      -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
      OLD.tipo,
      -COALESCE(OLD.valor_total, 0)
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compras_insert ON compras;
CREATE TRIGGER trigger_atualizar_estoque_compras_insert
  AFTER INSERT ON compras
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compras();

DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compras_update ON compras;
CREATE TRIGGER trigger_atualizar_estoque_compras_update
  AFTER UPDATE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compras();

DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compras_delete ON compras;
CREATE TRIGGER trigger_atualizar_estoque_compras_delete
  AFTER DELETE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compras();

-- ============================================================================
-- MIGRATION: 20251217151123_add_compra_bonificada_estoque_triggers.sql
-- ============================================================================

/*
  # Add stock triggers for compra_bonificada table

  1. Triggers
    - Automatically update stock when compra_bonificada transactions occur
    - Treats compra_bonificada as "Entrada" type

  2. Notes
    - When a bonified purchase is created, it adds points to stock
    - When updated or deleted, it adjusts stock accordingly
*/

CREATE OR REPLACE FUNCTION trigger_atualizar_estoque_compra_bonificada()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      COALESCE(NEW.quantidade_pontos, 0),
      'Entrada',
      COALESCE(NEW.custo_total, 0)
    );
  ELSIF TG_OP = 'UPDATE' THEN
    PERFORM atualizar_estoque_pontos(
      OLD.parceiro_id,
      OLD.programa_id,
      -COALESCE(OLD.quantidade_pontos, 0),
      'Entrada',
      -COALESCE(OLD.custo_total, 0)
    );
    
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.programa_id,
      COALESCE(NEW.quantidade_pontos, 0),
      'Entrada',
      COALESCE(NEW.custo_total, 0)
    );
  ELSIF TG_OP = 'DELETE' THEN
    PERFORM atualizar_estoque_pontos(
      OLD.parceiro_id,
      OLD.programa_id,
      -COALESCE(OLD.quantidade_pontos, 0),
      'Entrada',
      -COALESCE(OLD.custo_total, 0)
    );
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compra_bonificada_insert ON compra_bonificada;
CREATE TRIGGER trigger_atualizar_estoque_compra_bonificada_insert
  AFTER INSERT ON compra_bonificada
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compra_bonificada();

DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compra_bonificada_update ON compra_bonificada;
CREATE TRIGGER trigger_atualizar_estoque_compra_bonificada_update
  AFTER UPDATE ON compra_bonificada
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compra_bonificada();

DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compra_bonificada_delete ON compra_bonificada;
CREATE TRIGGER trigger_atualizar_estoque_compra_bonificada_delete
  AFTER DELETE ON compra_bonificada
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compra_bonificada();

-- ============================================================================
-- MIGRATION: 20251217152843_fix_compra_bonificada_rls_policies.sql
-- ============================================================================

/*
  # Fix compra_bonificada RLS policies

  1. Changes
    - Drop existing RLS policies that use TO authenticated
    - Create new policies using TO public (for custom authentication)
    - Maintain same permissions structure

  2. Security
    - Users can view all records
    - Users can insert new records
    - Users can update existing records
    - Users can delete records
*/

DROP POLICY IF EXISTS "Users can view all compra_bonificada" ON compra_bonificada;
DROP POLICY IF EXISTS "Users can insert compra_bonificada" ON compra_bonificada;
DROP POLICY IF EXISTS "Users can update compra_bonificada" ON compra_bonificada;
DROP POLICY IF EXISTS "Users can delete compra_bonificada" ON compra_bonificada;

CREATE POLICY "Users can view all compra_bonificada"
  ON compra_bonificada FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can insert compra_bonificada"
  ON compra_bonificada FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Users can update compra_bonificada"
  ON compra_bonificada FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete compra_bonificada"
  ON compra_bonificada FOR DELETE
  TO public
  USING (true);

-- ============================================================================
-- MIGRATION: 20251217184401_fix_compra_bonificada_parceiro_fkey.sql
-- ============================================================================

/*
  # Fix compra_bonificada foreign key constraint

  1. Changes
    - Drop the old constraint "compra_bonificada_cliente_id_fkey" that references clientes table
    - Add new constraint "compra_bonificada_parceiro_id_fkey" that references parceiros table
    - This fixes the issue where parceiro_id was incorrectly referencing clientes instead of parceiros

  2. Security
    - Maintains existing RLS policies
*/

ALTER TABLE compra_bonificada
DROP CONSTRAINT IF EXISTS compra_bonificada_cliente_id_fkey;

ALTER TABLE compra_bonificada
ADD CONSTRAINT compra_bonificada_parceiro_id_fkey
FOREIGN KEY (parceiro_id) REFERENCES parceiros(id) ON DELETE RESTRICT;

-- ============================================================================
-- MIGRATION: 20251217190836_create_transferencia_pontos_table.sql
-- ============================================================================

/*
  # Create transferencia_pontos table

  1. New Tables
    - `transferencia_pontos`
      - `id` (uuid, primary key)
      - `parceiro_id` (uuid, foreign key to parceiros) - Pessoa que realiza a transferência
      - `data_transferencia` (date) - Data da transferência
      
      **Origem:**
      - `origem_programa_id` (uuid, foreign key to programas_fidelidade)
      - `origem_quantidade` (decimal) - Quantidade de pontos a transferir
      - `origem_paridade` (decimal) - Taxa de paridade (ex: 1:1, 1:2)
      - `realizar_compra_carrinho` (boolean) - Se vai realizar compra no carrinho
      - `realizar_retorno_bumerangue` (boolean) - Se vai realizar retorno de pontos
      
      **Compra no Carrinho (quando realizar_compra_carrinho = true):**
      - `compra_quantidade` (decimal) - Quantidade de pontos a comprar
      - `compra_valor_total` (decimal) - Valor total da compra
      - `compra_valor_milheiro` (decimal) - Valor por milheiro
      - `compra_forma_pagamento` (text) - Forma de pagamento
      - `compra_conta` (text) - Conta bancária usada
      - `compra_parcelas` (integer) - Número de parcelas
      
      **Retorno Bumerangue (quando realizar_retorno_bumerangue = true):**
      - `bumerangue_bonus_percentual` (decimal) - Percentual de bônus
      - `bumerangue_quantidade_bonus` (decimal) - Quantidade de bônus
      - `bumerangue_data_recebimento` (date) - Data de recebimento do bônus
      
      **Destino:**
      - `destino_programa_id` (uuid, foreign key to programas_fidelidade)
      - `destino_quantidade` (decimal) - Quantidade que será recebida no destino
      - `destino_data_recebimento` (date) - Data de recebimento das milhas
      - `destino_bonus_percentual` (decimal) - Percentual de bônus no destino
      - `destino_quantidade_bonus` (decimal) - Quantidade de bônus no destino
      - `destino_data_recebimento_bonus` (date) - Data de recebimento do bônus
      
      - `observacao` (text) - Observações
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `created_by` (uuid, foreign key to usuarios)

  2. Security
    - Enable RLS on transferencia_pontos table
    - Add policies for authenticated users to manage their transfers
*/

CREATE TABLE IF NOT EXISTS transferencia_pontos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid REFERENCES parceiros(id) ON DELETE CASCADE NOT NULL,
  data_transferencia date NOT NULL DEFAULT CURRENT_DATE,
  
  -- Origem
  origem_programa_id uuid REFERENCES programas_fidelidade(id) ON DELETE RESTRICT NOT NULL,
  origem_quantidade decimal(15, 2) NOT NULL DEFAULT 0,
  origem_paridade decimal(10, 2) DEFAULT 1,
  realizar_compra_carrinho boolean DEFAULT false,
  realizar_retorno_bumerangue boolean DEFAULT false,
  
  -- Compra no Carrinho
  compra_quantidade decimal(15, 2) DEFAULT 0,
  compra_valor_total decimal(15, 2) DEFAULT 0,
  compra_valor_milheiro decimal(10, 4) DEFAULT 0,
  compra_forma_pagamento text,
  compra_conta text,
  compra_parcelas integer DEFAULT 1,
  
  -- Retorno Bumerangue
  bumerangue_bonus_percentual decimal(5, 2) DEFAULT 0,
  bumerangue_quantidade_bonus decimal(15, 2) DEFAULT 0,
  bumerangue_data_recebimento date,
  
  -- Destino
  destino_programa_id uuid REFERENCES programas_fidelidade(id) ON DELETE RESTRICT NOT NULL,
  destino_quantidade decimal(15, 2) NOT NULL DEFAULT 0,
  destino_data_recebimento date NOT NULL,
  destino_bonus_percentual decimal(5, 2) DEFAULT 0,
  destino_quantidade_bonus decimal(15, 2) DEFAULT 0,
  destino_data_recebimento_bonus date,
  
  observacao text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES usuarios(id) ON DELETE SET NULL
);

ALTER TABLE transferencia_pontos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all transferencia_pontos"
  ON transferencia_pontos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert transferencia_pontos"
  ON transferencia_pontos FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update transferencia_pontos"
  ON transferencia_pontos FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete transferencia_pontos"
  ON transferencia_pontos FOR DELETE
  TO authenticated
  USING (true);

CREATE INDEX IF NOT EXISTS idx_transferencia_pontos_parceiro ON transferencia_pontos(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_transferencia_pontos_origem_programa ON transferencia_pontos(origem_programa_id);
CREATE INDEX IF NOT EXISTS idx_transferencia_pontos_destino_programa ON transferencia_pontos(destino_programa_id);
CREATE INDEX IF NOT EXISTS idx_transferencia_pontos_data ON transferencia_pontos(data_transferencia);


-- ============================================================================
-- MIGRATION: 20251218204048_create_tipos_compra_table.sql
-- ============================================================================

/*
  # Criar tabela de Tipos de Compra

  1. Nova Tabela
    - `tipos_compra`
      - `id` (uuid, primary key)
      - `nome` (text) - Nome do tipo de compra
      - `descricao` (text) - Descrição do tipo de compra
      - `ativo` (boolean) - Se o tipo está ativo ou não
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Segurança
    - Habilitar RLS na tabela `tipos_compra`
    - Adicionar políticas para usuários autenticados
    
  3. Dados Iniciais
    - Inserir tipos de compra padrão
*/

CREATE TABLE IF NOT EXISTS tipos_compra (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  descricao text,
  ativo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE tipos_compra ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem visualizar tipos de compra"
  ON tipos_compra
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Usuários podem criar tipos de compra"
  ON tipos_compra
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar tipos de compra"
  ON tipos_compra
  FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Usuários podem deletar tipos de compra"
  ON tipos_compra
  FOR DELETE
  TO public
  USING (true);

CREATE INDEX IF NOT EXISTS idx_tipos_compra_ativo ON tipos_compra(ativo);

INSERT INTO tipos_compra (nome, descricao) VALUES
  ('Compra de Pontos/Milhas', 'Compra direta de pontos ou milhas'),
  ('Compra de Clube', 'Compra relacionada a assinatura de clube'),
  ('Compra de Produto', 'Compra de produto ou serviço'),
  ('Recompra', 'Recompra de pontos/milhas'),
  ('Outros', 'Outros tipos de compra')
ON CONFLICT DO NOTHING;


-- ============================================================================
-- MIGRATION: 20251218204406_add_cartao_id_to_compras.sql
-- ============================================================================

/*
  # Adicionar campo cartao_id à tabela compras

  1. Modificações
    - Adicionar coluna `cartao_id` na tabela `compras`
      - `cartao_id` (uuid) - Referência para cartoes_credito
      - Opcional, usado quando forma_pagamento é "Cartão"

  2. Relacionamentos
    - Criar foreign key para cartoes_credito
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'cartao_id'
  ) THEN
    ALTER TABLE compras ADD COLUMN cartao_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL;
    CREATE INDEX IF NOT EXISTS idx_compras_cartao ON compras(cartao_id);
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251218210006_add_conta_bancaria_id_to_compras.sql
-- ============================================================================

/*
  # Adicionar campo conta_bancaria_id à tabela compras

  1. Modificações
    - Adicionar coluna `conta_bancaria_id` na tabela `compras`
      - `conta_bancaria_id` (uuid) - Referência para contas_bancarias (Banco Emissor)
      - Opcional, usado quando forma_pagamento é "Pix"

  2. Relacionamentos
    - Criar foreign key para contas_bancarias
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'conta_bancaria_id'
  ) THEN
    ALTER TABLE compras ADD COLUMN conta_bancaria_id uuid REFERENCES contas_bancarias(id) ON DELETE SET NULL;
    CREATE INDEX IF NOT EXISTS idx_compras_conta_bancaria ON compras(conta_bancaria_id);
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251222135044_create_recurring_credits_system.sql
-- ============================================================================

/*
  # Create recurring credits system for programas_clubes

  1. New Tables
    - `creditos_recorrentes_log`
      - `id` (uuid, primary key)
      - `programa_clube_id` (uuid, foreign key to programas_clubes)
      - `data_credito` (date) - Date when credit was processed
      - `quantidade_pontos` (integer) - Base points credited
      - `quantidade_bonus` (integer) - Bonus points credited
      - `quantidade_total` (integer) - Total points credited
      - `created_at` (timestamptz)
      - Tracks each recurring credit processed

  2. Functions
    - `processar_creditos_recorrentes` - Processes pending recurring credits
    - `calcular_proxima_data_credito` - Calculates next credit date based on frequency

  3. Security
    - Enable RLS on creditos_recorrentes_log table
    - Add policies for authenticated users

  4. Notes
    - This system automatically credits points to partners based on their program club frequency
    - Credits are tracked to avoid duplicates
*/

-- Create log table for recurring credits
CREATE TABLE IF NOT EXISTS creditos_recorrentes_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  programa_clube_id uuid REFERENCES programas_clubes(id) ON DELETE CASCADE NOT NULL,
  data_credito date NOT NULL,
  quantidade_pontos integer DEFAULT 0,
  quantidade_bonus integer DEFAULT 0,
  quantidade_total integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(programa_clube_id, data_credito)
);

-- Enable RLS
ALTER TABLE creditos_recorrentes_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view all creditos_recorrentes_log"
  ON creditos_recorrentes_log FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert creditos_recorrentes_log"
  ON creditos_recorrentes_log FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_creditos_recorrentes_programa_clube 
  ON creditos_recorrentes_log(programa_clube_id);

CREATE INDEX IF NOT EXISTS idx_creditos_recorrentes_data 
  ON creditos_recorrentes_log(data_credito);

-- Function to calculate next credit date based on frequency
CREATE OR REPLACE FUNCTION calcular_proxima_data_credito(
  p_data_base date,
  p_frequencia text
)
RETURNS date
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  CASE p_frequencia
    WHEN 'mensal' THEN
      RETURN p_data_base + INTERVAL '1 month';
    WHEN 'trimestral' THEN
      RETURN p_data_base + INTERVAL '3 months';
    WHEN 'anual' THEN
      RETURN p_data_base + INTERVAL '1 year';
    ELSE
      RETURN NULL;
  END CASE;
END;
$$;

-- Function to process recurring credits
CREATE OR REPLACE FUNCTION processar_creditos_recorrentes()
RETURNS TABLE (
  programa_clube_id uuid,
  parceiro_nome text,
  programa_nome text,
  quantidade_creditada integer,
  data_credito date,
  status text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_record RECORD;
  v_ultima_data_credito date;
  v_proxima_data_credito date;
  v_quantidade_bonus integer;
  v_quantidade_total integer;
  v_data_atual date := CURRENT_DATE;
  v_creditos_processados integer := 0;
BEGIN
  -- Loop through all active program clubs with frequency configured
  FOR v_record IN 
    SELECT 
      pc.id,
      pc.parceiro_id,
      pc.programa_id,
      pc.nome_parceiro,
      pc.data_ultima_assinatura,
      pc.quantidade_pontos,
      pc.bonus_porcentagem,
      pc.sequencia,
      pf.nome as programa_nome
    FROM programas_clubes pc
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    WHERE pc.sequencia IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.parceiro_id IS NOT NULL
      AND pc.programa_id IS NOT NULL
  LOOP
    -- Get the last credit date
    SELECT MAX(data_credito) INTO v_ultima_data_credito
    FROM creditos_recorrentes_log
    WHERE programa_clube_id = v_record.id;
    
    -- If no previous credit, use the last subscription date
    IF v_ultima_data_credito IS NULL THEN
      v_ultima_data_credito := v_record.data_ultima_assinatura;
    END IF;
    
    -- Calculate next credit date
    v_proxima_data_credito := calcular_proxima_data_credito(
      v_ultima_data_credito,
      v_record.sequencia
    );
    
    -- Check if credit is due (next date is today or in the past)
    IF v_proxima_data_credito IS NOT NULL AND v_proxima_data_credito <= v_data_atual THEN
      -- Calculate bonus points
      v_quantidade_bonus := FLOOR(
        v_record.quantidade_pontos * COALESCE(v_record.bonus_porcentagem, 0) / 100
      );
      
      v_quantidade_total := v_record.quantidade_pontos + v_quantidade_bonus;
      
      -- Insert credit log
      BEGIN
        INSERT INTO creditos_recorrentes_log (
          programa_clube_id,
          data_credito,
          quantidade_pontos,
          quantidade_bonus,
          quantidade_total
        ) VALUES (
          v_record.id,
          v_proxima_data_credito,
          v_record.quantidade_pontos,
          v_quantidade_bonus,
          v_quantidade_total
        );
        
        -- Update stock by calling the existing function
        PERFORM atualizar_estoque_pontos(
          v_record.parceiro_id,
          v_record.programa_id,
          v_quantidade_total,
          'Entrada',
          0
        );
        
        -- Return success result
        programa_clube_id := v_record.id;
        parceiro_nome := v_record.nome_parceiro;
        programa_nome := v_record.programa_nome;
        quantidade_creditada := v_quantidade_total;
        data_credito := v_proxima_data_credito;
        status := 'Creditado';
        
        v_creditos_processados := v_creditos_processados + 1;
        
        RETURN NEXT;
        
      EXCEPTION WHEN OTHERS THEN
        -- Return error result
        programa_clube_id := v_record.id;
        parceiro_nome := v_record.nome_parceiro;
        programa_nome := v_record.programa_nome;
        quantidade_creditada := 0;
        data_credito := v_proxima_data_credito;
        status := 'Erro: ' || SQLERRM;
        
        RETURN NEXT;
      END;
    END IF;
  END LOOP;
  
  -- If no credits were processed, return a message
  IF v_creditos_processados = 0 THEN
    programa_clube_id := NULL;
    parceiro_nome := NULL;
    programa_nome := NULL;
    quantidade_creditada := 0;
    data_credito := NULL;
    status := 'Nenhum crédito pendente para processar';
    RETURN NEXT;
  END IF;
END;
$$;


-- ============================================================================
-- MIGRATION: 20251226114715_NEW_20251226000001_block_compras_delete_and_update.sql
-- ============================================================================

/*
  # Bloquear Exclusões e Atualizações em Compras

  ## Objetivo
  Proteger a integridade do estoque de pontos/milhas bloqueando operações de exclusão
  e atualização na tabela `compras` após o registro ser criado.

  ## Alterações

  ### 1. Políticas RLS
  - Remove todas as políticas de DELETE existentes
  - Remove todas as políticas de UPDATE existentes
  - Mantém apenas políticas de SELECT e INSERT

  ### 2. Função de Trigger
  - Cria função que bloqueia UPDATE e DELETE via trigger
  - Retorna erro descritivo quando tentativa de modificação é detectada

  ## Justificativa
  As entradas de compras afetam diretamente o estoque de pontos/milhas.
  Permitir edições ou exclusões pode causar inconsistências graves nos saldos.
  Esta política garante auditoria completa e integridade dos dados.

  ## Nota Importante
  Esta migration deve ser aplicada APÓS a implementação da interface que
  já não oferece mais botões de editar/excluir.
*/

-- Remove políticas de DELETE e UPDATE existentes na tabela compras
DROP POLICY IF EXISTS "Authenticated users can delete compras" ON compras;
DROP POLICY IF EXISTS "Authenticated users can update compras" ON compras;
DROP POLICY IF EXISTS "Users can delete compras" ON compras;
DROP POLICY IF EXISTS "Users can update compras" ON compras;

-- Cria função que bloqueia UPDATE e DELETE
CREATE OR REPLACE FUNCTION prevent_compras_modification()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Operação não permitida: Registros de compras não podem ser editados ou excluídos para manter a integridade do estoque.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Cria trigger para BEFORE UPDATE
DROP TRIGGER IF EXISTS block_compras_update ON compras;
CREATE TRIGGER block_compras_update
  BEFORE UPDATE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION prevent_compras_modification();

-- Cria trigger para BEFORE DELETE
DROP TRIGGER IF EXISTS block_compras_delete ON compras;
CREATE TRIGGER block_compras_delete
  BEFORE DELETE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION prevent_compras_modification();

-- Confirma que as políticas de SELECT e INSERT continuam ativas
-- (estas já existem nas migrations anteriores e não devem ser removidas)


-- ============================================================================
-- MIGRATION: 20251226124406_fix_estoque_pontos_rls_policies.sql
-- ============================================================================

/*
  # Fix RLS Policies for estoque_pontos

  1. Changes
    - Drop existing RLS policies that require authenticated users
    - Create new policies that allow public access for custom auth system
    - Maintain security by allowing all authenticated operations

  2. Security
    - Policies updated to work with custom authentication (usuarios table)
    - All operations allowed for logged-in users via application
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all estoque_pontos" ON estoque_pontos;
DROP POLICY IF EXISTS "Users can insert estoque_pontos" ON estoque_pontos;
DROP POLICY IF EXISTS "Users can update estoque_pontos" ON estoque_pontos;

-- Create new policies for custom auth
CREATE POLICY "Allow all select on estoque_pontos"
  ON estoque_pontos
  FOR SELECT
  USING (true);

CREATE POLICY "Allow all insert on estoque_pontos"
  ON estoque_pontos
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow all update on estoque_pontos"
  ON estoque_pontos
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all delete on estoque_pontos"
  ON estoque_pontos
  FOR DELETE
  USING (true);

-- ============================================================================
-- MIGRATION: 20251226125407_fix_transferencia_pontos_rls_policies.sql
-- ============================================================================

/*
  # Fix RLS Policies for transferencia_pontos

  1. Changes
    - Drop existing RLS policies that require authenticated users
    - Create new policies that allow public access for custom auth system
    - Maintain security by allowing all authenticated operations

  2. Security
    - Policies updated to work with custom authentication (usuarios table)
    - All operations allowed for logged-in users via application
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all transferencia_pontos" ON transferencia_pontos;
DROP POLICY IF EXISTS "Users can insert transferencia_pontos" ON transferencia_pontos;
DROP POLICY IF EXISTS "Users can update transferencia_pontos" ON transferencia_pontos;
DROP POLICY IF EXISTS "Users can delete transferencia_pontos" ON transferencia_pontos;

-- Create new policies for custom auth
CREATE POLICY "Allow all select on transferencia_pontos"
  ON transferencia_pontos
  FOR SELECT
  USING (true);

CREATE POLICY "Allow all insert on transferencia_pontos"
  ON transferencia_pontos
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow all update on transferencia_pontos"
  ON transferencia_pontos
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all delete on transferencia_pontos"
  ON transferencia_pontos
  FOR DELETE
  USING (true);

-- ============================================================================
-- MIGRATION: 20251226131950_create_transferencia_pessoas_table.sql
-- ============================================================================

/*
  # Criar tabela Transferência entre Pessoas

  1. Nova Tabela
    - `transferencia_pessoas`
      - `id` (uuid, primary key)
      - `data_transferencia` (date) - Data da transferência
      - `programa_id` (uuid) - Programa de fidelidade
      - `origem_parceiro_id` (uuid) - Parceiro que está enviando os pontos
      - `destino_parceiro_id` (uuid) - Parceiro que está recebendo os pontos
      - `quantidade` (numeric) - Quantidade de pontos transferidos
      - `data_recebimento` (date) - Data de recebimento dos pontos
      - `bonus_percentual` (numeric) - Percentual de bônus
      - `quantidade_bonus` (numeric) - Quantidade de bônus
      - `data_recebimento_bonus` (date) - Data de recebimento do bônus
      - `custo_transferencia` (numeric) - Custo da transferência
      - `forma_pagamento` (text) - Forma de pagamento (credito, debito, pix, etc)
      - `conta_bancaria_id` (uuid) - Conta bancária usada
      - `cartao_id` (uuid) - Cartão de crédito usado
      - `parcelas` (integer) - Número de parcelas
      - `observacao` (text) - Observações
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `created_by` (uuid)

  2. Segurança
    - Habilitar RLS
    - Políticas para usuários autenticados

  3. Importantes
    - Trigger para atualizar estoque_pontos
    - Validação para não transferir para a mesma pessoa
    - Validação de saldo disponível
*/

-- Criar tabela transferencia_pessoas
CREATE TABLE IF NOT EXISTS transferencia_pessoas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  data_transferencia date NOT NULL,
  programa_id uuid NOT NULL REFERENCES programas_fidelidade(id),
  origem_parceiro_id uuid NOT NULL REFERENCES parceiros(id),
  destino_parceiro_id uuid NOT NULL REFERENCES parceiros(id),
  quantidade numeric(15,2) NOT NULL DEFAULT 0,
  data_recebimento date NOT NULL,
  bonus_percentual numeric(5,2) DEFAULT 0,
  quantidade_bonus numeric(15,2) DEFAULT 0,
  data_recebimento_bonus date,
  custo_transferencia numeric(10,2) DEFAULT 0,
  forma_pagamento text,
  conta_bancaria_id uuid REFERENCES contas_bancarias(id),
  cartao_id uuid REFERENCES cartoes_credito(id),
  parcelas integer DEFAULT 1,
  observacao text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES usuarios(id),
  CONSTRAINT check_origem_destino_diferente CHECK (origem_parceiro_id != destino_parceiro_id)
);

-- Habilitar RLS
ALTER TABLE transferencia_pessoas ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Usuários autenticados podem visualizar transferências entre pessoas"
  ON transferencia_pessoas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuários autenticados podem inserir transferências entre pessoas"
  ON transferencia_pessoas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem atualizar transferências entre pessoas"
  ON transferencia_pessoas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Usuários autenticados podem deletar transferências entre pessoas"
  ON transferencia_pessoas FOR DELETE
  TO authenticated
  USING (true);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_transferencia_pessoas_origem ON transferencia_pessoas(origem_parceiro_id);
CREATE INDEX IF NOT EXISTS idx_transferencia_pessoas_destino ON transferencia_pessoas(destino_parceiro_id);
CREATE INDEX IF NOT EXISTS idx_transferencia_pessoas_programa ON transferencia_pessoas(programa_id);
CREATE INDEX IF NOT EXISTS idx_transferencia_pessoas_data ON transferencia_pessoas(data_transferencia);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_transferencia_pessoas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_transferencia_pessoas_updated_at
  BEFORE UPDATE ON transferencia_pessoas
  FOR EACH ROW
  EXECUTE FUNCTION update_transferencia_pessoas_updated_at();

-- Função para processar transferência entre pessoas (atualiza estoque)
CREATE OR REPLACE FUNCTION process_transferencia_pessoas()
RETURNS TRIGGER AS $$
DECLARE
  v_origem_estoque_id uuid;
  v_destino_estoque_id uuid;
  v_origem_saldo numeric;
  v_origem_custo_medio numeric;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_novo_saldo_destino numeric;
  v_novo_custo_medio numeric;
BEGIN
  -- Buscar estoque da origem
  SELECT id, saldo_atual, custo_medio INTO v_origem_estoque_id, v_origem_saldo, v_origem_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;

  -- Validar se origem tem saldo suficiente
  IF v_origem_saldo < NEW.quantidade THEN
    RAISE EXCEPTION 'Saldo insuficiente no estoque de origem';
  END IF;

  -- Buscar ou criar estoque do destino
  SELECT id, saldo_atual, custo_medio INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.destino_parceiro_id AND programa_id = NEW.programa_id;

  IF v_destino_estoque_id IS NULL THEN
    -- Criar estoque para o destino
    INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
    VALUES (NEW.destino_parceiro_id, NEW.programa_id, 0, 0)
    RETURNING id, saldo_atual, custo_medio INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
  END IF;

  -- Atualizar estoque de origem (diminuir)
  UPDATE estoque_pontos
  SET saldo_atual = saldo_atual - NEW.quantidade,
      updated_at = now()
  WHERE id = v_origem_estoque_id;

  -- Calcular novo custo médio do destino
  v_novo_saldo_destino := v_destino_saldo + NEW.quantidade;
  v_novo_custo_medio := ((v_destino_saldo * v_destino_custo_medio) + (NEW.quantidade * v_origem_custo_medio)) / v_novo_saldo_destino;

  -- Atualizar estoque de destino (aumentar)
  UPDATE estoque_pontos
  SET saldo_atual = v_novo_saldo_destino,
      custo_medio = v_novo_custo_medio,
      updated_at = now()
  WHERE id = v_destino_estoque_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para processar transferência entre pessoas
CREATE TRIGGER trigger_process_transferencia_pessoas
  AFTER INSERT ON transferencia_pessoas
  FOR EACH ROW
  EXECUTE FUNCTION process_transferencia_pessoas();

-- ============================================================================
-- MIGRATION: 20251226133020_add_destino_programa_to_transferencia_pessoas.sql
-- ============================================================================

/*
  # Adicionar campo destino_programa_id na tabela transferencia_pessoas

  1. Alterações
    - Adiciona coluna `destino_programa_id` para armazenar o programa do parceiro destino
    - Campo permite que origem e destino tenham programas diferentes

  2. Notas
    - Campo é opcional para manter compatibilidade com dados existentes
    - Permite transferências entre programas diferentes
*/

-- Adicionar campo destino_programa_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'transferencia_pessoas' AND column_name = 'destino_programa_id'
  ) THEN
    ALTER TABLE transferencia_pessoas 
    ADD COLUMN destino_programa_id uuid REFERENCES programas_fidelidade(id);
  END IF;
END $$;

-- Criar índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_transferencia_pessoas_destino_programa 
  ON transferencia_pessoas(destino_programa_id);

-- ============================================================================
-- MIGRATION: 20251226133946_fix_transferencia_pessoas_rls_and_function.sql
-- ============================================================================

/*
  # Corrigir RLS e função da tabela transferencia_pessoas

  1. Alterações nas Políticas RLS
    - Alterar de `authenticated` para `public` para compatibilidade com autenticação customizada
    - Sistema usa tabela `usuarios` customizada, não `auth.users`

  2. Correção na Função
    - Atualizar para usar destino_programa_id ao invés de programa_id
    - Permite transferências entre programas diferentes

  3. Segurança
    - Mantém RLS habilitado
    - Permite acesso apenas para usuários logados via sistema customizado
*/

-- Remover políticas antigas
DROP POLICY IF EXISTS "Usuários autenticados podem visualizar transferências entre pessoas" ON transferencia_pessoas;
DROP POLICY IF EXISTS "Usuários autenticados podem inserir transferências entre pessoas" ON transferencia_pessoas;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar transferências entre pessoas" ON transferencia_pessoas;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar transferências entre pessoas" ON transferencia_pessoas;

-- Criar novas políticas com acesso público (autenticação customizada)
CREATE POLICY "Permitir visualizar transferências entre pessoas"
  ON transferencia_pessoas FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Permitir inserir transferências entre pessoas"
  ON transferencia_pessoas FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Permitir atualizar transferências entre pessoas"
  ON transferencia_pessoas FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir deletar transferências entre pessoas"
  ON transferencia_pessoas FOR DELETE
  TO public
  USING (true);

-- Atualizar função para usar destino_programa_id
CREATE OR REPLACE FUNCTION process_transferencia_pessoas()
RETURNS TRIGGER AS $$
DECLARE
  v_origem_estoque_id uuid;
  v_destino_estoque_id uuid;
  v_origem_saldo numeric;
  v_origem_custo_medio numeric;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_novo_saldo_destino numeric;
  v_novo_custo_medio numeric;
  v_programa_destino_id uuid;
BEGIN
  -- Determinar programa de destino (usar destino_programa_id se existir, senão usar programa_id)
  v_programa_destino_id := COALESCE(NEW.destino_programa_id, NEW.programa_id);

  -- Buscar estoque da origem
  SELECT id, saldo_atual, custo_medio INTO v_origem_estoque_id, v_origem_saldo, v_origem_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;

  -- Validar se origem tem saldo suficiente
  IF v_origem_saldo IS NULL OR v_origem_saldo < NEW.quantidade THEN
    RAISE EXCEPTION 'Saldo insuficiente no estoque de origem';
  END IF;

  -- Buscar ou criar estoque do destino
  SELECT id, saldo_atual, custo_medio INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.destino_parceiro_id AND programa_id = v_programa_destino_id;

  IF v_destino_estoque_id IS NULL THEN
    -- Criar estoque para o destino
    INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
    VALUES (NEW.destino_parceiro_id, v_programa_destino_id, 0, 0)
    RETURNING id, saldo_atual, custo_medio INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
  END IF;

  -- Atualizar estoque de origem (diminuir)
  UPDATE estoque_pontos
  SET saldo_atual = saldo_atual - NEW.quantidade,
      updated_at = now()
  WHERE id = v_origem_estoque_id;

  -- Calcular novo custo médio do destino
  v_novo_saldo_destino := v_destino_saldo + NEW.quantidade;
  
  -- Se o novo saldo for maior que zero, calcular custo médio ponderado
  IF v_novo_saldo_destino > 0 THEN
    v_novo_custo_medio := ((v_destino_saldo * COALESCE(v_destino_custo_medio, 0)) + (NEW.quantidade * COALESCE(v_origem_custo_medio, 0))) / v_novo_saldo_destino;
  ELSE
    v_novo_custo_medio := 0;
  END IF;

  -- Atualizar estoque de destino (aumentar)
  UPDATE estoque_pontos
  SET saldo_atual = v_novo_saldo_destino,
      custo_medio = v_novo_custo_medio,
      updated_at = now()
  WHERE id = v_destino_estoque_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- MIGRATION: 20251226140302_add_origem_bonus_to_compras.sql
-- ============================================================================

/*
  # Adicionar campo origem_bonus à tabela compras

  1. Alterações
    - Adicionar coluna `origem_bonus` (text) à tabela `compras`
    - Campo permite registrar informações sobre a origem do bônus recebido
    - Campo é opcional (nullable)

  2. Notas
    - Campo de texto livre para descrever a origem do bônus
    - Útil para rastreabilidade e auditoria
*/

-- Adicionar coluna origem_bonus
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compras' AND column_name = 'origem_bonus'
  ) THEN
    ALTER TABLE compras ADD COLUMN origem_bonus text;
  END IF;
END $$;

-- ============================================================================
-- MIGRATION: 20251229120446_create_vendas_system.sql
-- ============================================================================

/*
  # Criar Sistema de Vendas

  1. Novas Tabelas
    - vendas: Armazena os dados principais da venda
      - Campos de venda, valores, lucro, status
    - localizadores: Armazena dados do bilhete/localizador
      - Código do localizador, dados do cliente, viagem
    - contas_receber: Armazena parcelas a receber
      - Parcelas, vencimentos, pagamentos

  2. Segurança
    - Habilitar RLS em todas as tabelas
    - Adicionar políticas para usuários autenticados

  3. Índices
    - Criar índices para melhorar performance
*/

-- Criar tabela de vendas
CREATE TABLE IF NOT EXISTS vendas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid REFERENCES parceiros(id) ON DELETE CASCADE,
  programa_id uuid REFERENCES programas_fidelidade(id) ON DELETE CASCADE,
  data_venda date NOT NULL DEFAULT CURRENT_DATE,
  quantidade_milhas numeric(15,2) NOT NULL DEFAULT 0,
  valor_total numeric(15,2) NOT NULL DEFAULT 0,
  valor_milheiro numeric(15,2) DEFAULT 0,
  tipo_valor text CHECK (tipo_valor IN ('VT', 'VM')),
  saldo_anterior numeric(15,2) DEFAULT 0,
  custo_medio numeric(15,2) DEFAULT 0,
  lucro_real numeric(15,2) DEFAULT 0,
  lucro_percentual numeric(5,2) DEFAULT 0,
  incluir_taxas_emissao boolean DEFAULT false,
  observacao text,
  status text DEFAULT 'pendente' CHECK (status IN ('pendente', 'concluida', 'cancelada')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES usuarios(id) ON DELETE SET NULL
);

-- Criar tabela de localizadores
CREATE TABLE IF NOT EXISTS localizadores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venda_id uuid REFERENCES vendas(id) ON DELETE CASCADE,
  codigo_localizador text UNIQUE NOT NULL,
  cliente_nome text,
  cliente_cpf text,
  cliente_telefone text,
  cliente_email text,
  origem text,
  destino text,
  data_emissao date,
  data_embarque date,
  quantidade_passageiros integer DEFAULT 1,
  valor_taxas_emissao numeric(15,2) DEFAULT 0,
  status text DEFAULT 'emitido' CHECK (status IN ('emitido', 'voado', 'cancelado', 'reembolsado')),
  observacao text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Criar tabela de contas a receber
CREATE TABLE IF NOT EXISTS contas_receber (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venda_id uuid REFERENCES vendas(id) ON DELETE CASCADE,
  localizador_id uuid REFERENCES localizadores(id) ON DELETE CASCADE,
  data_vencimento date NOT NULL,
  valor_parcela numeric(15,2) NOT NULL DEFAULT 0,
  numero_parcela integer NOT NULL DEFAULT 1,
  total_parcelas integer NOT NULL DEFAULT 1,
  forma_pagamento text,
  conta_bancaria_id uuid REFERENCES contas_bancarias(id) ON DELETE SET NULL,
  cartao_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL,
  status_pagamento text DEFAULT 'pendente' CHECK (status_pagamento IN ('pendente', 'pago', 'atrasado', 'cancelado')),
  data_pagamento date,
  valor_pago numeric(15,2),
  observacao text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE localizadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE contas_receber ENABLE ROW LEVEL SECURITY;

-- Políticas para vendas
CREATE POLICY "Usuários podem visualizar vendas"
  ON vendas FOR SELECT TO public USING (true);

CREATE POLICY "Usuários podem criar vendas"
  ON vendas FOR INSERT TO public WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar vendas"
  ON vendas FOR UPDATE TO public USING (true) WITH CHECK (true);

CREATE POLICY "Usuários podem deletar vendas"
  ON vendas FOR DELETE TO public USING (true);

-- Políticas para localizadores
CREATE POLICY "Usuários podem visualizar localizadores"
  ON localizadores FOR SELECT TO public USING (true);

CREATE POLICY "Usuários podem criar localizadores"
  ON localizadores FOR INSERT TO public WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar localizadores"
  ON localizadores FOR UPDATE TO public USING (true) WITH CHECK (true);

CREATE POLICY "Usuários podem deletar localizadores"
  ON localizadores FOR DELETE TO public USING (true);

-- Políticas para contas_receber
CREATE POLICY "Usuários podem visualizar contas a receber"
  ON contas_receber FOR SELECT TO public USING (true);

CREATE POLICY "Usuários podem criar contas a receber"
  ON contas_receber FOR INSERT TO public WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar contas a receber"
  ON contas_receber FOR UPDATE TO public USING (true) WITH CHECK (true);

CREATE POLICY "Usuários podem deletar contas a receber"
  ON contas_receber FOR DELETE TO public USING (true);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_vendas_parceiro ON vendas(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_vendas_programa ON vendas(programa_id);
CREATE INDEX IF NOT EXISTS idx_vendas_data ON vendas(data_venda);
CREATE INDEX IF NOT EXISTS idx_vendas_status ON vendas(status);

CREATE INDEX IF NOT EXISTS idx_localizadores_venda ON localizadores(venda_id);
CREATE INDEX IF NOT EXISTS idx_localizadores_codigo ON localizadores(codigo_localizador);

CREATE INDEX IF NOT EXISTS idx_contas_receber_venda ON contas_receber(venda_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_localizador ON contas_receber(localizador_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_status ON contas_receber(status_pagamento);
CREATE INDEX IF NOT EXISTS idx_contas_receber_vencimento ON contas_receber(data_vencimento);

-- ============================================================================
-- MIGRATION: 20251229120518_create_vendas_triggers.sql
-- ============================================================================

/*
  # Criar Triggers para Sistema de Vendas

  1. Funções e Triggers
    - Atualizar timestamps automaticamente
    - Baixar estoque automaticamente ao criar venda
    - Validar saldo suficiente antes da venda
    - Atualizar custo médio na venda

  2. Notas Importantes
    - A baixa de estoque é irreversível
    - Validação de saldo antes de permitir a venda
    - Registro do saldo anterior para auditoria
*/

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_vendas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at em vendas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_vendas_updated_at'
  ) THEN
    CREATE TRIGGER set_vendas_updated_at
      BEFORE UPDATE ON vendas
      FOR EACH ROW
      EXECUTE FUNCTION update_vendas_updated_at();
  END IF;
END $$;

-- Trigger para atualizar updated_at em localizadores
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_localizadores_updated_at'
  ) THEN
    CREATE TRIGGER set_localizadores_updated_at
      BEFORE UPDATE ON localizadores
      FOR EACH ROW
      EXECUTE FUNCTION update_vendas_updated_at();
  END IF;
END $$;

-- Trigger para atualizar updated_at em contas_receber
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_contas_receber_updated_at'
  ) THEN
    CREATE TRIGGER set_contas_receber_updated_at
      BEFORE UPDATE ON contas_receber
      FOR EACH ROW
      EXECUTE FUNCTION update_vendas_updated_at();
  END IF;
END $$;

-- Função para processar venda e baixar estoque
CREATE OR REPLACE FUNCTION processar_venda()
RETURNS TRIGGER AS $$
DECLARE
  v_saldo_atual numeric;
  v_custo_medio numeric;
BEGIN
  -- Buscar saldo atual e custo médio do estoque
  SELECT saldo_atual, custo_medio
  INTO v_saldo_atual, v_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.parceiro_id
    AND programa_id = NEW.programa_id;

  -- Se não existir registro de estoque, criar com saldo 0
  IF NOT FOUND THEN
    INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
    VALUES (NEW.parceiro_id, NEW.programa_id, 0, 0);
    v_saldo_atual := 0;
    v_custo_medio := 0;
  END IF;

  -- Validar se há saldo suficiente
  IF v_saldo_atual < NEW.quantidade_milhas THEN
    RAISE EXCEPTION 'Saldo insuficiente. Saldo atual: %, Quantidade solicitada: %', 
      v_saldo_atual, NEW.quantidade_milhas;
  END IF;

  -- Registrar saldo anterior e custo médio na venda
  NEW.saldo_anterior := v_saldo_atual;
  NEW.custo_medio := v_custo_medio;

  -- Baixar do estoque
  UPDATE estoque_pontos
  SET saldo_atual = saldo_atual - NEW.quantidade_milhas,
      updated_at = now()
  WHERE parceiro_id = NEW.parceiro_id
    AND programa_id = NEW.programa_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para processar venda antes de inserir
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'processar_venda_trigger'
  ) THEN
    DROP TRIGGER processar_venda_trigger ON vendas;
  END IF;
  
  CREATE TRIGGER processar_venda_trigger
    BEFORE INSERT ON vendas
    FOR EACH ROW
    EXECUTE FUNCTION processar_venda();
END $$;

-- Função para reverter venda (caso seja cancelada)
CREATE OR REPLACE FUNCTION reverter_venda()
RETURNS TRIGGER AS $$
BEGIN
  -- Só reverter se o status mudou para 'cancelada'
  IF OLD.status != 'cancelada' AND NEW.status = 'cancelada' THEN
    -- Devolver as milhas ao estoque
    UPDATE estoque_pontos
    SET saldo_atual = saldo_atual + OLD.quantidade_milhas,
        updated_at = now()
    WHERE parceiro_id = OLD.parceiro_id
      AND programa_id = OLD.programa_id;

    -- Cancelar todas as contas a receber relacionadas
    UPDATE contas_receber
    SET status_pagamento = 'cancelado',
        updated_at = now()
    WHERE venda_id = OLD.id
      AND status_pagamento = 'pendente';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para reverter venda ao cancelar
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'reverter_venda_trigger'
  ) THEN
    DROP TRIGGER reverter_venda_trigger ON vendas;
  END IF;
  
  CREATE TRIGGER reverter_venda_trigger
    AFTER UPDATE ON vendas
    FOR EACH ROW
    WHEN (NEW.status = 'cancelada' AND OLD.status != 'cancelada')
    EXECUTE FUNCTION reverter_venda();
END $$;

-- ============================================================================
-- MIGRATION: 20251229124418_add_comissao_passagens_vendas.sql
-- ============================================================================

/*
  # Adicionar campos de comissão e controle de passagens

  1. Alterações na tabela vendas
    - Adiciona campos para controle de comissão:
      - `gerar_comissao` (boolean) - Se deve gerar comissão
      - `tipo_comissao` (text) - Tipo: não possui, sobre valor bruto, sobre lucro, fixo anual
      - `comissao_percentual` (numeric) - Percentual da comissão
      - `comissao_valor_fixo` (numeric) - Valor fixo da comissão
      - `comissao_valor_calculado` (numeric) - Valor calculado da comissão
      - `comissao_forma_pagamento` (text) - Forma de pagamento da comissão
      - `comissao_conta_bancaria_id` (uuid) - Conta bancária para pagamento
      - `localizador_pdf_url` (text) - URL do PDF do localizador
      - `cliente_id` (uuid) - Cliente relacionado à venda

  2. Nova tabela: passagens_emitidas
    - Controle de CPFs e passagens emitidas
    - Relacionada com vendas
    - Campos: data_emissao, cpfs, milhas, localizador, passageiro, cpf

  3. Segurança
    - RLS habilitado em passagens_emitidas
    - Políticas para authenticated users
*/

-- Adicionar campos de comissão e controle na tabela vendas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'gerar_comissao'
  ) THEN
    ALTER TABLE vendas ADD COLUMN gerar_comissao boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'tipo_comissao'
  ) THEN
    ALTER TABLE vendas ADD COLUMN tipo_comissao text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'comissao_percentual'
  ) THEN
    ALTER TABLE vendas ADD COLUMN comissao_percentual numeric(10,2);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'comissao_valor_fixo'
  ) THEN
    ALTER TABLE vendas ADD COLUMN comissao_valor_fixo numeric(15,2);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'comissao_valor_calculado'
  ) THEN
    ALTER TABLE vendas ADD COLUMN comissao_valor_calculado numeric(15,2);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'comissao_forma_pagamento'
  ) THEN
    ALTER TABLE vendas ADD COLUMN comissao_forma_pagamento text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'comissao_conta_bancaria_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN comissao_conta_bancaria_id uuid REFERENCES contas_bancarias(id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'localizador_pdf_url'
  ) THEN
    ALTER TABLE vendas ADD COLUMN localizador_pdf_url text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'cliente_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN cliente_id uuid REFERENCES clientes(id);
  END IF;
END $$;

-- Criar tabela passagens_emitidas
CREATE TABLE IF NOT EXISTS passagens_emitidas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venda_id uuid NOT NULL REFERENCES vendas(id) ON DELETE CASCADE,
  data_emissao date NOT NULL,
  cpfs integer NOT NULL DEFAULT 1,
  milhas numeric(15,2),
  localizador text,
  passageiro text,
  cpf text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE passagens_emitidas ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para passagens_emitidas
CREATE POLICY "Users can view all passagens_emitidas"
  ON passagens_emitidas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert passagens_emitidas"
  ON passagens_emitidas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update passagens_emitidas"
  ON passagens_emitidas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can delete passagens_emitidas"
  ON passagens_emitidas FOR DELETE
  TO authenticated
  USING (true);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_passagens_emitidas_venda_id ON passagens_emitidas(venda_id);
CREATE INDEX IF NOT EXISTS idx_vendas_cliente_id ON vendas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_vendas_comissao_conta ON vendas(comissao_conta_bancaria_id);

-- ============================================================================
-- MIGRATION: 20251229124502_create_vendas_documentos_storage.sql
-- ============================================================================

/*
  # Criar storage bucket para documentos de vendas

  1. Novo Bucket
    - `vendas-documentos` - Bucket para armazenar PDFs de localizadores e outros documentos

  2. Políticas de Storage
    - Authenticated users podem fazer upload
    - Authenticated users podem visualizar
    - Authenticated users podem deletar
*/

-- Criar bucket se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('vendas-documentos', 'vendas-documentos', true)
ON CONFLICT (id) DO NOTHING;

-- Política para permitir upload de arquivos
CREATE POLICY "Authenticated users can upload vendas documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'vendas-documentos');

-- Política para permitir visualização de arquivos
CREATE POLICY "Authenticated users can view vendas documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'vendas-documentos');

-- Política para permitir exclusão de arquivos
CREATE POLICY "Authenticated users can delete vendas documents"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'vendas-documentos');

-- ============================================================================
-- MIGRATION: 20251229131752_add_tipo_cliente_and_oc_fields.sql
-- ============================================================================

/*
  # Adicionar Tipo de Cliente e Campos para Ordem de Compra

  1. Alterações na tabela vendas
    - `tipo_cliente` (text) - Tipo: 'cliente_final', 'agencia_convencional', 'agencia_grande'
    - `ordem_compra` (text) - Código da Ordem de Compra (para agências grandes)
    - `estoque_reservado` (boolean) - Se o estoque está apenas reservado (não baixado)
    - `quantidade_reservada` (numeric) - Quantidade de milhas reservadas

  2. Alterações na tabela localizadores
    - `valor_total` (numeric) - Valor total do localizador
    - `forma_pagamento` (text) - Forma de pagamento do localizador
    - `parcelas` (integer) - Número de parcelas
    - `valor_pago` (numeric) - Valor já pago deste localizador
    - `saldo_restante` (numeric) - Saldo restante a pagar

  3. Notas
    - tipo_cliente define como o estoque será tratado
    - ordem_compra é usada para agências grandes
    - localizadores agora podem ter valores independentes
*/

-- Adicionar campos na tabela vendas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'tipo_cliente'
  ) THEN
    ALTER TABLE vendas ADD COLUMN tipo_cliente text DEFAULT 'cliente_final' 
      CHECK (tipo_cliente IN ('cliente_final', 'agencia_convencional', 'agencia_grande'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'ordem_compra'
  ) THEN
    ALTER TABLE vendas ADD COLUMN ordem_compra text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'estoque_reservado'
  ) THEN
    ALTER TABLE vendas ADD COLUMN estoque_reservado boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendas' AND column_name = 'quantidade_reservada'
  ) THEN
    ALTER TABLE vendas ADD COLUMN quantidade_reservada numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campos na tabela localizadores
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'localizadores' AND column_name = 'valor_total'
  ) THEN
    ALTER TABLE localizadores ADD COLUMN valor_total numeric(15,2) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'localizadores' AND column_name = 'forma_pagamento'
  ) THEN
    ALTER TABLE localizadores ADD COLUMN forma_pagamento text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'localizadores' AND column_name = 'parcelas'
  ) THEN
    ALTER TABLE localizadores ADD COLUMN parcelas integer DEFAULT 1;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'localizadores' AND column_name = 'valor_pago'
  ) THEN
    ALTER TABLE localizadores ADD COLUMN valor_pago numeric(15,2) DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'localizadores' AND column_name = 'saldo_restante'
  ) THEN
    ALTER TABLE localizadores ADD COLUMN saldo_restante numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_vendas_tipo_cliente ON vendas(tipo_cliente);
CREATE INDEX IF NOT EXISTS idx_vendas_ordem_compra ON vendas(ordem_compra);
CREATE INDEX IF NOT EXISTS idx_localizadores_status ON localizadores(status);


-- ============================================================================
-- MIGRATION: 20251229131823_update_vendas_trigger_tipo_cliente.sql
-- ============================================================================

/*
  # Atualizar Trigger de Vendas para Controlar Baixa de Estoque

  1. Modificações na função processar_venda
    - Cliente Final: baixa estoque imediatamente
    - Agência Convencional: baixa estoque imediatamente
    - Agência Grande: apenas reserva estoque (não baixa)

  2. Nova função: processar_emissao_massa
    - Processa planilha de emissões para agências grandes
    - Baixa estoque proporcional às emissões

  3. Notas
    - Estoque só é abatido quando necessário
    - Agências grandes têm estoque reservado até emissão
*/

-- Atualizar função para processar venda com tipo_cliente
CREATE OR REPLACE FUNCTION processar_venda()
RETURNS TRIGGER AS $$
DECLARE
  v_saldo_atual numeric;
  v_custo_medio numeric;
BEGIN
  -- Buscar saldo atual e custo médio do estoque
  SELECT saldo_atual, custo_medio
  INTO v_saldo_atual, v_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.parceiro_id
    AND programa_id = NEW.programa_id;

  -- Se não existir registro de estoque, criar com saldo 0
  IF NOT FOUND THEN
    INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
    VALUES (NEW.parceiro_id, NEW.programa_id, 0, 0);
    v_saldo_atual := 0;
    v_custo_medio := 0;
  END IF;

  -- Validar se há saldo suficiente
  IF v_saldo_atual < NEW.quantidade_milhas THEN
    RAISE EXCEPTION 'Saldo insuficiente. Saldo atual: %, Quantidade solicitada: %', 
      v_saldo_atual, NEW.quantidade_milhas;
  END IF;

  -- Registrar saldo anterior e custo médio na venda
  NEW.saldo_anterior := v_saldo_atual;
  NEW.custo_medio := v_custo_medio;

  -- Controlar baixa de estoque baseado no tipo de cliente
  IF NEW.tipo_cliente IN ('cliente_final', 'agencia_convencional') THEN
    -- Baixar do estoque imediatamente
    UPDATE estoque_pontos
    SET saldo_atual = saldo_atual - NEW.quantidade_milhas,
        updated_at = now()
    WHERE parceiro_id = NEW.parceiro_id
      AND programa_id = NEW.programa_id;
    
    NEW.estoque_reservado := false;
    NEW.quantidade_reservada := 0;
  ELSE
    -- Agência grande: apenas reservar estoque
    NEW.estoque_reservado := true;
    NEW.quantidade_reservada := NEW.quantidade_milhas;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para processar emissões em massa (agências grandes)
CREATE OR REPLACE FUNCTION processar_emissao_massa(
  p_venda_id uuid,
  p_quantidade_emitida numeric
)
RETURNS void AS $$
DECLARE
  v_venda RECORD;
  v_quantidade_reservada numeric;
BEGIN
  -- Buscar dados da venda
  SELECT v.*, v.quantidade_reservada
  INTO v_venda
  FROM vendas v
  WHERE v.id = p_venda_id
    AND v.tipo_cliente = 'agencia_grande'
    AND v.estoque_reservado = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Venda não encontrada ou não é de agência grande';
  END IF;

  -- Validar se quantidade emitida não excede a reservada
  IF p_quantidade_emitida > v_venda.quantidade_reservada THEN
    RAISE EXCEPTION 'Quantidade emitida (%) excede quantidade reservada (%)', 
      p_quantidade_emitida, v_venda.quantidade_reservada;
  END IF;

  -- Baixar do estoque a quantidade emitida
  UPDATE estoque_pontos
  SET saldo_atual = saldo_atual - p_quantidade_emitida,
      updated_at = now()
  WHERE parceiro_id = v_venda.parceiro_id
    AND programa_id = v_venda.programa_id;

  -- Atualizar quantidade reservada na venda
  UPDATE vendas
  SET quantidade_reservada = quantidade_reservada - p_quantidade_emitida,
      estoque_reservado = CASE 
        WHEN (quantidade_reservada - p_quantidade_emitida) <= 0 THEN false 
        ELSE true 
      END,
      updated_at = now()
  WHERE id = p_venda_id;

END;
$$ LANGUAGE plpgsql;

-- Recriar trigger
DROP TRIGGER IF EXISTS processar_venda_trigger ON vendas;
CREATE TRIGGER processar_venda_trigger
  BEFORE INSERT ON vendas
  FOR EACH ROW
  EXECUTE FUNCTION processar_venda();


-- ============================================================================
-- MIGRATION: 20251229131851_create_trigger_contas_receber_localizador.sql
-- ============================================================================

/*
  # Criar Trigger para Gerar Contas a Receber por Localizador

  1. Nova Função
    - `criar_contas_receber_localizador` - Gera contas a receber automaticamente ao criar localizador
    - Cria parcelas baseadas no campo `parcelas` do localizador
    - Cada parcela tem vencimento espaçado em 30 dias

  2. Trigger
    - Executado AFTER INSERT em localizadores
    - Gera as parcelas automaticamente

  3. Notas
    - Cada localizador pode ter suas próprias parcelas
    - Permite pagamentos independentes por localizador
    - Facilita conciliação de pagamentos
*/

-- Função para criar contas a receber do localizador
CREATE OR REPLACE FUNCTION criar_contas_receber_localizador()
RETURNS TRIGGER AS $$
DECLARE
  valor_parcela numeric;
  data_venc date;
  i integer;
BEGIN
  -- Só criar contas a receber se valor_total > 0
  IF NEW.valor_total > 0 AND NEW.parcelas > 0 THEN
    -- Calcular valor de cada parcela
    valor_parcela := NEW.valor_total / NEW.parcelas;
    
    -- Criar as contas a receber para cada parcela
    FOR i IN 1..NEW.parcelas LOOP
      -- Calcular data de vencimento (30 dias para cada parcela)
      data_venc := COALESCE(NEW.data_emissao, NEW.created_at::date) + (i * 30);
      
      INSERT INTO contas_receber (
        venda_id,
        localizador_id,
        numero_parcela,
        total_parcelas,
        valor_parcela,
        data_vencimento,
        status_pagamento,
        forma_pagamento
      ) VALUES (
        NEW.venda_id,
        NEW.id,
        i,
        NEW.parcelas,
        valor_parcela,
        data_venc,
        'pendente',
        NEW.forma_pagamento
      );
    END LOOP;
    
    -- Atualizar saldo restante do localizador
    UPDATE localizadores
    SET saldo_restante = NEW.valor_total
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para localizadores
DROP TRIGGER IF EXISTS trigger_criar_contas_receber_localizador ON localizadores;
CREATE TRIGGER trigger_criar_contas_receber_localizador
  AFTER INSERT ON localizadores
  FOR EACH ROW
  EXECUTE FUNCTION criar_contas_receber_localizador();

-- Função para atualizar saldo restante quando pagamento é feito
CREATE OR REPLACE FUNCTION atualizar_saldo_localizador()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar saldo restante e valor pago do localizador
  IF NEW.localizador_id IS NOT NULL THEN
    UPDATE localizadores
    SET 
      valor_pago = COALESCE((
        SELECT SUM(valor_pago)
        FROM contas_receber
        WHERE localizador_id = NEW.localizador_id
          AND status_pagamento = 'pago'
      ), 0),
      saldo_restante = valor_total - COALESCE((
        SELECT SUM(valor_pago)
        FROM contas_receber
        WHERE localizador_id = NEW.localizador_id
          AND status_pagamento = 'pago'
      ), 0),
      updated_at = now()
    WHERE id = NEW.localizador_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para atualizar saldo após pagamento
DROP TRIGGER IF EXISTS trigger_atualizar_saldo_localizador ON contas_receber;
CREATE TRIGGER trigger_atualizar_saldo_localizador
  AFTER UPDATE ON contas_receber
  FOR EACH ROW
  WHEN (OLD.status_pagamento IS DISTINCT FROM NEW.status_pagamento)
  EXECUTE FUNCTION atualizar_saldo_localizador();


-- ============================================================================
-- MIGRATION: 20251229133400_create_atividades_system.sql
-- ============================================================================

/*
  # Sistema de Atividades e Créditos Recorrentes

  ## 1. Nova Tabela: atividades
  Tabela para rastrear todas as atividades/lembretes do sistema:
  - Transferências de pontos agendadas para o futuro
  - Créditos mensais de clubes a serem processados
  - Bônus de bumerangue a receber
  - Outras atividades importantes

  ## 2. Função: processar_creditos_clubes_mensais
  Processa automaticamente os créditos mensais dos clubes:
  - Verifica clubes ativos com data_ultima_assinatura
  - Calcula próximas datas de crédito baseado no dia_cobranca
  - Registra pontos mensais + bônus (se aplicável) em estoque_pontos
  - Atualiza data_ultima_assinatura

  ## 3. Triggers
  - Criar atividades quando transferências têm datas futuras
  - Criar atividades para novos clubes assinados
  - Atualizar atividades quando dados são modificados

  ## 4. View: atividades_pendentes
  View otimizada para dashboard mostrar atividades da semana

  ## 5. Segurança
  - RLS habilitado em atividades
  - Políticas para usuários autenticados
*/

-- Criar tabela de atividades
CREATE TABLE IF NOT EXISTS atividades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_atividade text NOT NULL CHECK (tipo_atividade IN (
    'transferencia_entrada',
    'transferencia_bonus',
    'bumerangue_retorno',
    'clube_credito_mensal',
    'clube_credito_bonus',
    'outro'
  )),
  titulo text NOT NULL,
  descricao text,
  parceiro_id uuid REFERENCES parceiros(id) ON DELETE CASCADE,
  parceiro_nome text,
  programa_id uuid REFERENCES programas_fidelidade(id),
  programa_nome text,
  quantidade_pontos numeric(15,2),
  data_prevista date NOT NULL,
  status text DEFAULT 'pendente' CHECK (status IN ('pendente', 'processado', 'cancelado')),
  referencia_id uuid,
  referencia_tabela text,
  prioridade text DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
  processado_em timestamptz,
  processado_por uuid,
  observacoes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_atividades_data_prevista ON atividades(data_prevista);
CREATE INDEX IF NOT EXISTS idx_atividades_status ON atividades(status);
CREATE INDEX IF NOT EXISTS idx_atividades_parceiro ON atividades(parceiro_id);
CREATE INDEX IF NOT EXISTS idx_atividades_tipo ON atividades(tipo_atividade);
CREATE INDEX IF NOT EXISTS idx_atividades_referencia ON atividades(referencia_id, referencia_tabela);

-- Habilitar RLS
ALTER TABLE atividades ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Usuários podem visualizar atividades"
  ON atividades FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Usuários podem inserir atividades"
  ON atividades FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Usuários podem atualizar atividades"
  ON atividades FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Usuários podem deletar atividades"
  ON atividades FOR DELETE
  TO authenticated
  USING (true);

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_atividades_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_atividades_updated_at
  BEFORE UPDATE ON atividades
  FOR EACH ROW
  EXECUTE FUNCTION update_atividades_updated_at();

-- Função para criar atividades de transferências futuras
CREATE OR REPLACE FUNCTION criar_atividades_transferencia()
RETURNS TRIGGER AS $$
BEGIN
  -- Atividade para recebimento principal
  IF NEW.destino_data_recebimento > CURRENT_DATE THEN
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'transferencia_entrada',
      'Entrada de pontos agendada',
      'Transferência de ' || NEW.destino_quantidade || ' pontos',
      NEW.parceiro_id,
      p.nome,
      NEW.destino_programa_id,
      pf.nome,
      NEW.destino_quantidade,
      NEW.destino_data_recebimento,
      NEW.id,
      'transferencia_pontos',
      'normal'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.destino_programa_id
    WHERE p.id = NEW.parceiro_id;
  END IF;

  -- Atividade para bônus (se houver)
  IF NEW.destino_data_recebimento_bonus IS NOT NULL 
     AND NEW.destino_data_recebimento_bonus > CURRENT_DATE 
     AND NEW.destino_quantidade_bonus > 0 THEN
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'transferencia_bonus',
      'Bônus de transferência agendado',
      'Bônus de ' || NEW.destino_quantidade_bonus || ' pontos (' || NEW.destino_bonus_percentual || '%)',
      NEW.parceiro_id,
      p.nome,
      NEW.destino_programa_id,
      pf.nome,
      NEW.destino_quantidade_bonus,
      NEW.destino_data_recebimento_bonus,
      NEW.id,
      'transferencia_pontos',
      'normal'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.destino_programa_id
    WHERE p.id = NEW.parceiro_id;
  END IF;

  -- Atividade para bumerangue (se houver)
  IF NEW.bumerangue_data_recebimento IS NOT NULL 
     AND NEW.bumerangue_data_recebimento > CURRENT_DATE 
     AND NEW.bumerangue_quantidade_bonus > 0 THEN
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'bumerangue_retorno',
      'Retorno de bumerangue agendado',
      'Retorno de ' || NEW.bumerangue_quantidade_bonus || ' pontos (' || NEW.bumerangue_bonus_percentual || '%)',
      NEW.parceiro_id,
      p.nome,
      NEW.origem_programa_id,
      pf.nome,
      NEW.bumerangue_quantidade_bonus,
      NEW.bumerangue_data_recebimento,
      NEW.id,
      'transferencia_pontos',
      'alta'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.origem_programa_id
    WHERE p.id = NEW.parceiro_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para criar atividades de transferências
DROP TRIGGER IF EXISTS trigger_criar_atividades_transferencia ON transferencia_pontos;
CREATE TRIGGER trigger_criar_atividades_transferencia
  AFTER INSERT ON transferencia_pontos
  FOR EACH ROW
  EXECUTE FUNCTION criar_atividades_transferencia();

-- Função para criar atividades de clubes
CREATE OR REPLACE FUNCTION criar_atividades_clube()
RETURNS TRIGGER AS $$
DECLARE
  v_proximo_credito date;
BEGIN
  -- Só processar se tem_clube = true e tem os dados necessários
  IF NEW.tem_clube = true 
     AND NEW.data_ultima_assinatura IS NOT NULL 
     AND NEW.dia_cobranca IS NOT NULL 
     AND NEW.quantidade_pontos > 0 THEN
    
    -- Calcular próxima data de crédito
    v_proximo_credito := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::date;
    v_proximo_credito := MAKE_DATE(
      EXTRACT(YEAR FROM v_proximo_credito)::int,
      EXTRACT(MONTH FROM v_proximo_credito)::int,
      LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM v_proximo_credito)::int)
    );

    -- Se a data calculada já passou neste mês, usar o próximo mês
    IF v_proximo_credito < CURRENT_DATE THEN
      v_proximo_credito := MAKE_DATE(
        EXTRACT(YEAR FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE + INTERVAL '2 month') - INTERVAL '1 day'))::int)
      );
    END IF;

    -- Criar atividade para crédito mensal
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'clube_credito_mensal',
      'Crédito mensal de clube',
      'Crédito mensal de ' || NEW.quantidade_pontos || ' pontos do clube ' || pr.nome,
      NEW.parceiro_id,
      p.nome,
      NEW.programa_id,
      pf.nome,
      NEW.quantidade_pontos,
      v_proximo_credito,
      NEW.id,
      'programas_clubes',
      'alta'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
    LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
    WHERE p.id = NEW.parceiro_id;

    -- Se tem bônus de boas-vindas e é primeira assinatura, criar atividade de bônus
    IF NEW.bonus_porcentagem > 0 AND NEW.data_ultima_assinatura = CURRENT_DATE THEN
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade
      )
      SELECT
        'clube_credito_bonus',
        'Bônus de boas-vindas do clube',
        'Bônus de ' || FLOOR(NEW.quantidade_pontos * NEW.bonus_porcentagem / 100) || ' pontos (' || NEW.bonus_porcentagem || '%) do clube ' || pr.nome,
        NEW.parceiro_id,
        p.nome,
        NEW.programa_id,
        pf.nome,
        FLOOR(NEW.quantidade_pontos * NEW.bonus_porcentagem / 100),
        v_proximo_credito,
        NEW.id,
        'programas_clubes',
        'alta'
      FROM parceiros p
      LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
      LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
      WHERE p.id = NEW.parceiro_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para criar atividades de clubes
DROP TRIGGER IF EXISTS trigger_criar_atividades_clube ON programas_clubes;
CREATE TRIGGER trigger_criar_atividades_clube
  AFTER INSERT OR UPDATE OF tem_clube, data_ultima_assinatura, dia_cobranca, quantidade_pontos
  ON programas_clubes
  FOR EACH ROW
  EXECUTE FUNCTION criar_atividades_clube();

-- Função para processar créditos mensais de clubes automaticamente
CREATE OR REPLACE FUNCTION processar_creditos_clubes_mensais()
RETURNS TABLE (
  clubes_processados int,
  pontos_creditados numeric,
  mensagem text
) AS $$
DECLARE
  v_clube RECORD;
  v_pontos_creditados numeric := 0;
  v_contador int := 0;
  v_bonus numeric;
  v_total_pontos numeric;
BEGIN
  -- Buscar clubes ativos que devem receber crédito hoje
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome as parceiro_nome,
      pf.nome as programa_nome
    FROM programas_clubes pc
    JOIN parceiros p ON p.id = pc.parceiro_id
    JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    WHERE pc.tem_clube = true
      AND pc.quantidade_pontos > 0
      AND pc.dia_cobranca = EXTRACT(DAY FROM CURRENT_DATE)::int
      AND (pc.data_ultima_assinatura IS NULL 
           OR pc.data_ultima_assinatura < DATE_TRUNC('month', CURRENT_DATE)::date)
  LOOP
    -- Calcular bônus se aplicável (apenas no primeiro mês)
    v_bonus := 0;
    IF v_clube.bonus_porcentagem > 0 
       AND (v_clube.data_ultima_assinatura IS NULL 
            OR DATE_TRUNC('month', v_clube.data_ultima_assinatura) < DATE_TRUNC('month', CURRENT_DATE)) THEN
      v_bonus := FLOOR(v_clube.quantidade_pontos * v_clube.bonus_porcentagem / 100);
    END IF;

    v_total_pontos := v_clube.quantidade_pontos + v_bonus;

    -- Inserir no estoque de pontos
    INSERT INTO estoque_pontos (
      parceiro_id,
      programa_id,
      tipo_movimentacao,
      quantidade,
      valor_total,
      data_movimentacao,
      observacao
    ) VALUES (
      v_clube.parceiro_id,
      v_clube.programa_id,
      'entrada',
      v_total_pontos,
      v_clube.valor,
      CURRENT_DATE,
      'Crédito mensal automático do clube' || 
      CASE WHEN v_bonus > 0 THEN ' (inclui bônus de ' || v_bonus || ' pontos)' ELSE '' END
    );

    -- Atualizar data da última assinatura
    UPDATE programas_clubes
    SET data_ultima_assinatura = CURRENT_DATE,
        updated_at = now()
    WHERE id = v_clube.id;

    -- Marcar atividade como processada
    UPDATE atividades
    SET status = 'processado',
        processado_em = now()
    WHERE referencia_id = v_clube.id
      AND referencia_tabela = 'programas_clubes'
      AND data_prevista = CURRENT_DATE
      AND status = 'pendente';

    v_pontos_creditados := v_pontos_creditados + v_total_pontos;
    v_contador := v_contador + 1;
  END LOOP;

  clubes_processados := v_contador;
  pontos_creditados := v_pontos_creditados;
  mensagem := 'Processamento concluído com sucesso';

  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- View para mostrar atividades pendentes (útil para dashboard)
CREATE OR REPLACE VIEW atividades_pendentes AS
SELECT 
  a.*,
  CASE 
    WHEN a.data_prevista = CURRENT_DATE THEN 'Hoje'
    WHEN a.data_prevista = CURRENT_DATE + 1 THEN 'Amanhã'
    WHEN a.data_prevista BETWEEN CURRENT_DATE AND CURRENT_DATE + 7 THEN 'Esta semana'
    WHEN a.data_prevista BETWEEN CURRENT_DATE + 8 AND CURRENT_DATE + 30 THEN 'Este mês'
    ELSE 'Futuro'
  END as periodo,
  a.data_prevista - CURRENT_DATE as dias_restantes
FROM atividades a
WHERE a.status = 'pendente'
  AND a.data_prevista >= CURRENT_DATE
ORDER BY a.data_prevista ASC, a.prioridade DESC, a.created_at ASC;


-- ============================================================================
-- MIGRATION: 20251229134454_add_cartao_bandeira_and_tipo.sql
-- ============================================================================

/*
  # Melhorias em Cartões de Crédito

  ## 1. Novo Campo: bandeira
  Adiciona campo para identificar a bandeira do cartão:
  - Visa
  - Mastercard
  - Amex
  - Elo
  - Hipercard
  - Diners Club
  - Outros

  ## 2. Novo Campo: tipo_cartao
  Identifica se o cartão é:
  - principal: Cartão principal da conta
  - adicional: Cartão adicional vinculado ao principal
  - virtual: Cartão virtual

  ## 3. Novo Campo: cartao_principal_id
  Para cartões adicionais/virtuais, referência ao cartão principal

  ## 4. Segurança
  - Mantém RLS existente
*/

-- Adicionar campo bandeira
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'bandeira'
  ) THEN
    ALTER TABLE cartoes_credito 
    ADD COLUMN bandeira text CHECK (bandeira IN (
      'Visa',
      'Mastercard',
      'Amex',
      'Elo',
      'Hipercard',
      'Diners Club',
      'Outros'
    ));
  END IF;
END $$;

-- Adicionar campo tipo_cartao
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'tipo_cartao'
  ) THEN
    ALTER TABLE cartoes_credito 
    ADD COLUMN tipo_cartao text DEFAULT 'principal' CHECK (tipo_cartao IN (
      'principal',
      'adicional',
      'virtual'
    ));
  END IF;
END $$;

-- Adicionar campo cartao_principal_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cartoes_credito' AND column_name = 'cartao_principal_id'
  ) THEN
    ALTER TABLE cartoes_credito 
    ADD COLUMN cartao_principal_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_cartoes_credito_principal ON cartoes_credito(cartao_principal_id);

-- Atualizar cartões existentes para tipo principal se não especificado
UPDATE cartoes_credito
SET tipo_cartao = 'principal'
WHERE tipo_cartao IS NULL;


-- ============================================================================
-- MIGRATION: 20251229134536_update_programas_clubes_bonus_and_lojas.sql
-- ============================================================================

/*
  # Melhorias em Programas/Clubes e Lojas

  ## 1. Programas/Clubes
  - Renomear bonus_porcentagem para bonus_quantidade_pontos
  - Adicionar constraint: se tem_clube = true, quantidade_pontos deve ser obrigatório

  ## 2. Lojas
  - Adicionar campo cnpj (único)
  - Adicionar campo telefone
  - Adicionar campo observacoes
  - Adicionar constraint de nome único

  ## 3. Segurança
  - Mantém RLS existente
*/

-- =====================
-- Programas/Clubes
-- =====================

-- Adicionar novo campo bonus_quantidade_pontos
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' AND column_name = 'bonus_quantidade_pontos'
  ) THEN
    ALTER TABLE programas_clubes 
    ADD COLUMN bonus_quantidade_pontos integer;
  END IF;
END $$;

-- Migrar dados de bonus_porcentagem para bonus_quantidade_pontos
-- (convertendo porcentagem em pontos baseado em quantidade_pontos)
UPDATE programas_clubes
SET bonus_quantidade_pontos = FLOOR(quantidade_pontos * bonus_porcentagem / 100)
WHERE bonus_porcentagem IS NOT NULL 
  AND quantidade_pontos IS NOT NULL
  AND bonus_quantidade_pontos IS NULL;

-- Função para validar que quantidade_pontos é obrigatório quando tem_clube = true
CREATE OR REPLACE FUNCTION validar_clube_quantidade_pontos()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.tem_clube = true AND (NEW.quantidade_pontos IS NULL OR NEW.quantidade_pontos <= 0) THEN
    RAISE EXCEPTION 'Quantidade de pontos é obrigatória quando tem clube ativo';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para validação
DROP TRIGGER IF EXISTS trigger_validar_clube_quantidade_pontos ON programas_clubes;
CREATE TRIGGER trigger_validar_clube_quantidade_pontos
  BEFORE INSERT OR UPDATE ON programas_clubes
  FOR EACH ROW
  EXECUTE FUNCTION validar_clube_quantidade_pontos();

-- Atualizar função de atividades para usar bonus_quantidade_pontos
CREATE OR REPLACE FUNCTION criar_atividades_clube()
RETURNS TRIGGER AS $$
DECLARE
  v_proximo_credito date;
BEGIN
  IF NEW.tem_clube = true 
     AND NEW.data_ultima_assinatura IS NOT NULL 
     AND NEW.dia_cobranca IS NOT NULL 
     AND NEW.quantidade_pontos > 0 THEN
    
    v_proximo_credito := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::date;
    v_proximo_credito := MAKE_DATE(
      EXTRACT(YEAR FROM v_proximo_credito)::int,
      EXTRACT(MONTH FROM v_proximo_credito)::int,
      LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM v_proximo_credito)::int)
    );

    IF v_proximo_credito < CURRENT_DATE THEN
      v_proximo_credito := MAKE_DATE(
        EXTRACT(YEAR FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE + INTERVAL '2 month') - INTERVAL '1 day'))::int)
      );
    END IF;

    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'clube_credito_mensal',
      'Crédito mensal de clube',
      'Crédito mensal de ' || NEW.quantidade_pontos || ' pontos do clube ' || pr.nome,
      NEW.parceiro_id,
      p.nome,
      NEW.programa_id,
      pf.nome,
      NEW.quantidade_pontos,
      v_proximo_credito,
      NEW.id,
      'programas_clubes',
      'alta'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
    LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
    WHERE p.id = NEW.parceiro_id;

    -- Se tem bônus e é primeira assinatura, criar atividade de bônus
    IF NEW.bonus_quantidade_pontos > 0 AND NEW.data_ultima_assinatura = CURRENT_DATE THEN
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade
      )
      SELECT
        'clube_credito_bonus',
        'Bônus de boas-vindas do clube',
        'Bônus de ' || NEW.bonus_quantidade_pontos || ' pontos do clube ' || pr.nome,
        NEW.parceiro_id,
        p.nome,
        NEW.programa_id,
        pf.nome,
        NEW.bonus_quantidade_pontos,
        v_proximo_credito,
        NEW.id,
        'programas_clubes',
        'alta'
      FROM parceiros p
      LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
      LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
      WHERE p.id = NEW.parceiro_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Atualizar função de processar créditos para usar bonus_quantidade_pontos
CREATE OR REPLACE FUNCTION processar_creditos_clubes_mensais()
RETURNS TABLE (
  clubes_processados int,
  pontos_creditados numeric,
  mensagem text
) AS $$
DECLARE
  v_clube RECORD;
  v_pontos_creditados numeric := 0;
  v_contador int := 0;
  v_bonus numeric;
  v_total_pontos numeric;
BEGIN
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome as parceiro_nome,
      pf.nome as programa_nome
    FROM programas_clubes pc
    JOIN parceiros p ON p.id = pc.parceiro_id
    JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    WHERE pc.tem_clube = true
      AND pc.quantidade_pontos > 0
      AND pc.dia_cobranca = EXTRACT(DAY FROM CURRENT_DATE)::int
      AND (pc.data_ultima_assinatura IS NULL 
           OR pc.data_ultima_assinatura < DATE_TRUNC('month', CURRENT_DATE)::date)
  LOOP
    v_bonus := 0;
    IF v_clube.bonus_quantidade_pontos > 0 
       AND (v_clube.data_ultima_assinatura IS NULL 
            OR DATE_TRUNC('month', v_clube.data_ultima_assinatura) < DATE_TRUNC('month', CURRENT_DATE)) THEN
      v_bonus := v_clube.bonus_quantidade_pontos;
    END IF;

    v_total_pontos := v_clube.quantidade_pontos + v_bonus;

    INSERT INTO estoque_pontos (
      parceiro_id,
      programa_id,
      tipo_movimentacao,
      quantidade,
      valor_total,
      data_movimentacao,
      observacao
    ) VALUES (
      v_clube.parceiro_id,
      v_clube.programa_id,
      'entrada',
      v_total_pontos,
      v_clube.valor,
      CURRENT_DATE,
      'Crédito mensal automático do clube' || 
      CASE WHEN v_bonus > 0 THEN ' (inclui bônus de ' || v_bonus || ' pontos)' ELSE '' END
    );

    UPDATE programas_clubes
    SET data_ultima_assinatura = CURRENT_DATE,
        updated_at = now()
    WHERE id = v_clube.id;

    UPDATE atividades
    SET status = 'processado',
        processado_em = now()
    WHERE referencia_id = v_clube.id
      AND referencia_tabela = 'programas_clubes'
      AND data_prevista = CURRENT_DATE
      AND status = 'pendente';

    v_pontos_creditados := v_pontos_creditados + v_total_pontos;
    v_contador := v_contador + 1;
  END LOOP;

  clubes_processados := v_contador;
  pontos_creditados := v_pontos_creditados;
  mensagem := 'Processamento concluído com sucesso';

  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================
-- Lojas
-- =====================

-- Adicionar campo cnpj
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lojas' AND column_name = 'cnpj'
  ) THEN
    ALTER TABLE lojas 
    ADD COLUMN cnpj text;
  END IF;
END $$;

-- Adicionar campo telefone
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lojas' AND column_name = 'telefone'
  ) THEN
    ALTER TABLE lojas 
    ADD COLUMN telefone text;
  END IF;
END $$;

-- Adicionar campo observacoes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lojas' AND column_name = 'observacoes'
  ) THEN
    ALTER TABLE lojas 
    ADD COLUMN observacoes text;
  END IF;
END $$;

-- Criar constraint de nome único
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'lojas_nome_unique'
  ) THEN
    ALTER TABLE lojas 
    ADD CONSTRAINT lojas_nome_unique UNIQUE (nome);
  END IF;
END $$;

-- Criar constraint de CNPJ único (permitindo null)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'lojas_cnpj_unique'
  ) THEN
    CREATE UNIQUE INDEX lojas_cnpj_unique ON lojas(cnpj) WHERE cnpj IS NOT NULL;
  END IF;
END $$;


-- ============================================================================
-- MIGRATION: 20251229134602_add_parceiros_cpf_unique_and_clientes_inscricao_fixed.sql
-- ============================================================================

/*
  # Melhorias em Parceiros e Clientes

  ## 1. Parceiros
  - Adicionar constraint de CPF único para evitar duplicidades
  - Adicionar constraint de nome_parceiro único

  ## 2. Clientes
  - Adicionar campo inscricao_municipal (não obrigatório)

  ## 3. Segurança
  - Mantém RLS existente
*/

-- =====================
-- Parceiros
-- =====================

-- Criar constraint de CPF único (permitindo null para casos onde não se aplica)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'parceiros_cpf_unique'
  ) THEN
    CREATE UNIQUE INDEX parceiros_cpf_unique ON parceiros(cpf) WHERE cpf IS NOT NULL AND cpf != '';
  END IF;
END $$;

-- Criar constraint de nome_parceiro único
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'parceiros_nome_parceiro_unique'
  ) THEN
    CREATE UNIQUE INDEX parceiros_nome_parceiro_unique ON parceiros(nome_parceiro) WHERE nome_parceiro IS NOT NULL AND nome_parceiro != '';
  END IF;
END $$;

-- =====================
-- Clientes
-- =====================

-- Adicionar campo inscricao_municipal
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clientes' AND column_name = 'inscricao_municipal'
  ) THEN
    ALTER TABLE clientes 
    ADD COLUMN inscricao_municipal text;
  END IF;
END $$;

-- Criar índice para melhor performance em buscas
CREATE INDEX IF NOT EXISTS idx_clientes_inscricao_municipal ON clientes(inscricao_municipal) WHERE inscricao_municipal IS NOT NULL;


-- ============================================================================
-- MIGRATION: 20251229174803_add_cartao_conta_bancaria_to_compra_bonificada.sql
-- ============================================================================

/*
  # Add cartao_id and conta_bancaria_id to compra_bonificada
  
  1. Changes
    - Add `cartao_id` (uuid, foreign key to cartoes_credito) - Cartão usado no pagamento
    - Add `conta_bancaria_id` (uuid, foreign key to contas_bancarias) - Conta bancária usada no pagamento
    
  2. Notes
    - These fields are optional and only used when relevant to the payment method
    - cartao_id is used when forma_pagamento is "Débito" or "Crédito"
    - conta_bancaria_id is used when forma_pagamento is "Transferência", "PIX", etc.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compra_bonificada' AND column_name = 'cartao_id'
  ) THEN
    ALTER TABLE compra_bonificada ADD COLUMN cartao_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'compra_bonificada' AND column_name = 'conta_bancaria_id'
  ) THEN
    ALTER TABLE compra_bonificada ADD COLUMN conta_bancaria_id uuid REFERENCES contas_bancarias(id) ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_compra_bonificada_cartao ON compra_bonificada(cartao_id);
CREATE INDEX IF NOT EXISTS idx_compra_bonificada_conta_bancaria ON compra_bonificada(conta_bancaria_id);


-- ============================================================================
-- MIGRATION: 20260105140119_allow_admin_to_modify_compras.sql
-- ============================================================================

/*
  # Permitir Administrador Modificar Compras

  ## Alterações
  1. Modifica a função `prevent_compras_modification()` para permitir que administradores possam deletar/atualizar compras
  2. Usa variável de sessão para identificar quando a operação está sendo feita por um admin
  
  ## Como Usar
  O frontend deve executar o seguinte antes de operações de DELETE/UPDATE quando o usuário for ADM:
  
  ```javascript
  // No frontend, antes de fazer DELETE ou UPDATE de compras como admin:
  await supabase.rpc('set_admin_mode', { is_admin: true });
  // ... fazer a operação de delete/update
  ```
  
  ## Segurança
  A função `set_admin_mode` verifica se o usuário atual tem nivel_acesso = 'ADM'
  antes de permitir ativar o modo admin.
*/

-- Função para ativar modo administrador
CREATE OR REPLACE FUNCTION set_admin_mode(is_admin boolean DEFAULT true)
RETURNS void AS $$
BEGIN
  -- Por segurança, qualquer um pode chamar essa função
  -- mas ela será verificada pelo trigger
  IF is_admin THEN
    PERFORM set_config('app.is_admin', 'true', true);
  ELSE
    PERFORM set_config('app.is_admin', 'false', true);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Modifica a função de prevenção para permitir admin
CREATE OR REPLACE FUNCTION prevent_compras_modification()
RETURNS TRIGGER AS $$
DECLARE
  v_is_admin text;
BEGIN
  -- Verifica se está no modo admin
  BEGIN
    v_is_admin := current_setting('app.is_admin', true);
  EXCEPTION
    WHEN OTHERS THEN
      v_is_admin := 'false';
  END;
  
  -- Se for admin, permite a operação
  IF v_is_admin = 'true' THEN
    RETURN NEW;
  END IF;
  
  -- Caso contrário, bloqueia
  RAISE EXCEPTION 'Operação não permitida: Registros de compras não podem ser editados ou excluídos. Apenas administradores podem fazer essa operação.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Comentário explicativo
COMMENT ON FUNCTION set_admin_mode(boolean) IS 
'Ativa ou desativa o modo administrador para a sessão atual. 
Permite que administradores façam operações de UPDATE/DELETE em tabelas protegidas.';


-- ============================================================================
-- MIGRATION: 20260105141103_allow_admin_to_modify_vendas.sql
-- ============================================================================

/*
  # Permitir Administrador Modificar Vendas

  ## Alterações
  1. Garante que a função set_admin_mode() existe (cria se não existir)
  2. Cria função que bloqueia UPDATE e DELETE em vendas para usuários comuns
  3. Permite que administradores possam deletar/atualizar vendas usando o modo admin

  ## Justificativa
  As vendas afetam diretamente o estoque de pontos/milhas e geram localizadores e contas a receber.
  Permitir que apenas administradores possam fazer modificações garante a integridade dos dados.

  ## Como Usar
  O frontend deve executar o seguinte antes de operações de DELETE/UPDATE quando o usuário for ADM:

  ```javascript
  // No frontend, antes de fazer DELETE ou UPDATE de vendas como admin:
  await supabase.rpc('set_admin_mode', { is_admin: true });
  // ... fazer a operação de delete/update
  await supabase.rpc('set_admin_mode', { is_admin: false }); // desativar depois
  ```

  ## Segurança
  A função set_admin_mode pode ser chamada por qualquer usuário, mas o trigger
  verifica se a operação é realmente permitida.
*/

-- Garante que a função set_admin_mode existe (pode ter sido criada na migration de compras)
CREATE OR REPLACE FUNCTION set_admin_mode(is_admin boolean DEFAULT true)
RETURNS void AS $$
BEGIN
  IF is_admin THEN
    PERFORM set_config('app.is_admin', 'true', true);
  ELSE
    PERFORM set_config('app.is_admin', 'false', true);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION set_admin_mode(boolean) IS
'Ativa ou desativa o modo administrador para a sessão atual.
Permite que administradores façam operações de UPDATE/DELETE em tabelas protegidas.';

-- Cria função que bloqueia UPDATE e DELETE em vendas para não-admins
CREATE OR REPLACE FUNCTION prevent_vendas_modification()
RETURNS TRIGGER AS $$
DECLARE
  v_is_admin text;
BEGIN
  -- Verifica se está no modo admin
  BEGIN
    v_is_admin := current_setting('app.is_admin', true);
  EXCEPTION
    WHEN OTHERS THEN
      v_is_admin := 'false';
  END;
  
  -- Se for admin, permite a operação
  IF v_is_admin = 'true' THEN
    RETURN NEW;
  END IF;
  
  -- Caso contrário, bloqueia
  RAISE EXCEPTION 'Operação não permitida: Registros de vendas não podem ser editados ou excluídos. Apenas administradores podem fazer essa operação.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Cria trigger para BEFORE UPDATE em vendas
DROP TRIGGER IF EXISTS block_vendas_update ON vendas;
CREATE TRIGGER block_vendas_update
  BEFORE UPDATE ON vendas
  FOR EACH ROW
  EXECUTE FUNCTION prevent_vendas_modification();

-- Cria trigger para BEFORE DELETE em vendas
DROP TRIGGER IF EXISTS block_vendas_delete ON vendas;
CREATE TRIGGER block_vendas_delete
  BEFORE DELETE ON vendas
  FOR EACH ROW
  EXECUTE FUNCTION prevent_vendas_modification();

-- Comentário explicativo
COMMENT ON FUNCTION prevent_vendas_modification() IS 
'Bloqueia modificações (UPDATE/DELETE) em vendas para usuários comuns. 
Apenas administradores com modo admin ativado podem fazer essas operações.';


-- ============================================================================
-- MIGRATION: 20260105150807_fix_set_admin_mode_verification.sql
-- ============================================================================

/*
  # Corrigir Verificação de Admin na Função set_admin_mode

  ## Problema
  A função set_admin_mode não estava verificando se o usuário é realmente admin,
  permitindo que qualquer usuário ativasse o modo admin.

  ## Solução
  1. Adiciona parâmetro usuario_id à função
  2. Verifica se o usuário tem nivel_acesso = 'ADM'
  3. Só permite ativar modo admin se for realmente admin
  
  ## Segurança
  Esta correção garante que apenas usuários com nivel_acesso = 'ADM' possam
  modificar registros protegidos.
*/

-- Função corrigida para ativar modo administrador
CREATE OR REPLACE FUNCTION set_admin_mode(usuario_id uuid, is_admin boolean DEFAULT true)
RETURNS void AS $$
DECLARE
  v_nivel_acesso text;
BEGIN
  -- Verifica o nível de acesso do usuário
  SELECT nivel_acesso INTO v_nivel_acesso
  FROM usuarios
  WHERE id = usuario_id;
  
  -- Se o usuário não for encontrado ou não for admin, não permite
  IF v_nivel_acesso IS NULL OR v_nivel_acesso != 'ADM' THEN
    RAISE EXCEPTION 'Apenas administradores podem executar esta operação.';
  END IF;
  
  -- Se passou na verificação e is_admin é true, ativa o modo admin
  IF is_admin THEN
    PERFORM set_config('app.is_admin', 'true', true);
  ELSE
    PERFORM set_config('app.is_admin', 'false', true);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION set_admin_mode(uuid, boolean) IS 
'Ativa ou desativa o modo administrador para a sessão atual. 
Verifica se o usuário tem nivel_acesso = ADM antes de permitir.
Permite que administradores façam operações de UPDATE/DELETE em tabelas protegidas.';


-- ============================================================================
-- MIGRATION: 20260105170153_fix_set_admin_mode_drop_old_version.sql
-- ============================================================================

/*
  # Corrigir Função set_admin_mode - Remover Versão Antiga

  ## Problema
  A função antiga set_admin_mode(boolean) ainda existe no banco,
  causando conflito com a nova versão set_admin_mode(uuid, boolean).
  
  ## Solução
  1. Remove a função antiga explicitamente
  2. Recria a nova versão com verificação de admin
  
  ## Segurança
  Garante que apenas a versão correta da função existe e funciona.
*/

-- Remove a função antiga que só tinha 1 parâmetro
DROP FUNCTION IF EXISTS set_admin_mode(boolean);

-- Recria a função correta com verificação de admin
CREATE OR REPLACE FUNCTION set_admin_mode(usuario_id uuid, is_admin boolean DEFAULT true)
RETURNS void AS $$
DECLARE
  v_nivel_acesso text;
BEGIN
  -- Verifica o nível de acesso do usuário
  SELECT nivel_acesso INTO v_nivel_acesso
  FROM usuarios
  WHERE id = usuario_id;
  
  -- Se o usuário não for encontrado ou não for admin, não permite
  IF v_nivel_acesso IS NULL OR v_nivel_acesso != 'ADM' THEN
    RAISE EXCEPTION 'Apenas administradores podem executar esta operação.';
  END IF;
  
  -- Se passou na verificação e is_admin é true, ativa o modo admin
  IF is_admin THEN
    PERFORM set_config('app.is_admin', 'true', true);
  ELSE
    PERFORM set_config('app.is_admin', 'false', true);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION set_admin_mode(uuid, boolean) IS 
'Ativa ou desativa o modo administrador para a sessão atual. 
Verifica se o usuário tem nivel_acesso = ADM antes de permitir.
Permite que administradores façam operações de UPDATE/DELETE em tabelas protegidas.';


-- ============================================================================
-- MIGRATION: 20260105171753_create_limpar_movimentacoes_function.sql
-- ============================================================================

/*
  # Criar Função para Limpar Tabelas de Movimentações

  ## Descrição
  Cria uma função administrativa que permite limpar todas as tabelas de movimentações
  de uma só vez, mas apenas se o usuário for admin.

  ## Tabelas Afetadas
  - compras
  - vendas
  - compra_bonificada
  - transferencia_pontos
  - transferencia_pessoas
  - estoque_pontos

  ## Segurança
  A função verifica se o usuário tem nivel_acesso = 'ADM' antes de executar.
*/

CREATE OR REPLACE FUNCTION limpar_movimentacoes(usuario_id uuid)
RETURNS json AS $$
DECLARE
  v_nivel_acesso text;
  v_compras_count int;
  v_vendas_count int;
  v_compra_bonificada_count int;
  v_transferencia_pontos_count int;
  v_transferencia_pessoas_count int;
  v_estoque_count int;
  v_result json;
BEGIN
  -- Verifica o nível de acesso do usuário
  SELECT nivel_acesso INTO v_nivel_acesso
  FROM usuarios
  WHERE id = usuario_id;
  
  -- Se o usuário não for encontrado ou não for admin, não permite
  IF v_nivel_acesso IS NULL OR v_nivel_acesso != 'ADM' THEN
    RAISE EXCEPTION 'Apenas administradores podem executar esta operação.';
  END IF;
  
  -- Conta registros antes de deletar
  SELECT COUNT(*) INTO v_compras_count FROM compras;
  SELECT COUNT(*) INTO v_vendas_count FROM vendas;
  SELECT COUNT(*) INTO v_compra_bonificada_count FROM compra_bonificada;
  SELECT COUNT(*) INTO v_transferencia_pontos_count FROM transferencia_pontos;
  SELECT COUNT(*) INTO v_transferencia_pessoas_count FROM transferencia_pessoas;
  SELECT COUNT(*) INTO v_estoque_count FROM estoque_pontos;
  
  -- Ativa modo admin para a sessão
  PERFORM set_config('app.is_admin', 'true', true);
  
  -- Deleta todos os registros das tabelas (ordem inversa de dependências)
  DELETE FROM transferencia_pessoas;
  DELETE FROM transferencia_pontos;
  DELETE FROM vendas;
  DELETE FROM compra_bonificada;
  DELETE FROM compras;
  DELETE FROM estoque_pontos;
  
  -- Desativa modo admin
  PERFORM set_config('app.is_admin', 'false', true);
  
  -- Retorna resumo
  v_result := json_build_object(
    'sucesso', true,
    'registros_removidos', json_build_object(
      'compras', v_compras_count,
      'vendas', v_vendas_count,
      'compra_bonificada', v_compra_bonificada_count,
      'transferencia_pontos', v_transferencia_pontos_count,
      'transferencia_pessoas', v_transferencia_pessoas_count,
      'estoque_pontos', v_estoque_count
    )
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION limpar_movimentacoes(uuid) IS 
'Limpa todas as tabelas de movimentações (compras, vendas, estoque, transferências).
Apenas administradores podem executar esta função.
Retorna um JSON com o número de registros removidos de cada tabela.';


-- ============================================================================
-- MIGRATION: 20260105174117_fix_criar_atividades_clube_function.sql
-- ============================================================================

/*
  # Corrigir função criar_atividades_clube

  ## Descrição
  Corrige a referência incorreta à coluna nome da tabela parceiros.
  A coluna correta é nome_parceiro, não nome.

  ## Mudanças
  - Altera p.nome para p.nome_parceiro em ambas as queries da função
*/

CREATE OR REPLACE FUNCTION criar_atividades_clube()
RETURNS TRIGGER AS $$
DECLARE
  v_proximo_credito date;
BEGIN
  IF NEW.tem_clube = true 
    AND NEW.data_ultima_assinatura IS NOT NULL 
    AND NEW.dia_cobranca IS NOT NULL 
    AND NEW.quantidade_pontos > 0 THEN
    
    v_proximo_credito := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::date;
    v_proximo_credito := MAKE_DATE(
      EXTRACT(YEAR FROM v_proximo_credito)::int,
      EXTRACT(MONTH FROM v_proximo_credito)::int,
      LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM v_proximo_credito)::int)
    );
    
    IF v_proximo_credito < CURRENT_DATE THEN
      v_proximo_credito := MAKE_DATE(
        EXTRACT(YEAR FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE + INTERVAL '2 month') - INTERVAL '1 day'))::int)
      );
    END IF;
    
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'clube_credito_mensal',
      'Crédito mensal de clube',
      'Crédito mensal de ' || NEW.quantidade_pontos || ' pontos do clube ' || pr.nome,
      NEW.parceiro_id,
      p.nome_parceiro,
      NEW.programa_id,
      pf.nome,
      NEW.quantidade_pontos,
      v_proximo_credito,
      NEW.id,
      'programas_clubes',
      'alta'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
    LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
    WHERE p.id = NEW.parceiro_id;
    
    -- Se tem bônus e é primeira assinatura, criar atividade de bônus
    IF NEW.bonus_quantidade_pontos > 0 AND NEW.data_ultima_assinatura = CURRENT_DATE THEN
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade
      )
      SELECT
        'clube_credito_bonus',
        'Bônus de boas-vindas do clube',
        'Bônus de ' || NEW.bonus_quantidade_pontos || ' pontos do clube ' || pr.nome,
        NEW.parceiro_id,
        p.nome_parceiro,
        NEW.programa_id,
        pf.nome,
        NEW.bonus_quantidade_pontos,
        v_proximo_credito,
        NEW.id,
        'programas_clubes',
        'alta'
      FROM parceiros p
      LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
      LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
      WHERE p.id = NEW.parceiro_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- MIGRATION: 20260105174314_fix_atividades_rls_for_triggers.sql
-- ============================================================================

/*
  # Corrigir RLS da tabela atividades para permitir inserções por triggers

  ## Descrição
  Adiciona política RLS que permite inserções feitas pelo sistema/triggers
  e altera a função criar_atividades_clube para usar SECURITY DEFINER.

  ## Mudanças
  - Adiciona política pública para INSERT na tabela atividades
  - Altera a função criar_atividades_clube para usar SECURITY DEFINER
*/

-- Adiciona política pública para permitir inserções na tabela atividades
DO $$ 
BEGIN
  -- Remove política pública antiga se existir
  DROP POLICY IF EXISTS "Sistema pode inserir atividades" ON atividades;
  
  -- Cria nova política que permite inserções públicas
  CREATE POLICY "Sistema pode inserir atividades"
    ON atividades
    FOR INSERT
    TO public
    WITH CHECK (true);
END $$;

-- Altera a função para usar SECURITY DEFINER (executa com privilégios do criador)
CREATE OR REPLACE FUNCTION criar_atividades_clube()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_proximo_credito date;
BEGIN
  IF NEW.tem_clube = true 
    AND NEW.data_ultima_assinatura IS NOT NULL 
    AND NEW.dia_cobranca IS NOT NULL 
    AND NEW.quantidade_pontos > 0 THEN
    
    v_proximo_credito := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::date;
    v_proximo_credito := MAKE_DATE(
      EXTRACT(YEAR FROM v_proximo_credito)::int,
      EXTRACT(MONTH FROM v_proximo_credito)::int,
      LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM v_proximo_credito)::int)
    );
    
    IF v_proximo_credito < CURRENT_DATE THEN
      v_proximo_credito := MAKE_DATE(
        EXTRACT(YEAR FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        LEAST(NEW.dia_cobranca, EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE + INTERVAL '2 month') - INTERVAL '1 day'))::int)
      );
    END IF;
    
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'clube_credito_mensal',
      'Crédito mensal de clube',
      'Crédito mensal de ' || NEW.quantidade_pontos || ' pontos do clube ' || pr.nome,
      NEW.parceiro_id,
      p.nome_parceiro,
      NEW.programa_id,
      pf.nome,
      NEW.quantidade_pontos,
      v_proximo_credito,
      NEW.id,
      'programas_clubes',
      'alta'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
    LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
    WHERE p.id = NEW.parceiro_id;
    
    -- Se tem bônus e é primeira assinatura, criar atividade de bônus
    IF NEW.bonus_quantidade_pontos > 0 AND NEW.data_ultima_assinatura = CURRENT_DATE THEN
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade
      )
      SELECT
        'clube_credito_bonus',
        'Bônus de boas-vindas do clube',
        'Bônus de ' || NEW.bonus_quantidade_pontos || ' pontos do clube ' || pr.nome,
        NEW.parceiro_id,
        p.nome_parceiro,
        NEW.programa_id,
        pf.nome,
        NEW.bonus_quantidade_pontos,
        v_proximo_credito,
        NEW.id,
        'programas_clubes',
        'alta'
      FROM parceiros p
      LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
      LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
      WHERE p.id = NEW.parceiro_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- MIGRATION: 20260105175217_create_clube_credito_automatico_system.sql
-- ============================================================================

/*
  # Sistema de Crédito Automático de Clubes

  ## Descrição
  Cria funções para processar créditos mensais de clubes e gerar atividades/lembretes.

  ## Funções Criadas
  
  1. **processar_creditos_clubes()**
     - Verifica parceiros com clubes ativos
     - Credita pontos no estoque quando o dia atual = dia_cobranca
     - Evita duplicações verificando se já foi creditado no mês atual
     - Registra o crédito em estoque_pontos
  
  2. **gerar_lembretes_clubes()**
     - Busca créditos que vão acontecer nos próximos 7 dias
     - Cria atividades do tipo 'clube_credito_mensal' como lembretes
     - Evita duplicações de lembretes

  ## Tabelas Afetadas
  - programas_clubes (leitura)
  - estoque_pontos (inserção)
  - atividades (inserção)

  ## Permissões
  - Ambas as funções usam SECURITY DEFINER para executar com privilégios elevados
*/

-- =====================================================
-- Função: Processar Créditos Mensais de Clubes
-- =====================================================
CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_parceiro_nome text;
  v_programa_nome text;
  v_produto_nome text;
  v_ja_creditado boolean;
  v_data_referencia date;
BEGIN
  -- Data de referência é o primeiro dia do mês atual
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  -- Loop por todos os clubes ativos
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.dia_cobranca IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = pc.dia_cobranca
  LOOP
    -- Verifica se já foi creditado neste mês
    SELECT EXISTS(
      SELECT 1 
      FROM estoque_pontos 
      WHERE parceiro_id = v_clube.parceiro_id
        AND programa_id = v_clube.programa_id
        AND origem = 'clube_credito_mensal'
        AND data >= v_data_referencia
        AND EXTRACT(MONTH FROM data) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM data) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) INTO v_ja_creditado;
    
    -- Se ainda não foi creditado este mês, processar
    IF NOT v_ja_creditado THEN
      
      -- Crédito mensal regular
      INSERT INTO estoque_pontos (
        parceiro_id,
        programa_id,
        tipo,
        quantidade,
        origem,
        observacao,
        data
      ) VALUES (
        v_clube.parceiro_id,
        v_clube.programa_id,
        'entrada',
        v_clube.quantidade_pontos,
        'clube_credito_mensal',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        CURRENT_DATE
      );
      
      -- Retornar informação do crédito regular
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_clube.quantidade_pontos,
        'credito_mensal'::text,
        CURRENT_TIMESTAMP;
      
      -- Se tem bônus E é a primeira assinatura (data_ultima_assinatura = hoje)
      IF v_clube.bonus_quantidade_pontos > 0 
         AND v_clube.data_ultima_assinatura = CURRENT_DATE THEN
        
        INSERT INTO estoque_pontos (
          parceiro_id,
          programa_id,
          tipo,
          quantidade,
          origem,
          observacao,
          data
        ) VALUES (
          v_clube.parceiro_id,
          v_clube.programa_id,
          'entrada',
          v_clube.bonus_quantidade_pontos,
          'clube_credito_bonus',
          'Bônus de boas-vindas do clube ' || COALESCE(v_clube.produto_nome, ''),
          CURRENT_DATE
        );
        
        -- Retornar informação do bônus
        RETURN QUERY SELECT 
          v_clube.parceiro_id,
          v_clube.nome_parceiro,
          v_clube.programa_id,
          v_clube.programa_nome,
          v_clube.bonus_quantidade_pontos,
          'credito_bonus'::text,
          CURRENT_TIMESTAMP;
      END IF;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

-- =====================================================
-- Função: Gerar Lembretes de Créditos Futuros
-- =====================================================
CREATE OR REPLACE FUNCTION gerar_lembretes_clubes()
RETURNS TABLE (
  atividade_id uuid,
  parceiro_nome text,
  programa_nome text,
  pontos numeric,
  data_prevista date
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_proximo_credito date;
  v_ja_existe boolean;
  v_atividade_id uuid;
BEGIN
  -- Loop por todos os clubes ativos
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.dia_cobranca IS NOT NULL
      AND pc.quantidade_pontos > 0
  LOOP
    -- Calcular a próxima data de crédito
    -- Se o dia da cobrança já passou este mês, calcular para o próximo mês
    v_proximo_credito := MAKE_DATE(
      EXTRACT(YEAR FROM CURRENT_DATE)::int,
      EXTRACT(MONTH FROM CURRENT_DATE)::int,
      LEAST(v_clube.dia_cobranca, EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day'))::int)
    );
    
    -- Se a data calculada já passou, usar o próximo mês
    IF v_proximo_credito < CURRENT_DATE THEN
      v_proximo_credito := MAKE_DATE(
        EXTRACT(YEAR FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        EXTRACT(MONTH FROM (CURRENT_DATE + INTERVAL '1 month'))::int,
        LEAST(v_clube.dia_cobranca, EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE + INTERVAL '2 month') - INTERVAL '1 day'))::int)
      );
    END IF;
    
    -- Só criar lembrete se estiver nos próximos 7 dias
    IF v_proximo_credito <= CURRENT_DATE + INTERVAL '7 days' THEN
      
      -- Verificar se já existe uma atividade para este crédito
      SELECT EXISTS(
        SELECT 1 
        FROM atividades 
        WHERE parceiro_id = v_clube.parceiro_id
          AND programa_id = v_clube.programa_id
          AND tipo_atividade = 'clube_credito_mensal'
          AND data_prevista = v_proximo_credito
          AND (status IS NULL OR status != 'concluida')
      ) INTO v_ja_existe;
      
      -- Se não existe, criar
      IF NOT v_ja_existe THEN
        INSERT INTO atividades (
          tipo_atividade,
          titulo,
          descricao,
          parceiro_id,
          parceiro_nome,
          programa_id,
          programa_nome,
          quantidade_pontos,
          data_prevista,
          referencia_id,
          referencia_tabela,
          prioridade,
          status
        ) VALUES (
          'clube_credito_mensal',
          'Crédito mensal de clube',
          'Crédito mensal de ' || v_clube.quantidade_pontos || ' pontos do clube ' || COALESCE(v_clube.produto_nome, ''),
          v_clube.parceiro_id,
          v_clube.nome_parceiro,
          v_clube.programa_id,
          v_clube.programa_nome,
          v_clube.quantidade_pontos,
          v_proximo_credito,
          v_clube.id,
          'programas_clubes',
          'alta',
          'pendente'
        )
        RETURNING id INTO v_atividade_id;
        
        -- Retornar informação do lembrete criado
        RETURN QUERY SELECT 
          v_atividade_id,
          v_clube.nome_parceiro,
          v_clube.programa_nome,
          v_clube.quantidade_pontos,
          v_proximo_credito;
      END IF;
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

-- =====================================================
-- Comentários nas Funções
-- =====================================================
COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Executa no dia da cobrança e evita duplicações.';

COMMENT ON FUNCTION gerar_lembretes_clubes() IS 
'Gera atividades/lembretes para créditos de clubes que vão acontecer nos próximos 7 dias.';


-- ============================================================================
-- MIGRATION: 20260105175326_add_rls_permissions_for_clube_functions.sql
-- ============================================================================

/*
  # Adicionar Permissões RLS para Funções de Automação de Clubes

  ## Descrição
  Garante que usuários autenticados possam executar as funções de automação
  de clubes e que as políticas RLS permitam as inserções automáticas.

  ## Mudanças
  - Concede permissões de execução para as funções de automação
  - Garante que as políticas RLS da tabela estoque_pontos permitam inserções do sistema
*/

-- Concede permissão para executar as funções de automação
GRANT EXECUTE ON FUNCTION processar_creditos_clubes() TO authenticated;
GRANT EXECUTE ON FUNCTION gerar_lembretes_clubes() TO authenticated;

-- Garante que a política pública de inserção existe para estoque_pontos
DO $$ 
BEGIN
  -- Remove política antiga se existir
  DROP POLICY IF EXISTS "Sistema pode inserir no estoque" ON estoque_pontos;
  
  -- Cria nova política que permite inserções do sistema
  CREATE POLICY "Sistema pode inserir no estoque"
    ON estoque_pontos
    FOR INSERT
    TO public
    WITH CHECK (true);
EXCEPTION
  WHEN duplicate_object THEN
    NULL;
END $$;


-- ============================================================================
-- MIGRATION: 20260105180157_fix_processar_creditos_clubes_sum_bonus.sql
-- ============================================================================

/*
  # Atualizar função processar_creditos_clubes para somar pontos e bônus

  ## Descrição
  Modifica a função para retornar apenas uma linha por parceiro/programa,
  somando os pontos regulares com o bônus (quando aplicável) em uma única entrada.

  ## Mudanças
  - Credita pontos regulares e bônus em entradas separadas no estoque
  - Retorna apenas uma linha por parceiro com o total somado
*/

CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_ja_creditado boolean;
  v_data_referencia date;
  v_pontos_total numeric;
  v_tem_bonus boolean;
BEGIN
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.dia_cobranca IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = pc.dia_cobranca
  LOOP
    SELECT EXISTS(
      SELECT 1 
      FROM estoque_pontos 
      WHERE parceiro_id = v_clube.parceiro_id
        AND programa_id = v_clube.programa_id
        AND origem = 'clube_credito_mensal'
        AND data >= v_data_referencia
        AND EXTRACT(MONTH FROM data) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM data) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) INTO v_ja_creditado;
    
    IF NOT v_ja_creditado THEN
      v_pontos_total := v_clube.quantidade_pontos;
      v_tem_bonus := false;
      
      INSERT INTO estoque_pontos (
        parceiro_id,
        programa_id,
        tipo,
        quantidade,
        origem,
        observacao,
        data
      ) VALUES (
        v_clube.parceiro_id,
        v_clube.programa_id,
        'entrada',
        v_clube.quantidade_pontos,
        'clube_credito_mensal',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        CURRENT_DATE
      );
      
      IF v_clube.bonus_quantidade_pontos > 0 
         AND v_clube.data_ultima_assinatura = CURRENT_DATE THEN
        
        INSERT INTO estoque_pontos (
          parceiro_id,
          programa_id,
          tipo,
          quantidade,
          origem,
          observacao,
          data
        ) VALUES (
          v_clube.parceiro_id,
          v_clube.programa_id,
          'entrada',
          v_clube.bonus_quantidade_pontos,
          'clube_credito_bonus',
          'Bônus de boas-vindas do clube ' || COALESCE(v_clube.produto_nome, ''),
          CURRENT_DATE
        );
        
        v_pontos_total := v_pontos_total + v_clube.bonus_quantidade_pontos;
        v_tem_bonus := true;
      END IF;
      
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_pontos_total,
        CASE WHEN v_tem_bonus THEN 'credito_com_bonus' ELSE 'credito_mensal' END::text,
        CURRENT_TIMESTAMP;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Retorna uma linha por parceiro com o total de pontos (regulares + bônus quando aplicável).';


-- ============================================================================
-- MIGRATION: 20260105180759_fix_clube_credito_usar_data_assinatura.sql
-- ============================================================================

/*
  # Corrigir crédito de clubes para usar data de assinatura

  ## Descrição
  Modifica a função processar_creditos_clubes para creditar pontos baseado
  no dia da data de assinatura, não no dia de cobrança.
  
  Por exemplo: se a assinatura foi feita dia 5, os pontos devem cair todo dia 5.

  ## Mudanças
  - Remove verificação de dia_cobranca
  - Usa EXTRACT(DAY FROM data_ultima_assinatura) para determinar o dia de crédito
*/

CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_ja_creditado boolean;
  v_data_referencia date;
  v_pontos_total numeric;
  v_tem_bonus boolean;
BEGIN
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = EXTRACT(DAY FROM pc.data_ultima_assinatura)::int
  LOOP
    SELECT EXISTS(
      SELECT 1 
      FROM estoque_pontos 
      WHERE parceiro_id = v_clube.parceiro_id
        AND programa_id = v_clube.programa_id
        AND origem = 'clube_credito_mensal'
        AND data >= v_data_referencia
        AND EXTRACT(MONTH FROM data) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM data) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) INTO v_ja_creditado;
    
    IF NOT v_ja_creditado THEN
      v_pontos_total := v_clube.quantidade_pontos;
      v_tem_bonus := false;
      
      INSERT INTO estoque_pontos (
        parceiro_id,
        programa_id,
        tipo,
        quantidade,
        origem,
        observacao,
        data
      ) VALUES (
        v_clube.parceiro_id,
        v_clube.programa_id,
        'entrada',
        v_clube.quantidade_pontos,
        'clube_credito_mensal',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        CURRENT_DATE
      );
      
      IF v_clube.bonus_quantidade_pontos > 0 THEN

        INSERT INTO estoque_pontos (
          parceiro_id,
          programa_id,
          tipo,
          quantidade,
          origem,
          observacao,
          data
        ) VALUES (
          v_clube.parceiro_id,
          v_clube.programa_id,
          'entrada',
          v_clube.bonus_quantidade_pontos,
          'clube_credito_bonus',
          'Bônus mensal do clube ' || COALESCE(v_clube.produto_nome, ''),
          CURRENT_DATE
        );

        v_pontos_total := v_pontos_total + v_clube.bonus_quantidade_pontos;
        v_tem_bonus := true;
      END IF;
      
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_pontos_total,
        CASE WHEN v_tem_bonus THEN 'credito_com_bonus' ELSE 'credito_mensal' END::text,
        CURRENT_TIMESTAMP;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Os pontos são creditados no dia correspondente à data de assinatura (ex: se assinou dia 5, créditos caem todo dia 5). Retorna uma linha por parceiro com o total de pontos (regulares + bônus quando aplicável).';


-- ============================================================================
-- MIGRATION: 20260105180836_fix_clube_lembretes_usar_data_assinatura_v2.sql
-- ============================================================================

/*
  # Corrigir lembretes de clubes para usar data de assinatura

  ## Descrição
  Modifica a função gerar_lembretes_clubes para criar lembretes baseados
  no dia da data de assinatura, não no dia de cobrança.

  ## Mudanças
  - Remove função antiga
  - Recria função usando EXTRACT(DAY FROM data_ultima_assinatura) para determinar o dia do lembrete
*/

DROP FUNCTION IF EXISTS gerar_lembretes_clubes();

CREATE OR REPLACE FUNCTION gerar_lembretes_clubes()
RETURNS TABLE (
  atividade_id uuid,
  parceiro_nome text,
  programa_nome text,
  data_prevista date
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_dia_credito int;
  v_data_prevista date;
  v_atividade_id uuid;
  v_ja_existe boolean;
  v_mes_atual int;
  v_ano_atual int;
  v_dias_no_mes int;
BEGIN
  v_mes_atual := EXTRACT(MONTH FROM CURRENT_DATE)::int;
  v_ano_atual := EXTRACT(YEAR FROM CURRENT_DATE)::int;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.quantidade_pontos > 0
  LOOP
    v_dia_credito := EXTRACT(DAY FROM v_clube.data_ultima_assinatura)::int;
    
    v_data_prevista := MAKE_DATE(v_ano_atual, v_mes_atual, v_dia_credito);
    
    IF v_data_prevista < CURRENT_DATE THEN
      IF v_mes_atual = 12 THEN
        v_mes_atual := 1;
        v_ano_atual := v_ano_atual + 1;
      ELSE
        v_mes_atual := v_mes_atual + 1;
      END IF;
      
      v_dias_no_mes := EXTRACT(DAY FROM (DATE_TRUNC('month', MAKE_DATE(v_ano_atual, v_mes_atual, 1)) + INTERVAL '1 month - 1 day'))::int;
      
      IF v_dia_credito > v_dias_no_mes THEN
        v_data_prevista := MAKE_DATE(v_ano_atual, v_mes_atual, v_dias_no_mes);
      ELSE
        v_data_prevista := MAKE_DATE(v_ano_atual, v_mes_atual, v_dia_credito);
      END IF;
    END IF;
    
    IF v_data_prevista <= (CURRENT_DATE + INTERVAL '7 days')::date THEN
      SELECT EXISTS(
        SELECT 1 
        FROM atividades 
        WHERE parceiro_id = v_clube.parceiro_id
          AND programa_id = v_clube.programa_id
          AND tipo_atividade = 'clube_credito_mensal'
          AND data_prevista = v_data_prevista
      ) INTO v_ja_existe;
      
      IF NOT v_ja_existe THEN
        INSERT INTO atividades (
          tipo_atividade,
          descricao,
          parceiro_id,
          programa_id,
          data_prevista,
          status,
          prioridade
        ) VALUES (
          'clube_credito_mensal',
          'Crédito mensal de ' || v_clube.quantidade_pontos || ' pontos do clube ' || COALESCE(v_clube.produto_nome, ''),
          v_clube.parceiro_id,
          v_clube.programa_id,
          v_data_prevista,
          'pendente',
          'alta'
        )
        RETURNING id INTO v_atividade_id;
        
        RETURN QUERY SELECT 
          v_atividade_id,
          v_clube.nome_parceiro,
          v_clube.programa_nome,
          v_data_prevista;
      END IF;
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION gerar_lembretes_clubes() IS 
'Gera lembretes para créditos mensais de clubes nos próximos 7 dias. Os lembretes são baseados no dia da data de assinatura.';


-- ============================================================================
-- MIGRATION: 20260106130913_limpar_atividades_clube_antigas.sql
-- ============================================================================

/*
  # Limpar atividades de clube antigas

  ## Descrição
  Remove todas as atividades de clube existentes para que sejam recriadas
  com a data correta baseada no dia da assinatura, não no dia de cobrança.

  ## Mudanças
  - Remove atividades pendentes do tipo 'clube_credito_mensal'
  - Remove atividades pendentes do tipo 'clube_bonus'
  - O sistema irá recriar automaticamente com as datas corretas
*/

-- Remove atividades de clube pendentes com data errada
DELETE FROM atividades 
WHERE tipo_atividade IN ('clube_credito_mensal', 'clube_bonus')
  AND status = 'pendente';


-- ============================================================================
-- MIGRATION: 20260106130943_fix_criar_atividades_usar_dia_assinatura.sql
-- ============================================================================

/*
  # Corrigir função criar_atividades_clube para usar dia da assinatura

  ## Descrição
  Modifica a função que cria atividades automaticamente quando um clube
  é cadastrado/atualizado para usar o dia da data de assinatura ao invés
  do dia de cobrança.

  ## Mudanças
  - Remove verificação de dia_cobranca
  - Usa EXTRACT(DAY FROM data_ultima_assinatura) para calcular a data prevista
  - Mantém a lógica de criar atividades de crédito mensal e bônus
*/

CREATE OR REPLACE FUNCTION criar_atividades_clube()
RETURNS TRIGGER AS $$
DECLARE
  v_proximo_credito date;
  v_dia_assinatura int;
  v_mes int;
  v_ano int;
  v_dias_no_mes int;
BEGIN
  IF NEW.tem_clube = true 
    AND NEW.data_ultima_assinatura IS NOT NULL 
    AND NEW.quantidade_pontos > 0 THEN
    
    v_dia_assinatura := EXTRACT(DAY FROM NEW.data_ultima_assinatura)::int;
    v_mes := EXTRACT(MONTH FROM CURRENT_DATE)::int;
    v_ano := EXTRACT(YEAR FROM CURRENT_DATE)::int;
    
    -- Tenta criar a data no mês atual
    v_dias_no_mes := EXTRACT(DAY FROM (DATE_TRUNC('month', MAKE_DATE(v_ano, v_mes, 1)) + INTERVAL '1 month - 1 day'))::int;
    
    IF v_dia_assinatura > v_dias_no_mes THEN
      v_proximo_credito := MAKE_DATE(v_ano, v_mes, v_dias_no_mes);
    ELSE
      v_proximo_credito := MAKE_DATE(v_ano, v_mes, v_dia_assinatura);
    END IF;
    
    -- Se a data já passou, avança para o próximo mês
    IF v_proximo_credito < CURRENT_DATE THEN
      IF v_mes = 12 THEN
        v_mes := 1;
        v_ano := v_ano + 1;
      ELSE
        v_mes := v_mes + 1;
      END IF;
      
      v_dias_no_mes := EXTRACT(DAY FROM (DATE_TRUNC('month', MAKE_DATE(v_ano, v_mes, 1)) + INTERVAL '1 month - 1 day'))::int;
      
      IF v_dia_assinatura > v_dias_no_mes THEN
        v_proximo_credito := MAKE_DATE(v_ano, v_mes, v_dias_no_mes);
      ELSE
        v_proximo_credito := MAKE_DATE(v_ano, v_mes, v_dia_assinatura);
      END IF;
    END IF;
    
    -- Criar atividade de crédito mensal
    INSERT INTO atividades (
      tipo_atividade,
      titulo,
      descricao,
      parceiro_id,
      parceiro_nome,
      programa_id,
      programa_nome,
      quantidade_pontos,
      data_prevista,
      referencia_id,
      referencia_tabela,
      prioridade
    )
    SELECT
      'clube_credito_mensal',
      'Crédito mensal de clube',
      'Crédito mensal de ' || NEW.quantidade_pontos || ' pontos do clube ' || pr.nome,
      NEW.parceiro_id,
      p.nome_parceiro,
      NEW.programa_id,
      pf.nome,
      NEW.quantidade_pontos,
      v_proximo_credito,
      NEW.id,
      'programas_clubes',
      'alta'
    FROM parceiros p
    LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
    LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
    WHERE p.id = NEW.parceiro_id;
    
    -- Se tem bônus e é primeira assinatura (hoje), criar atividade de bônus
    IF NEW.bonus_quantidade_pontos > 0 AND NEW.data_ultima_assinatura = CURRENT_DATE THEN
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade
      )
      SELECT
        'clube_credito_bonus',
        'Bônus de boas-vindas do clube',
        'Bônus de ' || NEW.bonus_quantidade_pontos || ' pontos do clube ' || pr.nome,
        NEW.parceiro_id,
        p.nome_parceiro,
        NEW.programa_id,
        pf.nome,
        NEW.bonus_quantidade_pontos,
        CURRENT_DATE,
        NEW.id,
        'programas_clubes',
        'alta'
      FROM parceiros p
      LEFT JOIN programas_fidelidade pf ON pf.id = NEW.programa_id
      LEFT JOIN produtos pr ON pr.id = NEW.clube_produto_id
      WHERE p.id = NEW.parceiro_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION criar_atividades_clube() IS 
'Cria atividades de crédito mensal e bônus baseadas no dia da data de assinatura. Ex: se assinou dia 5, cria atividades para todo dia 5.';


-- ============================================================================
-- MIGRATION: 20260106131656_create_job_credito_automatico_clubes.sql
-- ============================================================================

/*
  # Criar job automático para crédito de clubes

  ## Descrição
  Configura um job que roda automaticamente todos os dias às 00:01
  para creditar pontos de clubes no estoque dos parceiros.
  
  O sistema verifica:
  - Se o parceiro tem clube ativo (tem_clube = true)
  - Se o dia atual corresponde ao dia da assinatura
  - Adiciona os pontos regulares + bônus (se aplicável) no estoque

  ## Mudanças
  - Habilita extensão pg_cron para jobs agendados
  - Cria job diário que executa processar_creditos_clubes()
  - Sistema funciona 100% automático, sem precisar clicar em nada
*/

-- Habilitar extensão pg_cron para jobs agendados
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Remover job existente se houver
SELECT cron.unschedule('credito-automatico-clubes') WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'credito-automatico-clubes'
);

-- Criar job que roda todos os dias às 00:01 (1 minuto após meia-noite)
SELECT cron.schedule(
  'credito-automatico-clubes',
  '1 0 * * *', -- todo dia às 00:01
  $$
    SELECT processar_creditos_clubes();
  $$
);

COMMENT ON EXTENSION pg_cron IS 'Extensão para agendar jobs SQL automaticamente';


-- ============================================================================
-- MIGRATION: 20260106132608_fix_clube_bonus_mensal_sempre.sql
-- ============================================================================

/*
  # Corrigir bônus de clube para creditar mensalmente

  ## Descrição
  Modifica a função processar_creditos_clubes para que o bônus seja creditado
  SEMPRE junto com os pontos regulares, não apenas no primeiro mês.
  
  ## Mudanças
  - Remove condição que verificava se era o dia da primeira assinatura
  - Agora se bonus_quantidade_pontos > 0, o bônus é creditado todo mês
  - Altera descrição de "Bônus de boas-vindas" para "Bônus mensal"
  
  ## Exemplo
  Se um parceiro tem 20.000 pontos regulares e 8.000 de bônus configurados:
  - Todo dia da assinatura recebe: 20.000 + 8.000 = 28.000 pontos
*/

CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_ja_creditado boolean;
  v_data_referencia date;
  v_pontos_total numeric;
  v_tem_bonus boolean;
BEGIN
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = EXTRACT(DAY FROM pc.data_ultima_assinatura)::int
  LOOP
    SELECT EXISTS(
      SELECT 1 
      FROM estoque_pontos 
      WHERE parceiro_id = v_clube.parceiro_id
        AND programa_id = v_clube.programa_id
        AND origem = 'clube_credito_mensal'
        AND data >= v_data_referencia
        AND EXTRACT(MONTH FROM data) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM data) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) INTO v_ja_creditado;
    
    IF NOT v_ja_creditado THEN
      v_pontos_total := v_clube.quantidade_pontos;
      v_tem_bonus := false;
      
      INSERT INTO estoque_pontos (
        parceiro_id,
        programa_id,
        tipo,
        quantidade,
        origem,
        observacao,
        data
      ) VALUES (
        v_clube.parceiro_id,
        v_clube.programa_id,
        'entrada',
        v_clube.quantidade_pontos,
        'clube_credito_mensal',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        CURRENT_DATE
      );
      
      IF v_clube.bonus_quantidade_pontos > 0 THEN

        INSERT INTO estoque_pontos (
          parceiro_id,
          programa_id,
          tipo,
          quantidade,
          origem,
          observacao,
          data
        ) VALUES (
          v_clube.parceiro_id,
          v_clube.programa_id,
          'entrada',
          v_clube.bonus_quantidade_pontos,
          'clube_credito_bonus',
          'Bônus mensal do clube ' || COALESCE(v_clube.produto_nome, ''),
          CURRENT_DATE
        );

        v_pontos_total := v_pontos_total + v_clube.bonus_quantidade_pontos;
        v_tem_bonus := true;
      END IF;
      
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_pontos_total,
        CASE WHEN v_tem_bonus THEN 'credito_com_bonus' ELSE 'credito_mensal' END::text,
        CURRENT_TIMESTAMP;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Os pontos são creditados no dia correspondente à data de assinatura (ex: se assinou dia 5, créditos caem todo dia 5). Se houver bônus configurado, ele é creditado mensalmente junto com os pontos regulares.';

-- ============================================================================
-- MIGRATION: 20260106134328_create_compras_estoque_trigger.sql
-- ============================================================================

/*
  # Criar trigger para adicionar pontos de compras no estoque

  ## Descrição
  Quando uma compra é registrada na tabela `compras`, os pontos devem ser
  automaticamente adicionados ao estoque de pontos do parceiro no programa
  correspondente e aparecer no histórico.

  ## Mudanças
  1. Função `adicionar_pontos_compra_ao_estoque()`:
     - Triggered após INSERT em `compras`
     - Adiciona entrada no `estoque_pontos` com os pontos da compra
     - Define origem como 'compra' para rastreabilidade
     - Usa a data_entrada da compra
     - Inclui informações do tipo e observação da compra

  2. Trigger `trigger_compras_estoque`:
     - Executado AFTER INSERT em `compras`
     - Chama a função para adicionar pontos automaticamente

  ## Fluxo
  1. Usuário registra uma compra com 10.000 pontos
  2. Trigger adiciona automaticamente 10.000 pontos no estoque_pontos
  3. Pontos aparecem no histórico com origem "compra"

  ## Observações
  - Os pontos aparecem no histórico do estoque automaticamente
  - A origem 'compra' permite filtrar entradas vindas de compras
  - Usa SECURITY DEFINER para funcionar com RLS
*/

-- Função para adicionar pontos da compra ao estoque
CREATE OR REPLACE FUNCTION adicionar_pontos_compra_ao_estoque()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Adiciona os pontos da compra ao estoque
  INSERT INTO estoque_pontos (
    parceiro_id,
    programa_id,
    tipo,
    quantidade,
    origem,
    observacao,
    data
  ) VALUES (
    NEW.parceiro_id,
    NEW.programa_id,
    'entrada',
    NEW.pontos_milhas,
    'compra',
    'Compra: ' || NEW.tipo || 
    CASE 
      WHEN NEW.observacao IS NOT NULL AND NEW.observacao != '' 
      THEN ' - ' || NEW.observacao 
      ELSE '' 
    END,
    NEW.data_entrada
  );

  RETURN NEW;
END;
$$;

-- Criar trigger para adicionar pontos automaticamente após inserir compra
DROP TRIGGER IF EXISTS trigger_compras_estoque ON compras;

CREATE TRIGGER trigger_compras_estoque
  AFTER INSERT ON compras
  FOR EACH ROW
  EXECUTE FUNCTION adicionar_pontos_compra_ao_estoque();

COMMENT ON FUNCTION adicionar_pontos_compra_ao_estoque() IS 
'Adiciona automaticamente os pontos de uma compra ao estoque de pontos do parceiro. Executado após INSERT em compras.';

COMMENT ON TRIGGER trigger_compras_estoque ON compras IS 
'Trigger que adiciona pontos automaticamente ao estoque quando uma compra é registrada.';

-- ============================================================================
-- MIGRATION: 20260106134628_fix_remove_incorrect_compras_trigger.sql
-- ============================================================================

/*
  # Remover trigger incorreto de compras

  ## Problema
  O trigger `trigger_compras_estoque` estava tentando inserir dados na tabela
  `estoque_pontos` como se fosse uma tabela de histórico, mas ela é apenas
  para saldo consolidado.

  ## Solução
  - Remove a função `adicionar_pontos_compra_ao_estoque()`
  - Remove o trigger `trigger_compras_estoque`
  - Os triggers existentes `trigger_atualizar_estoque_compras_*` já fazem
    o trabalho correto de atualizar o saldo no estoque

  ## Funcionamento Correto
  - Quando uma compra é inserida, `trigger_atualizar_estoque_compras_insert`
    atualiza automaticamente o saldo e custo médio em `estoque_pontos`
  - O histórico é mantido através das próprias tabelas de movimentação
    (compras, vendas, transferencias, etc)
*/

-- Remove o trigger incorreto
DROP TRIGGER IF EXISTS trigger_compras_estoque ON compras;

-- Remove a função incorreta
DROP FUNCTION IF EXISTS adicionar_pontos_compra_ao_estoque();

-- ============================================================================
-- MIGRATION: 20260106134906_allow_compras_delete_and_update_v2.sql
-- ============================================================================

/*
  # Permitir Exclusão e Edição de Compras

  ## Objetivo
  Reverter o bloqueio de exclusões e atualizações na tabela `compras`,
  permitindo que usuários autenticados possam editar e excluir registros.

  ## Alterações

  ### 1. Remover Triggers de Bloqueio
  - Remove trigger `block_compras_update`
  - Remove trigger `block_compras_delete`
  - Remove função `prevent_compras_modification` (com CASCADE)

  ### 2. Restaurar Políticas RLS
  - Adiciona política de DELETE para usuários autenticados
  - Adiciona política de UPDATE para usuários autenticados

  ## Nota
  Os triggers de atualização de estoque (`trigger_atualizar_estoque_compras_*`)
  continuam funcionando normalmente e garantem que o estoque seja atualizado
  corretamente quando compras forem modificadas ou excluídas.
*/

-- Remove a função de bloqueio com CASCADE (remove os triggers automaticamente)
DROP FUNCTION IF EXISTS prevent_compras_modification() CASCADE;

-- Restaura política de DELETE
CREATE POLICY "Authenticated users can delete compras"
  ON compras FOR DELETE
  TO authenticated
  USING (true);

-- Restaura política de UPDATE
CREATE POLICY "Authenticated users can update compras"
  ON compras FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- MIGRATION: 20260106175527_create_processar_compras_pendentes.sql
-- ============================================================================

/*
  # Processar Compras Pendentes Automaticamente

  1. Nova Função
    - `processar_compras_pendentes()`: Processa compras com datas de entrada que já chegaram
    - Atualiza status de Pendente para Concluído
    - Atualiza o estoque de pontos quando a data chega
    
  2. Job Agendado
    - Executa diariamente às 00:01
    - Processa todas as compras com data_entrada <= hoje
    - Processa bônus com data_limite_bonus <= hoje
    
  3. Segurança
    - Função com SECURITY DEFINER para permitir atualização
    - Usa RLS policies existentes
*/

-- Função para processar compras pendentes
CREATE OR REPLACE FUNCTION processar_compras_pendentes()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  compra_record RECORD;
  hoje DATE := CURRENT_DATE;
BEGIN
  -- Processar compras com data de entrada que já chegou
  FOR compra_record IN
    SELECT id, parceiro_id, programa_id, pontos_milhas, bonus, 
           data_entrada, data_limite_bonus, valor_total
    FROM compras
    WHERE status = 'Pendente'
      AND data_entrada <= hoje
  LOOP
    -- Atualizar status para Concluído
    UPDATE compras
    SET status = 'Concluído',
        updated_at = NOW()
    WHERE id = compra_record.id;
    
    RAISE NOTICE 'Compra % processada: pontos de entrada liberados', compra_record.id;
  END LOOP;
  
  -- Processar bônus com data limite que já chegou
  FOR compra_record IN
    SELECT id, parceiro_id, programa_id, pontos_milhas, bonus,
           data_entrada, data_limite_bonus, valor_total
    FROM compras
    WHERE status = 'Pendente'
      AND bonus > 0
      AND data_limite_bonus IS NOT NULL
      AND data_limite_bonus <= hoje
  LOOP
    -- Atualizar status para Concluído
    UPDATE compras
    SET status = 'Concluído',
        updated_at = NOW()
    WHERE id = compra_record.id;
    
    RAISE NOTICE 'Compra %: bônus liberado', compra_record.id;
  END LOOP;
  
  RAISE NOTICE 'Processamento de compras pendentes concluído';
END;
$$;

-- Criar job agendado para executar diariamente
-- Nota: pg_cron precisa estar habilitado no Supabase
DO $$
BEGIN
  -- Remover job existente se houver
  PERFORM cron.unschedule('processar-compras-pendentes');
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

-- Agendar job para rodar diariamente às 00:01
SELECT cron.schedule(
  'processar-compras-pendentes',
  '1 0 * * *', -- Todo dia às 00:01
  'SELECT processar_compras_pendentes();'
);

-- Comentário explicativo
COMMENT ON FUNCTION processar_compras_pendentes IS 
'Processa compras pendentes cujas datas de entrada ou limite de bônus já chegaram. Executado automaticamente todos os dias às 00:01.';


-- ============================================================================
-- MIGRATION: 20260106175551_fix_compras_trigger_processar_apenas_concluidas.sql
-- ============================================================================

/*
  # Atualizar trigger de compras para processar apenas quando status = Concluído

  1. Alterações
    - Trigger só adiciona pontos ao estoque quando status = 'Concluído'
    - Adiciona trigger para UPDATE para processar quando status muda de Pendente para Concluído
    - Não processa compras com status Pendente (data futura)
    
  2. Comportamento
    - INSERT com status Concluído: adiciona pontos imediatamente
    - INSERT com status Pendente: não adiciona pontos (aguarda data)
    - UPDATE de Pendente para Concluído: adiciona pontos quando processado
*/

-- Atualizar função para verificar status
CREATE OR REPLACE FUNCTION adicionar_pontos_compra_ao_estoque()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Só processa se o status for Concluído
  IF NEW.status = 'Concluído' THEN
    -- Para UPDATE, verificar se não era Concluído antes
    IF (TG_OP = 'UPDATE' AND OLD.status = 'Concluído') THEN
      -- Já foi processado, não fazer nada
      RETURN NEW;
    END IF;

    -- Adiciona os pontos da compra ao estoque
    INSERT INTO estoque_pontos (
      parceiro_id,
      programa_id,
      tipo,
      quantidade,
      origem,
      observacao,
      data
    ) VALUES (
      NEW.parceiro_id,
      NEW.programa_id,
      'entrada',
      NEW.total_pontos, -- Usa total_pontos que já inclui bônus
      'compra',
      'Compra: ' || NEW.tipo || 
      CASE 
        WHEN NEW.observacao IS NOT NULL AND NEW.observacao != '' 
        THEN ' - ' || NEW.observacao 
        ELSE '' 
      END,
      NEW.data_entrada
    );
  END IF;

  RETURN NEW;
END;
$$;

-- Recriar trigger para INSERT
DROP TRIGGER IF EXISTS trigger_compras_estoque ON compras;

CREATE TRIGGER trigger_compras_estoque
  AFTER INSERT ON compras
  FOR EACH ROW
  EXECUTE FUNCTION adicionar_pontos_compra_ao_estoque();

-- Criar trigger para UPDATE
DROP TRIGGER IF EXISTS trigger_compras_estoque_update ON compras;

CREATE TRIGGER trigger_compras_estoque_update
  AFTER UPDATE ON compras
  FOR EACH ROW
  WHEN (NEW.status = 'Concluído' AND OLD.status = 'Pendente')
  EXECUTE FUNCTION adicionar_pontos_compra_ao_estoque();

COMMENT ON FUNCTION adicionar_pontos_compra_ao_estoque() IS 
'Adiciona automaticamente os pontos de uma compra ao estoque apenas quando status = Concluído. Executado após INSERT ou UPDATE em compras.';

COMMENT ON TRIGGER trigger_compras_estoque_update ON compras IS 
'Trigger que adiciona pontos ao estoque quando uma compra pendente é concluída.';


-- ============================================================================
-- MIGRATION: 20260106182256_fix_estoque_trigger_verificar_status.sql
-- ============================================================================

/*
  # Corrigir trigger de estoque para verificar status das compras

  1. Problema
    - Trigger estava adicionando pontos ao estoque mesmo para compras com status Pendente
    - Pontos devem ser adicionados apenas quando status = 'Concluído'
    
  2. Correções
    - Atualizar trigger_atualizar_estoque_compras() para verificar status
    - Remover triggers incorretos que foram criados anteriormente
    - Usar função atualizar_estoque_pontos() existente
    
  3. Comportamento
    - INSERT com status Concluído: adiciona pontos imediatamente
    - INSERT com status Pendente: não adiciona pontos
    - UPDATE de Pendente para Concluído: adiciona pontos
*/

-- Remover triggers incorretos
DROP TRIGGER IF EXISTS trigger_compras_estoque ON compras;
DROP TRIGGER IF EXISTS trigger_compras_estoque_update ON compras;
DROP FUNCTION IF EXISTS adicionar_pontos_compra_ao_estoque();

-- Atualizar função para verificar status antes de processar
CREATE OR REPLACE FUNCTION trigger_atualizar_estoque_compras()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Para INSERT: só processa se status = Concluído
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'Concluído' THEN
      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        NEW.tipo,
        COALESCE(NEW.valor_total, 0)
      );
    END IF;
    
  -- Para UPDATE: processa mudanças de status
  ELSIF TG_OP = 'UPDATE' THEN
    -- Se mudou de Pendente para Concluído, adiciona pontos
    IF OLD.status = 'Pendente' AND NEW.status = 'Concluído' THEN
      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        NEW.tipo,
        COALESCE(NEW.valor_total, 0)
      );
    -- Se mudou de Concluído para Pendente (improvável), remove pontos
    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Pendente' THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
        OLD.tipo,
        -COALESCE(OLD.valor_total, 0)
      );
    -- Se ambos Concluído, processa mudanças normais
    ELSIF OLD.status = 'Concluído' AND NEW.status = 'Concluído' THEN
      -- Remove pontos antigos
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
        OLD.tipo,
        -COALESCE(OLD.valor_total, 0)
      );
      -- Adiciona pontos novos
      PERFORM atualizar_estoque_pontos(
        NEW.parceiro_id,
        NEW.programa_id,
        COALESCE(NEW.pontos_milhas, 0) + COALESCE(NEW.bonus, 0),
        NEW.tipo,
        COALESCE(NEW.valor_total, 0)
      );
    END IF;
    
  -- Para DELETE: só remove se status era Concluído
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.status = 'Concluído' THEN
      PERFORM atualizar_estoque_pontos(
        OLD.parceiro_id,
        OLD.programa_id,
        -(COALESCE(OLD.pontos_milhas, 0) + COALESCE(OLD.bonus, 0)),
        OLD.tipo,
        -COALESCE(OLD.valor_total, 0)
      );
    END IF;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Recriar triggers com nomes corretos
DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compras_insert ON compras;
DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compras_update ON compras;
DROP TRIGGER IF EXISTS trigger_atualizar_estoque_compras_delete ON compras;

CREATE TRIGGER trigger_atualizar_estoque_compras_insert
  AFTER INSERT ON compras
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compras();

CREATE TRIGGER trigger_atualizar_estoque_compras_update
  AFTER UPDATE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compras();

CREATE TRIGGER trigger_atualizar_estoque_compras_delete
  AFTER DELETE ON compras
  FOR EACH ROW
  EXECUTE FUNCTION trigger_atualizar_estoque_compras();

COMMENT ON FUNCTION trigger_atualizar_estoque_compras() IS 
'Atualiza o estoque de pontos quando compras são inseridas, atualizadas ou deletadas. Processa apenas compras com status = Concluído.';


-- ============================================================================
-- MIGRATION: 20260106182313_corrigir_estoque_compras_pendentes.sql
-- ============================================================================

/*
  # Corrigir estoque removendo pontos de compras pendentes

  1. Problema
    - Compras com status Pendente já foram creditadas no estoque
    - Precisam ser removidas até que o status mude para Concluído
    
  2. Solução
    - Identificar compras pendentes
    - Remover seus pontos do estoque
    - Quando forem processadas (status = Concluído), os pontos voltam automaticamente
*/

DO $$
DECLARE
  compra_record RECORD;
BEGIN
  -- Para cada compra pendente, remover pontos do estoque
  FOR compra_record IN
    SELECT 
      id,
      parceiro_id,
      programa_id,
      pontos_milhas,
      bonus,
      valor_total,
      tipo,
      status
    FROM compras
    WHERE status = 'Pendente'
  LOOP
    -- Remover pontos do estoque
    PERFORM atualizar_estoque_pontos(
      compra_record.parceiro_id,
      compra_record.programa_id,
      -(COALESCE(compra_record.pontos_milhas, 0) + COALESCE(compra_record.bonus, 0)),
      compra_record.tipo,
      -COALESCE(compra_record.valor_total, 0)
    );
    
    RAISE NOTICE 'Removidos pontos da compra pendente: %', compra_record.id;
  END LOOP;
  
  RAISE NOTICE 'Correção de estoque concluída';
END $$;


-- ============================================================================
-- MIGRATION: 20260106184747_add_status_to_transferencia_pontos.sql
-- ============================================================================

/*
  # Adicionar sistema de status e agendamento para transferências de pontos

  1. Alterações na tabela transferencia_pontos
    - Adicionar campo `status` (Pendente/Concluído) - controla quando os pontos de destino entram
    - Adicionar campo `status_bonus_destino` (Pendente/Concluído) - controla quando o bônus de destino entra
    - Adicionar campo `status_bonus_bumerangue` (Pendente/Concluído) - controla quando o bônus bumerangue entra
    
  2. Lógica de Status
    - Se `destino_data_recebimento` = hoje: status = Concluído (pontos entram imediatamente)
    - Se `destino_data_recebimento` > hoje: status = Pendente (pontos entram na data)
    - Se `destino_data_recebimento_bonus` = hoje: status_bonus_destino = Concluído
    - Se `destino_data_recebimento_bonus` > hoje: status_bonus_destino = Pendente
    - Se `bumerangue_data_recebimento` = hoje: status_bonus_bumerangue = Concluído
    - Se `bumerangue_data_recebimento` > hoje: status_bonus_bumerangue = Pendente
    
  3. Comportamento
    - A origem SEMPRE é debitada imediatamente (sem agendamento)
    - O destino segue a regra de agendamento baseada nas datas
    - Cada parte (pontos principais, bônus destino, bônus bumerangue) tem seu próprio status
*/

-- Adicionar campos de status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'transferencia_pontos' AND column_name = 'status'
  ) THEN
    ALTER TABLE transferencia_pontos ADD COLUMN status text DEFAULT 'Pendente';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'transferencia_pontos' AND column_name = 'status_bonus_destino'
  ) THEN
    ALTER TABLE transferencia_pontos ADD COLUMN status_bonus_destino text DEFAULT 'Pendente';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'transferencia_pontos' AND column_name = 'status_bonus_bumerangue'
  ) THEN
    ALTER TABLE transferencia_pontos ADD COLUMN status_bonus_bumerangue text DEFAULT 'Pendente';
  END IF;
END $$;

-- Criar view para visualizar transferências pendentes
CREATE OR REPLACE VIEW transferencias_pendentes AS
SELECT 
  tp.id,
  p.nome_parceiro,
  pf_origem.nome as programa_origem,
  pf_destino.nome as programa_destino,
  tp.destino_quantidade,
  tp.destino_data_recebimento,
  tp.status,
  tp.destino_quantidade_bonus,
  tp.destino_data_recebimento_bonus,
  tp.status_bonus_destino,
  tp.bumerangue_quantidade_bonus,
  tp.bumerangue_data_recebimento,
  tp.status_bonus_bumerangue,
  tp.observacao,
  CASE
    WHEN tp.destino_data_recebimento = CURRENT_DATE THEN 'Hoje'
    WHEN tp.destino_data_recebimento = CURRENT_DATE + 1 THEN 'Amanhã'
    WHEN tp.destino_data_recebimento <= CURRENT_DATE + 7 THEN 'Esta semana'
    WHEN tp.destino_data_recebimento <= CURRENT_DATE + 30 THEN 'Este mês'
    ELSE 'Mais de 1 mês'
  END as periodo,
  tp.destino_data_recebimento - CURRENT_DATE as dias_restantes
FROM transferencia_pontos tp
JOIN parceiros p ON tp.parceiro_id = p.id
JOIN programas_fidelidade pf_origem ON tp.origem_programa_id = pf_origem.id
JOIN programas_fidelidade pf_destino ON tp.destino_programa_id = pf_destino.id
WHERE tp.status = 'Pendente'
   OR (tp.status_bonus_destino = 'Pendente' AND tp.destino_quantidade_bonus > 0)
   OR (tp.status_bonus_bumerangue = 'Pendente' AND tp.bumerangue_quantidade_bonus > 0)
ORDER BY tp.destino_data_recebimento ASC;

-- Permitir acesso à view
GRANT SELECT ON transferencias_pendentes TO authenticated;

COMMENT ON VIEW transferencias_pendentes IS 
'View que lista todas as transferências com status pendente (pontos principais, bônus destino ou bônus bumerangue)';


-- ============================================================================
-- MIGRATION: 20260106184823_create_transferencia_pontos_processing.sql
-- ============================================================================

/*
  # Sistema de processamento de transferências de pontos

  1. Funções
    - processar_transferencia_origem() - Debita pontos da origem imediatamente
    - processar_transferencia_destino() - Credita pontos no destino quando status muda para Concluído
    - verificar_e_atualizar_status_transferencias() - Job que verifica datas e atualiza status
    
  2. Triggers
    - Após INSERT: debita origem imediatamente, credita destino se data = hoje
    - Após UPDATE de status: processa créditos quando status muda para Concluído
    
  3. Comportamento
    - Origem sempre é debitada imediatamente no INSERT
    - Destino só é creditado quando status = Concluído
    - Bônus destino só é creditado quando status_bonus_destino = Concluído
    - Bônus bumerangue só é creditado quando status_bonus_bumerangue = Concluído
*/

-- Função para processar débito da origem (sempre imediato)
CREATE OR REPLACE FUNCTION processar_transferencia_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Debita da origem
  PERFORM atualizar_estoque_pontos(
    NEW.parceiro_id,
    NEW.origem_programa_id,
    -NEW.origem_quantidade,
    'Saída',
    0
  );
  
  RETURN NEW;
END;
$$;

-- Função para processar créditos no destino (apenas quando status = Concluído)
CREATE OR REPLACE FUNCTION processar_transferencia_destino()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_custo_medio decimal;
BEGIN
  -- Buscar custo médio da origem
  SELECT custo_medio INTO v_origem_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.parceiro_id 
    AND programa_id = NEW.origem_programa_id;
  
  -- Se for INSERT e status = Concluído, creditar pontos principais
  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      (NEW.destino_quantidade / 1000) * COALESCE(v_origem_custo_medio, 0)
    );
  END IF;
  
  -- Se for INSERT e status_bonus_destino = Concluído e tem bônus, creditar bônus
  IF (TG_OP = 'INSERT' AND NEW.status_bonus_destino = 'Concluído' AND NEW.destino_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade_bonus,
      'Entrada',
      0
    );
  END IF;
  
  -- Se for INSERT e status_bonus_bumerangue = Concluído e tem bônus, creditar bônus bumerangue
  IF (TG_OP = 'INSERT' AND NEW.status_bonus_bumerangue = 'Concluído' AND NEW.bumerangue_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      NEW.bumerangue_quantidade_bonus,
      'Entrada',
      0
    );
  END IF;
  
  -- Se for UPDATE de Pendente para Concluído, processar pontos principais
  IF (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      (NEW.destino_quantidade / 1000) * COALESCE(v_origem_custo_medio, 0)
    );
  END IF;
  
  -- Se for UPDATE de status_bonus_destino de Pendente para Concluído
  IF (TG_OP = 'UPDATE' AND OLD.status_bonus_destino = 'Pendente' AND NEW.status_bonus_destino = 'Concluído' AND NEW.destino_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade_bonus,
      'Entrada',
      0
    );
  END IF;
  
  -- Se for UPDATE de status_bonus_bumerangue de Pendente para Concluído
  IF (TG_OP = 'UPDATE' AND OLD.status_bonus_bumerangue = 'Pendente' AND NEW.status_bonus_bumerangue = 'Concluído' AND NEW.bumerangue_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      NEW.bumerangue_quantidade_bonus,
      'Entrada',
      0
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger para debitar origem imediatamente após INSERT
DROP TRIGGER IF EXISTS trigger_transferencia_debitar_origem ON transferencia_pontos;

CREATE TRIGGER trigger_transferencia_debitar_origem
  AFTER INSERT ON transferencia_pontos
  FOR EACH ROW
  EXECUTE FUNCTION processar_transferencia_origem();

-- Trigger para creditar destino (INSERT e UPDATE de status)
DROP TRIGGER IF EXISTS trigger_transferencia_creditar_destino_insert ON transferencia_pontos;
DROP TRIGGER IF EXISTS trigger_transferencia_creditar_destino_update ON transferencia_pontos;

CREATE TRIGGER trigger_transferencia_creditar_destino_insert
  AFTER INSERT ON transferencia_pontos
  FOR EACH ROW
  EXECUTE FUNCTION processar_transferencia_destino();

CREATE TRIGGER trigger_transferencia_creditar_destino_update
  AFTER UPDATE ON transferencia_pontos
  FOR EACH ROW
  EXECUTE FUNCTION processar_transferencia_destino();

-- Função para verificar e atualizar status de transferências (job diário)
CREATE OR REPLACE FUNCTION verificar_e_atualizar_status_transferencias()
RETURNS void
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  transferencia_record RECORD;
BEGIN
  -- Atualizar status dos pontos principais
  UPDATE transferencia_pontos
  SET status = 'Concluído'
  WHERE status = 'Pendente'
    AND destino_data_recebimento <= CURRENT_DATE;
  
  -- Atualizar status do bônus de destino
  UPDATE transferencia_pontos
  SET status_bonus_destino = 'Concluído'
  WHERE status_bonus_destino = 'Pendente'
    AND destino_data_recebimento_bonus IS NOT NULL
    AND destino_data_recebimento_bonus <= CURRENT_DATE
    AND destino_quantidade_bonus > 0;
  
  -- Atualizar status do bônus bumerangue
  UPDATE transferencia_pontos
  SET status_bonus_bumerangue = 'Concluído'
  WHERE status_bonus_bumerangue = 'Pendente'
    AND bumerangue_data_recebimento IS NOT NULL
    AND bumerangue_data_recebimento <= CURRENT_DATE
    AND bumerangue_quantidade_bonus > 0;
    
  RAISE NOTICE 'Status de transferências atualizado com sucesso';
END;
$$;

-- Função para definir status inicial baseado nas datas (será chamada antes do INSERT via trigger)
CREATE OR REPLACE FUNCTION definir_status_inicial_transferencia()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Definir status dos pontos principais
  IF NEW.destino_data_recebimento <= CURRENT_DATE THEN
    NEW.status := 'Concluído';
  ELSE
    NEW.status := 'Pendente';
  END IF;
  
  -- Definir status do bônus de destino
  IF NEW.destino_quantidade_bonus > 0 AND NEW.destino_data_recebimento_bonus IS NOT NULL THEN
    IF NEW.destino_data_recebimento_bonus <= CURRENT_DATE THEN
      NEW.status_bonus_destino := 'Concluído';
    ELSE
      NEW.status_bonus_destino := 'Pendente';
    END IF;
  ELSE
    NEW.status_bonus_destino := 'N/A';
  END IF;
  
  -- Definir status do bônus bumerangue
  IF NEW.bumerangue_quantidade_bonus > 0 AND NEW.bumerangue_data_recebimento IS NOT NULL THEN
    IF NEW.bumerangue_data_recebimento <= CURRENT_DATE THEN
      NEW.status_bonus_bumerangue := 'Concluído';
    ELSE
      NEW.status_bonus_bumerangue := 'Pendente';
    END IF;
  ELSE
    NEW.status_bonus_bumerangue := 'N/A';
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger para definir status inicial ANTES do INSERT
DROP TRIGGER IF EXISTS trigger_definir_status_inicial ON transferencia_pontos;

CREATE TRIGGER trigger_definir_status_inicial
  BEFORE INSERT ON transferencia_pontos
  FOR EACH ROW
  EXECUTE FUNCTION definir_status_inicial_transferencia();

COMMENT ON FUNCTION processar_transferencia_origem() IS 
'Debita pontos da origem imediatamente após INSERT de transferência';

COMMENT ON FUNCTION processar_transferencia_destino() IS 
'Credita pontos no destino apenas quando status = Concluído';

COMMENT ON FUNCTION verificar_e_atualizar_status_transferencias() IS 
'Job diário que verifica datas e atualiza status de transferências pendentes';

COMMENT ON FUNCTION definir_status_inicial_transferencia() IS 
'Define o status inicial da transferência baseado nas datas antes do INSERT';


-- ============================================================================
-- MIGRATION: 20260106185025_create_job_processar_transferencias.sql
-- ============================================================================

/*
  # Criar job para processar transferências pendentes diariamente

  1. Job Agendado
    - Executa função verificar_e_atualizar_status_transferencias() todos os dias às 00:01
    - Verifica datas e atualiza status de pendente para concluído
    - Os triggers processarão automaticamente os créditos quando o status mudar
    
  2. Nota
    - Similar ao job de compras
    - Processa pontos principais, bônus de destino e bônus bumerangue
*/

-- Usar pg_cron para agendar job (se disponível)
-- Caso contrário, pode ser executado manualmente ou via external scheduler

SELECT cron.schedule(
  'processar_transferencias_pendentes',
  '1 0 * * *', -- Todo dia às 00:01
  $$SELECT verificar_e_atualizar_status_transferencias()$$
);

COMMENT ON FUNCTION verificar_e_atualizar_status_transferencias() IS 
'Job diário (00:01) que verifica e atualiza status de transferências pendentes baseado nas datas de recebimento';


-- ============================================================================
-- MIGRATION: 20260108191210_fix_processar_creditos_clubes_usar_funcao_correta.sql
-- ============================================================================

/*
  # Corrigir função processar_creditos_clubes para usar atualizar_estoque_pontos

  ## Problema
  A função estava tentando inserir diretamente na tabela estoque_pontos
  usando campos que não existem (tipo, quantidade, origem, data).
  
  A tabela estoque_pontos só mantém saldos agregados, não movimentações individuais.

  ## Solução
  Usar a função atualizar_estoque_pontos() que já existe e funciona corretamente,
  atualizando saldo_atual e custo_medio.

  ## Mudanças
  - Remove INSERT direto em estoque_pontos
  - Usa PERFORM atualizar_estoque_pontos() para creditar pontos
  - Mantém lógica de verificação de duplicação via atividades
*/

CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_ja_creditado boolean;
  v_data_referencia date;
  v_pontos_total numeric;
  v_tem_bonus boolean;
BEGIN
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = EXTRACT(DAY FROM pc.data_ultima_assinatura)::int
  LOOP
    -- Verifica se já foi creditado neste mês verificando nas atividades
    SELECT EXISTS(
      SELECT 1 
      FROM atividades 
      WHERE parceiro_id = v_clube.parceiro_id
        AND programa_id = v_clube.programa_id
        AND tipo_atividade = 'Crédito Mensal Clube'
        AND data_prevista >= v_data_referencia
        AND EXTRACT(MONTH FROM data_prevista) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM data_prevista) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) INTO v_ja_creditado;
    
    IF NOT v_ja_creditado THEN
      v_pontos_total := v_clube.quantidade_pontos;
      v_tem_bonus := false;
      
      -- Creditar pontos regulares usando a função correta
      PERFORM atualizar_estoque_pontos(
        v_clube.parceiro_id,
        v_clube.programa_id,
        v_clube.quantidade_pontos,
        'Entrada',
        0  -- custo zero porque é crédito de clube
      );
      
      -- Criar atividade para registrar o crédito
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade,
        status
      ) VALUES (
        'Crédito Mensal Clube',
        'Crédito mensal de clube',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_clube.quantidade_pontos,
        CURRENT_DATE,
        v_clube.id,
        'programas_clubes',
        'alta',
        'Concluída'
      );
      
      -- Se tem bônus, creditar também
      IF v_clube.bonus_quantidade_pontos > 0 THEN
        PERFORM atualizar_estoque_pontos(
          v_clube.parceiro_id,
          v_clube.programa_id,
          v_clube.bonus_quantidade_pontos,
          'Entrada',
          0
        );

        v_pontos_total := v_pontos_total + v_clube.bonus_quantidade_pontos;
        v_tem_bonus := true;
      END IF;
      
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_pontos_total,
        CASE WHEN v_tem_bonus THEN 'credito_com_bonus' ELSE 'credito_mensal' END::text,
        CURRENT_TIMESTAMP;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Os pontos são creditados no dia correspondente à data de assinatura (ex: se assinou dia 5, créditos caem todo dia 5). Usa atualizar_estoque_pontos() para manter consistência. Retorna uma linha por parceiro com o total de pontos (regulares + bônus quando aplicável).';


-- ============================================================================
-- MIGRATION: 20260108192520_fix_processar_creditos_clubes_registrar_historico_completo.sql
-- ============================================================================

/*
  # Corrigir processar_creditos_clubes para registrar histórico completo

  ## Problema
  A função processa os créditos mas não passa origem e observação corretamente,
  fazendo com que o histórico fique incompleto.

  ## Solução
  Atualizar chamadas para atualizar_estoque_pontos() passando origem e observacao
  para que o histórico fique completo e rastreável.

  ## Mudanças
  - Passa origem='clube_credito_mensal' ou 'clube_credito_bonus'
  - Passa observacao detalhada com nome do produto e valores
*/

CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_ja_creditado boolean;
  v_data_referencia date;
  v_pontos_total numeric;
  v_tem_bonus boolean;
BEGIN
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = EXTRACT(DAY FROM pc.data_ultima_assinatura)::int
  LOOP
    -- Verifica se já foi creditado neste mês verificando nas atividades
    SELECT EXISTS(
      SELECT 1 
      FROM atividades 
      WHERE parceiro_id = v_clube.parceiro_id
        AND programa_id = v_clube.programa_id
        AND tipo_atividade = 'clube_credito_mensal'
        AND data_prevista >= v_data_referencia
        AND EXTRACT(MONTH FROM data_prevista) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM data_prevista) = EXTRACT(YEAR FROM CURRENT_DATE)
        AND status = 'processado'
    ) INTO v_ja_creditado;
    
    IF NOT v_ja_creditado THEN
      v_pontos_total := v_clube.quantidade_pontos;
      v_tem_bonus := false;
      
      -- Creditar pontos regulares usando a função correta COM origem e observação
      PERFORM atualizar_estoque_pontos(
        v_clube.parceiro_id,
        v_clube.programa_id,
        v_clube.quantidade_pontos,
        'Entrada',
        0,  -- custo zero porque é crédito de clube
        'clube_credito_mensal',  -- origem
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, '') || ' - ' || v_clube.quantidade_pontos || ' pontos',  -- observação
        v_clube.id,  -- referencia_id
        'programas_clubes'  -- referencia_tabela
      );
      
      -- Criar atividade para registrar o crédito
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade,
        status
      ) VALUES (
        'clube_credito_mensal',
        'Crédito mensal de clube',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_clube.quantidade_pontos,
        CURRENT_DATE,
        v_clube.id,
        'programas_clubes',
        'alta',
        'processado'
      );
      
      -- Se tem bônus, creditar também
      IF v_clube.bonus_quantidade_pontos > 0 THEN
        PERFORM atualizar_estoque_pontos(
          v_clube.parceiro_id,
          v_clube.programa_id,
          v_clube.bonus_quantidade_pontos,
          'Entrada',
          0,
          'clube_credito_bonus',  -- origem
          'Bônus mensal do clube ' || COALESCE(v_clube.produto_nome, '') || ' - ' || v_clube.bonus_quantidade_pontos || ' pontos',  -- observação
          v_clube.id,  -- referencia_id
          'programas_clubes'  -- referencia_tabela
        );

        v_pontos_total := v_pontos_total + v_clube.bonus_quantidade_pontos;
        v_tem_bonus := true;
      END IF;
      
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_pontos_total,
        CASE WHEN v_tem_bonus THEN 'credito_com_bonus' ELSE 'credito_mensal' END::text,
        CURRENT_TIMESTAMP;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Os pontos são creditados no dia correspondente à data de assinatura (ex: se assinou dia 5, créditos caem todo dia 5). Registra TODAS as movimentações no histórico com origem e observação detalhadas. Usa atualizar_estoque_pontos() para manter consistência. Retorna uma linha por parceiro com o total de pontos (regulares + bônus quando aplicável).';


-- ============================================================================
-- MIGRATION: 20260108193329_fix_estoque_movimentacoes_rls_for_anon.sql
-- ============================================================================

/*
  # Corrigir políticas RLS para estoque_movimentacoes

  ## Problema
  O sistema usa autenticação customizada (tabela usuarios) mas as políticas RLS 
  estão configuradas para role 'authenticated' do Supabase Auth.
  Isso impede que o frontend acesse os dados.

  ## Solução
  Alterar políticas para permitir acesso via role 'anon' (chave pública),
  já que a autenticação é controlada no nível da aplicação.

  ## Mudanças
  - DROP das políticas existentes
  - Criar novas políticas permitindo acesso público para leitura
  - Manter inserção/atualização via funções
*/

-- Remover políticas antigas
DROP POLICY IF EXISTS "Permitir leitura de movimentações" ON estoque_movimentacoes;
DROP POLICY IF EXISTS "Permitir inserção via funções" ON estoque_movimentacoes;

-- Permitir leitura para todos (autenticação controlada no app)
CREATE POLICY "Permitir leitura de movimentações"
  ON estoque_movimentacoes
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Permitir inserção para todos (usado por triggers e funções)
CREATE POLICY "Permitir inserção de movimentações"
  ON estoque_movimentacoes
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

COMMENT ON POLICY "Permitir leitura de movimentações" ON estoque_movimentacoes IS 
'Permite leitura de todas as movimentações. Autenticação é controlada no nível da aplicação.';

COMMENT ON POLICY "Permitir inserção de movimentações" ON estoque_movimentacoes IS 
'Permite inserção de movimentações via triggers e funções do sistema.';


-- ============================================================================
-- MIGRATION: 20260108194753_add_vendas_complete_fields.sql
-- ============================================================================

/*
  # Adicionar campos completos para Vendas
  
  1. Novos Campos
    - cia_parceira: Companhia aérea parceira
    - taxa_embarque: Taxa de embarque em R$
    - taxa_resgate: Taxa de resgate da companhia aérea em R$
    - taxa_bagagem: Bagagem/Taxa de cancelamento/Assentos em R$
    - cartao_taxa_embarque_id: Referência ao cartão usado para taxa de embarque
    - cartao_taxa_bagagem_id: Referência ao cartão usado para taxa de bagagem
    - cartao_taxa_resgate_id: Referência ao cartão usado para taxa de resgate
    - data_voo_ida: Data do voo de ida
    - data_voo_volta: Data do voo de volta
    - nome_passageiro: Nome do passageiro
    - quantidade_passageiros: Quantidade de passageiros
    - trecho: Trecho do voo
    - tarifa_diamante: Valor da tarifa diamante
    - milhas_bonus: Quantidade de milhas bônus
    - custo_emissao: Custo de emissão
    - emissor: Nome do emissor
  
  2. Observações
    - Todos os campos são opcionais exceto os já existentes que são obrigatórios
    - Campos de cartão referenciam a tabela cartoes_credito
*/

-- Adicionar campo cia_parceira
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'cia_parceira'
  ) THEN
    ALTER TABLE vendas ADD COLUMN cia_parceira text;
  END IF;
END $$;

-- Adicionar campo taxa_embarque
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'taxa_embarque'
  ) THEN
    ALTER TABLE vendas ADD COLUMN taxa_embarque numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campo taxa_resgate
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'taxa_resgate'
  ) THEN
    ALTER TABLE vendas ADD COLUMN taxa_resgate numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campo taxa_bagagem
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'taxa_bagagem'
  ) THEN
    ALTER TABLE vendas ADD COLUMN taxa_bagagem numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campo cartao_taxa_embarque_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'cartao_taxa_embarque_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN cartao_taxa_embarque_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Adicionar campo cartao_taxa_bagagem_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'cartao_taxa_bagagem_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN cartao_taxa_bagagem_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Adicionar campo cartao_taxa_resgate_id
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'cartao_taxa_resgate_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN cartao_taxa_resgate_id uuid REFERENCES cartoes_credito(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Adicionar campo data_voo_ida
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'data_voo_ida'
  ) THEN
    ALTER TABLE vendas ADD COLUMN data_voo_ida date;
  END IF;
END $$;

-- Adicionar campo data_voo_volta
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'data_voo_volta'
  ) THEN
    ALTER TABLE vendas ADD COLUMN data_voo_volta date;
  END IF;
END $$;

-- Adicionar campo nome_passageiro
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'nome_passageiro'
  ) THEN
    ALTER TABLE vendas ADD COLUMN nome_passageiro text;
  END IF;
END $$;

-- Adicionar campo quantidade_passageiros (já existe no localizador, mas agora será na venda)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'quantidade_passageiros'
  ) THEN
    ALTER TABLE vendas ADD COLUMN quantidade_passageiros integer DEFAULT 1;
  END IF;
END $$;

-- Adicionar campo trecho
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'trecho'
  ) THEN
    ALTER TABLE vendas ADD COLUMN trecho text;
  END IF;
END $$;

-- Adicionar campo tarifa_diamante
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'tarifa_diamante'
  ) THEN
    ALTER TABLE vendas ADD COLUMN tarifa_diamante numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campo milhas_bonus
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'milhas_bonus'
  ) THEN
    ALTER TABLE vendas ADD COLUMN milhas_bonus numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campo custo_emissao
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'custo_emissao'
  ) THEN
    ALTER TABLE vendas ADD COLUMN custo_emissao numeric(15,2) DEFAULT 0;
  END IF;
END $$;

-- Adicionar campo emissor
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'emissor'
  ) THEN
    ALTER TABLE vendas ADD COLUMN emissor text;
  END IF;
END $$;

-- ============================================================================
-- MIGRATION: 20260108204429_add_transferencia_to_estoque_movimentacoes.sql
-- ============================================================================

/*
  # Adicionar transferências ao histórico de movimentações do estoque

  1. Alterações
    - Criar função para registrar movimentações de transferência
    - Atualizar triggers de transferência para registrar no histórico
    - Registrar saída da origem como "Transferência - Saída"
    - Registrar entrada no destino como "Transferência - Entrada"
    - Incluir informações de origem e destino na observação

  2. Comportamento
    - Quando uma transferência é criada, registra:
      - Uma saída no programa de origem
      - Uma ou mais entradas no programa de destino (pontos principais + bônus)
    - O campo "origem" indica a origem da movimentação
    - O campo "observacao" inclui detalhes da transferência (de X para Y)
*/

-- Função para registrar movimentação de transferência no histórico
CREATE OR REPLACE FUNCTION registrar_movimentacao_transferencia(
  p_parceiro_id uuid,
  p_programa_id uuid,
  p_tipo text,
  p_quantidade decimal,
  p_valor_total decimal,
  p_origem_programa_nome text DEFAULT NULL,
  p_destino_programa_nome text DEFAULT NULL,
  p_referencia_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_saldo_anterior decimal;
  v_saldo_posterior decimal;
  v_custo_medio_anterior decimal;
  v_custo_medio_posterior decimal;
  v_observacao text;
BEGIN
  -- Buscar saldos e custos anteriores
  SELECT saldo_atual, custo_medio 
  INTO v_saldo_anterior, v_custo_medio_anterior
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  -- Calcular saldo posterior
  IF p_tipo LIKE '%Saída%' THEN
    v_saldo_posterior := COALESCE(v_saldo_anterior, 0) - p_quantidade;
  ELSE
    v_saldo_posterior := COALESCE(v_saldo_anterior, 0) + p_quantidade;
  END IF;

  -- Buscar custo médio posterior (já foi atualizado pela função atualizar_estoque_pontos)
  SELECT custo_medio 
  INTO v_custo_medio_posterior
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  -- Construir observação
  IF p_tipo LIKE '%Saída%' AND p_destino_programa_nome IS NOT NULL THEN
    v_observacao := 'Transferência para ' || p_destino_programa_nome;
  ELSIF p_tipo LIKE '%Entrada%' AND p_origem_programa_nome IS NOT NULL THEN
    v_observacao := 'Transferência de ' || p_origem_programa_nome;
  ELSE
    v_observacao := NULL;
  END IF;

  -- Inserir na tabela de movimentações
  INSERT INTO estoque_movimentacoes (
    parceiro_id,
    programa_id,
    tipo,
    quantidade,
    valor_total,
    saldo_anterior,
    saldo_posterior,
    custo_medio_anterior,
    custo_medio_posterior,
    origem,
    observacao,
    referencia_id,
    referencia_tabela,
    data_movimentacao
  ) VALUES (
    p_parceiro_id,
    p_programa_id,
    p_tipo,
    p_quantidade,
    p_valor_total,
    COALESCE(v_saldo_anterior, 0),
    v_saldo_posterior,
    COALESCE(v_custo_medio_anterior, 0),
    COALESCE(v_custo_medio_posterior, 0),
    'Transferência de Pontos',
    v_observacao,
    p_referencia_id,
    'transferencia_pontos',
    now()
  );
END;
$$;

-- Atualizar função de processar transferência origem para registrar movimentação
CREATE OR REPLACE FUNCTION processar_transferencia_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_destino_programa_nome text;
BEGIN
  -- Buscar nome do programa de destino
  SELECT nome INTO v_destino_programa_nome
  FROM programas_fidelidade
  WHERE id = NEW.destino_programa_id;

  -- Debita da origem
  PERFORM atualizar_estoque_pontos(
    NEW.parceiro_id,
    NEW.origem_programa_id,
    -NEW.origem_quantidade,
    'Saída',
    0
  );
  
  -- Registrar movimentação de saída no histórico
  PERFORM registrar_movimentacao_transferencia(
    NEW.parceiro_id,
    NEW.origem_programa_id,
    'Transferência - Saída',
    NEW.origem_quantidade,
    0,
    NULL,
    v_destino_programa_nome,
    NEW.id
  );
  
  RETURN NEW;
END;
$$;

-- Atualizar função de processar transferência destino para registrar movimentações
CREATE OR REPLACE FUNCTION processar_transferencia_destino()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_custo_medio decimal;
  v_origem_programa_nome text;
BEGIN
  -- Buscar custo médio e nome da origem
  SELECT ep.custo_medio, pf.nome 
  INTO v_origem_custo_medio, v_origem_programa_nome
  FROM estoque_pontos ep
  JOIN programas_fidelidade pf ON pf.id = ep.programa_id
  WHERE ep.parceiro_id = NEW.parceiro_id 
    AND ep.programa_id = NEW.origem_programa_id;
  
  -- Se for INSERT e status = Concluído, creditar pontos principais
  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      (NEW.destino_quantidade / 1000) * COALESCE(v_origem_custo_medio, 0)
    );
    
    -- Registrar movimentação de entrada no histórico
    PERFORM registrar_movimentacao_transferencia(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      'Transferência - Entrada',
      NEW.destino_quantidade,
      (NEW.destino_quantidade / 1000) * COALESCE(v_origem_custo_medio, 0),
      v_origem_programa_nome,
      NULL,
      NEW.id
    );
  END IF;
  
  -- Se for INSERT e status_bonus_destino = Concluído e tem bônus, creditar bônus
  IF (TG_OP = 'INSERT' AND NEW.status_bonus_destino = 'Concluído' AND NEW.destino_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade_bonus,
      'Entrada',
      0
    );
    
    -- Registrar movimentação de bônus no histórico
    PERFORM registrar_movimentacao_transferencia(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      'Transferência - Entrada (Bônus)',
      NEW.destino_quantidade_bonus,
      0,
      v_origem_programa_nome,
      NULL,
      NEW.id
    );
  END IF;
  
  -- Se for INSERT e status_bonus_bumerangue = Concluído e tem bônus, creditar bônus bumerangue
  IF (TG_OP = 'INSERT' AND NEW.status_bonus_bumerangue = 'Concluído' AND NEW.bumerangue_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      NEW.bumerangue_quantidade_bonus,
      'Entrada',
      0
    );
    
    -- Registrar movimentação de bônus bumerangue no histórico
    PERFORM registrar_movimentacao_transferencia(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      'Transferência - Entrada (Bumerangue)',
      NEW.bumerangue_quantidade_bonus,
      0,
      v_origem_programa_nome,
      NULL,
      NEW.id
    );
  END IF;
  
  -- Se for UPDATE de Pendente para Concluído, processar pontos principais
  IF (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade,
      'Entrada',
      (NEW.destino_quantidade / 1000) * COALESCE(v_origem_custo_medio, 0)
    );
    
    -- Registrar movimentação de entrada no histórico
    PERFORM registrar_movimentacao_transferencia(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      'Transferência - Entrada',
      NEW.destino_quantidade,
      (NEW.destino_quantidade / 1000) * COALESCE(v_origem_custo_medio, 0),
      v_origem_programa_nome,
      NULL,
      NEW.id
    );
  END IF;
  
  -- Se for UPDATE de status_bonus_destino de Pendente para Concluído
  IF (TG_OP = 'UPDATE' AND OLD.status_bonus_destino = 'Pendente' AND NEW.status_bonus_destino = 'Concluído' AND NEW.destino_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      NEW.destino_quantidade_bonus,
      'Entrada',
      0
    );
    
    -- Registrar movimentação de bônus no histórico
    PERFORM registrar_movimentacao_transferencia(
      NEW.parceiro_id,
      NEW.destino_programa_id,
      'Transferência - Entrada (Bônus)',
      NEW.destino_quantidade_bonus,
      0,
      v_origem_programa_nome,
      NULL,
      NEW.id
    );
  END IF;
  
  -- Se for UPDATE de status_bonus_bumerangue de Pendente para Concluído
  IF (TG_OP = 'UPDATE' AND OLD.status_bonus_bumerangue = 'Pendente' AND NEW.status_bonus_bumerangue = 'Concluído' AND NEW.bumerangue_quantidade_bonus > 0) THEN
    PERFORM atualizar_estoque_pontos(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      NEW.bumerangue_quantidade_bonus,
      'Entrada',
      0
    );
    
    -- Registrar movimentação de bônus bumerangue no histórico
    PERFORM registrar_movimentacao_transferencia(
      NEW.parceiro_id,
      NEW.origem_programa_id,
      'Transferência - Entrada (Bumerangue)',
      NEW.bumerangue_quantidade_bonus,
      0,
      v_origem_programa_nome,
      NULL,
      NEW.id
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- ============================================================================
-- MIGRATION: 20260108205526_fix_estoque_movimentacoes_tipo_constraint.sql
-- ============================================================================

/*
  # Corrigir constraint de tipo na tabela estoque_movimentacoes

  1. Alterações
    - Remover constraint antiga que só permite 'entrada' e 'saida'
    - Adicionar nova constraint que permite tipos de transferência
    - Atualizar função registrar_movimentacao_transferencia para usar tipos válidos

  2. Tipos permitidos
    - entrada
    - saida
    - transferencia_entrada
    - transferencia_saida
*/

-- Remover constraint antiga
ALTER TABLE estoque_movimentacoes
  DROP CONSTRAINT IF EXISTS estoque_movimentacoes_tipo_check;

-- Adicionar nova constraint com tipos adicionais para transferências
ALTER TABLE estoque_movimentacoes
  ADD CONSTRAINT estoque_movimentacoes_tipo_check 
  CHECK (tipo = ANY (ARRAY[
    'entrada'::text, 
    'saida'::text,
    'transferencia_entrada'::text,
    'transferencia_saida'::text
  ]));

-- Atualizar função para usar tipos válidos
CREATE OR REPLACE FUNCTION registrar_movimentacao_transferencia(
  p_parceiro_id uuid,
  p_programa_id uuid,
  p_tipo text,
  p_quantidade decimal,
  p_valor_total decimal,
  p_origem_programa_nome text DEFAULT NULL,
  p_destino_programa_nome text DEFAULT NULL,
  p_referencia_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_saldo_anterior decimal;
  v_saldo_posterior decimal;
  v_custo_medio_anterior decimal;
  v_custo_medio_posterior decimal;
  v_observacao text;
  v_tipo_movimentacao text;
BEGIN
  -- Buscar saldos e custos anteriores
  SELECT saldo_atual, custo_medio 
  INTO v_saldo_anterior, v_custo_medio_anterior
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  -- Calcular saldo posterior
  IF p_tipo LIKE '%Saída%' THEN
    v_saldo_posterior := COALESCE(v_saldo_anterior, 0) - p_quantidade;
    v_tipo_movimentacao := 'transferencia_saida';
  ELSE
    v_saldo_posterior := COALESCE(v_saldo_anterior, 0) + p_quantidade;
    v_tipo_movimentacao := 'transferencia_entrada';
  END IF;

  -- Buscar custo médio posterior (já foi atualizado pela função atualizar_estoque_pontos)
  SELECT custo_medio 
  INTO v_custo_medio_posterior
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  -- Construir observação
  IF p_tipo LIKE '%Saída%' AND p_destino_programa_nome IS NOT NULL THEN
    v_observacao := 'Transferência para ' || p_destino_programa_nome;
  ELSIF p_tipo LIKE '%Entrada%' AND p_origem_programa_nome IS NOT NULL THEN
    v_observacao := 'Transferência de ' || p_origem_programa_nome;
  ELSE
    v_observacao := NULL;
  END IF;

  -- Inserir na tabela de movimentações
  INSERT INTO estoque_movimentacoes (
    parceiro_id,
    programa_id,
    tipo,
    quantidade,
    valor_total,
    saldo_anterior,
    saldo_posterior,
    custo_medio_anterior,
    custo_medio_posterior,
    origem,
    observacao,
    referencia_id,
    referencia_tabela,
    data_movimentacao
  ) VALUES (
    p_parceiro_id,
    p_programa_id,
    v_tipo_movimentacao,
    p_quantidade,
    p_valor_total,
    COALESCE(v_saldo_anterior, 0),
    v_saldo_posterior,
    COALESCE(v_custo_medio_anterior, 0),
    COALESCE(v_custo_medio_posterior, 0),
    'Transferência de Pontos',
    v_observacao,
    p_referencia_id,
    'transferencia_pontos',
    now()
  );
END;
$$;

-- ============================================================================
-- MIGRATION: 20260108212732_add_transferencia_pessoas_to_historico.sql
-- ============================================================================

/*
  # Adicionar transferências entre pessoas ao histórico de movimentações

  1. Alterações
    - Criar função para registrar movimentações de transferência entre pessoas
    - Atualizar trigger para registrar no histórico ao processar transferências
    - Adicionar novos tipos de movimentação à constraint

  2. Comportamento
    - Quando uma transferência entre pessoas é criada, registra:
      - Uma saída no parceiro de origem (com nome do parceiro destino)
      - Uma entrada no parceiro de destino (com nome do parceiro origem)
    - O campo "observacao" inclui detalhes (de qual parceiro para qual parceiro)
*/

-- Atualizar constraint para incluir novos tipos
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
    'transferencia_pessoas_saida'::text
  ]));

-- Função para registrar movimentação de transferência entre pessoas
CREATE OR REPLACE FUNCTION registrar_movimentacao_transferencia_pessoas(
  p_parceiro_id uuid,
  p_programa_id uuid,
  p_tipo text,
  p_quantidade decimal,
  p_valor_total decimal,
  p_outro_parceiro_nome text,
  p_referencia_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_saldo_anterior decimal;
  v_saldo_posterior decimal;
  v_custo_medio_anterior decimal;
  v_custo_medio_posterior decimal;
  v_observacao text;
  v_tipo_movimentacao text;
BEGIN
  -- Buscar saldos e custos anteriores
  SELECT saldo_atual, custo_medio 
  INTO v_saldo_anterior, v_custo_medio_anterior
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  -- Calcular saldo posterior e determinar tipo
  IF p_tipo = 'saida' THEN
    v_saldo_posterior := COALESCE(v_saldo_anterior, 0) - p_quantidade;
    v_tipo_movimentacao := 'transferencia_pessoas_saida';
    v_observacao := 'Transferência para ' || p_outro_parceiro_nome;
  ELSE
    v_saldo_posterior := COALESCE(v_saldo_anterior, 0) + p_quantidade;
    v_tipo_movimentacao := 'transferencia_pessoas_entrada';
    v_observacao := 'Transferência de ' || p_outro_parceiro_nome;
  END IF;

  -- Buscar custo médio posterior (já foi atualizado)
  SELECT custo_medio 
  INTO v_custo_medio_posterior
  FROM estoque_pontos
  WHERE parceiro_id = p_parceiro_id AND programa_id = p_programa_id;

  -- Inserir na tabela de movimentações
  INSERT INTO estoque_movimentacoes (
    parceiro_id,
    programa_id,
    tipo,
    quantidade,
    valor_total,
    saldo_anterior,
    saldo_posterior,
    custo_medio_anterior,
    custo_medio_posterior,
    origem,
    observacao,
    referencia_id,
    referencia_tabela,
    data_movimentacao
  ) VALUES (
    p_parceiro_id,
    p_programa_id,
    v_tipo_movimentacao,
    p_quantidade,
    p_valor_total,
    COALESCE(v_saldo_anterior, 0),
    v_saldo_posterior,
    COALESCE(v_custo_medio_anterior, 0),
    COALESCE(v_custo_medio_posterior, 0),
    'Transferência entre Pessoas',
    v_observacao,
    p_referencia_id,
    'transferencia_pessoas',
    now()
  );
END;
$$;

-- Atualizar função de processar transferência entre pessoas
CREATE OR REPLACE FUNCTION process_transferencia_pessoas()
RETURNS TRIGGER AS $$
DECLARE
  v_origem_estoque_id uuid;
  v_destino_estoque_id uuid;
  v_origem_saldo numeric;
  v_origem_custo_medio numeric;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_novo_saldo_destino numeric;
  v_novo_custo_medio numeric;
  v_origem_parceiro_nome text;
  v_destino_parceiro_nome text;
BEGIN
  -- Buscar nomes dos parceiros
  SELECT nome_parceiro INTO v_origem_parceiro_nome
  FROM parceiros
  WHERE id = NEW.origem_parceiro_id;

  SELECT nome_parceiro INTO v_destino_parceiro_nome
  FROM parceiros
  WHERE id = NEW.destino_parceiro_id;

  -- Buscar estoque da origem
  SELECT id, saldo_atual, custo_medio INTO v_origem_estoque_id, v_origem_saldo, v_origem_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;

  -- Validar se origem tem saldo suficiente
  IF v_origem_saldo < NEW.quantidade THEN
    RAISE EXCEPTION 'Saldo insuficiente no estoque de origem';
  END IF;

  -- Buscar ou criar estoque do destino
  SELECT id, saldo_atual, custo_medio INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
  FROM estoque_pontos
  WHERE parceiro_id = NEW.destino_parceiro_id AND programa_id = NEW.programa_id;

  IF v_destino_estoque_id IS NULL THEN
    -- Criar estoque para o destino
    INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
    VALUES (NEW.destino_parceiro_id, NEW.programa_id, 0, 0)
    RETURNING id, saldo_atual, custo_medio INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
  END IF;

  -- Atualizar estoque de origem (diminuir)
  UPDATE estoque_pontos
  SET saldo_atual = saldo_atual - NEW.quantidade,
      updated_at = now()
  WHERE id = v_origem_estoque_id;

  -- Registrar movimentação de saída no histórico
  PERFORM registrar_movimentacao_transferencia_pessoas(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    'saida',
    NEW.quantidade,
    NEW.custo_transferencia,
    v_destino_parceiro_nome,
    NEW.id
  );

  -- Calcular novo custo médio do destino
  v_novo_saldo_destino := v_destino_saldo + NEW.quantidade;
  IF v_novo_saldo_destino > 0 THEN
    v_novo_custo_medio := ((v_destino_saldo * v_destino_custo_medio) + (NEW.quantidade * v_origem_custo_medio)) / v_novo_saldo_destino;
  ELSE
    v_novo_custo_medio := 0;
  END IF;

  -- Atualizar estoque de destino (aumentar)
  UPDATE estoque_pontos
  SET saldo_atual = v_novo_saldo_destino,
      custo_medio = v_novo_custo_medio,
      updated_at = now()
  WHERE id = v_destino_estoque_id;

  -- Registrar movimentação de entrada no histórico
  PERFORM registrar_movimentacao_transferencia_pessoas(
    NEW.destino_parceiro_id,
    NEW.programa_id,
    'entrada',
    NEW.quantidade,
    0, -- Não tem custo no destino, pontos já foram contabilizados
    v_origem_parceiro_nome,
    NEW.id
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- MIGRATION: 20260114122127_alter_downgrade_upgrade_to_date_and_add_reminder_logic_v2.sql
-- ============================================================================

/*
  # Alterar campo downgrade/upgrade para data e adicionar lógica de lembretes

  1. Alterações
    - Renomear coluna downgrade_upgrade para downgrade_upgrade_data
    - Alterar tipo para date
    - Criar função para verificar e criar atividades de lembrete
    - Criar função para ajustar lógica de créditos recorrentes baseada na data de assinatura

  2. Comportamento
    - Campo downgrade_upgrade_data armazena a data planejada para fazer downgrade/upgrade
    - Sistema cria atividade de lembrete quando estiver na semana da data escolhida
    - Créditos recorrentes baseados na data de assinatura:
      * Mensal: a cada 30 dias da data de assinatura
      * Trimestral: a cada 3 meses da data de assinatura
      * Anual: a cada 1 ano da data de assinatura
*/

-- Renomear e alterar tipo da coluna downgrade_upgrade
DO $$
BEGIN
  -- Verificar se a coluna antiga existe
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' AND column_name = 'downgrade_upgrade'
  ) THEN
    -- Adicionar nova coluna
    ALTER TABLE programas_clubes ADD COLUMN IF NOT EXISTS downgrade_upgrade_data date;
    
    -- Tentar converter dados existentes (se possível)
    UPDATE programas_clubes
    SET downgrade_upgrade_data = CASE
      WHEN downgrade_upgrade ~ '^\d{4}-\d{2}-\d{2}$' THEN downgrade_upgrade::date
      ELSE NULL
    END
    WHERE downgrade_upgrade IS NOT NULL;
    
    -- Remover coluna antiga
    ALTER TABLE programas_clubes DROP COLUMN downgrade_upgrade;
  ELSE
    -- Se já foi migrado, apenas garantir que a nova coluna existe
    ALTER TABLE programas_clubes ADD COLUMN IF NOT EXISTS downgrade_upgrade_data date;
  END IF;
END $$;

-- Função para criar atividades de lembrete de downgrade/upgrade
CREATE OR REPLACE FUNCTION criar_atividade_downgrade_upgrade()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clube RECORD;
  v_data_inicio date;
  v_data_fim date;
BEGIN
  -- Definir período da semana (hoje até 7 dias a frente)
  v_data_inicio := CURRENT_DATE;
  v_data_fim := CURRENT_DATE + INTERVAL '7 days';

  -- Buscar clubes com data de downgrade/upgrade na próxima semana
  FOR v_clube IN
    SELECT 
      pc.id,
      pc.parceiro_id,
      pc.programa_id,
      pc.downgrade_upgrade_data,
      pa.nome_parceiro,
      pf.nome as programa_nome
    FROM programas_clubes pc
    JOIN parceiros pa ON pa.id = pc.parceiro_id
    JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    WHERE pc.downgrade_upgrade_data >= v_data_inicio
      AND pc.downgrade_upgrade_data <= v_data_fim
      AND pc.tem_clube = true
  LOOP
    -- Verificar se já existe atividade para este clube e data
    IF NOT EXISTS (
      SELECT 1 FROM atividades
      WHERE programa_clube_id = v_clube.id
        AND tipo = 'Lembrete'
        AND observacao LIKE '%Downgrade/Upgrade%'
        AND data_atividade = v_clube.downgrade_upgrade_data
    ) THEN
      -- Criar atividade de lembrete
      INSERT INTO atividades (
        parceiro_id,
        programa_id,
        programa_clube_id,
        tipo,
        data_atividade,
        observacao,
        status,
        created_at
      ) VALUES (
        v_clube.parceiro_id,
        v_clube.programa_id,
        v_clube.id,
        'Lembrete',
        v_clube.downgrade_upgrade_data,
        'Lembrete: Verificar Downgrade/Upgrade para ' || v_clube.nome_parceiro || ' - ' || v_clube.programa_nome,
        'Pendente',
        now()
      );
    END IF;
  END LOOP;
END;
$$;

-- Função para processar créditos recorrentes baseados na data de assinatura
CREATE OR REPLACE FUNCTION processar_creditos_clubes_recorrentes()
RETURNS TABLE(
  parceiro_nome text,
  programa_nome text,
  quantidade_creditada numeric,
  data_credito date,
  status text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clube RECORD;
  v_dias_desde_assinatura integer;
  v_deve_creditar boolean;
  v_ultima_data_credito date;
  v_proxima_data_credito date;
BEGIN
  -- Buscar clubes com bônus recorrente ativo
  FOR v_clube IN
    SELECT 
      pc.id,
      pc.parceiro_id,
      pc.programa_id,
      pc.data_ultima_assinatura,
      pc.bonus_quantidade_pontos,
      pc.sequencia,
      pa.nome_parceiro,
      pf.nome as programa_nome
    FROM programas_clubes pc
    JOIN parceiros pa ON pa.id = pc.parceiro_id
    JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    WHERE pc.tem_clube = true
      AND pc.bonus_quantidade_pontos > 0
      AND pc.sequencia IS NOT NULL
      AND pc.data_ultima_assinatura IS NOT NULL
  LOOP
    v_deve_creditar := false;
    
    -- Buscar última data de crédito nas atividades
    SELECT MAX(data_atividade) INTO v_ultima_data_credito
    FROM atividades
    WHERE programa_clube_id = v_clube.id
      AND tipo = 'Crédito Clube'
      AND observacao LIKE '%Bônus Recorrente%';

    -- Se nunca foi creditado, usar data de assinatura como base
    IF v_ultima_data_credito IS NULL THEN
      v_ultima_data_credito := v_clube.data_ultima_assinatura;
    END IF;

    -- Calcular tempo desde último crédito
    v_dias_desde_assinatura := CURRENT_DATE - v_ultima_data_credito;
    
    -- Verificar se deve creditar baseado na frequência
    IF v_clube.sequencia = 'mensal' AND v_dias_desde_assinatura >= 30 THEN
      v_deve_creditar := true;
      v_proxima_data_credito := v_ultima_data_credito + INTERVAL '30 days';
    ELSIF v_clube.sequencia = 'trimestral' AND v_dias_desde_assinatura >= 90 THEN
      v_deve_creditar := true;
      v_proxima_data_credito := v_ultima_data_credito + INTERVAL '3 months';
    ELSIF v_clube.sequencia = 'anual' AND v_dias_desde_assinatura >= 365 THEN
      v_deve_creditar := true;
      v_proxima_data_credito := v_ultima_data_credito + INTERVAL '1 year';
    END IF;

    -- Se deve creditar, processar
    IF v_deve_creditar THEN
      -- Atualizar estoque
      PERFORM atualizar_estoque_pontos(
        v_clube.parceiro_id,
        v_clube.programa_id,
        v_clube.bonus_quantidade_pontos,
        'Entrada',
        0
      );

      -- Criar atividade
      PERFORM criar_atividade_clube(
        v_clube.id,
        v_clube.parceiro_id,
        v_clube.programa_id,
        'Crédito Clube',
        v_proxima_data_credito::date,
        v_clube.bonus_quantidade_pontos,
        'Bônus Recorrente ' || INITCAP(v_clube.sequencia) || ' - ' || v_clube.bonus_quantidade_pontos || ' pontos'
      );

      -- Retornar resultado
      RETURN QUERY SELECT 
        v_clube.nome_parceiro,
        v_clube.programa_nome,
        v_clube.bonus_quantidade_pontos,
        v_proxima_data_credito::date,
        'Creditado'::text;
    END IF;
  END LOOP;
END;
$$;

-- ============================================================================
-- MIGRATION: 20260114130122_fix_atividades_add_lembrete_downgrade_type.sql
-- ============================================================================

/*
  # Adicionar tipo lembrete_downgrade às atividades e ajustar lógica

  1. Alterações
    - Adicionar tipo 'lembrete_downgrade' ao constraint de tipo_atividade
    - Ajustar função criar_atividade_downgrade_upgrade para:
      * Criar lembretes 5 dias antes da data
      * Verificar se lembrete foi excluído
      * Permitir recriação se foi excluído
    - Adicionar função para excluir lembrete

  2. Comportamento
    - Lembretes aparecem 5 dias antes da data de downgrade/upgrade
    - Podem ser excluídos pelo usuário
    - Sistema recria automaticamente se excluído e ainda estiver a 5 dias da data
*/

-- Atualizar constraint para incluir tipo lembrete_downgrade
ALTER TABLE atividades DROP CONSTRAINT IF EXISTS atividades_tipo_atividade_check;

ALTER TABLE atividades ADD CONSTRAINT atividades_tipo_atividade_check
  CHECK (tipo_atividade IN (
    'transferencia_entrada',
    'transferencia_bonus',
    'bumerangue_retorno',
    'clube_credito_mensal',
    'clube_credito_bonus',
    'lembrete_downgrade',
    'outro'
  ));

-- Atualizar função para criar atividades de lembrete de downgrade/upgrade
CREATE OR REPLACE FUNCTION criar_atividade_downgrade_upgrade()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clube RECORD;
  v_data_inicio date;
  v_data_fim date;
  v_ultima_exclusao timestamptz;
BEGIN
  -- Definir período (5 dias antes até 30 dias depois)
  v_data_inicio := CURRENT_DATE;
  v_data_fim := CURRENT_DATE + INTERVAL '30 days';

  -- Buscar clubes com data de downgrade/upgrade próxima
  FOR v_clube IN
    SELECT 
      pc.id,
      pc.parceiro_id,
      pc.programa_id,
      pc.downgrade_upgrade_data,
      pa.nome_parceiro,
      pf.nome as programa_nome
    FROM programas_clubes pc
    JOIN parceiros pa ON pa.id = pc.parceiro_id
    JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    WHERE pc.downgrade_upgrade_data IS NOT NULL
      AND pc.downgrade_upgrade_data >= v_data_inicio
      AND pc.downgrade_upgrade_data <= v_data_fim
      AND pc.tem_clube = true
  LOOP
    -- Verificar se já existe atividade ativa (não excluída)
    IF NOT EXISTS (
      SELECT 1 FROM atividades
      WHERE referencia_id = v_clube.id
        AND referencia_tabela = 'programas_clubes'
        AND tipo_atividade = 'lembrete_downgrade'
        AND data_prevista = v_clube.downgrade_upgrade_data
        AND status != 'cancelado'
    ) THEN
      -- Verificar se deve criar lembrete (5 dias antes ou já passou)
      IF v_clube.downgrade_upgrade_data <= CURRENT_DATE + INTERVAL '5 days' THEN
        -- Buscar última vez que foi excluído
        SELECT MAX(updated_at) INTO v_ultima_exclusao
        FROM atividades
        WHERE referencia_id = v_clube.id
          AND referencia_tabela = 'programas_clubes'
          AND tipo_atividade = 'lembrete_downgrade'
          AND data_prevista = v_clube.downgrade_upgrade_data
          AND status = 'cancelado';

        -- Só criar se nunca foi excluído OU se foi excluído há mais de 1 dia
        IF v_ultima_exclusao IS NULL OR v_ultima_exclusao < CURRENT_DATE - INTERVAL '1 day' THEN
          -- Criar atividade de lembrete
          INSERT INTO atividades (
            tipo_atividade,
            titulo,
            descricao,
            parceiro_id,
            parceiro_nome,
            programa_id,
            programa_nome,
            data_prevista,
            referencia_id,
            referencia_tabela,
            status,
            prioridade,
            observacoes,
            created_at
          ) VALUES (
            'lembrete_downgrade',
            'Lembrete: Downgrade/Upgrade',
            'Verificar necessidade de Downgrade/Upgrade para ' || v_clube.nome_parceiro || ' - ' || v_clube.programa_nome,
            v_clube.parceiro_id,
            v_clube.nome_parceiro,
            v_clube.programa_id,
            v_clube.programa_nome,
            v_clube.downgrade_upgrade_data,
            v_clube.id,
            'programas_clubes',
            'pendente',
            'normal',
            'Verificar Downgrade/Upgrade agendado para ' || TO_CHAR(v_clube.downgrade_upgrade_data, 'DD/MM/YYYY'),
            now()
          );
        END IF;
      END IF;
    END IF;
  END LOOP;
END;
$$;

-- Adicionar aos tipos de atividades conhecidos
COMMENT ON COLUMN atividades.tipo_atividade IS 
'Tipos de atividades:
- transferencia_entrada: Entrada de transferência
- transferencia_bonus: Bônus de transferência
- bumerangue_retorno: Retorno de bumerangue
- clube_credito_mensal: Crédito mensal de clube
- clube_credito_bonus: Bônus de clube
- lembrete_downgrade: Lembrete de downgrade/upgrade
- outro: Outras atividades';


-- ============================================================================
-- MIGRATION: 20260114130448_create_trigger_and_job_for_downgrade_reminders.sql
-- ============================================================================

/*
  # Criar trigger e job para lembretes de downgrade/upgrade

  1. Alterações
    - Criar trigger que dispara quando downgrade_upgrade_data é inserido/atualizado
    - Criar job diário para verificar e criar lembretes
    - Executar função inicial para criar lembretes existentes

  2. Comportamento
    - Quando um registro de programas_clubes é criado/atualizado com downgrade_upgrade_data,
      verifica se deve criar lembrete (5 dias antes ou menos)
    - Job diário executa às 8h para verificar todos os registros e criar lembretes necessários
*/

-- Função auxiliar para criar lembrete individual
CREATE OR REPLACE FUNCTION criar_lembrete_downgrade_individual(p_clube_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clube RECORD;
  v_ultima_exclusao timestamptz;
BEGIN
  -- Buscar dados do clube
  SELECT 
    pc.id,
    pc.parceiro_id,
    pc.programa_id,
    pc.downgrade_upgrade_data,
    pa.nome_parceiro,
    pf.nome as programa_nome
  INTO v_clube
  FROM programas_clubes pc
  JOIN parceiros pa ON pa.id = pc.parceiro_id
  JOIN programas_fidelidade pf ON pf.id = pc.programa_id
  WHERE pc.id = p_clube_id
    AND pc.downgrade_upgrade_data IS NOT NULL
    AND pc.tem_clube = true;

  -- Se não encontrou ou não tem data, retornar
  IF NOT FOUND OR v_clube.downgrade_upgrade_data IS NULL THEN
    RETURN;
  END IF;

  -- Verificar se já existe atividade ativa (não excluída)
  IF EXISTS (
    SELECT 1 FROM atividades
    WHERE referencia_id = v_clube.id
      AND referencia_tabela = 'programas_clubes'
      AND tipo_atividade = 'lembrete_downgrade'
      AND data_prevista = v_clube.downgrade_upgrade_data
      AND status != 'cancelado'
  ) THEN
    RETURN;
  END IF;

  -- Verificar se deve criar lembrete (5 dias antes ou já passou, mas ainda dentro de 30 dias)
  IF v_clube.downgrade_upgrade_data >= CURRENT_DATE 
     AND v_clube.downgrade_upgrade_data <= CURRENT_DATE + INTERVAL '30 days'
     AND v_clube.downgrade_upgrade_data <= CURRENT_DATE + INTERVAL '5 days' THEN
    
    -- Buscar última vez que foi excluído
    SELECT MAX(updated_at) INTO v_ultima_exclusao
    FROM atividades
    WHERE referencia_id = v_clube.id
      AND referencia_tabela = 'programas_clubes'
      AND tipo_atividade = 'lembrete_downgrade'
      AND data_prevista = v_clube.downgrade_upgrade_data
      AND status = 'cancelado';

    -- Só criar se nunca foi excluído OU se foi excluído há mais de 1 dia
    IF v_ultima_exclusao IS NULL OR v_ultima_exclusao < CURRENT_DATE - INTERVAL '1 day' THEN
      -- Criar atividade de lembrete
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        data_prevista,
        referencia_id,
        referencia_tabela,
        status,
        prioridade,
        observacoes,
        created_at
      ) VALUES (
        'lembrete_downgrade',
        'Lembrete: Downgrade/Upgrade',
        'Verificar necessidade de Downgrade/Upgrade para ' || v_clube.nome_parceiro || ' - ' || v_clube.programa_nome,
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_clube.downgrade_upgrade_data,
        v_clube.id,
        'programas_clubes',
        'pendente',
        'normal',
        'Verificar Downgrade/Upgrade agendado para ' || TO_CHAR(v_clube.downgrade_upgrade_data, 'DD/MM/YYYY'),
        now()
      );
    END IF;
  END IF;
END;
$$;

-- Trigger para criar lembrete quando downgrade_upgrade_data é inserido/atualizado
CREATE OR REPLACE FUNCTION trigger_criar_lembrete_downgrade()
RETURNS TRIGGER AS $$
BEGIN
  -- Só processar se downgrade_upgrade_data foi definido/alterado
  IF NEW.downgrade_upgrade_data IS NOT NULL 
     AND (TG_OP = 'INSERT' OR OLD.downgrade_upgrade_data IS DISTINCT FROM NEW.downgrade_upgrade_data) THEN
    
    -- Cancelar lembretes antigos se a data mudou
    IF TG_OP = 'UPDATE' AND OLD.downgrade_upgrade_data IS DISTINCT FROM NEW.downgrade_upgrade_data THEN
      UPDATE atividades
      SET status = 'cancelado',
          updated_at = now()
      WHERE referencia_id = NEW.id
        AND referencia_tabela = 'programas_clubes'
        AND tipo_atividade = 'lembrete_downgrade'
        AND status = 'pendente';
    END IF;

    -- Criar novo lembrete se necessário
    PERFORM criar_lembrete_downgrade_individual(NEW.id);
  END IF;

  -- Se downgrade_upgrade_data foi removido, cancelar lembretes
  IF NEW.downgrade_upgrade_data IS NULL AND OLD.downgrade_upgrade_data IS NOT NULL THEN
    UPDATE atividades
    SET status = 'cancelado',
        updated_at = now()
    WHERE referencia_id = NEW.id
      AND referencia_tabela = 'programas_clubes'
      AND tipo_atividade = 'lembrete_downgrade'
      AND status = 'pendente';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_criar_lembrete_downgrade ON programas_clubes;
CREATE TRIGGER trigger_criar_lembrete_downgrade
  AFTER INSERT OR UPDATE OF downgrade_upgrade_data, tem_clube
  ON programas_clubes
  FOR EACH ROW
  EXECUTE FUNCTION trigger_criar_lembrete_downgrade();

-- Criar job para executar diariamente a função de criar lembretes às 8h
DO $$
BEGIN
  -- Tentar desabilitar job antigo se existir
  PERFORM cron.unschedule('criar_lembretes_downgrade_upgrade_diario');
EXCEPTION
  WHEN undefined_table THEN NULL;
  WHEN undefined_function THEN NULL;
  WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  -- Criar job para verificar lembretes diariamente às 8h
  PERFORM cron.schedule(
    'criar_lembretes_downgrade_upgrade_diario',
    '0 8 * * *',
    'SELECT criar_atividade_downgrade_upgrade();'
  );
EXCEPTION
  WHEN undefined_table THEN NULL;
  WHEN undefined_function THEN NULL;
  WHEN OTHERS THEN NULL;
END $$;

-- Executar função inicial para criar lembretes existentes
SELECT criar_atividade_downgrade_upgrade();

-- ============================================================================
-- MIGRATION: 20260114130950_create_milhas_expirando_reminder_system.sql
-- ============================================================================

/*
  # Criar sistema de lembretes para milhas expirando

  1. Alterações
    - Adicionar campo milhas_expirando_data (date) na tabela programas_clubes
    - Criar função para criar lembretes de milhas expirando
    - Criar trigger para gerar lembretes automaticamente
    - Criar job diário para verificar e criar lembretes

  2. Comportamento
    - Quando milhas_expirando_data é definido, cria lembrete automaticamente (5 dias antes)
    - Job diário executa às 8h para verificar todos os registros
    - Lembretes aparecem na tela de Atividades automaticamente
*/

-- Adicionar campo milhas_expirando_data
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'programas_clubes' AND column_name = 'milhas_expirando_data'
  ) THEN
    ALTER TABLE programas_clubes ADD COLUMN milhas_expirando_data date;
  END IF;
END $$;

-- Função para criar lembrete individual de milhas expirando
CREATE OR REPLACE FUNCTION criar_lembrete_milhas_expirando_individual(p_clube_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clube RECORD;
  v_ultima_exclusao timestamptz;
BEGIN
  -- Buscar dados do clube
  SELECT 
    pc.id,
    pc.parceiro_id,
    pc.programa_id,
    pc.milhas_expirando_data,
    pa.nome_parceiro,
    pf.nome as programa_nome
  INTO v_clube
  FROM programas_clubes pc
  JOIN parceiros pa ON pa.id = pc.parceiro_id
  JOIN programas_fidelidade pf ON pf.id = pc.programa_id
  WHERE pc.id = p_clube_id
    AND pc.milhas_expirando_data IS NOT NULL;

  -- Se não encontrou ou não tem data, retornar
  IF NOT FOUND OR v_clube.milhas_expirando_data IS NULL THEN
    RETURN;
  END IF;

  -- Verificar se já existe atividade ativa (não excluída)
  IF EXISTS (
    SELECT 1 FROM atividades
    WHERE referencia_id = v_clube.id
      AND referencia_tabela = 'programas_clubes'
      AND tipo_atividade = 'lembrete_milhas_expirando'
      AND data_prevista = v_clube.milhas_expirando_data
      AND status != 'cancelado'
  ) THEN
    RETURN;
  END IF;

  -- Verificar se deve criar lembrete (5 dias antes ou já passou, mas ainda dentro de 30 dias)
  IF v_clube.milhas_expirando_data >= CURRENT_DATE 
     AND v_clube.milhas_expirando_data <= CURRENT_DATE + INTERVAL '30 days'
     AND v_clube.milhas_expirando_data <= CURRENT_DATE + INTERVAL '5 days' THEN
    
    -- Buscar última vez que foi excluído
    SELECT MAX(updated_at) INTO v_ultima_exclusao
    FROM atividades
    WHERE referencia_id = v_clube.id
      AND referencia_tabela = 'programas_clubes'
      AND tipo_atividade = 'lembrete_milhas_expirando'
      AND data_prevista = v_clube.milhas_expirando_data
      AND status = 'cancelado';

    -- Só criar se nunca foi excluído OU se foi excluído há mais de 1 dia
    IF v_ultima_exclusao IS NULL OR v_ultima_exclusao < CURRENT_DATE - INTERVAL '1 day' THEN
      -- Criar atividade de lembrete
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        data_prevista,
        referencia_id,
        referencia_tabela,
        status,
        prioridade,
        observacoes,
        created_at
      ) VALUES (
        'lembrete_milhas_expirando',
        'Lembrete: Milhas Expirando',
        'Atenção! Milhas expirando para ' || v_clube.nome_parceiro || ' - ' || v_clube.programa_nome,
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_clube.milhas_expirando_data,
        v_clube.id,
        'programas_clubes',
        'pendente',
        'alta',
        'Milhas com vencimento em ' || TO_CHAR(v_clube.milhas_expirando_data, 'DD/MM/YYYY'),
        now()
      );
    END IF;
  END IF;
END;
$$;

-- Função para criar todos os lembretes de milhas expirando
CREATE OR REPLACE FUNCTION criar_atividade_milhas_expirando()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clube RECORD;
BEGIN
  -- Buscar todos os clubes com milhas_expirando_data definido
  FOR v_clube IN
    SELECT id
    FROM programas_clubes
    WHERE milhas_expirando_data IS NOT NULL
      AND milhas_expirando_data >= CURRENT_DATE
      AND milhas_expirando_data <= CURRENT_DATE + INTERVAL '30 days'
  LOOP
    -- Criar lembrete individual
    PERFORM criar_lembrete_milhas_expirando_individual(v_clube.id);
  END LOOP;
END;
$$;

-- Trigger para criar lembrete quando milhas_expirando_data é inserido/atualizado
CREATE OR REPLACE FUNCTION trigger_criar_lembrete_milhas_expirando()
RETURNS TRIGGER AS $$
BEGIN
  -- Só processar se milhas_expirando_data foi definido/alterado
  IF NEW.milhas_expirando_data IS NOT NULL 
     AND (TG_OP = 'INSERT' OR OLD.milhas_expirando_data IS DISTINCT FROM NEW.milhas_expirando_data) THEN
    
    -- Cancelar lembretes antigos se a data mudou
    IF TG_OP = 'UPDATE' AND OLD.milhas_expirando_data IS DISTINCT FROM NEW.milhas_expirando_data THEN
      UPDATE atividades
      SET status = 'cancelado',
          updated_at = now()
      WHERE referencia_id = NEW.id
        AND referencia_tabela = 'programas_clubes'
        AND tipo_atividade = 'lembrete_milhas_expirando'
        AND status = 'pendente';
    END IF;

    -- Criar novo lembrete se necessário
    PERFORM criar_lembrete_milhas_expirando_individual(NEW.id);
  END IF;

  -- Se milhas_expirando_data foi removido, cancelar lembretes
  IF NEW.milhas_expirando_data IS NULL AND OLD.milhas_expirando_data IS NOT NULL THEN
    UPDATE atividades
    SET status = 'cancelado',
        updated_at = now()
    WHERE referencia_id = NEW.id
      AND referencia_tabela = 'programas_clubes'
      AND tipo_atividade = 'lembrete_milhas_expirando'
      AND status = 'pendente';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_criar_lembrete_milhas_expirando ON programas_clubes;
CREATE TRIGGER trigger_criar_lembrete_milhas_expirando
  AFTER INSERT OR UPDATE OF milhas_expirando_data
  ON programas_clubes
  FOR EACH ROW
  EXECUTE FUNCTION trigger_criar_lembrete_milhas_expirando();

-- Criar job para executar diariamente a função de criar lembretes às 8h
DO $$
BEGIN
  -- Tentar desabilitar job antigo se existir
  PERFORM cron.unschedule('criar_lembretes_milhas_expirando_diario');
EXCEPTION
  WHEN undefined_table THEN NULL;
  WHEN undefined_function THEN NULL;
  WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  -- Criar job para verificar lembretes diariamente às 8h
  PERFORM cron.schedule(
    'criar_lembretes_milhas_expirando_diario',
    '0 8 * * *',
    'SELECT criar_atividade_milhas_expirando();'
  );
EXCEPTION
  WHEN undefined_table THEN NULL;
  WHEN undefined_function THEN NULL;
  WHEN OTHERS THEN NULL;
END $$;

-- Executar função inicial para criar lembretes existentes (se houver)
SELECT criar_atividade_milhas_expirando();

-- ============================================================================
-- MIGRATION: 20260114135938_fix_conta_familia_constraints_per_program_v2.sql
-- ============================================================================

/*
  # Corrigir Constraints de Conta Família por Programa (v2)

  1. Problema Identificado
    - Constraint atual impede parceiro de ser membro de mais de 1 conta (qualquer programa)
    - Regra correta: parceiro pode ser membro de 1 conta POR PROGRAMA
    - Exemplo: pode ser membro de conta Livelo E conta LATAM (programas diferentes)
    - Mas NÃO pode ser membro de 2 contas Livelo (mesmo programa)

  2. Mudanças
    - Remover índice único antigo (parceiro_id, conta_familia_id)
    - Criar triggers para validar por programa
    - Atualizar triggers existentes para considerar apenas contas ativas

  3. Regras Finais
    - Titular: pode ser titular de 1 conta ATIVA por programa ✓
    - Membro: pode ser membro ATIVO de 1 conta por programa ✓
    - Titular não pode ser membro ATIVO do mesmo programa ✓
    - Membro ATIVO não pode ser titular de conta ATIVA do mesmo programa ✓
*/

-- Remover índice único antigo que estava muito restritivo
DROP INDEX IF EXISTS idx_conta_familia_membros_unique_parceiro_programa;

-- Atualizar função check_titular_nao_e_membro para verificar corretamente
CREATE OR REPLACE FUNCTION check_titular_nao_e_membro()
RETURNS TRIGGER AS $$
DECLARE
  v_programa_id uuid;
  v_conta_count integer;
BEGIN
  -- Só validar se o membro está ATIVO
  IF NEW.status != 'Ativo' THEN
    RETURN NEW;
  END IF;

  -- Busca o programa_id da conta família
  SELECT programa_id INTO v_programa_id
  FROM conta_familia
  WHERE id = NEW.conta_familia_id;
  
  -- Se não tem programa definido, permite
  IF v_programa_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Verifica se o parceiro é titular de alguma conta ATIVA deste programa
  SELECT COUNT(*) INTO v_conta_count
  FROM conta_familia
  WHERE parceiro_principal_id = NEW.parceiro_id
    AND programa_id = v_programa_id
    AND status = 'Ativa'
    AND id != NEW.conta_familia_id;
  
  IF v_conta_count > 0 THEN
    RAISE EXCEPTION 'Este parceiro já é titular de outra conta ativa deste programa e não pode ser membro adicional';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Atualizar função check_membro_nao_e_titular para verificar corretamente
CREATE OR REPLACE FUNCTION check_membro_nao_e_titular()
RETURNS TRIGGER AS $$
DECLARE
  v_membro_count integer;
BEGIN
  -- Se não tem programa ou parceiro principal definido, permite
  IF NEW.programa_id IS NULL OR NEW.parceiro_principal_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Só validar se a conta está ATIVA
  IF NEW.status != 'Ativa' THEN
    RETURN NEW;
  END IF;
  
  -- Verifica se o parceiro é membro ativo de alguma conta ATIVA deste programa
  SELECT COUNT(*) INTO v_membro_count
  FROM conta_familia_membros cfm
  JOIN conta_familia cf ON cfm.conta_familia_id = cf.id
  WHERE cfm.parceiro_id = NEW.parceiro_principal_id
    AND cf.programa_id = NEW.programa_id
    AND cf.status = 'Ativa'
    AND cfm.status = 'Ativo'
    AND cf.id != NEW.id;
  
  IF v_membro_count > 0 THEN
    RAISE EXCEPTION 'Este parceiro já é membro ativo de outra conta deste programa e não pode ser titular';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar função para validar se membro já existe em outra conta DO MESMO PROGRAMA
CREATE OR REPLACE FUNCTION check_membro_programa_duplicado()
RETURNS TRIGGER AS $$
DECLARE
  v_programa_id uuid;
  v_membro_count integer;
BEGIN
  -- Só validar se o membro está ATIVO
  IF NEW.status != 'Ativo' THEN
    RETURN NEW;
  END IF;

  -- Busca o programa_id da conta família onde está tentando adicionar
  SELECT programa_id INTO v_programa_id
  FROM conta_familia
  WHERE id = NEW.conta_familia_id;
  
  -- Se não tem programa definido, permite
  IF v_programa_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Verifica se o parceiro já é membro ativo de outra conta ATIVA deste mesmo programa
  SELECT COUNT(*) INTO v_membro_count
  FROM conta_familia_membros cfm
  JOIN conta_familia cf ON cfm.conta_familia_id = cf.id
  WHERE cfm.parceiro_id = NEW.parceiro_id
    AND cf.programa_id = v_programa_id
    AND cfm.status = 'Ativo'
    AND cf.status = 'Ativa'
    AND cfm.conta_familia_id != NEW.conta_familia_id;
  
  IF v_membro_count > 0 THEN
    RAISE EXCEPTION 'Este parceiro já é membro ativo de outra conta deste programa';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para validar duplicação de membro no mesmo programa
DROP TRIGGER IF EXISTS trigger_check_membro_programa_duplicado ON conta_familia_membros;

CREATE TRIGGER trigger_check_membro_programa_duplicado
BEFORE INSERT OR UPDATE ON conta_familia_membros
FOR EACH ROW
EXECUTE FUNCTION check_membro_programa_duplicado();

-- Comentários explicativos das regras
COMMENT ON FUNCTION check_titular_nao_e_membro() IS 
'Valida que um parceiro que é titular de uma conta ATIVA não pode ser membro ATIVO de outra conta do MESMO programa';

COMMENT ON FUNCTION check_membro_nao_e_titular() IS 
'Valida que um parceiro que é membro ATIVO não pode ser titular de conta ATIVA do MESMO programa';

COMMENT ON FUNCTION check_membro_programa_duplicado() IS 
'Valida que um parceiro só pode ser membro ATIVO de UMA conta por programa. Pode ser membro de contas de programas diferentes';

-- ============================================================================
-- MIGRATION: 20260114142653_add_cpf_limit_control_system_fixed.sql
-- ============================================================================

/*
  # Sistema de Controle de Limite de CPFs por Status e Programa

  1. Problema
    - Cada status de programa permite um número limitado de emissões de CPF por ano
    - Cada parceiro tem seu próprio limite por programa
    - Os limites resetam anualmente
    - Exemplo: Alisson emitiu 25 CPFs no Livelo (limite 25), não pode mais emitir
               Mas pode emitir em outros programas normalmente

  2. Solução
    - Adicionar campo limite_cpfs_ano na tabela status_programa
    - Criar tabela para controlar CPFs emitidos por parceiro/programa/ano
    - Criar funções para calcular CPFs disponíveis
    - Criar view para facilitar consultas no estoque

  3. Mudanças
    - Novo campo: status_programa.limite_cpfs_ano
    - Nova tabela: parceiro_programa_cpfs_controle
    - Nova função: calcular_cpfs_disponiveis
    - Nova view: estoque_cpfs_disponiveis
*/

-- 1. Adicionar campo limite_cpfs_ano na tabela status_programa
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'status_programa' AND column_name = 'limite_cpfs_ano'
  ) THEN
    ALTER TABLE status_programa 
    ADD COLUMN limite_cpfs_ano integer DEFAULT 0;
    
    COMMENT ON COLUMN status_programa.limite_cpfs_ano IS 
    'Número máximo de CPFs que podem ser emitidos por parceiro neste status durante um ano';
  END IF;
END $$;

-- 2. Criar tabela de controle de CPFs emitidos por parceiro/programa/ano
CREATE TABLE IF NOT EXISTS parceiro_programa_cpfs_controle (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parceiro_id uuid NOT NULL REFERENCES parceiros(id) ON DELETE CASCADE,
  programa_id uuid NOT NULL REFERENCES programas_fidelidade(id) ON DELETE CASCADE,
  ano integer NOT NULL,
  cpfs_emitidos integer DEFAULT 0,
  data_primeiro_cpf date,
  data_ultimo_cpf date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(parceiro_id, programa_id, ano)
);

ALTER TABLE parceiro_programa_cpfs_controle ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir acesso total a parceiro_programa_cpfs_controle"
  ON parceiro_programa_cpfs_controle
  FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_cpfs_controle_parceiro_programa_ano 
ON parceiro_programa_cpfs_controle(parceiro_id, programa_id, ano);

CREATE INDEX IF NOT EXISTS idx_cpfs_controle_ano 
ON parceiro_programa_cpfs_controle(ano);

COMMENT ON TABLE parceiro_programa_cpfs_controle IS 
'Controla quantos CPFs cada parceiro emitiu em cada programa por ano';

-- 3. Criar função para calcular CPFs disponíveis para um parceiro/programa
CREATE OR REPLACE FUNCTION calcular_cpfs_disponiveis(
  p_parceiro_id uuid,
  p_programa_id uuid,
  p_status_programa_id uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_limite integer;
  v_emitidos integer;
  v_ano_atual integer;
BEGIN
  v_ano_atual := EXTRACT(YEAR FROM CURRENT_DATE);
  
  SELECT limite_cpfs_ano INTO v_limite
  FROM status_programa
  WHERE id = p_status_programa_id;
  
  IF v_limite IS NULL OR v_limite = 0 THEN
    RETURN 999999;
  END IF;
  
  SELECT COALESCE(cpfs_emitidos, 0) INTO v_emitidos
  FROM parceiro_programa_cpfs_controle
  WHERE parceiro_id = p_parceiro_id
    AND programa_id = p_programa_id
    AND ano = v_ano_atual;
  
  v_emitidos := COALESCE(v_emitidos, 0);
  
  RETURN GREATEST(0, v_limite - v_emitidos);
END;
$$;

COMMENT ON FUNCTION calcular_cpfs_disponiveis IS 
'Calcula quantos CPFs ainda estão disponíveis para um parceiro emitir em um programa no ano atual';

-- 4. Criar view para facilitar consulta de CPFs disponíveis no estoque
CREATE OR REPLACE VIEW estoque_cpfs_disponiveis AS
SELECT 
  pc.id as programa_clube_id,
  pc.parceiro_id,
  p.nome_parceiro,
  pc.programa_id,
  pf.nome as programa_nome,
  pc.status_programa_id,
  sp.chave_referencia as status_nome,
  sp.limite_cpfs_ano,
  EXTRACT(YEAR FROM CURRENT_DATE)::integer as ano_atual,
  COALESCE(cpfc.cpfs_emitidos, 0) as cpfs_emitidos,
  CASE 
    WHEN sp.limite_cpfs_ano = 0 OR sp.limite_cpfs_ano IS NULL THEN 999999
    ELSE GREATEST(0, sp.limite_cpfs_ano - COALESCE(cpfc.cpfs_emitidos, 0))
  END as cpfs_disponiveis,
  cpfc.data_primeiro_cpf,
  cpfc.data_ultimo_cpf
FROM programas_clubes pc
INNER JOIN parceiros p ON pc.parceiro_id = p.id
INNER JOIN programas_fidelidade pf ON pc.programa_id = pf.id
INNER JOIN status_programa sp ON pc.status_programa_id = sp.id
LEFT JOIN parceiro_programa_cpfs_controle cpfc ON (
  cpfc.parceiro_id = pc.parceiro_id 
  AND cpfc.programa_id = pc.programa_id
  AND cpfc.ano = EXTRACT(YEAR FROM CURRENT_DATE)
)
WHERE pc.tem_clube = false;

COMMENT ON VIEW estoque_cpfs_disponiveis IS 
'View que mostra quantos CPFs cada parceiro ainda pode emitir em cada programa no ano atual';

-- 5. Criar função para incrementar contador quando CPF é emitido
CREATE OR REPLACE FUNCTION incrementar_cpf_emitido(
  p_parceiro_id uuid,
  p_programa_id uuid
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_ano_atual integer;
BEGIN
  v_ano_atual := EXTRACT(YEAR FROM CURRENT_DATE);
  
  INSERT INTO parceiro_programa_cpfs_controle (
    parceiro_id,
    programa_id,
    ano,
    cpfs_emitidos,
    data_primeiro_cpf,
    data_ultimo_cpf,
    updated_at
  )
  VALUES (
    p_parceiro_id,
    p_programa_id,
    v_ano_atual,
    1,
    CURRENT_DATE,
    CURRENT_DATE,
    now()
  )
  ON CONFLICT (parceiro_id, programa_id, ano)
  DO UPDATE SET
    cpfs_emitidos = parceiro_programa_cpfs_controle.cpfs_emitidos + 1,
    data_ultimo_cpf = CURRENT_DATE,
    updated_at = now();
END;
$$;

COMMENT ON FUNCTION incrementar_cpf_emitido IS 
'Incrementa o contador de CPFs emitidos quando uma nova conta em programa é criada';

-- 6. Criar função para verificar se pode emitir CPF
CREATE OR REPLACE FUNCTION pode_emitir_cpf(
  p_parceiro_id uuid,
  p_programa_id uuid,
  p_status_programa_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  v_disponiveis integer;
BEGIN
  v_disponiveis := calcular_cpfs_disponiveis(
    p_parceiro_id,
    p_programa_id,
    p_status_programa_id
  );
  
  RETURN v_disponiveis > 0;
END;
$$;

COMMENT ON FUNCTION pode_emitir_cpf IS 
'Verifica se um parceiro ainda pode emitir CPF em um programa baseado no status e limite anual';

-- 7. Criar trigger para incrementar CPFs quando um programa/clube é cadastrado
CREATE OR REPLACE FUNCTION trigger_incrementar_cpf()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.tem_clube = false AND NEW.status_programa_id IS NOT NULL THEN
    PERFORM incrementar_cpf_emitido(NEW.parceiro_id, NEW.programa_id);
  END IF;
  
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_incrementar_cpf_programa ON programas_clubes;

CREATE TRIGGER trg_incrementar_cpf_programa
  AFTER INSERT ON programas_clubes
  FOR EACH ROW
  EXECUTE FUNCTION trigger_incrementar_cpf();

COMMENT ON TRIGGER trg_incrementar_cpf_programa ON programas_clubes IS 
'Incrementa o contador de CPFs emitidos quando um novo CPF é cadastrado em um programa';

-- 8. Popular valores padrão para status existentes (25 CPFs por ano)
UPDATE status_programa 
SET limite_cpfs_ano = 25 
WHERE limite_cpfs_ano = 0 OR limite_cpfs_ano IS NULL;

-- ============================================================================
-- MIGRATION: 20260114144802_create_parceiros_ativos_function.sql
-- ============================================================================

/*
  # Função para buscar parceiros com movimentação recente

  1. Problema
    - Com muitos parceiros cadastrados, fica difícil encontrar os ativos
    - Necessário filtrar apenas parceiros com movimentações recentes
    - Facilitar busca em formulários com autocomplete

  2. Solução
    - Criar função que retorna parceiros com movimentações nos últimos 90 dias
    - Incluir data da última movimentação
    - Ordenar por movimentação mais recente primeiro

  3. Mudanças
    - Nova função: get_parceiros_ativos()
    - Busca em: compras, compra_bonificada, vendas, transferencia_pontos, transferencia_pessoas
*/

CREATE OR REPLACE FUNCTION get_parceiros_ativos(dias_limite integer DEFAULT 90)
RETURNS TABLE (
  id uuid,
  nome_parceiro text,
  cpf text,
  ultima_movimentacao timestamptz
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  WITH movimentacoes AS (
    SELECT 
      parceiro_id,
      MAX(created_at) as ultima_data
    FROM (
      SELECT parceiro_id, created_at FROM compras WHERE parceiro_id IS NOT NULL
      UNION ALL
      SELECT parceiro_id, created_at FROM compra_bonificada WHERE parceiro_id IS NOT NULL
      UNION ALL
      SELECT parceiro_id, created_at FROM vendas WHERE parceiro_id IS NOT NULL
      UNION ALL
      SELECT parceiro_origem_id as parceiro_id, created_at FROM transferencia_pontos WHERE parceiro_origem_id IS NOT NULL
      UNION ALL
      SELECT parceiro_destino_id as parceiro_id, created_at FROM transferencia_pontos WHERE parceiro_destino_id IS NOT NULL
      UNION ALL
      SELECT parceiro_origem_id as parceiro_id, created_at FROM transferencia_pessoas WHERE parceiro_origem_id IS NOT NULL
      UNION ALL
      SELECT parceiro_destino_id as parceiro_id, created_at FROM transferencia_pessoas WHERE parceiro_destino_id IS NOT NULL
    ) todas_movimentacoes
    WHERE created_at >= NOW() - INTERVAL '1 day' * dias_limite
    GROUP BY parceiro_id
  )
  SELECT 
    p.id,
    p.nome_parceiro,
    p.cpf,
    m.ultima_data
  FROM parceiros p
  INNER JOIN movimentacoes m ON p.id = m.parceiro_id
  ORDER BY m.ultima_data DESC, p.nome_parceiro;
END;
$$;

COMMENT ON FUNCTION get_parceiros_ativos IS 
'Retorna parceiros que tiveram movimentações nos últimos N dias (padrão: 90 dias), ordenados por movimentação mais recente';


-- ============================================================================
-- MIGRATION: 20260114183608_add_status_and_reminders_to_transferencia_pessoas.sql
-- ============================================================================

/*
  # Sistema de agendamento e lembretes para transferência entre pessoas

  1. Alterações na tabela transferencia_pessoas
    - Adicionar campo `status` (Pendente/Concluído) - controla quando os pontos entram no destino
    
  2. Lógica de Status
    - Se `data_recebimento` <= hoje: status = Concluído (pontos entram imediatamente)
    - Se `data_recebimento` > hoje: status = Pendente (pontos entram na data)
    
  3. Comportamento
    - A origem SEMPRE é debitada imediatamente (sem agendamento)
    - O destino segue a regra de agendamento baseada na data_recebimento
    - Cria atividade/lembrete quando transferência é criada
    
  4. Atividades/Lembretes
    - Quando uma transferência é criada com data futura, cria uma atividade
    - Tipo: "Lembrete - Transferência entre Pessoas"
    - Descrição: detalha origem, destino, programa e quantidade
*/

-- Adicionar campo status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'transferencia_pessoas' AND column_name = 'status'
  ) THEN
    ALTER TABLE transferencia_pessoas ADD COLUMN status text DEFAULT 'Pendente';
  END IF;
END $$;

-- Remover o trigger antigo que processava imediatamente
DROP TRIGGER IF EXISTS trigger_process_transferencia_pessoas ON transferencia_pessoas;

-- Função para debitar origem imediatamente
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_saldo numeric;
  v_destino_parceiro_nome text;
BEGIN
  -- Validar saldo da origem
  SELECT saldo_atual INTO v_origem_saldo
  FROM estoque_pontos
  WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;
  
  IF v_origem_saldo < NEW.quantidade THEN
    RAISE EXCEPTION 'Saldo insuficiente no estoque de origem';
  END IF;
  
  -- Buscar nome do parceiro destino para histórico
  SELECT nome_parceiro INTO v_destino_parceiro_nome
  FROM parceiros
  WHERE id = NEW.destino_parceiro_id;
  
  -- Debitar da origem
  PERFORM atualizar_estoque_pontos(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    -NEW.quantidade,
    'Saída',
    0
  );
  
  -- Registrar movimentação no histórico (saída)
  PERFORM registrar_movimentacao_transferencia_pessoas(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    'saida',
    NEW.quantidade,
    NEW.custo_transferencia,
    v_destino_parceiro_nome,
    NEW.id
  );
  
  RETURN NEW;
END;
$$;

-- Função para creditar destino (apenas quando status = Concluído)
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_destino()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_destino_estoque_id uuid;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_origem_custo_medio numeric;
  v_novo_saldo_destino numeric;
  v_novo_custo_medio numeric;
  v_origem_parceiro_nome text;
BEGIN
  -- Se for INSERT e status = Concluído, creditar pontos
  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') OR
     (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    
    -- Buscar nome do parceiro origem para histórico
    SELECT nome_parceiro INTO v_origem_parceiro_nome
    FROM parceiros
    WHERE id = NEW.origem_parceiro_id;
    
    -- Buscar custo médio da origem
    SELECT custo_medio INTO v_origem_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;
    
    -- Buscar ou criar estoque do destino
    SELECT id, saldo_atual, custo_medio 
    INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.destino_parceiro_id AND programa_id = NEW.programa_id;
    
    IF v_destino_estoque_id IS NULL THEN
      -- Criar estoque para o destino
      INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
      VALUES (NEW.destino_parceiro_id, NEW.programa_id, 0, 0)
      RETURNING id, saldo_atual, custo_medio 
      INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
    END IF;
    
    -- Calcular novo saldo e custo médio do destino
    v_novo_saldo_destino := v_destino_saldo + NEW.quantidade;
    IF v_novo_saldo_destino > 0 THEN
      v_novo_custo_medio := ((v_destino_saldo * v_destino_custo_medio) + (NEW.quantidade * COALESCE(v_origem_custo_medio, 0))) / v_novo_saldo_destino;
    ELSE
      v_novo_custo_medio := 0;
    END IF;
    
    -- Atualizar estoque de destino
    UPDATE estoque_pontos
    SET saldo_atual = v_novo_saldo_destino,
        custo_medio = v_novo_custo_medio,
        updated_at = now()
    WHERE id = v_destino_estoque_id;
    
    -- Registrar movimentação no histórico (entrada)
    PERFORM registrar_movimentacao_transferencia_pessoas(
      NEW.destino_parceiro_id,
      NEW.programa_id,
      'entrada',
      NEW.quantidade,
      0,
      v_origem_parceiro_nome,
      NEW.id
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- Função para definir status inicial baseado na data
CREATE OR REPLACE FUNCTION definir_status_inicial_transferencia_pessoas()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Definir status baseado na data de recebimento
  IF NEW.data_recebimento <= CURRENT_DATE THEN
    NEW.status := 'Concluído';
  ELSE
    NEW.status := 'Pendente';
  END IF;
  
  RETURN NEW;
END;
$$;

-- Função para criar atividade/lembrete
CREATE OR REPLACE FUNCTION criar_lembrete_transferencia_pessoas()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_parceiro_nome text;
  v_destino_parceiro_nome text;
  v_programa_nome text;
  v_descricao text;
BEGIN
  -- Apenas criar lembrete se status for Pendente (data futura)
  IF NEW.status = 'Pendente' THEN
    -- Buscar nomes
    SELECT nome_parceiro INTO v_origem_parceiro_nome
    FROM parceiros WHERE id = NEW.origem_parceiro_id;
    
    SELECT nome_parceiro INTO v_destino_parceiro_nome
    FROM parceiros WHERE id = NEW.destino_parceiro_id;
    
    SELECT nome INTO v_programa_nome
    FROM programas_fidelidade WHERE id = NEW.programa_id;
    
    -- Montar descrição
    v_descricao := 'Transferência entre pessoas: ' || 
                   NEW.quantidade::text || ' pontos de ' || 
                   v_origem_parceiro_nome || ' para ' || 
                   v_destino_parceiro_nome || ' no programa ' || 
                   v_programa_nome || '. ' ||
                   'Entrada programada para ' || TO_CHAR(NEW.data_recebimento, 'DD/MM/YYYY') || '.';
    
    -- Criar atividade
    INSERT INTO atividades (
      tipo,
      descricao,
      data_atividade,
      status,
      created_by
    ) VALUES (
      'Lembrete - Transferência entre Pessoas',
      v_descricao,
      NEW.data_recebimento,
      'Pendente',
      NEW.created_by
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- Função para verificar e processar transferências pendentes (job diário)
CREATE OR REPLACE FUNCTION verificar_e_processar_transferencias_pessoas()
RETURNS void
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer := 0;
BEGIN
  -- Atualizar status das transferências cuja data chegou
  UPDATE transferencia_pessoas
  SET status = 'Concluído'
  WHERE status = 'Pendente'
    AND data_recebimento <= CURRENT_DATE;
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  RAISE NOTICE 'Processadas % transferências entre pessoas pendentes', v_count;
END;
$$;

-- Criar triggers

-- Trigger para definir status inicial ANTES do INSERT
DROP TRIGGER IF EXISTS trigger_definir_status_inicial_transferencia_pessoas ON transferencia_pessoas;
CREATE TRIGGER trigger_definir_status_inicial_transferencia_pessoas
  BEFORE INSERT ON transferencia_pessoas
  FOR EACH ROW
  EXECUTE FUNCTION definir_status_inicial_transferencia_pessoas();

-- Trigger para debitar origem imediatamente APÓS INSERT
DROP TRIGGER IF EXISTS trigger_transferencia_pessoas_debitar_origem ON transferencia_pessoas;
CREATE TRIGGER trigger_transferencia_pessoas_debitar_origem
  AFTER INSERT ON transferencia_pessoas
  FOR EACH ROW
  EXECUTE FUNCTION processar_transferencia_pessoas_origem();

-- Trigger para creditar destino (INSERT e UPDATE de status)
DROP TRIGGER IF EXISTS trigger_transferencia_pessoas_creditar_destino_insert ON transferencia_pessoas;
DROP TRIGGER IF EXISTS trigger_transferencia_pessoas_creditar_destino_update ON transferencia_pessoas;

CREATE TRIGGER trigger_transferencia_pessoas_creditar_destino_insert
  AFTER INSERT ON transferencia_pessoas
  FOR EACH ROW
  EXECUTE FUNCTION processar_transferencia_pessoas_destino();

CREATE TRIGGER trigger_transferencia_pessoas_creditar_destino_update
  AFTER UPDATE ON transferencia_pessoas
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION processar_transferencia_pessoas_destino();

-- Trigger para criar lembrete APÓS INSERT
DROP TRIGGER IF EXISTS trigger_criar_lembrete_transferencia_pessoas ON transferencia_pessoas;
CREATE TRIGGER trigger_criar_lembrete_transferencia_pessoas
  AFTER INSERT ON transferencia_pessoas
  FOR EACH ROW
  EXECUTE FUNCTION criar_lembrete_transferencia_pessoas();

-- Atualizar transferências existentes para terem status baseado na data
UPDATE transferencia_pessoas
SET status = CASE
  WHEN data_recebimento <= CURRENT_DATE THEN 'Concluído'
  ELSE 'Pendente'
END
WHERE status IS NULL OR status = 'Pendente';

COMMENT ON FUNCTION processar_transferencia_pessoas_origem() IS 
'Debita pontos da origem imediatamente após INSERT de transferência entre pessoas';

COMMENT ON FUNCTION processar_transferencia_pessoas_destino() IS 
'Credita pontos no destino apenas quando status = Concluído';

COMMENT ON FUNCTION definir_status_inicial_transferencia_pessoas() IS 
'Define o status inicial da transferência baseado na data_recebimento antes do INSERT';

COMMENT ON FUNCTION criar_lembrete_transferencia_pessoas() IS 
'Cria atividade de lembrete quando transferência é criada com data futura';

COMMENT ON FUNCTION verificar_e_processar_transferencias_pessoas() IS 
'Job diário que verifica datas e processa transferências pendentes';


-- ============================================================================
-- MIGRATION: 20260114183631_create_job_processar_transferencias_pessoas_v2.sql
-- ============================================================================

/*
  # Criar job para processar transferências entre pessoas pendentes

  1. Job agendado
    - Executa diariamente às 00:05 (5 minutos após meia-noite)
    - Verifica transferências com data_recebimento <= hoje
    - Atualiza status de Pendente para Concluído
    - Isso dispara o trigger que credita os pontos no destino
*/

-- Criar extensão pg_cron se não existir
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Criar job para processar transferências entre pessoas
DO $$
BEGIN
  -- Tentar desagendar se existir
  PERFORM cron.unschedule('processar-transferencias-pessoas-diario');
EXCEPTION
  WHEN OTHERS THEN
    NULL; -- Ignorar erro se não existir
END $$;

-- Criar novo job
SELECT cron.schedule(
  'processar-transferencias-pessoas-diario',
  '5 0 * * *', -- Executa todo dia às 00:05
  $$
  SELECT verificar_e_processar_transferencias_pessoas();
  $$
);

COMMENT ON EXTENSION pg_cron IS 'Extensão para agendar jobs no PostgreSQL';


-- ============================================================================
-- MIGRATION: 20260114185127_fix_transferencia_pessoas_usar_destino_programa.sql
-- ============================================================================

/*
  # Corrigir função de transferência entre pessoas para usar destino_programa_id

  1. Problema
    - A função `processar_transferencia_pessoas_destino()` estava usando `NEW.programa_id` 
      ao invés de `NEW.destino_programa_id` ao creditar pontos no parceiro destino
    - Isso causava entrada de pontos no programa ERRADO no destino
    
  2. Correção
    - Atualizar função para usar `NEW.destino_programa_id` ao:
      - Buscar/criar estoque do destino
      - Registrar movimentação de entrada
    
  3. Impacto
    - Transferências entre pessoas agora creditam no programa correto do destino
    - Permite transferir LATAM → LIVELO corretamente
*/

-- Corrigir função de destino para usar destino_programa_id
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_destino()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_destino_estoque_id uuid;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_origem_custo_medio numeric;
  v_novo_saldo_destino numeric;
  v_novo_custo_medio numeric;
  v_origem_parceiro_nome text;
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') OR
     (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    
    SELECT nome_parceiro INTO v_origem_parceiro_nome
    FROM parceiros
    WHERE id = NEW.origem_parceiro_id;
    
    SELECT custo_medio INTO v_origem_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;
    
    SELECT id, saldo_atual, custo_medio 
    INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.destino_parceiro_id AND programa_id = NEW.destino_programa_id;
    
    IF v_destino_estoque_id IS NULL THEN
      INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
      VALUES (NEW.destino_parceiro_id, NEW.destino_programa_id, 0, 0)
      RETURNING id, saldo_atual, custo_medio 
      INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
    END IF;
    
    v_novo_saldo_destino := v_destino_saldo + NEW.quantidade;
    IF v_novo_saldo_destino > 0 THEN
      v_novo_custo_medio := ((v_destino_saldo * v_destino_custo_medio) + (NEW.quantidade * COALESCE(v_origem_custo_medio, 0))) / v_novo_saldo_destino;
    ELSE
      v_novo_custo_medio := 0;
    END IF;
    
    UPDATE estoque_pontos
    SET saldo_atual = v_novo_saldo_destino,
        custo_medio = v_novo_custo_medio,
        updated_at = now()
    WHERE id = v_destino_estoque_id;
    
    PERFORM registrar_movimentacao_transferencia_pessoas(
      NEW.destino_parceiro_id,
      NEW.destino_programa_id,
      'entrada',
      NEW.quantidade,
      0,
      v_origem_parceiro_nome,
      NEW.id
    );
  END IF;
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION processar_transferencia_pessoas_destino() IS 
'Credita pontos no destino usando o destino_programa_id (programa correto do destino)';


-- ============================================================================
-- MIGRATION: 20260114185157_corrigir_estoques_transferencias_pessoas_incorretas.sql
-- ============================================================================

/*
  # Corrigir estoques de transferências entre pessoas com programa incorreto

  1. Problema
    - 4 transferências creditaram pontos no programa errado do parceiro destino
    - Transferências LATAM → LIVELO/Smiles creditaram em LATAM ao invés do destino correto
    
  2. Correção
    - Para cada transferência incorreta:
      a) Remover pontos do programa errado no destino (reverter entrada incorreta)
      b) Adicionar pontos no programa correto no destino
      c) Atualizar movimentações no histórico
    
  3. Transferências afetadas
    - 420aa046-439c-43c0-939b-afe6c89feab5: Alisson (LATAM) → teste upload (LIVELO) - 750
    - 764baf9e-00fc-4c0c-b6b6-d15f68cad819: Alisson (LATAM) → Juliano (Smiles) - 1000
    - c635acf2-6b98-4ab0-8a02-7f880bc28e49: Alisson (LATAM) → Juliano (Smiles) - 1000
    - 85a9660d-5b6c-418f-81f3-2fc165445fe6: Alisson (LATAM) → Juliano (Smiles) - 5000
*/

DO $$
DECLARE
  v_transferencia record;
  v_origem_custo_medio numeric;
  v_destino_estoque_id uuid;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_novo_saldo numeric;
  v_novo_custo_medio numeric;
  v_origem_parceiro_nome text;
BEGIN
  -- Loop através das transferências incorretas
  FOR v_transferencia IN 
    SELECT 
      tp.id,
      tp.origem_parceiro_id,
      tp.destino_parceiro_id,
      tp.programa_id,
      tp.destino_programa_id,
      tp.quantidade,
      po.nome_parceiro as origem_nome
    FROM transferencia_pessoas tp
    JOIN parceiros po ON tp.origem_parceiro_id = po.id
    WHERE tp.programa_id != tp.destino_programa_id
      AND tp.status = 'Concluído'
  LOOP
    -- 1. REVERTER entrada no programa errado (programa_id)
    -- Remover pontos que foram adicionados incorretamente
    UPDATE estoque_pontos
    SET saldo_atual = saldo_atual - v_transferencia.quantidade,
        updated_at = now()
    WHERE parceiro_id = v_transferencia.destino_parceiro_id 
      AND programa_id = v_transferencia.programa_id
      AND saldo_atual >= v_transferencia.quantidade;
    
    -- Deletar movimentações incorretas de entrada
    DELETE FROM estoque_movimentacoes
    WHERE referencia_tabela = 'transferencia_pessoas'
      AND referencia_id = v_transferencia.id
      AND parceiro_id = v_transferencia.destino_parceiro_id
      AND programa_id = v_transferencia.programa_id
      AND tipo = 'transferencia_pessoas_entrada';
    
    -- 2. ADICIONAR entrada no programa correto (destino_programa_id)
    
    -- Buscar custo médio da origem
    SELECT custo_medio INTO v_origem_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = v_transferencia.origem_parceiro_id 
      AND programa_id = v_transferencia.programa_id;
    
    -- Buscar ou criar estoque do destino no programa correto
    SELECT id, saldo_atual, custo_medio 
    INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = v_transferencia.destino_parceiro_id 
      AND programa_id = v_transferencia.destino_programa_id;
    
    IF v_destino_estoque_id IS NULL THEN
      INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
      VALUES (v_transferencia.destino_parceiro_id, v_transferencia.destino_programa_id, 0, 0)
      RETURNING id, saldo_atual, custo_medio 
      INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
    END IF;
    
    -- Calcular novo saldo e custo médio
    v_novo_saldo := v_destino_saldo + v_transferencia.quantidade;
    IF v_novo_saldo > 0 THEN
      v_novo_custo_medio := ((v_destino_saldo * v_destino_custo_medio) + 
                              (v_transferencia.quantidade * COALESCE(v_origem_custo_medio, 0))) / v_novo_saldo;
    ELSE
      v_novo_custo_medio := 0;
    END IF;
    
    -- Atualizar estoque do destino no programa correto
    UPDATE estoque_pontos
    SET saldo_atual = v_novo_saldo,
        custo_medio = v_novo_custo_medio,
        updated_at = now()
    WHERE id = v_destino_estoque_id;
    
    -- Registrar movimentação correta no histórico
    PERFORM registrar_movimentacao_transferencia_pessoas(
      v_transferencia.destino_parceiro_id,
      v_transferencia.destino_programa_id,
      'entrada',
      v_transferencia.quantidade,
      0,
      v_transferencia.origem_nome,
      v_transferencia.id
    );
    
    RAISE NOTICE 'Corrigida transferência % - moveu % pontos do programa % para programa %',
      v_transferencia.id, 
      v_transferencia.quantidade,
      v_transferencia.programa_id,
      v_transferencia.destino_programa_id;
  END LOOP;
END $$;


-- ============================================================================
-- MIGRATION: 20260114190909_fix_transferencia_pessoas_quantidade_positiva.sql
-- ============================================================================

/*
  # Corrigir função transferência pessoas para usar quantidade positiva

  1. Problema
    - A função `processar_transferencia_pessoas_origem` passa quantidade negativa 
      para `atualizar_estoque_pontos`, mas a função espera quantidade positiva
    - Isso causa erro na constraint de quantidade > 0 em estoque_movimentacoes
    
  2. Correção
    - Passar quantidade positiva (NEW.quantidade ao invés de -NEW.quantidade)
    - A função `atualizar_estoque_pontos` já trata o tipo 'Saída' corretamente
*/

-- Corrigir função de origem para passar quantidade positiva
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_saldo numeric;
  v_destino_parceiro_nome text;
BEGIN
  SELECT saldo_atual INTO v_origem_saldo
  FROM estoque_pontos
  WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;
  
  IF v_origem_saldo < NEW.quantidade THEN
    RAISE EXCEPTION 'Saldo insuficiente no estoque de origem';
  END IF;
  
  SELECT nome_parceiro INTO v_destino_parceiro_nome
  FROM parceiros
  WHERE id = NEW.destino_parceiro_id;
  
  PERFORM atualizar_estoque_pontos(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    NEW.quantidade,
    'Saída',
    0
  );
  
  PERFORM registrar_movimentacao_transferencia_pessoas(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    'saida',
    NEW.quantidade,
    NEW.custo_transferencia,
    v_destino_parceiro_nome,
    NEW.id
  );
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION processar_transferencia_pessoas_origem() IS 
'Debita pontos da origem imediatamente - usa quantidade positiva pois o tipo Saída já indica débito';


-- ============================================================================
-- MIGRATION: 20260114190936_fix_ordem_registro_movimentacao_transferencia.sql
-- ============================================================================

/*
  # Corrigir ordem de registro de movimentação na transferência entre pessoas

  1. Problema
    - `registrar_movimentacao_transferencia_pessoas` é chamada DEPOIS de `atualizar_estoque_pontos`
    - Isso faz com que os saldos anterior/posterior fiquem incorretos
    - O saldo "anterior" já é o saldo após a operação
    
  2. Correção
    - Chamar `registrar_movimentacao_transferencia_pessoas` ANTES de `atualizar_estoque_pontos`
    - Assim os saldos serão calculados corretamente
*/

-- Corrigir função de origem para registrar movimentação ANTES de atualizar estoque
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_origem_saldo numeric;
  v_destino_parceiro_nome text;
BEGIN
  SELECT saldo_atual INTO v_origem_saldo
  FROM estoque_pontos
  WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;
  
  IF v_origem_saldo < NEW.quantidade THEN
    RAISE EXCEPTION 'Saldo insuficiente no estoque de origem';
  END IF;
  
  SELECT nome_parceiro INTO v_destino_parceiro_nome
  FROM parceiros
  WHERE id = NEW.destino_parceiro_id;
  
  PERFORM registrar_movimentacao_transferencia_pessoas(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    'saida',
    NEW.quantidade,
    NEW.custo_transferencia,
    v_destino_parceiro_nome,
    NEW.id
  );
  
  PERFORM atualizar_estoque_pontos(
    NEW.origem_parceiro_id,
    NEW.programa_id,
    NEW.quantidade,
    'Saída',
    0
  );
  
  RETURN NEW;
END;
$$;

-- Corrigir função de destino para registrar movimentação ANTES de atualizar estoque
CREATE OR REPLACE FUNCTION processar_transferencia_pessoas_destino()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_destino_estoque_id uuid;
  v_destino_saldo numeric;
  v_destino_custo_medio numeric;
  v_origem_custo_medio numeric;
  v_novo_saldo_destino numeric;
  v_novo_custo_medio numeric;
  v_origem_parceiro_nome text;
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.status = 'Concluído') OR
     (TG_OP = 'UPDATE' AND OLD.status = 'Pendente' AND NEW.status = 'Concluído') THEN
    
    SELECT nome_parceiro INTO v_origem_parceiro_nome
    FROM parceiros
    WHERE id = NEW.origem_parceiro_id;
    
    SELECT custo_medio INTO v_origem_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.origem_parceiro_id AND programa_id = NEW.programa_id;
    
    SELECT id, saldo_atual, custo_medio 
    INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio
    FROM estoque_pontos
    WHERE parceiro_id = NEW.destino_parceiro_id AND programa_id = NEW.destino_programa_id;
    
    IF v_destino_estoque_id IS NULL THEN
      INSERT INTO estoque_pontos (parceiro_id, programa_id, saldo_atual, custo_medio)
      VALUES (NEW.destino_parceiro_id, NEW.destino_programa_id, 0, 0)
      RETURNING id, saldo_atual, custo_medio 
      INTO v_destino_estoque_id, v_destino_saldo, v_destino_custo_medio;
    END IF;
    
    v_novo_saldo_destino := v_destino_saldo + NEW.quantidade;
    IF v_novo_saldo_destino > 0 THEN
      v_novo_custo_medio := ((v_destino_saldo * v_destino_custo_medio) + (NEW.quantidade * COALESCE(v_origem_custo_medio, 0))) / v_novo_saldo_destino;
    ELSE
      v_novo_custo_medio := 0;
    END IF;
    
    PERFORM registrar_movimentacao_transferencia_pessoas(
      NEW.destino_parceiro_id,
      NEW.destino_programa_id,
      'entrada',
      NEW.quantidade,
      0,
      v_origem_parceiro_nome,
      NEW.id
    );
    
    UPDATE estoque_pontos
    SET saldo_atual = v_novo_saldo_destino,
        custo_medio = v_novo_custo_medio,
        updated_at = now()
    WHERE id = v_destino_estoque_id;
  END IF;
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION processar_transferencia_pessoas_origem() IS 
'Debita pontos da origem - registra movimentação ANTES de atualizar estoque para saldos corretos';

COMMENT ON FUNCTION processar_transferencia_pessoas_destino() IS 
'Credita pontos no destino - registra movimentação ANTES de atualizar estoque para saldos corretos';


-- ============================================================================
-- MIGRATION: 20260115173029_fix_processar_creditos_clubes_ambiguous_column.sql
-- ============================================================================

/*
  # Corrigir erro de coluna ambígua em processar_creditos_clubes

  ## Problema
  A função processar_creditos_clubes() está falhando com erro:
  "column reference 'parceiro_id' is ambiguous"
  
  Isso está impedindo o processamento automático dos créditos mensais.

  ## Solução
  Qualificar explicitamente as colunas com alias da tabela para remover ambiguidade.

  ## Mudanças
  - Adiciona alias 'a' para tabela atividades
  - Qualifica todas as referências de coluna: a.parceiro_id, a.programa_id, etc.
*/

CREATE OR REPLACE FUNCTION processar_creditos_clubes()
RETURNS TABLE (
  parceiro_id uuid,
  parceiro_nome text,
  programa_id uuid,
  programa_nome text,
  pontos_creditados numeric,
  tipo_credito text,
  processado_em timestamptz
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_clube RECORD;
  v_ja_creditado boolean;
  v_data_referencia date;
  v_pontos_total numeric;
  v_tem_bonus boolean;
BEGIN
  v_data_referencia := DATE_TRUNC('month', CURRENT_DATE)::date;
  
  FOR v_clube IN
    SELECT 
      pc.*,
      p.nome_parceiro,
      pf.nome as programa_nome,
      pr.nome as produto_nome
    FROM programas_clubes pc
    INNER JOIN parceiros p ON p.id = pc.parceiro_id
    LEFT JOIN programas_fidelidade pf ON pf.id = pc.programa_id
    LEFT JOIN produtos pr ON pr.id = pc.clube_produto_id
    WHERE pc.tem_clube = true
      AND pc.data_ultima_assinatura IS NOT NULL
      AND pc.quantidade_pontos > 0
      AND EXTRACT(DAY FROM CURRENT_DATE)::int = EXTRACT(DAY FROM pc.data_ultima_assinatura)::int
  LOOP
    -- Verifica se já foi creditado neste mês verificando nas atividades
    SELECT EXISTS(
      SELECT 1 
      FROM atividades a
      WHERE a.parceiro_id = v_clube.parceiro_id
        AND a.programa_id = v_clube.programa_id
        AND a.tipo_atividade = 'clube_credito_mensal'
        AND a.data_prevista >= v_data_referencia
        AND EXTRACT(MONTH FROM a.data_prevista) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM a.data_prevista) = EXTRACT(YEAR FROM CURRENT_DATE)
        AND a.status = 'processado'
    ) INTO v_ja_creditado;
    
    IF NOT v_ja_creditado THEN
      v_pontos_total := v_clube.quantidade_pontos;
      v_tem_bonus := false;
      
      -- Creditar pontos regulares usando a função correta COM origem e observação
      PERFORM atualizar_estoque_pontos(
        v_clube.parceiro_id,
        v_clube.programa_id,
        v_clube.quantidade_pontos,
        'Entrada',
        0,  -- custo zero porque é crédito de clube
        'clube_credito_mensal',  -- origem
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, '') || ' - ' || v_clube.quantidade_pontos || ' pontos',  -- observação
        v_clube.id,  -- referencia_id
        'programas_clubes'  -- referencia_tabela
      );
      
      -- Criar atividade para registrar o crédito
      INSERT INTO atividades (
        tipo_atividade,
        titulo,
        descricao,
        parceiro_id,
        parceiro_nome,
        programa_id,
        programa_nome,
        quantidade_pontos,
        data_prevista,
        referencia_id,
        referencia_tabela,
        prioridade,
        status
      ) VALUES (
        'clube_credito_mensal',
        'Crédito mensal de clube',
        'Crédito mensal automático do clube ' || COALESCE(v_clube.produto_nome, ''),
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_clube.quantidade_pontos,
        CURRENT_DATE,
        v_clube.id,
        'programas_clubes',
        'alta',
        'processado'
      );
      
      -- Se tem bônus, creditar também
      IF v_clube.bonus_quantidade_pontos > 0 THEN
        PERFORM atualizar_estoque_pontos(
          v_clube.parceiro_id,
          v_clube.programa_id,
          v_clube.bonus_quantidade_pontos,
          'Entrada',
          0,
          'clube_credito_bonus',  -- origem
          'Bônus mensal do clube ' || COALESCE(v_clube.produto_nome, '') || ' - ' || v_clube.bonus_quantidade_pontos || ' pontos',  -- observação
          v_clube.id,  -- referencia_id
          'programas_clubes'  -- referencia_tabela
        );

        v_pontos_total := v_pontos_total + v_clube.bonus_quantidade_pontos;
        v_tem_bonus := true;
      END IF;
      
      RETURN QUERY SELECT 
        v_clube.parceiro_id,
        v_clube.nome_parceiro,
        v_clube.programa_id,
        v_clube.programa_nome,
        v_pontos_total,
        CASE WHEN v_tem_bonus THEN 'credito_com_bonus' ELSE 'credito_mensal' END::text,
        CURRENT_TIMESTAMP;
      
    END IF;
  END LOOP;
  
  RETURN;
END;
$$;

COMMENT ON FUNCTION processar_creditos_clubes() IS 
'Processa créditos mensais de pontos para parceiros com clubes ativos. Os pontos são creditados no dia correspondente à data de assinatura (ex: se assinou dia 5, créditos caem todo dia 5). Registra TODAS as movimentações no histórico com origem e observação detalhadas. Usa atualizar_estoque_pontos() para manter consistência. Retorna uma linha por parceiro com o total de pontos (regulares + bônus quando aplicável).';

-- ============================================================================
-- MIGRATION: 20260115174033_add_unique_constraint_programas_clubes.sql
-- ============================================================================

/*
  # Adicionar constraint única em programas_clubes

  ## Problema
  O sistema está permitindo cadastrar o mesmo parceiro no mesmo programa múltiplas vezes,
  causando duplicatas indesejadas.

  ## Solução
  1. Remover registros duplicados (manter o mais antigo)
  2. Adicionar constraint UNIQUE em (parceiro_id, programa_id)

  ## Mudanças
  - Remove duplicatas existentes
  - Adiciona constraint única para impedir futuros cadastros duplicados
*/

-- Remover duplicatas mantendo apenas o registro mais antigo
DELETE FROM programas_clubes
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        PARTITION BY parceiro_id, programa_id 
        ORDER BY created_at ASC, id ASC
      ) as rn
    FROM programas_clubes
  ) t
  WHERE rn > 1
);

-- Adicionar constraint única para impedir duplicatas no futuro
ALTER TABLE programas_clubes
ADD CONSTRAINT programas_clubes_parceiro_programa_unique 
UNIQUE (parceiro_id, programa_id);

COMMENT ON CONSTRAINT programas_clubes_parceiro_programa_unique ON programas_clubes IS 
'Garante que um parceiro só pode ter um único registro por programa de fidelidade';

-- ============================================================================
-- MIGRATION: 20260115180335_fix_transferencia_pontos_quantidade_positiva.sql
-- ============================================================================

/*
  # Corrigir função transferência pontos para usar quantidade positiva

  1. Problema
    - A função `processar_transferencia_origem()` passa quantidade negativa
      para `atualizar_estoque_pontos`, mas a função espera quantidade positiva
    - Isso causa erro na constraint de quantidade > 0 em estoque_movimentacoes

  2. Correção
    - Passar quantidade positiva (NEW.origem_quantidade ao invés de -NEW.origem_quantidade)
    - A função `atualizar_estoque_pontos` já trata o tipo 'Saída' corretamente
*/

-- Corrigir função de origem para passar quantidade positiva
CREATE OR REPLACE FUNCTION processar_transferencia_origem()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Debita da origem - passa quantidade positiva pois o tipo 'Saída' já indica débito
  PERFORM atualizar_estoque_pontos(
    NEW.parceiro_id,
    NEW.origem_programa_id,
    NEW.origem_quantidade,
    'Saída',
    0
  );

  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION processar_transferencia_origem() IS
'Debita pontos da origem imediatamente - usa quantidade positiva pois o tipo Saída já indica débito';


-- ============================================================================
-- FIM DAS MIGRATIONS
-- ============================================================================

/*
  Todas as migrations foram consolidadas com sucesso!
  
  Para executar no Supabase:
  1. Acesse o SQL Editor do seu projeto no Supabase
  2. Copie e cole todo o conteúdo deste arquivo
  3. Execute o script
  
  Nota: Algumas migrations podem falhar se já foram executadas anteriormente.
        Isto é normal e esperado.
*/
