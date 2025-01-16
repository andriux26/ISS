#!/bin/bash

### Run as a normal user
if [ $EUID -eq 0 ]; then
    echo "This script shouldn't be run as root."
    exit 1
fi

## import common lib
. "$HOME/.noaa.conf"
. "$ISS_HOME/common.sh"

if pgrep "rtl_fm" > /dev/null
then
    log "There is an already running rtl_fm instance but I dont care for now, I prefer this pass" "INFO"
    pkill -9 -f rtl_fm
fi

# $1 = Satellite Name
# $2 = Frequency
# $3 = FileName base
# $4 = TLE File
# $5 = EPOC start time
# $6 = Time to capture
# $7 = Satellite max elevation

log "Starting rtl_fm record" "INFO"
timeout "${6}" /usr/local/bin/rtl_fm ${BIAS_TEE} -M fm -f 437.8M -s 48k -g $GAIN -E dc -E wav -E deemp -F 9 - | sox -t raw -r 48k -c 1 -b 16 -e s - -t wav "${ISS_OUTPUT}/audio/${3}.wav" rate 11025

log "Recording completed" "INFO"

sqlite3 "$ISS_HOME/panel.db" "insert into decoded_passes (pass_start, file_path, daylight_pass, sat_type, img_count) values ($5,\"$3\",1,2,0);"
log "Database updated with pass information" "INFO"

sqlite3 "$ISS_HOME/panel.db" "update predict_passes set is_active = 0 where (predict_passes.pass_start) in (select predict_passes.pass_start from predict_passes inner join decoded_passes on predict_passes.pass_start = decoded_passes.pass_start where decoded_passes.pass_start = $5);"
log "Marked operation as completed in database" "INFO"
