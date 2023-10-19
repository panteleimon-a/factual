# Frontend resources
FROM python:3.10-slim-bullseye
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONBUFFERED=1
RUN mkdir /code
COPY . /code/
WORKDIR /code
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc-dev libpq-dev python-dev
COPY . .
CMD HOME=/root python3 manage.py runserver localhost:8000
