Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   GUYUB PLATFORM - SETUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking Docker..." -ForegroundColor Yellow
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker not installed!" -ForegroundColor Red
    pause
    exit
}

Write-Host ""
Write-Host "Stopping old containers..." -ForegroundColor Yellow
docker compose down -v 2>$null

Write-Host ""
Write-Host "Starting containers (please wait)..." -ForegroundColor Yellow
docker compose up -d --build

Write-Host ""
Write-Host "Waiting 30 seconds for services..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor Cyan
Write-Host "  http://localhost:5173/       (Landing Page)"
Write-Host "  http://localhost:5173/login  (Login)"
Write-Host "  http://localhost:8080/health (API Health)"
Write-Host ""
Write-Host "Login:" -ForegroundColor Cyan
Write-Host "  Email:    admin@guyub.id"
Write-Host "  Password: Admin@123"
Write-Host ""
pause
