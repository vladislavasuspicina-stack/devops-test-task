#!/bin/bash
# Test script for DevOps application

set -e

echo "=== DevOps Test Task - Application Test ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Docker
echo "1. Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"
echo "   Version: $(docker --version)"
echo ""

# Check Docker Compose
echo "2. Checking Docker Compose installation..."
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose found${NC}"
echo "   Version: $(docker-compose --version)"
echo ""

# Stop any existing containers
echo "3. Stopping existing containers..."
docker-compose down 2>/dev/null || true
echo -e "${GREEN}✓ Ready to start${NC}"
echo ""

# Start containers
echo "4. Starting containers from docker-compose.yml..."
docker-compose up -d
echo -e "${GREEN}✓ Containers started${NC}"
echo ""

# Wait for services to be ready
echo "5. Waiting for services to be healthy (30 seconds)..."
for i in {1..30}; do
    if curl -s http://localhost 2>/dev/null | grep -q "Hello from Effective Mobile"; then
        echo -e "${GREEN}✓ Service is ready!${NC}"
        break
    fi
    echo "   Waiting... ($i/30)"
    sleep 1
done
echo ""

# Test the endpoint
echo "6. Testing HTTP endpoint..."
echo "   URL: http://localhost"
RESPONSE=$(curl -s http://localhost)
echo "   Response: $RESPONSE"
echo ""

# Verify response
if echo "$RESPONSE" | grep -q "Hello from Effective Mobile"; then
    echo -e "${GREEN}✓ Test PASSED!${NC}"
    echo ""
    echo "=== Service is working correctly ==="
    echo ""
    echo "Container status:"
    docker-compose ps
    echo ""
    echo "To view logs: docker-compose logs -f"
    echo "To stop: docker-compose down"
else
    echo -e "${RED}✗ Test FAILED!${NC}"
    echo "Expected: 'Hello from Effective Mobile!'"
    echo "Got: '$RESPONSE'"
    exit 1
fi
