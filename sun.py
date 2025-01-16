#!/usr/bin/env python3
import ephem
import time
import sys
timezone = -3 + time.localtime().tm_isdst
date = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(sys.argv[1])-(timezone*60*60)))

obs=ephem.Observer()
obs.lat='55.54'
obs.long='24.25'
obs.date = date

sun = ephem.Sun(obs)
sun.compute(obs)
sun_angle = float(sun.alt) * 57.2957795 # Rad to deg
print(int(sun_angle))
