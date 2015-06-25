# TimeLapse

## tl-gen.sh

tl-gen.sh is a back-end video timelapse generation script.  If you run the script with no arguments it will give you the syntax and argument definition.

It's input files are dated files in the form of '[Camera]/YYYY/MM/DD/YYYYMMDD\_hhmmss.jpg' from the home directory (the `home` variable at the top of the script).  [Camera] is an argument passed in and YYYY is the year, MM the month, DD the day, hh the hour in 24-hour format, mm the minute, and ss the seconds.  All values are 0 padded where needed and the time and date is assumed to be UTC.

It is reliant and always will be on gstreamer.  It should work with a standard gstreamer installation with the x264 module and will (eventually) make use of Raspberry Pi's hardware accelerated encoding.  At this time it is also reliant on GNU date though that may change if it becomes problematic.  Outside of that it should be a POSIX/SUS complaint shell script.

Copyright (C) APRS World, LLC. 2015
ALL RIGHTS RESERVED!
david@aprsworld.com
