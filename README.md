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

### Add Client to Inventory

To add a client to the inventory, run:
```bash
curl https://raw.githubusercontent.com/openflighthpc/cluster-inventory/main/client.el9.sh |SERVER="SERVER_IP_ADDRESS" HUNTER_GROUPS='compute,all' PREFIX='node' /bin/bash
```

Where:
- `SERVER` is the Inventory Server IP [REQUIRED]
- `HUNTER_GROUPS` is a comma-separated list of groups [OPTIONAL]
- `PREFIX` is the label desired for the system minus any numerical (e.g. for `node01` naming this would be `node`) [OPTIONAL]

This can be done through cloud-init as follows:
```
#cloud-config
runcmd:
  - "curl https://raw.githubusercontent.com/openflighthpc/cluster-inventory/main/client.el9.sh |SERVER='10.50.1.70' HUNTER_GROUPS='compute,all' PREFIX='node' /bin/bash"
```

