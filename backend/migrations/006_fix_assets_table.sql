-- =====================================================
-- Migration: Fix app_assets table schema
-- Description: Add missing columns and rename existing ones
--              to match the Asset entity
-- =====================================================

-- Add title column
ALTER TABLE app_assets
ADD COLUMN title VARCHAR(255) NULL AFTER kind;

-- Add storage_disk column
ALTER TABLE app_assets
ADD COLUMN storage_disk VARCHAR(50) DEFAULT 'local' AFTER storage_path;

-- Add deleted_at column for soft delete
ALTER TABLE app_assets
ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL AFTER updated_at;

-- Add index on deleted_at
ALTER TABLE app_assets
ADD INDEX idx_assets_deleted_at (deleted_at);

-- Rename original_name to original_filename
ALTER TABLE app_assets
CHANGE COLUMN original_name original_filename VARCHAR(255) NOT NULL;

-- Rename size to file_size
ALTER TABLE app_assets
CHANGE COLUMN size file_size BIGINT UNSIGNED NOT NULL;
