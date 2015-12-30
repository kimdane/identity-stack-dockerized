# HOW TO

## Install (after installing docker)
	$ mkdir -p /var/lib/id-stack/
	$ git clone https://github.com/ConductAS/identity-stack-dockerized.git /var/lib/id-stack/repo
	$ cd /var/lib/id-stack/repo
	$ chmod +x update-binaries.sh 
	$ ./update-binaries.sh


## Start containers
	$ docker run -d -p 636:636 -p 389:389 --name opendj -v /var/lib/id-stack/repo:/opt/repo conductdocker/opendj-nightly
	$ docker run -d --link opendj --name openam-svc-a -v /var/lib/id-stack/repo:/opt/repo conductdocker/openam-nightly
	$ docker run -d --link opendj --name openam-svc-b -v /var/lib/id-stack/repo:/opt/repo conductdocker/openam-nightly
	$ docker run -d --name postgres -e POSTGRES_PASSWORD=openidm -e POSTGRES_USER=openidm -v /var/lib/id-stack/repo/postgres:/docker-entrypoint-initdb.d postgres
	$ docker run --link opendj --link postgres --name openidm -v /Users/kim/Code/iam-dockers/repo:/opt/repo conductdocker/openidm-nightly
	$ docker run -d -p 443:443 -p 80:80 --link openam-svc-a --link openam-svc-b --link openidm --name openam.example.com haproxy-iam
	$ docker run --rm --link openam-svc-a --link openam-svc-b --link opendj --name ssoconfig -v /var/lib/id-stack/repo:/opt/repo ssoconfig-nightly

## Optional volumes
	$ mkdir /var/lib/id-stack/pgdata
-e PGDATA=/var/lib/postgresql/data/pgdata -v /var/lib/id-stack/pgdata:/var/lib/postgresql/data/pgdata 

	$ mkdir -p /var/lib/id-stack/logs/openidm
-v /var/lib/id-stack/logs/openidm:/opt/openidm/logs 

	$ mkdir -p /var/lib/id-stack/logs/openam-svc-a/log
-v /var/lib/id-stack/logs/openam-svc-a/log:/root/openam/openam/debug
	$ mkdir -p /var/lib/id-stack/logs/openam-svc-a/debug
-v /var/lib/id-stack/logs/openam-svc-a/debug:/root/openam/openam/debug

## Use
###Update /etc/hosts with the IP of your docker host IP and openam.example.com alias
	$ echo $DOCKER_HOST | egrep -o "\b(?:\d{1,3}\.){3}\d{1,3}\b" | xargs echo openam.example.com >> /etc/hosts
### Self service OpenIDM
http://openam.example.com/
### Admin console OpenIDM
http://openam.example.com/admin
### Admin console OpenAM
http://openam.example.com/openam
### LDAP (use curl or LDAP browser)
ldap://openam.example.com/dc=example,dc=com
