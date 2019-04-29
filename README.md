# telesploit-client
Scripts to create an open source Telesploit client

From the computer being used to access the Telesploit server, download the files or run 'git clone https://github.com/telesploit/telesploit-client.git'

On Linux, update the relay_fqdn variable in telesploit-client/server.cfg.
From a console, navigate to the telesploit-client/linux/ directory and run ./setup_client.sh.
After the client is configured run ./create_tunnels to establish the required connections to the relay.
Finally run ./console.sh to obtain a shell on the Telesploit server.

On Windows, partially preconfigured KiTTY client files have been provided.
Change the relay FQDN once the sessions have been imported into KiTTY or modify the following lines prior to import:
Telesploit-os-Relay-SSH, line 293 - HostName\telesploit-relay@relay-test.telesploit.com\
Telesploit-os-Relay-SSL, line 266 (requires ncat) - ProxyTelnetCommand\ncat%20--ssl-verify%20relay-os.telesploit.com%20443\

The commercial version of Telesploit includes fully configured SSH clients for Bitvise, KiTTY, and PuTTy.
