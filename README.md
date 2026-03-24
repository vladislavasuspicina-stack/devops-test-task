# DevOps Test Task

Простое веб-приложение с nginx reverse proxy за Docker Compose. Backend на Python, nginx только проксирует запросы.

## Архитектура (как это работает)

```
curl http://localhost
         ↓
Machine:80 → Docker:80 (nginx)
         ↓
nginx читает конфиг и перенаправляет на backend
         ↓
nginx → backend:8080 (Python HTTP server)
         ↓
Python ответит "Hello from Effective Mobile!"
         ↓
nginx передает ответ обратно
```

Docker Compose это всё оркеструет - создает сеть, поднимает контейнеры, дождется пока backend готов.

## Компоненты

### Backend
- **Python 3.11** slim образ (выбрал slim версию - меньше места)
- **http.server** встроенный модуль (не хотелось лишних зависимостей типа Flask)
- Слушает **:8080** но только в docker сети (для nginx видно)
- На **GET /** отвечает текстом "Hello from Effective Mobile!"
- Запускается от обычного пользователя (не root)

### Nginx
- **nginx:1.25-alpine** (alpine - компактный, быстрый)
- Слушает **:80** - это открыто на хост (пользователь видит)
- **Reverse proxy** - направляет запросы на backend через Docker DNS
- Конфиг подключается через volume (читай только)
- Дождется пока backend healthy прежде чем начать работать

## Требования

- Docker (с поддержкой Linux, даже на Windows/Mac значит Docker Desktop)
- Docker Compose v2+
- Минимум 2 Гб free memory (но кстати очень мало весит)

## Установка и запуск

### 1. Клонируем репо

```bash
git clone https://github.com/<your-username>/devops-test-task.git
cd devops-test-task
```

### 2. Поднимаем контейнеры

```bash
docker-compose up -d
```

Добавим `-d` флаг чтоб работал в фоне. Компоуз создаст:
- Backend контейнер (bilding из Dockerfile)
- Nginx контейнер
- Docker сеть
- Volume для конфига nginx

### 3. Ждем когда backend поднялся

```bash
docker-compose ps
```

Оба контейнера должны быть "healthy". Если нет - смотрим логи:

## Проверка

### Основная проверка

```bash
curl http://localhost
```

Должна вернуться строка:
```
Hello from Effective Mobile!
```

Если не поднялось - проверяем логи:
```bash
docker-compose logs
```

### Смотреть логи в реальном времени

```bash
docker-compose logs -f
```

Видно будет и логи nginx и логи Python сервера.

### Проверить конкретный контейнер

```bash
# Только backend
docker-compose logs backend -f

# Только nginx  
docker-compose logs nginx -f
```

## Как работает

**Цепочка запроса:**

1. Пользователь делает `curl http://localhost` (или открывает в браузере)
2. Запрос идет на порт 80 машины
3. Docker перенаправляет на контейнер nginx:80
4. Nginx смотрит конфиг (`nginx/nginx.conf`)
5. В конфиге определен `upstream backend` с адресом `backend:8080`
6. Docker DNS резолвит имя сервиса `backend` в IP контейнера
7. Nginx проксирует запрос внутри docker сети на `backend:8080`
8. Python server получает запрос на `/`, проверяет path и отвечает
9. Ответ идет обратно в nginx
10. Nginx отправляет клиенту

**Зачем это нужно:**
- Backend НЕ виден на машине - это безопасно
- Nginx видит backend по DNS имени (не нужно IP)
- Docker Compose управляет всем (порты, сеть, dependencies)

## Остановка

```bash
docker-compose down
```

Это **не удалит** volume'ы или образы, просто остановит контейнеры.

## Полная очистка

```bash
docker-compose down --rmi all
```

Это удалит и образы и контейнеры и сеть. Данные сохранятся только в volume'ах если они были.

## Технологии

- **Docker** - контейнеризация приложений
- **Docker Compose** - управление контейнерами (оркестрация)
- **Python 3.11** - язык для backend
- **Nginx 1.25** - reverse proxy / веб-сервер
- **Alpine Linux** (в nginx) - мини линукс для контейнеров

## Осбенности (что я учел)

**Безопасность:**
- Backend запускается от обычного юзера `appuser` (не root)
- Backend НЕ открыт на хост вообще
- Nginx конфиг подключен read-only
- Только nginx порт 80 видит машине

**Оптимизация:**
- Slim образ (не full Python, который гораздо больше)
- Alpine для nginx (очень легкий)
- Минимальнах зависимостей

**Надежность:**
- Health checks на обоих контейнерах
- Docker Compose дождется пока backend healthy перед nginx
- Auto-restart если что-то упадет
- Explicit network для сервисов

**Конфиг:**
- Правильные proxy заголовки (Host, X-Real-IP, X-Forwarded-For)
- Нормальные timeout'ы
- Логирование работает

## Структура проекта

```
devops-test-task/
├── backend/              # Python приложение
│   ├── Dockerfile       # Образ для backend
│   └── app.py           # HTTP сервер на Python
├── nginx/               # Nginx конфиг
│   └── nginx.conf       # Настройки reverse proxy
├── docker-compose.yml   # Оркестрация
├── README.md            # Этот файл
├── .gitignore          # Что не коммитить в git
├── test.sh             # Тест для Linux/Mac
└── test.bat            # Тест для Windows
```

## Проблемы и решение

**Q: Порт 80 уже занят**
A: Используй другой порт в docker-compose.yml:
```yaml
ports:
  - "8000:80"  # теперь доступно на :8000
```
Потом `curl http://localhost:8000`

**Q: Backend не отвечает**
A: Проверяем логи:
```bash
docker-compose logs backend
```

**Q: Health check'и падают**
A: Может быть контейнеры еще стартуют. Пробуем еще раз через 10 секунд:
```bash
docker-compose down && docker-compose up -d
```

**Q: Permission denied на nginx конфиг**
A: Проверяем что конфиг существует:
```bash
ls -la nginx/nginx.conf
```
Если файла нет - что-то с клонированием репо

## Notes

- Я выбрал Python с `http.server` потому что это встроено и не нужны зависимости
- Nginx slim image экономит место (важно если много контейнеров)
- Health checks помогают Docker понять когда сервис готов
- Docker Compose DNS очень удобно - не нужно IP адреса хардкодить

---

Made with ❤️ for Effective Mobile
