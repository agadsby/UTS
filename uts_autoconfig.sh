#!/bin/bash
#
# Very simple script to automate the startup of VM370 and prime the card reader and tape
# ready for VM370 MAINT user to load UTS image
# Once sucessfully run user can "DIAL UTS" using VM370 terminal
#

TOP="${VMHOME:-$HOME/VM}"
cd $TOP

#
PORT=8081
VMHOST=localhost
RDRPORT=3505
CONSOLE="/cgi-bin/tasks/syslog"

# 
# helper function to send command to Hercules console
#
herccmd() {
	CMD=$@
	status=`curl --data-urlencode "command=$CMD" --data-urlencode "send=send" \
		-o /dev/null -s -w '%{http_code}\n' http://$VMHOST:$PORT$CONSOLE`
	if [ "$status" -ne "200" ]; then
		if [ "$status" -eq "000" ]; then
			echo "$0: No connection to host" >&2
		else
			echo "$0: Command error - status $status" >&2
		fi
		exit 1
	fi


}

#
# helper function to send card deck to VM RDR
#
vmrdr() {
	FILE=$1
	if [ ! -f $FILE -o ! -r $FILE ] ; then
		echo "$0: $FILE not readable" >&2
		exit 1
	fi
	nc $VMHOST $RDRPORT <$FILE
	if [ $? -ne 0 ] ; then
		echo "$0: Failed to send $FILE to $VMHOST:$RDRPORT" >&2
		exit 1
	fi
}

# helper send command toHercules console
echo "Start VM370 using a another session"
echo -n "Hit <Enter> when done : "
read line

echo "Enabling spool devices on VM370"
herccmd "/start all"
sleep 1

echo "Send UTS Config Cards to MAINT via RDR"
vmrdr cards/adduts_exec.cards
sleep 1

echo "Loading UTS installation tape on 0480"
herccmd devinit 0480 uts/tapes/Amdahl_UTS2.aws noring
sleep 1

cat <<! 
Using a 3270 window
LOGIN MAINT CPCMS
READCARD ADDUTS EXEC
ADDUTS

Once succesfully restarted use another 3270 window to DIAL UTS
login using root / root
To shutdown use 'vmcmd / shutdown' followed by 'vmcmd exit'
!
