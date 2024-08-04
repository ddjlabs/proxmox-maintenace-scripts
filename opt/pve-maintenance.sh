#!/bin/bash
# Proxmox Cluster Maintenance Script

HOSTNAME=$(hostname)
SLEEPTIME=60

# Source the common functions
source pve-common.sh

# stop the node
/opt/pve-stop-node.sh

# Update/upgrade the node
/opt/pve-update-node.sh

# Reboot the node
echo "Rebooting $HOSTNAME now" | append_date_time
reboot now
exit 0