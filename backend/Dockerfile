# Multi-stage build for minimal image size
FROM python:3.11-slim as runtime

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN useradd -m -u 1000 appuser

# Copy application
COPY app.py .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (documentation, not published)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 -c "import http.client; http.client.HTTPConnection('localhost', 8080).request('GET', '/'); exit(0)" || exit 1

# Run application
CMD ["python3", "app.py"]
