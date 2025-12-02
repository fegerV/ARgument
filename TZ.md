# Техническое Задание: ARgument WebAR Service

## 1. Обзор проекта

### 1.1 Назначение
ARgument - это WebAR сервис для наложения видео-контента на напечатанные изображения с использованием технологии дополненной реальности. Пользователи могут загружать изображения и видео, генерировать AR-маркеры и делиться ссылками для просмотра AR-контента через веб-браузер без необходимости установки приложения.

### 1.2 Целевая аудитория
- Маркетологи и рекламные агентства
- Создатели контента и креативщики
- Образовательные учреждения
- Музеи и выставочные центры
- Розничные компании

### 1.3 Основные возможности
- Загрузка изображений для использования в качестве AR-маркеров
- Загрузка видео для наложения на маркеры
- Автоматическая генерация AR-маркеров
- Генерация уникальных WebAR ссылок для просмотра
- Просмотр AR-контента через веб-браузер
- Аналитика просмотров и взаимодействий
- Управление проектами и медиафайлами
- Административная панель

## 2. Архитектура системы

### 2.1 Общая архитектура

Система состоит из следующих компонентов:

1. **Backend API** - REST API для управления проектами, обработки файлов и аналитики
2. **Frontend Dashboard** - веб-интерфейс для создания и управления проектами
3. **WebAR Viewer** - специализированный веб-интерфейс для просмотра AR-контента
4. **Database** - PostgreSQL для хранения данных
5. **Storage** - файловое хранилище (S3/MinIO) для изображений и видео
6. **Cache** - Redis для кэширования сессий и данных аналитики
7. **Queue** - система очередей (Bull/RabbitMQ) для асинхронной обработки

### 2.2 Tech Stack

**Backend:**
- Framework: NestJS (TypeScript)
- ORM: TypeORM или Prisma
- Authentication: Passport.js + JWT
- File Processing: Sharp (images), FFmpeg (videos)
- Marker Generation: OpenCV (через bindings или microservice)
- Queue: Bull + Redis
- Validation: class-validator, class-transformer

**Frontend:**
- Framework: Next.js 14+ (React)
- State Management: Zustand или Redux Toolkit
- UI Library: Tailwind CSS + shadcn/ui
- Forms: React Hook Form + Zod
- API Client: TanStack Query (React Query)
- Charts: Recharts или Chart.js

**WebAR:**
- AR Framework: AR.js или 8th Wall
- 3D Rendering: Three.js или Babylon.js
- Video Processing: HTML5 Video API
- Camera Access: WebRTC getUserMedia API

**Database:**
- Primary: PostgreSQL 15+
- Cache: Redis 7+
- Search (optional): Elasticsearch

**DevOps:**
- Containerization: Docker + Docker Compose
- CI/CD: GitHub Actions
- Infrastructure: AWS (ECS/EC2) или Kubernetes
- Monitoring: Prometheus + Grafana
- Logging: ELK Stack или Loki

### 2.3 Data Flow

```
1. Пользователь создает проект
   ↓
2. Загружает изображение (будущий маркер)
   ↓
3. Система обрабатывает изображение (оптимизация, извлечение метаданных)
   ↓
4. Загружает видео для наложения
   ↓
5. Система обрабатывает видео (транскодинг, сжатие)
   ↓
6. Генерируется AR-маркер (feature extraction)
   ↓
7. Создается уникальная WebAR ссылка
   ↓
8. Пользователь печатает изображение и распространяет
   ↓
9. Зритель открывает ссылку в браузере
   ↓
10. WebAR Viewer инициализируется
   ↓
11. Камера сканирует напечатанное изображение
   ↓
12. Маркер распознается
   ↓
13. Видео накладывается и воспроизводится
   ↓
14. Система собирает аналитику
```

## 3. Функциональные требования

### 3.1 Аутентификация и авторизация

**FR-1.1: Регистрация пользователей**
- Email + password регистрация
- Валидация email (confirmation link)
- Проверка сложности пароля
- Согласие с Terms of Service

**FR-1.2: Вход в систему**
- Email + password authentication
- "Remember me" функциональность
- Password reset через email
- OAuth2 интеграция (Google, GitHub - optional)

**FR-1.3: Управление профилем**
- Обновление информации профиля
- Смена пароля
- Удаление аккаунта
- Просмотр использования квоты

**FR-1.4: Роли и права доступа**
- **User** - базовая роль, может создавать проекты
- **Admin** - административный доступ, управление всеми ресурсами
- **Viewer** - только просмотр AR-контента (без входа)

