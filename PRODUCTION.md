# 🚀 Production Deployment Guide

## Overview

Panduan lengkap untuk deploy Laravel 12 + Vite + Jenkins CI/CD ke production environment.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   Docker Hub    │    │   Production    │
│                 │    │                 │    │   Environment   │
│  Source Code    │───▶│  Docker Images  │───▶│  Running Apps   │
│  Jenkinsfile    │    │  Multi-platform │    │  Load Balancer  │
│  Dockerfile     │    │  Auto-builds    │    │  Health Checks  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Pre-Production Checklist

### 🔐 Security Setup
- [ ] Environment variables secured
- [ ] Database credentials rotated
- [ ] SSL certificates configured
- [ ] Firewall rules applied
- [ ] Docker image scanning passed

### 🔧 Infrastructure Setup
- [ ] Load balancer configured
- [ ] Database backup strategy
- [ ] Log aggregation setup
- [ ] Monitoring alerts configured
- [ ] Resource limits defined

### 📊 Performance Optimization
- [ ] Opcache enabled
- [ ] Redis/Memcached configured
- [ ] CDN setup for assets
- [ ] Database indexing optimized
- [ ] Queue workers configured

## 🚀 Deployment Strategies

### 1. Blue-Green Deployment
```bash
# Deploy to green environment
docker-compose -f docker-compose.prod.yml up -d --scale app=2

# Health check
curl -f http://green.yourapp.com/health

# Switch traffic
# Update load balancer to point to green

# Rollback if needed
# Switch load balancer back to blue
```

### 2. Rolling Update
```bash
# Update containers one by one
docker-compose -f docker-compose.prod.yml up -d --scale app=3 --no-recreate

# Gradually replace old containers
docker-compose -f docker-compose.prod.yml stop app_old
```

### 3. Canary Deployment
```bash
# Deploy new version to subset of servers
docker-compose -f docker-compose.canary.yml up -d

# Monitor metrics
# Gradually increase traffic to new version
```

## 🔧 Production Configuration

### docker-compose.prod.yml
```yaml
version: '3.8'

services:
  app:
    image: rofiq02bae/laravel-vite-app:latest
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - DB_HOST=db-primary
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - app-network

  db-primary:
    image: mysql:8.0
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    networks:
      - app-network

  redis:
    image: redis:alpine
    deploy:
      resources:
        limits:
          memory: 256M
    networks:
      - app-network

volumes:
  db-data:
    driver: local

networks:
  app-network:
    driver: overlay
```

### nginx.conf
```nginx
upstream laravel {
    server app:8000;
}

server {
    listen 80;
    server_name yourapp.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourapp.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://laravel;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        access_log off;
        proxy_pass http://laravel/health;
    }
}
```

## 📊 Monitoring & Observability

### Health Check Endpoint
```php
// routes/web.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'version' => config('app.version'),
        'environment' => config('app.env'),
        'database' => DB::connection()->getPdo() ? 'connected' : 'disconnected',
        'cache' => Cache::get('health_check') !== null ? 'working' : 'failed'
    ]);
});
```

### Prometheus Metrics
```yaml
# docker-compose.monitoring.yml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### Log Aggregation
```yaml
# docker-compose.logging.yml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
    
  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
```

## 🔄 Backup & Recovery

### Database Backup
```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="laravel"

# Create backup
docker exec mysql-container mysqldump -u root -p${DB_PASSWORD} ${DB_NAME} > ${BACKUP_DIR}/db_backup_${DATE}.sql

# Compress backup
gzip ${BACKUP_DIR}/db_backup_${DATE}.sql

# Upload to S3 (optional)
aws s3 cp ${BACKUP_DIR}/db_backup_${DATE}.sql.gz s3://your-backup-bucket/

# Cleanup old backups (keep last 7 days)
find ${BACKUP_DIR} -name "db_backup_*.sql.gz" -mtime +7 -delete
```

### Application Backup
```bash
#!/bin/bash
# app-backup.sh

# Backup application files
tar -czf /backups/app_backup_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/html

# Backup Docker volumes
docker run --rm -v laravel-jenkins-app_db_data:/volume -v /backups:/backup busybox tar -czf /backup/volume_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /volume .
```

## 🚨 Disaster Recovery

### Rollback Procedure
```bash
#!/bin/bash
# rollback.sh

PREVIOUS_VERSION="v1.2.3"

echo "🚨 Starting rollback to version: ${PREVIOUS_VERSION}"

# Pull previous version
docker pull rofiq02bae/laravel-vite-app:${PREVIOUS_VERSION}

# Update docker-compose to use previous version
sed -i "s|:latest|:${PREVIOUS_VERSION}|g" docker-compose.prod.yml

# Deploy previous version
docker-compose -f docker-compose.prod.yml up -d

# Run health check
./health-check.sh

echo "✅ Rollback completed"
```

### Database Recovery
```bash
#!/bin/bash
# restore-db.sh

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

echo "🗄️ Restoring database from: ${BACKUP_FILE}"

# Restore database
gunzip -c ${BACKUP_FILE} | docker exec -i mysql-container mysql -u root -p${DB_PASSWORD} laravel

echo "✅ Database restore completed"
```

## 📈 Performance Optimization

### Laravel Optimizations
```bash
# Production optimizations
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan optimize

# OPcache configuration
echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini
echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini
echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/opcache.ini
```

### Database Optimizations
```sql
-- Index optimization
ANALYZE TABLE users;
OPTIMIZE TABLE users;

-- Query performance
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- Connection pooling
SET GLOBAL max_connections = 200;
SET GLOBAL wait_timeout = 300;
```

## 🔐 Security Hardening

### Container Security
```dockerfile
# Use non-root user
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Remove unnecessary packages
RUN apt-get autoremove -y && apt-get clean

# Set secure file permissions
RUN chmod 600 /var/www/.env
```

### Network Security
```yaml
# docker-compose.prod.yml
networks:
  frontend:
    driver: overlay
    external: true
  backend:
    driver: overlay
    internal: true
```

### Environment Security
```bash
# Use Docker secrets
echo "db_password" | docker secret create db_password -

# Reference in compose
services:
  app:
    secrets:
      - db_password
```

---

🏆 **Production Ready Checklist:**
- [ ] All security measures implemented
- [ ] Monitoring and alerting configured
- [ ] Backup and recovery tested
- [ ] Performance optimized
- [ ] Documentation updated
- [ ] Team trained on procedures
