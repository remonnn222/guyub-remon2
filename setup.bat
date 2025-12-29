@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM #############################################
REM   GUYUB PLATFORM - ONE CLICK SETUP (Windows)
REM   For: Interns & New Developers
REM #############################################

echo.
echo ╔════════════════════════════════════════════╗
echo ║     GUYUB PLATFORM - SETUP SCRIPT          ║
echo ║     Family Tree ^& Genealogy Platform       ║
echo ╚════════════════════════════════════════════╝
echo.

REM Step 1: Check Docker
echo [1/5] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker not found!
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo [OK] Docker is running

REM Step 2: Check Docker Compose
echo [2/5] Checking Docker Compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Docker Compose not found!
        pause
        exit /b 1
    )
)
echo [OK] Docker Compose is available

REM Step 3: Create .env file
echo [3/5] Setting up environment...
if not exist ".env" (
    (
        echo # Database
        echo DB_ROOT_PASSWORD=rootsecret
        echo DB_DATABASE=guyub
        echo DB_USERNAME=guyub
        echo DB_PASSWORD=secret
        echo DB_PORT=3306
        echo.
        echo # API
        echo API_PORT=8080
        echo JWT_SECRET=guyub-super-secret-jwt-key-2024
        echo.
        echo # Frontend
        echo FRONTEND_PORT=5173
    ) > .env
    echo [OK] Created .env file
) else (
    echo [OK] .env file already exists
)

REM Step 4: Start containers
echo [4/5] Starting services (this may take a few minutes on first run)...
echo     Cleaning up old containers...
docker-compose down -v 2>nul
docker compose down -v 2>nul

echo     Building and starting containers...
docker-compose up -d --build 2>nul || docker compose up -d --build

REM Step 5: Wait for services
echo [5/5] Waiting for services to be ready...

echo     Waiting for MySQL...
set /a count=0
:wait_mysql
set /a count+=1
if %count% gtr 30 goto mysql_timeout
docker exec guyub-mysql mysqladmin ping -h localhost -u root -prootsecret >nul 2>&1
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto wait_mysql
)
echo     [OK] MySQL is ready
goto wait_backend

:mysql_timeout
echo     [WARN] MySQL took too long, continuing...

:wait_backend
echo     Waiting for Backend API...
set /a count=0
:wait_api
set /a count+=1
if %count% gtr 30 goto api_timeout
curl -s http://localhost:8080/health >nul 2>&1
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto wait_api
)
echo     [OK] Backend is ready
goto wait_frontend

:api_timeout
echo     [WARN] Backend took too long, continuing...

:wait_frontend
echo     Waiting for Frontend...
set /a count=0
:wait_fe
set /a count+=1
if %count% gtr 20 goto fe_timeout
curl -s http://localhost:5173 >nul 2>&1
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto wait_fe
)
echo     [OK] Frontend is ready
goto done

:fe_timeout
echo     [WARN] Frontend took too long, continuing...

:done
echo.
echo ╔════════════════════════════════════════════╗
echo ║         SETUP COMPLETE!                    ║
echo ╚════════════════════════════════════════════╝
echo.
echo Application URLs:
echo    Landing Page  : http://localhost:5173/
echo    Login Page    : http://localhost:5173/login
echo    Backend API   : http://localhost:8080/api/v1
echo.
echo Login Credentials:
echo    Email    : admin@guyub.id
echo    Password : Admin@123
echo.
echo Useful Commands:
echo    View logs     : docker-compose logs -f
echo    Stop all      : docker-compose down
echo    Restart       : docker-compose restart
echo    Reset DB      : docker-compose down -v ^&^& docker-compose up -d
echo.
echo Happy coding!
echo.
pause
