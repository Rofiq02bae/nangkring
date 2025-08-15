#!/bin/bash

# 🐳 Docker Hub Deployment Script
# Script untuk pull dan deploy image dari Docker Hub

echo "🚀 Deploying Laravel app from Docker Hub..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOCKER_HUB_USERNAME="rofiq02bae"
IMAGE_NAME="laravel-vite-app"
IMAGE_TAG="latest"
FULL_IMAGE="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${BLUE}📦 Docker Hub Image: ${FULL_IMAGE}${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose down

# Pull latest image from Docker Hub
echo -e "${YELLOW}📥 Pulling latest image from Docker Hub...${NC}"
docker pull $FULL_IMAGE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Successfully pulled ${FULL_IMAGE}${NC}"
else
    echo -e "${RED}❌ Failed to pull image from Docker Hub${NC}"
    echo -e "${YELLOW}💡 Falling back to local build...${NC}"
    
    # Uncomment build section in docker-compose.yml
    sed -i 's|# build:|build:|g' docker-compose.yml
    sed -i 's|# context: .|context: .|g' docker-compose.yml
    sed -i 's|# dockerfile: Dockerfile|dockerfile: Dockerfile|g' docker-compose.yml
    
    # Comment out image line
    sed -i 's|image: rofiq02bae/laravel-vite-app:latest|# image: rofiq02bae/laravel-vite-app:latest|g' docker-compose.yml
fi

# Start services
echo -e "${YELLOW}🚀 Starting services...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 15

# Check service status
echo -e "${YELLOW}📊 Checking service status...${NC}"
docker-compose ps

# Test Laravel app
echo -e "${YELLOW}🔍 Testing Laravel app...${NC}"
if curl -f http://localhost:8000 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Laravel app is running successfully!${NC}"
else
    echo -e "${RED}❌ Laravel app is not responding${NC}"
fi

# Show deployment info
echo -e "\n${GREEN}🎉 Deployment Information:${NC}"
echo -e "🌐 Laravel App: http://localhost:8000"
echo -e "🐳 Docker Image: ${FULL_IMAGE}"
echo -e "📊 Container Status:"
docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}"

# Show useful commands
echo -e "\n${BLUE}📋 Useful Commands:${NC}"
echo -e "📜 View logs: docker-compose logs -f app"
echo -e "🔧 Access container: docker-compose exec app bash"
echo -e "🛑 Stop services: docker-compose down"
echo -e "🔄 Restart services: docker-compose restart"

echo -e "\n${GREEN}✅ Deployment completed!${NC}"
