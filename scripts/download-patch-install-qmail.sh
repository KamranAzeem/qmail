#!/bin/bash
SCRIPT_PATH=$(dirname $0)
# echo $SCRIPT_PATH

# qmail software - run a sub-shell, and download the files at proper locations
( 
  echo "Downloading qmail, ucspi, daemontools and cdb into /downloads ..."
  echo

  mkdir /downloads
  cd /downloads

  # Download from main server in Chicago

  # wget http://cr.yp.to/software/qmail-1.03.tar.gz
  # wget http://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz
  # wget http://cr.yp.to/daemontools/daemontools-0.76.tar.gz

  curl -# -LO http://cr.yp.to/software/qmail-1.03.tar.gz
  curl -# -LO http://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz
  curl -# -LO http://cr.yp.to/daemontools/daemontools-0.76.tar.gz
  curl -# -LO http://cr.yp.to/cdb/cdb-0.75.tar.gz

  # From: http://www.lifewithqmail.org/lwq.html#installation
  #   /usr/local/src is a good choice for qmail and ucspi-tcp. daemontools should be built under /package.
   
  echo "Copying qmail-1.03.tar.gz, ucspi-tcp-0.88.tar.gz and cdb-0.75.tar.gz to /usr/local/src/" 
  cp /downloads/qmail-1.03.tar.gz   /usr/local/src/
  cp /downloads/ucspi-tcp-0.88.tar.gz /usr/local/src/
  cp /downloads/cdb-0.75.tar.gz /usr/local/src/

  echo "Unpacking qmail-1.03.tar.gz and ucspi-tcp-0.88.tar.gz in /usr/local/src/"

  cd /usr/local/src/
  tar xzf qmail-1.03.tar.gz && rm -f qmail-1.03.tar.gz
  tar xzf ucspi-tcp-0.88.tar.gz && rm -f ucspi-tcp-0.88.tar.gz
  tar xzf cdb-0.75.tar.gz && rm -f cdb-0.75.tar.gz

  echo "Copying and unpacking daemontools-0.76.tar.gz to the /package directory"

  mkdir /package 
  chmod 1755  /package
  cp /downloads/daemontools-0.76.tar.gz    /package/
  cd /package
  tar xzf  daemontools-0.76.tar.gz && rm -f daemontools-0.76.tar.gz 

  # Question: Why do we need to do "chmod 1755 /package"
  # Answer: http://www.lifewithqmail.org/lwq.html#installation

)

echo
echo "------------------------------------------------------------------------------------"
echo

# It is absolutely vital that you setup OS users and groups for qmail **BEFORE** you compile qmail.
# Otherwise compilation will fail.
# This is done in users-and-groups.sh file.

echo
echo "Leaving conf-split and conf-spawn with default values ..."
echo "conf-split:"
head -1  /usr/local/src/qmail-1.03/conf-split
echo
echo "conf-spawn:"
head -1  /usr/local/src/qmail-1.03/conf-spawn
echo

echo "Patching 'qmail' with JMS combined patch (http://qmail.jms1.net/patches/qmail-1.03-jms1.7.10.patch) ..."
echo 
(
  cd /downloads
  curl -sLO https://qmail.jms1.net/patches/qmail-1.03-jms1-7.10.patch

  # ls -l /downloads/qmail-1.03-jms1-7.10.patch

  cd /usr/local/src/qmail-1.03
  patch < /downloads/qmail-1.03-jms1-7.10.patch

  echo "Patch applied ..."
  echo

)

echo
echo "------------------------------------------------------------------------------------"
echo

echo "Compiling and installing qmail after patch is applied ..."
(
  cd /usr/local/src/qmail-1.03
  make clean
  make man
  make setup check
  ./install
  ./instcheck
)

echo
echo "------------------------------------------------------------------------------------"
echo

echo "Performing final configuration for qmail using './config-fast ${QMAIL_FQDN}' ..."
echo 
(
  cd /usr/local/src/qmail-1.03
  ./config-fast ${QMAIL_FQDN}
  
)

echo 
echo "Please note that you must not put your domain name in the locals file."
echo "Means, if you are configuring your server to host emails for the domain 'example.com' using vpopmail,"
echo "  , then the locals file must not contain the domain 'example.com'."
echo "It should only contain the full hostname of your server, such as 'qmail.example.com' ."
echo "Or, it could just be empty , but yet must exist."
echo "Great explanation by JMS here: https://qmail.jms1.net/upgrade-qmr.shtml"
echo "Look for: 'Problems with locals file' in the link above."
echo 

echo
echo "------------------------------------------------------------------------------------"
echo

