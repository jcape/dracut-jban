#!/bin/bash
#
# James' Boot-And-Nuke
#
# This script does the actual work of identifying the HDDs and SSDs, and wiping
# them. 
#

wantsuspend=""
devices=""

function sata_wipe() {
	# If the device is locked, assume we locked it.
	if [ -z "`hdparm -I  | grep 'not locked'`" ]; then
		hdparm --user-master u --security-unlock jban "$device"
		hdparm --user-master u --security-disable jban "$device"
	fi

	hdparm --user-master u --security-set-pass jban "$device"
	hdparm --user-master u --security-erase-enhanced jban "$device"
}

# Get a list of valid block devices
for device in /sys/block/*; do
	target=`readlink -f "$device"`
	if [ -n "`echo "$target" | grep '^/sys/devices/virtual/'`" ]; then
		continue
	fi

	device="/dev/`basename $device`"
	# Skip CD drives
	if [ -n "`echo -e "`hdparm -I $device`" | grep 'CD-ROM'`" ]; then
		continue
	fi

	devices="$device $devices"
done

for device in $devices; do
	if [ -z "`hdparm -I $device | grep 'not frozen'`" ]; then
		wantsuspend="$device $wantsuspend"
	fi
done

if [ 0 -lt $wantsuspend ]; then
	echo
	echo "The following devices are locked:"
	for $device in $wantsuspend; do
		echo "    $device"
	done
	echo
	echo "Press Return to suspend to RAM. After suspending, wake the"
	echo "computer to wipe these devices..."
	echo
	read

	echo 'mem' > /sys/power/state
fi

for device in $devices; do
	sata_wipe $device &
done
