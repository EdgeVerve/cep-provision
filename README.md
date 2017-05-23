## CEP (Cloud Enablement Platform)
CEP leverages docker swarm cluster which allows us to orchestrate docker container workloads. The CEP includes features

1. Dynamic URL Generation for services deployed in swarm 
2. Set of base docker images which applications can choose to use 
3. Docker Private Registry 
4. Service Health Checks 
5. Service monitoring
6. Service Logging
etc.

## CEP Infrastructure Provision
----------
You can follow the below steps to setup a CEP environment either in Public CLoud VMs (AWS, Azure etc), Private Cloud VM's or locally.

### Pre-Requisites:
-----------

* Linux based  - CentOS 7 or above / RHEL 7 or above, 64 bit. You can chose to use a single machine for the whole setup, However if you are doing a production like setup, the recommendation is 3 or more machines for availability reasons.
* Make sure that you have access to download softwares from the internet.  The ansible script download Docker from the Docker Repository on https://yum.dockerproject.org/repo/main/centos/7 and in addition downloads docker images from https://hub.docker.com
* Ansible \^2.2.0

    In order to install ansible, please run the below command in the Controller Machine.

    ```
    sudo yum install -y epel-release
    sudo yum install -y ansible
    ```
* Git

    In order to install git, please run the below command.

    ```
    sudo yum install -y git 
    ```
 
> Note: To Setup in RHEL  Machines, make sure that enterprise subscription is enabled, otherwise the ansible scripts may fail.
 
## Infrastructure I have for this tutorial:
-----------
For this tutorial let's assume that you have 3 machines. We will use one of the machines (Called ControllerMachine henceforth) as the controller machine where ansible will run to setup the CEP on the 3 machines (Called SwarmMachine henceforth).

The 3 machines I have are 
* Controller Machine : 10.0.0.8 
* Docker Swarm Machine : 10.0.0.8, 10.0.0.9 and 10.0.0.10

I have a sudo user called user1 on all 3 machines. You can see that controller machine will be a swarm machine as well. 

Let's start with the installation now. We will first setup the controller machine to ensure that we can execute the ansible script from there. SSH into the Controller Machine using the user user1
```
ssh user1@10.0.0.8 
```

