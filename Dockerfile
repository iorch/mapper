FROM postgres:latest
MAINTAINER Jorge Martínez "j.martinezortega@gmail.com"

ENV POSTGIS_MAJOR 2.1
ENV POSTGIS_VERSION 2.1.7+dfsg-3~94.git954a8d0.pgdg80+1

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
      && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
        && apt-get install -y \
             python-pip \
             python-dev \
             libpq-dev \
        && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /docker-entrypoint-initdb.d

COPY requirements.txt config.py web_service_storage.py /

RUN pip install -r requirements.txt
EXPOSE 5000

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY start_ws.sh /docker-entrypoint-initdb.d/start_ws.sh
