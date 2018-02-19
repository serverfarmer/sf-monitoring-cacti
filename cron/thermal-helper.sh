#!/bin/sh

host="`hostname`"
file="/var/cache/cacti/thermal-$host.txt"

if [ "`cat /proc/cpuinfo |grep Hardware |grep QNAP`" = "" ]; then  # don't do anything on QNAP with Debian

	if [ -f /etc/config/qpkg.conf ]; then  # still support QNAP with original QTS firmware
		echo "`/opt/farm/ext/monitoring-cacti/cron/thermal-dump-qnap-qts.sh`" >$file.new
	elif [ -f /etc/rpi-issue ]; then
		echo "`/opt/farm/ext/monitoring-cacti/cron/thermal-dump-raspi.sh`" >$file.new
	elif [ "`cat /sys/class/dmi/id/product_name`" = "SBC-FITPC2" ]; then
		echo "`/opt/farm/ext/monitoring-cacti/cron/thermal-dump-fitpc2.sh`" >$file.new
	else
		echo "`/opt/farm/ext/monitoring-cacti/cron/thermal-dump-sensors.sh`" >$file.new
	fi

	echo -n "date " >>$file.new
	date +%s >>$file.new
	mv -f $file.new $file 2>/dev/null
fi

/opt/farm/ext/monitoring-cacti/cron/send.sh $file
