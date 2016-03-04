#!/bin/bash
mkdir openidm
mkdir postgres
mkdir bin
cd bin

# Get openidm openam opendj and openig from ForgeRocks nightly builds GitHub repo
curl -o /tmp/getnightly.sh https://raw.githubusercontent.com/ForgeRock/frstack/master/bin/getnightly.sh
chmod +x /tmp/getnightly.sh 
AM="BAD"
echo -n "Use latest releases? [Y/n]: "
read nightly
if [ "$nightly" == "n" ]; then 
	AM_VERSION=$(grep "^AM_VERSION" /tmp/getnightly.sh|grep -o "[0-9]*\.[0-9]*\.[0-9]*")
	IDM_VERSION=$(grep "^IDM_VERSION" /tmp/getnightly.sh|grep -o "[0-9]*\.[0-9]*\.[0-9]*")
	DJ_VERSION=$(grep "^DJ_VERSION" /tmp/getnightly.sh|grep -o "[0-9]*\.[0-9]*\.[0-9]*")
	IG_VERSION=$(grep "^IG_VERSION" /tmp/getnightly.sh|grep -o "[0-9]*\.[0-9]*\.[0-9]*")
	echo -n "OpenAM version [$AM_VERSION]: "
	read AM
	if [ -z "${AM}" ]; then AM=$AM_VERSION;fi
	echo -n "OpenIDM version [$IDM_VERSION]: "
	read IDM
	if [ -z "${IDM}" ]; then IDM=$IDM_VERSION;fi
	echo -n "OpenDJ version [$DJ_VERSION]: "
	read DJ
	if [ -z "${DJ}" ]; then DJ=$DJ_VERSION;fi
	echo -n "OpenIG version [$IG_VERSION]: "
	read IG
	if [ -z "${IG}" ]; then IG=$IG_VERSION;fi

	if [ "$(uname)" == "Darwin" ]; then
		sed -i '' 's/^AM_VERSION.*/AM_VERSION="'$AM'-SNAPSHOT"/' /tmp/getnightly.sh
		sed -i '' 's/^IDM_VERSION.*/IDM_VERSION="'$IDM'-SNAPSHOT"/' /tmp/getnightly.sh
		sed -i '' 's/^DJ_VERSION.*/DJ_VERSION="'$DJ'-SNAPSHOT"/' /tmp/getnightly.sh
		sed -i '' 's/^IG_VERSION.*/IG_VERSION="'$IG'-SNAPSHOT"/' /tmp/getnightly.sh
	else
		sed -i 's/^AM_VERSION.*/AM_VERSION="'$AM'-SNAPSHOT"/' /tmp/getnightly.sh
		sed -i 's/^IDM_VERSION.*/IDM_VERSION="'$IDM'-SNAPSHOT"/' /tmp/getnightly.sh
		sed -i 's/^DJ_VERSION.*/DJ_VERSION="'$DJ'-SNAPSHOT"/' /tmp/getnightly.sh
		sed -i 's/^IG_VERSION.*/IG_VERSION="'$IG'-SNAPSHOT"/' /tmp/getnightly.sh
	fi
fi

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
#mkdir updated_postgres
#mkdir -p updated_openidm/conf
cp /tmp/openidm/db/postgresql/scripts/openidm.pgsql postgres/01_init.sql
cp /tmp/openidm/db/postgresql/scripts/default_schema_optimization.pgsql postgres/02_optimize.sql
cp openidm/conf/datasource.jdbc-default.json openidm/conf/datasource.jdbc-default.old
cp openidm/conf/repo.jdbc.json openidm/conf/repo.jdbc.old
cp /tmp/openidm/db/postgresql/conf/datasource.jdbc-default.json openidm/conf/datasource.jdbc-default.json
cp /tmp/openidm/db/postgresql/conf/repo.jdbc.json openidm/conf/repo.jdbc.json
rm -r /tmp/openidm
if [ "$(uname)" == "Darwin" ]; then
	sed -i '' 's/localhost:5432/postgres:5432/g' openidm/conf/datasource.jdbc-default.json
else
	sed -i 's/localhost:5432/postgres:5432/g' openidm/conf/datasource.jdbc-default.json
fi

