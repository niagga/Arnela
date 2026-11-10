-- Add NIF field to clients table (required)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='clients' AND column_name='nif'
    ) THEN
        ALTER TABLE clients ADD COLUMN nif VARCHAR(20);
    END IF;
END$$;

-- Temporarily copy DNI to NIF for existing records
UPDATE clients SET nif = dni WHERE nif IS NULL;

-- Make NIF required
ALTER TABLE clients ALTER COLUMN nif SET NOT NULL;

-- Make DNI optional
ALTER TABLE clients ALTER COLUMN dni DROP NOT NULL;

-- Drop old unique constraint on DNI
DROP INDEX IF EXISTS idx_clients_dni_unique;

-- Create unique constraint for NIF (excluding soft-deleted records)
CREATE UNIQUE INDEX idx_clients_nif_unique ON clients(nif) WHERE deleted_at IS NULL;

-- Create unique constraint for DNI only when it's not empty (excluding soft-deleted records)
CREATE UNIQUE INDEX idx_clients_dni_unique ON clients(dni) WHERE deleted_at IS NULL AND dni != '';

-- Create index for NIF
-- `000002_create_clients_table` ya crea `idx_clients_nif` sobre la misma columna,
-- así que en una base virgen el nombre existe y el CREATE sin guard abortaba la
-- migración ("relation idx_clients_nif already exists"). IF NOT EXISTS lo vuelve
-- idempotente para bases nuevas y no-op para las que ya aplicaron esta migración.
CREATE INDEX IF NOT EXISTS idx_clients_nif ON clients(nif) WHERE deleted_at IS NULL;
