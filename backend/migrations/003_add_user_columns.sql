-- =====================================================
-- Migration: Add missing user columns
-- Version: 003
-- Created: 2025-12-17
-- =====================================================

-- Add last_login_at column
ALTER TABLE users ADD COLUMN last_login_at TIMESTAMP NULL AFTER type;

-- Add last_login_ip column
ALTER TABLE users ADD COLUMN last_login_ip VARCHAR(45) NULL AFTER last_login_at;

-- Add preferences column
ALTER TABLE users ADD COLUMN preferences JSON NULL AFTER last_login_ip;

-- Add two_factor_recovery_codes column
ALTER TABLE users ADD COLUMN two_factor_recovery_codes TEXT NULL AFTER two_factor_secret;

-- Add two_factor_confirmed_at column
ALTER TABLE users ADD COLUMN two_factor_confirmed_at TIMESTAMP NULL AFTER two_factor_recovery_codes;

-- =====================================================
-- END OF MIGRATION
-- =====================================================
