#!/bin/bash

SCRIPT_PATH=$(dirname $0)
echo $SCRIPT_PATH
PERL_MODULES_FILE=${SCRIPT_PATH}/perl-modules.list


if [ -r ${PERL_MODULES_FILE} ]; then
  echo "Found list of perl modules to be installed (${PERL_MODULES_FILE}) ..."

  echo
  echo "Please note: Some modules may require user input (yes, no, etc) ..."
  echo 
  sleep 5 

  for MODULE in $(cat ${PERL_MODULES_FILE}); do
    echo "Checking if ${MODULE} exists ..."
    perldoc -i -l ${MODULE}
    if [ $? -eq 0 ]; then 
      echo "Perl module ${MODULE} exists - skipping installation ..."
    else
      echo "Installing perl module:  ${MODULE} ..."
      # old method: (not reliable)
      # perl -MCPAN -e "CPAN::Shell->notest(install, ${MODULE})"
      echo "Performing: cpan -f -i ${MODULE}"
      cpan -f -i ${MODULE}
    fi
  done
else
  echo "File not found: ${PERL_MODULES_FILE}"
fi


# Some packages don't get installed easily.
# At this point, you just need to change into each directory of the module and install it using the actual manual compilation technique.
# [root@qmail build]# cd /root/.cpan/build/Net-Ident-1.20/
# [root@qmail Net-Ident-1.20]# perl Makefile.PL && make && make install


