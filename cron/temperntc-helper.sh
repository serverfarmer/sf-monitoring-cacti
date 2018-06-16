#!/bin/sh

host="`hostname`"
file="/var/cache/cacti/temperntc-$host.txt"

/opt/farm/ext/thermal-utils/sensors/temperntc.pl 2>/dev/null >$file.new

echo -n "date " >>$file.new
date +%s >>$file.new
mv -f $file.new $file 2>/dev/null

/opt/farm/ext/monitoring-cacti/cron/send.sh $file
