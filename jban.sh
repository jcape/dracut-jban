#!/bin/bash
#
# James' Boot-And-Nuke
#
# This script does the actual work of identifying the HDDs and SSDs, and wiping
# them. 
#

function wipehdd() {
	device="$1"
	
}

function wipessd() {
	hdparm --user-master u --security-set-pass jban

}

for device in /sys/block/*; do
	target=$(readlink -f "$device")
	if [ "/sys/devices/virtual/" == "${target:0:21}" ]; then
		continue
	fi

	device="/dev/$(basename $device)"
	hdpout="$(hdparm -I $device)"
	if [ -n "$(echo -e "$hdpout" | grep 'CD-ROM')" ]; then
		continue
	fi

	if [ -n "$(echo -e "$hdpout" | grep -i 'SSD')" ]; then

		# If the device is marked as frozen, suspend (requires external
		# intervention to wake and continue nuking).
		if [ -z "$(echo -e "$hdpout" | grep 'not frozen')" ]; then
			echo -n mem > /sys/power/state
		fi

		# Assume if it's locked that we're the one that locked it
		if [ -z "$(echo -e "$hdpout" | grep 'not locked')"]; then
			hdparm --user-master u --security-unlock jban "$device"
			hdparm --user-master u --security-disable jban "$device"
		fi

		hdparm --user-master u --security-set-pass jban "$device"
		hdparm --user-master u --security-erase-enhanced jban "$device"
	else
		wipe -kDf "$device"
	fi
done

