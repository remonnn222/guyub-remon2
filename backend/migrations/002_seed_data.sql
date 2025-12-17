-- =====================================================
-- Guyub Platform - Seed Data
-- Version: 2.0.0
-- Created: 2025-12-17
-- =====================================================

-- =====================================================
-- 1. SEED ROLES
-- =====================================================
INSERT INTO roles (name, guard_name, description, level) VALUES
('super_admin', 'web', 'Full system access - can manage everything', 100),
('admin', 'web', 'Administrative access - can manage users and settings', 90),
('member', 'web', 'Regular member - can manage their family trees', 50),
('viewer', 'web', 'View only access', 10);

-- =====================================================
-- 2. SEED PERMISSIONS
-- =====================================================
INSERT INTO permissions (name, guard_name) VALUES
-- User permissions
('users.view', 'web'),
('users.create', 'web'),
('users.edit', 'web'),
('users.delete', 'web'),

-- Role permissions
('roles.view', 'web'),
('roles.create', 'web'),
('roles.edit', 'web'),
('roles.delete', 'web'),

-- Family permissions
('families.view', 'web'),
('families.create', 'web'),
('families.edit', 'web'),
('families.delete', 'web'),
('families.invite', 'web'),

-- Person permissions
('persons.view', 'web'),
('persons.create', 'web'),
('persons.edit', 'web'),
('persons.delete', 'web'),

-- Relationship permissions
('relationships.view', 'web'),
('relationships.create', 'web'),
('relationships.edit', 'web'),
('relationships.delete', 'web'),

-- Tree permissions
('tree.view', 'web'),
('tree.edit', 'web'),
('tree.export', 'web'),

-- Audit permissions
('audit.view', 'web'),
('audit.export', 'web'),

-- Analytics permissions
('analytics.view', 'web'),

-- Settings permissions
('settings.view', 'web'),
('settings.edit', 'web');

-- =====================================================
-- 3. ASSIGN PERMISSIONS TO ROLES
-- =====================================================

-- Super Admin gets all permissions
INSERT INTO role_has_permissions (permission_id, role_id)
SELECT p.id, r.id
FROM permissions p, roles r
WHERE r.name = 'super_admin';

-- Admin gets most permissions (except role management)
INSERT INTO role_has_permissions (permission_id, role_id)
SELECT p.id, r.id
FROM permissions p, roles r
WHERE r.name = 'admin' AND p.name NOT LIKE 'roles.%';

-- Member gets family/person/tree permissions
INSERT INTO role_has_permissions (permission_id, role_id)
SELECT p.id, r.id
FROM permissions p, roles r
WHERE r.name = 'member' AND (
    p.name LIKE 'families.%' OR
    p.name LIKE 'persons.%' OR
    p.name LIKE 'relationships.%' OR
    p.name LIKE 'tree.%'
);

-- Viewer gets view-only permissions
INSERT INTO role_has_permissions (permission_id, role_id)
SELECT p.id, r.id
FROM permissions p, roles r
WHERE r.name = 'viewer' AND p.name LIKE '%.view';

-- =====================================================
-- 4. SEED ADMIN USER
-- Password: Admin@123 (hashed with bcrypt)
-- =====================================================
INSERT INTO users (name, email, password, status, type, email_verified_at, created_at)
VALUES (
    'Super Admin',
    'admin@guyub.id',
    '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3pPVJDZQqPw6Q8/X5hBB8j8WS5Iq',
    'active',
    'internal',
    NOW(),
    NOW()
);

-- Assign super_admin role to admin user
INSERT INTO model_has_roles (role_id, model_type, model_id)
SELECT r.id, 'users', u.id
FROM roles r, users u
WHERE r.name = 'super_admin' AND u.email = 'admin@guyub.id';

