# Architecture Overview

## System Architecture

ARgument is built as a modern, scalable monorepo application with clear separation between backend, frontend, and shared code.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Browser    │  │   Mobile     │  │   Desktop    │      │
│  │   (WebAR)    │  │   Browser    │  │   Browser    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Frontend Layer                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          Next.js 14 (React App Router)               │   │
│  │  - Dashboard UI                                       │   │
│  │  - WebAR Viewer                                       │   │
│  │  - Authentication Pages                               │   │
│  │  - Project Management                                 │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼ HTTP/REST API
┌─────────────────────────────────────────────────────────────┐
│                      Backend Layer                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              NestJS API Server                        │   │
│  │  ┌────────────────┐  ┌─────────────────┐            │   │
│  │  │ Auth Module    │  │ Projects Module │            │   │
│  │  ├────────────────┤  ├─────────────────┤            │   │
│  │  │ Users Module   │  │ Images Module   │            │   │
│  │  ├────────────────┤  ├─────────────────┤            │   │
│  │  │ Videos Module  │  │ Markers Module  │            │   │
│  │  ├────────────────┤  ├─────────────────┤            │   │
│  │  │ Links Module   │  │Analytics Module │            │   │
│  │  └────────────────┘  └─────────────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐  ┌────────────────┐  ┌────────────────┐
│  PostgreSQL   │  │     Redis      │  │  S3/MinIO      │
│   Database    │  │ Cache & Queue  │  │  File Storage  │
└───────────────┘  └────────────────┘  └────────────────┘
```

## Technology Stack

### Backend
- **Framework**: NestJS (TypeScript)
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+
- **ORM**: TypeORM
- **Authentication**: JWT with Passport.js
- **API Documentation**: Swagger/OpenAPI
- **Validation**: class-validator, class-transformer

### Frontend
- **Framework**: Next.js 14 (App Router)
- **UI Library**: React 18
- **Styling**: Tailwind CSS + shadcn/ui
- **State Management**: Zustand
- **API Client**: TanStack Query (React Query)
- **Forms**: React Hook Form + Zod
- **WebAR**: AR.js + Three.js

### DevOps
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana (planned)
- **Logging**: Structured logging with Winston

## Key Design Principles

### 1. Monorepo Structure
- **Shared Code**: Common types and constants in `shared/` package
- **Independent Services**: Backend and frontend can be deployed separately
- **Type Safety**: End-to-end TypeScript type safety

### 2. Modularity
- **Backend**: Feature-based module organization
- **Frontend**: Component-based architecture
- **Clear Boundaries**: Well-defined interfaces between layers

### 3. Scalability
- **Horizontal Scaling**: Stateless API servers
- **Caching**: Redis for session and data caching
- **CDN**: CloudFront for static assets and videos
- **Database**: Read replicas for analytics queries

### 4. Security
- **Authentication**: JWT with short expiration
- **Authorization**: Role-based access control (RBAC)
- **Input Validation**: Request validation at API layer
- **Data Protection**: Encryption at rest and in transit

### 5. Performance
- **API Response**: < 200ms (p95)
- **Page Load**: < 2s initial load
- **WebAR Init**: < 3s
- **Video Streaming**: Adaptive bitrate

## Data Flow

### User Registration & Authentication
1. User submits registration form (Frontend)
2. Frontend validates input with Zod schema
3. Backend validates and hashes password (bcrypt)
4. User record created in PostgreSQL
5. JWT tokens generated and returned
6. Frontend stores access token

### Project Creation & Media Upload
1. User creates project (Frontend → Backend)
2. Backend validates user quota
3. Project record created in database
4. User uploads image
5. Backend processes image (Sharp)
6. Image stored in S3/MinIO
7. Metadata saved to database
8. User uploads video
9. Video processing job queued (Bull + Redis)
10. Worker processes video (FFmpeg)
11. Processed video stored in S3/MinIO

### AR Marker Generation
1. User requests marker generation
2. Backend extracts image features (OpenCV)
3. Marker data generated and stored
4. Tracking quality score calculated
5. Marker file (.fset) created
6. Marker associated with image and video

### WebAR Link Generation
1. User creates AR link
2. Backend generates unique slug
3. QR code generated
4. Link record created with settings
5. Link URL returned to user

### AR Session & Analytics
1. Viewer opens AR link
2. WebAR Viewer loads in browser
3. Camera permission requested
4. AR.js initializes with marker data
5. Session created in database
6. User scans printed image
7. Marker detected event tracked
8. Video overlay rendered
9. Playback events tracked
10. Session ended and duration calculated
11. Analytics aggregated daily

## Module Dependencies

```
┌─────────────┐
│    Auth     │
│   Module    │────────┐
└─────────────┘        │
                       │
┌─────────────┐        │     ┌─────────────┐
│    Users    │◄───────┼─────│  Projects   │
│   Module    │        │     │   Module    │
└─────────────┘        │     └─────────────┘
                       │            │
┌─────────────┐        │     ┌──────┴──────┐
│   Images    │◄───────┼─────┤             │
│   Module    │        │     │             │
└─────────────┘        │     │             │
       │               │     │             │
       ├───────────────┼─────┤             │
       │               │     │             │
┌──────▼──────┐        │     │             │
│   Markers   │◄───────┼─────┤             │
│   Module    │        │     │             │
└─────────────┘        │     │             │
       │               │     │             │
       ├───────────────┴─────┤             │
       │                     │             │
┌──────▼──────┐              │             │
│    Links    │◄─────────────┤             │
│   Module    │              │             │
└─────────────┘              │             │
       │                     │             │
┌──────▼──────┐              │             │
│  Analytics  │◄─────────────┘             │
│   Module    │                            │
└─────────────┘                            │
       │                                   │
┌──────▼──────┐                            │
│   Videos    │◄───────────────────────────┘
│   Module    │
└─────────────┘
```

## Security Architecture

### Authentication Flow
1. User login with email/password
2. Backend validates credentials
3. Access token (15min) & refresh token (7d) generated
4. Tokens returned to client
5. Client stores access token in memory
6. Refresh token stored in httpOnly cookie
7. Access token included in API requests
8. Backend validates token on each request
9. Token refresh when expired

### Authorization
- **User Role**: Basic access to own resources
- **Admin Role**: Full access to all resources
- **Guards**: NestJS guards for route protection
- **Decorators**: Custom decorators for role checking

## Deployment Architecture

### Development
- Docker Compose for local development
- Hot reload for both backend and frontend
- Local PostgreSQL, Redis, and MinIO

### Staging/Production
- AWS ECS or Kubernetes
- RDS for PostgreSQL
- ElastiCache for Redis
- S3 for file storage
- CloudFront CDN
- Application Load Balancer
- Auto-scaling groups

## Future Enhancements

- WebSocket support for real-time analytics
- Microservices for video processing
- GraphQL API option
- Mobile app (React Native)
- Advanced AR features (3D models, animations)
- Multi-tenancy support
- Advanced analytics with machine learning
