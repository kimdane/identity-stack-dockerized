# HOW TO

## Install (after installing docker)
Evry container will try to download binaries, but if you mount the repo and update the binaries you will only need to download them once.

	$ git clone https://github.com/ConductAS/identity-stack-dockerized.git repo
	$ cd repo
	$ ./update-binaries.sh

The update also fetches some new config files in separate folders for OpenIDM, which you might need if the default database schema has changed.

## Mount repository into a volume
"If you are using Docker Machine on Mac or Windows, your Docker daemon has only limited access to your OS X or Windows filesystem." So make sure you use a path starting with /Users/ or /c/Users/ for OS X and Windows.

    $ docker create --name repo -v $(pwd)/repo:/opt/repo debian:jessie /bin/true

## Start containers
	$ docker run -d --name opendj --volumes-from repo conductdocker/opendj-nightly
	$ docker run -d --link opendj --name openam-svc-a --volumes-from repo conductdocker/openam-nightly
	$ docker run -d --link opendj --name openam-svc-b --volumes-from repo conductdocker/openam-nightly
	$ docker run -d --name postgres -e POSTGRES_PASSWORD=openidm -e POSTGRES_USER=openidm -v $(pwd)/repo/postgres:/docker-entrypoint-initdb.d postgres
	$ docker run -d --link opendj --link postgres --name openidm --volumes-from repo conductdocker/openidm-nightly
	$ docker run -d -p 443:443 -p 80:80 -p 636:636 -p 389:389 --restart=always --link opendj --link openam-svc-a --link openam-svc-b --link openidm --name iam.example.com conductdocker/haproxy-iam
	$ docker run --rm --link openam-svc-a --link openam-svc-b --link opendj --name ssoconfig --volumes-from repo conductdocker/ssoconfig-nightly

(You might need to run the last container twice if configuration fails first time.)

### Optional volumes
	$ mkdir $(pwd)/pgdata
-e PGDATA=/usr/local/postgresql/data/pgdata -v $(pwd)/pgdata:/var/lib/postgresql/data/pgdata 

	$ mkdir -p $(pwd)/logs/openidm
-v $(pwd)/logs/openidm:/opt/openidm/logs 

	$ mkdir -p $(pwd)/logs/openam-svc-a/log
-v $(pwd)/logs/openam-svc-a/log:/root/openam/openam/debug

	$ mkdir -p $(pwd)/logs/openam-svc-a/debug
-v $(pwd)/logs/openam-svc-a/debug:/root/openam/openam/debug

## Use
Update /etc/hosts with the IP of your docker host and openam.example.com as an alias

	$ sudo -Es 'echo $(echo $DOCKER_HOST | egrep -o "\b(?:\d{1,3}\.){3}\d{1,3}\b") iam.example.com >> /etc/hosts' 

#### Self service OpenIDM
http://iam.example.com/
#### Admin console OpenIDM
http://iam.example.com/admin
#### Admin console OpenAM
http://iam.example.com/openam
#### LDAP (use curl or LDAP browser)
ldap://iam.example.com/dc=example,dc=com