-- =====================================================
-- 5. SEED DEMO USER (for testing)
-- Password: Demo@123
-- =====================================================
INSERT INTO users (name, email, password, status, type, email_verified_at, created_at)
VALUES (
    'Budi Kusuma',
    'budi@guyub.id',
    '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3pPVJDZQqPw6Q8/X5hBB8j8WS5Iq',
    'active',
    'customer',
    NOW(),
    NOW()
);

-- Assign member role to demo user
INSERT INTO model_has_roles (role_id, model_type, model_id)
SELECT r.id, 'users', u.id
FROM roles r, users u
WHERE r.name = 'member' AND u.email = 'budi@guyub.id';

-- =====================================================
-- 6. SEED KUSUMA FAMILY (Demo Family Tree)
-- =====================================================
SET @demo_user_id = (SELECT id FROM users WHERE email = 'budi@guyub.id');
SET @family_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

INSERT INTO families (id, name, description, origin, motto, is_public, invite_code, created_by)
VALUES (
    @family_id,
    'Keluarga Kusuma',
    'Keluarga besar Kusuma yang berasal dari Yogyakarta. Silsilah keluarga ini mencakup lima generasi, dimulai dari Raden Mas Soekarno Kusuma dan Raden Ayu Kartini Wulandari.',
    'Yogyakarta, Indonesia',
    'Bersatu Kita Teguh, Bercerai Kita Runtuh',
    TRUE,
    'KUSUMA01',
    @demo_user_id
);

-- Add demo user as family owner
INSERT INTO family_members (family_id, user_id, role, joined_at)
VALUES (@family_id, @demo_user_id, 'owner', NOW());

-- =====================================================
-- 7. SEED PERSONS (5 Generations - Kusuma Family)
-- =====================================================

-- Generation 1 - Great Grandparents (1920s)
SET @person_soekarno = '11111111-1111-1111-1111-111111111111';
SET @person_kartini = '11111111-1111-1111-1111-111111111112';

INSERT INTO persons (id, family_id, first_name, last_name, nickname, gender, birth_date, birth_place, death_date, death_place, is_alive, bio, occupation, generation_level, created_by) VALUES
(@person_soekarno, @family_id, 'Soekarno', 'Kusuma', 'Eyang Kakung', 'male', '1922-03-15', 'Yogyakarta', '1998-08-20', 'Yogyakarta', FALSE, 'Pendiri keluarga Kusuma. Seorang pegawai negeri yang dihormati di Yogyakarta. Beliau dikenal karena kebijaksanaan dan dedikasinya kepada keluarga.', 'Pegawai Negeri', 1, @demo_user_id),
(@person_kartini, @family_id, 'Kartini', 'Wulandari', 'Eyang Putri', 'female', '1925-04-21', 'Surakarta', '2005-12-10', 'Yogyakarta', FALSE, 'Istri tercinta Soekarno Kusuma. Seorang ibu yang penuh kasih sayang dan guru yang dihormati.', 'Guru', 1, @demo_user_id);

-- Generation 2 - Grandparents (1945-1955)
SET @person_bambang = '22222222-2222-2222-2222-222222222221';
SET @person_sri = '22222222-2222-2222-2222-222222222222';
SET @person_siti = '22222222-2222-2222-2222-222222222223';
SET @person_ahmad = '22222222-2222-2222-2222-222222222224';

