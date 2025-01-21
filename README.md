# Netplan to Interfaces Converter Script

This Bash script automates the process of switching network configuration from Netplan to the classic `interfaces` system on Ubuntu systems. It reads existing Netplan configurations, converts them to `interfaces` format, and applies the changes.

## Features
- Automatically backs up existing Netplan configuration files.
- Parses Netplan YAML files and converts them to the `interfaces` configuration format.
- Supports both DHCP and static IP configurations.
- Disables the Netplan service and enables the `networking` service.
- Ensures that the networking service is properly started.

## Requirements
- Ubuntu-based system with Netplan installed.
- Root permissions to execute the script.

## Usage
Option 1: Download and Execute the Script Directly

To download and execute the script in one step, use the following command:
  ```bash
curl -s https://raw.githubusercontent.com/djamic/NetplanToNetwork/refs/heads/main/netplan_to_interfaces.sh | bash
```

Option 2:
1. **Download the script:**
   Save the script as `netplan_to_interfaces.sh`.

2. **Make the script executable:**
   ```bash
   chmod +x netplan_to_interfaces.sh
   ```

3. **Run the script with root permissions:**
   ```bash
   sudo ./netplan_to_interfaces.sh
   ```

4. The script will:
   - Backup existing Netplan configurations.
   - Generate the `interfaces` file based on Netplan settings.
   - Disable the Netplan service and enable the `networking` service.

## Example
If your Netplan configuration file looks like this:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
```

The script will generate the following `/etc/network/interfaces` file:
```bash
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

## Notes
- Existing Netplan configurations are backed up with a timestamped suffix.
- Ensure you review the generated `interfaces` file for correctness before proceeding.

## Troubleshooting
- If the networking service fails to start, check the `/etc/network/interfaces` file for any errors.
- Logs can be reviewed using:
  ```bash
  journalctl -u networking.service
  ```

## License
This script is open-source and licensed under the MIT License.

