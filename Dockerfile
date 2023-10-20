# Frontend resources
FROM python:3.10-slim-bullseye
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONBUFFERED=1
RUN mkdir /code
COPY . /code/
WORKDIR /code

RUN curl https://sdk.cloud.google.com | bash
RUN bash install.sh --disable-prompts
#HERE!
RUN pip install --upgrade pip
# added gsutil in requirements
RUN pip install -r requirements.txt
RUN gcloud auth activate-service-account --key-file=key.json
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