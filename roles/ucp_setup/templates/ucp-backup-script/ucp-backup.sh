#!/bin/bash
if [ -f {{cepfolder}}/cep-data/ucp-backup.tar ]; then
 rm -f {{cepfolder}}/cep-data/ucp-backup-1.tar | echo "ucp-backup-1.tar not present"
 mv {{cepfolder}}/cep-data/ucp-backup.tar {{cepfolder}}/cep-data/ucp-backup-1.tar
 rm -f {{cepfolder}}/cep-data/ucp-backup.tar
fi
printf 'y\n' |docker container run --log-driver none --rm -i --name ucp -v /var/run/docker.sock:/var/run/docker.sock {{ucp}} backup --interactive > {{cepfolder}}/cep-data/ucp-backup.tar