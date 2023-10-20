# Frontend resources
FROM python:3.10-slim-bullseye
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONBUFFERED=1
RUN mkdir /code
COPY . /code/
WORKDIR /code

RUN docker pull gcr.io/google.com/cloudsdktool/google-cloud-cli:latest
RUN docker run --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:latest gcloud version

#HERE!
RUN docker run -ti --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud auth activate-service-account --key-file=key.json
#RUN gcloud auth activate-service-account --key-file=key.json

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN gsutil cp gs://platform-api-389019-tf2-models/models /API/models
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc-dev libpq-dev python-dev
COPY . .
EXPOSE 8000
CMD HOME=/root python3 manage.py runserver localhost:8000

# Frontend resources
#FROM python:3.10-slim-bullseye
#ENV PYTHONDONTWRITEBYTECODE=1 \
#    PYTHONBUFFERED=1
#RUN mkdir /code
#COPY . /code/
#WORKDIR /code
#RUN pip install --upgrade pip
#RUN pip install -r requirements.txt
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    gcc libc-dev libpq-dev python-dev
#COPY . .
#CMD HOME=/root python3 manage.py runserver localhost:8000