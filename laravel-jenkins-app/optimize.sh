#!/bin/bash

# 🔧 Performance Optimization Script
# Script untuk mengoptimalkan performa Laravel dalam production

echo "🚀 Starting Laravel Performance Optimization..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the Laravel directory
if [ ! -f "artisan" ]; then
    echo -e "${RED}❌ Not in Laravel directory. Please run from Laravel root.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Laravel directory detected${NC}"

# Clear all caches first
echo -e "${YELLOW}🧹 Clearing existing caches...${NC}"
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan event:clear

# Generate optimized caches
echo -e "${YELLOW}⚡ Generating optimized caches...${NC}"

# Config cache
echo -e "${BLUE}📝 Caching configuration...${NC}"
php artisan config:cache

# Route cache
echo -e "${BLUE}🛣️  Caching routes...${NC}"
php artisan route:cache

# View cache
echo -e "${BLUE}👁️  Caching views...${NC}"
php artisan view:cache

# Event cache
echo -e "${BLUE}🎯 Caching events...${NC}"
php artisan event:cache

# Optimize autoloader
echo -e "${BLUE}🔧 Optimizing autoloader...${NC}"
composer install --optimize-autoloader --no-dev

# Generate optimized class map
echo -e "${BLUE}📚 Optimizing class map...${NC}"
php artisan optimize

# Storage link
echo -e "${BLUE}🔗 Creating storage link...${NC}"
php artisan storage:link

# Database optimizations
echo -e "${BLUE}🗄️  Running database optimizations...${NC}"
php artisan migrate --force

# Queue optimization
echo -e "${BLUE}⚡ Optimizing queue...${NC}"
php artisan queue:restart

# Check Laravel version and optimizations
echo -e "\n${GREEN}📊 Optimization Summary:${NC}"
echo -e "Laravel Version: $(php artisan --version)"
echo -e "PHP Version: $(php -v | head -n 1)"

# Check cache status
echo -e "\n${YELLOW}📈 Cache Status:${NC}"
echo -e "Config Cache: $([ -f bootstrap/cache/config.php ] && echo '✅ Cached' || echo '❌ Not cached')"
echo -e "Route Cache: $([ -f bootstrap/cache/routes-v7.php ] && echo '✅ Cached' || echo '❌ Not cached')"
echo -e "View Cache: $([ -d storage/framework/views ] && [ "$(ls -A storage/framework/views)" ] && echo '✅ Cached' || echo '❌ Not cached')"

# File permissions
echo -e "\n${BLUE}🔐 Setting file permissions...${NC}"
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# OPcache recommendations
echo -e "\n${YELLOW}💡 OPcache Recommendations:${NC}"
echo -e "Add to your php.ini or docker php config:"
echo -e "opcache.enable=1"
echo -e "opcache.memory_consumption=128"
echo -e "opcache.max_accelerated_files=4000"
echo -e "opcache.revalidate_freq=2"
echo -e "opcache.fast_shutdown=1"

# Performance tips
echo -e "\n${BLUE}🎯 Additional Performance Tips:${NC}"
echo -e "1. Use Redis/Memcached for session and cache storage"
echo -e "2. Configure queue workers for background jobs"
echo -e "3. Use CDN for static assets"
echo -e "4. Enable gzip compression in web server"
echo -e "5. Use database indexing for frequently queried columns"

echo -e "\n${GREEN}✅ Performance optimization completed!${NC}"
echo -e "${YELLOW}💡 Run this script after each deployment for optimal performance.${NC}"
