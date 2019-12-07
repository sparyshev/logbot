# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.provision :shell, inline: "yum install -y https://yum.puppet.com/puppet6-release-el-7.noarch.rpm", :privileged => true
  config.vm.provision :shell, inline: "yum install -y puppet-agent git wget --nogpgcheck", :privileged => true
  config.vm.provision "puppet"
  config.vm.box = "centos/7"
  config.vm.network "forwarded_port", guest: 80, host: 80
  #config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.provision :shell, :inline => "useradd askbot && usermod -a -G wheel askbot && echo askbot | passwd --stdin askbot", :privileged => true
  config.vm.provision :shell, :inline => "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config; sudo systemctl restart sshd;", run: "always"
end