### 3.2 Управление проектами

**FR-2.1: Создание проекта**
- Имя проекта (required)
- Описание (optional)
- Теги для организации (optional)
- Настройки приватности (public/private)

**FR-2.2: Список проектов**
- Отображение всех проектов пользователя
- Сортировка (по дате, имени, просмотрам)
- Фильтрация по тегам, статусу
- Поиск по имени/описанию
- Pagination

**FR-2.3: Редактирование проекта**
- Обновление метаданных
- Добавление/удаление изображений
- Добавление/удаление видео
- Управление маркерами

**FR-2.4: Удаление проекта**
- Soft delete с возможностью восстановления (30 дней)
- Удаление всех связанных ресурсов
- Подтверждение действия

### 3.3 Работа с изображениями

**FR-3.1: Загрузка изображений**
- Поддерживаемые форматы: JPEG, PNG
- Максимальный размер: 10MB
- Минимальное разрешение: 640x480
- Drag & drop интерфейс
- Multiple file upload

**FR-3.2: Обработка изображений**
- Автоматическая оптимизация размера
- Генерация thumbnails
- Извлечение метаданных (EXIF)
- Проверка качества для AR-tracking
- Предварительный просмотр

**FR-3.3: Управление изображениями**
- Просмотр списка загруженных изображений
- Удаление изображений
- Замена изображений
- Скачивание оригиналов

### 3.4 Работа с видео

**FR-4.1: Загрузка видео**
- Поддерживаемые форматы: MP4, WebM, MOV
- Максимальный размер: 100MB
- Максимальная длительность: 2 минуты
- Drag & drop интерфейс

**FR-4.2: Обработка видео**
- Автоматический транскодинг в WebM/MP4
- Сжатие для оптимальной загрузки
- Генерация превью (poster image)
- Извлечение метаданных (duration, resolution, codec)

**FR-4.3: Управление видео**
- Просмотр списка загруженных видео
- Превью с воспроизведением
- Удаление видео
- Замена видео
- Скачивание обработанных версий

### 3.5 Генерация AR-маркеров

**FR-5.1: Создание маркера**
- Автоматическое извлечение особенностей (features) из изображения
- Генерация NFT (Natural Feature Tracking) маркера
- Валидация качества маркера (tracking score)
- Предупреждения о низком качестве изображения

**FR-5.2: Привязка видео к маркеру**
- Связывание одного или нескольких видео с маркером
- Настройка параметров наложения:
  - Масштаб видео относительно маркера
  - Позиция (центр, offset)
  - Rotation (опционально)
  - Opacity (опционально)
  - Autoplay настройки

**FR-5.3: Тестирование маркера**
- Веб-интерфейс для тестирования распознавания
- Проверка качества tracking
- Симуляция различных условий освещения

### 3.6 WebAR Viewer

**FR-6.1: Инициализация AR-сессии**
- Запрос доступа к камере
- Отображение инструкций для пользователя
- Индикатор загрузки ресурсов
- Fallback для неподдерживаемых браузеров

**FR-6.2: Распознавание маркера**
- Real-time детекция напечатанного изображения
- Отображение рамки вокруг распознанного маркера
- Обработка частичного распознавания
- Tracking stabilization

**FR-6.3: Воспроизведение видео**
- Автоматическое воспроизведение при распознавании
- Pause при потере tracking
- Resume при восстановлении tracking
- Плавные переходы

**FR-6.4: Управление воспроизведением**
- Play/Pause кнопка
- Volume control
- Fullscreen mode (опционально)
- Replay кнопка
- Progress bar

**FR-6.5: Responsive design**
- Адаптация под различные размеры экранов
- Portrait и landscape ориентации
- Touch-friendly controls
- Оптимизация для мобильных устройств

### 3.7 Генерация и управление ссылками

**FR-7.1: Создание WebAR ссылки**
- Автоматическая генерация уникального короткого URL
- QR-код для ссылки
- Custom slug (optional, для premium)
- Expiration date (optional)

**FR-7.2: Настройки ссылки**
- Enable/disable ссылки
- Password protection (optional, premium)
- Access limit (максимум просмотров)
- Geographic restrictions (optional, premium)

**FR-7.3: Sharing ссылки**
- Copy to clipboard
- Share via email
- Social media buttons (Facebook, Twitter, LinkedIn)
- Embed code (iframe)

### 3.8 Аналитика

