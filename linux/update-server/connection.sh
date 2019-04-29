#!/bin/bash
source ./server.cfg
echo 'This script allows re-configuration of outbound connections for the Telesploit server'
echo
echo 'What type of connection should the Telesploit server use?'
echo '[D]irect TLS - No proxy is required. Certificate checking is enabled'
echo '[U]nsafe TLS - No proxy is required. Certificate checking is disabled'
echo '[P]lain - Simple proxy. No password required'
echo '[B]asic - Proxy uses BASIC authentication.'
echo '[N]TLM - Proxy uses NTLM authentication.'
read -p 'Choose the Telesploit server connection type [D/U/P/B/N]: ' connection_type
echo
if [ -z "$relay_fqdn" ] ; then
    read -p 'Enter the relay FQDN, e.g. relay-os.telesploit.com: ' relay_fqdn
    echo
fi
set_proxy_variables () {
    read -p 'Enter the IP address or FQDN of the proxy server, e.g. 192.168.1.69 or proxy.corp.com: ' proxy_server
    echo
    read -p 'Enter the port used by the proxy server, e.g. 3128: ' proxy_port
    echo
}
set_proxy_credentials () {
    read -p 'Enter the username for the proxy server, e.g. pentester: ' proxy_username
    echo
    read -s -p 'Enter the password for the proxy server, e.g. SquidWard: ' proxy_password
    echo
}
set_proxy_domain () {
    read -p 'Enter the NTLM domain for the account, e.g. CORP: ' proxy_domain
    echo
}
if echo "$connection_type" | grep -iq "^d" ; then
    proxy_command="/usr/bin/ncat --ssl-verify $relay_fqdn 443"
elif echo "$connection_type" | grep -iq "^u" ; then
    proxy_command="/usr/bin/ncat --ssl $relay_fqdn 443"
elif echo "$connection_type" | grep -iq "^p" ; then
    set_proxy_variables
    proxy_command="/usr/bin/proxytunnel -v -p $proxy_server:$proxy_port -d $relay_fqdn:443 -e"
elif echo "$connection_type" | grep -iq "^b" ; then
    set_proxy_variables
    set_proxy_credentials
    proxy_command="/usr/bin/proxytunnel -v -p $proxy_server:$proxy_port -P $proxy_username:$proxy_password -d $relay_fqdn:443 -e"
elif echo "$connection_type" | grep -iq "^n" ; then
    set_proxy_variables
    set_proxy_credentials
    set_proxy_domain
    proxy_command="/usr/bin/proxytunnel -v -p $proxy_server:$proxy_port -N -t $proxy_domain -P $proxy_username:$proxy_password -d $relay_fqdn:443 -e"
else
    echo 'The entered option was not understood, please run the updater again and enter D/P/B/N'
    echo 'No changes have been made'
    exit
fi
echo
echo '________________________________________________________________'
echo
echo 'creating custom config file ./connection.conf'
echo "Host $service_name" > ./connection.conf
echo ' HostName localhost' >> ./connection.conf
echo ' AddressFamily inet' >> ./connection.conf
echo " User $relay_user" >> ./connection.conf
echo ' Port 22' >> ./connection.conf
echo " IdentityFile /root/.ssh/$server_ssh_key" >> ./connection.conf
echo " ProxyCommand $proxy_command" >> ./connection.conf
echo ' ServerAliveInterval 10' >> ./connection.conf
echo ' ServerAliveCountMax 3' >> ./connection.conf
echo ' ExitOnForwardFailure yes' >> ./connection.conf
echo ' StrictHostKeyChecking yes' >> ./connection.conf
echo " UserKnownHostsFile /root/.ssh/$known_hosts" >> ./connection.conf
echo >> ./connection.conf
echo "Host $service_ssh" >> ./connection.conf
echo " $forward_ssh" >> ./connection.conf
echo " $forward_irc" >> ./connection.conf
echo " $forward_collab" >> ./connection.conf
echo >> ./connection.conf
echo "Host $service_vnc" >> ./connection.conf
echo " $forward_vnc" >> ./connection.conf
echo >> ./connection.conf
echo "Host $service_rdp" >> ./connection.conf
echo " $forward_rdp" >> ./connection.conf
echo >> ./connection.conf
echo "Host $service_squid" >> ./connection.conf
echo " $forward_squid" >> ./connection.conf
echo >> ./connection.conf
echo "Host $service_socks" >> ./connection.conf
echo " $forward_socks" >> ./connection.conf
echo >> ./connection.conf
echo 'Host client' >> ./connection.conf
echo ' HostName localhost' >> ./connection.conf
echo ' AddressFamily inet' >> ./connection.conf
echo ' User root' >> ./connection.conf
echo ' Port 22' >> ./connection.conf
echo " IdentityFile /root/.ssh/$server_ssh_key" >> ./connection.conf
echo " LocalForward $local_socks_port $local_socks_target" >> ./connection.conf
echo ' ServerAliveInterval 10' >> ./connection.conf
echo ' ServerAliveCountMax 3' >> ./connection.conf
echo ' ExitOnForwardFailure yes' >> ./connection.conf
echo ' NoHostAuthenticationForLocalhost yes' >> ./connection.conf
echo 'finished creating custom config file'
echo
echo '________________________________________________________________'
echo
echo 'encrypting config file and copying to ./encrypted-configs/connection.conf.gpg'
if [ -z "$gpg_key" ] ; then
    echo
    read -s -p 'Enter the server gpg key, no single quotes: ' gpg_key
    echo
fi
gpg --yes --no-tty --batch --passphrase $gpg_key -o ./encrypted-configs/connection.conf.gpg -c ./connection.conf
echo 'completed encrypting and copying file'
echo
echo '________________________________________________________________'
echo
echo 'Review the following configuration file. If there are errors then rerun the script before transferring the GPG file to the configs directory on the Telesploit server USB drive'
echo
cat ./connection.conf
rm ./connection.conf
echo 


