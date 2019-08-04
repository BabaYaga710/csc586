#!/bin/bash 
# make sure to run script as sudo 


# LDAP 

# update first 
apt-get -q -y update 

# install maven 

apt-get install -y maven 

# Install php dependencies 

apt-get -y install php php-cgi libapache2-mod-php php-common php-pear php-mbstring 

a2enconf php7.0-cgi 

service apache2 restart 

# Pre-seed the slapd passwords 

export DEBIAN_FRONTEND='non-interactive'

echo -e "slapd slapd/root_password password password" |debconf-set-selections
echo -e "slapd slapd/root_password_again password password" |debconf-set-selections

echo -e "slapd slapd/internal/adminpw password password" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password password" |debconf-set-selections
echo -e "slapd slapd/password2 password password" |debconf-set-selections
echo -e "slapd slapd/password1 password password" |debconf-set-selections
echo -e "slapd slapd/domain string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd shared/organization string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd slapd/backend string MDB" |debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
echo -e "slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
echo -e "slapd slapd/allow_ldap_v2 boolean false" |debconf-set-selections
echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections

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
URI     ldap://192.168.1.1

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
EOF

# Be safe again 
chmod 744 /etc/ldap/ldap.conf 


# Now change all values in /etc/phpldapadmin/config.php to their actual values from example, or .com or localhost (I use sed)
echo -e "slapd slapd/internal/adminpw password password" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password password" |debconf-set-selections
echo -e "slapd slapd/password2 password password" |debconf-set-selections
echo -e "slapd slapd/password1 password password" |debconf-set-selections
echo -e "slapd slapd/domain string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd shared/organization string clemson.cloudlab.us" |debconf-set-selections
echo -e "slapd slapd/backend string MDB" |debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
echo -e "slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
echo -e "slapd slapd/allow_ldap_v2 boolean false" |debconf-set-selections
echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections

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
URI     ldap://192.168.1.1

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
EOF


# Line 286 
sed -i "s@$servers->setValue('server','name','LDAP Server');.*@$servers->setValue('server','name','LDAP');@" /etc/phpldapadmin/config.php
# Line 293 
sed -i "s@$servers->setValue('server','host','192.168.1.1');.*@$servers->setValue('server','host','192.168.1.1');@" /etc/phpldapadmin/config.php 
# Line 300 
sed -i "s@$servers->setValue('server','base',array('dc=clemson,dc=cloudlab,dc=us'));.*@$servers->setValue('server','base',array('dc=acu,dc=local'));@" /etc/phpldapadmin/config.php
# Line 326 
sed -i "s@$servers->setValue('login','bind_id','cn=admin,dc=clemson,dc=cloudlab,dc=us');.*@$servers->setValue('login','bind_id','cn=admin,dc=clemson,dc=cloudlab,dc=us');@" /etc/phpldapadmin/config.php

# Prevent error when creating users 

sed -i "s@$default = $this->getServer()->getValue('appearance','password_hash');.*@$default = $this->getServer()->getValue('appearance','password_hash_custom');@g" /usr/share/phpldapadmin/lib/TemplateRender.php

service apache2 restart 

cp /local/repository/basedn.ldif /users/*
cp /local/repository/users.ldif /users/*
