#!/bin/bash
source ./client-configs/client.cfg
connection=$(cat "$connection_file")
ssh -F $config_file server-$server
