FROM ubuntu:23.04

RUN apt update && apt install -y --no-install-recommends postgresql-client-15 wget gpg python3-pip
RUN wget --no-check-certificate https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc
RUN gpg --dearmor tarsnap-deb-packaging-key.asc
RUN mv tarsnap-deb-packaging-key.asc.gpg tarsnap-archive-keyring.gpg
RUN cp tarsnap-archive-keyring.gpg /usr/share/keyrings/
RUN echo "deb [signed-by=/usr/share/keyrings/tarsnap-archive-keyring.gpg, trusted=yes] http://pkg.tarsnap.com/deb/lunar/ ./" | tee -a /etc/apt/sources.list.d/tarsnap.list
RUN apt update
RUN apt install -y --no-install-recommends tarsnap

RUN pip install tarsnapper awscli --break-system-packages

ADD . /app
WORKDIR /app
