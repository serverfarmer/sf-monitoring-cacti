#!/bin/sh

host="`hostname`"
path="/var/cache/cacti"

file="$path/lxc-$host.txt"

echo -n "date " >$file.new
date +%s >>$file.new

for ID in `/usr/bin/lxc-ls`
do
	eval `/usr/bin/lxc-info -H -n $ID |grep TX |awk '{printf "NETOUT=%s\n", $3}'`
	eval `/usr/bin/lxc-info -H -n $ID |grep RX |awk '{printf "NETIN=%s\n", $3}'`
	eval `/usr/bin/lxc-info -H -n $ID |grep Memory |awk '{printf "MEM=%s\n", $3}'`

	file2="$path/du-$ID.txt"
	if [ ! -s $file2 ] || [ `stat -c %Y $file2` -le `date -d '-1 hour' +%s` ]; then
		du -sb /var/lib/lxc/$ID 2>/dev/null |cut -f1 >$file2
	fi
	SIZE="`cat $file2`"

	echo "id:$ID netin:$NETIN netout:$NETOUT memory:$MEM size:$SIZE" >>$file.new
done

mv -f $file.new $file 2>/dev/null

/opt/farm/ext/monitoring-cacti/cron/send.sh $file
