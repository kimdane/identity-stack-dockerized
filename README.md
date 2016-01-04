# HOW TO

## Install (after installing docker)
	$ mkdir -p /usr/local/id-stack/
	$ git clone https://github.com/ConductAS/identity-stack-dockerized.git /usr/local/id-stack/repo
	$ cd /usr/local/id-stack/repo
	$ chmod +x update-binaries.sh 
	$ ./update-binaries.sh


## Start containers
	$ docker run -d --name opendj -v /usr/local/id-stack/repo:/opt/repo conductdocker/opendj-nightly
	$ docker run -d --link opendj --name openam-svc-a -v /usr/local/id-stack/repo:/opt/repo conductdocker/openam-nightly
	$ docker run -d --link opendj --name openam-svc-b -v /usr/local/id-stack/repo:/opt/repo conductdocker/openam-nightly
	$ docker run -d --name postgres -e POSTGRES_PASSWORD=openidm -e POSTGRES_USER=openidm -v /usr/local/id-stack/repo/postgres:/docker-entrypoint-initdb.d postgres
	$ docker run --link opendj --link postgres --name openidm -v /usr/local/id-stack/repo:/opt/repo conductdocker/openidm-nightly
	$ docker run -d -p 443:443 -p 80:80 -p 636:636 -p 389:389 --link opendj --link openam-svc-a --link openam-svc-b --link openidm --name iam.example.com conductdocker/haproxy-iam
	$ docker run --rm --link openam-svc-a --link openam-svc-b --link opendj --name ssoconfig -v /usr/local/id-stack/repo:/opt/repo conductdocker/ssoconfig-nightly

## Optional volumes
	$ mkdir /usr/local/id-stack/pgdata
-e PGDATA=/usr/local/postgresql/data/pgdata -v /usr/local/id-stack/pgdata:/var/lib/postgresql/data/pgdata 

	$ mkdir -p /usr/local/id-stack/logs/openidm
-v /usr/local/id-stack/logs/openidm:/opt/openidm/logs 

	$ mkdir -p /usr/local/id-stack/logs/openam-svc-a/log
-v /usr/local/id-stack/logs/openam-svc-a/log:/root/openam/openam/debug

	$ mkdir -p /usr/local/id-stack/logs/openam-svc-a/debug
-v /usr/local/id-stack/logs/openam-svc-a/debug:/root/openam/openam/debug

## Use
Update /etc/hosts with the IP of your docker host and openam.example.com as an alias

	$ echo $DOCKER_HOST | egrep -o "\b(?:\d{1,3}\.){3}\d{1,3}\b" | xargs echo iam.example.com >> /etc/hosts

#### Self service OpenIDM
http://iam.example.com/
#### Admin console OpenIDM
http://iam.example.com/admin
#### Admin console OpenAM
http://iam.example.com/openam
#### LDAP (use curl or LDAP browser)
ldap://iam.example.com/dc=example,dc=com
