#!/bin/bash
#Clean up docker engine - images, containers, networks, volumes

echo "" >> /{{cepfolder}}/cep/cleanup_prune.log
date >> /{{cepfolder}}/cep/cleanup_prune.log
docker system prune -fa --volumes >> /{{cepfolder}}/cep/cleanup_prune.log
