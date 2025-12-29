#!/bin/bash

#############################################
#  GUYUB PLATFORM - ONE CLICK SETUP
#  For: Interns & New Developers
#############################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     GUYUB PLATFORM - SETUP SCRIPT          ║${NC}"
echo -e "${BLUE}║     Family Tree & Genealogy Platform       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check Docker
echo -e "${YELLOW}[1/5] Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found!${NC}"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Step 2: Check Docker Compose
echo -e "${YELLOW}[2/5] Checking Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose is available${NC}"

# Step 3: Create .env file if not exists
echo -e "${YELLOW}[3/5] Setting up environment...${NC}"
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
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
EOF
    echo -e "${GREEN}✓ Created .env file${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Step 4: Stop existing containers and clean up
echo -e "${YELLOW}[4/5] Starting services (this may take a few minutes on first run)...${NC}"
echo "   Cleaning up old containers..."
docker-compose down -v 2>/dev/null || docker compose down -v 2>/dev/null || true

echo "   Building and starting containers..."
docker-compose up -d --build 2>/dev/null || docker compose up -d --build

# Step 5: Wait for services
echo -e "${YELLOW}[5/5] Waiting for services to be ready...${NC}"

# Wait for MySQL
echo -n "   Waiting for MySQL"
for i in {1..30}; do
    if docker exec guyub-mysql mysqladmin ping -h localhost -u root -prootsecret &> /dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Wait for Backend
echo -n "   Waiting for Backend API"
for i in {1..30}; do
    if curl -s http://localhost:8080/health &> /dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Wait for Frontend
echo -n "   Waiting for Frontend"
for i in {1..20}; do
    if curl -s http://localhost:5173 &> /dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Done!
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         SETUP COMPLETE! 🎉                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📱 Application URLs:${NC}"
echo "   Landing Page  : http://localhost:5173/"
echo "   Login Page    : http://localhost:5173/login"
echo "   Backend API   : http://localhost:8080/api/v1"
echo ""
echo -e "${BLUE}🔐 Login Credentials:${NC}"
echo "   Email    : admin@guyub.id"
echo "   Password : Admin@123"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo "   View logs     : docker-compose logs -f"
echo "   Stop all      : docker-compose down"
echo "   Restart       : docker-compose restart"
echo "   Reset DB      : docker-compose down -v && docker-compose up -d"
echo ""
echo -e "${YELLOW}Happy coding! 🚀${NC}"
echo ""
