#!/bin/bash
source ./client-configs/client.cfg
connection=$(cat "$connection_file")
ssh -N -f -F $config_file $connection
