"""
Development settings for factualweb project.
"""

from .base import *

# Debug mode enabled for development
DEBUG = True

# Database - SQLite for local development
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Security settings for development
SECURE_SSL_REDIRECT = False
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False
SECURE_HSTS_SECONDS = 0
SECURE_HSTS_INCLUDE_SUBDOMAINS = False
SECURE_HSTS_PRELOAD = False

# Allow all hosts in development (override if needed)
ALLOWED_HOSTS = ['*']

# CORS settings for development
CORS_ALLOW_ALL_ORIGINS = True  # Allow all origins in dev for easier testing

# Additional development-specific settings
INTERNAL_IPS = [
    '127.0.0.1',
    'localhost',
]
