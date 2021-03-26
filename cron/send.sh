#!/bin/sh

file="/etc/local/.config/cacti"

if [ "$1" = "" ]; then
	echo "no file given"
	exit 1
elif [ ! -s $file.target ]; then
	echo "target not configured, aborting send"
	exit 1
fi

target="`cat $file.target`"
port="`cat $file.port`"

timelimit -q -t2 -T3 scp -B -q -i /root/.ssh/id_cacti -o StrictHostKeyChecking=no -o PasswordAuthentication=no -P $port $1 cacti-external@$target/data 2>&1 |grep -v "lost connection"
