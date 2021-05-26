#!/bin/bash
# Script to validate requirements for CIFS and network activity while mounting the filesyste,
# Usage:
#   cifs-validator.sh "mount -t cifs //mystorageaccountxxxxx.file.core.windows.net/aksshare1 /home/xxxxxxx/aksshare1 -o vers=3.0,credentials=/etc/smbcredentials/mystorageaccountxxxxx.cred,dir_mode=0777,file_mode=0777,serverino"

SECONDS=0
date=$(date +%d%m%Y-%H%M)
command=$1
log_file="/tmp/cifs-validator-${date}.log"
tcpdump_cap="/tmp/tcpdump-output-${date}.cap"

echo "CIFS Mount validation"

storage_account=$(echo $command | cut -d'/' -f 3)
file_share=$(echo $command | cut -d'/' -f 4)
mount_point=$(echo $command | cut -d' ' -f 5)
credentials_file=$(echo $command | sed -n -e 's/^.*credentials=//p' | cut -d',' -f 1)

function storage_account_connection {
    echo "Telnet test to Storage Account" >> ${log_file}
    { time sleep 10 | telnet ${storage_account} 445 >> ${log_file}; } 2>> ${log_file}
    echo "-----------------------------------------------------------" >> ${log_file}
}

function mount_point_validation {
    echo "Local mount point validation: ${mount_point}" >> ${log_file}
    [[ ! -d ${mount_point} ]] && echo "Local mount point does not exist" >> ${log_file} || echo "Local mount point is OK" >> ${log_file}
    echo "-----------------------------------------------------------" >> ${log_file}
}

function credentials_validation {
    echo "Credentials validation: ${credentials_file}" >> ${log_file}
    [[ ! -f ${credentials_file} ]] && echo "Credentials file does not exist" >> ${log_file} || echo "Credentials file is OK" >> ${log_file}
    echo "-----------------------------------------------------------" >> ${log_file}
}

function test_mount {
    echo "Taking some time to capture the network traffic will the mount command runs"
    echo "TCP and mount commands" >> ${log_file}
    timeout 20 tcpdump -nn -vvv -i eth0 port not '(22 or 80 or 443)' and dst not 168.63.129.16 and src not 168.63.129.16 -w ${tcpdump_cap} &
    strace ${command} 2>> ${log_file} >> ${log_file}
    echo "-----------------------------------------------------------" >> ${log_file}
    wait
}

function summary {
    totaltime=${SECONDS}
    echo "Total time: $((${totaltime} / 60)) minutes and $((${totaltime} % 60)) seconds elapsed." | tee >> ${log_file}
}

storage_account_connection
mount_point_validation
credentials_validation
test_mount
summary
