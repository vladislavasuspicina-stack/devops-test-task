# Базовый образ - python slim для меньшего размера
FROM python:3.11-slim

WORKDIR /app

# Создаем обычного пользователя для безопасности
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app

COPY app.py .

# Переключаемся на non-root пользователя
USER appuser

EXPOSE 8080

# Health check для docker-compose - так он знает когда сервис готов
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 -c "import http.client; http.client.HTTPConnection('localhost', 8080).request('GET', '/'); exit(0)" || exit 1

CMD ["python3", "app.py"]
