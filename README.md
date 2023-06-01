## Overview

Create a cluster asset inventory using Flight Tools on a clean Rocky 9 image. All nodes that join the inventory can be logged in via SSH with a known key created by the server.

## Setup

### Create Inventory Server

To setup the server, run:
```bash
curl https://raw.githubusercontent.com/openflighthpc/cluster-inventory/main/server.el9.sh |/bin/bash
```

This script: 
- Runs a `flight-hunter` server on port 8888
- Shares the SSH public key (`id_hunter.pub`) over port 1234 (with `socat`) 
- Provides access to inventory via command `hunter` (`hunter --help` for more info) 

This can be done through cloud-init as follows:
```
#cloud-config
runcmd:
  - "curl https://raw.githubusercontent.com/openflighthpc/cluster-inventory/main/server.el9.sh |/bin/bash"
```

### Add Client to Inventory

To add a client to the inventory, run:
```bash
curl https://raw.githubusercontent.com/openflighthpc/cluster-inventory/main/client.el9.sh |SERVER="SERVER_IP_ADDRESS" HUNTER_GROUPS='compute,all' PREFIX='node' /bin/bash
```

Where:
- `SERVER` is the Inventory Server IP [REQUIRED]
- `HUNTER_GROUPS` is a comma-separated list of groups [OPTIONAL]
- `PREFIX` is the label desired for the system minus any numerical (e.g. for `node01` naming this would be `node`) [OPTIONAL]

The script will setup the tools needed to send before sending data and getting the SSH pub key to trust from the server. To see and change what was run to send information to the inventory server, see `/root/send.sh`.

This can be done through cloud-init as follows:
```
#cloud-config
runcmd:
  - "curl https://raw.githubusercontent.com/openflighthpc/cluster-inventory/main/client.el9.sh |SERVER='10.50.1.70' HUNTER_GROUPS='compute,all' PREFIX='node' /bin/bash"
```

## Inventory Management

### Parsing Nodes

The nodes that have been added to the inventory end up in the hunter "buffer". These will need to be parsed by either:
- Manually setting labels with `hunter parse`
- Bulk-applying labels based on prefix rules with `hunter parse --auto` 

More information on parsing options and functionality can be seen in [the Flight Hunter README](https://github.com/openflighthpc/flight-hunter/tree/develop#parsing-nodes), the `parse` help page and through `/root/flight-hunter/etc/config.yml.ex`. 

### Modifying Payload Data

_Note: Modification can only be performed to nodes which have been parsed and, therefore, have labels_

To modify the payload data of a node:
```
modify payload nodename
```

To modify the hunter IP of a node:
```
modify ip nodename
```

### Bulk Modification 

- Using Groups 
    - _WIP_
- Using Genders Syntax
    - _WIP_
