# ARgument WebAR Service - Architecture Diagrams

## 1. System Architecture Overview

```mermaid
graph TB
    subgraph "Client Layer"
        Web[Web Browser]
        Mobile[Mobile Browser]
    end
    
    subgraph "CDN"
        CDN[CloudFront/Cloudflare<br/>Static Assets & Videos]
    end
    
    subgraph "Application Layer"
        LB[Load Balancer]
        API1[API Server 1<br/>NestJS]
        API2[API Server 2<br/>NestJS]
        Dashboard[Dashboard<br/>Next.js]
        Viewer[WebAR Viewer<br/>AR.js + Three.js]
    end
    
    subgraph "Background Processing"
        Queue[Redis Queue<br/>Bull]
        Worker1[Worker 1<br/>Image Processing]
        Worker2[Worker 2<br/>Video Processing]
        Worker3[Worker 3<br/>Marker Generation]
    end
    
    subgraph "Data Layer"
        DB[(PostgreSQL<br/>Primary)]
        DBReplica[(PostgreSQL<br/>Read Replica)]
        Redis[(Redis<br/>Cache & Queue)]
        S3[(S3/MinIO<br/>File Storage)]
    end
    
    subgraph "Monitoring"
        APM[APM<br/>Datadog/New Relic]
        Logs[Log Aggregation<br/>ELK/Loki]
        Metrics[Metrics<br/>Prometheus]
    end
    
    Web --> CDN
    Mobile --> CDN
    Web --> LB
    Mobile --> LB
    
    LB --> API1
    LB --> API2
    LB --> Dashboard
    LB --> Viewer
    
    API1 --> DB
    API2 --> DB
    API1 --> DBReplica
    API2 --> DBReplica
    API1 --> Redis
    API2 --> Redis
    API1 --> S3
    API2 --> S3
    API1 --> Queue
    API2 --> Queue
    
    Dashboard --> API1
    Dashboard --> API2
    Viewer --> CDN
    Viewer --> API1
    
    Queue --> Worker1
    Queue --> Worker2
    Queue --> Worker3
    Worker1 --> S3
    Worker2 --> S3
    Worker3 --> S3
    Worker1 --> DB
    Worker2 --> DB
    Worker3 --> DB
    
    API1 --> APM
    API2 --> APM
    Worker1 --> Logs
    Worker2 --> Logs
    API1 --> Metrics
    API2 --> Metrics
```

## 2. Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend Layer                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────┐         ┌─────────────────────┐       │
│  │   Dashboard App     │         │   WebAR Viewer      │       │
│  │   (Next.js)         │         │   (HTML5 + AR.js)   │       │
│  ├─────────────────────┤         ├─────────────────────┤       │
│  │ - Project Mgmt      │         │ - Camera Access     │       │
│  │ - File Upload       │         │ - Marker Detection  │       │
│  │ - Analytics View    │         │ - Video Overlay     │       │
│  │ - Admin Panel       │         │ - Analytics Track   │       │
│  └─────────────────────┘         └─────────────────────┘       │
│            │                              │                      │
└────────────┼──────────────────────────────┼──────────────────────┘
             │                              │
             └──────────────┬───────────────┘
                            │
                   REST API (JSON)
                            │
┌────────────────────────────┴─────────────────────────────────────┐
│                      Backend Layer (NestJS)                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     API Gateway                             │ │
│  │  - Authentication (JWT)                                     │ │
│  │  - Rate Limiting                                            │ │
│  │  - Request Validation                                       │ │
│  │  - Error Handling                                           │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                    │
│  ┌───────────────────────────┴────────────────────────────────┐ │
│  │                   Controllers Layer                         │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │  AuthController  │  ProjectController  │  ImageController  │ │
│  │  VideoController │  MarkerController   │  LinkController   │ │
│  │  AnalyticsController  │  AdminController                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                    │
│  ┌───────────────────────────┴────────────────────────────────┐ │
│  │                   Services Layer                            │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │  AuthService           │  ProjectService                    │ │
│  │  ImageProcessing       │  VideoProcessing                   │ │
│  │  MarkerGeneration      │  LinkService                       │ │
│  │  AnalyticsService      │  StorageService                    │ │
│  │  EmailService          │  CacheService                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                    │
│  ┌───────────────────────────┴────────────────────────────────┐ │
│  │                   Repository Layer                          │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │  UserRepository    │  ProjectRepository                     │ │
│  │  ImageRepository   │  VideoRepository                       │ │
│  │  MarkerRepository  │  AnalyticsRepository                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
             │                    │                    │
             │                    │                    │
