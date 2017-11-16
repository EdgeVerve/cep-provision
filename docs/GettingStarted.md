# Getting Started

## Pre-Requisites

* Linux based  - CentOS > 7 or RHEL > 7 (64 bit)
* Ansible (version > 2.2.0)

### Install CEP

You can follow the below steps to setup a CEP environment either in Public CLoud VMs (AWS, Azure etc), Private Cloud VMs or locally.
 
To begin with, get the source code

```
git clone https://github.com/EdgeVerve/cep-provision.git
```
Navigate to the cloned folder and modify Inventory File(Inventory_CEP for default) to add the details of your machines,

* *[manager]* - Add the machine details which needs to be created as manager mode in docker swarm cluster.

* *[worker]* - Add the machines details which needs to be created as worker mode in docker swarm cluster. Note, a machine can be both manger and worker.

Machine details has to be in following format:

```10.66.96.66  ansible_ssh_user=user ansible_ssh_pass=password ansible_become=true ansible_become_method=sudo ansible_become_pass=password```

> Machine Ip: IP of the machine

> ansible_ssh_user: The default ssh user name to use

> ansible_ssh_pass: The ssh password to use [optional if trust setup is done]

> ansible_become: This allows to force privilege escalation. [should be "yes"]

> ansible_become_method: Allows to set previlege escalation method [should be "sudo"]

> ansible_become_pass: Allows to set the previlege escalation password. [optional if trust setup is done]


Now go ahead and set Environment variables http_proxy, https_proxy, no_proxy. This is required if you use a proxy to access internet. 

```
export http_proxy=http://username:urlencodedpassword@proxyIp:port
export https_proxy=http://username:urlencodedpassword@proxyIp:port
export no_proxy=whatever no proxy ip addresses/domain names needed
```


set the following Environment variable required for Ansible

```
export ANSIBLE_SCP_IF_SSH=y 
export ANSIBLE_HOST_KEY_CHECKING=False
```
* ANSIBLE_SCP_IF_SSH - set to Y if SFTP is not enabled in the remote machines.
* ANSIBLE_HOST_KEY_CHECKING - set to True if a host is reinstalled and has a different key in �known_hosts�, this will result in an error message until corrected.

Now we will start the play to go ahead and install CEP. 

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko
```
It will ask for inputs. Here's the description of each question it asks 

* **Set Domain Name to access application/services(DNS should support \*.domainname)**: This is the subdomain you are going to use to access the services hosted on CEP. e.g. if you give cepapp.qa as input, the applications you deploy on the CEP will be accessible as https://application.cepapp.qa. 

* **Docker storage lvm setup required**: By default you can use any kind of storage for docker daemon to store it's files,the recommendation is to have a lvm storage. The Ansible script can create a lvm storage from unmounted space for you.

* **Docker storage setup required**: The ansible will convert the unmounted space to lvm storage and configure the docker daemon to use it. Specify unmounted storage path.

* **Do you want setup NFS Server to persist CEP Component data**: The ansible will setup NFS server on the machine specified in [NFSServer] group in inventory file and enable access to all the host machines in the cluster. 

* **Specify NFS Server share Folder (required if NFS Server setup is yes)**: The NFS share path will be mounted in all host machines for persisting CEP component datas like registry, grafana, portainer etc. 

* **Specify an folder for CEP config files and Docker data (eg: /datadisk)**: This is the folder on which CEP config files and data will be stored.
 
* **Install CEP Portal - Portainer - yes/no**: This can help in container management like check service logs etc.

* **Install Monitoring Service - Prometheus-Grafana**: This will setup monitoring for your environment.

* **Install Gitlab Service - yes/no**: This can help you install gitlab as a service.

* **Install Logging Service - Graylog - yes/no**: This will setup graylog for your environment as a centralized logging server.

Provide responses for the prompts. 

CEP install script stores the given responses and suggests the given input as default value next time you run the script. Alternatively, to set these parameters without the script asking for it, you can add these variables with your inputs in group_vars/all file like this,

```
domainname: cepapp.qa
cepfolder: /datadisk
installgitlab: False
installcepui: True
directLVMstorage: False
docker_storage_devs: ""
installgraylog: False
installmonitor: True
setupNFS: True
nfsSharePath: /nfsshare
installAutoScale: True
```

Once these values are stored in this file, the script reads from this and suggests default from this. To skip the prompt part you can run the following command,

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko --skip-tags "variable_setup"
```

The execution takes few minutes to complete and you can trace the execution steps in the command prompt. Post successful completion, CEP infrastructure will be ready for use.

You can check if CEP is up by accessing

```
curl -k https://registry.cepapp.qa/v2/_catalog
```
The above command should return a valid json which would prove that CEP is up and a docker registry is running on it. 

### Add Node

To Add Node into existing CEP infrastructure, please add node details in inventory file either in Manager group or worker group or both  and run below command,

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko
```

### Uninstall CEP

To Uninstall CEP infrastructure, Please run the below command

```
ansible-playbook --flush-cache CEP_Uninstall.yml -i Inventory_CEP
```
Provide responses for the prompts to complete uninstallation. To run as a single command instead of interactive prompts, use the below command with preset inputs.
```
ansible-playbook --flush-cache CEP_Uninstall.yml -i Inventory_CEP --extra-vars "CONFIRM=yes DomainName=cepapp.qa cepfolder=/datadisk"
```

## Run feature-specific mode of CEP
It is possible to run CEP with configuration to install only some specific feature or skip some feature. This can be achieved by adding 'tags' or 'skip-tags' flag with install CEP command.

The supported tags are:

**variable_setup**: Change/create setup configuration.

**pre_check**: Do pre-check of nodes to find if nodes are supported by CEP

**cert_gen**: Generate self-signed certificates that can be used for docker daemon and/or router ssl termination.

**nfs_server_setup**: Setup nfs server for persistence storage.

**docker_storage**: setup docker storage driver recommended by docker for specific OS

**certs**: install self-siged certificates

**install_docker**: Install docker-ce to all nodes.

**setup_cleanup_cron**: Setup cron to clean-up garbage volume/image/container generated by docker runtime.

**cadvisor**: Setup cadvisor as a service in all nodes.

**swarm_setup**: Setup swarm with the nodes specified in inventory file.

**router**: Setup router which will generate dynamic URL based on deployed application

**private_registry**: Setup private registry to serve private docker images.

**cep_portal**: Deploy Container Management Portal.

**gitlab**: Deploy gitlab in CEP.

**graylog**: Deploy logging service in CEP

**monitoring**: Setup and deploy monitoring components.

**auto-scaling**: Setup and deploy auto-scaling components

### To run specific task(s) on CEP

Example: To run swarm_setup with router where it is assumed that you have already have docker setup on nodes then you have to run,

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko --tags "swarm_setup,router"
```

### To skip specific task(s) on CEP
```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko --skip-tags "auto-scaling"
```

## Pre-check of CEP
CEP install script has a feature to test the nodes to see if it has pre-requisite access/packages before installing CEP on nodes.

Depending upon pass/fail status of node, the script will show what is the scan status and continue running on eligible nodes by default. If you only need to run pre_check first time, you can run,

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko --tags "pre_check"
```

This will show scan result of each node separately if the node is eligible for CEP Installation.

![pre_check_picture](pre-check.png)


## Note:

1. CEP install script stores certificates, configuration in the same folder where the code has been downloaded. If you decide to delete the folder, make sure to backup following files,

	a. SSL Certificates generated in SSLCertificates/.
	
	b. configuration on group_vars/all.
	
	c. Inventory on Inventory_CEP.
	
   Once you need to run the script again, restore these files before running the script.