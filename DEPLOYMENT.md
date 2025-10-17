# Factual Deployment Guide

This guide provides detailed instructions for deploying the Factual application in various environments.

## Table of Contents
1. [Local Development](#local-development)
2. [Docker Deployment](#docker-deployment)
3. [Production Deployment](#production-deployment)
4. [Environment Configuration](#environment-configuration)
5. [Troubleshooting](#troubleshooting)

## Local Development

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment:**
   ```bash
   cp ../.env.example .env
   # Edit .env with your configuration
   ```

5. **Download NLTK data:**
   ```bash
   python -c "import nltk; nltk.download('punkt'); nltk.download('stopwords')"
   ```

6. **Setup models:**
   - Place your trained TensorFlow model in `backend/API/models/`
   - The tokenizer will be downloaded automatically on first run

7. **Run migrations:**
   ```bash
   python manage.py migrate
   ```

8. **Create superuser (optional):**
   ```bash
   python manage.py createsuperuser
   ```

9. **Run development server:**
   ```bash
   python manage.py runserver
   ```

The backend API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your backend URL
   ```

4. **Start development server:**
   ```bash
   npm start
   ```

The frontend will be available at `http://localhost:3000`

## Docker Deployment

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+

### Quick Start

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd factual
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with production values
   ```

3. **Build and start services:**
   ```bash
   docker-compose up --build -d
   ```

4. **Check service health:**
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

5. **Access services:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Admin Panel: http://localhost:8000/admin

### Docker Commands

**Start services:**
```bash
docker-compose up -d
```

**Stop services:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f [service_name]
```

**Rebuild services:**
```bash
docker-compose up --build -d
```

**Execute commands in container:**
```bash
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
```

**Clean up (including volumes):**
```bash
docker-compose down -v
```

## Production Deployment

### Pre-deployment Checklist

- [ ] Generate strong `DJANGO_SECRET_KEY`
- [ ] Set `DJANGO_DEBUG=False`
- [ ] Configure proper `DJANGO_ALLOWED_HOSTS`
- [ ] Set up PostgreSQL database
- [ ] Configure external model API endpoint
- [ ] Set all required API keys
- [ ] Enable SSL/TLS
- [ ] Configure CORS origins
- [ ] Set up static file serving
- [ ] Configure backup strategy
- [ ] Set up monitoring and logging
- [ ] Configure firewall rules
- [ ] Set up domain and DNS

### Database Setup

#### PostgreSQL Installation

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

**Create database and user:**
```bash
sudo -u postgres psql
CREATE DATABASE factual_db;
CREATE USER factual_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE factual_db TO factual_user;
\q
```

#### Database Migration

**From SQLite to PostgreSQL:**
```bash
# 1. Export data from SQLite
python manage.py dumpdata --natural-foreign --natural-primary -e contenttypes -e auth.Permission --indent 4 > data.json

# 2. Update .env with PostgreSQL settings
# DB_ENGINE=django.db.backends.postgresql
# DB_NAME=factual_db
# DB_USER=factual_user
# DB_PASSWORD=your_password
# DB_HOST=localhost
# DB_PORT=5432

# 3. Run migrations
python manage.py migrate

# 4. Load data
python manage.py loaddata data.json
```

### External Model API Setup

The application requires an external sentiment analysis model API. You need to:

1. **Deploy your model as a separate service**
   - The model should be a REST API endpoint
   - Accept POST requests with JSON body: `{"text": "..."}`
   - Return sentiment analysis results

2. **Configure model endpoint:**
   ```env
   MODEL_API_URL=https://your-model-api.example.com/analyze
   MODEL_API_KEY=your-api-key-if-required
   ```

3. **Test model endpoint:**
   ```bash
   curl -X POST https://your-model-api.example.com/analyze \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer your-api-key" \
     -d '{"text": "This is a test"}'
   ```

### Nginx Configuration

**Example nginx configuration:**
```nginx
upstream backend {
    server localhost:8000;
}

upstream frontend {
    server localhost:3000;
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Frontend
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Django Admin
    location /admin/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /static/ {
        alias /path/to/factual/backend/staticfiles/;
    }

    # Media files
    location /media/ {
        alias /path/to/factual/backend/media/;
    }
}
```

### Systemd Service

**Backend service (`/etc/systemd/system/factual-backend.service`):**
```ini
[Unit]
Description=Factual Backend Service
After=network.target postgresql.service

[Service]
Type=notify
User=factual
Group=factual
WorkingDirectory=/path/to/factual/backend
Environment="DJANGO_SETTINGS_MODULE=factualweb.settings.prod"
EnvironmentFile=/path/to/factual/.env
ExecStart=/path/to/venv/bin/gunicorn factualweb.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --timeout 120 \
    --log-level info \
    --access-logfile /var/log/factual/access.log \
    --error-logfile /var/log/factual/error.log

[Install]
WantedBy=multi-user.target
```

**Enable and start service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable factual-backend
sudo systemctl start factual-backend
sudo systemctl status factual-backend
```

## Environment Configuration

### Required Environment Variables

#### Django Core
```env
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=your-domain.com,www.your-domain.com
DJANGO_SETTINGS_MODULE=factualweb.settings.prod
```

#### Database
```env
DB_ENGINE=django.db.backends.postgresql
DB_NAME=factual_db
DB_USER=factual_user
DB_PASSWORD=secure-password
DB_HOST=localhost
DB_PORT=5432
```

#### External Services
```env
MODEL_API_URL=https://your-model-api.example.com/analyze
MODEL_API_KEY=your-model-api-key
FACTUAL_API_KEY=your-factual-api-key
```

#### Security
```env
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
CORS_ALLOWED_ORIGINS=https://your-domain.com
```

### Generating Secret Key

```python
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Error
```
django.db.utils.OperationalError: could not connect to server
```
**Solution:**
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Verify database credentials in .env
- Check firewall rules allow database connection

#### 2. Model Not Loading
```
Warning: Model directory not found
```
**Solution:**
- Ensure model files are in `backend/API/models/`
- Check file permissions
- Verify model format is compatible with TensorFlow version

#### 3. CORS Errors
```
Access to fetch has been blocked by CORS policy
```
**Solution:**
- Add frontend URL to `CORS_ALLOWED_ORIGINS` in .env
- Verify CORS middleware is enabled
- Check browser console for exact error

#### 4. Static Files Not Loading
```
404 Not Found: /static/...
```
**Solution:**
```bash
python manage.py collectstatic --noinput
```
- Configure nginx to serve static files
- Verify `STATIC_ROOT` and `STATIC_URL` settings

#### 5. External Model API Not Available
```
Failed to connect to external model API
```
**Solution:**
- Verify `MODEL_API_URL` is correct
- Test endpoint with curl
- Check API key if required
- Ensure network connectivity

### Health Checks

**Backend health:**
```bash
curl http://localhost:8000/admin/login/
```

**Database connectivity:**
```bash
python manage.py dbshell
\conninfo
\q
```

**Check logs:**
```bash
# Django logs
tail -f /var/log/factual/error.log

# Docker logs
docker-compose logs -f backend

# System logs
journalctl -u factual-backend -f
```

### Performance Tuning

#### Gunicorn Workers
```bash
# Formula: (2 x CPU cores) + 1
workers = (2 * num_cores) + 1
```

#### Database Connection Pooling
```python
# In settings/prod.py
DATABASES = {
    'default': {
        # ... other settings ...
        'CONN_MAX_AGE': 60,  # Keep connections open for 60 seconds
        'OPTIONS': {
            'connect_timeout': 10,
        }
    }
}
```

#### Caching
```python
# Redis caching
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

## Monitoring

### Recommended Tools
- **Application Monitoring**: Sentry, New Relic
- **Infrastructure Monitoring**: Prometheus + Grafana
- **Log Management**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Uptime Monitoring**: UptimeRobot, Pingdom

### Key Metrics to Monitor
- API response times
- Error rates
- Database query performance
- Memory and CPU usage
- Disk space
- External API availability

## Backup Strategy

### Database Backups

**Daily backup script:**
```bash
#!/bin/bash
BACKUP_DIR="/backups/factual"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/factual_db_$DATE.sql.gz"

pg_dump -U factual_user factual_db | gzip > "$BACKUP_FILE"

# Keep only last 30 days
find "$BACKUP_DIR" -name "factual_db_*.sql.gz" -mtime +30 -delete
```

### Media Files Backup

```bash
rsync -avz /path/to/factual/backend/media/ backup-server:/backups/factual/media/
```

## Security Best Practices

1. **Keep dependencies updated:**
   ```bash
   pip list --outdated
   npm outdated
   ```

2. **Regular security audits:**
   ```bash
   pip install safety
   safety check
   ```

3. **Monitor logs for suspicious activity**

4. **Use environment variables for all secrets**

5. **Enable rate limiting on API endpoints**

6. **Regular database backups**

7. **SSL/TLS certificate renewal**

8. **Firewall configuration**

## Support

For additional help:
- Check GitHub Issues
- Review application logs
- Contact development team
