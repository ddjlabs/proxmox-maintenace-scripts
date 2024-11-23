#!/bin/bash

HOSTNAME=$(hostname)

# Source the common functions
source /opt/pve-common.sh

#Shutdown all containers and VMS on the host
pve_shutdown_all $HOSTNAME

#Stop Ceph too!
/opt/ceph_stop_node.sh

echo "" | append_date_time
echo "$HOSTNAME is ready to properly shutdown." | append_date_time
shutdown -H
exit 0