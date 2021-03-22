#!/bin/bash

# Script to automate the join process to an Active Directory Domain for Ubuntu VMs
# Usage:
# 	1. Configure the required variables
# 	2. set execution permissions: chmod +x <script_name>
#	  3. Run the script with: ./<script_name>

DNS1="10.0.33.4"                        # required variable
DNS2=""                                 # optional variable
DOMAIN="LOWELLCLOUD.LOCAL"              # required variable
DOMAINADMIN="dkiel"                     # required variable

function up_lower_domain {
        loweerdomain=${DOMAIN,,}
        upperdomain=${DOMAIN^^}
}


function basic_requirmeents {
# Checks if the required variables are properly configured
        [[ "${DNS1}" == "" ]] && { echo "variable DNS1 is empty but it is required"; exit; }
        [[ "${DOMAIN}" == "" ]] && { echo "variable DOMAIN is empty but it is required"; exit; }
        [[ "${DOMAINADMIN}" == "" ]] && { echo "variable DOMAINADMIN is empty but it is required"; exit; }
}


function configure_hosts_resolv {
# configures files:
#       /etc/hosts
#       /etc/resolv.conf
        echo "127.0.0.1 $(hostname) $(hostname).lowellcloud.local" > /etc/hosts
        systemctl disable systemd-resolved
        systemctl stop systemd-resolved
        [[ -L /etc/resolv.conf ]] && unlink /etc/resolv.conf
        [[ -z "${DNS1}" ]] || { [[ $(grep ${DNS1} /etc/resolv.conf) ]] || echo "nameserver ${DNS1}" >> /etc/resolv.conf; }
        [[ -z "${DNS2}" ]] || { [[ $(grep ${DNS2} /etc/resolv.conf) ]] || echo "nameserver ${DNS2}" >> /etc/resolv.conf; }

        echo "Files condiguration: OK"
}


function validate_connections {
# checks connectivity to Internet and DNS1
        [[ $(ping -c 2 github.com) ]] || exit
        [[ $(ping -c 2 ${DNS1}) ]] || exit

        echo "Connectivity: OK"
}


function install_packages {
# Installs the required packages in Ubuntu
        [[ $(echo | apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit krb5-user) ]] || exit

        echo "Packages installation: OK"
}


function discover_domain {
# discovers the domain
# If the domain is not discoverable, it does not continue
        [[ $(realm discover ${upperdomain}) ]] && echo "Domain dicover: OK" || echo "There is a problem discovering the domain upperdomain"
}


function modify_krb5_file {
# Configures the file /etc/krb5.conf
        [[ $(grep "#kdc_timesync = 1" /etc/krb5.conf) ]] || sed -i 's/kdc_timesync = 1/#kdc_timesync = 1/' /etc/krb5.conf
        [[ $(grep "#ccache_type = 4" /etc/krb5.conf) ]] || sed -i 's/ccache_type = 4/#ccache_type = 4/' /etc/krb5.conf
        [[ $(grep "#forwardable = true" /etc/krb5.conf) ]] || sed -i 's/forwardable = true/#forwardable = true/' /etc/krb5.conf
        [[ $(grep "#proxiable = true" /etc/krb5.conf) ]] || sed -i 's/proxiable = true/#proxiable = true/' /etc/krb5.conf
        [[ $(grep "dns_lookup_realm = false" /etc/krb5.conf) ]] || sed -i '/#proxiable = true/a \\tdns_lookup_realm = false' /etc/krb5.conf
        [[ $(grep "ticket_lifetime = 24h" /etc/krb5.conf) ]] || sed -i '/#proxiable = true/a \\tticket_lifetime = 24h' /etc/krb5.conf
        [[ $(grep "renew_lifetime = 7d" /etc/krb5.conf) ]] || sed -i '/#proxiable = true/a \\trenew_lifetime = 7d' /etc/krb5.conf
        [[ $(grep "forwardable = true" /etc/krb5.conf) ]] || sed -i '/#proxiable = true/a \\tforwardable = true' /etc/krb5.conf
        [[ $(grep "rdns = false" /etc/krb5.conf) ]] || sed -i '/#proxiable = true/a \\trdns = false' /etc/krb5.conf
}


function join_domain {
# joins the VM into the domain
        [[ $(realm list | grep configured) ]] || realm join --verbose ${upperdomain} -U "${DOMAINADMIN}@${upperdomain}" && echo "VM already joined the domain ${upperdomain}"
}


function enable_auto_home {
# configures the module to auto create the home directory
        pam-auth-update --enable mkhomedir
}


function reconfigure_restart_ssh {
# reconfigures sshd service to accept passwords in ssh connections and restarts the service
        [[ $(grep "PasswordAuthentication yes" /etc/ssh/sshd_config) ]] || sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        systemctl restart sshd.service
        [[ $(systemctl status sshd.service | grep running) ]] && echo "SSH service was reconfigured and restarted"
}


basic_requirmeents
up_lower_domain
configure_hosts_resolv
validate_connections
install_packages
discover_domain
modify_krb5_file
join_domain
enable_auto_home
reconfigure_restart_ssh
