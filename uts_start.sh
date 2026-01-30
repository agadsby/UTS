#!/bin/sh
# This command file launches the VM/370 Community Edition
# with the UTS config file attached.
# Ensure that the Hercules executable (hercules) is in your path.
#
# TOP="${VMHOME:-$HOME/VM}"
# cd $TOP
#
configfile="conf/vm370uts.conf"
logfile="./log.txt"

if [ -r ${logfile} ]; then
   mv ${logfile} ${logfile}.1
fi
if [ -r ${configfile} ]; then
   if [ $# -eq 1 -a "$1" = "-b" ]; then 
   	# background
   	hercules --NoUI -f ${configfile} --logfile=${logfile} < /dev/null > /dev/null 2>&1 &
   else
	hercules -f ${configfile} --logfile=${logfile}
   fi
fi
