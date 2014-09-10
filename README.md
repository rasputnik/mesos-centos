Mesos cluster
=============

CentOS 7 based Mesos cluster.

## base OS

CentOS7 core (from https://github.com/rasputnik/centos7-packer)

## requirements

* the centos base image above
* Ansible on your host machine
* 2 Vagrant plugins (see below)

## assumptions

* Hosts permit passwordless ssh+sudo for the relevant ansible_ssh_user.
* hosts connect to each others inventory hostname
* DNS works (see previous point)

## Vagrant setup

an inventory for Vagrant is in *vagrant_hosts*, the hostnames
in there need to match your Vagrantfile.

Vagrant box used is [my centos7 box](https://github.com/rasputnik/centos7-packer).

    packer build centos7.json
    vagrant box add centos7-core CentOS-7.0-1406-x86_64-v20140721-virtualbox.box

The current version of Vagrant (1.6.3) doesn't support CentOS7 networking
so apply [this plugin](https://github.com/vStone/vagrant-centos7_fix) to fix it.

    vagrant plugin install vagrant-centos7_fix

We'll also need name resolution. The [hostmanager plugin](https://github.com/smdahlen/vagrant-hostmanager)
will auto-manage the VMs /etc/hosts files.

    vagrant plugin install vagrant-hostmanager

Then

    vagrant up

_NB: this will also (try to) edit your local /etc/hosts_

run the main play with:

    ansible-playbook -i vagrant_hosts site.yml

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
