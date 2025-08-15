#!/bin/bash

# 🚀 Jenkins CI/CD Quick Setup Script
# Script untuk mempermudah setup Jenkins pipeline

echo "🔧 Starting Jenkins CI/CD Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No service "app" refers to undefined network app-network: invalid compose project

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Containers not running. Starting containers...${NC}"
    docker-compose up -d
    echo -e "${GREEN}✅ Containers started${NC}"
else
    echo -e "${GREEN}✅ Containers are already running${NC}"
fi

# Get Jenkins initial password
echo -e "${YELLOW}🔑 Getting Jenkins initial admin password...${NC}"
JENKINS_PASSWORD=$(docker exec laravel-jenkins-app-jenkins-1 cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)

if [ -n "$JENKINS_PASSWORD" ]; then
    echo -e "${GREEN}✅ Jenkins Initial Admin Password: ${JENKINS_PASSWORD}${NC}"
else
    echo -e "${RED}❌ Could not retrieve Jenkins password. Container might not be ready yet.${NC}"
    echo -e "${YELLOW}⏳ Waiting for Jenkins to start...${NC}"
    sleep 30
    JENKINS_PASSWORD=$(docker exec laravel-jenkins-app-jenkins-1 cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    if [ -n "$JENKINS_PASSWORD" ]; then
        echo -e "${GREEN}✅ Jenkins Initial Admin Password: ${JENKINS_PASSWORD}${NC}"
    else
        echo -e "${RED}❌ Jenkins might not be fully started yet. Please try again in a few minutes.${NC}"
    fi
fi

# Show service status
echo -e "\n${YELLOW}📊 Service Status:${NC}"
docker-compose ps

echo -e "\n${GREEN}🎉 Setup Information:${NC}"
echo -e "🌐 Jenkins URL: http://localhost:8080"
echo -e "🚀 Laravel App: http://localhost:8000"
echo -e "🗄️  MySQL Database: localhost:3306"
echo -e "🔑 Jenkins Password: ${JENKINS_PASSWORD}"

echo -e "\n${YELLOW}📋 Next Steps:${NC}"
echo "1. Open Jenkins at http://localhost:8080"
echo "2. Use password: ${JENKINS_PASSWORD}"
echo "3. Install suggested plugins"
echo "4. Follow steps in JENKINS_SETUP.md"

echo -e "\n${GREEN}✅ Quick setup completed!${NC}"
