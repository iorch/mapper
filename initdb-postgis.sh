#!/bin/sh

set -e

# Perform all actions as user 'postgres'
export PGUSER=postgres
export PGDATA=$PGDATA

# Create the 'tomala' template db
psql <<EOSQL
CREATE DATABASE tomala;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'tomala';
EOSQL

# Populate 'template_postgis'
cd /usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR
psql --dbname tomala < postgis.sql
psql --dbname tomala < topology.sql
psql --dbname tomala < spatial_ref_sys.sql
psql --dbname tomala -c "CREATE EXTENSION hstore;"
