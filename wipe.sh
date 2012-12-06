#!/bin/bash
#
# Perform a SATA wipe on a given device.
#

device="$1"

# If the device is locked, assume we locked it.
if [ -z "`hdparm -I $device | grep 'not locked'`" ]; then
	hdparm --user-master u --security-unlock jban "$device"
	hdparm --user-master u --security-disable jban "$device"
fi

hdparm --user-master u --security-set-pass jban "$device"
hdparm --user-master u --security-erase-enhanced jban "$device"
