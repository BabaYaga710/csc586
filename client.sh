#!/bin/bash

chmod +x client.sh

sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl restart apache2

sudo apt-get install -qq libpam-ldap

rm /etc/libnss-ldap.conf
wait 3
touch /etc/libnss-ldap.conf
echo "base dc=clemson,dc=cloudlab,dc=us" >> /etc/libnss-ldap.conf
echo "uri ldap://192.168.1.1" >> /etc/libnss-ldap.conf
echo "ldap_version 3" >> /etc/libnss-ldap.conf
echo "rootbinddn cn=admin,dc=clemson,dc=cloudlab,dc=us" >> /etc/libnss-ldap.conf
rm   /etc/pam_ldap.conf
touch /etc/pam_ldap.conf
echo "base dc=clemson,dc=cloudlab,dc=us" >> /etc/pam_ldap.conf
echo "uri ldap://192.168.1.1" >> /etc/pam_ldap.conf
echo "ldap_version 3" >> /etc/pam_ldap.conf
echo "rootbinddn cn=admin,dc=clemson,dc=cloudlab,dc=us" >> /etc/pam_ldap.conf
apt-get install libnss-ldap libpam-ldap nscd -y --force-yes
dpkg-reconfigure libnss-ldap
rm /etc/ldap/ldap.conf
echo "BASE    dc=clemson,dc=cloudlab,dc=us" >> /etc/ldap/ldap.conf
echo "URI     ldap://192.168.1.1" >> /etc/ldap/ldap.conf
echo "TLS_CACERT      /etc/ssl/certs/ca-certificates.crt" >>  /etc/ldap/ldap.conf
rm -r /etc/nsswitch.conf
touch  /etc/nsswitch.conf
echo "passwd: compat system ldap" >> /etc/nsswitch.conf
echo "group: compat system ldap" >> /etc/nsswitch.conf
echo "shadow: compat ldap" >> /etc/nsswitch.conf
echo "gshadow:        files" >> /etc/nsswitch.conf
echo "hosts:          files dns" >> /etc/nsswitch.conf
echo "networks:       files" >> /etc/nsswitch.conf
echo "protocols:      db files" >> /etc/nsswitch.conf
echo "services:       db files" >> /etc/nsswitch.conf
echo "ethers:         db files" >> /etc/nsswitch.conf
echo "rpc:            db files" >> /etc/nsswitch.conf
echo "netgroup:       nis" >> /etc/nsswitch.conf
rm /etc/pam.d/common-auth
touch  /etc/pam.d/common-auth
echo "auth    [success=2 default=ignore]      pam_unix.so obscure sha512" >> /etc/pam.d/common-auth
echo "auth    [success=1 default=ignore]      pam_ldap.so use_first_pass" >> /etc/pam.d/common-auth
echo "auth    requisite                       pam_deny.so" >> /etc/pam.d/common-auth
echo "auth    required                        pam_permit.so" >> /etc/pam.d/common-auth
rm /etc/pam.d/common-password
touch /etc/pam.d/common-password
echo "password        [success=2 default=ignore]      pam_unix.so obscure sha512" >> /etc/pam.d/common-password
echo "password        [success=1 user_unknown=ignore default=die]     pam_ldap.so use_authtok try_first_pass" >> /etc/pam.d/common-password
echo "password        requisite                       pam_deny.so" >> /etc/pam.d/common-password
echo "password        required                        pam_permit.so" >> /etc/pam.d/common-password
rm /etc/pam.d/common-session-noninteractive
touch /etc/pam.d/common-session-noninteractive
echo "session [default=1]                     pam_permit.so" >> /etc/pam.d/common-session-noninteractive
echo "session requisite                       pam_deny.so" >> /etc/pam.d/common-session-noninteractive
echo "session required                        pam_permit.so" >> /etc/pam.d/common-session-noninteractive
echo "session required        pam_unix.so" >> /etc/pam.d/common-session-noninteractive
echo "session optional                        pam_ldap.so" >> /etc/pam.d/common-session-noninteractive
echo "session required	pam_mkhomedir.so skel=/etc/skel/ umask=0077"	>> /etc/pam.d/common-session
echo "%main   ALL=(ALL:ALL) ALL" >> /etc/sudoers
rm /etc/libnss-ldap.secret
touch /etc/libnss-ldap.secret
echo "password" >> /etc/libnss-ldap.secret
service nscd restart

sudo su - student
echo "password"
