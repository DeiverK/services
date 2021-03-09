#!/bin/bash
# Just a basic cifs server to test local services
# Do not use it for production


function install_packages {
        yum install samba samba-client -y
}

function set_se_bool {
        setsebool -P samba_export_all_ro on
        setsebool -P samba_export_all_rw on
        setsebool -P samba_share_nfs on
        getsebool -a | grep samba | grep export
}

[[ ! -d " /samba/export_rw" ]] && mkdir -p /samba/export_rw
[[ $(grep samba_user1 /etc/passwd) ]] || useradd samba_user1
chown samba_user1:samba_user1 /samba/export_rw
semanage fcontext -at samba_share_t "/samba/export_rw(/.*)?"
restorecon -R /samba/export_rw
ls -ldZ /samba/export_rw

cp /etc/samba/smb.conf /etc/samba/smb.conf-$(date +%m%d%Y--%H%M).orig
[[ $(grep "Server string = Samba server %h" /etc/samba/smb.conf) ]] || sed -i '/user/a \\tServer string = Samba server %h' /etc/samba/smb.conf
[[ $(grep "hosts allow = 127. 10.0.4." /etc/samba/smb.conf) ]] || sed -i '/%h/a \\thosts allow = 127. 10.0.4.' /etc/samba/smb.conf
[[ $(grep "interfaces = lo" /etc/samba/smb.conf) ]] || sed -i '/127. 10.0.4./a \\tinterfaces = lo eth0' /etc/samba/smb.conf
[[ $(grep "#passdb backend = tdbsam" /etc/samba/smb.conf) ]] || sed -i 's/passdb backend = tdbsam/#passdb backend = tdbsam/' /etc/samba/smb.conf
[[ $(grep "passdb backend = smbpasswd:/etc/samba/smbpasswd.txt" /etc/samba/smb.conf) ]] || sed -i '/#passdb backend = tdbsam/a \\tpassdb backend = smbpasswd:/etc/samba/smbpasswd.txt' /etc/samba/smb.conf

[[ $(grep "bckp_storage" /etc/samba/smb.conf) ]] || \
echo -e "[bckp_storage]\n\tcomment = Folder for storing backups\n\tread only = no\n\tavailable = yes\n\tpath = /samba/export_rw\n\tpublic = yes \
\n\tvalid users = samba_user1\n\twrite list = samba_user1\n\twritable = yes\n\tbrowseable = yes" >> /etc/samba/smb.conf

(echo abcd; echo abcd) | smbpasswd -a samba_user1
pdbedit -Lv
systemctl start smb
smbclient -L //localhost -U samba_user1
