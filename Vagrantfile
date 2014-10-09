# -*- mode: ruby -*-
# vi: set ft=ruby :

## if you change these, change vagrant_hosts too
#
# would _dearly_ love to make this less clunkable,
# and just read vagrant_hosts directly.

hosts = [
  {:name => "master1", :ip => "10.0.0.111",   :ram => 1024},
  {:name => "slave1",  :ip => "10.0.0.112",   :ram => 1900},
  {:name => "slave2",  :ip => "10.0.0.113",   :ram => 1900},
]

Vagrant.configure("2") do |config|

  # setup /etc/hosts on each vm
  # - requires the vagrant-hostmanager plugin
  config.hostmanager.enabled = true
  # set to 'false' if you don't wan't to manage _your_ /etc/hosts
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true

  hosts.each do |host|
    config.vm.define host[:name] do |c|

      c.vm.box = "rasputnik/centos7.0-core"

      c.vm.hostname = host[:name]

      c.vm.network :private_network, ip: host[:ip], netmask: "255.255.255.0"

      c.vm.provider("virtualbox") do |vb|
        vb.memory = host[:ram]
      end

      # turn off shared folder
      c.vm.synced_folder ".", "/vagrant", :disabled => true
    end
  end
end
