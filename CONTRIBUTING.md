# Contributing to ARgument

Thank you for your interest in contributing to ARgument! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/argument.git`
3. Add upstream remote: `git remote add upstream https://github.com/original/argument.git`

## Development Setup

### Prerequisites

- Node.js 18+ and npm 9+
- Docker and Docker Compose (optional but recommended)
- PostgreSQL 15+ (if not using Docker)
- Redis 7+ (if not using Docker)

### Installation

```bash
# Install root dependencies
npm install

# Install backend dependencies
cd backend && npm install

# Install frontend dependencies
cd ../frontend && npm install

# Install shared dependencies
cd ../shared && npm install
```

### Using Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# Run migrations
npm run migration:run

# Seed database with test data
npm run seed

# View logs
npm run docker:logs
```

### Local Development (Without Docker)

1. **Start PostgreSQL and Redis**
2. **Configure environment variables**
   ```bash
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env.local
   ```
3. **Run migrations**
   ```bash
   cd backend && npm run migration:run
   ```
4. **Seed database**
   ```bash
   cd backend && npm run seed
   ```
5. **Start development servers**
   ```bash
   # From root directory
   npm run dev
   
   # Or start separately
   npm run dev:backend
   npm run dev:frontend
   ```

## Project Structure

```
argument/
├── backend/              # NestJS backend API
│   ├── src/
│   │   ├── modules/      # Feature modules
│   │   ├── config/       # Configuration
│   │   ├── database/     # Migrations and seeds
│   │   └── main.ts       # Entry point
│   └── Dockerfile
├── frontend/             # Next.js frontend
│   ├── src/
│   │   ├── app/          # App router pages
│   │   ├── components/   # React components
│   │   ├── lib/          # Utilities
│   │   └── hooks/        # Custom hooks
│   └── Dockerfile
├── shared/               # Shared types and constants
│   ├── types.ts
│   └── constants.ts
├── docs/                 # Documentation
└── docker-compose.yml    # Docker services
```

## Development Workflow

### Creating a New Feature

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the coding standards
   - Write tests for new functionality
   - Update documentation if needed

3. **Test your changes**
   ```bash
   npm run lint
   npm run test
   npm run build
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**

## Coding Standards

### TypeScript

- Use TypeScript for all new code
- Enable strict type checking
- Avoid using `any` type unless absolutely necessary
- Use interfaces for object types
- Use enums for constants with multiple related values

### Backend (NestJS)

- Follow NestJS best practices
- Use dependency injection
- Organize code by feature modules
- Use DTOs for request/response validation
- Use TypeORM entities for database models
- Write service layer tests

### Frontend (Next.js)

- Use React functional components with hooks
- Use TypeScript for type safety
- Follow Next.js App Router conventions
- Use React Query for API calls
- Use Tailwind CSS for styling
- Keep components small and focused

### Code Style

- Use ESLint and Prettier for code formatting
- Run `npm run format` before committing
- Follow existing patterns in the codebase
- Write self-documenting code
- Add comments for complex logic only

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(auth): add JWT refresh token functionality
fix(projects): resolve project deletion bug
docs(readme): update installation instructions
test(users): add unit tests for user service
```

## Testing

### Backend Tests

```bash
cd backend

# Unit tests
npm test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### Frontend Tests

```bash
cd frontend

# Run tests (when implemented)
npm test
```

### Test Guidelines

- Write unit tests for services and utilities
- Write integration tests for API endpoints
- Write E2E tests for critical user flows
- Aim for 80%+ test coverage
- Mock external dependencies

## Pull Request Process

1. **Update your branch with latest main**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Ensure all checks pass**
   - Linting
   - Type checking
   - Tests
   - Build

3. **Write a clear PR description**
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Screenshots (if applicable)

4. **Link related issues**
   - Use keywords: Fixes #123, Closes #456

5. **Request review**
   - Tag relevant reviewers
   - Address review comments promptly

6. **Squash commits** (if requested)
   ```bash
   git rebase -i HEAD~n
   ```

## Database Migrations

### Creating a Migration

```bash
cd backend
npm run migration:create -- src/database/migrations/YourMigrationName
```

### Running Migrations

```bash
cd backend
npm run migration:run
```

### Reverting Migrations

```bash
cd backend
npm run migration:revert
```

## API Documentation

- Update OpenAPI specification in `API_SPEC.yaml`
- Swagger docs are auto-generated at `/api/docs`
- Add JSDoc comments to controllers and DTOs

## Questions?

- Open an issue for bugs or feature requests
- Join our discussions for questions
- Check existing documentation first

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Follow our [Code of Conduct](CODE_OF_CONDUCT.md)

## License

By contributing to ARgument, you agree that your contributions will be licensed under the MIT License.
