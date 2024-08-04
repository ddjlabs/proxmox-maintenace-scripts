#!/bin/bash

HOSTNAME=$(hostname)

# Source the common functions
source pve-common.sh

# Main script logic for starting services
echo "Starting Ceph Services on host $HOSTNAME" | append_date_time

# Start services after maintenance
ceph_start_services

# Check health after restart
ceph_check_health

# Unset no rebalance if it was set
ceph_unset_norebalance

echo "Ceph services are now running. Cluster health should be monitored." | append_date_time