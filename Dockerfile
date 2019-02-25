FROM python:3.7-alpine3.8
RUN apk add --no-cache \
    bash \
    postgresql \
    tarsnap
RUN pip install tarsnapper==0.4.0 awscli
ADD . /app
WORKDIR /app
