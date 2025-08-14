# 🚀 Laravel 12 + Vite + Jenkins CI/CD

Project Laravel 12 dengan Vite dan Jenkins CI/CD menggunakan Docker untuk development dan production environment.

## 📁 Struktur Project

```
laravel-jenkins-app/
├── src/                    # Laravel 12 application
├── Dockerfile             # PHP 8.2 + Node.js 20 + Extensions
├── docker-compose.yml     # Laravel + MySQL + Jenkins services
├── Jenkinsfile           # CI/CD Pipeline configuration
├── setup.sh              # Quick setup script
├── JENKINS_SETUP.md      # Detailed Jenkins setup guide
└── README.md             # This file
```

## 🔧 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/Rofiq02bae/nangkring.git
cd nangkring/laravel-jenkins-app
```

### 2. Start Services
```bash
# Make setup script executable
chmod +x setup.sh

# Run quick setup
./setup.sh
```

### 3. Access Services
- **Laravel App**: http://localhost:8000
- **Jenkins**: http://localhost:8080
- **MySQL**: localhost:3306

## 🏗️ Tech Stack

- **Backend**: Laravel 12 (PHP 8.2)
- **Frontend**: Vite + JavaScript
- **Database**: MySQL 8.0
- **CI/CD**: Jenkins LTS
- **Containerization**: Docker + Docker Compose

## 📦 PHP Extensions Included

- `pdo_mysql` - MySQL database support
- `mbstring` - Multibyte string support
- `bcmath` - Arbitrary precision mathematics
- `gd` - Image processing
- `intl` - Internationalization
- `curl` - HTTP client
- `zip` - Archive handling

## Requirements

- Docker
- Docker Compose
- Jenkins

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd laravel-jenkins-app
   ```

2. **Build and run the containers:**

   ```bash
   docker-compose up --build
   ```

3. **Access the application:**

   Open your browser and navigate to `http://localhost:8000` to view the Laravel application.

4. **Access Jenkins:**

   Open your browser and navigate to `http://localhost:8080` to access the Jenkins dashboard.

## Docker Configuration

- **Dockerfile:** Sets up the Laravel environment with PHP 8.2, necessary extensions, Composer, and Node.js 20+ for Vite.
- **docker-compose.yml:** Defines services for the Laravel app, MySQL database, and Jenkins, with appropriate port mappings and volume mounts.

## Jenkins Pipeline

The `Jenkinsfile` defines the CI/CD pipeline with the following stages:

- Install PHP dependencies using Composer.
- Install JavaScript dependencies using npm.
- Build assets using Vite.
- Run database migrations with Laravel.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.