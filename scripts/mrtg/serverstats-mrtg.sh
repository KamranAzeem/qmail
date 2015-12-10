#!/bin/bash
# Author: Kamran Azeem
# Created: 2015-12-07
# Summary: Generate system stats used for MRTG.

# All MRTG need is a script which will output 4 lines of data.
# Line 1 -current state of the first variable, normally ‘incoming bytes count’
# Line 2 -current state of the second variable, normally ‘outgoing bytes count’
# Line 3 -string (in any human readable format), telling the uptime of the target.
# Line 4 -string, telling the name of the target.

#  It seems that the numbers must be integers.

case $1 in
  (cpu):
    # echo "CPU is /proc/cpuinfo"
    # return %age
    DATA=$(/bin/grep -w cpu /proc/stat | /bin/awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}' | awk '{print int($1)}' )
    DATASTRING="%CPU usage"
    ;;
  (load):
    # echo "Load average comes from uptime"
    DATA=$(/usr/bin/uptime | /bin/awk '{print $11 }' | /usr/bin/tr -d ',' | awk '{print int($1)}')
    DATASTRING="5 minute load average"
    ;;
  (memory):
    # echo "Memory stats come from /proc/meminfo"
    # Memory calculated is in MB
    MEMTOTAL=$(/bin/grep MemTotal /proc/meminfo | /bin/awk '{print $2 / 1024 }')
    MEMFREE=$(/bin/grep MemFree /proc/meminfo | /bin/awk '{print $2 / 1024 }')
    ## Note: expr and $(( number - number)) DOES NOT work in bash. I have to use bc. bc needs to be installed.
    DATA=$(echo "scale=3; ( ($MEMTOTAL - $MEMFREE) / $MEMTOTAL ) * 100 " | bc | awk '{print int($1)}')
    DATASTRING="%Memory usage"
    ;;
  (root):
    # echo "Root disk %"
    DATA=$(/bin/df  | /bin/grep -w "/" | /bin/awk '{print $5}' | /usr/bin/tr -d '%')
    DATASTRING="%disk - root (/)"
    ;;
  (home):
    # echo "Home partition %"
    DATA=$(/bin/df  | /bin/grep -w "/home" | /bin/awk '{print $5}' | /usr/bin/tr -d '%')
    DATASTRING="%disk - home (/home)"
    ;;
  (sent):
    echo "Numeber of emails sent today"
    ;;
  (received)
    echo "Number of emails received today (including spam)"
    ;;
  (blocked)
    echo "Number of rejected / blocked connections today."
    ;;
esac

# Display the stats for MRTG.
# Display same data value for both Incoming and Outgoing.
echo $DATA
echo $DATA
# Ideally I should display uptime here instead of 0. Will work on this later.
echo 0
echo $DATASTRING

exit $?

