# Bepro.fr

## Development

### Requirements

* [Vagrant 1.7.2+](http://www.vagrantup.com/downloads.html)
* [VirtualBox 4.3.28+](https://www.virtualbox.org/wiki/Downloads)
* [Ansible 1.9.1+](http://docs.ansible.com/intro_installation.html)
* [Vagrant Landrush 0.18.0+](https://github.com/phinze/landrush) or [Vagrant Host Manager plugin 1.5.0+](https://github.com/smdahlen/vagrant-hostmanager)

### Usage

Create virtualbox machine and install applications.

    $ make setup-dev

## Production

### Usage

Setup production server and install applications.

    $ make setup

Backup databases and assets.

    $ make backup

Restore databases and assets.

    $ make restore
