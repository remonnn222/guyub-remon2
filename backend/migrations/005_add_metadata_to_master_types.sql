-- =====================================================
-- Migration: Add metadata column to app_master_types
-- Version: 005
-- Created: 2025-12-17
-- =====================================================

-- Add metadata column to app_master_types
ALTER TABLE app_master_types
ADD COLUMN metadata JSON NULL AFTER sort_order;
