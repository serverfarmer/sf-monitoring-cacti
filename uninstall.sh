#!/bin/sh

if grep -q /opt/sf-monitoring-cacti/cron /etc/crontab; then
	sed -i -e "/\/opt\/sf-monitoring-cacti\/cron/d" /etc/crontab
fi
