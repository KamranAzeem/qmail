#!/bin/bash
# Author: Muhammad Kamran Azeem
# Licence: GPL v2
# Created: 20130409
# Updated: 20130409
# Description: Checks the difference of auth.cdb and validrcptto.cdb with earlier versions of same files
#              If changes are found, the script restarts qmail service to load new values.
# Changelog: At the end of the script.
######################################################################################################### 

######## Start - User configurable Section
# Qmail directory. Adjust of your qmail lives somewhere else.
VQ=/var/qmail

# Path to qmailctl program
QMAILCTL=/usr/bin/qmailctl

# Path to ValidRCPTTo CDB file
VRCPTFILE=$VQ/control/validrcptto.cdb

# Path to Auth CDB file
AUTHFILE=$VQ/control/auth.cdb

# Path to mkauth program
MKAUTH=/usr/local/bin/mkauth

# Path to mkvalidrcptto program
MKVRCPT=/usr/local/bin/mkvalidrcptto

######## End - User configurable Section



# You don't need to modify anything in the section below.

######## Start - Actual program code

# mkauth -c /tmp/auth.cdb.new 
# mkvalidrcptto -c /tmp/validrcptto.cdb.new
# SUM1=$(md5sum auth.cdb | cut -f 1 -d ' ')
# SUM2=$(md5sum auth.cdb.new | cut -f 1 -d ' ')
# if [ "$SUM1" == "$SUM2" ] ; then echo "Equal" ; else echo "Different"; fi

# Check if the files exist
if [ -d $VQ ] && [ -x $QMAILCTL ] && [ -r $VRCPTFILE ] && [ -r $AUTHFILE ] && [ -x $MKAUTH ] && [ -x $MKVRCPT ] ; then 
  echo "Files specified in configuration section exist. Good! Proceeding to run the script" 
else
  echo "One of the files or programs is missing. Please check and re-run the script."
  exit 9
fi 

# Generate a new auth cdb file in /tmp:
$MKAUTH -c /tmp/auth.cdb.new

# Generate a new validrcptto file in /tmp:
$MKVRCPT -c /tmp/validrcptto.cdb.new

# Generate SUM of old and new auth file:
AUTHSUMOLD=$(md5sum $AUTHFILE | cut -f1 -d ' ')
AUTHSUMNEW=$(md5sum /tmp/auth.cdb.new | cut -f1 -d ' ')

# Generate SUM of old and new validrcptto file:
VRCPTSUMOLD=$(md5sum $VRCPTFILE | cut -f1 -d ' ')
VRCPTSUMNEW=$(md5sum /tmp/validrcptto.cdb.new | cut -f1 -d ' ')


if [ "$AUTHSUMOLD" != "$AUTHSUMNEW" ] || [ "$VRCPTSUMOLD" != "$VRCPTSUMNEW" ] ; then 
  logger -s "qmail - Auth CDB or ValidRCPTTo CDB has changed. Need to restart qmail with new CDBs."
  logger -s "qmail - Creating CDB $VRCPTFILE ..."
  $MKVRCPT -c $VRCPTFILE
  logger -s "qmail - Creating CDB $AUTHFILE ..."
  $MKAUTH -c $AUTHFILE
  $QMAILCTL restart
  logger -s "qmail - CDBs recreated. qmail service restarted."
else
  echo  "qmail - No changes found in Auth CDB or ValidRCPTTo CDB."
  # No need to fill the log with "No changes found" message
  # logger -s "qmail - No changes found in Auth CDB or ValidRCPTTo CDB."
fi

exit $?

######## End - Actual program code


