# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.8.0"

## if you change these, change vagrant/hosts too
#
# would _dearly_ love to make this less clunkable,
# and just read vagrant/hosts directly.

hosts = [
  {:name => "master1", :ip => "10.0.0.111", :ram => 1024},
  {:name => "slave1",  :ip => "10.0.0.112", :ram => 1900, :mesos_storage => 4000},
  {:name => "slave2",  :ip => "10.0.0.113", :ram => 1900, :mesos_storage => 4000},
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

      c.vm.box = "box-cutter/centos72"
      c.vm.box_version = "2.0.13"

      # stop Vagrant 'helping'
      c.ssh.insert_key = false

      c.vm.hostname = host[:name]

      c.vm.network :private_network, ip: host[:ip], netmask: "255.255.255.0"

      c.vm.provider("virtualbox") do |vb|
        vb.memory = host[:ram]
        vb.linked_clone = true
      end

      # add a dedicated device for mesos to use
      # - let Ansible format and mount it
      if host[:mesos_storage] 
        c.persistent_storage.location = "disks/extra#{host[:name]}.vdi"
        c.persistent_storage.enabled = true
        c.persistent_storage.manage = false
        c.persistent_storage.size = host[:mesos_storage]
      end

      # turn off shared folder
      c.vm.synced_folder ".", "/vagrant", :disabled => true
    end
  end
end
