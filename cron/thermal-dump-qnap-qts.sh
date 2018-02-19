#!/bin/sh

sensor0=`getsysinfo systmp |cut -d' ' -f1`
echo "acpitz:0 core0:$sensor0 core1:0 core2:0 core3:0"
