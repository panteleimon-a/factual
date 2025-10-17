#!/bin/bash
# Healthcheck script for backend service
# Returns 0 if service is healthy, 1 otherwise

# Check if Django is responding
curl --fail --silent http://localhost:8000/admin/login/ > /dev/null

if [ $? -eq 0 ]; then
    echo "✓ Backend is healthy"
    exit 0
else
    echo "✗ Backend is not responding"
    exit 1
fi
