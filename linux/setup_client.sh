#!/bin/bash
host_name='localhost'
source ./client-configs/client.cfg
echo 'This script will configure the Telesploit client'
echo
echo "Please verify that the correct relay FQDN is set in ./client-configs/client.cfg and that your public key has been added on the relay (default /home/$ssh_user/.ssh/authorized_keys)"
echo
nslookup $relay_fqdn
echo
echo 'If the relay is not correct, or does not resolve then exit now and correct the issue'
read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
echo
echo 'After completing this script, run ./create_tunnels.sh to setup the tunnels used to connect to the Telesploit relay'
echo
echo 'After the tunnels have been established:'
echo "1) The script ./server_console.sh may be run to obtain a command line on the Telesploit server. Any other SSH client can be used by connecting to 127.0.0.1:$ssh_port"
echo "2) A VNC desktop on the Telesploit server can be accessed at 127.0.0.1:$vnc_port"
echo "3) An RDP desktop on the Telesploit server can be accessed at 127.0.0.1:$rdp_port (available only on enhanced deployments with additional Windows VM)"
echo "4) Web applications can be configured to use the squid proxy on the Telesploit server by setting the upstream proxy to 127.0.0.1:$webproxy_port"
echo "5) SOCKS applications can be configured to use the SOCKS proxy on the Telesploit server by configuring and executing the SSH config entry on the server and setting the application's upstream proxy to 127.0.0.1:$socksproxy_port"
echo "6) The IRC server on the Telesploit relay can be accessed at 127.0.0.1:$irc_port"
echo "7) The Mattermost server on the Telesploit relay can be accessed at 127.0.0.1:$collab_port"
echo
read -e -p "Enter the full path to the private key being used to access the Telesploit server, e.g. /home/user/.ssh/user.id_rsa, followed by [ENTER]: " key_path
echo
echo "What type of connection should the Telesploit client use?"
echo '[S]SH - SSH connection (recommended if SSH is allowed outbound from your location).'
echo '[D]irect TLS - No proxy is required. Certificate checking is enabled. SSH host-based verification is enabled. (must have ncat installed in /usr/bin/).'
echo '[U]nsafe TLS - No proxy is required. Certificate checking is disabled. SSH host-based verification is enabled. (must have ncat installed in /usr/bin/).'
echo '[P]lain - Simple proxy. No password required. Certificate checking is disabled. SSH host-based verification is enabled. (must have proxytunnels intalled in /usr/bin/).'
echo '[B]asic - Proxy uses BASIC authentication. Certificate checking is disabled. SSH host-based verification is enabled. (must have proxytunnels intalled in /usr/bin/).'
echo '[N]TLM - Proxy uses NTLM authentication. Certificate checking is disabled. SSH host-based verification is enabled. (must have proxytunnels intalled in /usr/bin/)'
read -p "Choose the $platform client connection type [S/D/U/P/B/N]: " connection_type
echo
set_proxy_variables () {
    if [ -z "$proxy_server" ] ; then
        read -p 'Enter the IP address or FQDN of the proxy server, e.g. 192.168.1.69 or proxy.corp.com: ' proxy_server
        echo
    fi
    if [ -z "$proxy_port" ] ; then
        read -p 'Enter the port used by the proxy server, e.g. 3128: ' proxy_port
        echo
    fi
}
set_proxy_credentials () {
    if [ -z "$proxy_username" ] ; then
        read -p 'Enter the username for the proxy server, e.g. pentester: ' proxy_username
        echo
    fi
    if [ -z "$proxy_password" ] ; then
        read -s -p 'Enter the password for the proxy server, e.g. SquidWard: ' proxy_password
        echo
    fi
}
set_proxy_domain () {
    if [ -z "$proxy_domain" ] ; then
        read -p 'Enter the NTLM domain for the account, e.g. CORP: ' proxy_domain
        echo
    fi
}
if echo "$connection_type" | grep -iq "^s" ; then
    host_name="$relay_fqdn"
    client_connection="relay-$server-ssh"
elif echo "$connection_type" | grep -iq "^d" ; then
    proxy_command="/usr/bin/ncat --ssl-verify $relay_fqdn 443"
    client_connection="relay-$server-ssl"
