# DevOps Test Task - Simple Web Application with Docker

Простое веб-приложение, развернутое в Docker контейнерах с nginx в качестве reverse proxy.

## Архитектура

```
┌─────────────────────────────────────────────┐
│            Host (localhost)                 │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │     Docker Network: app-network       │  │
│  │                                       │  │
│  │  ┌──────────────┐   ┌──────────────┐ │  │
│  │  │              │   │              │ │  │
│  │  │  nginx:80    │──→│ backend:8080 │ │  │
│  │  │  (reverse    │   │ (Python HTTP)│ │  │
│  │  │   proxy)     │   │              │ │  │
│  │  │              │   │              │ │  │
│  │  └──────────────┘   └──────────────┘ │  │
│  │        ↑                              │  │
│  └────────┼──────────────────────────────┘  │
│           │                                 │
│      :80  │  (published)                    │
│                                             │
└─────────────────────────────────────────────┘
```

## Компоненты

### Backend
- **Язык:** Python 3.11
- **Фреймворк:** `http.server` (встроенный модуль)
- **Порт:** 8080 (только внутри Docker сети)
- **Ответ:** "Hello from Effective Mobile!" на GET /

### Nginx
- **Образ:** `nginx:1.25-alpine`
- **Порт:** 80 (опубликован на хост)
- **Роль:** Reverse proxy к backend
- **Конфигурация:** `./nginx/nginx.conf`

## Требования

- Docker 20.10+
- Docker Compose 2.0+

## Установка и запуск

### 1. Клонирование репозитория

```bash
git clone https://github.com/<your-username>/devops-test-task.git
cd devops-test-task
```

### 2. Запуск контейнеров

```bash
docker-compose up -d
```

Команда запустит:
- `devops-backend` - Python приложение на порту 8080
- `devops-nginx` - Nginx reverse proxy на порту 80

### 3. Проверка статуса

```bash
docker-compose ps
```

Оба контейнера должны иметь статус "healthy" после инициализации.

## Проверка результата

### Тестирование локально

```bash
curl http://localhost
```

**Ожидаемый ответ:**
```
Hello from Effective Mobile!
```

### Альтернативные способы проверки

Через wget:
```bash
wget -q -O - http://localhost
```

Через Docker Compose:
```bash
docker-compose exec nginx wget -q -O - http://backend:8080/
```

Просмотр логов:
```bash
docker-compose logs -f
```

## Как работает схема

1. **Запрос от пользователя:** `curl http://localhost` отправляет HTTP запрос на порт 80
2. **Nginx обработка:** Nginx получает запрос и смотрит конфигурацию
3. **Upstream resolution:** В `nginx.conf` определен `upstream backend` с адресом `backend:8080`
4. **Service discovery:** Docker DNS разрешает имя сервиса `backend` в IP контейнера
5. **Проксирование:** Nginx проксирует запрос к контейнеру backend на порт 8080
6. **Ответ приложения:** Python сервер отвечает "Hello from Effective Mobile!"
7. **Возврат ответа:** Nginx возвращает ответ обратно клиенту

## Остановка

```bash
docker-compose down
```

## Очистка (включая образы)

```bash
docker-compose down --rmi all
```

## Технологии

- **Docker** - контейнеризация
- **Docker Compose** - оркестрация контейнеров
- **Python 3.11** - backend приложение
- **Nginx 1.25 Alpine** - reverse proxy
- **HTTP/1.1** - протокол взаимодействия

## Особенности реализации

### Безопасность
- Backend запускается от non-root пользователя (appuser)
- Backend не опубликован на хост - доступен только из Docker сети
- Nginx конфигурация подключена как read-only volume

### Оптимизация
- Использование `python:3.11-slim` для минимизации размера образа
- Multi-stage build для базовой оптимизации
- Alpine Linux для nginx (легкий образ)
- Автоматическое масштабирование worker процессов

### Надежность
- Health checks для обоих сервисов
- Зависимость nginx от healthy backend (`depends_on`)
- Automatic restart политика (`unless-stopped`)
- Explicit network (`app-network`)

### Конфигурация
- Правильная передача заголовков (Host, X-Real-IP, X-Forwarded-For)
- Оптимальные timeout'ы
- Graceful shutdown

## Структура проекта

```
devops-test-task/
├── backend/
│   ├── Dockerfile       # Конфигурация контейнера backend
│   └── app.py          # Python HTTP сервер
├── nginx/
│   └── nginx.conf      # Конфигурация nginx reverse proxy
├── docker-compose.yml  # Оркестрация контейнеров
├── .gitignore         # Файлы для игнорирования в git
├── README.md          # Этот файл
└── LICENSE            # Лицензия проекта
```

## Решение проблем

### Порт 80 занят

```bash
# Замените порт в docker-compose.yml
# ports:
#   - "8000:80"
docker-compose up -d
curl http://localhost:8000
```

### Backend недоступен из nginx

Проверьте имя сервиса и порт в `nginx.conf`:
```nginx
upstream backend {
    server backend:8080;  # backend - имя сервиса, 8080 - порт
}
```

### Health check не проходит

Проверьте логи:
```bash
docker-compose logs backend
docker-compose logs nginx
```

## Лицензия

MIT

## Автор

DevOps Test Task решение
