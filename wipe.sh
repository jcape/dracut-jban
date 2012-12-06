#!/bin/bash
#
# Perform a SATA wipe on a given device.
#

device="$1"

# Device does not support SATA erase, do it manually with "wipe" in 4-pass mode
if [ -z "`hdparm -I $device | grep '^Security'`" ]; then
	wipe -fqkFD $device &
else
	# If the device is locked, assume we locked it.
	if [ -z "`hdparm -I $device | grep 'not locked'`" ]; then
		hdparm --user-master u --security-unlock jban "$device"
		hdparm --user-master u --security-disable jban "$device"
	fi

	hdparm --user-master u --security-set-pass jban "$device"
	hdparm --user-master u --security-erase-enhanced jban "$device"
	hdparm -z "$device"
	sleep 1
	echo 
fi
echo "Finished wiping $device"
