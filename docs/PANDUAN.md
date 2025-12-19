# PANDUAN PENGEMBANGAN GUYUB PLATFORM

> Panduan lengkap untuk developer dalam memahami, setup, dan mengembangkan Guyub Platform

---

## Daftar Isi

1. [Pengenalan Proyek](#1-pengenalan-proyek)
2. [Tech Stack](#2-tech-stack)
3. [Arsitektur Sistem](#3-arsitektur-sistem)
4. [Persiapan Development](#4-persiapan-development)
5. [Setup Project](#5-setup-project)
6. [Struktur Folder](#6-struktur-folder)
7. [Panduan Membuat Module Baru](#7-panduan-membuat-module-baru)
8. [Konvensi Kode](#8-konvensi-kode)
9. [Database & Migration](#9-database--migration)
10. [API Development](#10-api-development)
11. [Frontend Development](#11-frontend-development)
12. [Testing](#12-testing)
13. [Debugging](#13-debugging)
14. [Deployment](#14-deployment)
15. [FAQ & Troubleshooting](#15-faq--troubleshooting)

---

## 0. Visual Flow Diagram

> **Bagian ini berisi diagram visual untuk memudahkan pemahaman sistem secara keseluruhan.**

### 0.1 Arsitektur Sistem Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              GUYUB PLATFORM                                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │   Browser   │     │   Mobile    │     │   Desktop   │     │   API       │   │
│  │   (Admin)   │     │    App      │     │    App      │     │   Client    │   │
│  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘   │
│         │                   │                   │                   │          │
│         └───────────────────┴───────────────────┴───────────────────┘          │
│                                      │                                          │
│                                      ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                         FRONTEND (React + TypeScript)                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │  │
│  │  │  Pages   │  │Components│  │  Stores  │  │   API    │  │  Hooks   │   │  │
│  │  │          │  │   (UI)   │  │(Zustand) │  │ (Axios)  │  │          │   │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │  │
│  └──────────────────────────────────┬───────────────────────────────────────┘  │
│                                      │ HTTP/REST                               │
│                                      ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                          BACKEND (Go + Gin)                                │  │
│  │                                                                            │  │
│  │  ┌─────────────────────────────────────────────────────────────────────┐  │  │
│  │  │ PRESENTATION: Router → Middleware → Handler → Response              │  │  │
│  │  └─────────────────────────────────┬───────────────────────────────────┘  │  │
│  │                                    │                                      │  │
│  │  ┌─────────────────────────────────┴───────────────────────────────────┐  │  │
│  │  │ APPLICATION: Service (Business Logic) + DTOs + Validation           │  │  │
│  │  └─────────────────────────────────┬───────────────────────────────────┘  │  │
│  │                                    │                                      │  │
│  │  ┌─────────────────────────────────┴───────────────────────────────────┐  │  │
│  │  │ DOMAIN: Entity + Repository Interface + Value Objects               │  │  │
│  │  └─────────────────────────────────┬───────────────────────────────────┘  │  │
│  │                                    │                                      │  │
│  │  ┌─────────────────────────────────┴───────────────────────────────────┐  │  │
│  │  │ INFRASTRUCTURE: MySQL Repository + JWT + Storage + External         │  │  │
│  │  └─────────────────────────────────┬───────────────────────────────────┘  │  │
│  └────────────────────────────────────┼──────────────────────────────────────┘  │
│                                       │                                          │
│                                       ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────────────┐  │
│  │                              DATABASE                                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │  │
│  │  │  users   │  │  roles   │  │  audit   │  │  master  │  │  assets  │   │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │  │
│  │                           MySQL 8.0                                       │  │
│  └──────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 0.2 Alur Request HTTP (Detail)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                            ALUR REQUEST HTTP                                      │
└──────────────────────────────────────────────────────────────────────────────────┘

  CLIENT                    BACKEND                                     DATABASE
    │                         │                                            │
    │  POST /api/v1/users     │                                            │
    │ ─────────────────────►  │                                            │
    │  {name, email, ...}     │                                            │
    │                         │                                            │
    │                    ┌────┴────┐                                       │
    │                    │ ROUTER  │                                       │
    │                    │  (Gin)  │                                       │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │  CORS   │ ◄── Cek origin, methods, headers     │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │ LOGGER  │ ◄── Log request: method, path, IP    │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │  AUTH   │ ◄── Validasi JWT token               │
    │                    │MIDDLEWARE│     Extract user_id dari token       │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │PERMISSION│ ◄── Cek apakah user punya            │
    │                    │MIDDLEWARE│     permission "users.create"        │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │ HANDLER │ ◄── Parse JSON body                  │
    │                    │         │     Validasi request struct           │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │ SERVICE │ ◄── Business logic:                  │
    │                    │         │     - Cek email duplikat              │
    │                    │         │     - Hash password                   │
    │                    │         │     - Set default values              │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │                    ┌────▼────┐      ┌─────────────┐                  │
    │                    │REPOSITORY│────►│   MySQL     │                  │
    │                    │         │◄─────│   INSERT    │                  │
    │                    └────┬────┘      └─────────────┘                  │
    │                         │                                            │
    │                    ┌────▼────┐                                       │
    │                    │ AUDIT   │ ◄── Log perubahan ke audit_logs      │
    │                    │ LOGGER  │                                       │
    │                    └────┬────┘                                       │
    │                         │                                            │
    │  201 Created            │                                            │
    │ ◄─────────────────────  │                                            │
    │  {success, data, msg}   │                                            │
    │                         │                                            │
```

### 0.3 Alur Autentikasi (Login Flow)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                              ALUR LOGIN                                           │
└──────────────────────────────────────────────────────────────────────────────────┘

  BROWSER                   FRONTEND                  BACKEND                DATABASE
     │                         │                         │                      │
     │  1. User input          │                         │                      │
     │     email & password    │                         │                      │
     │ ─────────────────────►  │                         │                      │
     │                         │                         │                      │
     │                         │  2. POST /auth/login    │                      │
     │                         │ ─────────────────────►  │                      │
     │                         │  {email, password}      │                      │
     │                         │                         │                      │
     │                         │                    ┌────┴────┐                 │
     │                         │                    │ AuthSvc │                 │
     │                         │                    └────┬────┘                 │
     │                         │                         │                      │
     │                         │                         │  3. SELECT user      │
     │                         │                         │     WHERE email=?    │
     │                         │                         │ ──────────────────►  │
     │                         │                         │ ◄──────────────────  │
     │                         │                         │                      │
     │                         │                    ┌────┴────┐                 │
     │                         │                    │ Verify  │                 │
     │                         │                    │Password │                 │
     │                         │                    │(bcrypt) │                 │
     │                         │                    └────┬────┘                 │
     │                         │                         │                      │
     │                         │                         │  4. Get user roles   │
     │                         │                         │     & permissions    │
     │                         │                         │ ──────────────────►  │
     │                         │                         │ ◄──────────────────  │
     │                         │                         │                      │
     │                         │                    ┌────┴────┐                 │
     │                         │                    │Generate │                 │
     │                         │                    │  JWT    │                 │
     │                         │                    │ Tokens  │                 │
     │                         │                    └────┬────┘                 │
     │                         │                         │                      │
     │                         │                         │  5. Log activity     │
     │                         │                         │     (LOGIN)          │
     │                         │                         │ ──────────────────►  │
     │                         │                         │                      │
     │                         │  6. Return tokens       │                      │
     │                         │ ◄─────────────────────  │                      │
     │                         │  {access_token,         │                      │
     │                         │   refresh_token,        │                      │
     │                         │   user}                 │                      │
     │                         │                         │                      │
     │                    ┌────┴────┐                    │                      │
     │                    │ Store   │                    │                      │
     │                    │ token di│                    │                      │
     │                    │ Zustand │                    │                      │
     │                    │& storage│                    │                      │
     │                    └────┬────┘                    │                      │
     │                         │                         │                      │
     │  7. Redirect ke         │                         │                      │
     │     /dashboard          │                         │                      │
     │ ◄─────────────────────  │                         │                      │
     │                         │                         │                      │


┌──────────────────────────────────────────────────────────────────────────────────┐
│                         TOKEN REFRESH FLOW                                        │
└──────────────────────────────────────────────────────────────────────────────────┘

  FRONTEND                                    BACKEND
     │                                           │
     │  Request dengan expired token             │
     │ ───────────────────────────────────────►  │
     │                                           │
     │  401 Unauthorized                         │
     │ ◄───────────────────────────────────────  │
     │                                           │
     │  POST /auth/refresh                       │
     │  {refresh_token}                          │
     │ ───────────────────────────────────────►  │
     │                                           │
     │  {new_access_token, new_refresh_token}    │
     │ ◄───────────────────────────────────────  │
     │                                           │
     │  Retry original request                   │
     │ ───────────────────────────────────────►  │
     │                                           │
     │  200 OK                                   │
     │ ◄───────────────────────────────────────  │
     │                                           │
```

### 0.4 Alur Permission Check (RBAC)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                          ALUR CEK PERMISSION                                      │
└──────────────────────────────────────────────────────────────────────────────────┘

                              REQUEST MASUK
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │   Extract JWT dari Header   │
                    │   Authorization: Bearer xxx │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │      Validasi JWT Token     │
                    │   - Cek signature           │
                    │   - Cek expiry              │
                    └──────────────┬──────────────┘
                                   │
                          ┌────────┴────────┐
                          │                 │
                       VALID             INVALID
                          │                 │
                          ▼                 ▼
              ┌───────────────────┐  ┌─────────────────┐
              │  Extract claims:  │  │ Return 401      │
              │  - user_id        │  │ Unauthorized    │
              │  - roles[]        │  └─────────────────┘
              │  - permissions[]  │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────────────────────┐
              │   Cek: user.type == "super_admin" │
              └─────────────────┬─────────────────┘
                                │
                       ┌────────┴────────┐
                       │                 │
                      YES               NO
                       │                 │
                       ▼                 ▼
         ┌─────────────────────┐  ┌─────────────────────────────┐
         │  BYPASS semua       │  │  Cek permission dari JWT    │
         │  permission check   │  │  claims.permissions[]       │
         │  ✓ ALLOWED          │  └──────────────┬──────────────┘
         └─────────────────────┘                 │
                                                 ▼
                                  ┌─────────────────────────────┐
                                  │ Permission yang dibutuhkan: │
                                  │ "users.create"              │
                                  └──────────────┬──────────────┘
                                                 │
                                        ┌────────┴────────┐
                                        │                 │
                                    DITEMUKAN         TIDAK ADA
                                        │                 │
                                        ▼                 ▼
                          ┌─────────────────────┐  ┌─────────────────┐
                          │  ✓ ALLOWED          │  │  Return 403     │
                          │  Lanjut ke Handler  │  │  Forbidden      │
                          └─────────────────────┘  └─────────────────┘


┌──────────────────────────────────────────────────────────────────────────────────┐
│                        STRUKTUR RBAC                                              │
└──────────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │                                USER                                          │
  │  ┌─────────┐                                                                │
  │  │ user_id │                                                                │
  │  │  name   │                                                                │
  │  │  email  │                                                                │
  │  └────┬────┘                                                                │
  │       │ many-to-many                                                        │
  │       ▼                                                                     │
  │  ┌──────────────────────────────────────────────────────────────────────┐  │
  │  │                          ROLES                                        │  │
  │  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐            │  │
  │  │  │ super_admin   │  │    admin      │  │   manager     │            │  │
  │  │  │ level: 100    │  │  level: 90    │  │  level: 70    │            │  │
  │  │  │ (bypass all)  │  │               │  │               │            │  │
  │  │  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘            │  │
  │  │          │                  │                  │                     │  │
  │  │          │ many-to-many     │                  │                     │  │
  │  │          ▼                  ▼                  ▼                     │  │
  │  │  ┌──────────────────────────────────────────────────────────────┐   │  │
  │  │  │                      PERMISSIONS                              │   │  │
  │  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │   │  │
  │  │  │  │ users.view   │  │ users.create │  │ users.edit   │       │   │  │
  │  │  │  │ users.delete │  │ roles.view   │  │ roles.create │       │   │  │
  │  │  │  │ audit.view   │  │ master.view  │  │ master.edit  │       │   │  │
  │  │  │  │     ...      │  │     ...      │  │     ...      │       │   │  │
  │  │  │  └──────────────┘  └──────────────┘  └──────────────┘       │   │  │
  │  │  └──────────────────────────────────────────────────────────────┘   │  │
  │  └──────────────────────────────────────────────────────────────────────┘  │
  └─────────────────────────────────────────────────────────────────────────────┘
```

### 0.5 Alur File Upload (Asset)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                            ALUR FILE UPLOAD                                       │
└──────────────────────────────────────────────────────────────────────────────────┘

  BROWSER                   FRONTEND                  BACKEND               STORAGE
     │                         │                         │                     │
     │  1. Pilih file          │                         │                     │
     │     (drag & drop)       │                         │                     │
     │ ─────────────────────►  │                         │                     │
     │                         │                         │                     │
     │                    ┌────┴────┐                    │                     │
     │                    │Validate │                    │                     │
     │                    │ - size  │                    │                     │
     │                    │ - type  │                    │                     │
     │                    └────┬────┘                    │                     │
     │                         │                         │                     │
     │                         │  2. POST /assets/upload │                     │
     │                         │     multipart/form-data │                     │
     │                         │ ─────────────────────►  │                     │
     │                         │                         │                     │
     │  [=====>    ] 45%       │                         │                     │
     │                         │  (progress callback)    │                     │
     │ ◄─────────────────────  │                         │                     │
     │                         │                         │                     │
     │                         │                    ┌────┴────┐                │
     │                         │                    │Validate │                │
     │                         │                    │ - MIME  │                │
     │                         │                    │ - size  │                │
     │                         │                    └────┬────┘                │
     │                         │                         │                     │
     │                         │                         │  3. Generate UUID   │
     │                         │                         │     & path          │
     │                         │                         │                     │
     │                         │                         │  4. Save file       │
     │                         │                         │ ─────────────────►  │
     │                         │                         │                     │
     │                         │                         │  storage/uploads/   │
     │                         │                         │  user_avatar/       │
     │                         │                         │  2024/12/           │
     │                         │                         │  {uuid}.jpg         │
     │                         │                         │ ◄─────────────────  │
     │                         │                         │                     │
     │                         │                    ┌────┴────┐                │
     │                         │                    │ INSERT  │                │
     │                         │                    │ assets  │                │
     │                         │                    │ table   │                │
     │                         │                    └────┬────┘                │
     │                         │                         │                     │
     │                         │  5. Return asset info   │                     │
     │                         │ ◄─────────────────────  │                     │
     │                         │  {id, url, filename}    │                     │
     │                         │                         │                     │
     │  [==========] 100%      │                         │                     │
     │  Upload berhasil!       │                         │                     │
     │ ◄─────────────────────  │                         │                     │
     │                         │                         │                     │


┌──────────────────────────────────────────────────────────────────────────────────┐
│                        ASSET LINKING PATTERN                                      │
└──────────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐          ┌──────────────────────────────────────┐
  │   users     │          │              app_assets               │
  │  ┌───────┐  │          │  ┌────────┬──────────┬─────────────┐ │
  │  │ id: 1 │──┼──────────┼──│ ref_id │   kind   │ storage_path│ │
  │  │ name  │  │          │  ├────────┼──────────┼─────────────┤ │
  │  └───────┘  │          │  │   "1"  │user_avatar│ /user/...  │ │
  └─────────────┘          │  │   "1"  │user_doc   │ /doc/...   │ │
                           │  │   "5"  │user_avatar│ /user/...  │ │
  ┌─────────────┐          │  │  "10"  │product_img│ /prod/...  │ │
  │  products   │          │  └────────┴──────────┴─────────────┘ │
  │  ┌───────┐  │          │                                      │
  │  │ id:10 │──┼──────────┼──► Polymorphic linking dengan        │
  │  │ name  │  │          │    ref_id + kind                     │
  │  └───────┘  │          │                                      │
  └─────────────┘          └──────────────────────────────────────┘
```

### 0.6 Database ERD (Entity Relationship)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           DATABASE ERD                                            │
└──────────────────────────────────────────────────────────────────────────────────┘

  ┌───────────────────┐         ┌───────────────────┐         ┌───────────────────┐
  │      users        │         │ model_has_roles   │         │      roles        │
  ├───────────────────┤         ├───────────────────┤         ├───────────────────┤
  │ PK id             │◄────────│ FK model_id       │────────►│ PK id             │
  │    name           │         │    model_type     │         │    name           │
  │    email          │         │ FK role_id        │         │    description    │
  │    password       │         └───────────────────┘         │    level          │
  │    phone          │                                       │    is_system      │
  │    status         │                                       └─────────┬─────────┘
  │    type           │                                                 │
  │    deleted_at     │                                                 │
  └───────────────────┘                                                 │
           │                                                            │
           │                    ┌───────────────────┐                   │
           │                    │role_has_permissions│                  │
           │                    ├───────────────────┤                   │
           │                    │ FK role_id        │◄──────────────────┘
           │                    │ FK permission_id  │
           │                    └─────────┬─────────┘
           │                              │
           │                              ▼
           │                    ┌───────────────────┐
           │                    │   permissions     │
           │                    ├───────────────────┤
           │                    │ PK id             │
           │                    │    name           │
           │                    │    guard_name     │
           │                    │    group          │
           │                    └───────────────────┘
           │
           ▼
  ┌───────────────────┐         ┌───────────────────┐
  │   activity_logs   │         │    audit_logs     │
  ├───────────────────┤         ├───────────────────┤
  │ PK id             │         │ PK id             │
  │ FK user_id ───────┼─────────│ FK user_id        │
  │    activity_type  │         │    event          │
  │    ip_address     │         │    auditable_type │
  │    user_agent     │         │    auditable_id   │
  │    device_type    │         │    old_values     │
  │    browser        │         │    new_values     │
  │    description    │         │    url            │
  └───────────────────┘         │    ip_address     │
                                │ (IMMUTABLE!)      │
                                └───────────────────┘

  ┌───────────────────┐         ┌───────────────────┐
  │ app_master_types  │         │ app_master_values │
  ├───────────────────┤         ├───────────────────┤
  │ PK id             │◄────────│ FK type_id        │
  │ FK parent_id ─────┼─┐       │ PK id             │
  │    code           │ │       │ FK parent_value_id│──┐
  │    name           │ │       │    code           │  │
  │    is_active      │ │       │    name           │  │
  │    sort_order     │ │       │    is_active      │  │
  │    deleted_at     │ │       │    sort_order     │  │
  └───────────────────┘ │       │    deleted_at     │  │
           ▲            │       └───────────────────┘  │
           │            │                ▲             │
           └────────────┘                └─────────────┘
        (self-reference)              (cascading values)


  ┌───────────────────┐
  │    app_assets     │
  ├───────────────────┤
  │ PK id (UUID)      │         CONTOH CASCADING:
  │    ref_id         │         ┌─────────────────────────────────┐
  │    kind           │         │ MASTER TYPE: LOKASI             │
  │    original_name  │         │                                 │
  │    mime_type      │         │ Provinsi (parent_id: NULL)      │
  │    file_size      │         │    └── Kota (parent_id: 1)      │
  │    storage_path   │         │         └── Kecamatan (...)     │
  │ FK uploaded_by    │         │                                 │
  │    deleted_at     │         │ MASTER VALUE:                   │
  └───────────────────┘         │ Jawa Timur (type: Provinsi)     │
                                │    └── Surabaya (parent: JaTim) │
                                │         └── Gubeng (parent: Sby)│
                                └─────────────────────────────────┘
```

### 0.7 Alur Membuat Module Baru (Visual Steps)

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                    ALUR MEMBUAT MODULE BARU (10 LANGKAH)                          │
└──────────────────────────────────────────────────────────────────────────────────┘

  START
    │
    ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: DOMAIN LAYER                                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  internal/domain/product/                                                │  │
│  │  ├── entity.go      ◄── Struct Product dengan GORM tags                 │  │
│  │  ├── repository.go  ◄── Interface Repository (CRUD methods)             │  │
│  │  └── enums.go       ◄── Status, Type (jika ada)                         │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 2: INFRASTRUCTURE LAYER                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  internal/infrastructure/persistence/mysql/                              │  │
│  │  └── product_repository.go  ◄── Implementasi Repository dengan GORM     │  │
│  │                                 - Create, Update, Delete                 │  │
│  │                                 - FindByID, FindAll                      │  │
│  │                                 - Search, Filter, Pagination             │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 3: APPLICATION LAYER                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  internal/application/product/                                           │  │
│  │  ├── service.go  ◄── Business logic (validasi, transform, audit)        │  │
│  │  ├── dto.go      ◄── CreateRequest, UpdateRequest, ProductResponse      │  │
│  │  └── errors.go   ◄── ErrProductNotFound, ErrCodeExists                  │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 4: PRESENTATION LAYER                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  internal/presentation/http/handler/                                     │  │
│  │  └── product_handler.go  ◄── HTTP handlers:                             │  │
│  │                              - List (GET /products)                      │  │
│  │                              - Create (POST /products)                   │  │
│  │                              - GetByID (GET /products/:id)               │  │
│  │                              - Update (PUT /products/:id)                │  │
│  │                              - Delete (DELETE /products/:id)             │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 5: REGISTER ROUTES                                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  internal/presentation/router/router.go                                  │  │
│  │                                                                          │  │
│  │  products := v1.Group("/products")                                       │  │
│  │  products.Use(authMiddleware.Auth())                                     │  │
│  │  {                                                                       │  │
│  │      products.GET("", handler.List)                                      │  │
│  │      products.POST("", middleware.Permission("products.create"), ...)    │  │
│  │      products.GET("/:id", handler.GetByID)                               │  │
│  │      products.PUT("/:id", middleware.Permission("products.edit"), ...)   │  │
│  │      products.DELETE("/:id", middleware.Permission("products.delete"))   │  │
│  │  }                                                                       │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 6: WIRE UP DI MAIN.GO                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  cmd/server/main.go                                                      │  │
│  │                                                                          │  │
│  │  // 1. Import                                                            │  │
│  │  appProduct "guyub/internal/application/product"                         │  │
│  │                                                                          │  │
│  │  // 2. Initialize                                                        │  │
│  │  productRepo := mysql.NewProductRepository(db)                           │  │
│  │  productService := appProduct.NewService(productRepo)                    │  │
│  │  productHandler := handler.NewProductHandler(productService)             │  │
│  │                                                                          │  │
│  │  // 3. Pass to router                                                    │  │
│  │  router.New(..., productHandler, ...)                                    │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 7: DATABASE MIGRATION                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  migrations/008_create_products_table.sql                                │  │
│  │                                                                          │  │
│  │  CREATE TABLE products (                                                 │  │
│  │      id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,                      │  │
│  │      code VARCHAR(50) NOT NULL UNIQUE,                                   │  │
│  │      name VARCHAR(255) NOT NULL,                                         │  │
│  │      ...                                                                 │  │
│  │  );                                                                      │  │
│  │                                                                          │  │
│  │  $ go run ./cmd/migrate up                                               │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 8: FRONTEND - API SERVICE                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  admin/src/api/products.ts                                               │  │
│  │                                                                          │  │
│  │  export const productsApi = {                                            │  │
│  │    list: (params) => apiClient.get('/products', { params }),             │  │
│  │    getById: (id) => apiClient.get(`/products/${id}`),                    │  │
│  │    create: (data) => apiClient.post('/products', data),                  │  │
│  │    update: (id, data) => apiClient.put(`/products/${id}`, data),         │  │
│  │    delete: (id) => apiClient.delete(`/products/${id}`),                  │  │
│  │  };                                                                      │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 9: FRONTEND - PAGES                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  admin/src/pages/products/                                               │  │
│  │  ├── ProductsListPage.tsx   ◄── Tabel dengan pagination, search, filter │  │
│  │  └── ProductFormPage.tsx    ◄── Form create/edit dengan validasi        │  │
│  │                                                                          │  │
│  │  Komponen yang dipakai:                                                  │  │
│  │  - useQuery untuk fetch data                                             │  │
│  │  - useMutation untuk create/update/delete                                │  │
│  │  - DataTable, Pagination, Badge, Modal, ConfirmDialog                    │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│  STEP 10: REGISTER FRONTEND ROUTE                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐  │
│  │  admin/src/router.tsx                                                    │  │
│  │                                                                          │  │
│  │  {                                                                       │  │
│  │    path: 'products',                                                     │  │
│  │    children: [                                                           │  │
│  │      { index: true, element: <ProductsListPage /> },                     │  │
│  │      { path: 'create', element: <ProductFormPage /> },                   │  │
│  │      { path: ':id/edit', element: <ProductFormPage /> },                 │  │
│  │    ]                                                                     │  │
│  │  }                                                                       │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────┬───────────────────────┘
                                                        │
                                                        ▼
                                                      DONE!
                                              Module siap digunakan
```

### 0.8 Frontend Component Tree

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                        FRONTEND COMPONENT TREE                                    │
└──────────────────────────────────────────────────────────────────────────────────┘

  App.tsx
    │
    ├── <QueryClientProvider>           ◄── React Query context
    │   │
    │   └── <RouterProvider>            ◄── React Router
    │       │
    │       ├── /auth/*                 ◄── Guest routes
    │       │   └── <AuthLayout>
    │       │       └── <LoginPage>
    │       │           ├── <Input>
    │       │           ├── <Button>
    │       │           └── <Spinner>
    │       │
    │       └── /*                      ◄── Protected routes
    │           └── <MainLayout>
    │               │
    │               ├── <Sidebar>
    │               │   ├── <Logo>
    │               │   ├── <NavItem> (Dashboard)
    │               │   ├── <NavItem> (Users)
    │               │   ├── <NavItem> (Roles)
    │               │   └── <Avatar>
    │               │
    │               ├── <Header>
    │               │   ├── <MenuButton>
    │               │   └── <UserDropdown>
    │               │
    │               ├── <Outlet>        ◄── Page content
    │               │   │
    │               │   ├── /dashboard
    │               │   │   └── <DashboardPage>
    │               │   │       ├── <StatCard>
    │               │   │       ├── <Chart>
    │               │   │       └── <RecentActivity>
    │               │   │
    │               │   ├── /users
    │               │   │   └── <UsersListPage>
    │               │   │       ├── <SearchInput>
    │               │   │       ├── <FilterDropdown>
    │               │   │       ├── <Button> (Add New)
    │               │   │       ├── <DataTable>
    │               │   │       │   ├── <Avatar>
    │               │   │       │   ├── <Badge>
    │               │   │       │   └── <ActionButtons>
    │               │   │       ├── <Pagination>
    │               │   │       └── <ConfirmDialog>
    │               │   │
    │               │   ├── /users/create
    │               │   │   └── <UserFormPage>
    │               │   │       ├── <Input>
    │               │   │       ├── <Select>
    │               │   │       ├── <AvatarUpload>
    │               │   │       └── <Button>
    │               │   │
    │               │   └── ... (other pages)
    │               │
    │               └── <Toast>         ◄── Global toast notifications
    │
    └── <ReactQueryDevtools>            ◄── Dev only


┌──────────────────────────────────────────────────────────────────────────────────┐
│                          UI COMPONENT LIBRARY                                     │
└──────────────────────────────────────────────────────────────────────────────────┘

  components/ui/
    │
    ├── Form Components
    │   ├── <Input>           ◄── Text, email, password, number
    │   ├── <Select>          ◄── Single/multi select dropdown
    │   ├── <Checkbox>        ◄── Boolean input
    │   ├── <Radio>           ◄── Option selection
    │   └── <Textarea>        ◄── Multi-line text
    │
    ├── Display Components
    │   ├── <Badge>           ◄── Status labels (success, warning, danger)
    │   ├── <Avatar>          ◄── User photo with fallback initials
    │   ├── <Card>            ◄── Container with shadow
    │   ├── <Spinner>         ◄── Loading indicator
    │   └── <Empty>           ◄── No data state
    │
    ├── Action Components
    │   ├── <Button>          ◄── primary, secondary, danger, ghost variants
    │   ├── <IconButton>      ◄── Icon-only button
    │   └── <Dropdown>        ◄── Action menu
    │
    ├── Feedback Components
    │   ├── <Toast>           ◄── Success/error/warning notifications
    │   ├── <Modal>           ◄── Dialog overlay
    │   └── <ConfirmDialog>   ◄── Confirmation modal
    │
    ├── Data Components
    │   ├── <DataTable>       ◄── Sortable table with actions
    │   └── <Pagination>      ◄── Page navigation
    │
    └── Upload Components
        ├── <FileUpload>      ◄── Drag & drop file upload
        └── <AvatarUpload>    ◄── Circular image upload
```

### 0.9 Development Workflow

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                         DEVELOPMENT WORKFLOW                                      │
└──────────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │   main branch   │
                              │   (production)  │
                              └────────┬────────┘
                                       │
                                       │ create branch
                                       ▼
                              ┌─────────────────┐
                              │  feature/xxx    │
                              │   atau          │
                              │  fix/xxx        │
                              └────────┬────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
    ┌─────────────┐            ┌─────────────┐            ┌─────────────┐
    │  Backend    │            │  Frontend   │            │  Database   │
    │  Changes    │            │  Changes    │            │  Migration  │
    └──────┬──────┘            └──────┬──────┘            └──────┬──────┘
           │                          │                          │
           │ go run ./cmd/server      │ npm run dev              │ go run ./cmd/migrate
           │                          │                          │
           └───────────────────────────┴──────────────────────────┘
                                       │
                                       │ test locally
                                       ▼
                              ┌─────────────────┐
                              │  git add .      │
                              │  git commit     │
                              │  git push       │
                              └────────┬────────┘
                                       │
                                       │ create Pull Request
                                       ▼
                              ┌─────────────────┐
                              │   Code Review   │
                              │   by team       │
                              └────────┬────────┘
                                       │
                              ┌────────┴────────┐
                              │                 │
                         APPROVED           REJECTED
                              │                 │
                              ▼                 ▼
                     ┌─────────────┐    ┌─────────────┐
                     │   Merge to  │    │   Fix &     │
                     │    main     │    │   Re-push   │
                     └─────────────┘    └─────────────┘


┌──────────────────────────────────────────────────────────────────────────────────┐
│                           GIT COMMIT CONVENTION                                   │
└──────────────────────────────────────────────────────────────────────────────────┘

  TYPE: DESCRIPTION

  ┌────────────┬──────────────────────────────────────────────────────────────────┐
  │   Type     │   Digunakan untuk                                                │
  ├────────────┼──────────────────────────────────────────────────────────────────┤
  │   feat     │   Fitur baru                                                     │
  │   fix      │   Bug fix                                                        │
  │   refactor │   Refactoring code (tidak mengubah behavior)                     │
  │   docs     │   Dokumentasi                                                    │
  │   style    │   Formatting, tidak mengubah code logic                          │
  │   test     │   Menambah test                                                  │
  │   chore    │   Maintenance, update dependencies                               │
  └────────────┴──────────────────────────────────────────────────────────────────┘

  CONTOH:
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  feat: add product module with CRUD operations                              │
  │  fix: resolve avatar not showing in users list                              │
  │  refactor: extract validation logic to separate function                    │
  │  docs: update PANDUAN.md with visual flows                                  │
  └─────────────────────────────────────────────────────────────────────────────┘
```

### 0.10 Ringkasan Quick Reference

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                         QUICK REFERENCE CARD                                      │
└──────────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  BACKEND COMMANDS                                                            │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  go run ./cmd/server          │  Jalankan server                            │
  │  air -c .air.toml             │  Jalankan dengan hot reload                 │
  │  go run ./cmd/migrate up      │  Jalankan migration                         │
  │  go run ./cmd/seed            │  Jalankan seeder                            │
  │  go test -v ./...             │  Jalankan semua test                        │
  │  go build -o bin/server       │  Build binary                               │
  └─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  FRONTEND COMMANDS                                                           │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  npm install                  │  Install dependencies                       │
  │  npm run dev                  │  Jalankan dev server (port 5173)            │
  │  npm run build                │  Build untuk production                     │
  │  npm run lint                 │  Jalankan linter                            │
  └─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  DATABASE SETUP                                                              │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  mysql -u root -p guyub < database/guyub_schema.sql     │  Import schema    │
  │  mysql -u root -p guyub < database/guyub_seed.sql       │  Import seed      │
  └─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  DEFAULT LOGIN                                                               │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  Email    : admin@guyub.id                                                  │
  │  Password : Admin@123                                                       │
  └─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  PORTS                                                                       │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  Backend  : http://localhost:8080                                           │
  │  Frontend : http://localhost:5173                                           │
  │  MySQL    : localhost:3306                                                  │
  └─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  FILE LOCATIONS (Backend)                                                    │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  Entity      : internal/domain/{module}/entity.go                           │
  │  Repository  : internal/infrastructure/persistence/mysql/{module}_repo.go   │
  │  Service     : internal/application/{module}/service.go                     │
  │  Handler     : internal/presentation/http/handler/{module}_handler.go       │
  │  Routes      : internal/presentation/router/router.go                       │
  │  Main        : cmd/server/main.go                                           │
  └─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────────┐
  │  FILE LOCATIONS (Frontend)                                                   │
  ├─────────────────────────────────────────────────────────────────────────────┤
  │  API Service : src/api/{module}.ts                                          │
  │  Types       : src/types/index.ts                                           │
  │  Pages       : src/pages/{module}/{Page}.tsx                                │
  │  Components  : src/components/ui/{Component}.tsx                            │
  │  Stores      : src/stores/{store}Store.ts                                   │
  │  Router      : src/router.tsx                                               │
  └─────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Pengenalan Proyek

### Apa itu Guyub Platform?

**Guyub** (bahasa Jawa untuk "kebersamaan") adalah platform **Family Tree & Genealogy** yang dibangun dengan prinsip **Clean Architecture**. Platform ini membantu keluarga melestarikan sejarah mereka dan memperkuat ikatan lintas generasi.

**Fitur Utama Family Tree:**
- **Interactive Family Tree** - Visualisasi pohon keluarga menggunakan React Flow dengan drag-and-drop
- **Person Management** - Profil lengkap: nama, gender, tanggal lahir/wafat, foto, pekerjaan
- **Relationship Mapping** - Koneksi parent-child, spouse, sibling dengan garis visual
- **Auto Layout** - Pengaturan otomatis posisi node berdasarkan generasi
- **Landing Page** - Halaman publik dengan preview pohon keluarga (Bahasa Indonesia)

**Fitur Admin:**
- **User Management** - Manajemen user dengan RBAC (Role-Based Access Control)
- **Master Data** - Data master dengan tipe hierarkis dan nilai bertingkat (cascading)
- **Audit Logging** - Log audit yang immutable (tidak bisa diubah/dihapus)
- **Activity Tracking** - Pelacakan aktivitas user
- **Asset Management** - Manajemen file upload (foto keluarga)
- **Analytics Dashboard** - Dashboard statistik dan grafik

### Mengapa Clean Architecture?

Clean Architecture memisahkan aplikasi menjadi layer-layer yang independen:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Handler HTTP, Middleware, Request/Response                  │
├─────────────────────────────────────────────────────────────┤
│                    APPLICATION LAYER                         │
│  Business Logic, Services, DTOs                              │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  Entities, Repository Interface, Value Objects               │
├─────────────────────────────────────────────────────────────┤
│                   INFRASTRUCTURE LAYER                       │
│  Database, External Services, File Storage                   │
└─────────────────────────────────────────────────────────────┘
```

**Keuntungan:**
- Mudah di-test (testable)
- Mudah dipelihara (maintainable)
- Mudah dikembangkan (scalable)
- Dependency mengalir ke dalam (Domain tidak bergantung pada apapun)

---

## 2. Tech Stack

### Backend

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **Go** | 1.23+ | Bahasa pemrograman utama |
| **Gin** | v1.10+ | HTTP web framework |
| **GORM** | v1.25+ | ORM untuk database |
| **JWT** | - | Token autentikasi |
| **Viper** | - | Konfigurasi management |
| **Zap** | - | Structured logging |
| **Validator** | v10 | Validasi request |

### Frontend

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **React** | 18+ | UI framework |
| **TypeScript** | 5+ | Type safety |
| **Vite** | 5+ | Build tool & dev server |
| **React Router** | 6+ | Routing |
| **React Query** | 5+ | Server state management |
| **Zustand** | 4+ | Client state management |
| **Tailwind CSS** | 3+ | Styling |
| **Axios** | 1+ | HTTP client |
| **React Hook Form** | 7+ | Form handling |
| **Zod** | 3+ | Schema validation |

### Database

| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **MySQL** | 8.0+ | Database utama |

### Tools

| Tool | Kegunaan |
|------|----------|
| **Air** | Hot reload untuk Go |
| **Docker** | Containerization |
| **Docker Compose** | Multi-container orchestration |

---

## 3. Arsitektur Sistem

### Alur Data (Data Flow)

```
[Client/Browser]
       │
       ▼
[React Frontend] ──HTTP Request──▶ [Go Backend]
       │                                 │
       │                                 ▼
       │                          [Router/Gin]
       │                                 │
       │                                 ▼
       │                          [Middleware]
       │                          (Auth, CORS, Logger)
       │                                 │
       │                                 ▼
       │                          [Handler]
       │                          (Parse Request)
       │                                 │
       │                                 ▼
       │                          [Service]
       │                          (Business Logic)
       │                                 │
       │                                 ▼
       │                          [Repository]
       │                          (Data Access)
       │                                 │
       │                                 ▼
       │                          [MySQL Database]
       │                                 │
       ◀────────HTTP Response────────────┘
```

### Layer Dependencies

```
Presentation ──depends on──▶ Application ──depends on──▶ Domain
                                  │
                                  │
                                  ▼
                            Infrastructure
                            (implements Domain interfaces)
```

**PENTING:** Domain layer TIDAK BOLEH bergantung pada layer lain!

---

## 4. Persiapan Development

### Software yang Harus Diinstall

#### Wajib (Required)

| Software | Versi Minimum | Cara Install (macOS) |
|----------|---------------|----------------------|
| **Go** | 1.23+ | `brew install go` |
| **Node.js** | 20+ | `brew install node` |
| **MySQL** | 8.0+ | `brew install mysql` |
| **Git** | 2.40+ | `brew install git` |

#### Opsional (Recommended)

| Software | Kegunaan | Cara Install |
|----------|----------|--------------|
| **Air** | Hot reload Go | `go install github.com/cosmtrek/air@latest` |
| **Docker** | Container | Download dari docker.com |
| **VS Code** | IDE | Download dari code.visualstudio.com |
| **TablePlus/DBeaver** | Database GUI | `brew install --cask tableplus` |

### VS Code Extensions

Ekstensi yang direkomendasikan:

```json
// .vscode/extensions.json
{
  "recommendations": [
    "golang.go",
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "formulahendry.auto-rename-tag"
  ]
}
```

### Konfigurasi Git

```bash
# Set identity
git config --global user.name "Nama Kamu"
git config --global user.email "email@kamu.com"

# Set default branch
git config --global init.defaultBranch main
```

---

## 5. Setup Project

### Langkah 1: Clone Repository

```bash
# Clone dari GitHub
git clone https://github.com/jaroteko18/guyub.git
cd guyub
```

### Langkah 2: Setup Database

```bash
# Login ke MySQL
mysql -u root -p

# Buat database
CREATE DATABASE guyub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Buat user (opsional)
CREATE USER 'guyub'@'localhost' IDENTIFIED BY 'password_kamu';
GRANT ALL PRIVILEGES ON guyub.* TO 'guyub'@'localhost';
FLUSH PRIVILEGES;

# Keluar dari MySQL
exit
```

### Langkah 3: Setup Backend

```bash
# Masuk ke folder backend
cd backend

# Copy file environment
cp .env.example .env

# Edit konfigurasi database
# Sesuaikan DB_USERNAME dan DB_PASSWORD
nano .env  # atau gunakan editor favorit

# Install dependencies
go mod download

# Jalankan migration
go run ./cmd/migrate up

# Jalankan seeder (data awal)
go run ./cmd/seed

# Jalankan server
go run ./cmd/server

# Atau dengan hot reload (recommended untuk development)
air -c .air.toml
```

Server backend akan berjalan di `http://localhost:8080`

### Langkah 4: Setup Frontend (Admin)

```bash
# Buka terminal baru, masuk ke folder admin
cd admin

# Install dependencies
npm install

# Copy file environment
cp .env.example .env

# Edit jika perlu
# VITE_API_URL=http://localhost:8080/api/v1

# Jalankan development server
npm run dev
```

Frontend akan berjalan di `http://localhost:5173`

### Langkah 5: Login

Buka browser dan akses `http://localhost:5173`

**Kredensial Default:**
| Field | Value |
|-------|-------|
| Email | `admin@guyub.id` |
| Password | `Admin@123` |

---

## 6. Struktur Folder

### Backend Structure

```
backend/
├── cmd/                              # Entry points
│   ├── server/
│   │   └── main.go                   # Main application
│   ├── migrate/
│   │   └── main.go                   # Migration runner
│   └── seed/
│       └── main.go                   # Seeder runner
│
├── internal/                         # Private application code
│   ├── domain/                       # DOMAIN LAYER
│   │   ├── user/
│   │   │   ├── entity.go             # User entity struct
│   │   │   ├── repository.go         # Repository interface
│   │   │   ├── status.go             # Status enum
│   │   │   └── type.go               # Type enum
│   │   ├── role/
│   │   ├── permission/
│   │   ├── master/
│   │   ├── audit/
│   │   ├── activity/
│   │   └── asset/
│   │
│   ├── application/                  # APPLICATION LAYER
│   │   ├── auth/
│   │   │   ├── service.go            # Auth business logic
│   │   │   └── errors.go             # Auth errors
│   │   ├── user/
│   │   │   ├── service.go            # User business logic
│   │   │   ├── dto.go                # Request/Response DTOs
│   │   │   └── errors.go             # User errors
│   │   ├── role/
│   │   ├── master/
│   │   ├── audit/
│   │   ├── activity/
│   │   ├── analytics/
│   │   └── asset/
│   │
│   ├── infrastructure/               # INFRASTRUCTURE LAYER
│   │   ├── persistence/
│   │   │   └── mysql/
│   │   │       ├── connection.go     # DB connection
│   │   │       ├── user_repository.go
│   │   │       ├── role_repository.go
│   │   │       └── ...
│   │   ├── auth/
│   │   │   ├── jwt.go                # JWT service
│   │   │   └── password.go           # Password hashing
│   │   └── storage/
│   │       └── local.go              # Local file storage
│   │
│   └── presentation/                 # PRESENTATION LAYER
│       ├── http/
│       │   ├── handler/
│       │   │   ├── auth_handler.go
│       │   │   ├── user_handler.go
│       │   │   └── ...
│       │   ├── middleware/
│       │   │   ├── auth.go           # JWT auth middleware
│       │   │   ├── cors.go           # CORS middleware
│       │   │   └── logger.go         # Request logger
│       │   ├── request/
│       │   │   └── validator.go      # Request validation
│       │   └── response/
│       │       └── response.go       # Standard responses
│       └── router/
│           └── router.go             # Route definitions
│
├── pkg/                              # Public packages (reusable)
│   ├── config/
│   │   └── config.go                 # Configuration loader
│   ├── logger/
│   │   └── logger.go                 # Zap logger wrapper
│   └── utils/
│       └── helpers.go
│
├── migrations/                       # SQL migrations
│   ├── 001_create_users_table.sql
│   ├── 002_create_roles_tables.sql
│   └── ...
│
├── config/
│   └── config.yaml                   # Default config
│
├── storage/
│   └── uploads/                      # Uploaded files
│
├── .env.example
├── .air.toml                         # Air hot reload config
├── go.mod
├── go.sum
├── Makefile
└── Dockerfile
```

### Frontend Structure

```
admin/
├── src/
│   ├── api/                          # API client
│   │   ├── client.ts                 # Axios instance
│   │   ├── auth.ts                   # Auth API
│   │   ├── users.ts                  # Users API
│   │   ├── roles.ts                  # Roles API
│   │   └── ...
│   │
│   ├── components/
│   │   ├── ui/                       # Base UI components
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── DataTable.tsx
│   │   │   ├── Pagination.tsx
│   │   │   ├── Avatar.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── Toast.tsx
│   │   │   ├── Spinner.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── ConfirmDialog.tsx
│   │   │   ├── AvatarUpload.tsx
│   │   │   ├── FileUpload.tsx
│   │   │   └── index.ts              # Export all
│   │   └── shared/                   # Complex shared components
│   │
│   ├── hooks/                        # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useModal.ts
│   │   ├── usePagination.ts
│   │   └── useDebounce.ts
│   │
│   ├── layouts/
│   │   ├── MainLayout.tsx            # Authenticated layout
│   │   └── AuthLayout.tsx            # Guest layout
│   │
│   ├── pages/
│   │   ├── auth/
│   │   │   └── LoginPage.tsx
│   │   ├── dashboard/
│   │   │   └── DashboardPage.tsx
│   │   ├── users/
│   │   │   ├── UsersListPage.tsx
│   │   │   └── UserFormPage.tsx
│   │   ├── roles/
│   │   ├── master/
│   │   ├── audit/
│   │   ├── activity/
│   │   ├── analytics/
│   │   ├── profile/
│   │   └── index.tsx                 # Page exports
│   │
│   ├── stores/                       # Zustand stores
│   │   ├── authStore.ts              # Auth state
│   │   └── uiStore.ts                # UI state (toast, sidebar)
│   │
│   ├── types/
│   │   └── index.ts                  # TypeScript types
│   │
│   ├── utils/
│   │   ├── format.ts                 # Formatting helpers
│   │   └── helpers.ts
│   │
│   ├── App.tsx
│   ├── router.tsx                    # React Router config
│   ├── main.tsx                      # Entry point
│   └── index.css                     # Global styles
│
├── public/
├── index.html
├── tailwind.config.js
├── tsconfig.json
├── vite.config.ts
├── package.json
└── Dockerfile
```

---

## 7. Panduan Membuat Module Baru

Berikut adalah langkah-langkah lengkap untuk membuat module baru. Contoh: Module **Product**.

### Step 1: Domain Layer (Backend)

Buat folder `internal/domain/product/`

#### 1.1 Entity (`entity.go`)

```go
// internal/domain/product/entity.go
package product

import (
    "time"
    "gorm.io/gorm"
)

// Product represents a product entity
type Product struct {
    ID          uint64         `gorm:"primaryKey;autoIncrement" json:"id"`
    Code        string         `gorm:"type:varchar(50);uniqueIndex;not null" json:"code"`
    Name        string         `gorm:"type:varchar(255);not null" json:"name"`
    Description *string        `gorm:"type:text" json:"description,omitempty"`
    Price       float64        `gorm:"type:decimal(15,2);not null;default:0" json:"price"`
    Stock       int            `gorm:"type:int;not null;default:0" json:"stock"`
    IsActive    bool           `gorm:"type:tinyint(1);not null;default:1" json:"is_active"`
    CreatedAt   time.Time      `gorm:"autoCreateTime" json:"created_at"`
    UpdatedAt   time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
    DeletedAt   gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
}

// TableName returns the table name
func (Product) TableName() string {
    return "products"
}
```

#### 1.2 Repository Interface (`repository.go`)

```go
// internal/domain/product/repository.go
package product

import "context"

// Repository defines the product repository interface
type Repository interface {
    // Create creates a new product
    Create(ctx context.Context, product *Product) error

    // Update updates an existing product
    Update(ctx context.Context, product *Product) error

    // Delete soft deletes a product
    Delete(ctx context.Context, id uint64) error

    // FindByID finds a product by ID
    FindByID(ctx context.Context, id uint64) (*Product, error)

    // FindByCode finds a product by code
    FindByCode(ctx context.Context, code string) (*Product, error)

    // FindAll returns all products with pagination
    FindAll(ctx context.Context, params *ListParams) ([]*Product, int64, error)

    // Restore restores a soft-deleted product
    Restore(ctx context.Context, id uint64) error
}

// ListParams defines parameters for listing products
type ListParams struct {
    Page     int
    PerPage  int
    Search   string
    SortBy   string
    SortDir  string
    IsActive *bool
}
```

### Step 2: Infrastructure Layer (Backend)

Buat file `internal/infrastructure/persistence/mysql/product_repository.go`

```go
// internal/infrastructure/persistence/mysql/product_repository.go
package mysql

import (
    "context"
    "guyub/internal/domain/product"
    "gorm.io/gorm"
)

type productRepository struct {
    db *gorm.DB
}

// NewProductRepository creates a new product repository
func NewProductRepository(db *gorm.DB) product.Repository {
    return &productRepository{db: db}
}

func (r *productRepository) Create(ctx context.Context, p *product.Product) error {
    return r.db.WithContext(ctx).Create(p).Error
}

func (r *productRepository) Update(ctx context.Context, p *product.Product) error {
    return r.db.WithContext(ctx).Save(p).Error
}

func (r *productRepository) Delete(ctx context.Context, id uint64) error {
    return r.db.WithContext(ctx).Delete(&product.Product{}, id).Error
}

func (r *productRepository) FindByID(ctx context.Context, id uint64) (*product.Product, error) {
    var p product.Product
    err := r.db.WithContext(ctx).First(&p, id).Error
    if err == gorm.ErrRecordNotFound {
        return nil, nil
    }
    return &p, err
}

func (r *productRepository) FindByCode(ctx context.Context, code string) (*product.Product, error) {
    var p product.Product
    err := r.db.WithContext(ctx).Where("code = ?", code).First(&p).Error
    if err == gorm.ErrRecordNotFound {
        return nil, nil
    }
    return &p, err
}

func (r *productRepository) FindAll(ctx context.Context, params *product.ListParams) ([]*product.Product, int64, error) {
    var products []*product.Product
    var total int64

    query := r.db.WithContext(ctx).Model(&product.Product{})

    // Search
    if params.Search != "" {
        search := "%" + params.Search + "%"
        query = query.Where("name LIKE ? OR code LIKE ?", search, search)
    }

    // Filter by is_active
    if params.IsActive != nil {
        query = query.Where("is_active = ?", *params.IsActive)
    }

    // Count total
    query.Count(&total)

    // Sorting
    sortBy := params.SortBy
    if sortBy == "" {
        sortBy = "created_at"
    }
    sortDir := params.SortDir
    if sortDir == "" {
        sortDir = "desc"
    }
    query = query.Order(sortBy + " " + sortDir)

    // Pagination
    offset := (params.Page - 1) * params.PerPage
    query = query.Offset(offset).Limit(params.PerPage)

    err := query.Find(&products).Error
    return products, total, err
}

func (r *productRepository) Restore(ctx context.Context, id uint64) error {
    return r.db.WithContext(ctx).Unscoped().Model(&product.Product{}).
        Where("id = ?", id).Update("deleted_at", nil).Error
}
```

### Step 3: Application Layer (Backend)

Buat folder `internal/application/product/`

#### 3.1 Service (`service.go`)

```go
// internal/application/product/service.go
package product

import (
    "context"
    "guyub/internal/domain/product"
)

type Service struct {
    productRepo product.Repository
}

func NewService(productRepo product.Repository) *Service {
    return &Service{productRepo: productRepo}
}

// List returns paginated products
func (s *Service) List(ctx context.Context, req *ListRequest) (*ListResponse, error) {
    params := &product.ListParams{
        Page:     req.Page,
        PerPage:  req.PerPage,
        Search:   req.Search,
        SortBy:   req.SortBy,
        SortDir:  req.SortDir,
        IsActive: req.IsActive,
    }

    products, total, err := s.productRepo.FindAll(ctx, params)
    if err != nil {
        return nil, err
    }

    // Convert to response DTOs
    items := make([]*ProductResponse, len(products))
    for i, p := range products {
        items[i] = toProductResponse(p)
    }

    return &ListResponse{
        Items: items,
        Meta: &PaginationMeta{
            CurrentPage: req.Page,
            PerPage:     req.PerPage,
            Total:       total,
            LastPage:    (total + int64(req.PerPage) - 1) / int64(req.PerPage),
        },
    }, nil
}

// Create creates a new product
func (s *Service) Create(ctx context.Context, req *CreateRequest) (*ProductResponse, error) {
    // Check duplicate code
    existing, _ := s.productRepo.FindByCode(ctx, req.Code)
    if existing != nil {
        return nil, ErrCodeAlreadyExists
    }

    p := &product.Product{
        Code:        req.Code,
        Name:        req.Name,
        Description: req.Description,
        Price:       req.Price,
        Stock:       req.Stock,
        IsActive:    true,
    }

    if err := s.productRepo.Create(ctx, p); err != nil {
        return nil, err
    }

    return toProductResponse(p), nil
}

// GetByID returns a product by ID
func (s *Service) GetByID(ctx context.Context, id uint64) (*ProductResponse, error) {
    p, err := s.productRepo.FindByID(ctx, id)
    if err != nil {
        return nil, err
    }
    if p == nil {
        return nil, ErrProductNotFound
    }

    return toProductResponse(p), nil
}

// Update updates a product
func (s *Service) Update(ctx context.Context, id uint64, req *UpdateRequest) (*ProductResponse, error) {
    p, err := s.productRepo.FindByID(ctx, id)
    if err != nil {
        return nil, err
    }
    if p == nil {
        return nil, ErrProductNotFound
    }

    // Check duplicate code (if changed)
    if req.Code != p.Code {
        existing, _ := s.productRepo.FindByCode(ctx, req.Code)
        if existing != nil {
            return nil, ErrCodeAlreadyExists
        }
    }

    // Update fields
    p.Code = req.Code
    p.Name = req.Name
    p.Description = req.Description
    p.Price = req.Price
    p.Stock = req.Stock
    if req.IsActive != nil {
        p.IsActive = *req.IsActive
    }

    if err := s.productRepo.Update(ctx, p); err != nil {
        return nil, err
    }

    return toProductResponse(p), nil
}

// Delete soft deletes a product
func (s *Service) Delete(ctx context.Context, id uint64) error {
    p, err := s.productRepo.FindByID(ctx, id)
    if err != nil {
        return err
    }
    if p == nil {
        return ErrProductNotFound
    }

    return s.productRepo.Delete(ctx, id)
}

// Helper function
func toProductResponse(p *product.Product) *ProductResponse {
    return &ProductResponse{
        ID:          p.ID,
        Code:        p.Code,
        Name:        p.Name,
        Description: p.Description,
        Price:       p.Price,
        Stock:       p.Stock,
        IsActive:    p.IsActive,
        CreatedAt:   p.CreatedAt,
        UpdatedAt:   p.UpdatedAt,
    }
}
```

#### 3.2 DTOs (`dto.go`)

```go
// internal/application/product/dto.go
package product

import "time"

// ListRequest for listing products
type ListRequest struct {
    Page     int    `form:"page" validate:"min=1"`
    PerPage  int    `form:"per_page" validate:"min=1,max=100"`
    Search   string `form:"search"`
    SortBy   string `form:"sort_by"`
    SortDir  string `form:"sort_dir" validate:"omitempty,oneof=asc desc"`
    IsActive *bool  `form:"is_active"`
}

// CreateRequest for creating product
type CreateRequest struct {
    Code        string  `json:"code" validate:"required,max=50"`
    Name        string  `json:"name" validate:"required,max=255"`
    Description *string `json:"description"`
    Price       float64 `json:"price" validate:"min=0"`
    Stock       int     `json:"stock" validate:"min=0"`
}

// UpdateRequest for updating product
type UpdateRequest struct {
    Code        string  `json:"code" validate:"required,max=50"`
    Name        string  `json:"name" validate:"required,max=255"`
    Description *string `json:"description"`
    Price       float64 `json:"price" validate:"min=0"`
    Stock       int     `json:"stock" validate:"min=0"`
    IsActive    *bool   `json:"is_active"`
}

// ProductResponse for API response
type ProductResponse struct {
    ID          uint64    `json:"id"`
    Code        string    `json:"code"`
    Name        string    `json:"name"`
    Description *string   `json:"description,omitempty"`
    Price       float64   `json:"price"`
    Stock       int       `json:"stock"`
    IsActive    bool      `json:"is_active"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

// ListResponse for paginated list
type ListResponse struct {
    Items []*ProductResponse `json:"items"`
    Meta  *PaginationMeta    `json:"meta"`
}

// PaginationMeta for pagination info
type PaginationMeta struct {
    CurrentPage int   `json:"current_page"`
    PerPage     int   `json:"per_page"`
    Total       int64 `json:"total"`
    LastPage    int64 `json:"last_page"`
}
```

#### 3.3 Errors (`errors.go`)

```go
// internal/application/product/errors.go
package product

import "errors"

var (
    ErrProductNotFound   = errors.New("product not found")
    ErrCodeAlreadyExists = errors.New("product code already exists")
)
```

### Step 4: Presentation Layer (Backend)

Buat file `internal/presentation/http/handler/product_handler.go`

```go
// internal/presentation/http/handler/product_handler.go
package handler

import (
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    appProduct "guyub/internal/application/product"
    "guyub/internal/presentation/http/response"
)

type ProductHandler struct {
    productService *appProduct.Service
}

func NewProductHandler(productService *appProduct.Service) *ProductHandler {
    return &ProductHandler{productService: productService}
}

// List godoc
// @Summary List products
// @Tags Products
// @Produce json
// @Param page query int false "Page number"
// @Param per_page query int false "Items per page"
// @Param search query string false "Search term"
// @Success 200 {object} response.Response
// @Router /products [get]
func (h *ProductHandler) List(c *gin.Context) {
    var req appProduct.ListRequest
    if err := c.ShouldBindQuery(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "Invalid request", err)
        return
    }

    // Set defaults
    if req.Page == 0 {
        req.Page = 1
    }
    if req.PerPage == 0 {
        req.PerPage = 15
    }

    result, err := h.productService.List(c.Request.Context(), &req)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "Failed to fetch products", err)
        return
    }

    response.SuccessWithMeta(c, "Products retrieved successfully", result.Items, result.Meta)
}

// Create godoc
// @Summary Create product
// @Tags Products
// @Accept json
// @Produce json
// @Param body body appProduct.CreateRequest true "Product data"
// @Success 201 {object} response.Response
// @Router /products [post]
func (h *ProductHandler) Create(c *gin.Context) {
    var req appProduct.CreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "Invalid request", err)
        return
    }

    result, err := h.productService.Create(c.Request.Context(), &req)
    if err != nil {
        if err == appProduct.ErrCodeAlreadyExists {
            response.Error(c, http.StatusConflict, err.Error(), nil)
            return
        }
        response.Error(c, http.StatusInternalServerError, "Failed to create product", err)
        return
    }

    response.Success(c, http.StatusCreated, "Product created successfully", result)
}

// GetByID godoc
// @Summary Get product by ID
// @Tags Products
// @Produce json
// @Param id path int true "Product ID"
// @Success 200 {object} response.Response
// @Router /products/{id} [get]
func (h *ProductHandler) GetByID(c *gin.Context) {
    id, err := strconv.ParseUint(c.Param("id"), 10, 64)
    if err != nil {
        response.Error(c, http.StatusBadRequest, "Invalid ID", err)
        return
    }

    result, err := h.productService.GetByID(c.Request.Context(), id)
    if err != nil {
        if err == appProduct.ErrProductNotFound {
            response.Error(c, http.StatusNotFound, err.Error(), nil)
            return
        }
        response.Error(c, http.StatusInternalServerError, "Failed to fetch product", err)
        return
    }

    response.Success(c, http.StatusOK, "Product retrieved successfully", result)
}

// Update godoc
// @Summary Update product
// @Tags Products
// @Accept json
// @Produce json
// @Param id path int true "Product ID"
// @Param body body appProduct.UpdateRequest true "Product data"
// @Success 200 {object} response.Response
// @Router /products/{id} [put]
func (h *ProductHandler) Update(c *gin.Context) {
    id, err := strconv.ParseUint(c.Param("id"), 10, 64)
    if err != nil {
        response.Error(c, http.StatusBadRequest, "Invalid ID", err)
        return
    }

    var req appProduct.UpdateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "Invalid request", err)
        return
    }

    result, err := h.productService.Update(c.Request.Context(), id, &req)
    if err != nil {
        if err == appProduct.ErrProductNotFound {
            response.Error(c, http.StatusNotFound, err.Error(), nil)
            return
        }
        if err == appProduct.ErrCodeAlreadyExists {
            response.Error(c, http.StatusConflict, err.Error(), nil)
            return
        }
        response.Error(c, http.StatusInternalServerError, "Failed to update product", err)
        return
    }

    response.Success(c, http.StatusOK, "Product updated successfully", result)
}

// Delete godoc
// @Summary Delete product
// @Tags Products
// @Produce json
// @Param id path int true "Product ID"
// @Success 200 {object} response.Response
// @Router /products/{id} [delete]
func (h *ProductHandler) Delete(c *gin.Context) {
    id, err := strconv.ParseUint(c.Param("id"), 10, 64)
    if err != nil {
        response.Error(c, http.StatusBadRequest, "Invalid ID", err)
        return
    }

    err = h.productService.Delete(c.Request.Context(), id)
    if err != nil {
        if err == appProduct.ErrProductNotFound {
            response.Error(c, http.StatusNotFound, err.Error(), nil)
            return
        }
        response.Error(c, http.StatusInternalServerError, "Failed to delete product", err)
        return
    }

    response.Success(c, http.StatusOK, "Product deleted successfully", nil)
}
```

### Step 5: Register di Router & Main

#### 5.1 Update Router (`router.go`)

```go
// Tambahkan di internal/presentation/router/router.go

// Di struct Router, tambahkan:
productHandler *handler.ProductHandler

// Di function New(), tambahkan parameter:
productHandler *handler.ProductHandler,

// Di function Setup(), tambahkan routes:
// Products
products := v1.Group("/products")
products.Use(r.authMiddleware.Auth())
{
    products.GET("", r.productHandler.List)
    products.POST("", r.authMiddleware.RequirePermission("products.create"), r.productHandler.Create)
    products.GET("/:id", r.productHandler.GetByID)
    products.PUT("/:id", r.authMiddleware.RequirePermission("products.edit"), r.productHandler.Update)
    products.DELETE("/:id", r.authMiddleware.RequirePermission("products.delete"), r.productHandler.Delete)
}
```

#### 5.2 Update Main (`main.go`)

```go
// Di cmd/server/main.go, tambahkan:

// Import
appProduct "guyub/internal/application/product"

// Initialize repository
productRepo := mysql.NewProductRepository(db)

// Initialize service
productService := appProduct.NewService(productRepo)

// Initialize handler
productHandler := handler.NewProductHandler(productService)

// Pass ke router.New()
r := router.New(
    authMiddleware,
    authHandler,
    userHandler,
    roleHandler,
    masterHandler,
    analyticsHandler,
    activityHandler,
    auditHandler,
    assetHandler,
    productHandler,  // Tambahkan ini
    &router.Config{...},
)
```

### Step 6: Database Migration

Buat file `migrations/XXX_create_products_table.sql`

```sql
-- migrations/008_create_products_table.sql

CREATE TABLE IF NOT EXISTS products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    stock INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    UNIQUE INDEX idx_products_code (code),
    INDEX idx_products_name (name),
    INDEX idx_products_is_active (is_active),
    INDEX idx_products_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

Jalankan migration:

```bash
go run ./cmd/migrate up
```

### Step 7: Frontend - API Service

Buat file `admin/src/api/products.ts`

```typescript
// admin/src/api/products.ts
import apiClient from './client';
import type { PaginatedResponse, Product } from '@/types';

export interface ProductListParams {
  page?: number;
  per_page?: number;
  search?: string;
  sort_by?: string;
  sort_dir?: 'asc' | 'desc';
  is_active?: boolean;
}

export interface CreateProductData {
  code: string;
  name: string;
  description?: string;
  price: number;
  stock: number;
}

export interface UpdateProductData extends CreateProductData {
  is_active?: boolean;
}

export const productsApi = {
  list: (params?: ProductListParams) =>
    apiClient.get<PaginatedResponse<Product>>('/products', { params }),

  getById: (id: number) =>
    apiClient.get<{ data: Product }>(`/products/${id}`),

  create: (data: CreateProductData) =>
    apiClient.post<{ data: Product }>('/products', data),

  update: (id: number, data: UpdateProductData) =>
    apiClient.put<{ data: Product }>(`/products/${id}`, data),

  delete: (id: number) =>
    apiClient.delete(`/products/${id}`),
};
```

### Step 8: Frontend - Types

Tambahkan di `admin/src/types/index.ts`

```typescript
// Tambahkan interface Product
export interface Product extends BaseEntity {
  code: string;
  name: string;
  description: string | null;
  price: number;
  stock: number;
  is_active: boolean;
}
```

### Step 9: Frontend - Page Component

Buat file `admin/src/pages/products/ProductsListPage.tsx`

```tsx
// admin/src/pages/products/ProductsListPage.tsx
import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { PlusIcon, PencilIcon, TrashIcon } from '@heroicons/react/24/outline';
import { productsApi } from '@/api/products';
import { Button, DataTable, Pagination, Badge, ConfirmDialog, Card } from '@/components/ui';
import { useUIStore } from '@/stores/uiStore';
import type { Product } from '@/types';

const ProductsListPage: React.FC = () => {
  const queryClient = useQueryClient();
  const { toast } = useUIStore();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [deleteId, setDeleteId] = useState<number | null>(null);

  // Fetch products
  const { data, isLoading } = useQuery({
    queryKey: ['products', { page, search }],
    queryFn: () => productsApi.list({ page, per_page: 15, search }),
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: number) => productsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product deleted successfully');
      setDeleteId(null);
    },
    onError: () => {
      toast.error('Failed to delete product');
    },
  });

  const columns = [
    { key: 'code', label: 'Code', sortable: true },
    { key: 'name', label: 'Name', sortable: true },
    {
      key: 'price',
      label: 'Price',
      render: (product: Product) => `Rp ${product.price.toLocaleString('id-ID')}`,
    },
    { key: 'stock', label: 'Stock' },
    {
      key: 'is_active',
      label: 'Status',
      render: (product: Product) => (
        <Badge variant={product.is_active ? 'success' : 'danger'}>
          {product.is_active ? 'Active' : 'Inactive'}
        </Badge>
      ),
    },
    {
      key: 'actions',
      label: '',
      render: (product: Product) => (
        <div className="flex gap-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {/* Navigate to edit */}}
          >
            <PencilIcon className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setDeleteId(product.id)}
          >
            <TrashIcon className="h-4 w-4 text-red-500" />
          </Button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-900">Products</h1>
        <Button onClick={() => {/* Navigate to create */}}>
          <PlusIcon className="h-5 w-5 mr-2" />
          Add Product
        </Button>
      </div>

      <Card>
        <DataTable
          columns={columns}
          data={data?.data || []}
          loading={isLoading}
        />

        {data?.meta && (
          <div className="mt-4">
            <Pagination
              currentPage={data.meta.current_page}
              lastPage={data.meta.last_page}
              perPage={data.meta.per_page}
              total={data.meta.total}
              onPageChange={setPage}
            />
          </div>
        )}
      </Card>

      <ConfirmDialog
        open={deleteId !== null}
        onClose={() => setDeleteId(null)}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        title="Delete Product"
        message="Are you sure you want to delete this product?"
        confirmText="Delete"
        confirmVariant="danger"
        loading={deleteMutation.isPending}
      />
    </div>
  );
};

export default ProductsListPage;
```

### Step 10: Register Route di Router

Tambahkan di `admin/src/router.tsx`

```tsx
// Import
import ProductsListPage from '@/pages/products/ProductsListPage';

// Di dalam routes array, tambahkan:
{
  path: 'products',
  element: <ProductsListPage />,
},
```

### Checklist Module Baru

- [ ] Domain Layer
  - [ ] Entity dengan GORM tags
  - [ ] Repository interface
  - [ ] Enums/Value Objects (jika ada)
- [ ] Infrastructure Layer
  - [ ] Repository implementation
- [ ] Application Layer
  - [ ] Service dengan business logic
  - [ ] DTOs (Request/Response)
  - [ ] Custom errors
- [ ] Presentation Layer
  - [ ] Handler dengan semua CRUD operations
  - [ ] Validasi request
- [ ] Router
  - [ ] Register routes
  - [ ] Apply middleware (auth, permission)
- [ ] Main
  - [ ] Initialize repository, service, handler
  - [ ] Pass ke router
- [ ] Database
  - [ ] Migration file
  - [ ] Jalankan migration
- [ ] Frontend
  - [ ] API service
  - [ ] Types
  - [ ] List page
  - [ ] Form page (create/edit)
  - [ ] Register route
- [ ] Permission
  - [ ] Tambahkan permission di seeder
  - [ ] Assign ke role

---

## 8. Konvensi Kode

### Backend (Go)

#### Naming Convention

| Jenis | Convention | Contoh |
|-------|------------|--------|
| Package | lowercase, singular | `user`, `product` |
| Struct | PascalCase | `UserResponse`, `CreateRequest` |
| Interface | PascalCase, noun | `Repository`, `Service` |
| Function | PascalCase (exported), camelCase (private) | `GetByID`, `validateInput` |
| Variable | camelCase | `userRepo`, `totalCount` |
| Constant | PascalCase atau SCREAMING_SNAKE | `MaxRetries`, `MAX_RETRIES` |

#### Error Handling

```go
// Selalu return error, jangan panic
func (s *Service) GetByID(ctx context.Context, id uint64) (*Response, error) {
    // Cek error
    result, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, err  // Return error ke caller
    }

    // Cek nil
    if result == nil {
        return nil, ErrNotFound
    }

    return toResponse(result), nil
}
```

#### Comments

```go
// GetByID returns a user by their ID.
// Returns ErrUserNotFound if user doesn't exist.
func (s *Service) GetByID(ctx context.Context, id uint64) (*UserResponse, error) {
    // ... implementation
}
```

### Frontend (TypeScript/React)

#### Naming Convention

| Jenis | Convention | Contoh |
|-------|------------|--------|
| Component | PascalCase | `UserList`, `ProductForm` |
| Function | camelCase | `handleSubmit`, `formatDate` |
| Variable | camelCase | `isLoading`, `userData` |
| Constant | SCREAMING_SNAKE | `API_URL`, `MAX_ITEMS` |
| Type/Interface | PascalCase | `User`, `CreateUserData` |
| File (component) | PascalCase | `UserList.tsx` |
| File (utility) | camelCase | `formatters.ts` |

#### Component Structure

```tsx
// 1. Imports
import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';

// 2. Types
interface Props {
  userId: number;
}

// 3. Component
const UserDetail: React.FC<Props> = ({ userId }) => {
  // 3.1 Hooks (state, queries, mutations)
  const [isEditing, setIsEditing] = useState(false);
  const { data, isLoading } = useQuery({...});

  // 3.2 Derived state
  const fullName = `${data?.firstName} ${data?.lastName}`;

  // 3.3 Event handlers
  const handleEdit = () => {
    setIsEditing(true);
  };

  // 3.4 Effects
  useEffect(() => {
    // ...
  }, [dependency]);

  // 3.5 Render helpers
  const renderContent = () => {
    if (isLoading) return <Spinner />;
    // ...
  };

  // 3.6 Return JSX
  return (
    <div>
      {renderContent()}
    </div>
  );
};

export default UserDetail;
```

---

## 9. Database & Migration

### Family Tree Database Schema

```
┌────────────────────┐       ┌────────────────────┐
│     families       │       │      persons       │
├────────────────────┤       ├────────────────────┤
│ id                 │◄──────┤ family_id (FK)     │
│ name               │       │ id                 │
│ description        │       │ first_name         │
│ origin             │       │ last_name          │
│ motto              │       │ nickname           │
│ invite_code        │       │ gender             │
│ is_public          │       │ birth_date         │
│ created_by         │       │ death_date         │
└────────────────────┘       │ is_alive           │
                             │ photo_url          │
                             │ generation_level   │
                             └─────────┬──────────┘
                                       │
        ┌──────────────────────────────┴──────────────────────────────┐
        │                                                              │
        ▼                                                              ▼
┌────────────────────┐                                   ┌────────────────────┐
│   relationships    │                                   │   tree_positions   │
├────────────────────┤                                   ├────────────────────┤
│ id                 │                                   │ id                 │
│ person_id (FK)     │                                   │ person_id (FK)     │
│ related_person_id  │                                   │ family_id (FK)     │
│ type               │                                   │ x                  │
│ marriage_status    │                                   │ y                  │
│ marriage_date      │                                   │ level              │
│ divorce_date       │                                   │ order              │
└────────────────────┘                                   └────────────────────┘

Relationship Types: parent, child, spouse, sibling
Marriage Status: married, divorced, widowed
```

### Membuat Migration Baru

```bash
# Format nama file: XXX_description.sql
# XXX = nomor urut (001, 002, dst)

# Contoh
touch migrations/009_add_category_to_products.sql
```

### Struktur Migration

```sql
-- migrations/009_add_category_to_products.sql

-- Deskripsi: Menambahkan kolom category_id ke tabel products

-- UP Migration
ALTER TABLE products
ADD COLUMN category_id BIGINT UNSIGNED NULL AFTER name,
ADD INDEX idx_products_category_id (category_id),
ADD CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE SET NULL;

-- DOWN Migration (untuk rollback, simpan di file terpisah atau comment)
-- ALTER TABLE products DROP FOREIGN KEY fk_products_category;
-- ALTER TABLE products DROP COLUMN category_id;
```

### Menjalankan Migration

```bash
# Jalankan semua migration yang belum dijalankan
go run ./cmd/migrate up

# Rollback migration terakhir
go run ./cmd/migrate down

# Reset semua migration
go run ./cmd/migrate reset

# Cek status migration
go run ./cmd/migrate status
```

### Best Practices

1. **Satu migration untuk satu perubahan** - Jangan gabung banyak perubahan
2. **Selalu sediakan rollback** - Pikirkan cara rollback sebelum deploy
3. **Jangan edit migration yang sudah dijalankan** - Buat migration baru
4. **Gunakan transaksi** - Untuk operasi yang harus atomic
5. **Test di local dulu** - Sebelum jalankan di staging/production

---

## 10. API Development

### Response Format Standard

#### Success Response

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

#### Success dengan Pagination

```json
{
  "success": true,
  "message": "Data retrieved",
  "data": [...],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 15,
    "total": 150
  }
}
```

#### Error Response

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email is required"],
    "password": ["Password must be at least 8 characters"]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Kapan Digunakan |
|------|---------|-----------------|
| 200 | OK | Request berhasil |
| 201 | Created | Resource berhasil dibuat |
| 204 | No Content | Berhasil tapi tidak ada response body |
| 400 | Bad Request | Request tidak valid (validation error) |
| 401 | Unauthorized | Belum login / token invalid |
| 403 | Forbidden | Tidak punya permission |
| 404 | Not Found | Resource tidak ditemukan |
| 409 | Conflict | Duplikat (unique constraint) |
| 422 | Unprocessable | Business logic error |
| 500 | Internal Error | Server error |

### Validasi Request

Gunakan struct tags untuk validasi:

```go
type CreateRequest struct {
    Email    string `json:"email" validate:"required,email,max=255"`
    Password string `json:"password" validate:"required,min=8"`
    Name     string `json:"name" validate:"required,max=100"`
    Phone    string `json:"phone" validate:"omitempty,e164"`
    Age      int    `json:"age" validate:"omitempty,min=1,max=150"`
}
```

### Validasi Tags yang Sering Dipakai

| Tag | Deskripsi | Contoh |
|-----|-----------|--------|
| `required` | Wajib diisi | `validate:"required"` |
| `email` | Format email | `validate:"email"` |
| `min` | Minimum (string=length, number=value) | `validate:"min=8"` |
| `max` | Maximum | `validate:"max=255"` |
| `oneof` | Salah satu dari | `validate:"oneof=admin user"` |
| `omitempty` | Skip jika kosong | `validate:"omitempty,email"` |
| `e164` | Format telepon internasional | `validate:"e164"` |
| `url` | Format URL | `validate:"url"` |
| `uuid` | Format UUID | `validate:"uuid"` |

---

## 11. Frontend Development

### State Management

#### Kapan Pakai React Query vs Zustand?

| React Query | Zustand |
|-------------|---------|
| Data dari server | Data client-side |
| Caching API response | UI state |
| Background refetching | Form state |
| Optimistic updates | Theme, sidebar |

#### Contoh React Query

```tsx
// Fetch data
const { data, isLoading, error } = useQuery({
  queryKey: ['users', { page, search }],
  queryFn: () => usersApi.list({ page, search }),
});

// Mutation
const mutation = useMutation({
  mutationFn: (data: CreateUserData) => usersApi.create(data),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] });
    toast.success('User created');
  },
  onError: (error) => {
    toast.error(getErrorMessage(error));
  },
});
```

#### Contoh Zustand

```tsx
// stores/uiStore.ts
import { create } from 'zustand';

interface UIState {
  sidebarOpen: boolean;
  setSidebarOpen: (open: boolean) => void;
  toast: {
    success: (message: string) => void;
    error: (message: string) => void;
  };
}

export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  setSidebarOpen: (open) => set({ sidebarOpen: open }),
  toast: {
    success: (message) => { /* implementation */ },
    error: (message) => { /* implementation */ },
  },
}));
```

### Family Tree Component

Family Tree menggunakan **React Flow** (@xyflow/react) untuk visualisasi interaktif pohon keluarga.

#### Struktur Komponen

```
admin/src/components/family/
├── FamilyTree.tsx      # Komponen utama React Flow
├── PersonNode.tsx      # Custom node untuk setiap person
└── index.ts            # Export barrel
```

#### FamilyTree Props

```tsx
interface FamilyTreeProps {
  data: FamilyTreeData;                    // Data pohon keluarga
  onPersonEdit?: (person: Person) => void; // Handler edit person
  onAddRelative?: (person: Person, type: RelationshipType) => void;
  onPositionsChange?: (positions: Position[]) => void;
  isEditable?: boolean;                    // Default true
  minimal?: boolean;                       // Default false - hide semua controls
}
```

#### Penggunaan Minimal Mode

Untuk preview di landing page, gunakan `minimal={true}`:

```tsx
<FamilyTree
  data={demoFamily}
  minimal={true}       // Sembunyikan semua controls
  isEditable={false}   // Non-editable
/>
```

Dalam minimal mode:
- Search bar, stats panel, minimap, legend tersembunyi
- Background transparan
- Drag, zoom, pan dinonaktifkan
- Hanya menampilkan nodes dan edges

#### Edge Styling

| Relationship | Style |
|-------------|-------|
| Parent-Child | Solid line, amber color, arrow marker |
| Spouse | Dashed line, pink color, animated |
| Sibling | Dashed line, indigo color |

#### Auto Layout

```tsx
// Fungsi auto-layout mengelompokkan berdasarkan generation_level
function autoLayout(persons: Person[], relationships: Relationship[]) {
  // Group by generation
  // Calculate horizontal spread
  // Center each generation
}
```

### Form Handling dengan React Hook Form

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Schema
const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Min 8 characters'),
});

type FormData = z.infer<typeof schema>;

// Component
const LoginForm = () => {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    // Handle submit
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input
        {...register('email')}
        error={errors.email?.message}
      />
      <Input
        type="password"
        {...register('password')}
        error={errors.password?.message}
      />
      <Button type="submit" loading={isSubmitting}>
        Login
      </Button>
    </form>
  );
};
```

### Tailwind CSS Tips

#### Responsive Design

```tsx
// Mobile first approach
<div className="
  w-full          // Mobile: full width
  md:w-1/2        // Tablet: half width
  lg:w-1/3        // Desktop: third width
">
```

#### Common Patterns

```tsx
// Card
<div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">

// Flex container
<div className="flex items-center justify-between gap-4">

// Grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

// Form input
<input className="
  w-full px-3 py-2
  border border-gray-300 rounded-lg
  focus:ring-2 focus:ring-primary-500 focus:border-primary-500
  disabled:bg-gray-100 disabled:cursor-not-allowed
"/>
```

---

## 12. Testing

### Backend Testing

#### Unit Test

```go
// internal/application/user/service_test.go
package user

import (
    "context"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// Mock repository
type mockUserRepo struct {
    mock.Mock
}

func (m *mockUserRepo) FindByID(ctx context.Context, id uint64) (*User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*User), args.Error(1)
}

// Test
func TestService_GetByID(t *testing.T) {
    mockRepo := new(mockUserRepo)
    service := NewService(mockRepo)

    t.Run("success", func(t *testing.T) {
        expectedUser := &User{ID: 1, Name: "John"}
        mockRepo.On("FindByID", mock.Anything, uint64(1)).Return(expectedUser, nil)

        result, err := service.GetByID(context.Background(), 1)

        assert.NoError(t, err)
        assert.Equal(t, "John", result.Name)
    })

    t.Run("not found", func(t *testing.T) {
        mockRepo.On("FindByID", mock.Anything, uint64(999)).Return(nil, nil)

        result, err := service.GetByID(context.Background(), 999)

        assert.Error(t, err)
        assert.Equal(t, ErrUserNotFound, err)
        assert.Nil(t, result)
    })
}
```

#### Menjalankan Test

```bash
# Semua test
go test -v ./...

# Dengan coverage
go test -v -cover ./...

# Package tertentu
go test -v ./internal/application/user/...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Frontend Testing

```bash
# Jalankan test
npm test

# Dengan coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

---

## 13. Debugging

### Backend Debugging

#### Logging

```go
import "guyub/pkg/logger"

// Debug
logger.Debug("Processing request", "user_id", userID)

// Info
logger.Info("User created successfully", "email", user.Email)

// Warning
logger.Warn("Rate limit approaching", "current", count, "max", limit)

// Error
logger.Error("Failed to create user", "error", err, "email", email)
```

#### Debug dengan Delve

```bash
# Install
go install github.com/go-delve/delve/cmd/dlv@latest

# Debug
dlv debug ./cmd/server

# Attach ke process
dlv attach <pid>
```

### Frontend Debugging

#### React DevTools

Install extension React Developer Tools di browser.

#### Console Logging

```tsx
// Di component
console.log('Render', { data, isLoading });

// Di effect
useEffect(() => {
  console.log('Effect triggered', dependency);
}, [dependency]);
```

#### React Query DevTools

```tsx
// main.tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

<QueryClientProvider client={queryClient}>
  <App />
  <ReactQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

### Database Debugging

```sql
-- Cek slow queries
SHOW PROCESSLIST;

-- Explain query
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- Cek table size
SELECT
  table_name,
  ROUND(data_length / 1024 / 1024, 2) AS data_mb,
  ROUND(index_length / 1024 / 1024, 2) AS index_mb
FROM information_schema.tables
WHERE table_schema = 'guyub';
```

---

## 14. Deployment

### Build untuk Production

#### Backend

```bash
cd backend

# Build binary
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/server ./cmd/server

# Atau dengan Makefile
make build
```

#### Frontend

```bash
cd admin

# Build static files
npm run build

# Output di folder dist/
```

### Docker

```bash
# Build images
docker-compose build

# Run
docker-compose up -d

# Logs
docker-compose logs -f

# Stop
docker-compose down
```

### Environment Production

```env
# Backend
APP_ENV=production
LOG_LEVEL=info
LOG_FORMAT=json

# Database
DB_HOST=mysql-server
DB_PORT=3306

# JWT
JWT_SECRET=<strong-secret-key>
JWT_EXPIRY=3600
```

### Checklist Deployment

- [ ] Build tanpa error
- [ ] Migration sudah dijalankan
- [ ] Environment variables sudah diset
- [ ] CORS sudah dikonfigurasi
- [ ] SSL/HTTPS sudah aktif
- [ ] Backup database
- [ ] Health check endpoint
- [ ] Monitoring & logging
- [ ] Rollback plan

---

## 15. FAQ & Troubleshooting

### Backend

#### Q: Error "connection refused" ke database

**A:** Pastikan:
1. MySQL sudah running: `brew services start mysql`
2. Kredensial di `.env` sudah benar
3. Database sudah dibuat: `CREATE DATABASE guyub;`

#### Q: Error "token invalid"

**A:** Cek:
1. JWT_SECRET di backend dan cara generate token
2. Token sudah expired? Cek JWT_EXPIRY
3. Format header: `Authorization: Bearer <token>`

#### Q: Error CORS

**A:** Pastikan origin frontend ada di CORS config:
```env
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Frontend

#### Q: Error "Network Error"

**A:** Cek:
1. Backend sudah running?
2. VITE_API_URL di `.env` sudah benar?
3. CORS sudah dikonfigurasi?

#### Q: State tidak update setelah mutation

**A:** Pastikan invalidate query:
```tsx
onSuccess: () => {
  queryClient.invalidateQueries({ queryKey: ['users'] });
}
```

#### Q: Hot reload tidak jalan

**A:** Coba:
1. Restart dev server
2. Clear cache: `rm -rf node_modules/.vite`
3. Reinstall: `rm -rf node_modules && npm install`

### Database

#### Q: Migration gagal

**A:** Cek:
1. Syntax SQL sudah benar?
2. Table/column yang direferensi sudah ada?
3. Cek error message lengkap di log

#### Q: Data tidak muncul setelah seeding

**A:** Cek:
1. Seeder sudah dijalankan? `go run ./cmd/seed`
2. Koneksi database benar?
3. Cek di database langsung: `SELECT * FROM users;`

---

## Kontak & Support

Jika ada pertanyaan atau menemukan bug:

1. Buat issue di repository
2. Hubungi tim development
3. Cek dokumentasi di `README.md` dan `docs/PANDUAN.md`

---

**Selamat Coding! Semangat!**

---

*Dokumentasi ini dibuat pada: 2025-12-17*
*Versi: 1.0.0*
