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
Now we will start the play to go ahead and install CEP. 

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko
```
It will ask for inputs. Here's the description of each question it asks 

* *Set Domain Name to access application/services(DNS should support \*.domainname) [cepapp.dev]*: This is the subdomain you are going to use to access the services hosted on CEP. e.g. if you give cepapp.qa as input, the applications you deploy on the CEP will be accessible as https://application.cepapp.qa. 

* *Docker storage lvm setup required [no]*: By default you can use any kind of storage for docker daemon to store it's files,the recommendation is to have a lvm storage. The Ansible script can create a lvm storage from unmounted space for you.

* *Docker storage setup required [/dev/sdb]*: The ansible will convert the unmounted space to lvm storage and configure the docker daemon to use it. Specify unmounted storage path.

* *Do you want setup NFS Server to persist CEP Component data*: The ansible will setup NFS server on the machine specified in [NFSServer] group in inventory file and enable access to all the host machines in the cluster. 

* *Specify NFS Server share Folder (required if NFS Server setup is yes)*: The NFS share path will be mounted in all host machines for persisting CEP component datas like registry, grafana, portainer etc. 

* *Specify an folder for CEP config files and Docker data (eg: /datadisk)*: This is the folder on which CEP config files and data will be stored.
 
* *Install CEP Portal - Portainer - yes/no [no]*: This can help in container management like check service logs etc.

* *Install Monitoring Service - Prometheus-Grafana*: This will setup monitoring for your environment.

* *Install Gitlab Service - yes/no [no]*: This can help you install gitlab as a service.

* *Install Logging Service - Graylog - yes/no[no]*: This will setup graylog for your environment as a centralized logging server.

Provide responses for the prompts. To run as a single command instead of interactive prompts, use the below command with preset inputs.

```
ANSIBLE_SCP_IF_SSH=y ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko  --extra-vars "DomainName=cepapp.qa cepfolder=/data InstallGitlab= cepUI=yes cepmon=yes cepGraylog=yes DirectLVMstorage=yes Docker_storage_devs=/dev/sdb setupNFS= NFSSharepath="
```

* ANSIBLE_SCP_IF_SSH - set to Y if SFTP is not enabled in the remote machines.
* ANSIBLE_HOST_KEY_CHECKING - set to True if a host is reinstalled and has a different key in �known_hosts�, this will result in an error message until corrected.

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