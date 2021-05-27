#!/usr/bin/env bash

# This script pings a remote host to check the availability and keeps a log of it
# Usage:
# ping.sh 8.8.8.8 24
# Fisrt parameter is the remote host
# Second parameter is the time frame of the test
remote_host=$1
time_in_hours=$2
working_folder="$(pwd)"
faillog="${working_folder}/availability-fail-${remote_host}.log"
successlog="${working_folder}/availability-success-${remote_host}.log"
iterationlog="${working_folder}/iteration-${remote_host}.log"


let iterations=3600*${time_in_hours}
let lap=0


while [ ${lap} -lt ${iterations} ]
do
    ping -c 1 ${remote_host} >> ${iterationlog}
    if [[ $? -ne 0 ]]
    then
        current_date=$(date +%d-%m-%Y" "%T)
        echo "The ${remote_host} is not available... Ping failed at: ${current_date}" >> ${faillog}
        ((lap=lap+10))
    else
        current_date=$(date +%d-%m-%Y" "%T)
        echo "Ping working to ${remote_host}. Time: ${current_date}" >> ${successlog}
        sleep 1s
    fi
    ((lap=lap+1))
done

exit 0
