#!/bin/bash

HOSTNAME=$(hostname)
SLEEPTIME=300

# Source the common functions
source pve-common.sh

# Enable maintenance mode
pve_enable_cluster_maintenance $HOSTNAME

#Shutdown all Non-HA VMs
pve_shutdown_vms $HOSTNAME

#Shutdown all Non-HA Containers
pve_shutdown_containers $HOSTNAME


# Wait for all VMs to shutdown
echo "" | append_date_time
echo "Waiting $SLEEPTIME seconds for VMs to shutdown and migrate appropriately on $HOSTNAME..." | append_date_time
sleep $SLEEPTIME

#Stop Ceph too!
/opt/ceph_stop_node.sh

echo "" | append_date_time
echo "$HOSTNAME is ready for system maintenance." | append_date_time
exit 0