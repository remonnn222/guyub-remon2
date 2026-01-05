#!/bin/bash

#############################################
#  GUYUB PLATFORM - COMPLETE ONE-CLICK SETUP
#  For: Interns & New Developers
#
#  This script handles EVERYTHING:
#  - Checks Docker
#  - Creates .env files from .env.example
#  - Stops old containers
#  - Builds and starts all services
#  - Waits for services to be ready
#  - Opens browser automatically
#############################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}  GUYUB PLATFORM - COMPLETE SETUP${NC}"
echo -e "${CYAN}  Family Tree & Genealogy Platform${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# ============================================
# STEP 1: Check Docker
# ============================================
echo -e "${YELLOW}[1/6] Checking Docker...${NC}"

if ! command -v docker &> /dev/null; then
    echo ""
    echo -e "${RED}ERROR: Docker is not installed!${NC}"
    echo ""
    echo -e "${YELLOW}Please install Docker Desktop:${NC}"
    echo "https://www.docker.com/products/docker-desktop"
    echo ""
    exit 1
fi

if ! docker info &> /dev/null; then
    echo ""
    echo -e "${RED}ERROR: Docker is not running!${NC}"
    echo ""
    echo -e "${YELLOW}Please start Docker Desktop and try again.${NC}"
    echo ""
    exit 1
fi

echo -e "  ${GREEN}Docker OK${NC}"

# ============================================
# STEP 2: Create .env files
# ============================================
echo -e "${YELLOW}[2/6] Setting up environment files...${NC}"

# Root .env (for docker-compose)
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "  ${GREEN}Created .env from .env.example${NC}"
    else
        cat > .env << 'EOF'
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
EOF
        echo -e "  ${GREEN}Created .env with defaults${NC}"
    fi
else
    echo -e "  ${GREEN}.env already exists${NC}"
fi

# Backend .env
if [ ! -f "backend/.env" ]; then
    if [ -f "backend/.env.example" ]; then
        cp backend/.env.example backend/.env
        echo -e "  ${GREEN}Created backend/.env${NC}"
    fi
else
    echo -e "  ${GREEN}backend/.env already exists${NC}"
fi

# Admin/Frontend .env
if [ ! -f "admin/.env" ]; then
    if [ -f "admin/.env.example" ]; then
        cp admin/.env.example admin/.env
        echo -e "  ${GREEN}Created admin/.env${NC}"
    fi
else
    echo -e "  ${GREEN}admin/.env already exists${NC}"
fi

# ============================================
# STEP 3: Stop old containers
# ============================================
echo -e "${YELLOW}[3/6] Stopping old containers...${NC}"
docker compose down -v 2>/dev/null || docker-compose down -v 2>/dev/null || true
echo -e "  ${GREEN}Done${NC}"

# ============================================
# STEP 4: Build and start containers
# ============================================
echo -e "${YELLOW}[4/6] Building and starting containers...${NC}"
echo -e "  ${GRAY}This may take 2-5 minutes on first run...${NC}"
echo ""

docker compose up -d --build 2>/dev/null || docker-compose up -d --build

echo ""
echo -e "  ${GREEN}Containers started${NC}"

# ============================================
# STEP 5: Wait for services
# ============================================
echo -e "${YELLOW}[5/6] Waiting for services to be ready...${NC}"

# Wait for MySQL
echo -n "  Waiting for MySQL"
for i in {1..30}; do
    if docker exec guyub-mysql mysqladmin ping -h localhost -u root -prootsecret &> /dev/null; then
        echo -e " ${GREEN}OK${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Wait for Backend
echo -n "  Waiting for Backend"
for i in {1..30}; do
    if curl -s http://localhost:8080/health &> /dev/null; then
        echo -e " ${GREEN}OK${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Wait for Frontend
echo -n "  Waiting for Frontend"
for i in {1..20}; do
    if curl -s http://localhost:5173 &> /dev/null; then
        echo -e " ${GREEN}OK${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# ============================================
# STEP 5b: Check if seeder ran (users exist)
# ============================================
echo -e "${YELLOW}[5b/6] Verifying database seeder...${NC}"
USER_COUNT=$(docker exec guyub-mysql mysql -u root -prootsecret -N -e "SELECT COUNT(*) FROM guyub.users;" 2>/dev/null || echo "0")

if [ "$USER_COUNT" = "0" ] || [ -z "$USER_COUNT" ]; then
    echo -e "  ${YELLOW}No users found, running seeder...${NC}"
    docker exec -i guyub-mysql mysql -u root -prootsecret guyub < backend/migrations/002_seed_data.sql 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}Seeder completed${NC}"
    else
        echo -e "  ${RED}Seeder failed - you may need to run manually${NC}"
    fi
else
    echo -e "  ${GREEN}Database already seeded ($USER_COUNT users found)${NC}"
fi

# ============================================
# STEP 6: Done!
# ============================================
echo -e "${YELLOW}[6/6] Opening browser...${NC}"

# Open browser (cross-platform)
if command -v open &> /dev/null; then
    open http://localhost:5173
elif command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:5173
elif command -v start &> /dev/null; then
    start http://localhost:5173
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  SETUP COMPLETE!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}URLs:${NC}"
echo -e "  Landing Page : ${WHITE}http://localhost:5173/${NC}"
echo -e "  Login Page   : ${WHITE}http://localhost:5173/login${NC}"
echo -e "  Backend API  : ${WHITE}http://localhost:8080/api/v1${NC}"
echo -e "  Health Check : ${WHITE}http://localhost:8080/health${NC}"
echo ""
echo -e "${CYAN}Login Credentials:${NC}"
echo -e "  Email    : ${WHITE}admin@guyub.id${NC}"
echo -e "  Password : ${WHITE}Admin@123${NC}"
echo ""
echo -e "${CYAN}Useful Commands:${NC}"
echo -e "  ${GRAY}View logs : docker compose logs -f${NC}"
echo -e "  ${GRAY}Stop      : docker compose down${NC}"
echo -e "  ${GRAY}Restart   : docker compose restart${NC}"
echo -e "  ${GRAY}Reset DB  : docker compose down -v && docker compose up -d${NC}"
echo ""
echo -e "${YELLOW}Happy coding!${NC}"
echo ""
