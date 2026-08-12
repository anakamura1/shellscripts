#!/bin/bash
#Verify the falcon-sensor package is there
dpkg -l | grep falcon-sensor
if [ $? -gt 0 ]; then
    echo "Falcon-Sensor is not installed. Move on from this machine."
    exit 0
else
    sudo apt-get purge falcon-sensor -y
    dpkg -l | grep falcon-sensor
    if [ $? -gt 0 ]; then
        echo "Falcone sensor is removed"
        exit 0
    fi
fi
