# oh-servers

Scripts for VM provisioning and installing software on VMs.

## rack-vm

Creates or deletes Rackspace VMs. Copy `rack-vm-create`, `rack-vm-delete` and
`rack-vm` to `/usr/local/bin`.

To create a VM (`<hostname>` must be unique):

    rack-vm-create <hostname>

To delete a VM:

    rack-vm-delete <hostname>