INSERT INTO persons (id, family_id, first_name, last_name, nickname, gender, birth_date, birth_place, death_date, death_place, is_alive, bio, occupation, education, generation_level, created_by) VALUES
(@person_bambang, @family_id, 'Bambang', 'Kusuma', 'Pak De', 'male', '1948-07-12', 'Yogyakarta', '2020-03-15', 'Jakarta', FALSE, 'Anak sulung Soekarno dan Kartini. Seorang insinyur sukses yang membangun banyak infrastruktur di Indonesia.', 'Insinyur Sipil', 'ITB - Teknik Sipil', 2, @demo_user_id),
(@person_sri, @family_id, 'Sri', 'Rahayu', 'Bu De', 'female', '1952-09-03', 'Bandung', NULL, NULL, TRUE, 'Istri setia Bambang Kusuma. Seorang dokter yang mengabdikan hidupnya untuk membantu masyarakat.', 'Dokter', 'Universitas Indonesia - Kedokteran', 2, @demo_user_id),
(@person_siti, @family_id, 'Siti', 'Kusuma', 'Bu Lik', 'female', '1950-11-25', 'Yogyakarta', NULL, NULL, TRUE, 'Anak kedua Soekarno dan Kartini. Seorang pengusaha batik yang sukses di Yogyakarta.', 'Pengusaha Batik', 'UGM - Ekonomi', 2, @demo_user_id),
(@person_ahmad, @family_id, 'Ahmad', 'Wijaya', 'Pak Lik', 'male', '1948-05-17', 'Semarang', '2015-06-22', 'Yogyakarta', FALSE, 'Suami Siti Kusuma. Seorang dosen yang dihormati di UGM.', 'Dosen', 'UGM - Sastra Jawa', 2, @demo_user_id);

-- Generation 3 - Parents (1970-1985)
SET @person_budi = '33333333-3333-3333-3333-333333333331';
SET @person_dewi = '33333333-3333-3333-3333-333333333332';
SET @person_ratna = '33333333-3333-3333-3333-333333333333';
SET @person_hendra = '33333333-3333-3333-3333-333333333334';
SET @person_agus = '33333333-3333-3333-3333-333333333335';
SET @person_maya = '33333333-3333-3333-3333-333333333336';

INSERT INTO persons (id, family_id, first_name, last_name, nickname, gender, birth_date, birth_place, is_alive, bio, occupation, education, email, phone, address, generation_level, created_by) VALUES
(@person_budi, @family_id, 'Budi', 'Kusuma', 'Pak Budi', 'male', '1975-03-28', 'Jakarta', TRUE, 'Anak sulung Bambang dan Sri. Seorang arsitek sukses yang telah mendesain banyak gedung ikonik di Jakarta.', 'Arsitek', 'ITB - Arsitektur', 'budi.kusuma@email.com', '+62812345678', 'Jl. Menteng Raya No. 123, Jakarta Pusat', 3, @demo_user_id),
(@person_dewi, @family_id, 'Dewi', 'Lestari', 'Bu Dewi', 'female', '1978-08-14', 'Surabaya', TRUE, 'Istri Budi Kusuma. Seorang penulis novel terkenal dan aktivis pendidikan.', 'Penulis', 'UI - Sastra Indonesia', 'dewi.lestari@email.com', '+62812345679', 'Jl. Menteng Raya No. 123, Jakarta Pusat', 3, @demo_user_id),
(@person_ratna, @family_id, 'Ratna', 'Kusuma', 'Bu Ratna', 'female', '1972-12-05', 'Jakarta', TRUE, 'Anak kedua Bambang dan Sri. Seorang psikolog anak yang memiliki klinik sendiri.', 'Psikolog', 'UI - Psikologi', 'ratna.kusuma@email.com', '+62812345680', 'Jl. Kemang Raya No. 45, Jakarta Selatan', 3, @demo_user_id),
(@person_hendra, @family_id, 'Hendra', 'Santoso', 'Pak Hendra', 'male', '1970-06-18', 'Bandung', TRUE, 'Suami Ratna Kusuma. Seorang pengusaha restoran yang sukses.', 'Pengusaha', 'Unpad - Manajemen', 'hendra.santoso@email.com', '+62812345681', 'Jl. Kemang Raya No. 45, Jakarta Selatan', 3, @demo_user_id),
(@person_agus, @family_id, 'Agus', 'Wijaya', 'Pak Agus', 'male', '1976-09-30', 'Yogyakarta', TRUE, 'Anak Siti dan Ahmad Wijaya. Seorang programmer dan pendiri startup teknologi.', 'CEO Startup', 'ITS - Informatika', 'agus.wijaya@email.com', '+62812345682', 'Jl. BSD Boulevard No. 88, Tangerang Selatan', 3, @demo_user_id),
(@person_maya, @family_id, 'Maya', 'Sari', 'Bu Maya', 'female', '1980-02-14', 'Jakarta', TRUE, 'Istri Agus Wijaya. Seorang desainer interior dan ibu rumah tangga.', 'Desainer Interior', 'Trisakti - Desain Interior', 'maya.sari@email.com', '+62812345683', 'Jl. BSD Boulevard No. 88, Tangerang Selatan', 3, @demo_user_id);

