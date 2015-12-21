#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom


bash /opt/farm/scripts/setup/role.sh sf-standby-monitor

mkdir -p /var/cache/cacti

if ! grep -q /var/cache/cacti /etc/fstab && [ "$HWTYPE" = "physical" ]; then
	echo "tmpfs /var/cache/cacti tmpfs noatime,size=16m 0 0" >>/etc/fstab
fi

if grep -q /opt/farm/scripts/cacti /etc/crontab; then
	echo "removing old crontab entries"
	sed -i -e "/farm\/scripts\/cacti\//d" /etc/crontab
fi

if ! grep -q /opt/sf-monitoring-cacti/cron /etc/crontab; then
	echo "setting up crontab entries"

	if [ -f /etc/postfix/virtual_aliases ]; then
		echo "*/5 * * * * root /opt/sf-monitoring-cacti/cron/mta-helper.sh" >>/etc/crontab
	fi

	if [ "$HWTYPE" = "physical" ]; then
		echo "*/5 * * * * root /opt/sf-monitoring-cacti/cron/smart-helper.sh" >>/etc/crontab
		echo "*/5 * * * * root /opt/sf-monitoring-cacti/cron/thermal-helper.sh" >>/etc/crontab
		echo "1   * * * * root /opt/sf-monitoring-cacti/cron/disklabel-helper.sh" >>/etc/crontab
	fi
fi

if [ ! -f /root/.ssh/id_cacti ]; then
	echo "generating ssh key for cacti-external user"
	ssh-keygen -t rsa -f /root/.ssh/id_cacti -P ""

	echo "key generated, now paste the following public key into `cacti_ssh_target`/.ssh/authorized_keys file:"
	cat /root/.ssh/id_cacti.pub
fi
