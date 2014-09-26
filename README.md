Mesos cluster
=============

CentOS 7 based Mesos cluster. Intended to be a clean baseline
for framework testing.

Currently 0.20.0 with docker support.

See examples/ for some ways to run frameworks against this stack.

## base OS

CentOS7 core (from https://github.com/rasputnik/centos7-packer)

## requirements

* the centos base image above
* Ansible on your host machine
* Vagrant 1.6.4 or better is needed to support EL7 networking.
* a Vagrant plugin (see below)

## assumptions

* Hosts permit passwordless ssh+sudo for the relevant ansible_ssh_user.
* hosts connect to each others inventory hostname
* DNS works (see previous point)

## Vagrant setup

an inventory for Vagrant is in *vagrant/hosts*, the hostnames
in there need to match your Vagrantfile.

Vagrant box used is [my centos7 box](https://github.com/rasputnik/centos7-packer).

_(NB: you won't get a lot of RAM offered by the slaves. Mesos > 0.20.0 reserves 1Gb or half system RAM for the OS)_

We'll need name resolution, and /etc/hosts is nice and simple.

The [hostmanager plugin](https://github.com/smdahlen/vagrant-hostmanager)
will auto-manage the VMs /etc/hosts files.

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

* role-specific vars live in $rolename/defaults/main.yml.
* globals live in group_vars/all
* 'environment' specific vars _(e.g. ansible_ssh_user)_ live in [all:vars] within the relevant inventory

### BUGS

Oh, I expect so. Log an issue / PR if you notice any.
