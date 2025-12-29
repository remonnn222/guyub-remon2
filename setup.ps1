#############################################
#  GUYUB PLATFORM - ONE CLICK SETUP
#  For: Interns & New Developers (PowerShell)
#############################################

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     GUYUB PLATFORM - SETUP SCRIPT          ║" -ForegroundColor Cyan
Write-Host "║     Family Tree & Genealogy Platform       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Docker
Write-Host "[1/5] Checking Docker..." -ForegroundColor Yellow
try {
    $null = docker --version
    $null = docker info 2>$null
    Write-Host "[OK] Docker is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker not found or not running!" -ForegroundColor Red
    Write-Host "Please install/start Docker Desktop from: https://www.docker.com/products/docker-desktop"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Check Docker Compose
Write-Host "[2/5] Checking Docker Compose..." -ForegroundColor Yellow
try {
    $null = docker compose version 2>$null
    Write-Host "[OK] Docker Compose is available" -ForegroundColor Green
} catch {
    try {
        $null = docker-compose --version
        Write-Host "[OK] Docker Compose is available" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Docker Compose not found!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Step 3: Create .env file
Write-Host "[3/5] Setting up environment..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    @"
# Database
DB_ROOT_PASSWORD=rootsecret
DB_DATABASE=guyub
DB_USERNAME=guyub
DB_PASSWORD=secret
DB_PORT=3306

# API
API_PORT=8080
JWT_SECRET=guyub-super-secret-jwt-key-2024

# Frontend
FRONTEND_PORT=5173
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "[OK] Created .env file" -ForegroundColor Green
} else {
    Write-Host "[OK] .env file already exists" -ForegroundColor Green
}

# Step 4: Start containers
Write-Host "[4/5] Starting services (this may take a few minutes on first run)..." -ForegroundColor Yellow
Write-Host "    Cleaning up old containers..."
docker compose down -v 2>$null
docker-compose down -v 2>$null

Write-Host "    Building and starting containers..."
try {
    docker compose up -d --build
} catch {
    docker-compose up -d --build
}

# Step 5: Wait for services
Write-Host "[5/5] Waiting for services to be ready..." -ForegroundColor Yellow

# Wait for MySQL
Write-Host "    Waiting for MySQL..." -NoNewline
for ($i = 0; $i -lt 30; $i++) {
    try {
        $result = docker exec guyub-mysql mysqladmin ping -h localhost -u root -prootsecret 2>$null
        if ($result -match "alive") {
            Write-Host " [OK]" -ForegroundColor Green
            break
        }
    } catch {}
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
}

# Wait for Backend
Write-Host "    Waiting for Backend API..." -NoNewline
for ($i = 0; $i -lt 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host " [OK]" -ForegroundColor Green
            break
        }
    } catch {}
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
}

# Wait for Frontend
Write-Host "    Waiting for Frontend..." -NoNewline
for ($i = 0; $i -lt 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5173" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host " [OK]" -ForegroundColor Green
            break
        }
    } catch {}
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
}

# Done!
Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         SETUP COMPLETE!                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Cyan
Write-Host "   Landing Page  : " -NoNewline; Write-Host "http://localhost:5173/" -ForegroundColor White
Write-Host "   Login Page    : " -NoNewline; Write-Host "http://localhost:5173/login" -ForegroundColor White
Write-Host "   Backend API   : " -NoNewline; Write-Host "http://localhost:8080/api/v1" -ForegroundColor White
Write-Host ""
Write-Host "Login Credentials:" -ForegroundColor Cyan
Write-Host "   Email    : " -NoNewline; Write-Host "admin@guyub.id" -ForegroundColor White
Write-Host "   Password : " -NoNewline; Write-Host "Admin@123" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "   View logs     : docker compose logs -f"
Write-Host "   Stop all      : docker compose down"
Write-Host "   Restart       : docker compose restart"
Write-Host "   Reset DB      : docker compose down -v; docker compose up -d"
Write-Host ""
Write-Host "Happy coding!" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
