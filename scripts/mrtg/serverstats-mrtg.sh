#!/bin/bash
# Author: Kamran Azeem
# Created: 2015-12-07
# Summary: Generate system stats used for MRTG.

# All MRTG need is a script which will output 4 lines of data.
# Line 1 -current state of the first variable, normally ‘incoming bytes count’ (Integer)
# Line 2 -current state of the second variable, normally ‘outgoing bytes count’ (Integer)
# Line 3 -string (in any human readable format), telling the uptime of the target.
# Line 4 -string, telling the name of the target.

#  It seems that the numbers must be integers.

case $1 in
  (cpu):
    # echo "CPU is /proc/cpuinfo"
    # return %age
    DATA1=$(/bin/grep -w cpu /proc/stat | /bin/awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' | awk '{print int($1)}' )
    DATA2=$DATA1
    DATASTRING="%CPU usage"
    ;;
  (load):
    # echo "Load average comes from uptime"
    DATA1=$(/usr/bin/uptime | /bin/awk '{print $11 }' | /usr/bin/tr -d ',' | awk '{print int($1)}')
    DATA2=$DATA1
    DATASTRING="5 minute load average"
    ;;
  (memory):
    # echo "Memory stats come from /proc/meminfo"
    # Memory calculated is in MB
    # Total amount of installed memory
    MEMTOTAL=$(/bin/grep -w MemTotal /proc/meminfo | /bin/awk '{print $2 / 1024 }')
    # Amount of free memory , normally the figure under the "free" column in the first line of the output from "free -m" command.
    MEMFREE=$(/bin/grep -w MemFree /proc/meminfo | /bin/awk '{print $2 / 1024 }')

    # The amount of memory being used as buffers and cached.
    MEMBUFFERS=$(/bin/grep -w Buffers /proc/meminfo | /bin/awk '{print $2 / 1024 }')
    MEMCACHED=$(/bin/grep -w Cached /proc/meminfo | /bin/awk '{print $2 / 1024 }')

    # The actual amount of free memory is actually the figure under the free column + amount alloted to buffers and cache.
    # This is because the when a (new) process is started and it needs memory, then system releases memory
    # from cached, and gives it to the new process. When there is no more memory for cached and buffers, and processes need more,
    # then the swapping starts. 
   
    # In order to calculate the amount of actual used memory, we need to do the following calculation:
    # Total memory - (free + buffers + cached) 

    ## Note: expr and $(( number - number)) DOES NOT work in bash. I have to use bc. bc needs to be installed.
    DATA1=$(echo "scale=3; ( $MEMTOTAL - ($MEMFREE + $MEMBUFFERS + $MEMCACHED) ) " | bc | awk '{print int($1)}')

    # We can plot the actual used (i.e. without buffers and cache) against the normal used (i.e. with buffers and cache).
    # This shoud be an interesting graph. We already have DATA1, we need DATA2.
    DATA2=$(echo "scale=3; ( $MEMTOTAL - $MEMFREE ) " | bc | awk '{print int($1)}')
    
    DATASTRING="Memory usage (MB)"

    ;;
  (root):
    # echo "Root disk %"
    DATA1=$(/bin/df  | /bin/grep -w "/" | /bin/awk '{print $5}' | /usr/bin/tr -d '%')
    DATA2=$DATA1
    DATASTRING="%disk - root (/)"
    ;;
  (home):
    # echo "Home partition %"
    DATA1=$(/bin/df  | /bin/grep -w "/home" | /bin/awk '{print $5}' | /usr/bin/tr -d '%')
    DATA2=$DATA1
    DATASTRING="%disk - home (/home)"
    ;;
  (sent):
    echo "Numeber of emails sent today"
    ;;
  (received)
    # echo "Number of emails received today (including spam)"
    LOGDATE=$(date +"%b %d")
    MAILCLEAN=$(grep -w "spamd: clean message" /var/log/maillog* | grep "$LOGDATE" | wc -l)
    MAILSPAM=$(grep -w "spamd: identified spam" /var/log/maillog* | grep "$LOGDATE" | wc -l)
    DATA1=$MAILCLEAN
    DATA2=$MAILSPAM
    DATASTRING="Incoming Mails (SPAM / Clean)"
    ;;
  (blocked)
    # echo "Number of rejected / blocked connections today at SMTP level."
    LOGDATE=$(date +"%Y-%m-%d")
    SMTPRBL=$(grep rblsmtpd  /var/log/qmail/qmail-smtpd/current | tai64nlocal | grep $LOGDATE | wc -l)
    DATA1=$SMTPRBL
    DATA2=$DATA1
    DATASTRING="SMTP blocked using RBL"
    ;;
  (network)
    INTERFACE=eth0
    # echo "Network traffic in MegaBytes"
    RX=$(ip -s link ls $INTERFACE | grep -A1 -w RX | grep -v RX | awk '{print int(($1 / 1024)/1024)}')
    TX=$(ip -s link ls $INTERFACE | grep -A1 -w TX | grep -v TX | awk '{print int(($1 / 1024)/1024)}')
    DATA1=$RX
    DATA2=$TX
    DATASTRING="Network traffic for $INTERFACE (MB)"
    ;;
  (*)
    echo "Usage: $0 cpu|memory|load|root|home|spam"
    exit 1
    ;; 
esac

# Display the stats for MRTG.
# Display same data value for both Incoming and Outgoing.
echo $DATA1
echo $DATA2
# Ideally I should display uptime here instead of 0. Will work on this later.
echo $(uptime)
echo $DATASTRING

exit $?

