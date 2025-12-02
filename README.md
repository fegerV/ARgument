# ARgument - WebAR Video Overlay Service

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18+-61DAFB.svg)](https://reactjs.org/)

> Революционный WebAR сервис для наложения видео-контента на напечатанные изображения через браузер, без установки приложений.

## 🎯 Описание проекта

ARgument - это платформа для создания интерактивного дополненного реальности контента. Пользователи могут загружать изображения и видео, генерировать AR-маркеры и делиться WebAR ссылками, которые позволяют зрителям видеть видео, наложенное на напечатанное изображение, прямо через веб-браузер.

### Ключевые возможности

- 📸 **Загрузка изображений** - поддержка JPEG, PNG до 10MB
- 🎬 **Загрузка видео** - поддержка MP4, WebM, MOV до 100MB
- 🎯 **Автоматическая генерация AR-маркеров** с оценкой качества
- 🔗 **Генерация уникальных WebAR ссылок** с QR-кодами
- 📊 **Детальная аналитика** просмотров и взаимодействий
- 🖥️ **Интуитивный Dashboard** для управления проектами
- 👁️ **WebAR Viewer** с real-time video overlay
- 🔐 **Защита ссылок** паролем и ограничениями доступа
- 📱 **Кросс-платформенность** - работает на iOS, Android, Desktop

## 📚 Документация

- **[TZ.md](./TZ.md)** - Полное техническое задание
- **[API_SPEC.yaml](./API_SPEC.yaml)** - OpenAPI 3.0 спецификация
- **[DATABASE_SCHEMA.sql](./DATABASE_SCHEMA.sql)** - Схема базы данных PostgreSQL
- **[ARCHITECTURE_DIAGRAM.md](./ARCHITECTURE_DIAGRAM.md)** - Диаграммы архитектуры
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Инструкции по развертыванию

## 🏗️ Архитектура

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Browser   │────▶│   Next.js   │────▶│   NestJS    │
│  (AR.js)    │     │  Dashboard  │     │   Backend   │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                                │
                    ┌───────────────────────────┼───────┐
                    │                           │       │
              ┌─────▼─────┐          ┌─────────▼─┐  ┌──▼────┐
              │PostgreSQL │          │   Redis   │  │  S3   │
              │    DB     │          │Queue/Cache│  │Storage│
              └───────────┘          └───────────┘  └───────┘
```

### Tech Stack

**Backend:**
- NestJS (TypeScript)
- PostgreSQL 15+ (Primary database)
- Redis 7+ (Cache & Queue)
- TypeORM / Prisma (ORM)
- Bull (Job queue)
- Sharp (Image processing)
- FFmpeg (Video processing)
- OpenCV (Marker generation)

**Frontend:**
- Next.js 14+ (React)
- TypeScript
- Tailwind CSS + shadcn/ui
- TanStack Query (React Query)
- Zustand / Redux Toolkit
- React Hook Form + Zod

**WebAR:**
- AR.js (Marker tracking)
- Three.js / Babylon.js (3D rendering)
- WebRTC (Camera access)

**Infrastructure:**
- Docker + Docker Compose
- AWS ECS/EC2 или Kubernetes
- CloudFront (CDN)
- GitHub Actions (CI/CD)

## 🚀 Быстрый старт

### Требования

- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- Docker (опционально)

### Установка (Local Development)

1. **Клонировать репозиторий**
```bash
git clone https://github.com/your-org/argument.git
cd argument
```

2. **Установить зависимости**
```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

3. **Настроить environment variables**

Скопировать `.env.example` в `.env` и заполнить:

```bash
# Backend
cp backend/.env.example backend/.env

# Frontend
cp frontend/.env.example frontend/.env.local
```

4. **Запустить базы данных (Docker)**
```bash
docker-compose -f docker-compose.dev.yml up -d postgres redis minio
```

5. **Выполнить миграции**
```bash
cd backend
npm run migration:run
```

6. **Запустить приложение**
```bash
# Backend API
cd backend
npm run start:dev

# Frontend Dashboard
cd frontend
npm run dev

# Workers (в отдельном терминале)
cd backend
npm run worker:dev
```

7. **Открыть браузер**
- Dashboard: http://localhost:3001
- API: http://localhost:3000
- API Docs: http://localhost:3000/api/docs

### Установка (Docker Compose)

```bash
# Создать .env файл
cp .env.example .env

# Запустить все сервисы
docker-compose up -d

# Выполнить миграции
docker-compose exec api npm run migration:run

# Просмотр логов
docker-compose logs -f
```

## 📖 API Documentation

API следует REST принципам и полностью документирован в OpenAPI 3.0 формате.

### Основные endpoints:

- `POST /api/v1/auth/register` - Регистрация
- `POST /api/v1/auth/login` - Вход
- `GET /api/v1/projects` - Список проектов
- `POST /api/v1/projects` - Создать проект
- `POST /api/v1/images/upload` - Загрузить изображение
- `POST /api/v1/videos/upload` - Загрузить видео
- `POST /api/v1/markers/generate` - Сгенерировать маркер
- `GET /api/v1/projects/{id}/links` - Получить WebAR ссылки
- `POST /api/v1/analytics/track` - Отследить событие

Полная спецификация: [API_SPEC.yaml](./API_SPEC.yaml)

### Аутентификация

API использует JWT Bearer tokens:

```bash
# Получить токен
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Использовать токен
curl http://localhost:3000/api/v1/projects \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🧪 Тестирование

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov

# Load testing
npm run test:load
```

### Test Coverage Targets

- Unit tests: 80%+ coverage
- Integration tests: критические API endpoints
- E2E tests: основные user flows
- Performance tests: 1000+ concurrent users

## 📊 Мониторинг

### Health Check

```bash
curl http://localhost:3000/health
```

### Metrics

- Prometheus metrics: http://localhost:3000/metrics
- Grafana dashboards: http://localhost:3000/grafana

### Logging

Логи доступны через:
- Console (development)
- CloudWatch (AWS production)
- ELK Stack (optional)

## 🔒 Безопасность

- ✅ HTTPS/TLS enforcement
- ✅ JWT authentication с коротким TTL
- ✅ Password hashing (bcrypt, cost 12)
- ✅ Rate limiting (100 req/min per user)
- ✅ Input validation & sanitization
- ✅ CORS policy
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CSRF tokens
- ✅ File upload validation

## 🌍 Deployment

### Production Deployment (AWS)

Полная инструкция: [DEPLOYMENT.md](./DEPLOYMENT.md)

**Быстрое развертывание:**

```bash
# Настроить AWS CLI
aws configure

# Деплой через Terraform
cd infrastructure
terraform init
terraform plan
terraform apply

# Или через CloudFormation
aws cloudformation create-stack --stack-name argument --template-body file://cloudformation.yml
```

### Docker Production

```bash
# Build images
docker build -t argument-api ./backend
docker build -t argument-frontend ./frontend

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

## 📈 Производительность

### Benchmarks

- API Response Time: < 200ms (p95)
- Page Load Time: < 2s
- WebAR Initialization: < 3s
- Marker Detection: < 100ms
- Video Overlay FPS: 30+

### Scalability

- Concurrent AR Sessions: 1000+
- API Requests: 10,000+ req/min
- Image Processing: 100+ images/min
- Video Processing: 50+ videos/min

## 🤝 Contributing

Мы приветствуем вклад в проект! Пожалуйста, следуйте этим шагам:

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

### Code Style

- TypeScript для всего кода
- ESLint + Prettier для форматирования
- Conventional Commits для сообщений коммитов
- Тесты для новых features

## 📝 License

Этот проект лицензирован под MIT License - см. [LICENSE](LICENSE) файл.

## 👥 Team

- **Product Owner**: [Name]
- **Tech Lead**: [Name]
- **Backend Team**: [Names]
- **Frontend Team**: [Names]
- **DevOps**: [Name]

## 📧 Контакты

- **Email**: support@argument.io
- **Website**: https://argument.io
- **Issues**: https://github.com/your-org/argument/issues
- **Discussions**: https://github.com/your-org/argument/discussions

## 🗺️ Roadmap

### Phase 1: MVP (Q1 2024) ✅
- [x] Core API
- [x] Basic WebAR Viewer
- [x] Image/Video upload
- [x] Marker generation
- [x] Dashboard UI

### Phase 2: Core Features (Q2 2024)
- [ ] Advanced analytics
- [ ] Admin panel
- [ ] Email notifications
- [ ] Social sharing
- [ ] QR codes

### Phase 3: Enhancement (Q3 2024)
- [ ] Custom domains
- [ ] Password-protected links
- [ ] Team collaboration
- [ ] Advanced video controls
- [ ] Webhook integrations

### Phase 4: Premium Features (Q4 2024)
- [ ] White labeling
- [ ] API access for developers
- [ ] Advanced marker types
- [ ] 3D model support
- [ ] Billing & subscriptions

## 🎓 Resources

- [AR.js Documentation](https://ar-js-org.github.io/AR.js-Docs/)
- [Three.js Documentation](https://threejs.org/docs/)
- [NestJS Documentation](https://docs.nestjs.com/)
- [Next.js Documentation](https://nextjs.org/docs)

---

**Built with ❤️ by the ARgument Team**
