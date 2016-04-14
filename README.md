
** NOTE: this is no longer maintained, master now based on EL7 **

Mesos cluster
=============

CentOS 6 based Mesos cluster. Intended to be a clean baseline
for framework testing.

Currently 0.22.1 with docker bridged networking support
(see examples/marathon/ for details on using it).

See frameworks/ for some ways to run frameworks against this stack.

## base OS

CentOS 6.6 x64 (from https://github.com/box-cutter/centos-vm )

## requirements

* the centos base image above
* Ansible on your host machine
* Virtualbox on host machine (box has 4.3.28 extensions)
* Vagrant 1.6.4 or better
* a Vagrant plugin (see below)

## assumptions

* Hosts permit passwordless ssh+sudo for the relevant ansible_ssh_user.
* hosts connect to each others inventory hostname
* DNS works (see previous point)

## Vagrant setup

an inventory for Vagrant is in *vagrant/hosts*, the hostnames
in there need to match your Vagrantfile.

_(NB: you won't get a lot of RAM offered by the slaves. Mesos > 0.20.0 reserves 1Gb or half system RAM for the OS)_

We'll need name resolution, and /etc/hosts is nice and simple.

The [hostmanager plugin](https://github.com/smdahlen/vagrant-hostmanager) will auto-manage that.

    vagrant plugin install vagrant-hostmanager

Then

    vagrant up

_NB: this will also (try to) edit your local /etc/hosts_

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
