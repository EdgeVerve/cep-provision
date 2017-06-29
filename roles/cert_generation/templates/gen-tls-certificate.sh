#!/bin/bash

while getopts ":i:d:t:c:p:e:" opt;
do     
       case $opt in
       i)  ipList="$OPTARG" >&2;;
       d)  dnsList="$OPTARG" >&2;;
       t)  target="$OPTARG" >&2;;
       c)  configPath="$OPTARG" >&2;;
       p)  passphrase="$OPTARG" >&2;;
       e)  environment="$OPTARG" >&2;;
       \?) echo "Invalid option -$OPTARG" >&2 
           exit 1
           ;;
       :) echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
       esac
done
      
target=${target%/}

echo "Alternative IPs" $ipList
echo "Alternative DNS" $dnsList
echo "Target Location" $target
echo "Config Location" $configPath

echo "Checking for existing Certificates"
if [ -e "$target/cert.pem" ] || [ -e "$target/key.pem" ]
then 
  echo "Server certificates exists! Exiting.."
  exit 0
fi

if [ -e "$target/ca.pem" ] 
then
  if [ -e "$target/ca-priv-key.pem" ] 
  then
    echo "CA certificate and key exists. Using existing ones."
    caGenNotNeeded=true
  else
    echo "CA certificate \"ca.pem\" exists but not CA key \"ca-priv-key.pem\". Please ensure both are available or let this script generate."
    exit 1
  fi
fi

if [ ! -e $configPath/openssl.cnf ]
then 
  echo "openssl.cnf not exists on $target"
  exit 1
fi

ipIncr=3
dnsIncr=3

cp $configPath/openssl.cnf /tmp/openssl.cnf

#Parsing alternative IPs to be included in certificates
if [ ! -z "$ipList" ]; then
  arrIP=${ipList//,/ }
  echo "IP LIST:" $arrIP[1]
  for i in "$arrIP"
    do
      echo "IP.$ipIncr = $i" >> /tmp/openssl.cnf
      ipIncr=$((ipIncr + 1))
    done
fi

#Parsing alternative DNS's to be included in certificates
if [ ! -z "$dnsList" ]; then
  arrDNS=${dnsList//,/ }
  echo "DNS LIST:" $arrDNS[0]
  for i in "$arrDNS"
    do
      echo "DNS.$dnsIncr = $i" >> /tmp/openssl.cnf
      dnsIncr=$((dnsIncr + 1))
    done
fi
openssl version
#Make Client folder
mkdir -p $target/client-certs

echo "Creating CA-key"
if [ ! "$caGenNotNeeded" = true ]; then
  openssl genrsa -out $target/ca-priv-key.pem 2048
fi

echo "Creating CA-cert"
if [ ! "$caGenNotNeeded" = true ]; then
  openssl req -x509 -sha1 -new -nodes -key $target/ca-priv-key.pem -days 10000 -out $target/ca.pem -subj /CN=docker-CA-$environment
fi 

echo "Creating docker-priv-key"
openssl genrsa -out $target/key.pem 2048 

echo "Creating CSR"
openssl req -new -key $target/key.pem -out $target/cert.csr -subj /CN=docker-server-client-$environment -config /tmp/openssl.cnf

echo "Creating certificate"
openssl x509 -sha1 -req -in $target/cert.csr -CA $target/ca.pem -CAkey $target/ca-priv-key.pem -CAcreateserial -out $target/cert.pem -days 3650 -extensions v3_req -extfile /tmp/openssl.cnf

