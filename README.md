# HOW TO

## Download binaries from ForgeRock nightly builds
Evry container will try to download binaries on it's own, but if you update the binaries and mount the repository as a docker volume they will not need to be downloaded each time you create a new stack.

	$ ./fetch-binaries.sh

The update also fetches some new config files into separate folders for OpenIDM and PostgreSQL, which you might need if the default database schema has changed.

## Mount repository into a volume and Start containers
#### With docker compose (also mounting repository as a volume)
	$ docker-compose up

#### Or without compose launching one by one
##### Mount repository into a volume
"If you are using Docker Machine on Mac or Windows, your Docker daemon has only limited access to your OS X or Windows filesystem." So make sure you use a path starting with /Users/ or /c/Users/ for OS X and Windows.

    $ docker create --name repo -v $(pwd):/opt/repo debian:jessie /bin/true

##### Start containers
	$ docker run -d --name opendj --volumes-from repo conductdocker/opendj-nightly
	$ docker run -d --link opendj --name openam-svc-a --volumes-from repo conductdocker/openam-nightly
	$ docker run -d --link opendj --name openam-svc-b --volumes-from repo conductdocker/openam-nightly
	$ docker run -d --name postgres -e POSTGRES_PASSWORD=openidm -e POSTGRES_USER=openidm -v $(pwd)/postgres:/docker-entrypoint-initdb.d postgres
	$ docker run -d --link opendj --link postgres --name openidm --volumes-from repo conductdocker/openidm-nightly
	$ docker run -d -p 443:443 -p 80:80 -p 636:636 -p 389:389 --restart=always --link opendj --link openam-svc-a --link openam-svc-b --link openidm --name iam.example.com conductdocker/haproxy-iam
	$ docker run --rm --link openam-svc-a --link openam-svc-b --link opendj --name ssoconfig --volumes-from repo conductdocker/ssoconfig-nightly

(You might need to run the last container twice if configuration fails first time.)

##### Optional volumes
	$ mkdir $(pwd)/pgdata
-e PGDATA=/usr/local/postgresql/data/pgdata -v $(pwd)/pgdata:/var/lib/postgresql/data/pgdata 

	$ mkdir -p $(pwd)/logs/openidm
-v $(pwd)/logs/openidm:/opt/openidm/logs 

	$ mkdir -p $(pwd)/logs/openam-svc-a/log
-v $(pwd)/logs/openam-svc-a/log:/root/openam/openam/debug

	$ mkdir -p $(pwd)/logs/openam-svc-a/debug
-v $(pwd)/logs/openam-svc-a/debug:/root/openam/openam/debug

## Use
Update /etc/hosts with the IP of your docker host and iam.example.com as an alias

	$ sudo -Es 'echo $(echo $DOCKER_HOST | egrep -o "\b(?:\d{1,3}\.){3}\d{1,3}\b") iam.example.com >> /etc/hosts' 

(The HaProxy is also set up with TLS for HTTPS and LDAPS)

#### Self service OpenIDM (openidm-admin/openidm-admin)
http://iam.example.com/
#### Admin console OpenIDM (openidm-admin/openidm-admin)
http://iam.example.com/admin
#### Admin console OpenAM (amadmin/password)
http://iam.example.com/openam
#### LDAP (use curl or LDAP browser) (cn=directory manager/password)
ldap://iam.example.com/dc=example,dc=com

## Enabling/Disabling Persistence
By default, the containers do not include peristence and data in openAM and openDJ will be lost if the containers are destoyed.
Scripts are provided to help make it easy to enable and disable peristence.
`$ ./make-persistent.sh` will modify the docker-compose file in place to add support for persistence and `$ ./clear-persistent.sh` will remove it as well as delete the persistnece folders that have been created.
