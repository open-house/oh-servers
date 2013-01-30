# oh-servers

Scripts for VM provisioning and installing software on VMs.

## oh-rack-vm

Creates or deletes Rackspace VMs. Copy `oh-rack-vm-create`, `oh-rack-vm-delete` and
`oh-rack-vm` to `/usr/local/bin`.

To be able to use Rackspace API create a configuration file `~/.novarc`:

    OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
    OS_VERSION=2.0
    OS_AUTH_SYSTEM=rackspace
    OS_REGION_NAME=DFW
    OS_TENANT_NAME=<USER_ID>
    OS_USERNAME=<USERNAME>
    OS_PASSWORD=<API_KEY>
    OS_NO_CACHE=1
    export OS_AUTH_URL OS_VERSION OS_AUTH_SYSTEM OS_REGION_NAME OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_NO_CACHE

Make sure the file is protected: `chmod 600 ~/.novarc`

To create a VM (`<hostname>` must be unique):

    oh-rack-vm-create <hostname>

To delete a VM:

    oh-rack-vm-delete <hostname>

## nova client

To get a list of VMs from command line, you can use nova client.

to install it:

    aptitude update
    aptitude install python-pip
    pip install rackspace-novaclient

to list the VMs:

    nova list

## oh-mysql

Install MySQL database on a VM.

Create configuration file `./oh-servers`:

    export OH_MYSQL_PASS=<root_db_pass>

Make sure the file is protected: `chmod 600 ~/.oh-servers`

Copy `oh-mysql` and `oh-mysql-install` to `/usr/local/bin`.

Install the database server:

    oh-mysql-install <hostname>
