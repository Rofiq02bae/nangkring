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
        # Check if MySQL container is running (look for db or mysql in name)
        mysql_container=$(docker ps --filter "status=running" --format "{{.Names}}" | grep -E "(mysql|db)" | head -1)
        
        if [ -n "$mysql_container" ]; then
            echo -e "${GREEN}✅ MySQL container: ${mysql_container} (running)${NC}"
            
            # Get MySQL version
            mysql_version=$(docker exec "$mysql_container" mysql --version 2>/dev/null | awk '{print $3}' | cut -d',' -f1)
            if [ -n "$mysql_version" ]; then
                echo -e "${BLUE}📋 MySQL version: ${mysql_version}${NC}"
            fi
            
            # Test database connection with mysqladmin
            if docker exec "$mysql_container" mysqladmin ping -h localhost --silent 2>/dev/null; then
                echo -e "${GREEN}✅ Database: Connection successful${NC}"
                
                # Check database status and variables
                uptime=$(docker exec "$mysql_container" mysql -e "SHOW STATUS LIKE 'Uptime';" 2>/dev/null | grep -v Variable | awk '{print $2}')
                if [ -n "$uptime" ]; then
                    uptime_hours=$((uptime / 3600))
                    echo -e "${BLUE}⏱️  MySQL uptime: ${uptime_hours} hours${NC}"
                fi
                
                # Check Laravel database connection
                env_file=".env"
                if [ -f "src/.env" ]; then
                    env_file="src/.env"
                fi
                
                if [ -f "$env_file" ]; then
                    db_name=$(grep "^DB_DATABASE=" "$env_file" | cut -d'=' -f2)
                    db_user=$(grep "^DB_USERNAME=" "$env_file" | cut -d'=' -f2)
                    db_pass=$(grep "^DB_PASSWORD=" "$env_file" | cut -d'=' -f2)
                    
                    if [ -n "$db_name" ]; then
                        echo -e "${BLUE}🗄️  Laravel database: ${db_name}${NC}"
                        
                        # Test Laravel database connectivity with credentials
                        if [ -n "$db_user" ] && [ -n "$db_pass" ]; then
                            table_count=$(docker exec "$mysql_container" mysql -u"$db_user" -p"$db_pass" -e "SELECT COUNT(*) as count FROM information_schema.tables WHERE table_schema='${db_name}';" 2>/dev/null | grep -v count | tail -1)
                            if [ -n "$table_count" ] && [ "$table_count" -gt 0 ]; then
                                echo -e "${GREEN}✅ Laravel DB: ${table_count} tables found${NC}"
                                
                                # Check specific Laravel tables
                                users_count=$(docker exec "$mysql_container" mysql -u"$db_user" -p"$db_pass" -e "SELECT COUNT(*) FROM ${db_name}.users;" 2>/dev/null | tail -1)
                                if [ -n "$users_count" ]; then
                                    echo -e "${BLUE}👥 Users table: ${users_count} records${NC}"
                                fi
                                
                                # Check migrations table
                                migrations_count=$(docker exec "$mysql_container" mysql -u"$db_user" -p"$db_pass" -e "SELECT COUNT(*) FROM ${db_name}.migrations;" 2>/dev/null | tail -1)
                                if [ -n "$migrations_count" ]; then
                                    echo -e "${BLUE}📦 Migrations run: ${migrations_count}${NC}"
                                fi
                            else
                                echo -e "${YELLOW}⚠️  Laravel DB: No tables found (run migrations?)${NC}"
                            fi
                        else
                            echo -e "${YELLOW}⚠️  Laravel DB: Missing credentials in .env${NC}"
                        fi
                    fi
                fi
                
                # Check MySQL processes
                processes=$(docker exec "$mysql_container" mysql -e "SHOW PROCESSLIST;" 2>/dev/null | wc -l)
                if [ -n "$processes" ] && [ "$processes" -gt 1 ]; then
                    echo -e "${BLUE}🔄 Active connections: $((processes - 1))${NC}"
                fi
                
            else
                echo -e "${RED}❌ Database: Connection failed${NC}"
                
                # Try to get error details
                error_log=$(docker logs "$mysql_container" --tail=5 2>/dev/null | grep -i error | tail -1)
                if [ -n "$error_log" ]; then
                    echo -e "${RED}🔍 Last error: ${error_log}${NC}"
                fi
            fi
            
            # Check MySQL container health
            health_status=$(docker inspect "$mysql_container" --format='{{.State.Health.Status}}' 2>/dev/null)
            if [ -n "$health_status" ]; then
                if [ "$health_status" = "healthy" ]; then
                    echo -e "${GREEN}💚 Container health: ${health_status}${NC}"
                else
                    echo -e "${YELLOW}⚠️  Container health: ${health_status}${NC}"
                fi
            fi
            
        else
            echo -e "${RED}❌ MySQL container: Not found or not running${NC}"
            
            # Check if MySQL container exists but stopped
            stopped_container=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | grep -E "(mysql|db)" | head -1)
            if [ -n "$stopped_container" ]; then
                echo -e "${YELLOW}⚠️  Found stopped MySQL container: ${stopped_container}${NC}"
                echo -e "${BLUE}💡 Run 'docker compose up -d' to start${NC}"
            fi
        fi
    else
        echo -e "${RED}❌ Docker not available${NC}"
    fi
}

# Function to check MySQL health (returns 0 for healthy, 1 for unhealthy)
check_mysql_health() {
    if command -v docker &> /dev/null; then
        # Check for MySQL container by name patterns
        mysql_container=$(docker ps --filter "status=running" --format "{{.Names}}" | grep -E "(mysql|db)" | head -1)
        
        if [ -n "$mysql_container" ]; then
            if docker exec "$mysql_container" mysqladmin ping -h localhost --silent 2>/dev/null; then
                return 0  # Healthy
            fi
        fi
    fi
    return 1  # Unhealthy
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
    
    # MySQL Database
    echo -e "${BLUE}🔍 Checking MySQL Database...${NC}"
    if check_mysql_health; then
        echo -e "${GREEN}✅ MySQL Database: Healthy${NC}"
        ((passed_checks++))
    else
        echo -e "${RED}❌ MySQL Database: Unhealthy${NC}"
    fi
    ((total_checks++))
    
    # Detailed database check
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
