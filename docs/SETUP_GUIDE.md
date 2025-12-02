# Setup Guide

Complete guide to setting up the ARgument development environment.

## Prerequisites

### Required Software

- **Node.js**: 18.x or higher ([Download](https://nodejs.org/))
- **npm**: 9.x or higher (comes with Node.js)
- **Docker**: 20.x or higher ([Download](https://www.docker.com/))
- **Docker Compose**: 2.x or higher (comes with Docker Desktop)
- **Git**: Latest version ([Download](https://git-scm.com/))

### Optional Tools

- **Postman**: For API testing
- **pgAdmin**: For PostgreSQL management
- **Redis Insight**: For Redis debugging

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/argument.git
cd argument
```

### 2. Install Dependencies

```bash
# Install root dependencies
npm install

# Install all workspace dependencies
npm install --workspaces
```

This will install dependencies for:
- Root workspace
- Backend (`backend/`)
- Frontend (`frontend/`)
- Shared (`shared/`)

## Development Setup

### Option A: Using Docker (Recommended)

#### 1. Start All Services

```bash
docker-compose up -d
```

This starts:
- PostgreSQL (port 5432)
- Redis (port 6379)
- MinIO (ports 9000, 9001)
- Backend API (port 3000)
- Frontend Dashboard (port 3001)

#### 2. Check Service Status

```bash
docker-compose ps
```

#### 3. View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

#### 4. Initialize Database

```bash
# Run migrations
npm run migration:run

# Seed test data
npm run seed
```

#### 5. Access Services

- **Frontend Dashboard**: http://localhost:3001
- **Backend API**: http://localhost:3000/api/v1
- **API Documentation**: http://localhost:3000/api/docs
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)

#### 6. Test Credentials

After seeding, you can log in with:
- **Admin**: admin@argument.io / admin123
- **User**: user@example.com / password123

### Option B: Local Development (Without Docker)

#### 1. Install PostgreSQL

**macOS (Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Ubuntu/Debian:**
```bash
sudo apt-get install postgresql-15
sudo systemctl start postgresql
```

**Windows:**
Download from [PostgreSQL Official Site](https://www.postgresql.org/download/windows/)

#### 2. Install Redis

**macOS (Homebrew):**
```bash
brew install redis
brew services start redis
```

**Ubuntu/Debian:**
```bash
sudo apt-get install redis-server
sudo systemctl start redis
```

**Windows:**
Download from [Redis Official Site](https://redis.io/download)

#### 3. Create Database

```bash
psql postgres
CREATE DATABASE argument;
CREATE USER argument WITH PASSWORD 'argument';
GRANT ALL PRIVILEGES ON DATABASE argument TO argument;
\q
```

#### 4. Configure Environment Variables

**Backend:**
```bash
cd backend
cp .env.example .env
```

Edit `backend/.env`:
```env
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=argument
DB_PASSWORD=argument
DB_DATABASE=argument
JWT_SECRET=your-secret-key
```

**Frontend:**
```bash
cd frontend
cp .env.example .env.local
```

Edit `frontend/.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

#### 5. Run Migrations

```bash
cd backend
npm run migration:run
```

#### 6. Seed Database

```bash
cd backend
npm run seed
```

#### 7. Start Development Servers

**Terminal 1 - Backend:**
```bash
cd backend
npm run start:dev
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

Or from root:
```bash
npm run dev
```

## Verification

### 1. Backend Health Check

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### 2. Frontend Access

Open browser: http://localhost:3001

You should see the ARgument landing page.

### 3. API Documentation

Open browser: http://localhost:3000/api/docs

You should see the Swagger UI.

### 4. Test API Endpoints

**Register:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

Save the `access_token` from the response.

**Get Projects:**
```bash
curl http://localhost:3000/api/v1/projects \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Common Issues

### Port Already in Use

**Error:** `Port 3000 is already in use`

**Solution:**
```bash
# Find process using port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process
kill -9 PID  # macOS/Linux
taskkill /PID PID /F  # Windows
```

### Database Connection Failed

**Error:** `ECONNREFUSED ::1:5432`

**Solution:**
- Check PostgreSQL is running: `brew services list` (macOS)
- Verify connection settings in `.env`
- Try using `127.0.0.1` instead of `localhost`

### Docker Container Exits

**Error:** Backend or frontend container stops

**Solution:**
```bash
# Check logs
docker-compose logs backend

# Rebuild containers
docker-compose down
docker-compose up --build -d
```

### Migration Failed

**Error:** Migration errors

**Solution:**
```bash
# Revert all migrations
cd backend
npm run migration:revert

# Run migrations again
npm run migration:run
```

### Node Modules Issues

**Error:** Module not found errors

**Solution:**
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install

# Or for all workspaces
npm run clean
npm install --workspaces
```

## Development Tools

### VS Code Extensions

Recommended extensions:
- ESLint
- Prettier
- TypeScript and JavaScript Language Features
- Tailwind CSS IntelliSense
- Docker
- PostgreSQL

### Browser Extensions

- React Developer Tools
- Redux DevTools (if using Redux)

## Next Steps

1. Read [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines
2. Check [Architecture Overview](./architecture/OVERVIEW.md)
3. Review [API Specification](../API_SPEC.yaml)
4. Start building features!

## Getting Help

- Open an issue on GitHub
- Check existing documentation
- Ask in discussions

## Cleanup

### Stop Services

```bash
# Docker
docker-compose down

# Remove volumes (WARNING: deletes all data)
docker-compose down -v
```

### Uninstall

```bash
# Remove node modules
rm -rf node_modules backend/node_modules frontend/node_modules shared/node_modules

# Remove Docker images
docker image prune -a
```
