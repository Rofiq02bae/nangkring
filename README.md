# 🚀 Laravel 12 + Vite + Jenkins CI/CD + Docker Hub

Enterprise-grade Laravel 12 application dengan Vite, Jenkins CI/CD, dan Docker Hub integration untuk development dan production environment.

## 🎯 Project Overview

Aplikasi Laravel 12 modern yang dilengkapi dengan:
- ⚡ **Vite** untuk fast asset bundling
- 🔄 **Jenkins CI/CD** untuk automated deployment
- 🐳 **Docker & Docker Hub** untuk containerization
- 📊 **Monitoring & Health Checks** 
- 🔐 **Production-ready Security**
- 📈 **Performance Optimization**

## 📁 Struktur Project

```
nangkring/
├── laravel-jenkins-app/          # Laravel application
│   ├── src/                      # Laravel 12 source code
│   ├── Dockerfile               # PHP 8.2 + Node.js 20
│   ├── docker-compose.yml       # Development services
│   ├── Jenkinsfile              # CI/CD pipeline
│   ├── setup.sh                 # Quick setup script
│   ├── deploy.sh                # Docker Hub deployment
│   ├── optimize.sh              # Performance optimization
│   └── JENKINS_SETUP.md         # Jenkins configuration
├── .github/workflows/           # GitHub Actions
│   ├── docker-build.yml         # Docker Hub automation
│   └── debug.yml                # CI/CD debugging
├── monitor.sh                   # System monitoring
├── PRODUCTION.md                # Production deployment guide
├── DOCKER_HUB.md               # Docker Hub integration
└── README.md                   # This file
```

## 🔧 Quick Start

### 1️⃣ Clone & Setup
```bash
git clone https://github.com/Rofiq02bae/nangkring.git
cd nangkring
chmod +x laravel-jenkins-app/setup.sh laravel-jenkins-app/deploy.sh laravel-jenkins-app/optimize.sh monitor.sh
```

### 2️⃣ Development Mode (Local Build)
```bash
cd laravel-jenkins-app
./setup.sh
```

### 3️⃣ Production Mode (Docker Hub)
```bash
cd laravel-jenkins-app
./deploy.sh
```

### 4️⃣ Performance Optimization
```bash
cd laravel-jenkins-app/src
../optimize.sh
```

### 5️⃣ System Monitoring
```bash
./monitor.sh
```

## 🌐 Access Points

| Service | URL | Port | Description |
|---------|-----|------|-------------|
| **Laravel App** | http://localhost:8000 | 8000 | Main application |
| **Jenkins** | http://localhost:8080 | 8080 | CI/CD dashboard |
| **MySQL** | localhost:3306 | 3306 | Database server |

## 🔗 Links

- **Repository**: https://github.com/Rofiq02bae/nangkring
- **Docker Hub**: https://hub.docker.com/r/rofiq02bae/laravel-vite-app
- **Maintainer**: @Rofiq02bae