**FR-8.1: Сбор событий**
- view_started - начало AR-сессии
- marker_detected - первое распознавание маркера
- video_started - начало воспроизведения видео
- video_paused - пауза
- video_completed - просмотр до конца
- video_replayed - повторное воспроизведение
- session_ended - завершение сессии

**FR-8.2: Метрики проекта**
- Общее количество просмотров
- Уникальные зрители (по IP/fingerprint)
- Среднее время просмотра
- Drop-off rate
- География просмотров (по IP)
- Device/browser распределение

**FR-8.3: Дашборд аналитики**
- Real-time счетчик просмотров
- Графики по датам
- Тепловая карта активности
- Таблица детальных сессий
- Export данных (CSV, JSON)

**FR-8.4: Сравнение проектов**
- Side-by-side comparison
- Performance benchmarking
- Engagement metrics

### 3.9 Административная панель

**FR-9.1: Управление пользователями**
- Список всех пользователей
- Поиск и фильтрация
- Просмотр активности пользователя
- Блокировка/разблокировка пользователей
- Изменение ролей
- Удаление аккаунтов

**FR-9.2: Модерация контента**
- Просмотр всех проектов
- Флаг неприемлемого контента
- Удаление проектов
- Статистика по использованию хранилища

**FR-9.3: Системная статистика**
- Total users, projects, views
- Storage usage
- API request metrics
- Error rates
- Performance metrics

**FR-9.4: Управление квотами**
- Просмотр и изменение лимитов пользователей
- Создание premium планов
- Billing интеграция (future)

## 4. Нефункциональные требования

### 4.1 Производительность

**NFR-1: Response Time**
- API endpoints: < 200ms (p95)
- Page load: < 2s (initial load)
- WebAR initialization: < 3s
- Marker detection latency: < 100ms
- Video overlay rendering: 30+ FPS

**NFR-2: Throughput**
- Поддержка 1000+ concurrent AR sessions
- API: 10,000+ requests per minute
- Image processing: 100+ images per minute
- Video processing: 50+ videos per minute (в очереди)

**NFR-3: Scalability**
- Horizontal scaling для API servers
- Database read replicas
- CDN для статических ресурсов и видео
- Auto-scaling при увеличении нагрузки

### 4.2 Надежность

**NFR-4: Availability**
- Uptime: 99.9% (SLA)
- Graceful degradation при частичных сбоях
- Health checks для всех сервисов

**NFR-5: Data Integrity**
- ACID транзакции в базе данных
- Backup ежедневно с retention 30 дней
- Point-in-time recovery возможность

**NFR-6: Error Handling**
- Retry механизмы для failed jobs
- Dead letter queue для критических ошибок
- User-friendly error messages

### 4.3 Безопасность

**NFR-7: Authentication & Authorization**
- JWT tokens с expiration (15 min access, 7 days refresh)
- Secure password hashing (bcrypt, cost factor 10+)
- RBAC для всех endpoints
- CSRF protection

**NFR-8: Data Protection**
- HTTPS enforcement (TLS 1.3)
- Encryption at rest для sensitive data
- Secure file uploads (virus scanning, type validation)
- Rate limiting (100 requests per minute per user)

**NFR-9: Privacy**
- GDPR compliance
- Data anonymization для аналитики
- User data export/deletion на запрос
- Cookie consent management

### 4.4 Совместимость

**NFR-10: Browser Support**
- Chrome 90+ (desktop, mobile)
- Firefox 88+ (desktop, mobile)
- Safari 14+ (desktop, iOS)
- Edge 90+
- WebXR API / WebRTC support required

**NFR-11: Device Support**
- Desktop: Windows, macOS, Linux
- Mobile: iOS 14+, Android 10+
- Minimum camera resolution: 720p
- Orientation: portrait and landscape

### 4.5 Удобство использования

**NFR-12: UX**
- Интуитивный интерфейс
- Onboarding tutorial для новых пользователей
- Contextual help и tooltips
- Error prevention и validation

**NFR-13: Accessibility**
- WCAG 2.1 AA compliance
- Keyboard navigation
- Screen reader support
- Color contrast соответствие

### 4.6 Поддерживаемость

**NFR-14: Code Quality**
- TypeScript для type safety
- ESLint + Prettier для code style
- 80%+ test coverage
- Comprehensive API documentation

**NFR-15: Monitoring**
- Application Performance Monitoring (APM)
- Error tracking (Sentry или аналог)
- Log aggregation
- Alerting для критических событий

**NFR-16: Documentation**
- API documentation (OpenAPI/Swagger)
- User guides
- Developer documentation
- Deployment guides

