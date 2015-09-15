#! /usr/bin/env bash

pg_ctlcluster `pg_lsclusters| tail -1| awk '{print $1}'` \
  `pg_lsclusters|tail -1 | awk '{print $2}'` start

shiny-server
