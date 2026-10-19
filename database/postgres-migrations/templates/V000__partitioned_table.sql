-- ============================================================
-- FILE: VXXX__{domain}_{table_name}_histories.sql
-- DESCRIPTION: High-volume audit/history table with monthly partitioning
-- ============================================================

-- TABLE: {domain}_{table_name}_histories
-- DESCRIPTION: Immutable audit trail, range-partitioned monthly by created_at.
CREATE TABLE {domain}_{table_name}_histories (
  id BIGSERIAL NOT NULL, 
  tenant_id INTEGER NOT NULL,
  entity_id INTEGER NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), 
  created_by INTEGER,
  archived BOOLEAN NOT NULL DEFAULT FALSE, 
  deleted_at TIMESTAMPTZ,
  PRIMARY KEY (id, created_at) -- MUST include partition key
) PARTITION BY RANGE (created_at);

-- Check Constraints
ALTER TABLE {domain}_{table_name}_histories ADD CONSTRAINT chk_{table_name}_histories_type
  CHECK (trigger_type IN ('user', 'system', 'webhook'));

-- Indexes (Inherited by partitions)
CREATE INDEX idx_{table_name}_histories_tenant ON {domain}_{table_name}_histories(tenant_id);
CREATE INDEX idx_{table_name}_histories_entity ON {domain}_{table_name}_histories(entity_id);
CREATE INDEX idx_{table_name}_histories_created_at ON {domain}_{table_name}_histories(created_at);

-- Monthly Partitions (Pre-create for next 12-24 months)
CREATE TABLE {domain}_{table_name}_histories_202601 PARTITION OF {domain}_{table_name}_histories FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE {domain}_{table_name}_histories_202602 PARTITION OF {domain}_{table_name}_histories FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
-- ... add more months ...

-- Default Partition (Catches outliers)
CREATE TABLE {domain}_{table_name}_histories_default PARTITION OF {domain}_{table_name}_histories DEFAULT;

-- Documentation
COMMENT ON TABLE {domain}_{table_name}_histories IS 'Immutable audit trail, partitioned monthly';
COMMENT ON COLUMN {domain}_{table_name}_histories.entity_id IS 'Reference to the parent entity';
COMMENT ON COLUMN {domain}_{table_name}_histories.created_at IS 'Partition key and event timestamp';
COMMENT ON COLUMN {domain}_{table_name}_histories.tenant_id IS 'Multi-tenant identifier';
COMMENT ON COLUMN {domain}_{table_name}_histories.metadata IS 'Flexible JSONB payload for extensible attributes';
COMMENT ON COLUMN {domain}_{table_name}_histories.created_by IS 'User ID who created the record';
COMMENT ON COLUMN {domain}_{table_name}_histories.archived IS 'Soft archive flag; archived records are read-only';
COMMENT ON COLUMN {domain}_{table_name}_histories.deleted_at IS 'Soft delete timestamp; non-null means deleted';