echo "Patching and compiling ucspi-tcp-0.88 ..."
echo 
(
  echo "Download two important patches for ucspi-tcp-0.88 from JMS website ..."
  cd /downloads/
  curl -sLO https://qmail.jms1.net/ucspi-tcp/ucspi-rss2.patch
  curl -sLO https://qmail.jms1.net/ucspi-tcp/tcpserver-limits-2007-12-22.patch

  cd /usr/local/src/ucspi-tcp-0.88
  sed -i 's/extern int errno\;/\#include \<errno\.h\>/' error.h

  patch < /downloads/ucspi-rss2.patch
  patch < /downloads/tcpserver-limits-2007-12-22.patch

  make
  make setup check
  ./install
  ./instcheck
)

echo
echo "------------------------------------------------------------------------------------"
echo

echo "Patching, compiling and installing daemontools-0.76 ..."
echo
(
  cd /package/admin/daemontools-0.76/
  sed -i 's/extern int errno\;/\#include \<errno\.h\>/' src/error.h
  package/install
)


echo
echo "------------------------------------------------------------------------------------"
echo

echo "Setting up daemontools to start at boot time  ..."
if [ -d /etc/systemd/system ] ; then
  echo "This seems to be a systemd based system ... Good!"
  echo "Setting up daemontools.service systemd service ..."

  if [ -r scripts/daemontools.service ] && [ -d /etc/systemd/system ] ; then
    cp scripts/daemontools.service /etc/systemd/system/
    systemctl enable daemontools.service
    echo "daemontools setup as a systemd service."
  fi
else
  echo "This is not a systemd based system ...."
  echo "Need another way to setup daemontools to start at system boot time"
fi

echo
echo "------------------------------------------------------------------------------------"
echo


echo "Patching, compiling and installing  cdb-0.75  ..."
echo
(
  cd /usr/local/src/cdb-0.75
  sed -i 's/extern int errno\;/\#include \<errno\.h\>/' error.h
  make
  make setup check
) 

echo
echo "------------------------------------------------------------------------------------"
echo

echo "Setting up qmail log directories  ..."
echo
(
  mkdir /var/log/qmail 

  mkdir /var/log/qmail/qmail-send 
  mkdir /var/log/qmail/qmail-smtpd 
  mkdir /var/log/qmail/qmail-pop3d 

  chown -R qmaill:root /var/log/qmail
  chmod -R 750 /var/log/qmail
)


echo
echo "------------------------------------------------------------------------------------"
echo

echo "Setting up qmail boot script  ..."
echo


(

cat > /var/qmail/rc << RC_EOF
#!/bin/sh
# Using stdout for logging
# Using control/defaultdelivery from qmail-local to deliver messages by default
exec env - PATH="/var/qmail/bin:$PATH" qmail-start "`cat /var/qmail/control/defaultdelivery`"
RC_EOF

chmod +x /var/qmail/rc

echo './Maildir/' > /var/qmail/control/defaultdelivery

)



echo
echo "------------------------------------------------------------------------------------"
echo

echo "Setting up qmailctl script  directly in /var/qmail/bin/ ..."
echo

# The qmailctl script used by LWQ does not have ability to manage smtpd-tls.
#   My script has that feature.
# Also, LWQ qmailctl script will process just one cdb file.
#   My script will manage all cdb files inside /etc/tcp/ directory
# So, don't use this:
# curl -sL http://lifewithqmail.org/qmailctl-script-dt70 -o /var/qmail/bin/qmailctl

# Use this instead:
cp ${SCRIPT_PATH}/qmailctl /var/qmail/bin/
chmod +x /var/qmail/bin/qmailctl
ln -s /var/qmail/bin/qmailctl /usr/bin/


echo
echo "------------------------------------------------------------------------------------"
echo

echo "Setting up directories for supervise scripts ..."
echo
mkdir -p /var/qmail/supervise/qmail-send/log
mkdir -p /var/qmail/supervise/qmail-smtpd/log
mkdir -p /var/qmail/supervise/qmail-smtpd-tls/log

# Note: Not creating directories for pop3, as we will use Dovecot for pop3 and imap services.

echo
echo "------------------------------------------------------------------------------------"
echo


echo "Setting up /var/qmail/control/concurrencyincoming with value of 20 - not entirely necessary though!"
# This file is not a standard. It is just something used by LWQ smtpd/run script.
# The file is checked for it's value by LWQ's inst_check.sh script. 
# We are using JMS' smtpd/run script, not LWQ's , so we can skip this.
# I did this anyway for completeness sake.

echo 20 > /var/qmail/control/concurrencyincoming
chmod 644 /var/qmail/control/concurrencyincoming


echo
echo "------------------------------------------------------------------------------------"
echo

echo "Creating various 'run' and 'log/run' files ..."
echo

