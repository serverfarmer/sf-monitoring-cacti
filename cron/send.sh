#!/bin/sh
. /opt/farm/scripts/functions.custom

if [ "$1" = "" ]; then
	echo "no file given"
	exit 1
fi

scp -B -q -i /root/.ssh/id_cacti -o StrictHostKeyChecking=no -o PasswordAuthentication=no -P `cacti_ssh_port` $1 cacti-external@`cacti_ssh_target`/data 2>&1 |grep -v "lost connection"
