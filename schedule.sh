#!/bin/bash

### Run as a normal user
if [ $EUID -eq 0 ]; then
    echo "This script shouldn't be run as root."
    exit 1
fi

## import common lib
. "$HOME/.noaa.conf"
. "$ISS_HOME/common.sh"
wget -qr http://www.celestrak.com/NORAD/elements/weather.txt -O "${ISS_HOME}"/predict/weather.txt
wget -qr http://www.celestrak.com/NORAD/elements/amateur.txt -O "${ISS_HOME}"/predict/amateur.txt
grep "NOAA 15" "${ISS_HOME}"/predict/weather.txt -A 2 > "${ISS_HOME}"/predict/weather.tle

if [ "$SCHEDULE_ISS" == "true" ]; then
    grep "ZARYA" "${ISS_HOME}"/predict/amateur.txt -A 2 > "${ISS_HOME}"/predict/amateur.tle


   





fi

#Remove all AT jobs
for i in $(atq | awk '{print $1}');do atrm "$i";done

#Schedule Satellite Passes:
if [ "$SCHEDULE_ISS" == "true" ]; then
    "${ISS_HOME}"/schedule_iss.sh "ISS (ZARYA)" 437.8000
fi
#"${NOAA_HOME}"/schedule_sat.sh "NOAA-15" 137.6200
