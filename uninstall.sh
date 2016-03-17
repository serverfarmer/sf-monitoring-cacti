#!/bin/sh

if grep -q /opt/farm/ext/monitoring-cacti/cron /etc/crontab; then
	sed -i -e "/\/opt\/farm\/ext\/monitoring-cacti\/cron/d" /etc/crontab
fi
