#!/bin/bash
#Clean up docker engine - images, containers, networks, volumes

docker system prune -fa >> /datadisk/evfpaas/cleanup_prune.log

#clean up registry data

docker exec -it `docker ps | grep private_registry | awk '{print $1}' | head -1` /bin/registry garbage-collect /etc/docker/registry/config.yml >> /datadisk/evfpaas/cleanup_registry.log
