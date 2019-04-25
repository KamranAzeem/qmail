#!/bin/bash
# https://sourceforge.net/projects/vpopmail/
# Vpopmail is a set of programs for creating and managing multiple virtual domains on a qmail server, 
#   with full support for many POP/IMAP servers. 
# A web interface to vpopmail called QmailAdmin is on SourceForge as well.

# https://sourceforge.net/projects/vpopmail/files/vpopmail-stable/5.4.33/vpopmail-5.4.33.tar.gz/download
VPOPMAIL_URL=https://sourceforge.net/projects/vpopmail/files/vpopmail-stable/5.4.33/vpopmail-5.4.33.tar.gz/download



echo
echo "------------------------------------------------------------------------------------"
echo

# Prepare mysql for vpopmail: (todo)
# Notes: The following (mysql related) steps are useful (but not necessary) to do 
#         before actually configuring, compiling and installing vpopmail.
#        It is because there are certain "tests", which are performed as part of vpopmail installation
#         , which tries to make a connection with the configured mysql server with the credentials you provide.
#        This information is shown at the end of the make install-strip command, which you can't miss. 
#        I just want to find an automated way to get all of the following done,
#          ,  **without** hardcoding dbhost, dbname, dbuser and db password.
#        I also want to be able to setup a mysql database through the script - in an automated way.


# mkdir ~vpopmail/etc
# chown vpopmail:vchkpw ~vpopmail/etc
# echo "localhost|0|vpopmaildbuser|redhat|vpopmail" > ~vpopmail/etc/vpopmail.mysql


# mysql -u root
# mysql> create database vpopmail;
# mysql> grant all on vpopmail.* to vpopmaildbuser@localhost identified by 'redhat';
# mysql> flush privileges;


echo "Downloading, compiling and installing vpopmail with mysql support ..."
echo
(
cd /usr/local/src/
echo "Downloading vpopmail from: ${VPOPMAIL_URL} ..."
FILENAME=$(basename $(dirname  $VPOPMAIL_URL))
curl -sL ${VPOPMAIL_URL} -o ${FILENAME}
tar xzf ${FILENAME}
DIRNAME=$(basename ${FILENAME} .tar.gz)
cd ${DIRNAME}

# Notes:
# * DO NOT USE the --enable-maildrop switch in vpopmail,
#     , otherwise you will not get any mails and will get "Unable to open mailbox" errors in the maillog.
# * Need to work on "onchange-script" later. Don't use it at the moment.



./configure --enable-logging=p --enable-auth-module=mysql --disable-clear-passwd \
  --disable-many-domains --enable-sql-logging --enable-mysql-replication --enable-valias \
  --disable-roaming-users --enable-spamassassin --enable-mysql-limits --enable-libdir=/usr/lib64/mysql/

make
make install-strip


echo
echo "Note: From qmailadmin's INSTALL file:"
echo "Please note that any time you reconfigure and install vpopmail"
echo "you will need to rebuild and install QmailAdmin.  QmailAdmin"
echo "statically links libvpopmail, so you need to recompile it"
echo "whenever libvpopmail changes."
echo
)

echo
echo "Setting up vchkpw as setuid ... (Based on explanation by JMS - https://qmail.jms1.net/upgrade-qmr.shtml ..."
echo
chmod u+s /home/vpopmail/bin/vchkpw 
ls -l /home/vpopmail/bin/vchkpw
echo