┌────────────┴────┐   ┌───────────┴────────┐   ┌──────┴───────┐
│   PostgreSQL    │   │   Redis Cache      │   │   S3/MinIO   │
│   (Primary DB)  │   │   & Queue          │   │   (Storage)  │
└─────────────────┘   └────────────────────┘   └──────────────┘
```

## 3. Data Flow Diagram

### 3.1 Project Creation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant D as Dashboard
    participant API as API Server
    participant DB as Database
    participant R as Redis
    
    U->>D: Create Project
    D->>API: POST /api/v1/projects
    API->>API: Validate JWT
    API->>API: Check Quota
    API->>DB: Insert Project
    DB-->>API: Project Created
    API->>R: Cache Project
    API-->>D: 201 Created
    D-->>U: Show Success
```

### 3.2 Image & Video Upload Flow

```mermaid
sequenceDiagram
    participant U as User
    participant D as Dashboard
    participant API as API Server
    participant Q as Queue
    participant W as Worker
    participant S3 as Storage
    participant DB as Database
    
    U->>D: Upload Image/Video
    D->>API: POST /api/v1/images/upload
    API->>API: Validate File
    API->>S3: Upload Original
    S3-->>API: File URL
    API->>DB: Save Metadata
    API->>Q: Add Processing Job
    Q-->>W: Job Assigned
    API-->>D: 202 Accepted
    D-->>U: Processing...
    
    W->>S3: Download File
    W->>W: Process (Resize/Transcode)
    W->>S3: Upload Processed
    W->>DB: Update Status
    W->>API: Webhook/Event
    API-->>D: Status Update (WebSocket)
    D-->>U: Processing Complete
```

### 3.3 Marker Generation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant D as Dashboard
    participant API as API Server
    participant Q as Queue
    participant W as Worker (OpenCV)
    participant S3 as Storage
    participant DB as Database
    
    U->>D: Generate Marker
    D->>API: POST /api/v1/markers/generate
    API->>DB: Get Image
    API->>Q: Add Marker Job
    Q-->>W: Job Assigned
    API-->>D: 202 Processing
    
    W->>S3: Download Image
    W->>W: Extract Features (OpenCV)
    W->>W: Generate NFT Marker
    W->>W: Calculate Quality Score
    W->>S3: Upload Marker Data
    W->>DB: Save Marker
    W->>API: Webhook
    API-->>D: Marker Ready
    D-->>U: Success + Quality Score
```

### 3.4 WebAR Viewing Flow

```mermaid
sequenceDiagram
    participant V as Viewer
    participant AR as WebAR Viewer
    participant API as API Server
    participant CDN as CDN
    participant DB as Database
    
    V->>AR: Open Link
    AR->>API: GET /api/v1/links/{id}
    API->>DB: Get Link Data
    API-->>AR: Link Config
    
    AR->>API: POST /api/v1/analytics/track (view_started)
    AR->>V: Request Camera
    V->>AR: Camera Access Granted
    
    AR->>CDN: Load Marker Data
    AR->>CDN: Load Video
    AR->>AR: Initialize AR.js
    
    loop Tracking Loop
        AR->>AR: Scan for Marker
        AR->>AR: Detect Marker
        AR->>API: POST /api/v1/analytics/track (marker_detected)
        AR->>AR: Overlay Video
        AR->>API: POST /api/v1/analytics/track (video_started)
    end
    
    AR->>API: POST /api/v1/analytics/track (video_completed)
    AR->>API: POST /api/v1/analytics/track (session_ended)
