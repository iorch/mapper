#! /usr/bin/env bash

pg_ctlcluster `pg_lsclusters| tail -1| awk '{print $1}'` \
  `pg_lsclusters|tail -1 | awk '{print $2}'` start

su -c "psql -c \"CREATE USER root WITH PASSWORD '$POSTGRES_PASSWD';\"" \
    -s /bin/bash postgres

su -c "psql -c \"CREATE DATABASE tomala OWNER root;\"" \
    -s /bin/bash postgres

su -c "psql -d tomala < /srv/shiny-server/tomalapp/scripts/heatmap.sql"

pg_ctlcluster `pg_lsclusters| tail -1| awk '{print $1}'` \
      `pg_lsclusters|tail -1 | awk '{print $2}'` stop
