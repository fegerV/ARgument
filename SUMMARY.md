# ARgument WebAR Service - Документация: Краткая сводка

## 📋 Обзор документации

Этот репозиторий содержит комплексное техническое задание для WebAR сервиса **ARgument** - платформы для наложения видео-контента на напечатанные изображения с использованием технологии дополненной реальности.

## 📁 Структура документации

### 1. **README.md** - Вводный документ
- Описание проекта и ключевые возможности
- Быстрый старт для разработчиков
- Tech stack и архитектура (краткая)
- Инструкции по установке и запуску
- API documentation overview
- Roadmap проекта

**Целевая аудитория**: Разработчики, PM, новые участники команды

### 2. **TZ.md** - Полное техническое задание
- Детальное описание назначения системы
- Архитектура системы и tech stack
- Функциональные требования (FR-1 до FR-9)
- Нефункциональные требования (NFR)
- Ограничения и квоты
- Этапы разработки (MVP → Phase 4)
- Риски и митигация
- Критерии приемки

**Целевая аудитория**: Разработчики, аналитики, архитекторы, PM

### 3. **API_SPEC.yaml** - OpenAPI 3.0 спецификация
- Полная спецификация REST API
- 30+ endpoints с примерами
- Схемы данных (schemas)
- Аутентификация и авторизация
- Примеры запросов и ответов
- Коды ошибок

**Целевая аудитория**: Backend разработчики, Frontend разработчики, QA

**Группы endpoints**:
- `/auth/*` - Аутентификация (регистрация, вход, восстановление пароля)
- `/users/*` - Управление пользователями
- `/projects/*` - CRUD проектов
- `/images/*` - Загрузка и управление изображениями
- `/videos/*` - Загрузка и обработка видео
- `/markers/*` - Генерация AR-маркеров
- `/links/*` - WebAR ссылки и QR-коды
- `/analytics/*` - Аналитика и трекинг
- `/admin/*` - Административные функции

### 4. **DATABASE_SCHEMA.sql** - Схема базы данных
- 13 таблиц (users, projects, images, videos, markers, links, sessions, analytics, etc.)
- Индексы для оптимизации производительности
- Triggers для автоматизации
- Functions для бизнес-логики
- Views для удобства запросов
- Enums для типизации
- Comments на таблицы и колонки

**Целевая аудитория**: Backend разработчики, DBA

**Основные таблицы**:
- `users` - пользователи и аутентификация
- `user_quotas` - квоты и лимиты
- `projects` - AR проекты
- `images` - загруженные изображения
- `videos` - загруженные видео
- `markers` - AR-маркеры
- `links` - публичные WebAR ссылки
- `sessions` - сессии просмотра
- `analytics_events` - события аналитики
- `analytics_daily` - агрегированная аналитика

### 5. **ARCHITECTURE_DIAGRAM.md** - Архитектурные диаграммы
- 9 диаграмм различных аспектов системы
- Mermaid и ASCII диаграммы
- Визуализация компонентов и их взаимодействия

**Диаграммы**:
1. System Architecture Overview
2. Component Architecture
3. Data Flow Diagrams (4 сценария)
4. Database Entity Relationship Diagram
5. Deployment Architecture (AWS + Docker)
6. Security Architecture
7. Monitoring & Observability Stack
8. Scalability Architecture
9. CI/CD Pipeline

**Целевая аудитория**: Архитекторы, Senior разработчики, DevOps

### 6. **DEPLOYMENT.md** - Инструкции по развертыванию
- Пошаговые инструкции для local development
- Docker Compose setup
- Production deployment на AWS
- Database migrations
- Monitoring setup
- Backup и recovery
- Troubleshooting guide
- Scaling guidelines

**Целевая аудитория**: DevOps, Backend разработчики

**Разделы**:
- Prerequisites
- Local Development Setup
- Environment Variables (полная справка)
- Docker Deployment (docker-compose.yml)
- Production Deployment (AWS ECS, RDS, S3, CloudFront)
- Database Migrations
- Monitoring (Prometheus, Grafana, ELK)
- Backup & Recovery
- Troubleshooting (частые проблемы)
- Scaling (horizontal и vertical)

## 🎯 Как использовать документацию

### Для разработчиков (начало работы):
1. **README.md** → Понять, что такое проект
2. **DEPLOYMENT.md** (Local Setup) → Настроить окружение
3. **API_SPEC.yaml** → Изучить API
4. **DATABASE_SCHEMA.sql** → Понять структуру данных

### Для архитекторов:
1. **TZ.md** → Полное понимание требований
2. **ARCHITECTURE_DIAGRAM.md** → Визуализация архитектуры
3. **API_SPEC.yaml** → Контракты API
4. **DATABASE_SCHEMA.sql** → Модель данных

