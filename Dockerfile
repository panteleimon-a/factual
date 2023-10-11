# Frontend resources
FROM python:3.10-slim-bullseye
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONBUFFERED=1

WORKDIR /WalkPhase2
COPY . /WalkPhase2
RUN pip install --upgrade pip
RUN apt-get update && apt-get install --no-install-recommends -y \
    gcc libc-dev libpq-dev  python-dev &&\
    pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
CMD python manage.py runserver 0.0.0.0:8080
