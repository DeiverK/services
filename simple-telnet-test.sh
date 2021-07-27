#!/bin/bash

list=$1
port=389

while read ip
do
    case $(telnet ${ip} ${port} </dev/null 2>&1 | tail -1) in
        (*closed*) echo "telnet to ${ip} connected " >>Telnet_results.txt
          ;;
        (*refused*) echo "telnet to ${ip} Refused " >>Telnet_results.txt
          ;;
        (*)         echo "telnet to ${ip} Failed " >>Telnet_results.txt
    esac
done <${list}

exit 0