### Для DevOps:
1. **DEPLOYMENT.md** → Все инструкции по деплою
2. **ARCHITECTURE_DIAGRAM.md** (Deployment section) → Инфраструктура
3. **TZ.md** (NFR section) → Требования к производительности

### Для PM/BA:
1. **README.md** → Обзор проекта
2. **TZ.md** → Функциональные требования
3. **README.md** (Roadmap) → План развития

### Для QA:
1. **API_SPEC.yaml** → Спецификация API для тестирования
2. **TZ.md** (Критерии приемки) → Test cases
3. **DATABASE_SCHEMA.sql** → Test data setup

## 📊 Ключевые метрики проекта

### Tech Stack
- **Backend**: NestJS + TypeScript + PostgreSQL + Redis
- **Frontend**: Next.js + React + TypeScript + Tailwind CSS
- **WebAR**: AR.js + Three.js
- **Infrastructure**: Docker + AWS ECS + S3 + CloudFront

### Scope
- **API Endpoints**: 30+
- **Database Tables**: 13
- **User Roles**: 3 (user, admin, viewer)
- **Development Phases**: 4 (MVP → Premium)
- **Estimated Timeline**: 8-10 недель для MVP

### Features
- ✅ Аутентификация и авторизация
- ✅ Управление проектами
- ✅ Загрузка изображений и видео
- ✅ Генерация AR-маркеров
- ✅ WebAR Viewer
- ✅ Аналитика и трекинг
- ✅ Admin panel
- ✅ QR-коды для ссылок

### Performance Targets
- API Response: < 200ms (p95)
- Page Load: < 2s
- WebAR Init: < 3s
- Marker Detection: < 100ms
- Concurrent Users: 1000+

### Quality Gates
- Unit Test Coverage: 80%+
- Integration Tests: All critical endpoints
- E2E Tests: Main user flows
- Security: OWASP Top 10 compliance
- Performance: Load testing with 1000+ concurrent users

## 🔄 Workflow разработки

```
1. Requirements → TZ.md
2. API Design → API_SPEC.yaml
3. Database Design → DATABASE_SCHEMA.sql
4. Architecture → ARCHITECTURE_DIAGRAM.md
5. Development → Code
6. Deployment → DEPLOYMENT.md
7. Monitoring → Built-in metrics
```

## 📝 Следующие шаги

### Для начала разработки:

1. **Setup Repository Structure**
   ```
   /backend          - NestJS API
   /frontend         - Next.js Dashboard
   /worker           - Background workers
   /infrastructure   - Terraform/CloudFormation
   /docs             - Additional documentation
   ```

2. **Initialize Projects**
   ```bash
   # Backend
   npx @nestjs/cli new backend
   
   # Frontend
   npx create-next-app@latest frontend --typescript --tailwind
   ```

3. **Setup Database**
   ```bash
   # Run schema
   psql -U postgres -d argument < DATABASE_SCHEMA.sql
   ```

4. **Implement Core Features** (по приоритету)
   - Phase 1: Authentication + Projects CRUD
   - Phase 2: Image/Video Upload + Processing
   - Phase 3: Marker Generation
   - Phase 4: WebAR Viewer
   - Phase 5: Analytics
   - Phase 6: Admin Panel

5. **Setup CI/CD**
   - GitHub Actions workflows
   - Automated testing
   - Docker builds
   - Deployment pipelines

## ❓ FAQ

### Q: Почему выбран NestJS?
**A**: Структурированный фреймворк с TypeScript, отличная поддержка микросервисов, встроенная валидация, хорошо масштабируется.

### Q: Почему AR.js, а не 8th Wall?
**A**: AR.js - бесплатная open-source библиотека, 8th Wall - коммерческая ($99+/мес). Для MVP достаточно AR.js.

### Q: Нужен ли Kubernetes?
**A**: Для MVP - нет, достаточно Docker Compose или AWS ECS. Kubernetes можно рассмотреть при scaling.

### Q: Как обрабатывать большие видео?
**A**: Async queue (Bull + Redis) для фоновой обработки, FFmpeg для транскодинга, CDN для доставки.

### Q: Как хранить видео?
**A**: S3 (prod) или MinIO (dev) для object storage, CDN для distribution.

## 🤝 Контрибьюция в документацию

Если вы нашли ошибки или хотите улучшить документацию:

1. Создайте issue с описанием проблемы
2. Или создайте PR с исправлениями
3. Следуйте стилю существующей документации

## 📞 Поддержка

- **Technical Questions**: tech@argument.io
- **Documentation Issues**: docs@argument.io
- **General Support**: support@argument.io

---

**Версия документации**: 1.0  
**Дата создания**: 2024  
**Статус**: Ready for Development

**Подготовлено для команды разработки ARgument**
