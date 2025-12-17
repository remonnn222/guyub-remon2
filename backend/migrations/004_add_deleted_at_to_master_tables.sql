-- =====================================================
-- Migration: Add deleted_at column to master tables
-- Version: 004
-- Created: 2025-12-17
-- =====================================================

-- Add deleted_at to app_master_types
ALTER TABLE app_master_types
ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL,
ADD INDEX idx_master_types_deleted_at (deleted_at);

-- Add deleted_at to app_master_values
ALTER TABLE app_master_values
ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL,
ADD INDEX idx_master_values_deleted_at (deleted_at);
