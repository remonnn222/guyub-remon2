-- =====================================================
-- Guyub Platform - Family Hierarchy Database Schema
-- Version: 2.0.0
-- Created: 2025-12-17
-- =====================================================

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NULL,
    avatar VARCHAR(500) NULL,
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    type ENUM('internal', 'customer', 'agent') NOT NULL DEFAULT 'customer',
    two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    two_factor_secret VARCHAR(255) NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_users_email (email),
    INDEX idx_users_status (status),
    INDEX idx_users_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 2. ROLES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    guard_name VARCHAR(50) NOT NULL DEFAULT 'web',
    description VARCHAR(500) NULL,
    level INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_role_name_guard (name, guard_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. PERMISSIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    guard_name VARCHAR(50) NOT NULL DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_permission_name_guard (name, guard_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. ROLE HAS PERMISSIONS (Pivot)
-- =====================================================
CREATE TABLE IF NOT EXISTS role_has_permissions (
    permission_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (permission_id, role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 5. MODEL HAS ROLES (Pivot - Polymorphic)
-- =====================================================
CREATE TABLE IF NOT EXISTS model_has_roles (
    role_id BIGINT UNSIGNED NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    INDEX idx_model_has_roles_model (model_type, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 6. MODEL HAS PERMISSIONS (Pivot - Polymorphic)
-- =====================================================
CREATE TABLE IF NOT EXISTS model_has_permissions (
    permission_id BIGINT UNSIGNED NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    INDEX idx_model_has_permissions_model (model_type, model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 7. FAMILIES TABLE (Family Groups/Clans)
-- =====================================================
CREATE TABLE IF NOT EXISTS families (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    origin VARCHAR(255) NULL,
    motto VARCHAR(500) NULL,
    coat_of_arms VARCHAR(500) NULL,
    cover_image VARCHAR(500) NULL,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    invite_code VARCHAR(20) NOT NULL UNIQUE,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_families_invite_code (invite_code),
    INDEX idx_families_created_by (created_by),
    INDEX idx_families_public (is_public)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 8. PERSONS TABLE (Family Tree Nodes)
-- =====================================================
CREATE TABLE IF NOT EXISTS persons (
    id CHAR(36) PRIMARY KEY,
    family_id CHAR(36) NOT NULL,

    -- Basic Info
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100) NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,

    -- Life Dates
    birth_date DATE NULL,
    birth_place VARCHAR(255) NULL,
    death_date DATE NULL,
    death_place VARCHAR(255) NULL,
    is_alive BOOLEAN NOT NULL DEFAULT TRUE,

    -- Profile
    photo_url VARCHAR(500) NULL,
    bio TEXT NULL,
    occupation VARCHAR(255) NULL,
    education VARCHAR(255) NULL,

    -- Contact (for living members)
    email VARCHAR(255) NULL,
    phone VARCHAR(50) NULL,
    address TEXT NULL,

    -- Tree info
    generation_level INT NOT NULL DEFAULT 0,

    -- Metadata
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (family_id) REFERENCES families(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_persons_family (family_id),
    INDEX idx_persons_generation (family_id, generation_level),
    INDEX idx_persons_name (first_name, last_name),
    INDEX idx_persons_alive (is_alive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 9. FAMILY MEMBERS TABLE (User Access to Families)
-- =====================================================
CREATE TABLE IF NOT EXISTS family_members (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    family_id CHAR(36) NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    person_id CHAR(36) NULL,
    role ENUM('owner', 'admin', 'editor', 'viewer') NOT NULL DEFAULT 'viewer',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (family_id) REFERENCES families(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE SET NULL,
    UNIQUE KEY unique_family_member (family_id, user_id),
    INDEX idx_family_members_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 10. RELATIONSHIPS TABLE (Connections Between Persons)
-- =====================================================
CREATE TABLE IF NOT EXISTS relationships (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    person_id CHAR(36) NOT NULL,
    related_person_id CHAR(36) NOT NULL,
    type ENUM(
        'parent', 'child', 'spouse', 'sibling',
        'step_parent', 'step_child',
        'adoptive_parent', 'adopted_child'
    ) NOT NULL,

    -- For spouse relationships
    marriage_status ENUM('married', 'divorced', 'widowed', 'separated', 'engaged', 'partner') NULL,
    marriage_date DATE NULL,
    marriage_place VARCHAR(255) NULL,
    divorce_date DATE NULL,

    -- Metadata
    notes TEXT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE,
    FOREIGN KEY (related_person_id) REFERENCES persons(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    UNIQUE KEY unique_relationship (person_id, related_person_id, type),
    INDEX idx_relationships_person (person_id),
    INDEX idx_relationships_related (related_person_id),
    INDEX idx_relationships_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 11. TREE POSITIONS TABLE (For Visualization)
-- =====================================================
CREATE TABLE IF NOT EXISTS tree_positions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    person_id CHAR(36) NOT NULL UNIQUE,
    family_id CHAR(36) NOT NULL,
    x DOUBLE NOT NULL DEFAULT 0,
    y DOUBLE NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 0,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE,
    FOREIGN KEY (family_id) REFERENCES families(id) ON DELETE CASCADE,
    INDEX idx_tree_positions_family (family_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 12. AUDIT LOGS TABLE (IMMUTABLE)
-- =====================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    event ENUM('created', 'updated', 'deleted', 'restored') NOT NULL,
    auditable_type VARCHAR(255) NOT NULL,
    auditable_id VARCHAR(36) NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    url VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_logs_user (user_id),
    INDEX idx_audit_logs_auditable (auditable_type, auditable_id),
    INDEX idx_audit_logs_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 13. ACTIVITY LOGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS activity_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    activity_type ENUM(
        'login', 'logout', 'password_reset', 'profile_update', 'failed_login',
        'family_created', 'family_updated', 'family_deleted',
        'person_added', 'person_updated', 'person_deleted',
        'relationship_added', 'relationship_removed',
        'tree_updated', 'member_invited', 'member_joined'
    ) NOT NULL,
    description VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    device_type VARCHAR(50) NULL,
    browser VARCHAR(100) NULL,
    platform VARCHAR(100) NULL,
    location VARCHAR(255) NULL,
    metadata JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_activity_logs_user (user_id),
    INDEX idx_activity_logs_type (activity_type),
    INDEX idx_activity_logs_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 14. ASSETS TABLE (File Uploads)
-- =====================================================
CREATE TABLE IF NOT EXISTS app_assets (
    id CHAR(36) PRIMARY KEY,
    ref_id VARCHAR(36) NULL,
    kind VARCHAR(50) NULL,
    original_name VARCHAR(255) NOT NULL,
    storage_path VARCHAR(500) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size BIGINT UNSIGNED NOT NULL,
    metadata JSON NULL,
    uploaded_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_assets_ref (ref_id, kind),
    INDEX idx_assets_uploaded_by (uploaded_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 15. MASTER TYPES TABLE (Categories)
-- =====================================================
CREATE TABLE IF NOT EXISTS app_master_types (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT UNSIGNED NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES app_master_types(id) ON DELETE CASCADE,
    INDEX idx_master_types_parent (parent_id),
    INDEX idx_master_types_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 16. MASTER VALUES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS app_master_values (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type_id BIGINT UNSIGNED NOT NULL,
    parent_value_id BIGINT UNSIGNED NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    metadata JSON NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES app_master_types(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_value_id) REFERENCES app_master_values(id) ON DELETE CASCADE,
    UNIQUE KEY unique_value_code_type (type_id, code),
    INDEX idx_master_values_type (type_id),
    INDEX idx_master_values_parent (parent_value_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 17. SESSIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload TEXT NOT NULL,
    last_activity INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_sessions_user (user_id),
    INDEX idx_sessions_last_activity (last_activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 18. PERSONAL ACCESS TOKENS
-- =====================================================
CREATE TABLE IF NOT EXISTS personal_access_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    abilities TEXT NULL,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tokens_tokenable (tokenable_type, tokenable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TRIGGERS FOR AUDIT LOG IMMUTABILITY
-- =====================================================
DELIMITER //

CREATE TRIGGER prevent_audit_update BEFORE UPDATE ON audit_logs
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit logs cannot be modified';
END//

CREATE TRIGGER prevent_audit_delete BEFORE DELETE ON audit_logs
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Audit logs cannot be deleted';
END//

DELIMITER ;

-- =====================================================
-- END OF MIGRATION
-- =====================================================
