## Commonly faced issues and queries

> How CEP is different from Docker swarm?

CEP is different from Docker swarm in a way that it not only eases docker swarm setup by just taking the server credentials and doing the rest on its own, it creates and configures add-on services that helps to serve, manage, monitor and log deployed application.

> How CEP, as its name suggests, provides cloud enablement for application?

CEP enables developers to deploy, manage, test, monitor their application in container right from there local machine till production providing repeatable behavior throughout. In other words, if developers are able to run application successfully in their local/dev setup, the application behavior would be consistent till production given the isolating and portable nature of containers.

> What if I wanted to add/remove nodes from CEP cluster?

Adding node is seamless! You just need to add node in inventory file as described in guide and run the script. CEP will add this node to configuration of each of the supporting CEP services and Docker swarm will take care of spinning up new containers on the new node.

Removing node is a three step process. 
1. You need to remove the node from inventory file and run CEP Install script to remove the node from configuration of supporting CEP services.
2. If the node is a manager node then you need to demote the node to worker node before removing. You need to ssh into the node and do 'docker swarm leave' to make this node leave swarm.
3. Remove node from docker swarm cluster using 'docker node ls' to get the node id and 'docker node rm <node id>' to remove the node.

> What is the minimum configuration to deploy CEP cluster? 

If you choose not to have graylog / gitlab in your CEP, having three 2GB RAM/30GB HDD machine should be fine for normal usage on CEP. Again depending upon you usage you may need vertically / horizontally scale your machine(s). 
If you choose to use graylog/gitlab, it's better to have 4GB RAM per machine.

> Is it safe to run CEP script again on a working cluster?

CEP script was written in a manner that if no configuration changes for a particular node, no service of that node is turned on / turned off / restarted by CEP. If some settings has been changed on daemon level, CEP will reload and restart docker daemon.

> How can I distinguish between deployed application and CEP services as both are deployed as a docker service?

Names of CEP services start with "cep" e.g. cep_router, cep-portal etc. Make sure you know what you are doing before changing or don't tinker with these services.

> CEP Install script is unable to connect to some/all nodes mentioned in Inventory - what needs to be done?

1. Make sure you are able to do SSH directly from control machine to every nodes.
2. Make sure these two variables are added to environment,
	export ANSIBLE_SCP_IF_SSH=y 
	export ANSIBLE_HOST_KEY_CHECKING=False 
3. If first two still does not solve the issue, try changing ssh agent from '-c paramiko' to '-c openssh' and see if it works.

> What is lvm setup option in CEP script? 

LVM setup is required for docker installation on centos/rhel as recommended by docker. More information can be found [here](./docs/docker_storage.md)

> I want to use my valid certificates instead of self-signed certificate for my domain - how can I?

CEP by default serves deployed application using given domain name and SSL termination is done by self-signed certificates. You can install your own valid certificates for your domain by changing the DEFAULT_SSL_CERT environment variable on cep_router service to content of your certificate by something like this,

`docker service update cep_router --env-add DEFAULT_SSL_CERT="${cat valid.crt valid.key valid.ca}"`

Where you need to replace valid.crt , valid.key, valid.ca with the path to your certificate, key, ca file respectively.

> I am not able to access URL of application deployed in CEP, getting unable to connect server.

1. Check if host entry is added to your machine if needed. Host entry can be any of the machine on cluster.
2. Check if the URL is going through proxy. If yes, try bypassing proxy for the URL.

> I am not able to access URL of application deployed in CEP, getting 503 server unavailable.

This means browser is able to connect to the server but server is not returning proper response.

1. Check if application is deployed successfully and not giving any error in logs.
2. Check docker service ps <application name\> of the service to check if deployed service is in running condition.
3. Check if application docker service has VIRTUAL_HOST and SERVICE_PORTS variable present.
4. Check if application docker service is part of router_network.