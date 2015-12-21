#!/bin/sh

host="`hostname`"
file="/var/cache/cacti/temperntc-$host.txt"

echo "`/opt/sf-monitoring-cacti/cron/temperntc-monitor.pl`" >$file.new

echo -n "date " >>$file.new
date +%s >>$file.new
mv -f $file.new $file 2>/dev/null

/opt/sf-monitoring-cacti/cron/send.sh $file
