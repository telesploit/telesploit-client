#!/bin/bash
source ./client-configs/client.cfg
connection=$(cat "$connection_file")
pids=$(ps -fp $(pgrep ssh) | grep $connection | awk '{print $2;}')
for fn in $pids; do kill -9 "$fn"; done