```

## 4. Database Entity Relationship Diagram

```
┌─────────────────┐
│     users       │
├─────────────────┤
│ PK id           │──┐
│    email        │  │
│    password_hash│  │
│    name         │  │
│    role         │  │
│    created_at   │  │
└─────────────────┘  │
                     │
         ┌───────────┼────────────────────────┐
         │           │                        │
         │  ┌────────▼──────────┐    ┌────────▼──────────┐
         │  │   user_quotas     │    │   refresh_tokens  │
         │  ├───────────────────┤    ├───────────────────┤
         │  │ PK id             │    │ PK id             │
         │  │ FK user_id        │    │ FK user_id        │
         │  │    max_projects   │    │    token          │
         │  │    max_storage    │    │    expires_at     │
         │  │    current_storage│    └───────────────────┘
         │  └───────────────────┘
         │
         │  ┌─────────────────┐
         └─>│    projects     │
            ├─────────────────┤
            │ PK id           │──┐
            │ FK user_id      │  │
            │    name         │  │
            │    description  │  │
            │    total_views  │  │
            │    created_at   │  │
            └─────────────────┘  │
                                 │
         ┌───────────────────────┼────────────────┐
         │                       │                │
         │                       │                │
    ┌────▼──────────┐   ┌────────▼────────┐   ┌─▼──────────────────┐
    │    images     │   │     videos      │   │  analytics_daily   │
    ├───────────────┤   ├─────────────────┤   ├────────────────────┤
    │ PK id         │──┐│ PK id           │   │ PK id              │
    │ FK project_id │  ││ FK project_id   │   │ FK project_id      │
    │    file_path  │  ││    file_path    │   │    date            │
    │    width      │  ││    duration     │   │    total_views     │
    │    height     │  ││    status       │   │    unique_viewers  │
    │    format     │  │└─────────────────┘   │    avg_watch_time  │
    └───────────────┘  │                      └────────────────────┘
                       │
                       │
              ┌────────▼────────┐
              │    markers      │
              ├─────────────────┤
              │ PK id           │──┐
              │ FK image_id     │  │
              │ FK video_id     │  │
              │    marker_data  │  │
              │    settings     │  │
              └─────────────────┘  │
                                   │
                          ┌────────▼────────┐
                          │     links       │
                          ├─────────────────┤
                          │ PK id           │──┐
                          │ FK project_id   │  │
                          │ FK marker_id    │  │
                          │    url          │  │
                          │    is_active    │  │
                          │    current_views│  │
                          └─────────────────┘  │
                                               │
                                      ┌────────▼────────┐
                                      │    sessions     │
                                      ├─────────────────┤
                                      │ PK id           │──┐
                                      │ FK link_id      │  │
                                      │    fingerprint  │  │
                                      │    ip_address   │  │
                                      │    user_agent   │  │
                                      │    started_at   │  │
                                      │    duration     │  │
                                      └─────────────────┘  │
                                                           │
                                              ┌────────────▼──────────┐
                                              │  analytics_events     │
                                              ├───────────────────────┤
                                              │ PK id                 │
                                              │ FK session_id         │
                                              │    event_type         │
                                              │    metadata           │
                                              │    timestamp          │
                                              └───────────────────────┘
```

## 5. Deployment Architecture

### 5.1 AWS Deployment

```
┌─────────────────────────────────────────────────────────────────┐
│                         Route 53 (DNS)                           │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│               CloudFront CDN (Static Assets & Videos)            │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                    Application Load Balancer                     │
└────────┬───────────────────────┬─────────────────────┬──────────┘
         │                       │                     │
┌────────▼────────┐   ┌─────────▼────────┐   ┌────────▼──────────┐
│  ECS/EC2 (API)  │   │ ECS/EC2 (API)    │   │ ECS/EC2 (Workers) │
│  Auto Scaling   │   │  Auto Scaling    │   │  Auto Scaling     │
└────────┬────────┘   └─────────┬────────┘   └────────┬──────────┘
         │                      │                      │
         └──────────────────────┼──────────────────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         │                      │                      │
┌────────▼────────┐   ┌─────────▼────────┐   ┌────────▼──────────┐
│  RDS PostgreSQL │   │  ElastiCache     │   │      S3           │
│  Multi-AZ       │   │  Redis Cluster   │   │  (File Storage)   │
│  Read Replicas  │   └──────────────────┘   └───────────────────┘
└─────────────────┘
```

### 5.2 Docker Compose (Development)

```yaml
version: '3.8'

services:
  # Backend API
  api:
    build: ./backend
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
      - minio
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/argument
      - REDIS_URL=redis://redis:6379
      - S3_ENDPOINT=http://minio:9000

  # Frontend Dashboard
  dashboard:
    build: ./frontend
    ports:
      - "3001:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:3000

  # Background Workers
  worker:
    build: ./backend
    command: npm run worker
    depends_on:
      - postgres
      - redis
      - minio

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # Redis Cache & Queue
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  # MinIO (S3 compatible storage)
  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
