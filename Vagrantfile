# -*- mode: ruby -*-
# vi: set ft=ruby :

# Edit the variables between lines 7-18:

# Find your bridge interface name, e.g. with ip add or ifconfig or ipconfig
BRIDGE_IF="enp3s0"
# This will be the fixed IP address of the virtual machine
IP_ADDR_NODE01="192.168.2.1"
# Optional: fixed IP for second virtual machine

#Also adjust the 6 variables in the script section:
$script = <<-SCRIPT

IP_ADDR_NODE01="192.168.2.1"
GATEWAY="192.168.2.1"
DNS="192.168.2.1"
CLUSTER="sk-k8s"
SAN1="sk"
SAN2="sk.moonstreet.local"

echo "copy install script"
wget https://raw.githubusercontent.com/jacqinthebox/vagrant-kubernetes/master/kubernetes-vagrant-install.sh && chmod u=rwx kubernetes-vagrant-install.sh && chown vagrant.vagrant kubernetes-vagrant-install.sh

if [ ! -f /tmp/50-vagrant.yaml ]; then
  echo "adding gateway"
  cp /etc/netplan/50-vagrant.yaml /tmp/
cat << EOF >> /etc/netplan/50-vagrant.yaml
      gateway4: $GATEWAY
      nameservers:
        addresses: [$DNS,9.9.9.9]
EOF

netplan --debug generate
netplan --debug apply

fi
echo "configuring SSH to allow passwords"
sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
echo "restarting ssh service"
service ssh restart
echo "sshd has been restarted"

echo "installing kubernetes"
echo "running command ./kubernetes-vagrant-install.sh ${CLUSTER} ${IP_ADDR_NODE01} ${SAN1} ${SAN2}"
./kubernetes-vagrant-install.sh $CLUSTER $IP_ADDR_NODE01 $SAN1 $SAN2

SCRIPT


Vagrant.configure("2") do |config|
  config.vm.define "node01" do |node01_config|
    node01_config.vm.box = "geerlingguy/ubuntu1604"
    node01_config.vm.hostname = "node01"
    node01_config.vm.network "public_network", bridge: BRIDGE_IF, ip: IP_ADDR_NODE01
    node01_config.vm.network :forwarded_port, guest: 8080, host: 8080
    node01_config.vm.provider "virtualbox" do |v|
    
      v.linked_clone = true
      v.memory = 8192
    end
  end
  

  config.vm.provision "shell", inline: $script
end
