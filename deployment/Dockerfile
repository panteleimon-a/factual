# Frontend resources
FROM python:3.10-slim-bullseye
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONBUFFERED=1
RUN mkdir /code
COPY . /code/
WORKDIR /code

# install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc-dev libpq-dev python-dev curl

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# authenticate gcloud
# add models folder from storage bucket 
RUN HOME=/root gcloud auth activate-service-account --key-file=platform-api-389019-c18492c31c22.json && \gcloud config set project '${{ credentials.json.project_id }}'  && gsutil -m cp -r \
  "gs://platform-api-389019-tf2-models/models" \
  /API/models

COPY . .
EXPOSE 8000
CMD HOME=/root python3 manage.py runserver localhost:8000

# frontend resources
WORKDIR /factual_node
COPY package*.json ./
RUN npm install
RUN npm install react react-dom react-scripts
COPY . .
EXPOSE 3000
RUN HOME=/factual_node npm run build
RUN HOME=/factual_node npm start