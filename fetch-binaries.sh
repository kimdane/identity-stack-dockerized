#!/bin/bash

#mkdir openidm
#mkdir postgres

#echo -n "Input your ForgeRock Backstage username: "
#read USERNAME
#echo -n "Input your ForgeRock Backstage password: "
#read -s PASSWORD
#if [ "`curl -s -u $USERNAME:$PASSWORD -o /dev/null -w "%{http_code}" http://maven.forgerock.org:80/repo/forgerock-virtual/`" == "200" ];then 
#	echo "Username and password accepted";
#else 
#	echo "Incorrect username or password";
#fi

## Get openidm openam opendj and openig from ForgeRocks nightly builds GitHub repo

# Top level variables -edit these as appropriate

MVN_SNAPSHOT="http://maven.forgerock.org:80/repo/releases"


AM_VERSION="13.5.0"
IDM_VERSION="4.0.0"
IG_VERSION="4.0.0"
DJ_VERSION="3.0.0"

$stable = "y"

#echo -n "Use stable releases? [Y/n]: "
#read stable
if [ "$stable" == "n" ]; then
	MVN_SNAPSHOT="http://maven.forgerock.org:80/repo/forgerock-virtual"
	AM_VERSION="14.0.1-SNAPSHOT"
	IDM_VERSION="4.5.1-SNAPSHOT"
	IG_VERSION="4.0.0"
	DJ_VERSION="4.0.0-SNAPSHOT"
	
	echo -n "OpenAM version [$AM_VERSION]: "
	read AM
	if [ ! -z "${AM}" ]; then $AM_VERSION=$AM;fi
	echo -n "OpenIDM version [$IDM_VERSION]: "
	read IDM
	if [ ! -z "${IDM}" ]; then $IDM_VERSION=$IDM;fi
	echo -n "OpenDJ version [$DJ_VERSION]: "
	read DJ
	if [ ! -z "${DJ}" ]; then $DJ_VERSION=$DJ;fi
	echo -n "OpenIG version [$IG_VERSION]: "
	read IG
	if [ ! -z "${IG}" ]; then $IG_VERSION=$IG;fi
fi

# note trailing / is needed
AM_SERVER_PATH="$MVN_SNAPSHOT/org/forgerock/openam/openam-server/$AM_VERSION/"
AM_SSOTOOLS_PATH="$MVN_SNAPSHOT/org/forgerock/openam/openam-distribution-ssoadmintools/$AM_VERSION/"
AM_SSOCONFIGTOOLS_PATH="$MVN_SNAPSHOT/org/forgerock/openam/openam-distribution-ssoconfiguratortools/$AM_VERSION/"

IDM_PATH="$MVN_SNAPSHOT/org/forgerock/openidm/openidm-zip/$IDM_VERSION/"
IG_PATH="$MVN_SNAPSHOT/org/forgerock/openig/openig-war/$IG_VERSION/"
DJ_PATH="$MVN_SNAPSHOT/org/forgerock/opendj/opendj-server-legacy/$DJ_VERSION/"

# Directory to download to
dir=./bin/staging/


# These are the items you can download. tomcat, apache,jetty refer to agents
#items="openam ssoadm openidm openig opendj apache tomcat jetty"
items="openam ssoconfig openidm openig opendj"

