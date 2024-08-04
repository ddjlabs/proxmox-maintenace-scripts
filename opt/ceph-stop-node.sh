#!/bin/bash

HOSTNAME=$(hostname)

# Source the common functions
source pve-common.sh

# Main script logic for stopping services
echo "Stopping Ceph on $HOSTNAME" | append_date_time

# Check initial health
ceph_check_health

# Set cluster to no rebalance
ceph_set_norebalance

# Stop services for maintenance
ceph_stop_services

echo "Ceph services are now stopped. Perform maintenance as needed." | append_date_time
exit 0