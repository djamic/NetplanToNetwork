#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root."
   exit 1
fi

# Backup function
backup_file() {
    local file=$1
    if [[ -f $file ]]; then
        cp $file ${file}.backup_$(date +%F_%T)
        echo "Backup created for $file: ${file}.backup_$(date +%F_%T)"
    fi
}

# Convert netplan configuration to interfaces file
convert_netplan_to_interfaces() {
    local netplan_file=$1
    local interfaces_file=$2

    echo "Parsing netplan configuration..."
    network_name=$(grep -m 1 "dhcp4" $netplan_file | awk -F: '{print $1}' | xargs)
    dhcp_enabled=$(grep "dhcp4" $netplan_file | awk -F: '{print $2}' | xargs)
    static_ip=$(grep "addresses" $netplan_file | awk -F[ '{print $2}' | awk -F] '{print $1}' | xargs)
    gateway=$(grep "gateway4" $netplan_file | awk -F: '{print $2}' | xargs)
    dns=$(grep "nameservers" -A 1 $netplan_file | grep "addresses" | awk -F[ '{print $2}' | awk -F] '{print $1}' | xargs)

    echo "Creating interfaces configuration..."
    backup_file $interfaces_file

    {
        echo "# This file describes the network interfaces available on your system"
        echo "# and how to activate them. For more information, see interfaces(5)."
        echo ""
        echo "auto lo"
        echo "iface lo inet loopback"
        echo ""
        if [[ $dhcp_enabled == "true" ]]; then
            echo "auto $network_name"
            echo "iface $network_name inet dhcp"
        else
            echo "auto $network_name"
            echo "iface $network_name inet static"
            echo "    address $static_ip"
            echo "    gateway $gateway"
            echo "    dns-nameservers $dns"
        fi
    } > $interfaces_file

    echo "$interfaces_file successfully created."
}

# 1. Remove netplan
NETPLAN_DIR="/etc/netplan"
if [[ -d $NETPLAN_DIR ]]; then
    echo "Removing netplan configurations..."
    for file in $NETPLAN_DIR/*.yaml; do
        backup_file $file
        convert_netplan_to_interfaces $file "/etc/network/interfaces"
        rm -f $file
        echo "$file removed."
    done
else
    echo "Netplan configuration directory not found."
fi

# 2. Disable netplan service and enable networking service
echo "Disabling netplan service and enabling networking service..."
systemctl stop netplan.io
systemctl disable netplan.io
systemctl enable networking
systemctl restart networking

# Check the status
if systemctl is-active --quiet networking; then
    echo "Networking service successfully started."
else
    echo "Error starting networking service."
    exit 1
fi

echo "Process completed successfully."
