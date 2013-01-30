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

To create a VM (`<hostname>` must be unique):

    rack-vm-create <hostname>

To delete a VM:

    rack-vm-delete <hostname>