-- Generation 4 - Current Generation (1995-2010)
SET @person_arya = '44444444-4444-4444-4444-444444444441';
SET @person_putri = '44444444-4444-4444-4444-444444444442';
SET @person_dimas = '44444444-4444-4444-4444-444444444443';
SET @person_ayu = '44444444-4444-4444-4444-444444444444';
SET @person_rizki = '44444444-4444-4444-4444-444444444445';
SET @person_sarah = '44444444-4444-4444-4444-444444444446';

INSERT INTO persons (id, family_id, first_name, last_name, nickname, gender, birth_date, birth_place, is_alive, bio, occupation, education, email, phone, generation_level, created_by) VALUES
(@person_arya, @family_id, 'Arya', 'Kusuma', 'Arya', 'male', '1998-05-20', 'Jakarta', TRUE, 'Anak sulung Budi dan Dewi. Mahasiswa S2 di MIT, jurusan Computer Science.', 'Mahasiswa S2', 'MIT - Computer Science', 'arya.kusuma@email.com', '+62812345684', 4, @demo_user_id),
(@person_putri, @family_id, 'Putri', 'Kusuma', 'Putri', 'female', '2001-11-15', 'Jakarta', TRUE, 'Anak kedua Budi dan Dewi. Mahasiswa kedokteran di UI.', 'Mahasiswa', 'UI - Kedokteran', 'putri.kusuma@email.com', '+62812345685', 4, @demo_user_id),
(@person_dimas, @family_id, 'Dimas', 'Santoso', 'Dimas', 'male', '1999-07-08', 'Jakarta', TRUE, 'Anak sulung Ratna dan Hendra. Seorang chef muda yang berbakat.', 'Chef', 'Le Cordon Bleu - Culinary', 'dimas.santoso@email.com', '+62812345686', 4, @demo_user_id),
(@person_ayu, @family_id, 'Ayu', 'Santoso', 'Ayu', 'female', '2003-03-25', 'Jakarta', TRUE, 'Anak kedua Ratna dan Hendra. Siswa SMA yang berprestasi.', 'Pelajar', 'SMA Negeri 3 Jakarta', 'ayu.santoso@email.com', '+62812345687', 4, @demo_user_id),
(@person_rizki, @family_id, 'Rizki', 'Wijaya', 'Rizki', 'male', '2000-12-01', 'Tangerang', TRUE, 'Anak sulung Agus dan Maya. Seorang content creator dan influencer.', 'Content Creator', 'Binus - DKV', 'rizki.wijaya@email.com', '+62812345688', 4, @demo_user_id),
(@person_sarah, @family_id, 'Sarah', 'Anderson', 'Sarah', 'female', '1999-04-10', 'Boston, USA', TRUE, 'Istri Arya Kusuma. Seorang data scientist dari Amerika.', 'Data Scientist', 'Stanford - Data Science', 'sarah.anderson@email.com', '+1234567890', 4, @demo_user_id);

-- Generation 5 - Youngest Generation (2020+)
SET @person_baby_adam = '55555555-5555-5555-5555-555555555551';
SET @person_baby_zahra = '55555555-5555-5555-5555-555555555552';

