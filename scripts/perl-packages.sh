#!/bin/bash

PERL_PACKAGES="Digest::SHA1 Digest::HMAC Net::DNS Time::HiRes HTML::Tagset HTML::Parser  Parse::Syslog Statistics::Distributions "

PERL_PACKAGES_FILE=perl-packages.list

if [ -r ${PERL_PACKAGES_FILE} ]; then
  echo "Found list of perl modules to be installed (${PERL_PACKAGES_FILE}) ... installing ..."
  for PACKAGE in $(cat ${PERL_PACKAGES_FILE}); do
    echo "Installing perl package: ---- ${PACKAGE}"
    echo "perl -MCPAN -e \"install ${PACKAGE}\" "
  done

fi  

# Some packages don't get installed easily.
# At this point, you just need to change into each directory of the module and install it using the actual manual compilation technique.
# [root@qmail build]# cd /root/.cpan/build/Net-Ident-1.20/
# [root@qmail Net-Ident-1.20]# perl Makefile.PL && make && make install


