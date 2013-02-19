`oh-vm-rack { create | delete } <name>` -- create/delete Rackspace VM (returns public IP)

`oh-vm-inst-puppet <IP_address>` -- install puppet (client)

`manifests`

* install MySQL server
* create MySQL DB
* add OH repo
* install oh-*

`oh-vm-cmd <cmd1> [ <cmd2> .. <cmdN> ] <IP_address>` -- run arbitrary (puppet) commands via ssh
