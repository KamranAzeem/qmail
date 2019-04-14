#!/bin/bash

# Description
# This script is a mutitpurpose script. It can:
# * generate a certificate for a domain
# * renew the certificate
# * copy the certificates into qmail and dovecot SSL certificate locations, 
#   in the way (file format) those two services expect.


######################### START - USER CONFIGURATION ########################
#
#
#


# MAIN_DOMAIN:
# The (main) domainname / fqdn to create the ssl certificate. 
# The first domain provided (here MAIN_DOMAIN) will be the subject CN of the certificate, 
# The first domain will also be used in some software user interfaces, 
#   and as the file paths for the certificate and related material.
# During certificate creation, a directory with this name will be created under '/etc/letsencrypt/live/'.
#   e.g. /etc/letsencrypt/live/mail.ora-tech.com 

MAIN_DOMAIN='mail.ora-tech.com'


# ADDITIONAL_DOMAINS are list of comma delimited domains/fqdns you want as part of this certificate.
# All domains listed under ADDITIONAL_DOMAINS  will be Subject Alternative Names (SAN) on the certificate.
# This can be set to empty too.

ADDITIONAL_DOMAINS='mail2.ora-tech.com,imap.ora-tech.com,smtp.ora-tech.com'


# WEB_ROOT is the web directory which serves web content through your FQDN, through your web-server/apache.
# LetsEncrypt/Certbot will place some temporary files in this location to complete it's http challenge.
# So it is important that this location is setup as DOCUMENT_ROOT in the web server configuration 
#   for the domain you are interested in. It could be in a vhost configuration related to that domain.
WEB_ROOT=/var/www/html


# ADMIN_EMAIL:
# THe email on which LETSENCRYPT will send important information about your certificate, including verification.
ADMIN_EMAIL='kamranazeem@gmail.com'

# CHALLENGE_METHOD:
# This is the challenge which LETSENCRYPT will use to verify ownership of your domain. 
# For wildcard certificates, you will need to use the 'dns' challenge. (Not used by this script)
# For FQDN certificates, you have to use http challenge. (Used by this script). (Default).
# The ACME challenges are versioned. You can specify as http-01. 
#   If you don't mention the version, the latest version of the challenge is used.
# For most cases, you do not need to change it.
CHALLENGE_METHOD='http'


# complate path of letsencrypt's certbot's binary:
LETSENCRYPT='/opt/certbot/letsencrypt-auto'


# location of letsencrypt's certbot's config directory. Normally, you don't need to change this.
LETSENCRYPT_CONFIG_DIR='/etc/letsencrypt/'

# The user of the script does not have to modify anything beneath this line.

#
#
#
######################### END - USER CONFIGURATION #########################




######################### START - SYSTEM VARIABLES ############################
#
#
#

ACTION="$1"

ALL_DOMAINS="${MAIN_DOMAIN},${ADDITIONAL_DOMAINS}"

TIMESTAMP=$(date +%F_%H-%M)

#
#
#
######################### END - SYSTEM VARIABLES ##############################




######################### START - FUNCTIONS ############################
#
#
#

function create_certonly() {
# CREATE:
echo
echo "Creating LetsEncrypt certificate with the following details:"
echo "WEB_ROOT: ${WEB_ROOT}"
echo "CHALLENGE_METHOD: ${CHALLENGE_METHOD}"
echo "ALL_DOMAINS: ${ALL_DOMAINS}"
echo "ADMIN_EMAIL: ${ADMIN_EMAIL}"
echo

${LETSENCRYPT} certonly \
  --non-interactive \
  --webroot --webroot-path ${WEB_ROOT} \
  --preferred-challenges ${CHALLENGE_METHOD} \
  -d ${ALL_DOMAINS} \
  --email ${ADMIN_EMAIL} \
  --renew-by-default \
  --agree-tos \
  --text
}

function renew_certificate() {
# RENEW:
echo
echo "Attempting to RENEW LetsEncrypt certificate..."
echo
# echo "WEB_ROOT: ${WEB_ROOT}"
# echo "CHALLENGE_METHOD: ${CHALLENGE_METHOD}"
# echo "ALL_DOMAINS: ${ALL_DOMAINS}"
# echo "ADMIN_EMAIL: ${ADMIN_EMAIL}"


${LETSENCRYPT} renew --deploy-hook "/usr/local/bin/letsencrypt-cert-helper.sh restart_services"

}


#
#
#
######################### END - FUNCTIONS ##############################


######################### START - MAIN PROGRAM ############################
#
#
#

case ${ACTION} in

generate_certonly)

# call the generate_certonly function
generate_certonly
;;

renew)
# Call the renew_certificate function
renew_certificate
;;

restart_services)
## This simply/essentially restarts apache, qmail and dovecot, after renewal is successful.

# restart apache:
service httpd restart

# restart dovecot
service dovecot restart

# fix qmail certificate and restart qmail, using the same program with different argument (qmail)
source /usr/local/bin/letsencrypt-cert-helper.sh qmail 

;;

qmail)
# copy the certificates into qmail after adjusting them a bit
echo "Backing up existing qmail cert file as /root/qmail.servercert.pem.${TIMESTAMP}"
cp /var/qmail/control/servercert.pem /root/qmail.servercert.pem.${TIMESTAMP}
echo "Preparing letsencrypt generated certificate for qmail use"
cat ${LETSENCRYPT_CONFIG_DIR}/live/${MAIN_DOMAIN}/privkey.pem \
    ${LETSENCRYPT_CONFIG_DIR}/live/${MAIN_DOMAIN}/fullchain.pem > /var/qmail/control/servercert.pem
chmod 0640 /var/qmail/control/servercert.pem
chown root:nofiles /var/qmail/control/servercert.pem
echo "Restarting qmail service"
qmailctl restart
;;

dovecot)
# copy the generated certificates for dovecot
# dovecot uses the same certs directly from letsencrypt directory, so there is nothing to be done here.
;;


show_certificate_detail)
openssl x509 -in ${LETSENCRYPT_CONFIG_DIR}/live/${MAIN_DOMAIN}/fullchain.pem -text
;;


*) 
echo "Valid options are: generate_certonly, renew, qmail, show_certificate_detail, restart_services"
echo "Current certificates for ${MAIN_DOMAIN} are:"
ls -l ${LETSENCRYPT_CONFIG_DIR}/live/${MAIN_DOMAIN}/
;;

esac

#
#
#
######################### END - MAIN PROGRAM ##############################



