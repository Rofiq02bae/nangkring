#!/bin/bash

# 📊 System Monitoring Script
# Script untuk monitoring kesehatan sistem dan aplikasi

echo "📊 System Health Monitor"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check service health
check_service_health() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -e "${BLUE}🔍 Checking ${service_name}...${NC}"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$url" || echo "HTTPSTATUS:000")
    http_status=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    
    if [ "$http_status" = "$expected_status" ]; then
        echo -e "${GREEN}✅ ${service_name}: Healthy (${http_status})${NC}"
        return 0
    else
        echo -e "${RED}❌ ${service_name}: Unhealthy (${http_status})${NC}"
        return 1
    fi
}

# Function to check docker container status
check_docker_containers() {
    echo -e "\n${BLUE}🐳 Docker Container Status:${NC}"
    
    if command -v docker-compose &> /dev/null; then
        if [ -f "docker-compose.yml" ]; then
            docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}"
        else
            echo -e "${YELLOW}⚠️  docker-compose.yml not found${NC}"
        fi
    else
        echo -e "${RED}❌ docker-compose not installed${NC}"
    fi
}

# Function to check system resources
check_system_resources() {
    echo -e "\n${BLUE}💾 System Resources:${NC}"
    
    # Memory usage
    memory_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    echo -e "Memory Usage: ${memory_usage}%"
    
    # Disk usage
    disk_usage=$(df -h / | awk 'NR==2{printf "%s", $5}')
    echo -e "Disk Usage: ${disk_usage}"
    
    # CPU Load
    cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo -e "CPU Load (1min): ${cpu_load}"
    
    # Docker stats (if available)
    if command -v docker &> /dev/null; then
        echo -e "\n${BLUE}🐳 Docker Resource Usage:${NC}"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    fi
}

# Function to check database connectivity
check_database() {
    echo -e "\n${BLUE}🗄️  Database Connectivity:${NC}"
    
    if command -v docker &> /dev/null; then
        # Check if MySQL container is running
        mysql_container=$(docker ps --filter "name=mysql" --format "{{.Names}}" | head -1)
        
        if [ -n "$mysql_container" ]; then
            echo -e "${GREEN}✅ MySQL container: ${mysql_container}${NC}"
            
            # Test database connection
            if docker exec "$mysql_container" mysqladmin ping -h localhost --silent; then
                echo -e "${GREEN}✅ Database: Connection successful${NC}"
            else
                echo -e "${RED}❌ Database: Connection failed${NC}"
            fi
        else
            echo -e "${RED}❌ MySQL container: Not found${NC}"
        fi
    fi
}

# Function to check application logs
check_application_logs() {
    echo -e "\n${BLUE}📜 Recent Application Logs:${NC}"
    
    # Laravel logs
    if [ -f "storage/logs/laravel.log" ]; then
        echo -e "${YELLOW}🔍 Laravel Errors (last 5):${NC}"
        tail -n 20 storage/logs/laravel.log | grep -i error | tail -5 || echo "No recent errors found"
    fi
    
    # Docker logs
    if command -v docker-compose &> /dev/null && [ -f "docker-compose.yml" ]; then
        echo -e "\n${YELLOW}🐳 Docker Container Logs (last 10 lines):${NC}"
        app_container=$(docker-compose ps --services | grep app | head -1)
        if [ -n "$app_container" ]; then
            docker-compose logs --tail=10 "$app_container"
        fi
    fi
}

# Main monitoring function
main() {
    echo -e "${GREEN}🚀 Starting Health Check...${NC}"
    echo -e "Timestamp: $(date)"
    
    # Change to laravel-jenkins-app directory if it exists
    if [ -d "laravel-jenkins-app" ]; then
        cd laravel-jenkins-app
    fi
    
    # Service health checks
    echo -e "\n${BLUE}🌐 Service Health Checks:${NC}"
    
    total_checks=0
    passed_checks=0
    
    # Laravel app
    if check_service_health "Laravel App" "http://localhost:8000"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # Jenkins
    if check_service_health "Jenkins" "http://localhost:8080/login"; then
        ((passed_checks++))
    fi
    ((total_checks++))
    
    # MySQL (if accessible via HTTP - otherwise handled in check_database)
    check_database
    
    # Docker containers
    check_docker_containers
    
    # System resources
    check_system_resources
    
    # Application logs
    check_application_logs
    
    # Summary
    echo -e "\n${GREEN}📋 Health Check Summary:${NC}"
    echo -e "Services Checked: ${total_checks}"
    echo -e "Services Healthy: ${passed_checks}"
    echo -e "Success Rate: $((passed_checks * 100 / total_checks))%"
    
    if [ $passed_checks -eq $total_checks ]; then
        echo -e "${GREEN}🎉 All services are healthy!${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  Some services need attention${NC}"
        exit 1
    fi
}

# Run monitoring
main "$@"
