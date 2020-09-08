
BRIDGE_IF="enp3s"

IP_ADDR_NODE01="192.168.2.1"

$script = <<-SCRIPT

IP_ADDR_NODE01="192.168.2.1"
GATEWAY="192.168.2.1"
DNS="192.168.2.1"
CLUSTER="sk-k8s"
SAN1="sk"
SAN2="sk.moonstreet.local"

echo "copy install script"
wget https://raw.githubusercontent.com/jacqinthebox/vagrant-kubernetes/master/kubernetes-vagrant-install.sh && chmod u=rwx kubernetes-vagrant-install.sh && chown vagrant.vagrant kubernetes-vagrant-install.sh
wget https://gist.githubusercontent.com/mingderwang/d40204f8f5cb8a727adfea2a5e71b813/raw/402feb590552aebee76b0be675e360cff47fa727/50-vagrant.yaml && cp 50-vagrant.yam /tmp/

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
./install-myapp.sh  ##-------------------------->installation application
SCRIPT


Vagrant.configure("2") do |config|
  config.vm.define "node01" do |node01_config|
    node01_config.vm.box = "ubuntu/bionic64"
    node01_config.vm.hostname = "node01"
    node01_config.vm.network "public_network", bridge: BRIDGE_IF, ip: IP_ADDR_NODE01
    node01_config.vm.network :forwarded_port, guest: 8080, host: 8080
    node01_config.vm.provider "virtualbox" do |v|
    
      v.linked_clone = true
      v.memory = 4096
    end
  end
  

  config.vm.provision "shell", inline: $script
end