# qmail-send/run
cat > /var/qmail/supervise/qmail-send/run << SEND_RUN_EOF
#!/bin/sh
exec /var/qmail/rc
SEND_RUN_EOF

chmod +x /var/qmail/supervise/qmail-send/run


# qmail-send/log/run
cat > /var/qmail/supervise/qmail-send/log/run << SEND_LOG_EOF
#!/bin/sh
PATH=/var/qmail/bin:/usr/local/bin:/usr/bin:/bin
exec setuidgid qmaill multilog t s50000000 n20 /var/log/qmail/qmail-send 2>&1
SEND_LOG_EOF

chmod +x /var/qmail/supervise/qmail-send/log/run

# qmail-smtpd/run - by JMS
curl -sL http://qmail.jms1.net/scripts/service-qmail-smtpd-run -o /var/qmail/supervise/qmail-smtpd/run
chmod +x /var/qmail/supervise/qmail-smtpd/run

# This script needs a little adjustment.
# The most important variables to fix for the time-being are: IP and SMTP_CDB. 
# You should also disable anything related to VALIDRCPTTO at this moment.
# - The SMTP_CDB variable needs to be set to the value: /etc/tcp/smtp.cdb
#   Its value should be '/etc/tcp/smtp.cdb' instead of '/etc/tcp.smtp.cdb'.
#   It is becuase in my qmailctl script, I have machanism to manage all files under /etc/tcp/ ,
#     not just one '/etc/tcp.smtp.cdb' .
# I have noticed that JMS has it set to correct value already. i.e. /etc/tcp/smtp.cdb
#
# - The IP is what qmail process will bind itself to.
#   So, IP needs to have the IP address of the ethernet interface of the VM, not the IP of the physical server.
#   It cannot be an IP of AWS EIP or ELB, etc. 
# 

echo "Please configure IP (and other variables) in /var/qmail/supervise/qmail-smtpd/run before starting qmail!"



# qmail-smtpd/log/run 

cat > /var/qmail/supervise/qmail-smtpd/log/run << SMTPD_LOG_EOF
#!/bin/sh
PATH=/var/qmail/bin:/usr/local/bin:/usr/bin:/bin
exec setuidgid qmaill multilog t s50000000 n20 /var/log/qmail/qmail-smtpd 2>&1
SMTPD_LOG_EOF

chmod +x /var/qmail/supervise/qmail-smtpd/log/run


# qmail-smtpd-tls/run 
SMTPD_TLS_RUN_FILE=/var/qmail/supervise/qmail-smtpd-tls/run

curl -sL http://qmail.jms1.net/scripts/service-qmail-smtpd-run -o ${SMTPD_TLS_RUN_FILE}
chmod +x ${SMTPD_TLS_RUN_FILE}

# This file is created using the same JMS script for smtpd/run, but various values are adjusted
sed -i 's/^SMTP_CDB=.*$/SMTP_CDB=\/etc\/tcp\/smtp-tls.cdb/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^PORT=.*$/PORT=587/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^FORCE_TLS=.*$/FORCE_TLS=1/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^MFCHECK=.*$/MFCHECK=0/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^AUTH=.*$/AUTH=1/'   ${SMTPD_TLS_RUN_FILE}
sed -i 's/^REQUIRE_AUTH=.*$/REQUIRE_AUTH=1/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^SPFBEHAVIOR=.*$/SPFBEHAVIOR=0/' ${SMTPD_TLS_RUN_FILE}

# enable these:
sed -i 's/^#\(SMTPGREETING=.*\)$/\1/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^#\(AUTH_CDB=.*\)$/\1/' ${SMTPD_TLS_RUN_FILE}

# disable these:
sed -i 's/^\(CHECKPW=.*$\)/#\1/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^\(TRUE=.*$\)/#\1/' ${SMTPD_TLS_RUN_FILE}
sed -i 's/^\(VALIDRCPTTO_CDB=.*$\)/#\1/' ${SMTPD_TLS_RUN_FILE}


# qmail-smtpd-tls/run 

cat > /var/qmail/supervise/qmail-smtpd-tls/log/run << SMTPD_TLS_LOG_EOF
#!/bin/sh
PATH=/var/qmail/bin:/usr/local/bin:/usr/bin:/bin
exec setuidgid qmaill multilog t s50000000 n20 /var/log/qmail/qmail-smtpd-tls 2>&1
SMTPD_TLS_LOG_EOF

chmod +x /var/qmail/supervise/qmail-smtpd-tls/log/run

# Note: You may add steps to setup  qmail-pop3/* - if you are using qmail-pop3 for POP3 service.
#       I am using dovecot for IMAP and POP3 , so I will not setup qmail's pop3 service.