INSERT INTO persons (id, family_id, first_name, last_name, nickname, gender, birth_date, birth_place, is_alive, bio, generation_level, created_by) VALUES
(@person_baby_adam, @family_id, 'Adam', 'Kusuma', 'Baby Adam', 'male', '2023-06-15', 'Boston, USA', TRUE, 'Anak pertama Arya dan Sarah. Generasi penerus keluarga Kusuma.', 5, @demo_user_id),
(@person_baby_zahra, @family_id, 'Zahra', 'Santoso', 'Baby Zahra', 'female', '2024-01-20', 'Jakarta', TRUE, 'Anak pertama Dimas. Bayi yang ceria dan menggemaskan.', 5, @demo_user_id);

-- =====================================================
-- 8. SEED RELATIONSHIPS
-- =====================================================

-- Generation 1 - Great Grandparents Marriage
INSERT INTO relationships (person_id, related_person_id, type, marriage_status, marriage_date, marriage_place, created_by) VALUES
(@person_soekarno, @person_kartini, 'spouse', 'married', '1945-08-17', 'Yogyakarta', @demo_user_id),
(@person_kartini, @person_soekarno, 'spouse', 'married', '1945-08-17', 'Yogyakarta', @demo_user_id);

-- Generation 1 -> 2 (Parent-Child)
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
-- Soekarno & Kartini -> Bambang
(@person_soekarno, @person_bambang, 'parent', @demo_user_id),
(@person_kartini, @person_bambang, 'parent', @demo_user_id),
(@person_bambang, @person_soekarno, 'child', @demo_user_id),
(@person_bambang, @person_kartini, 'child', @demo_user_id),
-- Soekarno & Kartini -> Siti
(@person_soekarno, @person_siti, 'parent', @demo_user_id),
(@person_kartini, @person_siti, 'parent', @demo_user_id),
(@person_siti, @person_soekarno, 'child', @demo_user_id),
(@person_siti, @person_kartini, 'child', @demo_user_id);

-- Generation 2 Siblings
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
(@person_bambang, @person_siti, 'sibling', @demo_user_id),
(@person_siti, @person_bambang, 'sibling', @demo_user_id);

-- Generation 2 Marriages
INSERT INTO relationships (person_id, related_person_id, type, marriage_status, marriage_date, marriage_place, created_by) VALUES
(@person_bambang, @person_sri, 'spouse', 'widowed', '1972-06-15', 'Jakarta', @demo_user_id),
(@person_sri, @person_bambang, 'spouse', 'widowed', '1972-06-15', 'Jakarta', @demo_user_id),
(@person_siti, @person_ahmad, 'spouse', 'widowed', '1970-04-20', 'Yogyakarta', @demo_user_id),
(@person_ahmad, @person_siti, 'spouse', 'widowed', '1970-04-20', 'Yogyakarta', @demo_user_id);

-- Generation 2 -> 3 (Parent-Child)
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
-- Bambang & Sri -> Budi
(@person_bambang, @person_budi, 'parent', @demo_user_id),
(@person_sri, @person_budi, 'parent', @demo_user_id),
(@person_budi, @person_bambang, 'child', @demo_user_id),
(@person_budi, @person_sri, 'child', @demo_user_id),
-- Bambang & Sri -> Ratna
(@person_bambang, @person_ratna, 'parent', @demo_user_id),
(@person_sri, @person_ratna, 'parent', @demo_user_id),
(@person_ratna, @person_bambang, 'child', @demo_user_id),
(@person_ratna, @person_sri, 'child', @demo_user_id),
-- Siti & Ahmad -> Agus
(@person_siti, @person_agus, 'parent', @demo_user_id),
(@person_ahmad, @person_agus, 'parent', @demo_user_id),
(@person_agus, @person_siti, 'child', @demo_user_id),
(@person_agus, @person_ahmad, 'child', @demo_user_id);

-- Generation 3 Siblings
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
(@person_budi, @person_ratna, 'sibling', @demo_user_id),
(@person_ratna, @person_budi, 'sibling', @demo_user_id);

