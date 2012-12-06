#!/bin/bash
#
# James' Boot-And-Nuke
#
# This script does the actual work of identifying the HDDs and SSDs, and wiping
# them. 
#

wantsuspend=
devices=

timeoutsecs=`cat /proc/sys/kernel/hung_task_timeout_secs`
echo 0 > /proc/sys/kernel/hung_task_timeout_secs

# Get a list of valid block devices
for device in /sys/block/*; do
	target=`readlink -f "$device"`
	if [ -n "`echo "$target" | grep '^/sys/devices/virtual/'`" ]; then
		continue
	fi

	device="/dev/`basename $device`"
	# Skip CD drives
	if [ -n "`hdparm -I $device | grep 'CD-ROM'`" ]; then
		continue
	fi

	devices="$device $devices"
done

for device in $devices; do
	if [ -n "`hdparm -I $device | grep '^Security:'`" ]; then
		if [ -z "`hdparm -I $device | grep 'not frozen'`" ]; then
			wantsuspend="$device $wantsuspend"
		fi
	fi
done

if [ -n "$wantsuspend" ]; then
	echo
	echo "The following devices are locked:"
	for device in $wantsuspend; do
		echo "    $device"
	done
	echo
	echo "Press Return to suspend to RAM. After suspending, wake the"
	echo "computer to wipe these devices..."
	echo
	sleep 3

	echo 'mem' > /sys/power/state
fi

for device in $devices; do
	dash -m /sbin/sata_wipe $device &
done

wait
echo
echo "All drives finished wiping."
echo

echo $timeoutsecs > /proc/sys/kernel/hung_task_timeout_secs
