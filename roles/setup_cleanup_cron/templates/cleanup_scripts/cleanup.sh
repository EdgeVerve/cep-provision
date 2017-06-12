#!/bin/bash
#Clean up docker engine - images, containers, networks, volumes
 
docker system prune -a
 
#clean up registry data
 
docker exec -it `docker ps | grep private_registry | awk '{print $1}'` /bin/registry garbage-collect /etc/docker/registry/config.yml
