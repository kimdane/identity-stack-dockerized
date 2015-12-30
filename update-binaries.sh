#!/bin/bash
cd bin
curl -o /tmp/getnightly.sh https://raw.githubusercontent.com/ForgeRock/frstack/master/bin/getnightly.sh
chmod +x /tmp/getnightly.sh 
/tmp/getnightly.sh openidm openam opendj openig

unzip staging/openidm.zip \
openidm/db/postgresql/scripts/openidm.pgsql \
openidm/db/postgresql/scripts/default_schema_optimization.pgsql \
openidm/db/postgresql/conf/datasource.jdbc-default.json \
openidm/db/postgresql/conf/repo.jdbc.json \
-d /tmp/

cd ..
mkdir openidm
mkdir postgres
mkdir bin
cp /tmp/openidm/db/postgresql/scripts/openidm.pgsql postgres/01_init.sql
cp /tmp/openidm/db/postgresql/scripts/default_schema_optimization.pgsql postgres/02_optimize.sql
cp openidm/conf/datasource.jdbc-default.json openidm/conf/datasource.jdbc-default.old
cp openidm/conf/repo.jdbc.json openidm/conf/repo.jdbc.old
cp /tmp/openidm/db/postgresql/conf/datasource.jdbc-default.json openidm/conf/datasource.jdbc-default.json
cp /tmp/openidm/db/postgresql/conf/repo.jdbc.json openidm/conf/repo.jdbc.json
rm -r /tmp/openidm
