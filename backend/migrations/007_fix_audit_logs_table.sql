-- =====================================================
-- Migration: Fix audit_logs table schema
-- Description: Add missing columns to match the audit entity
-- =====================================================

-- Add user_name column
ALTER TABLE audit_logs
ADD COLUMN user_name VARCHAR(255) NULL AFTER user_id;

-- Add description column
ALTER TABLE audit_logs
ADD COLUMN description TEXT NULL AFTER new_values;

-- Add http_method column
ALTER TABLE audit_logs
ADD COLUMN http_method VARCHAR(10) NULL AFTER user_agent;

-- Add security_level column
ALTER TABLE audit_logs
ADD COLUMN security_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low' AFTER http_method;

-- Add tags column
ALTER TABLE audit_logs
ADD COLUMN tags JSON NULL AFTER security_level;

-- Update event enum to include more event types
ALTER TABLE audit_logs
MODIFY COLUMN event ENUM('created', 'updated', 'deleted', 'restored', 'login', 'logout', 'viewed', 'exported') NOT NULL;

-- Change auditable_id to support both numeric and UUID types
ALTER TABLE audit_logs
MODIFY COLUMN auditable_id BIGINT UNSIGNED NULL;
