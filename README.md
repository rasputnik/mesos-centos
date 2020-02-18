NOTE
====

I haven't maintained this for a couple of years now,
Ansible has moved on a bit. 

Also the base box will need an update.

Mesos cluster
=============

CentOS 7 based Mesos cluster. Intended to be a clean baseline
for framework testing.

Currently 0.28.1 with docker support and cgroups isolation
(see roles/mesos/{slave,master}/defaults for various tunings).

See frameworks/ for some ways to run frameworks against this stack.

## base OS

CentOS 7.x x64 (from https://github.com/box-cutter/centos-vm ) -
see Vagrantfile for precise version.

## requirements

* the centos base image above
* Ansible (2.x) on your host machine
* Virtualbox on host machine (box has 4.3.28 extensions)
* Vagrant 1.8.x or better (for linked_clones)
* 2 Vagrant plugins (see below)

## assumptions

* Hosts permit passwordless ssh+sudo for the relevant ansible_ssh_user.
* hosts connect to each others inventory hostname
* DNS works (see previous point)

## Vagrant setup

an inventory for Vagrant is in *vagrant/hosts*, the hostnames
in there need to match your Vagrantfile.

_(NB: you won't get a lot of RAM offered by the slaves. Mesos > 0.20.0 reserves 1Gb or half system RAM for the OS)_


### name resolution

we'll use a Vagrant plugin to ensure all nodes (and our host) can resolve each others names.

The [hostmanager plugin](https://github.com/smdahlen/vagrant-hostmanager) will auto-manage that.

    vagrant plugin install vagrant-hostmanager

### dedicated storage for /var/mesos on the slaves

This should stop slaves being taken out when sandboxes overflow, and also allow some custom
mount options _(see Vagrantfile for detail)_. the storage attaches at /dev/sdb

    vagrant plugin install vagrant-persistent-storage

Disks live under disks/ at the top of this repo. 

### do the thing

    vagrant up

_NB: hostmanager will (try to) edit your local /etc/hosts_

### wiping 

If you want to blow everything away, this should do the trick:

    vagrant destroy -f
    for i in master1 slave1 slave2
      do
        ssh-keygen -R $i
      done
    # remove the disks via Virtualbox 'Virtual Media Manager'


## time for Ansible

run the main play with:

    ansible-playbook -i vagrant/ site.yml

If you add/destroy vagrant VMs, the 'vagrant up' should
auto-manage your local /etc/hosts along with existing VMs. If you
need to ensure it's up to date, just run

    vagrant hostmanager

## vars

* role-specific vars live in $rolename/defaults/main.yml
* 'environment' specific vars _(e.g. ansible_ssh_user)_ live in [all:vars] within the relevant inventory
  and override role defaults

### BUGS

Oh, I expect so. Log an issue / PR if you notice any.
