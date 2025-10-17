# Contributing to Factual

Thank you for your interest in contributing to Factual! This document provides guidelines and instructions for contributing to the project.

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Testing](#testing)
6. [Documentation](#documentation)
7. [Pull Request Process](#pull-request-process)

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Prioritize the community's best interests
- Help others learn and grow

## Getting Started

### Prerequisites
- Python 3.10+
- Node.js 18+
- Git
- PostgreSQL (for production-like testing)

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/factual.git
   cd factual
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/panteleimon-a/factual.git
   ```

### Set Up Development Environment

#### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python -c "import nltk; nltk.download('punkt'); nltk.download('stopwords')"
cp ../.env.example .env
# Edit .env with development values
python manage.py migrate
python manage.py runserver
```

#### Frontend
```bash
cd frontend
npm install
cp .env.example .env.local
# Edit .env.local
npm start
```

## Development Workflow

### Branching Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/feature-name` - New features
- `bugfix/bug-name` - Bug fixes
- `hotfix/issue-name` - Critical production fixes

### Creating a Feature Branch

```bash
git checkout develop
git pull upstream develop
git checkout -b feature/your-feature-name
```

### Making Changes

1. Write clear, focused commits
2. Test your changes thoroughly
3. Update documentation as needed
4. Follow coding standards

### Commit Messages

Use conventional commit format:
```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Example:**
```
feat(api): add sentiment analysis endpoint

- Implement POST /api/analyze-and-match/
- Integrate external model API
- Add error handling for model failures

Closes #123
```

## Coding Standards

### Python (Backend)

**Follow PEP 8:**
```bash
# Install and run flake8
pip install flake8
flake8 .
```

**Code Style:**
- Use 4 spaces for indentation
- Maximum line length: 100 characters
- Use descriptive variable names
- Add docstrings to functions and classes
- Type hints where appropriate

**Example:**
```python
def analyze_sentiment(text: str, model_url: str) -> dict:
    """
    Analyze sentiment of given text using external model.
    
    Args:
        text: Input text to analyze
        model_url: URL of external sentiment model API
        
    Returns:
        Dictionary containing sentiment analysis results
        
    Raises:
        RequestException: If API call fails
    """
    response = requests.post(model_url, json={"text": text})
    response.raise_for_status()
    return response.json()
```

### JavaScript/React (Frontend)

**Follow ESLint rules:**
```bash
npm run lint
```

**Code Style:**
- Use 2 spaces for indentation
- Use functional components with hooks
- Use descriptive component and variable names
- Extract reusable logic into custom hooks
- Add PropTypes or TypeScript types

**Example:**
```javascript
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

const SearchBar = ({ onSearch, placeholder }) => {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await onSearch(query);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input 
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder={placeholder}
        disabled={loading}
      />
      <button type="submit" disabled={loading}>
        {loading ? 'Searching...' : 'Search'}
      </button>
    </form>
  );
};

SearchBar.propTypes = {
  onSearch: PropTypes.func.isRequired,
  placeholder: PropTypes.string
};

SearchBar.defaultProps = {
  placeholder: 'Search...'
};

export default SearchBar;
```

### Django Best Practices

**Views:**
- Use class-based views for consistency
- Keep views thin, move logic to services/utils
- Add proper error handling
- Validate input data

**Models:**
- Add `__str__` methods
- Use descriptive field names
- Add database indexes where appropriate
- Document complex fields

**Settings:**
- Use environment variables for configuration
- Never commit secrets
- Use appropriate settings module (dev/prod)

## Testing

### Backend Tests

**Run tests:**
```bash
cd backend
python manage.py test
```

**Write tests for:**
- All API endpoints
- Model methods
- Utility functions
- Edge cases and error handling

**Example:**
```python
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status

class AnalyzeEndpointTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        
    def test_analyze_endpoint_success(self):
        """Test successful sentiment analysis"""
        response = self.client.post(
            '/api/analyze-and-match/',
            {'text': 'This is a test'},
            format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('sentiment_analysis', response.data)
        
    def test_analyze_endpoint_missing_text(self):
        """Test endpoint with missing text field"""
        response = self.client.post(
            '/api/analyze-and-match/',
            {},
            format='json'
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
```

### Frontend Tests

**Run tests:**
```bash
cd frontend
npm test
```

**Write tests for:**
- Component rendering
- User interactions
- API integration
- Edge cases

**Example:**
```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import SearchBar from './SearchBar';

describe('SearchBar', () => {
  it('renders search input', () => {
    render(<SearchBar onSearch={() => {}} />);
    expect(screen.getByPlaceholderText(/search/i)).toBeInTheDocument();
  });

  it('calls onSearch when form is submitted', async () => {
    const mockSearch = jest.fn();
    render(<SearchBar onSearch={mockSearch} />);
    
    const input = screen.getByPlaceholderText(/search/i);
    const button = screen.getByRole('button');
    
    fireEvent.change(input, { target: { value: 'test query' } });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(mockSearch).toHaveBeenCalledWith('test query');
    });
  });
});
```

## Documentation

### Code Documentation

**Python:**
- Use docstrings for modules, classes, and functions
- Follow Google or NumPy docstring format
- Document parameters, return values, and exceptions

**JavaScript:**
- Use JSDoc comments for complex functions
- Document React component props
- Explain complex logic

### Project Documentation

When adding features:
- Update README.md if it affects usage
- Update DEPLOYMENT.md if it affects deployment
- Add examples to documentation
- Update API documentation

## Pull Request Process

### Before Submitting

1. **Update your branch:**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout feature/your-feature
   git rebase develop
   ```

2. **Run tests:**
   ```bash
   # Backend
   cd backend && python manage.py test
   
   # Frontend
   cd frontend && npm test
   ```

3. **Check code style:**
   ```bash
   # Backend
   flake8 .
   
   # Frontend
   npm run lint
   ```

4. **Update documentation**

### Submitting Pull Request

1. Push your branch:
   ```bash
   git push origin feature/your-feature
   ```

2. Create pull request on GitHub

3. Fill out PR template:
   - Description of changes
   - Related issue numbers
   - Testing performed
   - Screenshots (for UI changes)

4. Request review from maintainers

### PR Requirements

- [ ] Tests pass
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] Reviewed and approved
- [ ] Linked to related issue

### Review Process

1. Maintainers review your PR
2. Address feedback and push updates
3. Once approved, PR will be merged
4. Delete your feature branch

## Development Tips

### Backend

**Database migrations:**
```bash
python manage.py makemigrations
python manage.py migrate
```

**Django shell:**
```bash
python manage.py shell
```

**Create superuser:**
```bash
python manage.py createsuperuser
```

### Frontend

**Clear cache:**
```bash
rm -rf node_modules package-lock.json
npm install
```

**Build production:**
```bash
npm run build
```

### Docker

**Rebuild services:**
```bash
docker-compose up --build -d
```

**View logs:**
```bash
docker-compose logs -f backend
```

**Execute commands:**
```bash
docker-compose exec backend python manage.py migrate
```

## Getting Help

- **GitHub Issues**: Report bugs or request features
- **GitHub Discussions**: Ask questions or share ideas
- **Documentation**: Check README and DEPLOYMENT guides
- **Code Review**: Ask for feedback in PR comments

## Recognition

Contributors will be recognized in:
- Project README
- Release notes
- GitHub contributors page

Thank you for contributing to Factual! 🎉