```

## 6. Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Security Layers                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Layer 1: Network Security                                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - HTTPS/TLS 1.3 enforcement                                │ │
│  │ - WAF (Web Application Firewall)                           │ │
│  │ - DDoS protection                                          │ │
│  │ - IP whitelisting for admin endpoints                     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Layer 2: Application Security                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - JWT authentication with short expiry (15min)            │ │
│  │ - Refresh token rotation                                  │ │
│  │ - Rate limiting (100 req/min per user)                    │ │
│  │ - Input validation & sanitization                         │ │
│  │ - SQL injection prevention (ORM)                          │ │
│  │ - XSS prevention (CSP headers)                            │ │
│  │ - CSRF tokens                                             │ │
│  │ - CORS policy enforcement                                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Layer 3: Data Security                                          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - Password hashing (bcrypt, cost 12)                      │ │
│  │ - Encryption at rest (AES-256)                            │ │
│  │ - Encryption in transit (TLS)                             │ │
│  │ - Secure file upload validation                           │ │
│  │ - Virus scanning for uploaded files                       │ │
│  │ - Database connection encryption                          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  Layer 4: Access Control                                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ - RBAC (Role-Based Access Control)                        │ │
│  │ - Resource ownership validation                           │ │
│  │ - API key management                                      │ │
│  │ - Audit logging                                           │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## 7. Monitoring & Observability Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                      Application Metrics                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  API Server  →  Prometheus Exporter  →  Prometheus        │ │
│  │  Workers     →  Prometheus Exporter  →  Prometheus        │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│                           Grafana Dashboards                     │
│  - API Performance (latency, throughput)                        │
│  - Error Rates                                                  │
│  - Queue Length & Processing Time                              │
│  - Database Performance                                         │
│  - Storage Usage                                                │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         Application Logs                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  API Server  →  Filebeat  →  Elasticsearch  →  Kibana     │ │
│  │  Workers     →  Filebeat  →  Elasticsearch  →  Kibana     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         Error Tracking                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Application  →  Sentry  →  Alerts & Notifications        │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          APM (Tracing)                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Requests  →  Datadog/New Relic  →  Performance Insights  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 8. Scalability Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Load Distribution                         │
│                                                                   │
│  ┌───────────────┐      ┌───────────────┐      ┌─────────────┐ │
│  │  User Traffic │ ───▶ │ Load Balancer │ ───▶ │ API Servers │ │
│  └───────────────┘      └───────────────┘      │ (Auto Scale)│ │
│                                                 └─────────────┘ │
│                                                                   │
│  Scaling Triggers:                                               │
│  - CPU > 70% → Scale up                                         │
│  - Requests/sec > 1000 → Scale up                               │
│  - CPU < 30% for 10min → Scale down                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      Database Scaling                            │
│                                                                   │
│  ┌──────────────┐                                               │
│  │ Primary DB   │ ← Writes                                      │
│  └──────┬───────┘                                               │
│         │ Replication                                            │
│         ├────────┬────────┐                                     │
│  ┌──────▼──────┐ ┌───────▼──────┐ ┌────────▼──────┐          │
│  │ Replica 1   │ │  Replica 2   │ │  Replica 3    │          │
│  │ (Reads)     │ │  (Reads)     │ │  (Analytics)  │          │
│  └─────────────┘ └──────────────┘ └───────────────┘          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       Worker Scaling                             │
│                                                                   │
│  Queue Depth: 0-10       →  2 Workers                           │
│  Queue Depth: 10-50      →  5 Workers                           │
│  Queue Depth: 50-100     →  10 Workers                          │
│  Queue Depth: 100+       →  20 Workers (max)                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         Caching Strategy                         │
│                                                                   │
│  L1: Application Memory (LRU cache)                             │
│  L2: Redis (Distributed cache)                                  │
│  L3: CDN (Static assets & videos)                               │
│                                                                   │
│  Cache Keys:                                                     │
│  - user:{id} → TTL 5min                                         │
│  - project:{id} → TTL 10min                                     │
│  - link:{id} → TTL 1hour                                        │
│  - analytics:{project_id}:{date} → TTL 24hours                  │
└─────────────────────────────────────────────────────────────────┘
```

## 9. CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Actions                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
          ┌─────────▼──────┐  ┌─────────▼──────┐
          │   Pull Request │  │  Push to Main  │
          └────────┬───────┘  └────────┬───────┘
                   │                   │
        ┌──────────▼──────────┐       │
        │  1. Lint            │       │
        │  2. Unit Tests      │       │
        │  3. Integration     │       │
        │  4. Security Scan   │       │
        └─────────────────────┘       │
                                      │
                            ┌─────────▼──────────┐
                            │  1. Run all tests  │
                            │  2. Build Docker   │
                            │  3. Push to ECR    │
                            │  4. Deploy Staging │
                            │  5. E2E Tests      │
                            │  6. Deploy Prod    │
                            └────────────────────┘
```

---

## Diagram Legend

- **Solid lines (─)**: Synchronous communication
- **Dashed lines (┄)**: Asynchronous communication
- **Arrows (→, ▶)**: Data flow direction
- **Boxes (┌┐└┘)**: System components
- **PK**: Primary Key
- **FK**: Foreign Key