## 5. Ограничения и квоты

### 5.1 Пользовательские лимиты (Free Tier)
- Проекты: 5 активных проектов
- Storage: 500MB
- Изображения: 640x480 минимум, 4096x4096 максимум, 10MB per file
- Видео: до 2 минут, 100MB per file
- AR sessions: 1000 просмотров в месяц
- API rate limit: 100 req/min

### 5.2 Пользовательские лимиты (Premium Tier - future)
- Проекты: unlimited
- Storage: 10GB
- Видео: до 5 минут, 500MB per file
- AR sessions: unlimited
- Custom domains
- Priority processing
- Analytics export

### 5.3 Технические ограничения
- Marker detection accuracy: зависит от качества печати и освещения
- Video codec support: зависит от браузера
- Camera access: требует HTTPS и user permission
- Concurrent connections: ограничено инфраструктурой

## 6. Этапы разработки

### Phase 1: MVP (8-10 недель)
1. Backend API setup (NestJS, PostgreSQL, TypeORM)
2. Authentication & authorization
3. Basic CRUD для projects, images, videos
4. Image upload & processing
5. Video upload & basic processing
6. Simple marker generation (AR.js)
7. Basic WebAR viewer
8. Frontend dashboard (Next.js)
9. Deployment setup (Docker, CI/CD)

### Phase 2: Core Features (6-8 недель)
1. Advanced marker generation (quality scoring)
2. Video transcoding & optimization
3. Analytics implementation
4. Admin panel
5. Улучшенный WebAR viewer (controls, UI)
6. Testing & QA
7. Performance optimization

### Phase 3: Enhancement (4-6 недель)
1. Advanced analytics & reporting
2. Social sharing features
3. QR code generation
4. Email notifications
5. Storage optimization
6. CDN integration
7. Load testing & scaling

### Phase 4: Premium Features (опционально)
1. Custom domains
2. Password-protected links
3. White labeling
4. Advanced analytics
5. Billing integration
6. Team collaboration features

## 7. Риски и митигация

### Технические риски
1. **Marker detection accuracy**
   - Риск: низкое качество распознавания
   - Митигация: тестирование различных библиотек (AR.js, 8th Wall), рекомендации по печати

2. **Browser compatibility**
   - Риск: WebXR/WebRTC не поддерживается на всех устройствах
   - Митигация: fallback UI, четкие system requirements

3. **Video processing performance**
   - Риск: длительная обработка больших видео
   - Митигация: async queues, progress indicators, оптимизация FFmpeg

4. **Scalability bottlenecks**
   - Риск: перегрузка при росте пользователей
   - Митигация: load testing, auto-scaling, CDN

### Бизнес риски
1. **User adoption**
   - Риск: сложность использования
   - Митигация: onboarding, tutorials, customer support

2. **Storage costs**
   - Риск: высокие расходы на хранение
   - Митигация: квоты, сжатие, lifecycle policies

## 8. Зависимости

### Внешние сервисы
- Email delivery: SendGrid / AWS SES
- Storage: AWS S3 / MinIO
- CDN: CloudFront / Cloudflare
- Monitoring: Datadog / New Relic (optional)

### Библиотеки и фреймворки
- См. раздел 2.2 Tech Stack

## 9. Критерии приемки

1. ✅ Пользователь может зарегистрироваться и войти
2. ✅ Пользователь может создать проект
3. ✅ Пользователь может загрузить изображение (JPEG/PNG)
4. ✅ Пользователь может загрузить видео (MP4)
5. ✅ Система генерирует AR-маркер из изображения
6. ✅ Система создает уникальную WebAR ссылку
7. ✅ Зритель может открыть ссылку и увидеть AR-контент
8. ✅ Видео накладывается на распознанное изображение
9. ✅ Система собирает аналитику просмотров
10. ✅ Пользователь может просмотреть статистику проекта
11. ✅ Admin может управлять пользователями
12. ✅ Все API endpoints работают согласно спецификации
13. ✅ Unit tests покрытие > 80%
14. ✅ E2E tests для основных user flows
15. ✅ Performance metrics соответствуют NFR

## 10. Дополнительные материалы

- API Specification: см. `API_SPEC.yaml`
- Database Schema: см. `DATABASE_SCHEMA.sql`
- Deployment Guide: см. `DEPLOYMENT.md`
- Architecture Diagrams: см. `ARCHITECTURE_DIAGRAM.md`

---

**Версия документа:** 1.0  
**Дата:** 2024  
**Статус:** Draft for Development
