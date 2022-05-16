FROM python:3.10.4-alpine3.14
RUN apk add --no-cache \
    bash \
    postgresql \
    tarsnap
RUN pip install tarsnapper awscli
ADD . /app
WORKDIR /app
