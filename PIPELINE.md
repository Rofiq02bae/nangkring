# 🚀 Jenkins CI/CD Pipeline Documentation

## Pipeline Overview
Automated CI/CD pipeline untuk Laravel 12 + Vite dengan 5 stages utama.

## Pipeline Stages

### 1. Checkout
- Clone repository dari GitHub
- Branch: main
- Menggunakan credentials GitHub

### 2. Dependencies (Parallel)
- Composer install (PHP dependencies)
- NPM install (Node.js dependencies)
- Optimized untuk production

### 3. Build
- Compile Vite assets
- Generate production-ready files

### 4. Migrate
- Run database migrations
- Ensure database schema is up-to-date

### 5. Deploy
- Restart Laravel container
- Health check verification
- Automatic rollback on failure

## Trigger Events
- Push to main branch
- Manual trigger
- GitHub webhook (optional)

## Environment Variables
- APP_DIR: laravel-jenkins-app/src
- COMPOSE_FILE: laravel-jenkins-app/docker-compose.yml

## Success Criteria
- All stages pass
- Health check returns 200
- Application accessible on port 8000
