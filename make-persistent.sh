#!/bin/bash
mkdir -p persistence/opendj_data
mkdir -p persistence/pgdata
mkdir -p persistence/postgres
mkdir -p persistence/repo
mkdir -p persistence/openidm

sed -i 's/^#Persistence\(.*\)/\1/' docker-compose.yml
