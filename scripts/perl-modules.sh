#!/bin/bash

PERL_MODULES="Digest::SHA1 Digest::HMAC Net::DNS Time::HiRes HTML::Tagset HTML::Parser  Parse::Syslog Statistics::Distributions "

PERL_MODULES_FILE=perl-packages.list

if [ -r ${PERL_MODULES_FILE} ]; then
  echo "Found list of perl modules to be installed (${PERL_MODULES_FILE}) ..."
  for MODULE in $(cat ${PERL_MODULES_FILE}); do
    echo "Checking if ${MODULE} exists ..."
    perldoc -i -l ${MODULE}
    if [ $? -eq 0 ]; then 
      echo "Perl module ${MODULE} exists - skipping installation ..."
    else
      echo "Installing perl module:  ${MODULE} --- Using: perl -MCPAN -e 'install ${MODULE}'"
      perl -MCPAN -e "install ${MODULE}"

    fi
  done
fi


# Some packages don't get installed easily.
# At this point, you just need to change into each directory of the module and install it using the actual manual compilation technique.
# [root@qmail build]# cd /root/.cpan/build/Net-Ident-1.20/
# [root@qmail Net-Ident-1.20]# perl Makefile.PL && make && make install


