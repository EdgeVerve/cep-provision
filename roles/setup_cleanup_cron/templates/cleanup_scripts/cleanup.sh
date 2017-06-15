#!/bin/bash
#Clean up docker engine - images, containers, networks, volumes

docker system prune -fa >> /{{cepfolder}}/cep/cleanup_prune.log

#clean up registry data

docker exec -it `docker ps | grep private_registry | awk '{print $1}' | head -1` /bin/registry garbage-collect /etc/docker/registry/config.yml >> /{{cepfolder}}/cep/cleanup_registry.log
