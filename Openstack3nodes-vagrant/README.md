# Vagrant-Openstack-Puppet

This project aims to create a Vagrant setup to deploy Openstack with the
following setup:

1 Puppet-Master node with Openstack "Juno" modules and the packstack utility<br>
3 Puppet-Agent nodes as the basic openstack minimal arquitecture.

This deployment is for testing purposes, DO NOT USE THIS IN PRODUCTION.

Host Requirements:

* VirtualBox installed
* Vagrant installed
* git installed
* Installed Vagrant box: Puppet-Master configured with Openstack puppet/stackforge modules and the packstack utility. (provided)
* Installed Vagrant box: (CentOS 7, provided) 
* Routing rules to provide internet access to VMs (e.g. NAT iptables)<br>
`# iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE`<br>
 * enp0s3 refers to the host's network interface that provides internet access.
* ip forward bit activated<br>
`# systemctl net.ipv4.ip_forward=1`

# Host Network Scheme

According to the Openstack oficial documentation, we're going to define 3
host-only networks with the following configuration:

### vboxnet0
ip address: 10.0.0.1/24 <br>
dhcp: disabled

### vboxnet1
ip address: 10.0.1.1/24 <br>
dhcp: disabled

### vboxnet2
ip: 10.0.10.254/24 <br>
dhcp: disabled

# Deployment Guide

First, download this repository:<br>
`$ git clone git@github.com:includeproject/GPUaaS.git`

Then, you need to download, import and run the Openstack-PuppetMaster custom vagrant box, that we provide, in order to continue with this automated process. Of course, you can modify this virtual machine if you want to have a specific release of Openstack. In this Vagrant setup, we support the "Juno" release and we are looking for support the "Kilo" release in the near future.

### Downloading the Vagrant Boxes

In this step, we are going to create a local copy of the boxes that we need to run our instances. For now, the puppetmaster-box that we provide is mandatory because we it has a preconfigured puppet box with a prepopulate packstack utility. 

`$ vagrant box add erick0z/centos7-64-puppetmaster`<br>
`$ vagrant box add erick0z/centos7-64-puppet`

** If you provide your own CentOS 7 box, make sure that it has the following configuration:

* Firewalld: disabled
* NetworkManager: disabled
* network service: enabled
* EPEL 7 repository
* RDO JUNO repository
* SELINUX: permissive or disabled
* run: yum -y update

### Start the Openstack-PuppetMaster box
`$ cd GPUaaS/Puppetmaster/`<br>
`$ vagrant up`<br>

--username: vagrant<br>
--password: vagrant<br>
--rootpassword: vagrant<br>


Once we have our VM up and running we must verify for network connectivity:
`$ vagrant ssh`<br>
`$ ping 10.0.0.1`<br>
`$ ping openstack.org`

** The IP address for this VM should be 10.0.0.9/24

### Configuring the Puppet-Master node

By default, we have a pre-populate packstack/ directory in /root with an ans.txt file inside,  this file controls the whole configuration and installation of this Openstack enviroment. Feel free to modify this file and change whatever you consider necessary in order to fit your needs.(e.g installation of non-core modules like ironic, sahara, etc.).

### Start the 3 nodes of the Openstack enviroment
`$ cd GPUaaS/Openstack3nodes-vagrant/`<br>
`$ vagrant up`<br>

This could take some time to complete depending on your host's hardware. If you have succeded with this process, 
you can connect to your instances with `$ vagrant ssh controller`, `$ vagrant ssh network` and `$ vagrant ssh compute` <br>

Once we have our VMs up and running we must verify for network configuration:
`$ ip add` in each node to verify that the network configuration has succeded<br>


### Deploy the Openstack installation

Finally, connect to the puppetmaster node and run the packstack utility:<br>

`$ packstack --answer-file=packstack/ans.txt`<br>

The promt will ask you for the root password on each node. The default root password is: vagrant. <br>

This process will take some time depending on your network connection. If we don't see any error, we have an Openstack installation.

 
