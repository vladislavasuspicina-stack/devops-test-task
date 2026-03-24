# Примеры тестирования

## Базовая проверка что работает

### Linux / Mac / Windows (PowerShell или WSL)

```bash
# Просто открываем браузер или используем curl
curl http://localhost

# Или с verbose флагом чтобы видеть заголовки
curl -v http://localhost

# Можно добавить конкретный заголовок для теста
curl -H "X-Test: hello" http://localhost

# Проверить все заголовки в ответе
curl -i http://localhost
```

## Смотреть что происходит внутри

```bash
# Логи всех контейнеров в реальном времени
docker-compose logs -f

# Только backend
docker-compose logs backend -f

# Только nginx  
docker-compose logs nginx -f

# Последние 50 строк
docker-compose logs --tail=50
```

## Тестирование backend напрямую (без nginx)

```bash
# Подключиться к контейнеру
docker-compose exec backend /bin/sh

# Внутри контейнера
curl http://localhost:8080
python3 -c "import http.client; print(http.client.HTTPConnection('localhost', 8080).getresponse().read())"
exit
```

## Тестирование nginx конфига

```bash
# Проверить синтаксис конфига
docker-compose exec nginx nginx -t

# Перезагрузить конфиг без перезагрузки nginx
docker-compose exec nginx nginx -s reload
```

## Проверить DNS resolution

```bash
# Внутри nginx контейнера
docker-compose exec nginx nslookup backend

# Должно вернуть IP адрес контейнера backend
```

## Помер с вывод при успехе

```
$ curl http://localhost
Hello from Effective Mobile!

$ docker-compose logs backend
backend_1  | Server started at port 8080
backend_1  | [04/Mar/2026 10:15:30] GET / HTTP/1.1": 200 -

$ docker-compose logs nginx
nginx_1    | 172.18.0.1 - - [04/Mar/2026 10:15:30] "GET / HTTP/1.1" 200 28 "-" ...
```

## Стресс тестирование (если нужно)

```bash
# Установить ab (Apache Bench)
# apt-get install apache2-utils (Linux) или brew install httpd (Mac)

# 100 запросов с 10 параллельными соединениями
ab -n 100 -c 10 http://localhost/

# Много запросов долгое время
ab -t 30 -c 50 http://localhost/ 
```

## Если что-то не работает

```bash
# 1. Проверяем что образы собрались
docker image ls | grep backend

# 2. Проверяем что контейнеры поднялись
docker-compose ps

# 3. Смотрим полные логи
docker-compose logs

# 4. Пробуем пересоздать с нуля
docker-compose down
docker-compose up -d --build

# 5. Если совсем беда - полная очистка
docker-compose down --rmi all
docker system prune -a
docker-compose up -d
```
