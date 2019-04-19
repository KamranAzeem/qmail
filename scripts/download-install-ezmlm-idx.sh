#!/bin/bash
# This script downloads and installs ezmlm-idx without installing the original ezmlm 0.5.3 by djb.
# It is because ezmlm-idx is now a standalone package.
# On one of my production servers, ezmlm-7.1.1 did not pick up the existing mailing lists,
#   so I had to use ezmlm-6.0.1 . Also, using mysql for this task is pretty useless, as all the 
#   mailing lists are maintained as files under the ~vpopmail/<domainname>/  directory. 
#   And, qmailadmin sees those mailing lists just fine.

# If you want, you can compile ezmlm with mysql support. For that, you need to adjust certain files:
# * conf-cc
# * conf-ld
# * conf-mysql
# 
# See: http://ezmlm.untroubled.org/archive/7.2.2/README.mysql for more details
# Prerequisite: mysql-devel


echo
echo "------------------------------------------------------------------------------------"
echo



echo "Setting up ezmlm-idx 'without' mysql support ..."

(
cd /usr/local/src/

curl -sLO  http://ezmlm.untroubled.org/archive/7.2.2/ezmlm-idx-7.2.2.tar.gz
tar xzf ezmlm-idx-7.2.2.tar.gz
cd ezmlm-idx-7.2.2
chown -R root:root .
cd lang
ln -s en_US default
cd ..
make
make install
)

