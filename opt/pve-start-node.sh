#!/bin/bash

HOSTNAME=$(hostname)
SLEEPTIME=60

# Source the common functions
source pve-common.sh

#First Start Ceph!
/opt/ceph-start-node.sh

#Disable Maintenance Mode to move all VMs and Containers back on this ProxMox Node
echo "Disabling maintenance mode for $HOSTNAME. Please wait $SLEEPTIME seconds..." | append_date_time

pve_check_cluster_status

pve_disable_cluster_maintenance $HOSTNAME

sleep $SLEEPTIME

echo "$HOSTNAME is now out of maintenance mode. All operations should be back to normal"  | append_date_time
exit 0