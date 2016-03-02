#!/bin/bash
mkdir openidm
mkdir postgres
mkdir bin
cd bin

# Get openidm openam opendj and openig from ForgeRocks nightly builds GitHub repo
curl -o /tmp/getnightly.sh https://raw.githubusercontent.com/ForgeRock/frstack/master/bin/getnightly.sh
chmod +x /tmp/getnightly.sh 
/tmp/getnightly.sh openidm openam opendj openig

# Get the right version (by parsing the RELEASE-file after downloading nightly
# build) of OpenAM Configurator from ForgeRocks maven repo
AM=$(grep -o "openam-server/[^/]*/" staging/RELEASE |grep -o "/[^/]*/")
curl http://maven.forgerock.org/repo/simple/snapshots/org/forgerock/openam/openam-distribution-ssoconfiguratortools$AM \
   | grep -o 'href=.*\.zip\"' | grep -o 'openam.*zip' | \
 	xargs -I % curl -o staging/configurator.zip  \
 	http://maven.forgerock.org/repo/simple/snapshots/org/forgerock/openam/openam-distribution-ssoconfiguratortools$AM%

# Get filebeat deb-files for logging with logstash
curl https://www.elastic.co/downloads/beats/filebeat \
	| grep -o "\"https:[^:]*amd64.deb\"" | xargs curl -O

# Unziping and extracting schema-files from openidm to postgres
unzip staging/openidm.zip \
openidm/db/postgresql/scripts/openidm.pgsql \
openidm/db/postgresql/scripts/default_schema_optimization.pgsql \
openidm/db/postgresql/conf/datasource.jdbc-default.json \
openidm/db/postgresql/conf/repo.jdbc.json \
-d /tmp/

# Putting the schema-files in new folders for optional use
cd ..
mkdir updated_postgres
mkdir -p updated_openidm/conf
cp /tmp/openidm/db/postgresql/scripts/openidm.pgsql updated_postgres/01_init.sql
cp /tmp/openidm/db/postgresql/scripts/default_schema_optimization.pgsql updated_postgres/02_optimize.sql
cp openidm/conf/datasource.jdbc-default.json updated_openidm/conf/datasource.jdbc-default.old
cp openidm/conf/repo.jdbc.json updated_openidm/conf/repo.jdbc.old
cp /tmp/openidm/db/postgresql/conf/datasource.jdbc-default.json updated_openidm/conf/datasource.jdbc-default.json
cp /tmp/openidm/db/postgresql/conf/repo.jdbc.json updated_openidm/conf/repo.jdbc.json
rm -r /tmp/openidm

