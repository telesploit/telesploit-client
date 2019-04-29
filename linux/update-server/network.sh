#!/bin/bash
source ./server.cfg
echo 'This script allows changing of network connections between DHCP and custom static IP settings on the Telesploit server'
echo
read -p 'Configure the Telesploit server for DHCP or STATIC? [D/S]: ' dhcp_or_static
echo
if echo "$dhcp_or_static" | grep -iq "^s" ; then
    echo 'The Telesploit server will be set to use a static IP address.'
    if [ -z "$static_ip_cidr" ] ; then
        read -p 'Enter the static IP address and CIDR, e.g. 192.168.1.68/24: ' static_ip_cidr
        echo
    fi
    if [ -z "$static_gw" ] ; then
        read -p 'Enter the default gateway, e.g. 192.168.1.1: ' static_gw
        echo
    fi
    if [ -z "$static_dns1" ] ; then
        read -p 'Enter the primary DNS server, e.g. 8.8.8.8: ' static_dns1
        echo
    fi
    if [ -z "$static_dns2" ] ; then
        read -p 'Enter the secondary DNS server, e.g. 8.8.8.4: ' static_dns2
        echo
    fi
    echo 'creating custom config file ./network.conf'
    echo "nmcli con add con-name telesploit ifname eth0 type ethernet ip4 $static_ip_cidr gw4 $static_gw" > ./network.conf
    echo "nmcli con mod telesploit ipv4.dns $static_dns1" >> ./network.conf
    echo "nmcli con mod telesploit +ipv4.dns $static_dns2" >> ./network.conf

elif echo "$dhcp_or_static" | grep -iq "^d" ; then
    echo 'The Telesploit server will be set to use a DHCP assigned IP address.'
    echo 'creating custom config file ./network.conf'
    echo 'nmcli con add con-name telesploit ifname eth0 type ethernet' > ./network.conf
else
    echo 'The entered option was not understood. Please run the updater again and enter d/D/DHCP or s/S/STATIC'
    echo 'No changes have been made'
    exit
fi
echo
echo '________________________________________________________________'
echo
echo 'encrypting config file and copying to ./encrypted-configs/network.conf.gpg'
if [ -z "$gpg_key" ] ; then
    read -s -p 'Enter the server gpg key, no single quotes: ' gpg_key
    echo
fi
gpg --yes --no-tty --batch --passphrase $gpg_key -o ./encrypted-configs/network.conf.gpg -c ./network.conf
echo 'completed encrypting and copying file'
echo
echo '________________________________________________________________'
echo
echo 'Review the following network configuration.'
echo
cat ./network.conf
rm ./network.conf
echo
echo 'If there are errors then rerun the script before transferring the GPG file to the configs directory on the Telesploit server USB drive'
echo

