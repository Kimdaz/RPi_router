Currently not working as it should.

# Bash Script Documentation

## Overview
This bash script is designed to configure a network interface and set up DHCP and routing using `dnsmasq` and `iptables` on a Linux system. The primary purpose is to set a static IP address, configure DHCP settings, and establish routing rules.

## Script Breakdown

### Variables
- `LOCAL_IP`: Local IP address and subnet mask for the network interface (e.g., `192.168.8.1/24`).
- `DHCP_RANGE_START`: Starting IP address of the DHCP range (e.g., `192.168.8.2`).
- `DHCP_RANGE_END`: Ending IP address of the DHCP range (e.g., `192.168.8.200`).
- `DHCP_RANGE_NETMASK`: Netmask for the DHCP range (e.g., `255.255.255.0`).
- `DHCP_RANGE_LEASE`: Lease time for DHCP addresses (e.g., `1h`).

### Steps

1. **Update Package List and Install dnsmasq**
    ```bash
    sudo apt update
    sudo apt install dnsmasq -y
    ```
    - Updates the package list and installs `dnsmasq` for DHCP and DNS services.

2. **Configure dnsmasq**
    ```bash
    sudo echo interface=eth0 >> /etc/dnsmasq.conf
    sudo echo bind-dynamic >> /etc/dnsmasq.conf
    sudo echo domain-needed >> /etc/dnsmasq.conf
    sudo echo bogus-priv >> /etc/dnsmasq.conf
    sudo echo dhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,$DHCP_RANGE_NETMASK,$DHCP_RANGE_LEASE >> /etc/dnsmasq.conf
    ```
    - Configures `dnsmasq` to use `eth0` interface, set dynamic binding, and define DHCP settings.

3. **Install iptables**
    ```bash
    sudo apt install iptables -y
    ```
    - Installs `iptables` for managing routing rules.

4. **Flush iptables Rules**
    ```bash
    sudo iptables -F
    ```
    - Flushes all existing `iptables` rules.

5. **Create Routing Rules**
    ```bash
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
    sudo iptables -A FORWARD -i usb0 -o eth0 -j ACCEPT
    sudo iptables-apply
    ```
    - Adds NAT and forwarding rules to `iptables` to allow traffic between interfaces `eth0` and `usb0`.

6. **Save iptables Rules**
    ```bash
    sudo sh -c "iptables-save > /etc/network/iptables.up.rules"
    sudo echo "iptables-restore < /etc/network/iptables.up.rules" >> /etc/rc.local
    ```
    - Saves the `iptables` rules to a file and ensures they are restored on boot by adding the restore command to `/etc/rc.local`.

7. **Set Static IP Address**
    ```bash
    sudo nmcli con modify 'Wired connection 1' ipv4.addresses $LOCAL_IP
    sudo nmcli con modify 'Wired connection 1' ipv4.method manual
    sudo nmcli con modify 'Wired connection 1' ipv4.dns "1.1.1.1,1.0.0.1"
    ```
    - Configures the network connection (`Wired connection 1`) to use a static IP address and sets DNS servers.

8. **Restart Network Connection**
    ```bash
    sudo nmcli con down 'Wired connection 1'
    sudo nmcli con up 'Wired connection 1'
    ```
    - Restarts the network connection to apply the new settings.

## Usage
Run this script with superuser privileges to set up a network interface with the specified static IP, DHCP, and routing settings. Ensure the network interface names (`eth0` and `usb0`) match your system's configuration. Adjust the IP addresses and ranges as needed for your network environment.
