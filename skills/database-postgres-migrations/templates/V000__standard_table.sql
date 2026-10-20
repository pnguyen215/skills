-- ============================================================
-- FILE: VXXX__{domain}_{table_name}.sql
-- DESCRIPTION: Brief description of the migration purpose
-- ============================================================

-- TABLE: {domain}_{table_name}
-- DESCRIPTION: Detailed description of the table's role in the system.
CREATE TABLE {domain}_{table_name} (
  id SERIAL PRIMARY KEY, 
  tenant_id INTEGER NOT NULL, 
  
  -- Domain specific columns
  name VARCHAR(255) NOT NULL,
  amount NUMERIC(15, 4) NOT NULL DEFAULT 0,
  currency VARCHAR(10) DEFAULT 'USD',
  metadata JSONB DEFAULT '{}',
  
  -- Standard audit & lifecycle columns
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), 
  updated_at TIMESTAMPTZ, 
  created_by INTEGER, 
  updated_by INTEGER, 
  archived BOOLEAN NOT NULL DEFAULT FALSE, 
  deleted_at TIMESTAMPTZ
);

-- Constraints
ALTER TABLE {domain}_{table_name} ADD CONSTRAINT uk_{table_name}_name UNIQUE (name);
ALTER TABLE {domain}_{table_name} ADD CONSTRAINT chk_{table_name}_amount CHECK (amount >= 0);

-- Indexes
CREATE INDEX idx_{table_name}_tenant_id ON {domain}_{table_name}(tenant_id);
CREATE INDEX idx_{table_name}_deleted_at ON {domain}_{table_name}(deleted_at);
CREATE INDEX idx_{table_name}_archived_deleted ON {domain}_{table_name}(archived, deleted_at);

-- Foreign Keys
ALTER TABLE {domain}_{table_name} ADD CONSTRAINT fk_{table_name}_tenant FOREIGN KEY (tenant_id) REFERENCES tenant_tenants(id);
ALTER TABLE {domain}_{table_name} ADD CONSTRAINT fk_{table_name}_created_by FOREIGN KEY (created_by) REFERENCES iam_users(id);
ALTER TABLE {domain}_{table_name} ADD CONSTRAINT fk_{table_name}_updated_by FOREIGN KEY (updated_by) REFERENCES iam_users(id);

-- Documentation (Zero Exceptions)
COMMENT ON TABLE {domain}_{table_name} IS 'Detailed description of the table';
COMMENT ON COLUMN {domain}_{table_name}.tenant_id IS 'Multi-tenant identifier';
COMMENT ON COLUMN {domain}_{table_name}.name IS 'Unique name of the entity';
COMMENT ON COLUMN {domain}_{table_name}.amount IS 'Financial amount, stored with 4 decimal precision';
COMMENT ON COLUMN {domain}_{table_name}.currency IS 'ISO 4217 currency code';
COMMENT ON COLUMN {domain}_{table_name}.metadata IS 'Flexible JSONB payload for extensible attributes';
COMMENT ON COLUMN {domain}_{table_name}.created_at IS 'Timestamp of record creation';
COMMENT ON COLUMN {domain}_{table_name}.updated_at IS 'Timestamp of last modification';
COMMENT ON COLUMN {domain}_{table_name}.created_by IS 'User ID who created the record';
COMMENT ON COLUMN {domain}_{table_name}.updated_by IS 'User ID who last modified the record';
COMMENT ON COLUMN {domain}_{table_name}.archived IS 'Soft archive flag; archived records are read-only';
COMMENT ON COLUMN {domain}_{table_name}.deleted_at IS 'Soft delete timestamp; non-null means deleted';