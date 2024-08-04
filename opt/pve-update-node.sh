#!/bin/bash

HOSTNAME=$(hostname)
SLEEPTIME=60
num_to_keep=3

# Source the common functions
source pve-common.sh

#Perform System Maintenance
echo "Performing System updates for $HOSTNAME" | append_date_time

apt-get update -y
apt-get upgrade -y

echo "Updates Applied." | append_date_time

#Clean up old kernels and packages from server
clean_old_kernels $HOSTNAME

echo "Update process completed on $HOSTNAME" | append_date_time
exit 0