#!/bin/bash

echo "Creating necessary OS users and groups for qmail to work properly ..."

mkdir /var/qmail

groupadd nofiles
useradd  -g nofiles -d /var/qmail/alias -s /sbin/nologin -p '*'  -c 'qmail alias user'  alias
useradd  -g nofiles -d /var/qmail -s /sbin/nologin -p '*'  -c 'qmail daemon user'       qmaild
useradd  -g nofiles -d /var/qmail -s /sbin/nologin -p '*'  -c 'qmail log user'          qmaill
useradd  -g nofiles -d /var/qmail -s /sbin/nologin -p '*'  -c 'qmail password user'     qmailp

groupadd qmail
useradd  -g qmail -d /var/qmail -s /sbin/nologin -p '*'  -c 'qmail queue user'  qmailq
useradd  -g qmail -d /var/qmail -s /sbin/nologin -p '*'  -c 'qmail remote user' qmailr
useradd  -g qmail -d /var/qmail -s /sbin/nologin -p '*'  -c 'qmail send user'   qmails


# The following is needed for maildrop and vpopmail, and everything which depends on vpopmail.
groupadd  vchkpw
useradd  -g vchkpw -d /home/vpopmail -s /sbin/nologin  -p '*' -c 'vpopmail user' vpopmail
