# factual - Fact-Checking Platform

A production-ready fact-checking platform built with Django REST Framework backend and React frontend, featuring secure API endpoints and external model integration.

## 🏗️ Architecture

- **Backend**: Django 4.2 with Django REST Framework
- **Frontend**: React 18 with Bootstrap
- **Database**: PostgreSQL (production) / SQLite (development)
- **Containerization**: Docker & Docker Compose

## 📁 Project Structure

```
factual/
├── backend/                 # Django backend application
│   ├── API/                # API endpoints and views
│   ├── accounts/           # User authentication
│   ├── factualweb/         # Django project settings
│   │   └── settings/       # Split settings (base, dev, prod)
│   ├── bert/               # ML models and ETL
│   ├── manage.py           # Django management script
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend Docker configuration
├── frontend/               # React frontend application
│   ├── src/               # React source files
│   ├── public/            # Static assets
│   ├── package.json       # Node dependencies
│   └── Dockerfile         # Frontend Docker configuration
├── docker-compose.yml     # Multi-container setup
├── .env.example           # Environment variables template
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- Node.js 18+
- PostgreSQL (for production)
- Docker & Docker Compose (optional)

### Automated Setup (Recommended)

Use the provided setup script for quick installation:

```bash
git clone <repository-url>
cd factual
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Local Development Setup

#### 1. Clone the repository

```bash
git clone <repository-url>
cd factual
```

#### 2. Backend Setup

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment variables
cp ../.env.example .env
# Edit .env with your configuration

# Run migrations
python manage.py migrate

# Create superuser (optional)
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

The backend will be available at `http://localhost:8000`

#### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local
# Edit .env.local with your configuration

# Start development server
npm start
```

The frontend will be available at `http://localhost:3000`

### Docker Compose Setup

#### 1. Configure environment variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your production values
nano .env
```

#### 2. Build and run with Docker Compose

```bash
# Build and start all services (DB, Backend, Frontend)
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

Services will be available at:
- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:8000`
- PostgreSQL: `localhost:5432`

## 🔧 Configuration

### Environment Variables

All sensitive configuration is managed through environment variables. See `.env.example` for required variables:

#### Django Settings
- `DJANGO_SECRET_KEY`: Django secret key (required)
- `DJANGO_DEBUG`: Debug mode (True/False)
- `DJANGO_ALLOWED_HOSTS`: Comma-separated list of allowed hosts
- `DJANGO_SETTINGS_MODULE`: Settings module to use (dev/prod)

#### Database Settings
- `DB_ENGINE`: Database engine (default: postgresql)
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `DB_HOST`: Database host
- `DB_PORT`: Database port

#### External Model API
⚠️ **Important**: This application requires an external sentiment analysis model endpoint:
- `MODEL_API_URL`: URL of the external finetuned binary word-level sentiment model API
- `MODEL_API_KEY`: API key for the model endpoint (if required)

The model endpoint should accept POST requests with JSON body:
```json
{
  "text": "Text to analyze"
}
```

#### Factual API Settings
- `FACTUAL_API_KEY`: API key for Factual services

#### Frontend Settings
- `REACT_APP_API_URL`: Backend API URL

## 📡 API Endpoints

### Backend Endpoints

#### Original Fact-Check Endpoint
```
POST /api/
```
Legacy endpoint for fact-checking queries.

**Request Body:**
```json
{
  "text/URL": "Text or URL to fact-check"
}
```

#### Factual API Proxy
```
POST /api/factual/<endpoint>/
```
Low-level proxy endpoint for direct Factual API access.

#### Analyze and Match Endpoint
```
POST /api/analyze-and-match/
```
High-level endpoint that combines external sentiment model analysis with fact-checking.

**Request Body:**
```json
{
  "text": "Text to analyze and fact-check"
}
```

**Response:**
```json
{
  "sentiment_analysis": { ... },
  "fact_check_matches": [ ... ],
  "text": "Original text"
}
```

#### Authentication Endpoints
```
POST /account/register/         # User registration
POST /account/login/            # User login
POST /account/token/            # Get JWT token
POST /account/token/refresh/    # Refresh JWT token
GET  /account/get_profile/      # Get user profile
PUT  /account/update-profile/   # Update profile
PUT  /account/update-email/     # Update email
PUT  /account/change-password/  # Change password
```

## 🔒 Security Features

- Split Django settings (base, dev, prod) with secure defaults
- All secrets loaded from environment variables
- No credentials committed to repository
- CORS protection with configurable origins
- JWT-based authentication
- HTTPS enforcement in production
- Secure cookie settings
- HSTS headers in production
- Content Security Policy headers

## 🧪 Testing

### Backend Tests
```bash
cd backend
python manage.py test
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 📦 Deployment

### Production Checklist

1. ✅ Set strong `DJANGO_SECRET_KEY`
2. ✅ Set `DJANGO_DEBUG=False`
3. ✅ Configure `DJANGO_ALLOWED_HOSTS` with your domain
4. ✅ Set up PostgreSQL database
5. ✅ Configure `MODEL_API_URL` with your model endpoint
6. ✅ Set all required API keys
7. ✅ Enable SSL/TLS (set `SECURE_SSL_REDIRECT=True`)
8. ✅ Configure CORS origins properly
9. ✅ Set up static file serving (nginx/CDN)
10. ✅ Configure backup strategy for database

### Environment-Specific Settings

The application uses different settings modules:
- Development: `factualweb.settings.dev`
- Production: `factualweb.settings.prod`

Set the appropriate module using the `DJANGO_SETTINGS_MODULE` environment variable.

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests
4. Submit a pull request

## 📝 License

See LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check existing GitHub issues
2. Create a new issue with detailed description
3. Include error logs and environment details

## ⚠️ Important Notes

### External Model Requirement
This application requires an **external sentiment analysis model API** to be running and accessible. The model is NOT loaded in-process. You must:

1. Deploy your finetuned binary word-level sentiment model as a separate API service
2. Configure `MODEL_API_URL` to point to your model endpoint
3. Ensure the model API accepts POST requests with JSON body containing a "text" field
4. (Optional) Set `MODEL_API_KEY` if your model API requires authentication

The `/api/analyze-and-match/` endpoint will not function without a properly configured external model API.

### Database Migration
When switching from SQLite to PostgreSQL:
```bash
# Export data from SQLite
python manage.py dumpdata > data.json

# Configure PostgreSQL in .env
# Run migrations
python manage.py migrate

# Import data
python manage.py loaddata data.json
```
