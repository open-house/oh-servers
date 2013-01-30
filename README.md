# oh-servers

Scripts for VM provisioning and installing software on VMs.

## rack-vm

Creates or deletes Rackspace VMs. Copy `rack-vm-create`, `rack-vm-delete` and
`rack-vm` to `/usr/local/bin`.

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

    rack-vm-create <hostname>

To delete a VM:

    rack-vm-delete <hostname>

## nova client

To get a list of VMs from command line, you can use nova client.

to install it:

    aptitude update
    aptitude install python-pip
    pip install rackspace-novaclient

to list the VMs:

    nova list
