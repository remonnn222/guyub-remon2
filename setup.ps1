<#
.SYNOPSIS
    Guyub Platform - Complete One-Click Setup for Windows
.DESCRIPTION
    This script handles EVERYTHING:
    - Checks Docker
    - Creates .env files from .env.example
    - Stops old containers
    - Builds and starts all services
    - Waits for services to be ready
    - Opens browser automatically
.NOTES
    For Interns & New Developers
    Just run: .\setup.ps1
#>

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  GUYUB PLATFORM - COMPLETE SETUP" -ForegroundColor Cyan
Write-Host "  Family Tree & Genealogy Platform" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# STEP 1: Check Docker
# ============================================
Write-Host "[1/6] Checking Docker..." -ForegroundColor Yellow

$dockerVersion = docker --version 2>$null
if (-not $dockerVersion) {
    Write-Host ""
    Write-Host "ERROR: Docker is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

$dockerRunning = docker info 2>$null
if (-not $dockerRunning) {
    Write-Host ""
    Write-Host "ERROR: Docker is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "  Docker OK" -ForegroundColor Green

# ============================================
# STEP 2: Create .env files
# ============================================
Write-Host "[2/6] Setting up environment files..." -ForegroundColor Yellow

# Root .env (for docker-compose)
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "  Created .env from .env.example" -ForegroundColor Green
    } else {
        @"
# Database Configuration
DB_ROOT_PASSWORD=rootsecret
DB_DATABASE=guyub
DB_USERNAME=guyub
DB_PASSWORD=secret
DB_PORT=3306

# API Configuration
API_PORT=8080
JWT_SECRET=guyub-super-secret-jwt-key-2024

# Frontend Configuration
FRONTEND_PORT=5173
"@ | Out-File -FilePath ".env" -Encoding ASCII
        Write-Host "  Created .env with defaults" -ForegroundColor Green
    }
} else {
    Write-Host "  .env already exists" -ForegroundColor Green
}

# Backend .env
if (-not (Test-Path "backend/.env")) {
    if (Test-Path "backend/.env.example") {
        Copy-Item "backend/.env.example" "backend/.env"
        Write-Host "  Created backend/.env" -ForegroundColor Green
    }
} else {
    Write-Host "  backend/.env already exists" -ForegroundColor Green
}

# Admin/Frontend .env
if (-not (Test-Path "admin/.env")) {
    if (Test-Path "admin/.env.example") {
        Copy-Item "admin/.env.example" "admin/.env"
        Write-Host "  Created admin/.env" -ForegroundColor Green
    }
} else {
    Write-Host "  admin/.env already exists" -ForegroundColor Green
}

# ============================================
# STEP 3: Stop old containers
# ============================================
Write-Host "[3/6] Stopping old containers..." -ForegroundColor Yellow
docker compose down -v 2>$null | Out-Null
Write-Host "  Done" -ForegroundColor Green

# ============================================
# STEP 4: Build and start containers
# ============================================
Write-Host "[4/6] Building and starting containers..." -ForegroundColor Yellow
Write-Host "  This may take 2-5 minutes on first run..." -ForegroundColor Gray
Write-Host ""

docker compose up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Docker compose failed!" -ForegroundColor Red
    Write-Host "Check the error messages above." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "  Containers started" -ForegroundColor Green

# ============================================
# STEP 5: Wait for services
# ============================================
Write-Host "[5/6] Waiting for services to be ready..." -ForegroundColor Yellow

# Wait for MySQL (max 60 seconds)
Write-Host "  Waiting for MySQL..." -NoNewline
$mysqlReady = $false
for ($i = 0; $i -lt 30; $i++) {
    $result = docker exec guyub-mysql mysqladmin ping -h localhost -u root -prootsecret 2>$null
    if ($result -match "alive") {
        $mysqlReady = $true
        break
    }
    Start-Sleep -Seconds 2
    Write-Host "." -NoNewline
}
if ($mysqlReady) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " TIMEOUT (may still be starting)" -ForegroundColor Yellow
}

# Wait for Backend (max 60 seconds)
Write-Host "  Waiting for Backend..." -NoNewline
$backendReady = $false
for ($i = 0; $i -lt 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            break
        }
    } catch {}
    Start-Sleep -Seconds 2
    Write-Host "." -NoNewline
}
if ($backendReady) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " TIMEOUT (may still be starting)" -ForegroundColor Yellow
}

# Wait for Frontend (max 40 seconds)
Write-Host "  Waiting for Frontend..." -NoNewline
$frontendReady = $false
for ($i = 0; $i -lt 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5173" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $frontendReady = $true
            break
        }
    } catch {}
    Start-Sleep -Seconds 2
    Write-Host "." -NoNewline
}
if ($frontendReady) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " TIMEOUT (may still be starting)" -ForegroundColor Yellow
}

# ============================================
# STEP 5b: Check if seeder ran (users exist)
# ============================================
Write-Host "[5b/6] Verifying database seeder..." -ForegroundColor Yellow

$userCount = docker exec guyub-mysql mysql -u root -prootsecret -N -e "SELECT COUNT(*) FROM guyub.users;" 2>$null
$userCount = $userCount -replace '\D', ''

if ([string]::IsNullOrEmpty($userCount) -or $userCount -eq "0") {
    Write-Host "  No users found, running seeder..." -ForegroundColor Yellow
    Get-Content "backend/migrations/002_seed_data.sql" | docker exec -i guyub-mysql mysql -u root -prootsecret guyub 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Seeder completed" -ForegroundColor Green
    } else {
        Write-Host "  Seeder may have issues - check manually if login fails" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Database already seeded ($userCount users found)" -ForegroundColor Green
}

# ============================================
# STEP 6: Done!
# ============================================
Write-Host "[6/6] Opening browser..." -ForegroundColor Yellow
Start-Process "http://localhost:5173"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  Landing Page : http://localhost:5173/" -ForegroundColor White
Write-Host "  Login Page   : http://localhost:5173/login" -ForegroundColor White
Write-Host "  Backend API  : http://localhost:8080/api/v1" -ForegroundColor White
Write-Host "  Health Check : http://localhost:8080/health" -ForegroundColor White
Write-Host ""
Write-Host "Login Credentials:" -ForegroundColor Cyan
Write-Host "  Email    : admin@guyub.id" -ForegroundColor White
Write-Host "  Password : Admin@123" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "  View logs : docker compose logs -f" -ForegroundColor Gray
Write-Host "  Stop      : docker compose down" -ForegroundColor Gray
Write-Host "  Restart   : docker compose restart" -ForegroundColor Gray
Write-Host "  Reset DB  : docker compose down -v && docker compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "Happy coding! " -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to close"
