# oh-servers

Scripts for VM provisioning and installing software on VMs.

* oh-rack-vm-create -- create Rackspace VM
* oh-rack-vm-delete -- deltete Rackaspace VM
* oh-mysql-install -- install MySQL database
* oh-mysql-sql-pipeline-service -- execute MySQL commands
* oh-sw-install-pipeline-service -- install SW

## Usage

### Copy scripts

Copy all scripts to `/usr/local/bin`:

    cp oh-* /usr/local/bin

### Create configuration files

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

Make sure the file is protected:

    chmod 600 ~/.novarc

Create configuration file `~/.oh-servers`:

    export OH_MYSQL_PASS=<root_db_pass>

Make sure the file is protected:

    chmod 600 ~/.oh-servers

Create configuration file `~/.ssh/config`:
    # Bypass SSH key checking
    # http://linuxcommando.blogspot.sk/2008/10/how-to-disable-ssh-host-key-checking.html
    Host *
       StrictHostKeyChecking no
       UserKnownHostsFile=/dev/null

### Use the scripts

To create a VM:

    oh-rack-vm-create <vm_name>
    
.. script prints VMs public IP address to STDOUT - you can use in in a shell script like this:

    IP=$(oh-rack-vm-create <vm_name>)
    oh-mysql-install $IP
    oh-mysql-sql-pipeline-service $IP
    oh-sw-install-pipeline-service $IP
    
To delete a VM:

    oh-rack-vm-delete <vm_name>

### nova client (optional)

To get a list of VMs from command line, you can use nova client.

to install it:

    aptitude update
    aptitude install python-pip
    pip install rackspace-novaclient

to list the VMs:

    nova list

