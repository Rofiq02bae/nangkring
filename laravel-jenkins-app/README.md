# Laravel Jenkins CI/CD Project

This project is a Laravel 12 application configured with Docker and integrated with Jenkins for Continuous Integration and Continuous Deployment (CI/CD). The setup includes a MySQL database and utilizes Vite for asset bundling.

## Project Structure

```
laravel-jenkins-app
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
├── src
│   └── (Laravel project files)
└── README.md
```

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