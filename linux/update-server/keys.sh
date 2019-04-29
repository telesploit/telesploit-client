#!/bin/bash
source ./server.cfg
echo 'This script allows for updating the authorized_keys file on the Telesploit server'
echo
echo 'The following steps MUST be completed before running this script'
echo 'Step 1: Create a file containing all ssh public keys that require access to the server'
echo 'Step 2: Verify that the newly created file contents are properly formatted'
read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
echo
echo '________________________________________________________________'
echo
read -e -p 'Enter the full path and name of the file containing the ssh public keys, e.g. /home/clientname-keys/tester.keys, followed by [ENTER]: ' key_file
echo
echo '________________________________________________________________'
echo
echo "encrypting $key_file and copying to ./encrypted-configs/authorized.conf.gpg"
if [ -z "$gpg_key" ] ; then
    read -s -p 'Enter the server gpg key, no single quotes: ' gpg_key
    echo
fi
gpg --yes --no-tty --batch --passphrase $gpg_key -o ./encrypted-configs/authorized.conf.gpg -c $key_file
echo 'completed encrypting and copying file'
echo
echo '________________________________________________________________'
echo
echo 'Copy the ./encrypted-configs/authorized.conf.gpg file to the configs directory on the Telesploit server USB drive and reboot the device'
echo
