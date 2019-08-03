#!/bin/bash 
# make sure to run script as sudo 


# LDAP 

# update first 
##apt-get -q -y update 
sudo apt-get update

## install maven 

##apt-get install -y maven 

# install slapd

sudo apt-get install -y slapd ldap-utils

## Install php dependencies 

## apt-get -y install php php-cgi libapache2-mod-php php-common php-pear php-mbstring 

## a2enconf php7.0-cgi 

## service apache2 restart 

# Pre-seed the slapd passwords 

export DEBIAN_FRONTEND='non-interactive'

echo -e "slapd slapd/root_password password password" |debconf-set-selections
echo -e "slapd slapd/root_password_again password password" |debconf-set-selections

echo -e "slapd slapd/internal/adminpw password password" |debconf-set-selections

echo -e "slapd slapd/internal/generated_adminpw password password" |debconf-set-selections

# Must reconfigure slapd for it to work properly 
sudo dpkg-reconfigure slapd 
echo -e "slapd slapd/domain string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd shared/organization string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd slapd/backend string MDB" |debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
#echo -e "slapd slapd/allow_ldap_v2 boolean false" |debconf-set-selections
#echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections

sudo ufw allow ldap

cat dn: ou=People,dc=clemson,dc=cloudlab,dc=us > basedn.ldif
cat objectClass: organizationalUnit > basedn.ldif
cat ou: People > basedn.ldif

cat dn: ou=Groups,dc=clemson,dc=cloudlab,dc=us > basedn.ldif
cat objectClass: organizationalUnit > basedn.ldif
cat ou: Groups > basedn.ldif

cat dn: cn=CSC,ou=Groups,dc=clemson,dc=cloudlab,dc=us > basedn.ldif
cat objectClass: posixGroup > basedn.ldif
cat cn: CSC586 > basedn.ldif
cat gidNumber: 5000 > basedn.ldif

ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -W -f basedn.ldif

cat dn: uid=student,ou=People,dc=clemson,dc=cloudlab,dc=us > users.ldif
cat objectClass: inetOrgPerson > users.ldif
cat objectClass: posixAccount > users.ldif
cat objectClass: shadowAccount > users.ldif
cat uid: student > users.ldif
cat sn: Ram > users.ldif
cat givenName: Golden > users.ldif
cat cn: student > users.ldif
cat displayName: student > users.ldif
cat uidNumber: 10000 > users.ldif
cat gidNumber: 5000 > users.ldif
cat userPassword: password > users.ldif
cat gecos: Golden Ram > users.ldif
cat loginShell: /bin/dash > users.ldif
cat homeDirectory: /home/student > users.ldif

ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -W -f users.ldif

ldapsearch -x -LLL -b dc=clemson,dc=cloudlab,dc=us 'uid=student' cn gidNumber

# Grab slapd and ldap-utils (pre-seeded)
apt-get install -y slapd ldap-utils phpldapadmin

# Must reconfigure slapd for it to work properly 
sudo dpkg-reconfigure slapd 

# Gotta replace the ldap.conf file, it comments out stuff we need set by default - first open it for writing 

chmod 777 /etc/ldap/ldap.conf 

cat <<'EOF' > /etc/ldap/ldap.conf
#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.


BASE    dc=clemson,dc=cloudlab,dc=us
URI     ldap://192.168.1.1 ldap://192.168.1.1

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
EOF

# Be safe again 
chmod 744 /etc/ldap/ldap.conf 


# Now change all values in /etc/phpldapadmin/config.php to their actual values from example, or .com or localhost (I use sed)


# Line 286 
sed -i "s@$servers->setValue('server','name','LDAP Server');.*@$servers->setValue('server','name','LDAP');@" /etc/phpldapadmin/config.php
# Line 293 
sed -i "s@$servers->setValue('server','host','192.168.1.1');.*@$servers->setValue('server','host','192.168.1.1');@" /etc/phpldapadmin/config.php 
# Line 300 
sed -i "s@$servers->setValue('server','base',array('dc=clemson,dc=cloudlab,dc=us'));.*@$servers->setValue('server','base',array('dc=clemson,dc=cloudlab,dc=us'));@" /etc/phpldapadmin/config.php
# Line 326 
sed -i "s@$servers->setValue('login','bind_id','cn=admin,dc=clemson,dc=cloudlab,dc=us');.*@$servers->setValue('login','bind_id','cn=admin,dc=clemson,dc=cloudlab,dc=us');@" /etc/phpldapadmin/config.php

# Prevent error when creating users 

sed -i "s@$default = $this->getServer()->getValue('appearance','password_hash');.*@$default = $this->getServer()->getValue('appearance','password_hash_custom');@g" /usr/share/phpldapadmin/lib/TemplateRender.php

service apache2 restart 

echo ------------------------# 
echo 'PHPldapadmin installed.'
echo ------------------------# 

echo ""

echo ------------------------------------------------------------# 
echo 'Can now access phpldapadmin at http://your-ip/phpldapadmin.'
echo ------------------------------------------------------------# 

echo ""

echo ------------------------------------------------------------------------#
echo 'Username should be cloudlab.clemson.us password is the adminpw set during setup.'
echo ------------------------------------------------------------------------# S

# Logging 

echo -e 'Maven installed -done by' $USER 'at time\n' $DATE '\n' >> /var/log/installs/log.txt
echo -e 'slapd and ldap-utils configured and installed -done by' $USER 'at time\n' $DATE '\n' >> /var/log/installs/log.txt
echo -e 'phpldapadmin install configured -done by' $USER 'at time\n' $DATE '\n' >> /var/log/installs/log.txt
echo -e 'LDAP installed completed by' $USER 'at time\n' $DATE '\n' >> /var/log/installs/log.txt