To begin installing the CEP we would need to clone infra provision project from [github](https://github.com/EdgeVerve/cep-provision.git).  


Get the source code
```
git clone https://github.com/EdgeVerve/cep-provision.git
```

Navigate to the cloned folder 

You would see lot of yml files on the file system, The most interesting ones are 

* *CEP_Install.yml* : This is the yml file which has the ansible play to install CEP. 
* *CEP_Uninstall.yml* : This play will help you uninstall CEP.  

Apart from the above plays the most important file which needs to be configured by anyone installing CEP is `Inventory_CEP`. This file contains the configuration details for your landscape. Let's examine and configure it.

Inventory File structure includes below groups<br>

&nbsp;&nbsp;*[manager]* - You should put the details of the swarm machines here. These machines will create the docker swarm in the manager mode. (provide atleast two machines for primary & replica). You can have upto 7 Swarm Masters in a swarm cluster. Remember the larger the number of masters, the better the availability however the performance does suffer since elections do take more time then.<br>
&nbsp;&nbsp;*[worker]* - In this case we are going to put the details of swarm machines here. In case you decide to create a large swarm, you can have as many swarm nodes as you want. Remember Swarm Masters can double up as swarm nodes. <br>

Edit the inventory file and put the details of your machines in this file. 

Now go ahead and set Environment variables http_proxy, https_proxy, no_proxy. This is required if you use a proxy to access internet. 

```
export http_proxy=http://username:urlencodedpassword@proxyIp:port
export https_proxy=http://username:urlencodedpassword@proxyIp:port
export no_proxy=whatever no proxy things you need
```

Also set Environment variable needed for Ansible.

```
export ANSIBLE_SCP_IF_SSH=y 
export ANSIBLE_HOST_KEY_CHECKING=False
```
Now we will start the play to go ahead and install the CEP. 

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko
```
It will ask for inputs. Here's the description of each question it asks 

* *Do you want to perform Yum Update - yes/no [no]*: In general the recommendation is to say yes. This ensures that you have latest updates installed from RHEL/CentOS. If you have certain guidelines from your network admin you can chose to say no.
* *Set Domain Name to access application/services(DNS should support *.domainname) [cepapp.dev]*: This is the subdomain you are going to use to access the services hosted on CEP. e.g. if you give cepapp.qa as input, the applications you deploy on the CEP will be accessible as https://application.cepapp.qa . You need to ensure that there's a DNS entry made to resolve *.cepapp.qa to the IP of the Pilot Machine. If you can't make an entry in the DNS servers, then you'd need to use host file entries to resolve the domain names correctly from the client machines.
* *Specify an folder for CEP config files and Docker data (eg: /datadisk)*: This is the folder on which CEP config files and data will be stored.
* *Install Gitlab - yes/no [no]*: This can help you install gitlab as a service.
* *Install CEP Portal - Portainer - yes/no [no]*: This can help in container management like check service logs etc.
* *Docker storage lvm setup required [no]*: By default you can use any kind of storage for docker daemon to store it's files,the recommendation is to have a lvm storage. The Ansible script can create a lvm storage from unmounted space for you.
* *Docker storage setup required [/dev/sdb]*: The ansible will convert the unmounted space to lvm storage and configure the docker daemon to use it. Specify unmounted storage path 
* *Install Monitoring Service - Prometheus-Grafana*: This will setup monitoring for your environment.
* *Install Gitlab Service*: This will setup logging for your environment.

Provide responses for the prompts. To run as a single command instead of interactive prompts, use the below command with preset inputs.

```
ANSIBLE_SCP_IF_SSH=y ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko  --extra-vars "YumUpdate=yes DomainName=cepapp.qa cepfolder=/data InstallGitlab= cepUI=yes cepmon=yes cepGraylog= DirectLVMstorage=yes Docker_storage_devs=/dev/sdb"
```

* ANSIBLE_SCP_IF_SSH - set to Y if SFTP is not enabled in the remote machines.
* ANSIBLE_HOST_KEY_CHECKING - set to True if a host is reinstalled and has a different key in ‘known_hosts’, this will result in an error message until corrected.

The execution takes few minutes to complete and you can trace the execution steps in the command prompt. Post successful completion, CEP infrastructure will be ready for use.

You can check if CEP is up or not by doing 

```
curl -k https://registry.cepapp.qa/v2/_catalog
```
The above command should return a valid json which would prove that CEP is up and a docker registry is running on it. 

### Add Node
------

To Add Node into existing CEP infrastructure, please add node details in inventory file either in Manager group or worker group or both  and run below command,

```
ansible-playbook --flush-cache CEP_Install.yml -i Inventory_CEP -c paramiko
```

### Uninstall CEP
------

To Uninstall CEP infrastructure, Please run the below command

```
ansible-playbook --flush-cache CEP_Uninstall.yml -i Inventory_CEP
```
Provide responses for the prompts to complete uninstallation. To run as a single command instead of interactive prompts, use the below command with preset inputs.
```
ansible-playbook --flush-cache CEP_Uninstall.yml -i Inventory_CEP --extra-vars "CONFIRM=yes DomainName=cepapp.qa ceppaasfolder=/datadisk"
```

## Access servers without Passwords
------------------------------

It is recommended to have password less access to the servers to prevent password leak from Inventory file. To have this, one need to setup trust and add password less sudo access for the ansible user. Follow the steps mentioned to achieve this (taken from [SSH key setup](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)),

1. Generate public key in host machine
```
ssh-keygen -t rsa
```
2. Copy public key to target machines to setup trust
```
ssh-copy-id <user>@<target ip>
```
3. Add password less sudo access on servers
```
vi /etc/sudoers
#uncomment the following line
wheel ALL=(ALL) NOPASSWD:ALL
```
These steps will ensure password less access to servers and only mentioning the target ip and user in Inventory file is enough for ansible script to connect and form CEP infrastructure.

## Docker storage setup
-----------------------
By default, Docker puts data and metadata on a loop device backed by a sparse file.	This is great from a usability point of view (zero configuration needed) but terrible from a performance point of view.
To resolve this, real block devices should be provisioned for docker and docker needs to be configured to use direct-lvm storage driver.

To provision this, docker needs an unmounted storage space. Following commands lists the mounted devices, 
```
df -aTh
```
The device can be unmounted using the following command where /dev/sdb is the storage required.
```
umount /dev/sdb
```
If any process is restricting it from being mounted you can check for other mountpoints and check for blocking processes by following commands
```
fuser /dev/sdb
lsof /dev/sdb
```
After unmounting you can give input or append in existing ansible install command as follows.
This will **format** the /dev/sdb storage and provision it to be used with docker. Any data inside the partrition would be destroyed.
```
DirectLVMstorage=yes Docker_storage_devs=/dev/sdb
```
Docker daemon would also be configured by ansible script to use the specified volume as image and container storage.