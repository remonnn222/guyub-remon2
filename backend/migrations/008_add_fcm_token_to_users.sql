-- =====================================================
-- Add FCM Token Column to Users Table
-- Migration: 008_add_fcm_token_to_users.sql
-- Created: 2025-12-17
-- =====================================================

ALTER TABLE users
ADD COLUMN fcm_token TEXT NULL AFTER phone,
ADD INDEX idx_users_fcm_token (fcm_token(255));