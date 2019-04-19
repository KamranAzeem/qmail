#!/bin/bash
echo "This script installs all necessary packages required for qmail setup. - on CENTOS 7" 

yum -y update 

yum -y install epel-release*

yum -y install  kernel-devel kernel-headers git which tar unzip curl bzip2 gzip \
  telnet traceroute net-utils bind-utils  \
  net-snmp net-snmp-utils net-snmp-libs mrtg \
  httpd httpd-devel php php-imap php-mysql php-gd php-pear php-zlib php-mbstring php-xml \
  gcc gcc-c++ gdbm-devel pcre-devel libtool-ltdl libtool-ltdl-devel \
  mariadb-server mariadb-devel mariadb libdb4 libdb4-devel libdb4-utils compat-db47 postgresql-devel \
  openssl openssl-devel openldap-servers \
  perl perl-CPAN perl-libwww-perl perl-Digest-SHA1 perl-Digest-HMAC \
       perl-Net-DNS perl-HTML-Tagset perl-HTML-Parser perl-Time-HiRes \
       perl-TimeDate perl-suidperl perl-DateManip perl-CDB_File perl-Net-LibIDN \
  spamassassin expect zlib-devel \
  libidn libidn-devel libidn2 libidn2-devel \
  fam fam-devel gamin-devel patch patchutils

# No package php-imap available. # in epel
# No package db4 available. # in epel - libdb4
# No package db4-devel available. # in epel - libdb4-devel


