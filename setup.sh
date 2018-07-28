#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.dialog


/opt/farm/scripts/setup/extension.sh sf-cache-utils
/opt/farm/scripts/setup/extension.sh sf-thermal-utils

if [ "$HWTYPE" = "physical" ]; then
	/opt/farm/scripts/setup/extension.sh sf-monitoring-smart
fi

file="/etc/local/.config/cacti"

if [ ! -s $file.target ] && tty -s; then
	default="cacti.`external_domain`:/external"
	TARGET="`input \"enter Cacti target\" $default`"
	PORT="`input \"enter Cacti port\" 22000`"
	echo -n "$TARGET" >$file.target
	echo -n "$PORT" >$file.port
fi

if [ ! -s $file.target ]; then
	echo "skipping cacti configuration (no target configured)"
	exit 0
fi

if ! grep -q /opt/farm/ext/monitoring-cacti/cron /etc/crontab; then
	echo "setting up crontab entries"

	if [ -f /etc/lxc/default.conf ]; then
		echo "*/5 * * * * root /opt/farm/ext/monitoring-cacti/cron/lxc-helper.sh" >>/etc/crontab
	fi

	if [ -f /etc/vz/vz.conf ]; then
		echo "*/5 * * * * root /opt/farm/ext/monitoring-cacti/cron/vz-helper.sh" >>/etc/crontab
	fi

	if [ -f /etc/postfix/virtual_aliases ]; then
		echo "*/5 * * * * root /opt/farm/ext/monitoring-cacti/cron/mta-helper.sh" >>/etc/crontab
	fi

	if [ "$HWTYPE" = "physical" ]; then
		echo "1   * * * * root /opt/farm/ext/monitoring-cacti/cron/disklabel-helper.sh" >>/etc/crontab
	fi

	if [ "$HWTYPE" = "physical" ] || [ "$HWTYPE" = "oem" ]; then
		echo "*/5 * * * * root /opt/farm/ext/monitoring-cacti/cron/thermal-helper.sh" >>/etc/crontab
	fi
fi

if [ -d /etc/config/ssh ] && [ ! -d /root/.ssh ] && [ ! -h /root/.ssh ]; then
	ln -s /etc/config/ssh /root/.ssh
fi

if [ ! -f /root/.ssh/id_cacti ]; then
	echo "generating ssh key for cacti-external user"
	ssh-keygen -t rsa -f /root/.ssh/id_cacti -P ""

	echo "key generated, now paste the following public key into `cat $file.target`/.ssh/authorized_keys file:"
	cat /root/.ssh/id_cacti.pub
fi

# transitional code: get rid of cron/smart-helper.sh (moved to sf-monitoring-smart extension)
if grep -q /opt/farm/ext/monitoring-cacti/cron/smart-helper.sh /etc/crontab; then
	sed -i -e "/\/opt\/farm\/ext\/monitoring-cacti\/cron\/smart-helper.sh/d" /etc/crontab
fi
