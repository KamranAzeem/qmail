#!/bin/bash
echo "This script installs all necessary packages required for qmail setup."

yum -y install  kernel-devel kernel-headers git \
  net-snmp net-snmp-utils net-snmp-libs mrtg \
  httpd httpd-devel php php-imap php-mysql php-gd php-pear php-zlib php-mbstring php-xml \
  gcc gcc-c++ gdbm-devel pcre-devel libtool-ltdl libtool-ltdl-devel \
  mysql-server mysql-devel db4 db4-devel postgresql-devel \
  openssl openssl-devel openldap-servers \
  perl perl-libwww-perl perl-Digest-SHA1 perl-Digest-HMAC perl-Net-DNS perl-HTML-Tagset perl-HTML-Parser perl-Time-HiRes perl-TimeDate perl-suidperl perl-DateManip \
  spamassassin expect zlib-devel \
  fam fam-devel gamin-devel patch patchutils