elif echo "$connection_type" | grep -iq "^u" ; then
    proxy_command="/usr/bin/ncat --ssl $relay_fqdn 443"
    client_connection="relay-$server-ssl"
elif echo "$connection_type" | grep -iq "^p" ; then
    set_proxy_variables
    proxy_command="/usr/bin/proxytunnel -v -p $proxy_server:$proxy_port -d $relay_fqdn:443 -e"
    client_connection_="relay-$server-proxy-no-auth"
elif echo "$connection_type" | grep -iq "^b" ; then
    set_proxy_variables
    set_proxy_credentials
    proxy_command="/usr/bin/proxytunnel -v -p $proxy_server:$proxy_port -P $proxy_username:$proxy_password -d $relay_fqdn:443 -e"
    client_connection="relay-$server-proxy-basic-auth"
elif echo "$connection_type" | grep -iq "^n" ; then
    set_proxy_variables
    set_proxy_credentials
    set_proxy_domain
    proxy_command="/usr/bin/proxytunnel -v -p $proxy_server:$proxy_port -N -t $proxy_domain -P $proxy_username:$proxy_password -d $relay_fqdn:443 -e"
    client_connection="relay-$server-proxy-ntlm-auth"
else
    echo 'The entered option was not understood, please run the updater again and enter S/D/P/B/N'
    echo 'No changes have been made'
    exit
fi
# saving connection status to $connection_file
echo "$client_connection" > $connection_file
# creating ssh config file and saving to $config_file
echo "Host $client_connection" > $config_file
echo " AddressFamily inet" >> $config_file
echo " HostName $host_name" >> $config_file
echo " User $ssh_user" >> $config_file
echo " IdentityFile $key_path" >> $config_file
echo " Port 22" >> $config_file
if [[ "$proxy_command" ]]; then
    echo " ProxyCommand $proxy_command" >> $config_file
fi
echo " ServerAliveInterval 10" >> $config_file
echo " StrictHostKeyChecking yes" >> $config_file
echo " UserKnownHostsFile ./client-configs/$known_hosts" >> $config_file
echo " $forward_ssh" >> $config_file
echo " $forward_vnc" >> $config_file
echo " $forward_rdp" >> $config_file
echo " $forward_squid" >> $config_file
echo " $forward_socks" >> $config_file
echo " $forward_irc" >> $config_file
echo " $forward_collab" >> $config_file
echo >> $config_file
echo "Host server-$server" >> $config_file
echo " AddressFamily inet" >> $config_file
echo " User root" >> $config_file
echo " Port $ssh_port" >> $config_file
echo " IdentityFile $key_path" >> $config_file
echo " ServerAliveInterval 10" >> $config_file
echo " HostName localhost" >> $config_file
echo " NoHostAuthenticationForLocalhost yes" >> $config_file
echo
echo "retrieving trusted fingerprint from https://$relay_fqdn/trusted"
curl https://$relay_fqdn/trusted -o ./client-configs/trusted
echo
echo "retrieving ssh fingerprint from $relay_fqdn" 
ssh-keyscan -t rsa $relay_fqdn > ./client-configs/tested
echo
echo "running diff against trusted and tested"
echo
echo '________________________________________________________________'
diff -s ./client-configs/trusted ./client-configs/tested
echo '________________________________________________________________'
echo
echo "identical files indicate a secure connection"
echo "non-matching files may indicate an active man-in-the-middle attack, review the files 'trusted' and 'tested' before continuing"
read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
echo
echo "populating known_hosts file and saving to ./client-configs/$known_hosts"
echo "enter the password for your SSH key for $server at the prompt"
if echo "$connection_type" | grep -iq "^s" ; then
    ssh -q -i $key_path -o StrictHostKeyChecking=no -o UserKnownHostsFile=./client-configs/$known_hosts $ssh_user@$relay_fqdn > /dev/null 2>&1
else
    ssh -q -i $key_path -o StrictHostKeyChecking=no -o UserKnownHostsFile=./client-configs/$known_hosts -o ProxyCommand="/usr/bin/ncat --ssl $relay_fqdn 443" $ssh_user@localhost > /dev/null 2>&1
fi
echo
