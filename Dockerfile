# Frontend resources
FROM python:3.10-bullseye
ENV PYTHONUNBUFFERED 1
WORKDIR /factualweb
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . . 
CMD python manage.py runserver 0.0.0.0:80