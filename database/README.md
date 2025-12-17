# Database Guyub Platform

Folder ini berisi file SQL untuk setup database Guyub Platform.

## File-file

| File | Deskripsi |
|------|-----------|
| `guyub_schema.sql` | Struktur tabel (DDL) - semua CREATE TABLE |
| `guyub_seed.sql` | Data awal (roles, permissions, admin user) |

## Cara Import

### 1. Buat Database

```bash
mysql -u root -p -e "CREATE DATABASE guyub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 2. Import Schema

```bash
mysql -u root -p guyub < database/guyub_schema.sql
```

### 3. Import Seed Data

```bash
mysql -u root -p guyub < database/guyub_seed.sql
```

### Atau Import Sekaligus

```bash
mysql -u root -p guyub < database/guyub_schema.sql
mysql -u root -p guyub < database/guyub_seed.sql
```

## Default Login

Setelah import seed data:

| Field | Value |
|-------|-------|
| Email | `admin@guyub.id` |
| Password | `Admin@123` |

## Export Database (untuk update file ini)

```bash
# Export schema only (tanpa data)
mysqldump -u root -p guyub --no-data > database/guyub_schema.sql

# Export dengan data
mysqldump -u root -p guyub > database/guyub_full_YYYYMMDD.sql

# Export data only (untuk seed)
mysqldump -u root -p guyub --no-create-info > database/guyub_seed.sql
```

## Catatan

- Pastikan MySQL 8.0+ terinstall
- File ini di-generate dari migration files di `backend/migrations/`
- Jika ada perubahan schema, update file ini dengan menjalankan export ulang
