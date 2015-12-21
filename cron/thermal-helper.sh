#!/bin/sh

host="`hostname`"
file="/var/cache/cacti/thermal-$host.txt"

if [ "`cat /proc/cpuinfo |grep Hardware |grep QNAP`" = "" ]; then

	if [ "`cat /sys/class/dmi/id/product_name`" = "SBC-FITPC2" ]; then
		echo "`/opt/sf-monitoring-cacti/cron/thermal-dump-fitpc2.sh`" >$file.new
	else
		echo "`/opt/sf-monitoring-cacti/cron/thermal-dump-sensors.sh`" >$file.new
	fi

	echo -n "date " >>$file.new
	date +%s >>$file.new
	mv -f $file.new $file 2>/dev/null
fi

/opt/sf-monitoring-cacti/cron/send.sh $file