# If no args are supplied - all of the above assets are downloaded. If args are supplied
# just the named items are downloaded.
if [ $# -gt 0 ]; then
   items=$*
fi

# Default GNU Grep to use Perl regex
GREP="grep -o -P"
# Mac used BSD grep
if [ "`uname`" == "Darwin" ]; then
GREP="egrep -o"
fi

# If you want to force a fresh download uncomment this
# rm -fr $dir

mkdir -p $dir
cd $dir


# Download a file at URL $1 name it $2
download_file() {
   if [ ! -f $2 ]; then
      echo $1 >>RELEASE
      echo downloading $RELEASE
      echo $1 | xargs curl -u $USERNAME:$PASSWORD -o $2
   else
      # File already downloaded. log this to the release file and to the console
      echo "File $2 exists - Skipping. Delete this file if you really want to download a fresh version" >>RELEASE
      echo $2 already downloaded. Skipping
   fi
}

# function to parse a filename from an http dir listing path $1 with extension $2 (e.g. zip war etc.)
grep_file() {
   x=`curl -u $USERNAME:$PASSWORD -s $1 | $GREP  \".*?\.$2\" | tr -d \"`
   echo $1$x
}


# TOOD: Improve agent download process

# Apache Agent
# This script is quite specfific to Linux 64 bit VMs. You may want to make it more generic...
# TODO Have not quite figured out to scrape the Web Agent screen yet.
apache(){
APACHE="apache_v24_Linux_64_agent_4.0.0-SNAPSHOT.zip"
apache="http://download.forgerock.org/downloads/openam/webagents/nightly/Linux/$APACHE"
download_file $apache  apache_v24_agent.zip
}

# Tomcat JEE agent
tomcat(){
tomcat=`curl -s https://forgerock.org/downloads/openam-builds/ | grep -o "http://.*tomcat_v6.*\.zip" | head -1`
download_file $tomcat tomcat_agent.zip
}

# Jetty
jetty () {
jetty=`curl -s https://forgerock.org/downloads/openam-builds/ | grep -o "http://.*jetty_v7.*\.zip" | head -1`
download_file $jetty jetty_agent.zip
}


echo  "#Starting download at `date`" > RELEASE

for item in $items; do
   case $item in
   openam)  download_file `grep_file $AM_SERVER_PATH war` openam.war;;
   ssoadm)  download_file `grep_file $AM_SSOTOOLS_PATH zip`  ssoadmintools.zip;;
   ssoconfig) download_file `grep_file $AM_SSOCONFIGTOOLS_PATH zip` configurator.zip;;
   openidm) download_file `grep_file $IDM_PATH \.zip` openidm.zip;;
   openig)  download_file `grep_file $IG_PATH war` openig.war;;
   opendj)  download_file `grep_file $DJ_PATH zip` opendj.zip;;
   apache)  apache;;
   tomcat)  tomcat;;
   jetty)   jetty;;
   *)    echo "Invalid download asset name $item"
   esac
done

echo "# Finished download at `date`" >> RELEASE
unset USERNAME
unset PASSWORD

# Get filebeat deb-files for logging with logstash
#curl https://www.elastic.co/downloads/beats/filebeat \
#	| grep -o "\"https:[^:]*amd64.deb\"" | xargs curl -O

# Fetching sources from Git
#mkdir openidm
#cd openidm
#git init
#git remote add -f origin https://stash.forgerock.org/scm/openidm/openidm-public.git
#git config core.sparseCheckout true
#echo "openidm-public/openidm-zip/src/main/resources/*" >> .git/info/sparse-checkout
#git pull origin master

## Unziping and extracting schema-files from openidm to postgres
unzip openidm.zip \
openidm/db/postgresql/scripts/openidm.pgsql \
openidm/db/postgresql/scripts/default_schema_optimization.pgsql \
openidm/db/postgresql/conf/datasource.jdbc-default.json \
openidm/db/postgresql/conf/repo.jdbc.json \
-d /tmp/

# Putting the schema-files in new folders for optional use
cd ../../
#mkdir updated_postgres
#mkdir -p updated_openidm/conf
cp /tmp/openidm/db/postgresql/scripts/openidm.pgsql postgres/01_init.sql
cp /tmp/openidm/db/postgresql/scripts/default_schema_optimization.pgsql postgres/02_optimize.sql
cp openidm/conf/datasource.jdbc-default.json openidm/conf/datasource.jdbc-default.old
cp openidm/conf/repo.jdbc.json openidm/conf/repo.jdbc.old
cp /tmp/openidm/db/postgresql/conf/datasource.jdbc-default.json openidm/conf/datasource.jdbc-default.json
cp /tmp/openidm/db/postgresql/conf/repo.jdbc.json openidm/conf/repo.jdbc.json
if [ "$(uname)" == "Darwin" ]; then
	sed -i '' 's/localhost:5432/postgres:5432/g' openidm/conf/datasource.jdbc-default.json
else
	sed -i 's/localhost:5432/postgres:5432/g' openidm/conf/datasource.jdbc-default.json
fi

