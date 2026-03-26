# Guyub Platform

> **Guyub** (Javanese for "togetherness") - A Family Tree & Genealogy Platform built with Clean Architecture using Go (Gin) + React (TypeScript) + MySQL + React Flow.

[![Go Version](https://img.shields.io/badge/Go-1.23+-00ADD8?style=flat&logo=go)](https://golang.org)
[![React Version](https://img.shields.io/badge/React-18+-61DAFB?style=flat&logo=react)](https://reactjs.org)
[![MySQL Version](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql)](https://mysql.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Development](#development)
- [Deployment](#deployment)
- [Contributing](#contributing)

---

## Overview

Guyub Platform is a **Family Tree & Genealogy** application designed to help families preserve their history and strengthen bonds across generations. Built with enterprise-grade architecture, it provides:

- **Interactive Family Tree** visualization using React Flow
- **Person Management** with complete profiles (birth/death, photos, occupation)
- **Relationship Mapping** (parent-child, spouse, sibling connections)
- **Public Landing Page** with tree preview in Bahasa Indonesia
- **User Management** with role-based access control (RBAC)
- **Audit Logging** that is immutable and comprehensive
- **Asset Management** for photo uploads

The platform follows **Clean Architecture** principles, ensuring:
- Separation of concerns
- Testability
- Maintainability
- Scalability

---

## Features

### Family Tree Features

| Feature | Description |
|---------|-------------|
| **Interactive Tree** | React Flow-based visualization with drag-and-drop |
| **Person Profiles** | Complete details: name, gender, birth/death, photo, occupation |
| **Relationships** | Parent-child, spouse, sibling connections with visual edges |
| **Auto Layout** | Automatic tree arrangement by generation |
| **Tree Positions** | Customizable node positions saved to database |
| **Landing Page** | Public showcase with demo tree (Bahasa Indonesia) |
| **Minimal Mode** | Clean preview mode hiding all controls |

### Admin Features

| Feature | Description |
|---------|-------------|
| **Authentication** | JWT-based auth with refresh tokens |
| **Authorization** | RBAC with granular permissions |
| **User Management** | CRUD, bulk operations, import/export |
| **Role Management** | Dynamic roles with permission assignment |
| **Master Data** | Hierarchical types, cascading dropdowns |
| **Audit Logging** | Immutable logs for all changes |
| **Activity Tracking** | User activity monitoring |
| **Asset Management** | File upload with ref_id + kind pattern |
| **Analytics** | Dashboard with statistics and charts |

### Security Features

- Password hashing with bcrypt
- JWT with short expiry + refresh tokens
- Rate limiting on sensitive endpoints
- Audit trail for compliance
- IP address tracking
- Session management

### UI/UX Features

- Modern, clean interface (Emerald/Green theme)
- Responsive design
- Dark mode support (planned)
- Toast notifications
- Confirmation dialogs
- Loading states
- Empty states
- Pagination with info

---

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │   Handlers  │  │  Middleware │  │   Router    │                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
├─────────────────────────────────────────────────────────────────────┤
│                         APPLICATION                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │  Services   │  │    DTOs     │  │   Errors    │                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
├─────────────────────────────────────────────────────────────────────┤
│                           DOMAIN                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │  Entities   │  │ Value Objs  │  │ Repo Ifaces │                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
├─────────────────────────────────────────────────────────────────────┤
│                       INFRASTRUCTURE                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │  Database   │  │   Storage   │  │  External   │                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
Request → Router → Middleware → Handler → Service → Repository → Database
                                    ↓
Response ← Handler ← Service ← Repository
```

### Module Structure

Each module follows the same pattern:

```
module/
├── domain/
│   ├── entity.go         # Domain entity
│   ├── repository.go     # Repository interface
│   └── enums.go          # Value objects/enums
├── application/
│   ├── service.go        # Business logic
│   ├── dto.go            # Data transfer objects
│   └── errors.go         # Domain errors
├── infrastructure/
│   └── repository.go     # Repository implementation
└── presentation/
    └── handler.go        # HTTP handler
```

---

## Tech Stack

### Backend

| Technology | Purpose |
|------------|---------|
| **Go 1.23+** | Programming language |
| **Gin** | HTTP web framework |
| **GORM** | ORM for database operations |
| **JWT** | Authentication tokens |
| **Viper** | Configuration management |
| **Zap** | Structured logging |
| **Validator** | Request validation |

### Frontend

| Technology | Purpose |
|------------|---------|
| **React 18+** | UI framework |
| **TypeScript** | Type safety |
| **Vite** | Build tool |
| **React Router** | Routing |
| **React Flow** | Family tree visualization |
| **React Query** | Server state |
| **Zustand** | Client state |
| **Tailwind CSS** | Styling |
| **React Hook Form** | Forms |
| **Zod** | Validation |
| **Axios** | HTTP client |

### Database

| Technology | Purpose |
|------------|---------|
| **MySQL 8.0** | Primary database |
| **Redis** | Caching (optional) |

### DevOps

| Technology | Purpose |
|------------|---------|
| **Docker** | Containerization |
| **Docker Compose** | Local development |
| **Nginx** | Reverse proxy / SPA serving |
| **GitHub Actions** | CI/CD (planned) |

---

## Project Structure

```
guyub/
├── backend/                          # Go backend
│   ├── cmd/
│   │   ├── server/
│   │   │   └── main.go              # Application entry point
│   │   ├── migrate/
│   │   │   └── main.go              # Migration runner
│   │   └── seed/
│   │       └── main.go              # Seeder runner
│   ├── internal/
│   │   ├── domain/                  # Domain layer
│   │   │   ├── user/
│   │   │   ├── role/
│   │   │   ├── permission/
│   │   │   ├── master/
│   │   │   ├── audit/
│   │   │   ├── activity/
│   │   │   └── asset/
│   │   ├── application/             # Application layer
│   │   │   ├── user/
│   │   │   ├── role/
│   │   │   ├── master/
│   │   │   ├── auth/
│   │   │   ├── audit/
│   │   │   └── asset/
│   │   ├── infrastructure/          # Infrastructure layer
│   │   │   ├── persistence/
│   │   │   │   └── mysql/
│   │   │   ├── auth/
│   │   │   └── storage/
│   │   └── presentation/            # Presentation layer
│   │       ├── http/
│   │       │   ├── handler/
│   │       │   ├── middleware/
│   │       │   ├── request/
│   │       │   └── response/
│   │       └── router/
│   ├── pkg/                         # Shared packages
│   │   ├── config/
│   │   ├── logger/
│   │   ├── validator/
│   │   └── utils/
│   ├── migrations/                  # Database migrations
│   ├── config/
│   │   └── config.yaml
│   ├── .env.example
│   ├── go.mod
│   ├── go.sum
│   ├── Makefile
│   └── Dockerfile
│
├── frontend/                        # React frontend
│   ├── src/
│   │   ├── api/                    # API client
│   │   ├── components/
│   │   │   ├── ui/                 # Base UI components
│   │   │   ├── shared/             # Complex shared
│   │   │   ├── family/             # Family tree components
│   │   │   │   ├── FamilyTree.tsx  # React Flow tree
│   │   │   │   └── PersonNode.tsx  # Custom person node
│   │   │   ├── auth/
│   │   │   ├── users/
│   │   │   ├── roles/
│   │   │   ├── master/
│   │   │   ├── audit/
│   │   │   └── assets/
│   │   ├── hooks/                  # Custom hooks
│   │   ├── layouts/
│   │   ├── pages/
│   │   │   ├── landing/            # Public landing page
│   │   │   │   └── LandingPage.tsx # Hero with tree preview
│   │   │   ├── family/             # Family tree pages
│   │   │   └── ...
│   │   ├── stores/                 # Zustand stores
│   │   ├── types/
│   │   ├── utils/
│   │   └── styles/
│   ├── public/
│   ├── index.html
│   ├── tailwind.config.js
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── package.json
│   └── Dockerfile
│
├── docker-compose.yml
├── README.md                       # This file
└── LICENSE
```

---

## Getting Started

### Prerequisites

- **Go** 1.23 or higher
- **Node.js** 20 or higher
- **MySQL** 8.0 or higher
- **Docker** (optional, for containerized setup)

### Quick Start with Docker

```bash
# Clone the repository
git clone https://github.com/jaroteko18/guyub.git
cd guyub

# Start all services
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8080
```

### Manual Setup

#### 1. Database Setup

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE guyub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

#### 2. Backend Setup

```bash
cd backend

# Copy environment file
cp .env.example .env

# Edit .env with your database credentials
vim .env

# Install dependencies
go mod download

# Run migrations
go run ./cmd/migrate up

# Run seeders
go run ./cmd/seed

# Start the server
go run ./cmd/server
```

#### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Start development server
npm run dev
```

### Default Credentials

After running seeders, you can login with:

| Field | Value |
|-------|-------|
| Email | admin@guyub.id |
| Password | Admin@123 |

---

## Configuration

### Backend Environment Variables

```env
# Application
APP_NAME=Guyub-Platform
APP_ENV=development          # development, staging, production
APP_PORT=8080
APP_URL=http://localhost:8080

# Database
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=guyub
DB_USERNAME=root
DB_PASSWORD=secret
DB_MAX_OPEN_CONNS=25
DB_MAX_IDLE_CONNS=5
DB_CONN_MAX_LIFETIME=5m

# JWT
JWT_SECRET=your-256-bit-secret-key-here
JWT_EXPIRY=3600              # seconds (1 hour)
JWT_REFRESH_EXPIRY=604800    # seconds (7 days)

# Storage
STORAGE_DRIVER=local
STORAGE_PATH=./storage/uploads

# Rate Limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_DURATION=60       # seconds

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Authorization,Content-Type

# Logging
LOG_LEVEL=debug              # debug, info, warn, error
LOG_FORMAT=json              # json, console
```

### Frontend Environment Variables

```env
# API
VITE_API_URL=http://localhost:8080/api/v1
VITE_ASSETS_URL=http://localhost:8080/assets

# App
VITE_APP_NAME=Guyub Platform
VITE_APP_VERSION=1.0.0

# Features
VITE_ENABLE_2FA=true
VITE_ENABLE_IMPORT_EXPORT=true
```

---

## API Documentation

### Base URL

```
http://localhost:8080/api/v1
```

### Authentication

All protected endpoints require Bearer token:

```
Authorization: Bearer <jwt_token>
```

### Response Format

#### Success Response
```json
{
    "success": true,
    "message": "Operation successful",
    "data": { ... }
}
```

#### Paginated Response
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
        "email": ["The email field is required"]
    }
}
```

### Endpoints Summary

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/login` | Login | No |
| POST | `/auth/logout` | Logout | Yes |
| GET | `/auth/me` | Current user | Yes |
| GET | `/users` | List users | Yes |
| POST | `/users` | Create user | Yes |
| GET | `/users/:id` | Get user | Yes |
| PUT | `/users/:id` | Update user | Yes |
| DELETE | `/users/:id` | Delete user | Yes |
| GET | `/roles` | List roles | Yes |
| POST | `/roles` | Create role | Yes |
| GET | `/master/types` | List types | Yes |
| GET | `/audit` | List audit logs | Yes |
| GET | `/activity` | List activities | Yes |
| POST | `/assets/upload` | Upload file | Yes |

**Note**: See router for full API documentation

---

## Database Schema

### Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    users    │       │    roles    │       │ permissions │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id          │◄──┐   │ id          │◄──┐   │ id          │
│ name        │   │   │ name        │   │   │ name        │
│ email       │   │   │ description │   │   │ guard_name  │
│ password    │   │   │ level       │   │   └──────┬──────┘
│ status      │   │   └──────┬──────┘   │          │
│ type        │   │          │          │          │
│ deleted_at  │   │          │          │          │
└─────────────┘   │          │          │          │
                  │          ▼          │          ▼
           ┌──────┴───────────────┐   ┌─────────────────┐
           │  model_has_roles     │   │role_has_perms   │
           ├──────────────────────┤   ├─────────────────┤
           │ role_id (FK)         │   │ role_id (FK)    │
           │ model_type           │   │ permission_id   │
           │ model_id             │   └─────────────────┘
           └──────────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ app_master_types│       │app_master_values│
├─────────────────┤       ├─────────────────┤
│ id              │◄──────┤ type_id (FK)    │
│ parent_id (self)│       │ parent_value_id │
│ code            │       │ code            │
│ name            │       │ name            │
│ is_active       │       │ is_active       │
│ sort_order      │       │ sort_order      │
└─────────────────┘       └─────────────────┘

┌─────────────────┐       ┌─────────────────┐
│   audit_logs    │       │  activity_logs  │
├─────────────────┤       ├─────────────────┤
│ id              │       │ id              │
│ user_id (FK)    │       │ user_id (FK)    │
│ event           │       │ activity_type   │
│ auditable_type  │       │ ip_address      │
│ auditable_id    │       │ device_type     │
│ old_values      │       │ description     │
│ new_values      │       │ metadata        │
│ security_level  │       └─────────────────┘
└─────────────────┘
   (IMMUTABLE)

┌─────────────────┐
│   app_assets    │
├─────────────────┤
│ id (UUID)       │
│ ref_id          │
│ kind            │
│ original_filename│
│ mime_type       │
│ storage_path    │
│ uploaded_by     │
└─────────────────┘
```

### Tables Overview

| Table | Records | Description |
|-------|---------|-------------|
| users | Variable | User accounts |
| roles | 5 default | System roles |
| permissions | ~25 | System permissions |
| model_has_roles | Variable | User-Role mapping |
| role_has_permissions | Variable | Role-Permission mapping |
| audit_logs | Grows | Immutable audit trail |
| activity_logs | Grows | User activities |
| app_master_types | Variable | Master data types |
| app_master_values | Variable | Master data values |
| app_assets | Variable | Uploaded files |

---

## Development

### Running Tests

#### Backend
```bash
cd backend

# Run all tests
go test -v ./...

# Run with coverage
go test -v -cover ./...

# Run specific package
go test -v ./internal/application/user/...
```

#### Frontend
```bash
cd frontend

# Run tests
npm test

# Run with coverage
npm run test:coverage
```

### Code Style

#### Backend (Go)
- Follow [Effective Go](https://golang.org/doc/effective_go)
- Use `gofmt` for formatting
- Use `golangci-lint` for linting

```bash
# Format code
gofmt -w .

# Lint code
golangci-lint run
```

#### Frontend (TypeScript/React)
- Follow [Airbnb Style Guide](https://github.com/airbnb/javascript)
- Use ESLint + Prettier

```bash
# Lint code
npm run lint

# Format code
npm run format
```

### Database Migrations

```bash
cd backend

# Create new migration
go run ./cmd/migrate create <migration_name>

# Run migrations
go run ./cmd/migrate up

# Rollback last migration
go run ./cmd/migrate down

# Rollback all migrations
go run ./cmd/migrate reset
```

### Hot Reload

#### Backend
```bash
# Install air
go install github.com/cosmtrek/air@latest

# Run with hot reload
air -c .air.toml
```

#### Frontend
```bash
# Vite already includes hot reload
npm run dev
```

---

## Deployment

### Docker Deployment

#### Build Images

```bash
# Build backend
docker build -t guyub-backend:latest ./backend

# Build frontend
docker build -t guyub-frontend:latest ./frontend
```

#### Docker Compose (Production)

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  backend:
    image: guyub-backend:latest
    environment:
      - APP_ENV=production
      - DB_HOST=mysql
    ports:
      - "8080:8080"
    depends_on:
      - mysql

  frontend:
    image: guyub-frontend:latest
    ports:
      - "80:80"
    depends_on:
      - backend

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_DATABASE=guyub
      - MYSQL_ROOT_PASSWORD=secret
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

### Manual Deployment

#### Backend
```bash
# Build binary
CGO_ENABLED=0 GOOS=linux go build -o bin/server ./cmd/server

# Copy to server
scp bin/server user@server:/opt/guyub/

# Run with systemd
sudo systemctl start guyub
```

#### Frontend
```bash
# Build static files
npm run build

# Copy to server
scp -r dist/* user@server:/var/www/guyub/
```

---

## Contributing

### Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: fix bug
refactor: refactor code
docs: update documentation
test: add tests
chore: maintenance
```

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests are included
- [ ] Documentation is updated
- [ ] No sensitive data exposed
- [ ] Error handling is proper
- [ ] Migrations are reversible

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/PANDUAN.md](./docs/PANDUAN.md) | Comprehensive development guide (Bahasa Indonesia) |
| [database/](./database/) | Database schema and seed files for quick setup |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [Gin Web Framework](https://gin-gonic.com/)
- [GORM](https://gorm.io/)
- [React](https://reactjs.org/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Heroicons](https://heroicons.com/)

---

**Made with care for KANO**
#   g u y u b - t e s t i n g - r e m o n  
 