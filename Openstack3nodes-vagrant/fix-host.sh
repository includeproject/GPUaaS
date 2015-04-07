#!/bin/sh

set -e

HOST=$1
DOMAIN=${2:-includep.org}

if [ -z $HOST ]; then
  echo "Must specify hostname! ($0 <host>)" >&2
  exit 1
fi

echo $HOST > /etc/hostname

# configuring services

# Uncomment this if you are using your own centos-7 box
#sudo systemctl disable firewalld
#sudo systemctl stop firewalld
#sudo systemctl disable NetworkManager
#sudo systemctl stop NetworkManager
#sudo chkconfig network on
#sudo systemctl restart network 


cat > /etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       $HOST.$DOMAIN $HOST

# puppet-master node
10.0.0.9 puppet.includep.org

# controller node
10.0.0.11
# network node
10.0.0.21
# compute node
10.0.0.31
EOF

cp /tmp/network-config/$HOST/* /etc/sysconfig/network-scripts
sudo systemctl restart network

if [ $? == 0 ]
  then
    echo "Networking OK"
    echo "Testing network connectivity"
    ping -c 4 puppet.$DOMAIN
    if [ $? == 0 ]
      then
        echo "Local connectivity OK"
    fi
    ping -c 4 openstack.org
    if [ $? == 0 ]
      then
          echo "Internet access OK"
    fi
    echo "Installing puppet"
fi


sudo yum -y install puppet
if [ $? == 0 ]
  then
    echo "Puppet installed successfully"
fi
echo "configuring puppet"
sudo sed -i "12 a\ server = puppet.$DOMAIN" /etc/puppet/puppet.conf
echo "done"
echo "Retrieving the certificate signed by the puppet-master"
sudo puppet agent -t
if [ $? == 0 ]
  then
      echo "Certificate received"
fi
# NOT WORKING... these lines should create and inject ssh key-pair to the
# puppetmaster node in order to execute the last command:
# # packastack answerfile=/packstack/ans.txt

#echo "creating ssh key-pair"
#su -c "echo -e "\n\n\n" | ssh-keygen" - vagrant
#su -c "ssh-keygen -q -N \"\" -f .ssh/id_rsa" - vagrant
#echo "uploading to puppet-master"
#echo -e "yes\nvagrant\n" | su -c "ssh-copy-id -i .ssh/id_rsa.pub root:vagrant@puppet.includep.org" - vagrant
echo "$HOST OK."
