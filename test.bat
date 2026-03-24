# Test Windows batch file

@echo off
REM Test script for DevOps application on Windows

echo === DevOps Test Task - Application Test ===
echo.

REM Check Docker
echo 1. Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [FAILED] Docker is not installed or not running
    exit /b 1
)
for /f "tokens=*" %%i in ('docker --version') do set DOCKER_VERSION=%%i
echo [OK] Docker found
echo    Version: %DOCKER_VERSION%
echo.

REM Check Docker Compose
echo 2. Checking Docker Compose installation...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [FAILED] Docker Compose is not installed
    exit /b 1
)
for /f "tokens=*" %%i in ('docker-compose --version') do set COMPOSE_VERSION=%%i
echo [OK] Docker Compose found
echo    Version: %COMPOSE_VERSION%
echo.

REM Stop existing containers
echo 3. Stopping existing containers...
docker-compose down >nul 2>&1
echo [OK] Ready to start
echo.

REM Start containers
echo 4. Starting containers from docker-compose.yml...
docker-compose up -d
echo [OK] Containers started
echo.

REM Wait for services
echo 5. Waiting for services to be healthy (30 seconds)...
setlocal enabledelayedexpansion
for /l %%i in (1,1,30) do (
    curl -s http://localhost 2>nul | findstr "Hello from Effective Mobile" >nul
    if not errorlevel 1 (
        echo [OK] Service is ready!
        goto :test
    )
    echo    Waiting... (%%i/30)
    timeout /t 1 /nobreak >nul
)

:test
echo.

REM Test the endpoint
echo 6. Testing HTTP endpoint...
echo    URL: http://localhost
for /f "tokens=*" %%i in ('curl -s http://localhost 2^>nul') do set RESPONSE=%%i
echo    Response: %RESPONSE%
echo.

REM Verify response
echo %RESPONSE% | findstr "Hello from Effective Mobile" >nul
if not errorlevel 1 (
    echo [SUCCESS] Test PASSED!
    echo.
    echo === Service is working correctly ===
    echo.
    echo Container status:
    docker-compose ps
    echo.
    echo To view logs: docker-compose logs -f
    echo To stop: docker-compose down
) else (
    echo [FAILED] Test FAILED!
    echo Expected: 'Hello from Effective Mobile!'
    echo Got: '%RESPONSE%'
    exit /b 1
)
