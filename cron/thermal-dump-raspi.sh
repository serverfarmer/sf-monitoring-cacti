#!/bin/sh

sensor0=`/opt/vc/bin/vcgencmd measure_temp |sed -e s/temp=//g -e s/\'C//g`
echo "acpitz:0 core0:$sensor0 core1:0 core2:0 core3:0"

