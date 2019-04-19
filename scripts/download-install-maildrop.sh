#!/bin/bash

# Questions: What is maildrop? 
#            Why a piece of software in qmail installation is pulled from courier MTA website?
# Answer:
# The maildrop package contains the maildrop delivery agent/mail filter. 
#   This mail filter module is included in the Courier mail server, which uses it to filter incoming mail. 
#   So, you don't need to install it separately if you are using courier MTA.
#   But, we are not using Courier MTA! We are using Qmail.
#   Maildrop can also be used with other mail servers as well. So we will use it in our qmail installation.
# We download it from courier MTA website because they are ones developing it. 
#   ,(and) As mentioned above it is a standalone package which can be used with other MTAs too (like qmail).
#
# Big Question: Why install maildrop?
# Answer:
# I covered the answer in detail in my howtos on wbitt.com and blog.wbitt.com.
# First, the links, then the explanation:
# * https://wbitt.com/index.php?option=com_content&view=article&id=138:qmail-scanner-for-qmail&catid=34:howtos&Itemid=166
# * http://blog.wbitt.com/howtos-tutorials/autoresponder-and-courier-maildrop-for-qmail/
# * http://blog.wbitt.com/howtos-tutorials/qmail-scanner-for-qmail/
#
# Basically we need reformime from maildrop, which is used by qmail-scanner.
#   QmailScanner will stop working if it fails to find reformime. 
#   Actually, qmail-inject will also start failing. So you need it.
#   There is no package which provides reformime so maildrop is needed. 
# Qmail-Scanner̈́'s website lists this as a requirement, and also addresses this in two FAQs
# The FAQ # 9 and 10 on Qmail-Scanner site also explain the requirement of maildrop:
#   It says I must have reformime from the maildrop package! But I like procmail/[insert favorite MDA here]. 
#     Why do I have to....? 
#     You don't. reformime is needed for the extracting of MIME attachments by Qmail-Scanner - 
#       it doesn't have to be used by any other part of your system. Keep using procmail/whatever :-)
#   It says I must have maildrop installed. Will I have to install .qmail files for all users...?. 
#     You don't. Maildrop isn't used at all - only the reformime program that comes with it is. 
#     Qmail-Scanner installs at a very low level and doesn't require any per-user configuration.
#
# Memo: Some of this information is in the document: "Qmail on Centos 6.6 64 bit"
#
##########################################################################################################################


MAILDROP_URL=https://sourceforge.net/projects/courier/files/maildrop/3.0.0/maildrop-3.0.0.tar.bz2/download
UNICODE_URL=https://sourceforge.net/projects/courier/files/courier-unicode/2.1/courier-unicode-2.1.tar.bz2/download
SCRIPT_PATH=$(dirname $0)

echo
echo "------------------------------------------------------------------------------------"
echo



echo "Before we install maildrop, we need to create 'vchkpw' group and 'vpopmail' user . Creating ... "

groupadd vchkpw
useradd -g vchkpw -d /home/vpopmail -s /sbin/nologin -p '*' vpopmail


# You may need to install Courier unicode library  before you install maildrop. 
# From: http://www.courier-mta.org/download.html#unicode
# The Courier Unicode Library is used by most other Courier packages, 
# and needs to be installed in order to use them or build them.
# https://sourceforge.net/projects/courier/files/courier-unicode/2.1/courier-unicode-2.1.tar.bz2/download

# The download of software is a hassle, because they provide non-standard way to download each software.
# Each file is downloaded and saved as filename "download" . Also bzip2 is  needed to uncompress them.

echo "Downloading and compiling courier unicode ... (needed by courier-maildrop) ..."
(
cd /usr/local/src/
echo "Downloading Courier UNICODE from: ${UNICODE_URL} ..."
FILENAME=$(basename $(dirname  $UNICODE_URL))
curl -sL ${UNICODE_URL} -o ${FILENAME}
tar xjf ${FILENAME}
DIRNAME=$(basename ${FILENAME} .tar.bz2)
cd ${DIRNAME}
./configure
make
make install
echo
)


# maildrop also needs libidn (Internationalized Domain Name support) .
# libidn packages are available as yu/rpm packages (libidn-devel).

echo "Installing maildrop ... (needed by QMail-Scanner - later) ..."
(
cd /usr/local/src
echo "Downloading maildrop from: ${MAILDROP_URL} ..."
FILENAME=$(basename $(dirname  $MAILDROP_URL))
curl -sL ${MAILDROP_URL} -o ${FILENAME}
tar xjf ${FILENAME}
DIRNAME=$(basename ${FILENAME} .tar.bz2)
cd ${DIRNAME}


./configure --with-devel --enable-userdb --enable-maildirquota --enable-syslog=1 \
  --enable-trusted-users='root mail daemon postmaster qmaild mmdf' \
  --enable-restrict-trusted=0 --enable-maildrop-uid=root --enable-maildrop-gid=vchkpw

make
make install-strip
make install-man

echo
echo "Maildrop and reformime gets installed in /usr/local/bin/ . Here are the files:" 

ls -lh /usr/local/bin/maildrop /usr/local/bin/reformime 
echo
)



