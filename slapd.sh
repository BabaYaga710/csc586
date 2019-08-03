#!/bin/bash

sudo apt-get update


set -eu

status () {
  echo "---> ${@}" >&2
}

set +x
: LDAP_ROOTPASS=password
: LDAP_DOMAIN=clemson.cloudlab.us
: LDAP_ORGANISATION=clemson.cloudlab.us

  cat <<EOF | debconf-set-selections
slapd slapd/password1 password password
slapd slapd/password2 password password
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/domain string clemson.cloudlab.us
slapd shared/organization string clemson.cloudlab.us
slapd slapd/backend string MDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils

DEBIAN_FRONTEND=noninteractive dpkg-reconfigure slapd

  cat <<EOF > basedn.ldif
dn: ou=People,dc=clemson,dc=cloudlab,dc=us
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=clemson,dc=cloudlab,dc=us
objectClass: organizationalUnit
ou: Groups

dn: cn=CSC,ou=Groups,dc=clemson,dc=cloudlab,dc=us
objectClass: posixGroup
cn: CSC586
gidNumber: 5000
EOF

ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -W -f basedn.ldif

  cat <<EOF > users.ldif
dn: uid=student,ou=People,dc=clemson,dc=cloudlab,dc=us
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: student
sn: Ram
givenName: Golden
cn: student
displayName: student
uidNumber: 10000
gidNumber: 5000
userPassword: password
gecos: Golden Ram
loginShell: /bin/dash
homeDirectory: /home/student
EOF

ldapadd -x -D cn=admin,dc=clemson,dc=cloudlab,dc=us -W -f users.ldif

ldapsearch -x -LLL -b dc=clemson,dc=cloudlab,dc=us 'uid=student' cn gidNumber
