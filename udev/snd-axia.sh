#!/bin/bash
################################################################################
# snd-axia.sh - udev helper script for the snd-axia kernel module
################################################################################
#
# Copyright (C) 2017 Radio Bern RaBe
#                    Switzerland
#                    http://www.rabe.ch
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public 
# License as published  by the Free Software Foundation, version
# 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License  along with this program.
# If not, see <http://www.gnu.org/licenses/>.
#
# Please submit enhancements, bugfixes or comments via:
# https://github.com/radiorabe/systemd-axia-alsa
#
# Authors:
#  Christian Affolter <c.affolter@purplehaze.ch>
#
# Description:
# udev helper script for creating and removing the character device node
# (/dev/axia0) related to the snd-axia kernel module (Axia ALSA audio/network
# driver). This is required, as the snd-axia module doesn't expose the device
# information via sysfs.
#
# This script is supposed to be started from an udev rule via the RUN or IMPORT
# directive:
# - RUN{program}+="snd-axia.sh --mknod"
# - RUN{program}+="snd-axia.sh --rmnod"
# - IMPORT{program}+="snd-axia.sh --env"
# 
#
# Usage:
# snd-axia.sh [--mknode|--rmnode|--env]

# Get the major device number from /proc/devices
major=$( /usr/bin/awk '$2 == "axialivewire" { print $1; exit }' /proc/devices )

# Check that awk returned an integer
echo "${major}" | /usr/bin/grep --quiet --extended-regexp '^[0-9]+$'
test $? -eq 0 || exit 2

# The minor device number is hard coded, as only one device can exist
minor=0

# device node name
name="axia${minor}"

# device path (udev DEVNAME)
devName="/dev/${name}"

case "$1" in
    "--mknod")
        # Create the character device node
        /usr/bin/mknod "${devName}" c ${major} ${minor}
        exit $?
        ;;

    "--rmnod")
        # Removes the character device node
        /usr/bin/rm -f "${devName}"
        exit $?
        ;;

    "--env")
        # Print udev device properties for IMPORT{program}=...
        echo "NAME=${name}"
        echo "MAJOR=${major}"
        echo "MINOR=${minor}"
        echo "DEVNAME=${devName}"
        exit 0
        ;;

   *)
       # Invalid action
       exit 1
       ;;
esac
