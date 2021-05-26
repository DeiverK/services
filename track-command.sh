#!/usr/bin/env bash

# this scripts receives a command and executes the command to track the network activity and the system calls
# usage:
#   track-command.sh "command to track"
#   track-comamnd.sh "ssh remotehost"


command=$1
datetime=$(date +%d%m-%H%M)
script_log="/tmp/script_log.$(date +%d%m-%H%M)"

function start_tcpdump {
    tcpdump -U -i eth0 -nn not port '(22 or 443 or 80)' and not host 168.63.129.16 -w /tmp/tcpdump-${datetime} & >> ${script_log}
    sleep 3
}


function get_tcpdump_pid {
    tcpdump_pid=$(ps -ef | grep "tcpdump -U" | grep -v grep | awk '{print $2}')
    echo ${tcpdump_pid}
}


function run_strace {
    strace -o /tmp/stout-${datetime} ${command} >> ${script_log}
    sleep 3
    kill -9 $(get_tcpdump_pid)
}


start_tcpdump
run_strace
get_tcpdump_pid

exit 0