-- Generation 3 Marriages
INSERT INTO relationships (person_id, related_person_id, type, marriage_status, marriage_date, marriage_place, created_by) VALUES
(@person_budi, @person_dewi, 'spouse', 'married', '1997-12-25', 'Jakarta', @demo_user_id),
(@person_dewi, @person_budi, 'spouse', 'married', '1997-12-25', 'Jakarta', @demo_user_id),
(@person_ratna, @person_hendra, 'spouse', 'married', '1995-08-10', 'Bandung', @demo_user_id),
(@person_hendra, @person_ratna, 'spouse', 'married', '1995-08-10', 'Bandung', @demo_user_id),
(@person_agus, @person_maya, 'spouse', 'married', '2000-05-05', 'Yogyakarta', @demo_user_id),
(@person_maya, @person_agus, 'spouse', 'married', '2000-05-05', 'Yogyakarta', @demo_user_id);

-- Generation 3 -> 4 (Parent-Child)
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
-- Budi & Dewi -> Arya, Putri
(@person_budi, @person_arya, 'parent', @demo_user_id),
(@person_dewi, @person_arya, 'parent', @demo_user_id),
(@person_arya, @person_budi, 'child', @demo_user_id),
(@person_arya, @person_dewi, 'child', @demo_user_id),
(@person_budi, @person_putri, 'parent', @demo_user_id),
(@person_dewi, @person_putri, 'parent', @demo_user_id),
(@person_putri, @person_budi, 'child', @demo_user_id),
(@person_putri, @person_dewi, 'child', @demo_user_id),
-- Ratna & Hendra -> Dimas, Ayu
(@person_ratna, @person_dimas, 'parent', @demo_user_id),
(@person_hendra, @person_dimas, 'parent', @demo_user_id),
(@person_dimas, @person_ratna, 'child', @demo_user_id),
(@person_dimas, @person_hendra, 'child', @demo_user_id),
(@person_ratna, @person_ayu, 'parent', @demo_user_id),
(@person_hendra, @person_ayu, 'parent', @demo_user_id),
(@person_ayu, @person_ratna, 'child', @demo_user_id),
(@person_ayu, @person_hendra, 'child', @demo_user_id),
-- Agus & Maya -> Rizki
(@person_agus, @person_rizki, 'parent', @demo_user_id),
(@person_maya, @person_rizki, 'parent', @demo_user_id),
(@person_rizki, @person_agus, 'child', @demo_user_id),
(@person_rizki, @person_maya, 'child', @demo_user_id);

-- Generation 4 Siblings
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
(@person_arya, @person_putri, 'sibling', @demo_user_id),
(@person_putri, @person_arya, 'sibling', @demo_user_id),
(@person_dimas, @person_ayu, 'sibling', @demo_user_id),
(@person_ayu, @person_dimas, 'sibling', @demo_user_id);

-- Generation 4 Marriages
INSERT INTO relationships (person_id, related_person_id, type, marriage_status, marriage_date, marriage_place, created_by) VALUES
(@person_arya, @person_sarah, 'spouse', 'married', '2022-09-15', 'Boston, USA', @demo_user_id),
(@person_sarah, @person_arya, 'spouse', 'married', '2022-09-15', 'Boston, USA', @demo_user_id);

-- Generation 4 -> 5 (Parent-Child)
INSERT INTO relationships (person_id, related_person_id, type, created_by) VALUES
-- Arya & Sarah -> Adam
(@person_arya, @person_baby_adam, 'parent', @demo_user_id),
(@person_sarah, @person_baby_adam, 'parent', @demo_user_id),
(@person_baby_adam, @person_arya, 'child', @demo_user_id),
(@person_baby_adam, @person_sarah, 'child', @demo_user_id),
-- Dimas -> Zahra (single parent for demo)
(@person_dimas, @person_baby_zahra, 'parent', @demo_user_id),
(@person_baby_zahra, @person_dimas, 'child', @demo_user_id);

