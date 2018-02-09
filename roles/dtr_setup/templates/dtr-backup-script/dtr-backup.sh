#!/bin/bash
if [ -f {{cepfolder}}/cep-data/dtr-backup-metadata.tar ]; then
 rm -f {{cepfolder}}/cep-data/dtr-backup-metadata-1.tar | echo "dtr-backup-metadata-1.tar not present"
 mv {{cepfolder}}/cep-data/dtr-backup-metadata.tar {{cepfolder}}/cep-data/dtr-backup-metadata-1.tar
 rm -f {{cepfolder}}/cep-data/dtr-backup-metadata.tar
fi
export REPLICA_ID=`docker ps --format '{{"{{"}}.Names{{"}}"}}' | grep dtr-nginx | cut -c 11-`
echo $REPLICA_ID > {{cepfolder}}/cep-data/dtr-backup-replica-id.txt
docker run --log-driver none -i --rm  --env UCP_PASSWORD={{ucp_password}}   {{dtr}} backup   --ucp-url {{inventory_hostname}}:4433 --ucp-insecure-tls   --ucp-username {{ucp_username}}  --existing-replica-id $REPLICA_ID > {{cepfolder}}/cep-data/dtr-backup-metadata.tar