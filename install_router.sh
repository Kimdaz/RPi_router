#!/bin/bash

LOCAL_IP=192.168.8.1/24
DHCP_RANGE_START=192.168.8.2
DHCP_RANGE_END=192.168.8.200
DHCP_RANGE_NETMASK=255.255.255.0
DHCP_RANGE_LEASE=1h

# Install dnsmasq
sudo apt update
sudo apt install dnsmasq -y

# Do dnsmasq settings
sudo echo interface=eth0 >> /etc/dnsmasq.conf
sudo echo bind-dynamic >> /etc/dnsmasq.conf
sudo echo domain-needed >> /etc/dnsmasq.conf
sudo echo bogus-priv >> /etc/dnsmasq.conf
sudo echo dhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,$DHCP_RANGE_NETMASK,$DHCP_RANGE_LEASE >> /etc/dnsmasq.conf

# Install iptables
sudo apt install iptables -y

# Flush iptables rules
sudo iptables -F

# Create route
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
sudo iptables -A FORWARD -i usb0 -o eth0 -j ACCEPT
sudo iptables-apply

# Save iptables 
sudo sh -c "iptables-save > /etc/network/iptables.up.rules" 
sudo echo "iptables-restore < /etc/network/iptables.up.rules" >> /etc/rc.local

# Set static ip address
sudo nmcli con modify 'Wired connection 1' ipv4.addresses $LOCAL_IP
sudo nmcli con modify 'Wired connection 1' ipv4.method manual
sudo nmcli con modify 'Wired connection 1' ipv4.dns "1.1.1.1,1.0.0.1"

sudo nmcli con down 'Wired connection 1'
sudo nmcli con up 'Wired connection 1'

