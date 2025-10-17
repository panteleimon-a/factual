#!/bin/bash
# Setup script for Factual application
# This script helps with initial setup and environment configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print banner
echo "================================"
echo "  Factual Setup Script"
echo "================================"
echo

# Check prerequisites
print_info "Checking prerequisites..."

if ! command_exists python3; then
    print_error "Python 3 is not installed. Please install Python 3.10 or higher."
    exit 1
fi

if ! command_exists node; then
    print_error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

if ! command_exists git; then
    print_error "Git is not installed. Please install Git."
    exit 1
fi

print_info "✓ Prerequisites check passed"
echo

# Setup environment file
print_info "Setting up environment configuration..."
if [ ! -f .env ]; then
    cp .env.example .env
    print_info "Created .env file from .env.example"
    print_warning "Please edit .env file with your configuration before proceeding"
    read -p "Press enter to continue after editing .env file..."
else
    print_info ".env file already exists"
fi
echo

# Backend setup
print_info "Setting up backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3 -m venv venv
    print_info "✓ Virtual environment created"
else
    print_info "Virtual environment already exists"
fi

# Activate virtual environment
print_info "Activating virtual environment..."
source venv/bin/activate || . venv/Scripts/activate

# Install dependencies
print_info "Installing Python dependencies..."
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
print_info "✓ Python dependencies installed"

# Download NLTK data
print_info "Downloading NLTK data..."
python -c "import nltk; nltk.download('punkt', quiet=True); nltk.download('stopwords', quiet=True)"
print_info "✓ NLTK data downloaded"

# Run migrations
print_info "Running database migrations..."
python manage.py migrate --noinput
print_info "✓ Database migrations completed"

# Collect static files
print_info "Collecting static files..."
python manage.py collectstatic --noinput --clear
print_info "✓ Static files collected"

# Ask about creating superuser
read -p "Do you want to create a superuser account? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python manage.py createsuperuser
fi

cd ..

# Frontend setup
print_info "Setting up frontend..."
cd frontend

# Setup frontend environment
if [ ! -f .env.local ]; then
    cp .env.example .env.local
    print_info "Created .env.local file from .env.example"
else
    print_info ".env.local file already exists"
fi

# Install dependencies
print_info "Installing Node.js dependencies..."
npm install
print_info "✓ Node.js dependencies installed"

cd ..

# Summary
echo
echo "================================"
print_info "Setup completed successfully!"
echo "================================"
echo
echo "To start development:"
echo
echo "Backend:"
echo "  cd backend"
echo "  source venv/bin/activate"
echo "  python manage.py runserver"
echo
echo "Frontend:"
echo "  cd frontend"
echo "  npm start"
echo
echo "Or use Docker Compose:"
echo "  docker-compose up --build"
echo
print_warning "Don't forget to configure your external model API endpoint in .env"
print_warning "MODEL_API_URL and MODEL_API_KEY are required for the /api/analyze-and-match/ endpoint"
echo
