#!/bin/bash
#
# James' Boot-And-Nuke
#
# This script does the actual work of identifying the HDDs and SSDs, and wiping
# them. 
#

for device in /sys/block/*; do
	target=`readlink -f "$device"`
	if [ -n "`echo "$target" | grep '^/sys/devices/virtual/'`" ]; then
		continue
	fi

	device="/dev/`basename $device`"
	hdpout="`hdparm -I $device`"
	if [ -n "`echo -e "$hdpout" | grep 'CD-ROM'`" ]; then
		continue
	fi

	echo "Attempting to use SATA commands to securely erase $device"

	# If the device is marked as frozen, suspend (requires external
	# intervention to wake and continue nuking).
	if [ -z "`echo -e "$hdpout" | grep 'not frozen'`" ]; then
		echo "ERROR: Could not wipe because 'not frozen' was not found in the hdparm output."
		echo -e "$hdpout"
	fi

	# Assume if it's locked that we're the one that locked it
	if [ -z "`echo -e "$hdpout" | grep 'not locked'`"]; then
		hdparm --user-master u --security-unlock jban "$device"
		hdparm --user-master u --security-disable jban "$device"
	fi

	hdparm --user-master u --security-set-pass jban "$device"
	hdparm --user-master u --security-erase-enhanced jban "$device"
	echo "Done"

	if [ -z "`echo -e "$hdpout" | grep -i 'SSD'`" ]; then
		echo "Using wipe command against $device"
		wipe -kDf "$device"
		echo "Done"
	fi
done

