#!/bin/bash

# alias
# alias getinfo='echo "" >vminfo; vim vminfo; ./getinfo.sh vminfo'

propertiesfile=$1
echo "VM properties file: ${propertiesfile}"
echo "-------"

echo "$(grep "VM Name" ${propertiesfile} | awk '{print $1$2" "$3}')"
echo "$(grep "Resource Group" ${propertiesfile} | awk '{print $1$2" "$3}')"
echo "$(grep "State" ${propertiesfile} | grep -Ev 'Allocation|Power')"
echo "$(grep "Region" ${propertiesfile} | grep -Ev 'Network|Virtual')"
echo "$(grep "OS" ${propertiesfile} | grep -Ev 'Disk|using|Created|Guest')"
echo "$(grep -i "HyperV Generation Type" ${propertiesfile} | awk '{print $2" "$4}')"
echo "$(grep -i "Create Option" ${propertiesfile} | awk '{print $1$2" "$3}')"
echo "$(grep -i "Current Power State" ${propertiesfile} | awk '{print $2$3" "$4}')"
echo "$(grep -i "DIPs" ${propertiesfile} | awk '{print "PrivateIPs "$2","$3}')"
echo "$(grep -i "Public IPs" ${propertiesfile} | grep -v "Balancer\|Gateway" | awk '{print "PublicIPs "$4}')"
echo "$(grep -i "Virtual Network" ${propertiesfile} | awk '{print "VNET "$3}')"
echo "$(grep -i "Subnets" ${propertiesfile})"
echo "$(grep -i "Private IP Allocation Method" ${propertiesfile} | awk '{print "IPconf "$5}')"
echo "$(grep -i "VM Instance Time Created" ${propertiesfile} | awk '{print $3$4" "$5"-"$6}')"
echo "$(grep -i "OS Created From" ${propertiesfile} | awk '{print $1$2" "$4"-"$5}')"
echo "$(grep -i "Publisher " ${propertiesfile} | awk '{print "POSV "$8}')"
echo "$(grep -i "Guest Agent Status" ${propertiesfile} | awk '{print G$2$3" "$4"_"$5}')"
echo "$(grep -i "Guest Agent Message" ${propertiesfile} | awk '{print G$2$3" "$4"_"$5"_"$6"_"$7}')"
echo "$(grep -i "Guest Agent Version" ${propertiesfile} | awk '{print G$2$3" "$4}')"
echo "$(grep -i "GuestOSName" ${propertiesfile})"
echo "$(grep -i "GuestOSVersion" ${propertiesfile})"
echo "$(grep -i "GuestOSKernelVersion" ${propertiesfile})"
echo "$(grep -i "Size" ${propertiesfile})"
echo "$(grep -i "Billing Code" ${propertiesfile} | awk '{print $1$2" "$3}')"
