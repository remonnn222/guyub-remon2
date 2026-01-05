#!/bin/bash
#############################################
#  GUYUB PLATFORM - RESEED DATABASE
#  Run this if login returns 401 error
#############################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}Reseeding Guyub Database...${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q guyub-mysql; then
    echo -e "${RED}ERROR: guyub-mysql container is not running!${NC}"
    echo "Run ./setup.sh first"
    exit 1
fi

# Run seed SQL
docker exec -i guyub-mysql mysql -u root -prootsecret guyub < backend/migrations/002_seed_data.sql 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Seeder completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Login Credentials:${NC}"
    echo -e "  Email    : admin@guyub.id"
    echo -e "  Password : Admin@123"
    echo ""
else
    echo -e "${RED}Seeder failed!${NC}"
    echo "Try running: docker compose down -v && docker compose up -d --build"
    exit 1
fi