echo
echo "------------------------------------------------------------------------------------"
echo


#   Before we actually configure qmail to start at system startup,
#     , it is time should make sure that no service is running on port 25, 
#     such as sendmail, postfix or exim. If they are running, it is time to stop them.

echo "Disabling any other MTAs on this system ... sendmail, postfix, exim"

systemctl disable sendmail postfix exim
systemctl stop sendmail postfix exim



echo
echo "------------------------------------------------------------------------------------"
echo


echo "Create the /etc/tcp/smtp file, and set it up as bare minimum - for now"
# You can enhance it later. TODO / post-install-configuration.
#
mkdir /etc/tcp

cat > /etc/tcp/smtp << ETC_TCP_SMTP_EOF
echo '127.:allow,RELAYCLIENT=""' >>/etc/tcp.smtp
ETC_TCP_SMTP_EOF

qmailctl cdb



echo
echo "------------------------------------------------------------------------------------"
echo


echo "Link the supervise directories into /service directory."
#   Please note that the qmail system will start automatically shortly after these links are created. 

ln -s /var/qmail/supervise/qmail-send       /service/
ln -s /var/qmail/supervise/qmail-smtpd      /service/
ln -s /var/qmail/supervise/qmail-smtpd-tls  /service/

# After the linking, the qmail system would now be running automatically. 
#  , and the qmail service should be up for more than one second.
# However, If the qmail-smtpd service seems to be stuck at 1 second,
#  , then it indicates a problem.  Most likely causes can be:
#  * The IP is not set to correct IP of the VM
#  * The VALIDRCPTTO is not set correctly
#  * The /etc/tcp/smtp.cdb file does not exist.


echo
echo "------------------------------------------------------------------------------------"
echo

echo "Setup qmail to start at system startup ..."
echo "Daemontools (already configured) will handle qmail startup at system boot time."
echo

echo
echo "------------------------------------------------------------------------------------"
echo


echo "Lastly, replace any existing /usr/lib/sendmail with the qmail version: (recommended)"
mv /usr/lib/sendmail /usr/lib/sendmail.old                  # ignore any errors
mv /usr/sbin/sendmail /usr/sbin/sendmail.old                # ignore any errors
chmod 000 /usr/lib/sendmail.old /usr/sbin/sendmail.old        # ignore any errors
ln -s /var/qmail/bin/sendmail /usr/lib
ln -s /var/qmail/bin/sendmail /usr/sbin



echo
echo "------------------------------------------------------------------------------------"
echo

echo "Create system email-aliases for qmail ..."

# To create these aliases, decide where you want each of them to go (a local user or a remote address),
#   and create and populate the appropriate .qmail files. 
# For example, say local user 'dave' is both the system and mail administrator, then:

# echo dave > /var/qmail/alias/.qmail-root
# echo dave > /var/qmail/alias/.qmail-postmaster
# ln -s .qmail-postmaster /var/qmail/alias/.qmail-mailer-daemon
# ln -s .qmail-postmaster /var/qmail/alias/.qmail-abuse
# chmod 644 /var/qmail/alias/.qmail-root /var/qmail/alias/.qmail-postmaster

# What I want to do is setup these links to point to postmaster@yourdomain.com . 
#   I will set them to postmaster@example.com .

echo postmaster@example.com  > /var/qmail/alias/.qmail-root
echo postmaster@example.com  > /var/qmail/alias/.qmail-postmaster
ln -s /var/qmail/alias/.qmail-postmaster /var/qmail/alias/.qmail-mailer-daemon
ln -s /var/qmail/alias/.qmail-postmaster /var/qmail/alias/.qmail-abuse
chmod 644 /var/qmail/alias/.qmail-root /var/qmail/alias/.qmail-postmaster


echo
echo "------------------------------------------------------------------------------------"
echo

# Post install configuration:

echo "qmail installation complete. Manual post-install-configuration required:"
echo
echo " You need to setup correct IP and VALIDRCPTTO ,"
echo "   and other settings in qmail-smtpd/run and qmail-smtpd-tls/run files"
echo "Then restart qmail by:  'qmailctl up ; qmailctl cdb; qmailctl start; qmailctl stat'" 
echo
# These steps cannot be performed while building the container, 
#   unless we PASS certain variables to the container in Dockerfile

# The following command will return the IP of the docker container ( from inside). 
#   It could be used in a docker-entrypoint.sh sctip to setup correct value for IP in smtpd/run and smtpd-tls/run.
#   Or, we could simply setup IP to 0.0.0.0 to listen on all interfaces.
# Command: ip addr show scope global label eth0 | grep -w inet | awk '{print $2}' | cut -f1 -d/
