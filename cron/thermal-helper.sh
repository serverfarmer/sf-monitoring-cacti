#!/bin/sh

host="`hostname`"
file="/var/cache/cacti/thermal-$host.txt"

/opt/farm/ext/thermal-utils/sensors/cpu.sh >$file.new

echo -n "date " >>$file.new
date +%s >>$file.new
mv -f $file.new $file 2>/dev/null

/opt/farm/ext/monitoring-cacti/cron/send.sh $file
