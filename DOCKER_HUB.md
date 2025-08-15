# 🐳 Docker Hub Integration Guide

## Overview

Project ini menggunakan Docker Hub untuk menyimpan dan mendistribusikan Docker images secara otomatis melalui GitHub Actions.

## 📦 Docker Hub Repository

**Image**: `rofiq02bae/laravel-vite-app:latest`
**URL**: https://hub.docker.com/r/rofiq02bae/laravel-vite-app

## 🔄 Automated Build Process

### GitHub Actions Workflow

File: `.github/workflows/docker-build.yml`

**Triggers:**
- Push ke branch `main`
- Pull Request ke branch `main`
- Manual trigger via workflow_dispatch

**Jobs:**
1. **build-and-push**: Build dan push image ke Docker Hub
2. **security-scan**: Scan vulnerabilities dengan Trivy
3. **deploy**: Deploy notification dan verification

### Image Tags

- `latest` - Latest stable version dari main branch
- `main-<sha>` - Specific commit dari main branch
- `pr-<number>` - Pull request builds

## 🚀 Deployment Options

### Option 1: Docker Hub Image (Recommended)
```bash
# Pull dan jalankan dari Docker Hub
./deploy.sh
```

### Option 2: Local Build
```bash
# Edit docker-compose.yml untuk uncomment build section
# Comment image line
docker-compose up -d --build
```

## ⚙️ Setup Requirements

### GitHub Secrets

Untuk GitHub Actions berjalan, pastikan secrets berikut sudah dikonfigurasi:

1. **DOCKER_HUB_TOKEN**
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Add new secret: `DOCKER_HUB_TOKEN`
   - Value: Docker Hub Access Token

### Docker Hub Access Token

1. Login ke Docker Hub
2. Go to Account Settings → Security → Access Tokens
3. Generate new token dengan scope: **Read, Write, Delete**
4. Copy token ke GitHub secrets

## 🔧 Configuration Files

### docker-compose.yml
```yaml
services:
  app:
    # Use pre-built image from Docker Hub:
    image: rofiq02bae/laravel-vite-app:latest
    # Uncomment for local build:
    # build:
    #   context: .
    #   dockerfile: Dockerfile
```

### Jenkinsfile
Pipeline menggunakan image dari Docker Hub untuk deployment:
```groovy
sh "docker pull rofiq02bae/laravel-vite-app:latest"
```

## 📊 Image Information

### Built-in Components
- **Base**: PHP 8.2-FPM
- **Node.js**: 20.x LTS
- **Composer**: Latest
- **Extensions**: pdo_mysql, mbstring, bcmath, gd, intl, curl, zip

### Size Optimization
- Multi-stage build untuk size optimization
- Production dependencies only
- Layer caching untuk build speed

## 🛠️ Development Workflow

### Local Development
```bash
# Use local build for development
git checkout main
docker-compose up -d --build
```

### Production Deployment
```bash
# Use Docker Hub image for production
./deploy.sh
```

### CI/CD Pipeline
1. Developer push ke GitHub
2. GitHub Actions build & push ke Docker Hub
3. Jenkins pull image terbaru
4. Deploy ke production environment

## 🔍 Monitoring & Debugging

### Check Image Status
```bash
# Check local images
docker images | grep rofiq02bae/laravel-vite-app

# Pull specific tag
docker pull rofiq02bae/laravel-vite-app:main-abc1234

# Inspect image
docker inspect rofiq02bae/laravel-vite-app:latest
```

### Container Logs
```bash
# View application logs
docker-compose logs -f app

# Check container status
docker-compose ps
```

## 🔐 Security

### Image Scanning
- Trivy vulnerability scanner berjalan otomatis
- Results uploaded ke GitHub Security tab
- Critical vulnerabilities akan fail the build

### Best Practices
- Regular base image updates
- Minimal attack surface
- Non-root user dalam container
- Secrets management via environment variables

## 🚨 Troubleshooting

### Build Failures
```bash
# Check GitHub Actions logs
# Go to GitHub repo → Actions → Failed workflow

# Retry failed builds
# Re-run workflow in GitHub Actions
```

### Image Pull Failures
```bash
# Fallback to local build
sed -i 's|image: rofiq02bae/laravel-vite-app:latest|# image: rofiq02bae/laravel-vite-app:latest|g' docker-compose.yml
sed -i 's|# build:|build:|g' docker-compose.yml

# Build locally
docker-compose up -d --build
```

### Docker Hub Rate Limits
- Authenticate untuk higher rate limits
- Use Docker Hub Pro untuk unlimited pulls
- Implement retry logic dalam scripts

---

📚 **Documentation Links:**
- [Docker Hub Repository](https://hub.docker.com/r/rofiq02bae/laravel-vite-app)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