-- =====================================================
-- 9. SEED TREE POSITIONS (for visualization)
-- =====================================================
INSERT INTO tree_positions (person_id, family_id, x, y, level, sort_order) VALUES
-- Generation 1
(@person_soekarno, @family_id, 400, 50, 1, 1),
(@person_kartini, @family_id, 600, 50, 1, 2),
-- Generation 2
(@person_bambang, @family_id, 200, 200, 2, 1),
(@person_sri, @family_id, 400, 200, 2, 2),
(@person_siti, @family_id, 600, 200, 2, 3),
(@person_ahmad, @family_id, 800, 200, 2, 4),
-- Generation 3
(@person_budi, @family_id, 100, 350, 3, 1),
(@person_dewi, @family_id, 250, 350, 3, 2),
(@person_ratna, @family_id, 400, 350, 3, 3),
(@person_hendra, @family_id, 550, 350, 3, 4),
(@person_agus, @family_id, 700, 350, 3, 5),
(@person_maya, @family_id, 850, 350, 3, 6),
-- Generation 4
(@person_arya, @family_id, 50, 500, 4, 1),
(@person_sarah, @family_id, 150, 500, 4, 2),
(@person_putri, @family_id, 250, 500, 4, 3),
(@person_dimas, @family_id, 400, 500, 4, 4),
(@person_ayu, @family_id, 550, 500, 4, 5),
(@person_rizki, @family_id, 750, 500, 4, 6),
-- Generation 5
(@person_baby_adam, @family_id, 100, 650, 5, 1),
(@person_baby_zahra, @family_id, 400, 650, 5, 2);

-- =====================================================
-- 10. SEED MASTER DATA
-- =====================================================
INSERT INTO app_master_types (code, name, description, is_active, sort_order) VALUES
('RELATIONSHIP_TYPE', 'Relationship Types', 'Types of family relationships', TRUE, 1),
('GENDER', 'Gender', 'Gender options', TRUE, 2),
('MEMBER_ROLE', 'Member Roles', 'Family member access roles', TRUE, 3);

-- Relationship type values
SET @rel_type_id = (SELECT id FROM app_master_types WHERE code = 'RELATIONSHIP_TYPE');
INSERT INTO app_master_values (type_id, code, name, description, is_active, sort_order) VALUES
(@rel_type_id, 'parent', 'Parent', 'Biological or adoptive parent', TRUE, 1),
(@rel_type_id, 'child', 'Child', 'Biological or adopted child', TRUE, 2),
(@rel_type_id, 'spouse', 'Spouse', 'Married partner', TRUE, 3),
(@rel_type_id, 'sibling', 'Sibling', 'Brother or sister', TRUE, 4),
(@rel_type_id, 'step_parent', 'Step Parent', 'Step parent', TRUE, 5),
(@rel_type_id, 'step_child', 'Step Child', 'Step child', TRUE, 6),
(@rel_type_id, 'adoptive_parent', 'Adoptive Parent', 'Adoptive parent', TRUE, 7),
(@rel_type_id, 'adopted_child', 'Adopted Child', 'Adopted child', TRUE, 8);

-- Gender values
SET @gender_type_id = (SELECT id FROM app_master_types WHERE code = 'GENDER');
INSERT INTO app_master_values (type_id, code, name, is_active, sort_order) VALUES
(@gender_type_id, 'male', 'Male', TRUE, 1),
(@gender_type_id, 'female', 'Female', TRUE, 2),
(@gender_type_id, 'other', 'Other', TRUE, 3);

-- Member role values
SET @role_type_id = (SELECT id FROM app_master_types WHERE code = 'MEMBER_ROLE');
INSERT INTO app_master_values (type_id, code, name, description, is_active, sort_order) VALUES
(@role_type_id, 'owner', 'Owner', 'Full control of the family tree', TRUE, 1),
(@role_type_id, 'admin', 'Admin', 'Can manage members and settings', TRUE, 2),
(@role_type_id, 'editor', 'Editor', 'Can add and edit persons', TRUE, 3),
(@role_type_id, 'viewer', 'Viewer', 'View only access', TRUE, 4);

-- =====================================================
-- END OF SEED DATA
-- =====================================================
