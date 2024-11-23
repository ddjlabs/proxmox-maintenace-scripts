#!/bin/bash

HOSTNAME=$(hostname)
LXC_SHUTDOWN_TIMEOUT=60
VM_TIMEOUT=300

# Use this for logging
append_date_time() {
    while IFS= read -r line; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $HOSTNAME -  $line"
    done
}

# ===== Proxmox common functions =====

function pve_check_cluster_status {
    local SERVER=$1
    echo "Checking Cluster Status on $SERVER" | append_date_time
    while ! pvecm status &> /dev/null; do
        echo "Waiting for the cluster to become ready..." | append_date_time
        sleep 5
    done
}

function pve_disable_cluster_maintenance {
    local SERVER=$1
    echo "Disabling maintenance mode now on $SERVER." | append_date_time
    /usr/sbin/ha-manager crm-command node-maintenance disable $SERVER
    echo "Maintenance mode is disable. Normal Cluster Operations are active for $SERVER" | append_date_time
}

function pve_enable_cluster_maintenance {
    local SERVER=$1
    echo "Enabling maintenance mode now on $SERVER." | append_date_time
    /usr/sbin/ha-manager crm-command node-maintenance enable $SERVER
    echo "Maintenance mode is enabled. Cluster operations are suspended for $SERVER" | append_date_time
}

# Function to get a list of all running LXC containers
function pve_get_running_containers {
    # Use 'pct list' to get a list of running containers, filter by 'running'
    pct list | awk '/running/{print $1}'
}

#Function to shutdown all Non-HA Containers on a given Proxmox Node
function pve_shutdown_containers {
    local SERVER=$1
    echo "Starting the shutdown process for all running LXC containers on $SERVER..." | append_date_time

    # Fetch all running containers
    running_containers=$(pve_get_running_containers)

    # Check if there are no running containers
    if [[ -z "$running_containers" ]]; then
        echo "No running containers found. Exiting." | append_date_time
    else
        # Iterate over each running container and shut it down
        for container in $running_containers; do
            echo "Shutting down container ID $container on $SERVER (waiting $LXC_SHUTDOWN_TIMEOUT seconds to confirm)..." | append_date_time
            pct shutdown $container --forcestop --timeout $LXC_SHUTDOWN_TIMEOUT
        done
        echo "All containers have been successfully shut down." | append_date_time
    fi
}

#Function to shutdown all non-HA Virtual Machines on a given ProxMox Node
function pve_shutdown_vms {
    local SERVER=$1
    # Shutdown all non-HA VMs
    echo "Shutting down all non-HA VMs on $SERVER" | append_date_time

    # Loop through each VM that is not HA and shutdown
    for vmid in $(qm list | awk '{ if (NR!=1) {print $1} }'); do
        ha_managed=$(ha-manager status | grep -w $vmid)

        if [ -z "$ha_managed" ]; then
            echo "Shutting down VM ID: $vmid" | append_date_time
            qm shutdown $vmid --timeout $VM_TIMEOUT
        else
            echo "Skipping HA VM ID: $vmid" | append_date_time
        fi
    done
    echo "All non-HA VMs are stopped on $SERVER" | append_date_time
}

function pve_shutdown_all {
    local SERVER=$1
    # Shutdown all non-HA VMs
    echo "Shutting down all VMs and Containers on $SERVER" | append_date_time

    # Loop through each VM that is not HA and shutdown
    for vmid in $(qm list | awk '{ if (NR!=1) {print $1} }'); do
        echo "Shutting down VM ID: $vmid" | append_date_time
            qm shutdown $vmid --timeout $VM_TIMEOUT
    done
    echo "All VMs are stopped on $SERVER" | append_date_time

    # Fetch all running containers
    running_containers=$(pve_get_running_containers)
    echo "Start shutdown of all containers on $SERVER" | append_date_time

    # Iterate over each running container and shut it down
    for container in $running_containers; do
        echo "Shutting down container ID $container on $SERVER (waiting $LXC_SHUTDOWN_TIMEOUT seconds to confirm).."
        pct shutdown $container --forcestop --timeout $LXC_SHUTDOWN_TIMEOUT
    done
    echo "All containers have been successfully shut down." | append_date_time
}


# ==== CEPH MAINTENANCE FUNCTIONS =====

# Function to check Ceph health
function ceph_check_health {
    echo "Checking Ceph health..." | append_date_time
    ceph health
}

# Function to set no rebalance
function ceph_set_norebalance {
    echo "Setting Ceph to no rebalance mode..." | append_date_time
    ceph osd set norebalance
}

# Function to unset no rebalance
function ceph_unset_norebalance {
    echo "Unsetting Ceph no rebalance mode..." | append_date_time
    ceph osd unset norebalance
}

# Function to stop Ceph services dynamically
function ceph_stop_services {
    echo "Stopping Ceph OSDs..." | append_date_time
    systemctl stop ceph-osd.target

    echo "Stopping Ceph Mons..." | append_date_time
    systemctl stop ceph-mon.target

    echo "Stopping Ceph Mgrs..." | append_date_time
    systemctl stop ceph-mgr.target
}

# Function to start Ceph services dynamically
function ceph_start_services {
    echo "Starting Ceph OSDs..." | append_date_time
    systemctl start ceph-osd.target

    echo "Starting Ceph Mons..." | append_date_time
    systemctl start ceph-mon.target

    echo "Starting Ceph Mgrs..." | append_date_time
    systemctl start ceph-mgr.target
}

#Function to clean up old kernels
function clean_old_kernels {
    local SERVER=$1
    echo "Cleaning up old kernels on $SERVER..." | append_date_time
    apt-get autoremove -y
    apt-get autoclean

    #Update GRUB Configuration
    update-grub
    
    echo "Old kernels have been cleaned up on $SERVER." | append_date_time
}