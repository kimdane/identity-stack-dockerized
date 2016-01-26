#!/bin/bash
sudo rm -rf  persistence

sed -i 's/\(.* #Persistence\)$/#Persistence\1/' docker-compose.yml
