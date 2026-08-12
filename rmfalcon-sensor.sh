#!/bin/bash
#Verify the falcon-sensor package is there
if [[ $EUID -ne 0 ]]; then
echo "You must run this script as root/sudo"
exit 1
fi

if ! dpkg -l falcon-sensor &>/dev/null; then
    echo "Falcon-Sensor is not installed. Move on from this machine."
    exit 0
else
    apt-get purge falcon-sensor -y
    if ! dpkg -l falcon-sensor &>/dev/null; then
        echo "Falcone sensor is removed"
    else
        echo "Falcon sensor is still present. Removal failed."
        exit 1
    fi
fi
