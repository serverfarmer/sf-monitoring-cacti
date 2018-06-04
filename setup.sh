#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom


/opt/farm/scripts/setup/extension.sh sf-standby-monitor

if [ "$HWTYPE" = "physical" ]; then
	/opt/farm/scripts/setup/extension.sh sf-monitoring-smart
fi

mkdir -p /var/cache/cacti

if ! grep -q /var/cache/cacti /etc/fstab && [ "$HWTYPE" = "physical" ]; then
	echo "tmpfs /var/cache/cacti tmpfs noatime,size=16m 0 0" >>/etc/fstab
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

	echo "key generated, now paste the following public key into `cacti_ssh_target`/.ssh/authorized_keys file:"
	cat /root/.ssh/id_cacti.pub
fi

# transitional code: get rid of cron/smart-helper.sh (moved to sf-monitoring-smart extension)
if grep -q /opt/farm/ext/monitoring-cacti/cron/smart-helper.sh /etc/crontab; then
	sed -i -e "/\/opt\/farm\/ext\/monitoring-cacti\/cron\/smart-helper.sh/d" /etc/crontab
fi
