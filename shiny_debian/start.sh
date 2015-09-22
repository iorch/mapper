#! /usr/bin/env bash

pg_ctlcluster `pg_lsclusters| tail -1| awk '{print $1}'` \
  `pg_lsclusters|tail -1 | awk '{print $2}'` start

sed "s/POSTGRES_PORT_5432_TCP_ADDR/$POSTGRES_PORT_5432_TCP_ADDR/;
s/POSTGRES_PORT_5432_TCP_PORT/$POSTGRES_PORT_5432_TCP_PORT/;
s/POSTGRES_ENV_POSTGRES_PASSWORD/$POSTGRES_ENV_POSTGRES_PASSWORD/" \
/srv/shiny-server/tomalapp/server.R > tmp.R

mv tmp.R /srv/shiny-server/tomalapp/server.R

shiny-server
