# oh-servers

OH infrastructure scripts, i.e. for VM provisioning and installing software on VMs.

* `oh-vm-rack` -- create/delete Rackspace VM
* `oh-vm-cmds` -- run commands on VM or locally
* `manifests/` -- puppet manifests

## Usage

To get help on script usage, run it without arguments.

### Create configuration files

To be able to use Rackspace API create a configuration file:

    touch ~/.novarc
    chmod 600 ~/.novarc
    cat << EOF > ~/.novarc
    OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
    OS_VERSION=2.0
    OS_AUTH_SYSTEM=rackspace
    OS_REGION_NAME=DFW
    OS_TENANT_NAME=<USER_ID>
    OS_USERNAME=<USERNAME>
    OS_PASSWORD=<API_KEY>
    OS_NO_CACHE=1
    export OS_AUTH_URL OS_VERSION OS_AUTH_SYSTEM OS_REGION_NAME OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_NO_CACHE
    EOF

Create SSH client configuration file to allow non-interactive ssh connection to a new VM:

    cat << EOF >> ~/.ssh/config
    # Bypass SSH key checking
    # http://linuxcommando.blogspot.sk/2008/10/how-to-disable-ssh-host-key-checking.html
    Host *
        StrictHostKeyChecking no
    EOF

### Jenkins job configuraion sample (Build => Execute shell => Command):

    #!/bin/bash

    # source configuration (don't use -x!)
    . ~/.novarc

    # now we can print commands before executing them
    set -x

    OH_VM_RACK="/var/lib/jenkins/oh-servers/oh-vm-rack"
    OH_VM_CMDS="/var/lib/jenkins/oh-servers/oh-vm-cmds"

    # builds a VM
    IP=$($OH_VM_RACK create ${JOB_NAME}_${BUILD_NUMBER})
    
    # install SW and configure VM
    $OH_VM_CMDS $IP a b c d e f

    # check pipeline service is running and delete VM
    nc -z $IP 8080
    if [[ $? -eq 0 ]]; then
        echo "Service running on $IP, port 8080"
        $OH_VM_RACK delete ${JOB_NAME}_${BUILD_NUMBER}
        exit 0
    else
        $OH_VM_RACK delete ${JOB_NAME}_${BUILD_NUMBER}
        exit 1
    fi

.. don't forget the first line (`#!/bin/bash`), otherwise Jenkins will print out the API key!

### nova client (optional)

To get a list of VMs from command line, you can use nova client.

to install it:

    aptitude update
    aptitude install python-pip
    pip install rackspace-novaclient

commands:

    nova credentials
    nova list
    nova flavor-list
    nova image-list
    nova boot test01 --flavor 2 --image 8a3a9f96-b997-46fd-b7a8-a9e740796ffd
    nova delete <SERVER_ID>
