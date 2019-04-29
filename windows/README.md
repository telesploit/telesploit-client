For detailed instructions download the Windows client configuration guide from https://www.telesploit.com

Assigned Ports:

SSH: 14000
VNC: 14001
RDP: 14002
Web Proxy: 14003
SOCKS Proxy: 14004
IRC: 14008
Collaboration: 14009

Telesploit Open Source includes configuration files for KiTTY:

KiTTY (kitty_portable.exe) - https://www.9bis.net/kitty/?page=Download

Note: Change the relay FQDN once the sessions have been imported into KiTTY or modify the following lines prior to import:
Telesploit-os-Relay-SSH, line 293 - HostName\telesploit-relay@relay-test.telesploit.com\
Telesploit-os-Relay-SSL, line 266 (requires ncat) - ProxyTelnetCommand\ncat%20--ssl-verify%20relay-os.telesploit.com%20443\

The commercial version of Telesploit also includes fully configured SSH clients for the following applications:

Bitvise - https://www.bitvise.com/ssh-client-download
PuTTY - https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
