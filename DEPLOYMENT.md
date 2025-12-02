# ARgument WebAR Service - Deployment Guide

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Environment Variables](#environment-variables)
4. [Docker Deployment](#docker-deployment)
5. [Production Deployment (AWS)](#production-deployment-aws)
6. [Database Migrations](#database-migrations)
7. [Monitoring Setup](#monitoring-setup)
8. [Backup and Recovery](#backup-and-recovery)
9. [Troubleshooting](#troubleshooting)
10. [Scaling Guidelines](#scaling-guidelines)

---

## Prerequisites

### Required Software

- **Node.js**: v18+ (LTS recommended)
- **npm** or **yarn**: Latest version
- **PostgreSQL**: 15+
- **Redis**: 7+
- **Docker**: 20.10+ (for containerized deployment)
- **Docker Compose**: 2.0+
- **AWS CLI**: 2.0+ (for AWS deployment)
- **Git**: 2.30+

### Required Accounts & Services

- AWS Account (for production deployment)
- SendGrid or AWS SES (for email)
- Domain name and DNS access
- SSL Certificate (Let's Encrypt or AWS ACM)

---

## Local Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-org/argument.git
cd argument
```

### 2. Install Dependencies

#### Backend
```bash
cd backend
npm install
```

#### Frontend
```bash
cd frontend
npm install
```

### 3. Setup PostgreSQL

#### Using Docker
```bash
docker run -d \
  --name argument-postgres \
  -e POSTGRES_DB=argument \
  -e POSTGRES_USER=argument_user \
  -e POSTGRES_PASSWORD=secure_password \
  -p 5432:5432 \
  postgres:15-alpine
```

#### Using Local PostgreSQL
```bash
# Create database
createdb argument

# Create user
psql postgres -c "CREATE USER argument_user WITH PASSWORD 'secure_password';"
psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE argument TO argument_user;"
```

### 4. Setup Redis

```bash
docker run -d \
  --name argument-redis \
  -p 6379:6379 \
  redis:7-alpine
```

### 5. Setup MinIO (Local S3)

```bash
docker run -d \
  --name argument-minio \
  -p 9000:9000 \
  -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"
```

Access MinIO Console: http://localhost:9001

Create bucket named `argument-storage`

### 6. Configure Environment Variables

Create `.env` files in both backend and frontend directories.

#### Backend `.env`
```env
# Server
NODE_ENV=development
PORT=3000
API_URL=http://localhost:3000

# Database
DATABASE_URL=postgresql://argument_user:secure_password@localhost:5432/argument

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your-refresh-token-secret
JWT_REFRESH_EXPIRES_IN=7d

# Storage (MinIO/S3)
STORAGE_TYPE=s3
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=argument-storage
S3_REGION=us-east-1
S3_USE_SSL=false

# Email
EMAIL_SERVICE=sendgrid
SENDGRID_API_KEY=your-sendgrid-api-key
EMAIL_FROM=noreply@argument.io

# Rate Limiting
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100

# CORS
CORS_ORIGIN=http://localhost:3001

# File Upload
MAX_FILE_SIZE_MB=100
MAX_IMAGE_SIZE_MB=10
```

#### Frontend `.env.local`
```env
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_APP_URL=http://localhost:3001
NEXT_PUBLIC_AR_VIEWER_URL=http://localhost:3001/viewer
```

### 7. Run Database Migrations

```bash
cd backend
npm run migration:run
```

### 8. Seed Database (Optional)

```bash
npm run seed
```

### 9. Start Development Servers

#### Backend
```bash
cd backend
npm run start:dev
```

API will be available at: http://localhost:3000
API Docs (Swagger): http://localhost:3000/api/docs

#### Frontend
```bash
cd frontend
npm run dev
```

Dashboard will be available at: http://localhost:3001

#### Background Workers
```bash
cd backend
npm run worker:dev
```

---

## Environment Variables

### Backend Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `NODE_ENV` | Environment (development/production) | Yes | development |
| `PORT` | API server port | Yes | 3000 |
| `DATABASE_URL` | PostgreSQL connection string | Yes | - |
| `REDIS_HOST` | Redis host | Yes | localhost |
| `REDIS_PORT` | Redis port | Yes | 6379 |
| `JWT_SECRET` | JWT signing secret | Yes | - |
| `JWT_EXPIRES_IN` | Access token expiry | No | 15m |
| `S3_ENDPOINT` | S3/MinIO endpoint | Yes | - |
| `S3_ACCESS_KEY` | S3 access key | Yes | - |
| `S3_SECRET_KEY` | S3 secret key | Yes | - |
| `S3_BUCKET` | S3 bucket name | Yes | - |
| `SENDGRID_API_KEY` | SendGrid API key | Yes | - |
| `RATE_LIMIT_MAX_REQUESTS` | Rate limit per window | No | 100 |
| `MAX_FILE_SIZE_MB` | Max upload size | No | 100 |

### Frontend Environment Variables Reference

| Variable | Description | Required |
|----------|-------------|----------|
| `NEXT_PUBLIC_API_URL` | Backend API URL | Yes |
| `NEXT_PUBLIC_APP_URL` | Frontend URL | Yes |
| `NEXT_PUBLIC_AR_VIEWER_URL` | WebAR viewer URL | Yes |

---

## Docker Deployment

### Docker Compose (All-in-One)

#### 1. Create `docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: argument-postgres
    environment:
      POSTGRES_DB: argument
      POSTGRES_USER: argument_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U argument_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache & Queue
  redis:
    image: redis:7-alpine
    container_name: argument-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MinIO (S3-compatible storage)
  minio:
    image: minio/minio:latest
    container_name: argument-minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ACCESS_KEY}
      MINIO_ROOT_PASSWORD: ${MINIO_SECRET_KEY}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  # Backend API
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: argument-api
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      minio:
        condition: service_healthy
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://argument_user:${DB_PASSWORD}@postgres:5432/argument
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      S3_ENDPOINT: http://minio:9000
      S3_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      S3_SECRET_KEY: ${MINIO_SECRET_KEY}
      JWT_SECRET: ${JWT_SECRET}
      SENDGRID_API_KEY: ${SENDGRID_API_KEY}
    ports:
      - "3000:3000"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Background Workers
  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: argument-worker
    command: npm run worker
    depends_on:
      - postgres
      - redis
      - minio
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://argument_user:${DB_PASSWORD}@postgres:5432/argument
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      S3_ENDPOINT: http://minio:9000
      S3_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      S3_SECRET_KEY: ${MINIO_SECRET_KEY}
    restart: unless-stopped
    deploy:
      replicas: 2

  # Frontend Dashboard
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        NEXT_PUBLIC_API_URL: ${API_URL}
    container_name: argument-frontend
    depends_on:
      - api
    ports:
      - "3001:3000"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: argument-nginx
    depends_on:
      - api
      - frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

#### 2. Create `.env` file

```env
# Database
DB_PASSWORD=your_secure_db_password

# Redis
REDIS_PASSWORD=your_redis_password

# MinIO
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin_secret

# JWT
JWT_SECRET=your_jwt_secret_key

# Email
SENDGRID_API_KEY=your_sendgrid_key

# API URL
API_URL=https://api.yourdomain.com
```

#### 3. Start Services

```bash
docker-compose up -d
```

#### 4. Run Migrations

```bash
docker-compose exec api npm run migration:run
```

#### 5. Check Status

```bash
docker-compose ps
docker-compose logs -f api
```

---

## Production Deployment (AWS)

### Architecture Overview

```
Route 53 (DNS)
    ↓
CloudFront (CDN)
    ↓
Application Load Balancer
    ↓
ECS/EC2 (API Servers + Workers)
    ↓
RDS PostgreSQL + ElastiCache Redis + S3
```

### 1. Prerequisites Setup

#### Install AWS CLI

```bash
# macOS
brew install awscli

# Ubuntu
sudo apt install awscli

# Configure
aws configure
```

#### Install Terraform (Optional)

```bash
brew install terraform
```

### 2. Create VPC and Network

```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=argument-vpc}]'

# Create subnets (public and private)
aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.2.0/24 --availability-zone us-east-1b
```

### 3. Setup RDS PostgreSQL

```bash
aws rds create-db-instance \
  --db-instance-identifier argument-db \
  --db-instance-class db.t3.medium \
  --engine postgres \
  --engine-version 15.3 \
  --master-username argument_admin \
  --master-user-password <secure-password> \
  --allocated-storage 100 \
  --storage-type gp3 \
  --multi-az \
  --backup-retention-period 7 \
  --vpc-security-group-ids <security-group-id>
```

### 4. Setup ElastiCache Redis

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id argument-redis \
  --cache-node-type cache.t3.medium \
  --engine redis \
  --engine-version 7.0 \
  --num-cache-nodes 1 \
  --cache-subnet-group-name argument-subnet-group
```

### 5. Setup S3 Bucket

```bash
# Create bucket
aws s3 mb s3://argument-storage-prod

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket argument-storage-prod \
  --versioning-configuration Status=Enabled

# Set lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket argument-storage-prod \
  --lifecycle-configuration file://s3-lifecycle.json
```

**s3-lifecycle.json**
```json
{
  "Rules": [
    {
      "Id": "DeleteOldVersions",
      "Status": "Enabled",
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 30
      }
    },
    {
      "Id": "TransitionToIA",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "STANDARD_IA"
        }
      ]
    }
  ]
}
```

### 6. Build and Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Create repositories
aws ecr create-repository --repository-name argument-api
aws ecr create-repository --repository-name argument-frontend
aws ecr create-repository --repository-name argument-worker

# Build and push images
docker build -t argument-api ./backend
docker tag argument-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/argument-api:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/argument-api:latest

docker build -t argument-frontend ./frontend
docker tag argument-frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/argument-frontend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/argument-frontend:latest
```

### 7. Create ECS Cluster

```bash
aws ecs create-cluster --cluster-name argument-cluster
```

### 8. Create Task Definitions

**api-task-definition.json**
```json
{
  "family": "argument-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "containerDefinitions": [
    {
      "name": "api",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/argument-api:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:argument/database-url"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:argument/jwt-secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/argument-api",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

Register task definition:
```bash
aws ecs register-task-definition --cli-input-json file://api-task-definition.json
```

### 9. Create ECS Services

```bash
aws ecs create-service \
  --cluster argument-cluster \
  --service-name argument-api \
  --task-definition argument-api \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx,subnet-yyy],securityGroups=[sg-xxx],assignPublicIp=DISABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...,containerName=api,containerPort=3000"
```

### 10. Setup Application Load Balancer

```bash
# Create ALB
aws elbv2 create-load-balancer \
  --name argument-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx \
  --scheme internet-facing

# Create target groups
aws elbv2 create-target-group \
  --name argument-api-tg \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-xxx \
  --target-type ip \
  --health-check-path /health

# Create listeners
aws elbv2 create-listener \
  --load-balancer-arn <alb-arn> \
  --protocol HTTPS \
  --port 443 \
  --certificates CertificateArn=<acm-cert-arn> \
  --default-actions Type=forward,TargetGroupArn=<target-group-arn>
```

### 11. Setup CloudFront

```bash
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json
```

### 12. Setup Route 53

```bash
# Create hosted zone
aws route53 create-hosted-zone --name argument.io --caller-reference $(date +%s)

# Create record sets
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch file://dns-records.json
```

---

## Database Migrations

### Running Migrations

#### Development
```bash
npm run migration:run
```

#### Production
```bash
# Connect to production DB
DATABASE_URL="postgresql://..." npm run migration:run
```

### Creating New Migrations

```bash
npm run migration:create -- AddNewFeature
```

### Rolling Back Migrations

```bash
npm run migration:revert
```

---

## Monitoring Setup

### 1. Application Monitoring (Prometheus + Grafana)

#### Install Prometheus

```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

#### Install Grafana

```bash
docker run -d \
  --name grafana \
  -p 3000:3000 \
  grafana/grafana
```

### 2. Log Aggregation (ELK Stack)

```bash
docker-compose -f elk-docker-compose.yml up -d
```

### 3. Error Tracking (Sentry)

Add to backend:
```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});
```

---

## Backup and Recovery

### Database Backup

#### Automated Daily Backups

```bash
#!/bin/bash
# backup.sh

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="argument_backup_$TIMESTAMP.sql"

pg_dump -h localhost -U argument_user argument > $BACKUP_FILE
gzip $BACKUP_FILE

# Upload to S3
aws s3 cp $BACKUP_FILE.gz s3://argument-backups/
```

Schedule with cron:
```bash
0 2 * * * /path/to/backup.sh
```

#### Restore from Backup

```bash
gunzip argument_backup_20240101_020000.sql.gz
psql -h localhost -U argument_user argument < argument_backup_20240101_020000.sql
```

---

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Symptom**: `ECONNREFUSED` error
**Solution**:
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Check connection
psql -h localhost -U argument_user -d argument
```

#### 2. Redis Connection Failed

**Solution**:
```bash
# Test Redis connection
redis-cli ping
```

#### 3. S3/MinIO Upload Failed

**Solution**:
```bash
# Check MinIO is running
curl http://localhost:9000/minio/health/live

# Verify credentials
aws s3 ls --endpoint-url http://localhost:9000
```

#### 4. Worker Not Processing Jobs

**Solution**:
```bash
# Check worker logs
docker logs argument-worker

# Check Redis queue
redis-cli
> LLEN bull:image-processing:wait
```

---

## Scaling Guidelines

### Horizontal Scaling

#### API Servers
```bash
# Increase ECS service desired count
aws ecs update-service \
  --cluster argument-cluster \
  --service argument-api \
  --desired-count 5
```

#### Workers
```bash
# Scale worker service
aws ecs update-service \
  --cluster argument-cluster \
  --service argument-worker \
  --desired-count 10
```

### Vertical Scaling

#### Database
```bash
# Modify RDS instance class
aws rds modify-db-instance \
  --db-instance-identifier argument-db \
  --db-instance-class db.t3.large \
  --apply-immediately
```

### Auto Scaling

#### Setup Auto Scaling for ECS

```bash
# Register scalable target
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/argument-cluster/argument-api \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10

# Create scaling policy
aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --resource-id service/argument-cluster/argument-api \
  --scalable-dimension ecs:service:DesiredCount \
  --policy-name cpu-scaling-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration file://scaling-policy.json
```

---

## Security Checklist

- [ ] Change all default passwords
- [ ] Enable HTTPS/TLS
- [ ] Configure firewall rules
- [ ] Enable database encryption at rest
- [ ] Setup VPC and private subnets
- [ ] Configure security groups
- [ ] Enable AWS WAF
- [ ] Setup DDoS protection
- [ ] Enable audit logging
- [ ] Rotate secrets regularly
- [ ] Setup backup encryption
- [ ] Configure CORS properly
- [ ] Enable rate limiting

---

## Support

For deployment issues, contact: devops@argument.io

**Documentation Version**: 1.0  
**Last Updated**: 2024
