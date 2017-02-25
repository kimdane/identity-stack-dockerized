
JWT_SRC = \
	src/jose/apr_jwt.c \
	src/jose/apr_jwk.c \
	src/jose/apr_jws.c \
	src/jose/apr_jwe.c

JWT_HDRS = \
	src/jose/apr_jose.h

# Source files. mod_auth_openidc.c must be the first file.
SRC=src/mod_auth_openidc.c \
	src/cache/file.c \
	src/cache/memcache.c \
	src/cache/shm.c \
	src/cache/lock.c \
	src/oauth.c \
	src/proto.c \
	src/crypto.c \
	src/config.c \
	src/util.c \
	src/authz.c \
	src/session.c \
	src/metadata.c \
	$(JWT_SRC)

ifeq (0, 1)
SRC += \
	src/cache/redis.c	
REDIS_CFLAGS=-DUSE_LIBHIREDIS 
REDIS_LIBS=
endif

HDRS = \
	$(JWT_HDRS) \
	src/mod_auth_openidc.h \
	src/cache/cache.h

# Files to include when making a .tar.gz-file for distribution
DISTFILES=$(SRC) \
	$(HDRS) \
	test/test.c \
	test/stub.c \
	configure \
	configure.ac \
	Makefile.in \
	autogen.sh \
	INSTALL \
	README.md \
	AUTHORS \
	DISCLAIMER \
	auth_openidc.conf \
	LICENSE.txt \
	ChangeLog

all: src/mod_auth_openidc.la

CFLAGS=    -I/usr/local/include     $(REDIS_CFLAGS)
LIBS=-lssl -lcrypto   -lcurl   -L/usr/local/lib -ljansson   /usr/lib64/ $(REDIS_LIBS)

src/mod_auth_openidc.la: $(SRC) $(HDRS)
	/usr/sbin/apxs  -Wc,"-DNAMEVER=\"mod_auth_openidc-1.8.9rc4\" $(CFLAGS)" -Wl,"$(LIBS)" -Wc,-Wall -Wc,-g -c $(SRC)

configure:	configure.ac
	./autogen.sh

mod_auth_openidc-1.8.9rc4.tar.gz:	 $(DISTFILES)
	tar -c --transform="s#^#mod_auth_openidc-1.8.9rc4/#" -vzf $@ $(DISTFILES)

test/test: test/*.c src/mod_auth_openidc.la
	/usr/sbin/apxs  $(CFLAGS) -Wl,"$(LIBS)" -Isrc -Wc,-Wall -Wc,-g -c -o $@ test/*.c $(SRC:.c=.lo) -laprutil-1 -lldap -llber -lexpat -ldb-4.7 -lapr-1 -lpthread -ldl  

test-compile: test/test

test: test-compile
	test/test

.PHONY:	install
install: src/mod_auth_openidc.la
	/usr/sbin/apxs  -i -n mod_auth_openidc src/mod_auth_openidc.la

.PHONY: distfile
distfile:	mod_auth_openidc-1.8.9rc4.tar.gz

.PHONY:	clean
clean:
	rm -f src/mod_auth_openidc.la
	rm -f src/*.o src/cache/*.o src/jose/*.o test/*.o
	rm -f src/*.lo src/cache/*.lo src/jose/*.lo test/*.lo
	rm -f src/*.slo src/cache/*.slo src/jose/*.slo test/*.slo
	rm -rf src/.libs/ src/cache/.libs/ src/jose/.libs/ test/.libs
	rm -rf test/test

.PHONY:	distclean
distclean:	clean
	rm -f Makefile config.log config.status mod_auth_openidc-1.8.9rc4.tar.gz *~ \
	build-stamp config.guess config.sub
	rm -rf debian/mod-auth_openidc
	rm -f debian/files

.PHONY: fullclean
fullclean:	distclean
	rm -f configure aclocal.m4
