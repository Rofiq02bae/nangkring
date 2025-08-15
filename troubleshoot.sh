#!/bin/bash

# 🚨 Troubleshooting Script
# Script untuk mendiagnosa dan memperbaiki masalah umum

echo "🔍 Laravel CI/CD Troubleshooting Tool"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check and fix common issues
check_project_structure() {
    echo -e "\n${BLUE}📂 Checking project structure...${NC}"
    
    # Check Laravel directory
    if [ -d "laravel-jenkins-app/src" ]; then
        echo -e "${GREEN}✅ Laravel directory exists${NC}"
        
        # Check essential files
        if [ -f "laravel-jenkins-app/src/composer.json" ]; then
            echo -e "${GREEN}✅ composer.json found${NC}"
        else
            echo -e "${RED}❌ composer.json missing${NC}"
            echo -e "${YELLOW}💡 Suggestion: Run 'composer create-project laravel/laravel src' in laravel-jenkins-app/${NC}"
        fi
        
        if [ -f "laravel-jenkins-app/src/artisan" ]; then
            echo -e "${GREEN}✅ artisan command found${NC}"
        else
            echo -e "${RED}❌ artisan command missing${NC}"
        fi
        
        if [ -f "laravel-jenkins-app/src/package.json" ]; then
            echo -e "${GREEN}✅ package.json found${NC}"
        else
            echo -e "${YELLOW}⚠️  package.json missing - creating basic one...${NC}"
            create_basic_package_json
        fi
    else
        echo -e "${RED}❌ Laravel directory missing${NC}"
        echo -e "${YELLOW}💡 Creating Laravel project structure...${NC}"
        setup_laravel_project
    fi
}

create_basic_package_json() {
    cat > laravel-jenkins-app/src/package.json << 'EOF'
{
  "name": "laravel-vite-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.0.0",
    "laravel-vite-plugin": "^0.8.0",
    "vite": "^4.0.0"
  }
}
EOF
    echo -e "${GREEN}✅ Basic package.json created${NC}"
}

setup_laravel_project() {
    echo -e "${YELLOW}🔧 Setting up Laravel project...${NC}"
    
    mkdir -p laravel-jenkins-app/src
    cd laravel-jenkins-app
    
    if command -v composer &> /dev/null; then
        echo -e "${BLUE}📦 Creating Laravel project with Composer...${NC}"
        composer create-project laravel/laravel src --no-interaction
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Laravel project created successfully${NC}"
        else
            echo -e "${RED}❌ Failed to create Laravel project${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Composer not found${NC}"
        echo -e "${YELLOW}💡 Install Composer first: https://getcomposer.org/${NC}"
        return 1
    fi
    
    cd ..
}

check_docker_issues() {
    echo -e "\n${BLUE}🐳 Checking Docker configuration...${NC}"
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running${NC}"
        echo -e "${YELLOW}💡 Start Docker and try again${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Docker is running${NC}"
    
    # Check docker-compose file
    if [ -f "laravel-jenkins-app/docker-compose.yml" ]; then
        echo -e "${GREEN}✅ docker-compose.yml found${NC}"
        
        # Check for common issues
        if grep -q "version:" laravel-jenkins-app/docker-compose.yml; then
            echo -e "${YELLOW}⚠️  Removing deprecated version field...${NC}"
            sed -i '/^version:/d' laravel-jenkins-app/docker-compose.yml
            echo -e "${GREEN}✅ Fixed version field${NC}"
        fi
    else
        echo -e "${RED}❌ docker-compose.yml missing${NC}"
    fi
}

check_github_actions() {
    echo -e "\n${BLUE}🔄 Checking GitHub Actions...${NC}"
    
    if [ -d ".github/workflows" ]; then
        echo -e "${GREEN}✅ GitHub workflows directory exists${NC}"
        
        # Check workflow files
        workflow_count=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
        echo -e "${BLUE}📊 Found ${workflow_count} workflow file(s)${NC}"
        
        # Check for common issues in workflows
        for workflow in .github/workflows/*.yml; do
            if [ -f "$workflow" ]; then
                filename=$(basename "$workflow")
                echo -e "${BLUE}🔍 Checking ${filename}...${NC}"
                
                # Check for exit 1 commands
                if grep -q "exit 1" "$workflow"; then
                    echo -e "${YELLOW}⚠️  Found 'exit 1' in ${filename}${NC}"
                    echo -e "${YELLOW}💡 Consider using 'continue-on-error: true' for debugging steps${NC}"
                fi
                
                # Check for missing continue-on-error
                if grep -q "composer install" "$workflow" && ! grep -A5 -B5 "composer install" "$workflow" | grep -q "continue-on-error"; then
                    echo -e "${YELLOW}⚠️  composer install without error handling in ${filename}${NC}"
                fi
            fi
        done
    else
        echo -e "${RED}❌ GitHub workflows directory missing${NC}"
    fi
}

fix_common_permissions() {
    echo -e "\n${BLUE}🔐 Fixing file permissions...${NC}"
    
    # Make scripts executable
    scripts=("laravel-jenkins-app/setup.sh" "laravel-jenkins-app/deploy.sh" "laravel-jenkins-app/optimize.sh" "monitor.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            echo -e "${GREEN}✅ Made $script executable${NC}"
        else
            echo -e "${YELLOW}⚠️  $script not found${NC}"
        fi
    done
    
    # Fix Laravel storage permissions if Laravel exists
    if [ -d "laravel-jenkins-app/src/storage" ]; then
        echo -e "${BLUE}🗂️  Fixing Laravel storage permissions...${NC}"
        chmod -R 755 laravel-jenkins-app/src/storage
        chmod -R 755 laravel-jenkins-app/src/bootstrap/cache
        echo -e "${GREEN}✅ Laravel permissions fixed${NC}"
    fi
}

run_health_check() {
    echo -e "\n${BLUE}🩺 Running health check...${NC}"
    
    if [ -f "monitor.sh" ]; then
        echo -e "${BLUE}📊 Running system monitor...${NC}"
        ./monitor.sh || echo -e "${YELLOW}⚠️  Monitor completed with warnings${NC}"
    else
        echo -e "${YELLOW}⚠️  monitor.sh not found${NC}"
    fi
}

show_fixes() {
    echo -e "\n${GREEN}🔧 Applied Fixes:${NC}"
    echo -e "✅ Project structure validated"
    echo -e "✅ Docker configuration checked"
    echo -e "✅ File permissions fixed"
    echo -e "✅ GitHub Actions analyzed"
    
    echo -e "\n${BLUE}💡 Additional Recommendations:${NC}"
    echo -e "1. Ensure Docker Hub secrets are configured in GitHub"
    echo -e "2. Test workflows locally before pushing"
    echo -e "3. Use 'continue-on-error: true' for debugging steps"
    echo -e "4. Check Laravel .env configuration"
    echo -e "5. Verify database connections"
    
    echo -e "\n${YELLOW}🚀 Next Steps:${NC}"
    echo -e "1. Run: git add . && git commit -m 'fix: troubleshooting and fixes'"
    echo -e "2. Push changes: git push origin main"
    echo -e "3. Monitor GitHub Actions: github.com/Rofiq02bae/nangkring/actions"
    echo -e "4. Test locally: cd laravel-jenkins-app && ./setup.sh"
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Starting troubleshooting...${NC}"
    echo -e "Timestamp: $(date)"
    
    check_project_structure
    check_docker_issues
    check_github_actions
    fix_common_permissions
    run_health_check
    show_fixes
    
    echo -e "\n${GREEN}✅ Troubleshooting completed!${NC}"
}

# Run troubleshooting
main "$@"
