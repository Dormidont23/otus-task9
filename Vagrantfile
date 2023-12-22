# -*- mode: ruby -*-
# vim: set ft=ruby :
MACHINES = {
  :"otus-task9" => {
        :box_name => "generic/centos8s",
        :cpus => 2,
        :memory => 2048,
  }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
      box.vm.provision "shell", inline: <<-SHELL
        dnf install epel-release -y && dnf install spawn-fcgi php php-cli mod_fcgid httpd -y
      SHELL
    end
  end
end